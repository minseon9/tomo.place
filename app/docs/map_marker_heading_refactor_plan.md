# Execution Plan

## Requested Task
- `custom_marker_factory.dart`, `heading_calculator.dart`의 과도한 구현 단순화 및 대체
- atoms 하위에 현재 위치 마커, 방향 화살표 마커 구현
- molecules에 두 atoms를 묶어 일관되게 취급되도록 구성
- `google_location_service.dart`, `location_service.dart` 비사용. Location 패키지 스트림만 사용하도록 구조화
- `location_stream_service.dart`, `google_location_stream_service.dart`가 Location 패키지와의 의존이 분리되도록 리팩터링
- `map_renderer.dart`, `google_map_renderer.dart`에서 마커 갱신·애니메이션 전략 반영
- 현재 위치/방향 마커가 자연스럽게(위치/회전 애니메이션) 업데이트되도록 설계 및 예시 제공

## Identified Context
- 현재 `CustomMarkerFactory`는 Canvas 기반 동적 비트맵 생성으로 복잡도가 높음. 요구사항은 기본적으로 SVG 아이콘을 활용하는 단순한 atoms 구성이 적합
- `HeadingCalculator`는 방위각 계산, 카디널 문자열 변환 등 과한 책임을 가짐. 실제 지도 표시에는 기기 heading의 정규화 및 최단 회전 계산 정도면 충분
- 현재 스트리밍 계층은 `LocationService`와 `GoogleLocationService`를 통해 위치/heading을 제공하지만, 2차 목표로 이 계층을 제거하고 Location 패키지의 스트림에 직접 의존하려는 요구
- `GoogleMap`의 `Marker`는 `position`, `rotation`, `anchor`를 지원. 회전 애니메이션은 `rotation` 값을 주기적으로 갱신하는 방식으로 구현 가능. 위치 애니메이션은 `LatLngTween`으로 보간 후 주기적 마커 재구성으로 가능
- heading은 기기 센서/OS에 따라 미보고되는 경우가 있어, 대안으로 이전/현재 위치를 통한 bearing 보정 또는 별도 나침반 패키지 연동 고려 필요

## Execution Plan
1. 1차 목표: 마커/헤딩 단순화 및 UI 레이어 정리
   - 1.1 atoms 추가
     - 파일: `app/lib/domains/map/presentation/widgets/atoms/current_location_marker_atom.dart`
     - 파일: `app/lib/domains/map/presentation/widgets/atoms/direction_arrow_atom.dart`
     - 역할: SVG 아이콘 기반의 단순 마커(현재 위치, 방향 화살표) → `BitmapDescriptor` 생성 유틸 포함
   - 1.2 molecules 추가
     - 파일: `app/lib/domains/map/presentation/widgets/molecules/location_with_direction_marker_molecule.dart`
     - 역할: 항상 함께 노출되어야 하는 현재 위치 + 방향 화살표를 하나의 조합 단위로 관리 (UI 오버레이용 위젯 형태 + 지도 마커용 비트맵 생성기 제공)
   - 1.3 기존 유틸 정리
     - `custom_marker_factory.dart` 제거(또는 deprecate) → atoms의 `fromSvgToBitmapDescriptor`로 대체
     - `heading_calculator.dart` 제거(또는 deprecate) → 데이터 레이어의 `HeadingNormalizer`로 단순화(정규화/최단회전 차이 계산만)

2. 2차 목표: 스트림 계층 단순화와 의존성 역전
   - 2.1 스트림 소스 추상화
     - 파일: `app/lib/domains/map/data/stream/position_stream_source.dart`
     - 인터페이스: `Stream<LatLng> get position$`, `Stream<double> get heading$`, `Stream<EnhancedLocation> get enhanced$`
   - 2.2 Location 패키지 구현체
     - 파일: `app/lib/domains/map/data/stream/location_package_position_stream_source.dart`
     - 역할: Location 패키지만 사용해 스트림 제공. heading 미보고 시 보정(bearing 계산) 옵션 제공
   - 2.3 기존 `GoogleLocationStreamService` 리팩터링
     - 파일: `app/lib/domains/map/data/map/google/google_location_stream_service.dart`
     - 변경: 내부 의존을 `PositionStreamSource`로 교체. 거리/정확도 필터·브로드캐스트만 담당하는 어댑터 역할로 축소
   - 2.4 heading 가능 여부 점검 및 폴백 전략
     - 우선순위: (1) Location.heading → (2) 보간 bearing(이전/현재 위치) → (3) 추후 나침반 패키지 연동 옵션 유지

