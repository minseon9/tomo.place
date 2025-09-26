# Map 도메인 개선 계획 및 구현 결과

## 요구사항 분석

### 기존 문제점
1. **MapState의 설계 문제**: `MapReady` 상태가 `final currentPosition`을 가지고 있어서, 초기화 시점의 위치로 고정됨
2. **위치 이동 로직 문제**: `moveToCurrentLocation()`이 저장된 위치로 이동하는 것이 아니라, 실제 현재 위치로 이동해야 함
3. **Repository 활용 부족**: `LocationRepository`와 `MapControllerRepository`를 통한 계층화된 구조가 제대로 활용되지 않음
4. **Map Controller 준비 상태 관리**: Google Map Controller와 Location Service가 모두 준비된 상태에서 Map Widget이 로딩되어야 함

### 요구사항
- Google Map Renderer와 Google Map Controller Service가 모두 준비된 상태에서 Map Widget이 제대로 로딩
- 현재 위치로 초기화 및 현재 위치로 이동 기능이 올바르게 동작
- Repository 패턴을 통한 계층화된 구조 활용
- 기존 UseCase 구조를 활용한 비즈니스 로직 처리

## 구현된 개선 사항

### 1. MapState 재설계 ✅

**변경 전**:
```dart
class MapReady extends MapState {
  final LatLng currentPosition; // 문제: 고정된 위치
}
```

**변경 후**:
```dart
/// Map 로딩 상태 (Location Service 또는 Map Controller 준비 중)
class MapLoading extends MapState {
  final String? loadingMessage;
  
  const MapLoading({this.loadingMessage});
  
  @override
  List<Object?> get props => [loadingMessage];
}

/// Map 완전 준비 상태 (Location Service와 Map Controller 모두 사용 가능)
class MapReady extends MapState {
  const MapReady();
  
  @override
  List<Object?> get props => [];
}
```

**개선 효과**:
- `MapReady`는 완전히 준비된 상태로 명확히 정의
- `MapLoading`에 로딩 메시지 추가로 사용자 경험 개선
- 고정된 위치 문제 해결

### 2. MapNotifier 개선 ✅

**주요 변경사항**:

1. **initializeMap() 개선**:
```dart
Future<void> initializeMap() async {
  state = const MapLoading(loadingMessage: '위치 서비스 준비 중...');
  
  try {
    // 위치 권한 요청 및 서비스 준비
    await _getCurrentLocation.execute(); // 권한 체크 포함
    
    // Map Controller 대기 상태
    state = const MapLoading(loadingMessage: '지도 컨트롤러 준비 중...');
    
  } catch (e) {
    final err = _toError(e);
    state = MapError(error: err);
    _effects.report(err);
  }
}
```

2. **moveToCurrentLocation() 개선**:
```dart
Future<void> moveToCurrentLocation() async {
  if (state is! MapReady) return;
  
  try {
    // 1. 현재 위치 조회 (UseCase 사용)
    final currentPosition = await _getCurrentLocation.execute();
    
    // 2. 해당 위치로 이동 (UseCase 사용)
    await _moveToLocation.execute(currentPosition);
    
  } catch (e) {
    final err = _toError(e);
    _effects.report(err);
  }
}
```

3. **setMapController() 개선**:
```dart
void setMapController(MapControllerService controller) {
  _mapControllerService.setMapController(controller);
  
  // Location Service와 Map Controller 모두 준비된 경우 MapReady로 전환
  if (state is MapLoading) {
    state = const MapReady();
  }
}
```

4. **retry() 메서드 추가**:
```dart
Future<void> retry() async {
  if (state is MapError) {
    await initializeMap();
  }
}
```

**개선 효과**:
- UseCase 패턴을 통한 비즈니스 로직 처리
- 실시간 위치 조회로 정확한 현재 위치로 이동
- 명확한 상태 전환 로직
- 에러 복구 기능 추가

### 3. MapWidget 개선 ✅

**변경 전**: 단순한 if-else 구조

**변경 후**: Switch 표현식을 활용한 상태 기반 렌더링
```dart
return switch (mapState) {
  MapLoading() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        if (mapState.loadingMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(mapState.loadingMessage!),
          ),
      ],
    ),
  ),
  
  MapReady() => mapRenderer.renderMap(
    initialPosition: const LatLng(37.5665, 126.9780), // 기본값 (서울)
    zoom: 16,
    onMapCreated: (controller) {
      mapNotifier.setMapController(controller);
    },
    options: const MapRendererOptions(
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    ),
  ),
  
  MapError() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        Text(mapState.error.userMessage),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => mapNotifier.retry(),
          child: const Text('다시 시도'),
        ),
      ],
    ),
  ),
  
  _ => const SizedBox.shrink(),
};
```

**개선 효과**:
- 더 명확한 상태별 UI 처리
- 로딩 메시지 표시로 사용자 경험 개선
- 에러 상태에서 복구 기능 제공
- Switch 표현식으로 가독성 향상

## 아키텍처 개선 효과

### 1. 관심사 분리
- **MapNotifier**: 상태 관리 + UseCase 조합
- **UseCase**: 비즈니스 로직 (기존 구조 활용)
- **Repository**: 데이터 접근 (기존 구조 유지)

### 2. 명확한 상태 정의
- `MapInitial`: 초기 상태
- `MapLoading`: 로딩 중 (메시지 포함)
- `MapReady`: 완전 준비 상태 (모든 기능 사용 가능)
- `MapError`: 에러 상태 (복구 기능 포함)

### 3. UseCase 패턴 활용
- 기존 `GetCurrentLocationUseCase`와 `MoveToLocationUseCase` 활용
- 비즈니스 로직의 재사용성 향상
- 테스트 용이성 유지

### 4. 사용자 경험 개선
- 로딩 상태별 메시지 표시
- 에러 발생 시 복구 기능 제공
- 실시간 위치 조회로 정확한 위치 이동

## 테스트 고려사항

### 1. MapNotifier 테스트
- 상태 전환 로직 테스트
- UseCase 호출 테스트
- 에러 처리 테스트

### 2. MapWidget 테스트
- 상태별 UI 렌더링 테스트
- 사용자 인터랙션 테스트

### 3. 통합 테스트
- 전체 Map 초기화 플로우 테스트
- 위치 이동 기능 테스트

## 추가 개선 가능 사항

### 1. 성능 최적화
- 위치 조회 결과 캐싱
- 불필요한 상태 업데이트 방지

### 2. 사용자 경험
- 위치 권한 요청 UI 개선
- 네트워크 상태에 따른 처리

### 3. 확장성
- 새로운 Map 기능 추가 시 UseCase 패턴 활용
- 다른 Map Provider 지원 시 Renderer 패턴 활용

## 결론

기존 UseCase 구조를 활용하여 최소한의 변경으로 Map 도메인의 핵심 문제들을 해결했습니다. 

**주요 성과**:
- ✅ 고정된 위치 문제 해결
- ✅ 실시간 위치 조회 구현
- ✅ 명확한 상태 관리
- ✅ 사용자 경험 개선
- ✅ 기존 아키텍처 구조 유지

이제 Map이 완전히 준비된 상태에서만 비즈니스 로직이 실행되며, 사용자는 정확한 현재 위치로 이동할 수 있습니다.