3. 3차 목표: MapRenderer 반영
   - 3.1 `MapRenderer`/`GoogleMapRenderer`는 외부에서 주입되는 `Set<Marker>`를 그대로 렌더. 인터페이스 변경 없이 애니메이션 전략만 상위에서 수행
   - 3.2 `MapRendererOptions`는 그대로 유지. 필요 시 `compassEnabled` 같은 표시용 옵션만 추가 검토(기능 자체는 상위에서 처리)

4. 4차 목표: 부드러운 위치/방향 애니메이션
   - 4.1 위치 애니메이션: `LatLngTween` + `AnimationController`로 보간, 60fps 타이머로 마커 재구성
   - 4.2 회전 애니메이션: 최단 회전 경로 계산 후 `Tween<double>` 보간으로 `Marker.rotation` 주기 갱신
   - 4.3 앵커 최적화: `anchor: Offset(0.5, 0.5)`(중심 회전), 필요 시 화살표 꼬리 기준 조정

## Code Examples (핵심 스니펫)

### 1) atoms: SVG → BitmapDescriptor 변환 유틸
```dart
// app/lib/domains/map/presentation/widgets/atoms/marker_bitmap_utils.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerBitmapUtils {
  static Future<BitmapDescriptor> fromSvgAsset({
    required String assetPath,
    double size = 48,
    Color? color,
  }) async {
    final PictureInfo pictureInfo = await vg.loadPicture(
      SvgAssetLoader(assetPath, theme: SvgTheme(currentColor: color)),
      null,
    );
    final ui.Picture picture = pictureInfo.picture;
    final ui.Image image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }
}
```

```dart
// app/lib/domains/map/presentation/widgets/atoms/current_location_marker_atom.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'marker_bitmap_utils.dart';

class CurrentLocationMarkerAtom {
  static Future<BitmapDescriptor> icon({double size = 48}) {
    return MarkerBitmapUtils.fromSvgAsset(
      assetPath: 'assets/icons/my_icon.svg',
      size: size,
    );
  }
}
```

```dart
// app/lib/domains/map/presentation/widgets/atoms/direction_arrow_atom.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'marker_bitmap_utils.dart';

class DirectionArrowAtom {
  static Future<BitmapDescriptor> icon({double size = 56}) {
    // 신규 아이콘이 없다면 우선 임시 동일 아이콘 사용 후 교체
    return MarkerBitmapUtils.fromSvgAsset(
      assetPath: 'assets/icons/location_share_icon.svg',
      size: size,
    );
  }
}
```

### 2) molecules: 두 아이콘을 하나의 마커로 취급
```dart
// app/lib/domains/map/presentation/widgets/molecules/location_with_direction_marker_molecule.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../atoms/current_location_marker_atom.dart';
import '../atoms/direction_arrow_atom.dart';

class LocationWithDirectionMarkerMolecule {
  // 실제 GoogleMap Marker에서는 rotation으로 화살표를 회전시키고,
  // 현재 위치 아이콘은 화살표와 동일 비트맵 내에 포함시킬 수도 있으나,
  // 단순화를 위해 화살표 아이콘 1개만 사용 + 회전으로 표현한다.
  static Future<BitmapDescriptor> combinedIcon({
    double baseSize = 56,
  }) async {
    // 1차: 단일 화살표 아이콘 사용 (rotation으로 표현)
    return DirectionArrowAtom.icon(size: baseSize);
  }
}
```

### 3) heading 단순화 (데이터 레이어)
```dart
// app/lib/domains/map/data/heading/heading_normalizer.dart
class HeadingNormalizer {
  static double normalize(double heading) {
    double h = heading % 360;
    return h < 0 ? h + 360 : h;
  }

  static double shortestDelta(double from, double to) {
    double diff = (to - from) % 360;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    return diff;
  }
}
```

### 4) 스트림 계층 의존성 역전
```dart
// app/lib/domains/map/data/stream/position_stream_source.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EnhancedLocation {
  final LatLng position;
  final double accuracy;
  final double heading; // 센서 또는 보정값
  final DateTime timestamp;
  const EnhancedLocation(this.position, this.accuracy, this.heading, this.timestamp);
}

abstract class PositionStreamSource {
  Stream<LatLng> get position$;
  Stream<double> get heading$; // 미보고 시 0 또는 null 대체 가능
  Stream<EnhancedLocation> get enhanced$;
}
```

```dart
// app/lib/domains/map/data/stream/location_package_position_stream_source.dart
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'position_stream_source.dart';

class LocationPackagePositionStreamSource implements PositionStreamSource {
  final loc.Location _location = loc.Location();
  final _pos = StreamController<LatLng>.broadcast();
  final _head = StreamController<double>.broadcast();
  final _enh = StreamController<EnhancedLocation>.broadcast();

  StreamSubscription<loc.LocationData>? _sub;

  LocationPackagePositionStreamSource() {
    _sub = _location.onLocationChanged.listen((d) {
      if (d.latitude == null || d.longitude == null) return;
      final LatLng p = LatLng(d.latitude!, d.longitude!);
      final double acc = (d.accuracy ?? 0).toDouble();
      final double hdg = (d.heading ?? 0).toDouble(); // 미보고 시 0
      _pos.add(p);
      _head.add(hdg);
      _enh.add(EnhancedLocation(p, acc, hdg, DateTime.now()));
    });
  }

  @override
  Stream<LatLng> get position$ => _pos.stream;
  @override
  Stream<double> get heading$ => _head.stream;
  @override
  Stream<EnhancedLocation> get enhanced$ => _enh.stream;

  void dispose() {
    _sub?.cancel();
    _pos.close();
    _head.close();
    _enh.close();
  }
}
```

```dart
// app/lib/domains/map/data/map/google/google_location_stream_service.dart (핵심 변경만)
// 내부 의존을 LocationService → PositionStreamSource로 교체하여 데이터 소스 분리
class GoogleLocationStreamService /* implements LocationStreamService */ {
  final PositionStreamSource _source;
  GoogleLocationStreamService(this._source);

  // 기존 필터/브로드캐스트 책임만 유지
  // _source.enhanced$ 를 구독해 distance/accuracy 필터 후 app 전역 스트림으로 내보냄
}
```

### 5) MapRenderer는 변경 최소화, 상위에서 애니메이션 적용
```dart
// app/lib/domains/map/presentation/widgets/organisms/current_location_marker_widget.dart (요지)
class _LocationStreamWidgetState extends ConsumerState<LocationStreamWidget> {
  static const _markerId = MarkerId('current_location_with_direction');
  Set<Marker> _markers = {};

  // 애니메이션 상태
  late AnimationController _posCtl;
  late AnimationController _rotCtl;
  late Animation<LatLng> _posTween;
  late Animation<double> _rotTween;
  LatLng? _displayPos;
  double _displayBearing = 0;
  double _actualBearing = 0;

  Future<void> _updateMarker(LatLng pos, double bearing, BitmapDescriptor icon) async {
    _markers = {
      Marker(
        markerId: _markerId,
        position: pos,
        icon: icon,
        rotation: bearing,
        anchor: const Offset(0.5, 0.5),
      )
    };
    ref.read(locationMarkersProvider.notifier).state = _markers;
  }
}
```

### 6) 최단 회전 경로와 애니메이션 예시
```dart
double _shortestRotation(double from, double to) {
  double diff = (to - from) % 360;
  if (diff > 180) diff -= 360;
  if (diff < -180) diff += 360;
  return from + diff; // from → to 로 가는 최단 목표각
}
```

## Progress Status
1. atoms 설계/스니펫 작성 [Done]
2. molecules 설계/스니펫 작성 [Done]
3. heading 단순화 규칙 정의 [Done]
4. 스트림 소스 추상화 설계 [Done]
5. Location 패키지 구현체 설계 [Done]
6. GoogleLocationStreamService 의존 역전 설계 [Done]
7. MapRenderer 변경 전략 정리 [Done]
8. 위치/회전 애니메이션 스니펫 [Done]
9. 실제 코드 반영 및 파일 생성 [Pending]
10. 기존 파일(deprecate/삭제) 처리 [Pending]
11. 테스트 및 실기기 검증(heading 제공/정확도/배터리 영향) [Pending]

## Suggested Next Tasks
- 방향 아이콘 전용 SVG(`assets/icons/direction_arrow.svg`) 추가 및 디자인 가이드 반영
- heading 미보고 환경(iOS 시뮬레이터, 정지 상태 등)에서의 보정 전략 실측 튜닝(임계값, 관성)
- 애니메이션 빈도/주기 최적화로 배터리 영향 최소화(프레임 스로틀링, 변화량 기준 갱신)
- UI 오버레이(위젯) 방식과 지도 마커 방식 비교 테스트 후 최종 채택
- 리그레션 테스트: 기존 마커/권한/스트림 로직과의 충돌 여부 점검


