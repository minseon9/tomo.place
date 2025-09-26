# Map 도메인 아키텍처 개선 계획

## 현재 구조 분석

### 1. Auth 도메인 패턴 (참고 모델)
```dart
// app.dart에서 AuthState 리스너 패턴
ref.listen<AuthState>(authNotifierProvider, (prev, next) {
  switch (next) {
    case AuthInitial():
      ref.read(navigationActionsProvider).navigateToSignup();
    case AuthSuccess(isNavigateHome: true):
      ref.read(navigationActionsProvider).navigateToHome();
    case AuthFailure():
      ref.read(navigationActionsProvider).navigateToSignup();
  }
});
```

**Auth 도메인의 장점:**
- 상태 변화에 따른 명확한 액션 정의
- 앱 레벨에서 상태 관리
- 네비게이션과 상태가 분리됨

### 2. 현재 Map 도메인 문제점

#### A. MapPageDelegate의 역할 모호성
```dart
// 현재 구조
class MapPageDelegate extends ConsumerStatefulWidget implements MapPage {
  // 콜백 메서드들이 정의되어 있지만 실제로 사용되지 않음
  void setOnInitialized(VoidCallback? onInitialized);
  void setOnMoveToCurrentLocation(VoidCallback? onMoveToCurrentLocation);
  
  // initState에서 직접 MapNotifier 호출
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(mapNotifierProvider.notifier).initializeMap();
  });
}
```

**문제점:**
- 콜백 인터페이스가 정의되어 있지만 활용되지 않음
- MapPageDelegate가 직접 MapNotifier를 호출하는 구조
- 상태 변화에 따른 UI 업데이트가 명확하지 않음

#### B. MapWidget의 책임 과다
```dart
// 현재 MapWidget이 처리하는 것들
- MapState에 따른 UI 렌더링
- Map Controller 설정
- 상태별 다른 UI 표시
```

**문제점:**
- MapWidget이 상태 관리와 UI 렌더링을 모두 담당
- 상태 변화에 따른 부가 효과(side effect) 처리가 분산됨

#### C. MapState의 단순함
```dart
// 현재 MapState
MapInitial -> MapLoading -> MapReady/MapError
```

**문제점:**
- Map 초기화 과정의 세부 단계가 표현되지 않음
- 권한 요청, Map 렌더링, Controller 설정 등의 단계가 명확하지 않음

## 개선 계획

### Phase 1: MapState 세분화 및 상태별 액션 정의

#### 1.1 MapState 재설계
```dart
abstract class MapState extends Equatable {
  const MapState();
  
  // Map 관련 로직 사용 가능 여부만 정의
  bool get canUseUseCases => false;
}

// 구체적인 상태들
class MapInitial extends MapState {
  const MapInitial();
  @override
  List<Object?> get props => [];
}

class MapRequestingPermission extends MapState {
  const MapRequestingPermission();
  @override
  List<Object?> get props => [];
}

class MapPermissionGranted extends MapState {
  final LatLng initPosition;
  const MapPermissionGranted({required this.initPosition});
  @override
  List<Object?> get props => [initPosition];
}

class MapPermissionDenied extends MapState {
  final String? message;
  const MapPermissionDenied({this.message});
  @override
  List<Object?> get props => [message];
}

class MapRendering extends MapState {
  final LatLng initPosition;
  const MapRendering({required this.initPosition});
  @override
  List<Object?> get props => [initPosition];
}

class MapRendered extends MapState {
  final LatLng initPosition;
  const MapRendered({required this.initPosition});
  @override
  List<Object?> get props => [initPosition];
  
  @override
  bool get canUseUseCases => true; // 유일하게 UseCase 사용 가능
}

class MapRenderFailed extends MapState {
  final ExceptionInterface error;
  final LatLng? initPosition;
  const MapRenderFailed({required this.error, this.initPosition});
  @override
  List<Object?> get props => [error, initPosition];
}
```

#### 1.2 MapNotifier 개선
```dart
class MapNotifier extends StateNotifier<MapState> {
  // 상태 전환 메서드들
  Future<void> initializeMap() async {
    state = const MapRequestingPermission();
    // 권한 요청 로직
  }
  
  void startMapRendering(LatLng initPosition) {
    state = MapRendering(initPosition: initPosition);
  }
  
  void setMapController(MapControllerService controller) {
    // Controller 설정 후 MapRendered로 전환
  }
  
  // 비즈니스 로직 메서드들
  Future<void> moveToCurrentLocation() async {
    if (!state.canUseUseCases) return;
    // UseCase 실행
  }
}
```

### Phase 2: MapPageDelegate 리스너 패턴 적용

#### 2.1 Auth 패턴을 Map에 적용
```dart
class MapPageDelegate extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // MapState 리스너 추가 - 상태 변화에 따른 액션 정의
    ref.listen<MapState>(mapNotifierProvider, (prev, next) {
      switch (next) {
        case MapInitial():
          // 초기 상태 - 자동으로 권한 요청 시작
          ref.read(mapNotifierProvider.notifier).initializeMap();
        case MapPermissionGranted():
          // 권한 획득 후 Map 렌더링 시작
          ref.read(mapNotifierProvider.notifier).startMapRendering(next.initPosition);
        case MapRendered():
          // Map 완전 준비 완료 - 추가 액션 없음
        case MapPermissionDenied():
          // 권한 거부 - 사용자에게 알림
        case MapRenderFailed():
          // 렌더링 실패 - 에러 처리
      }
    });
    
    final mapState = ref.watch(mapNotifierProvider);
    
    return Stack(
      children: [
        // Map Widget은 항상 렌더링
        ref.watch(mapWidgetProvider),
        
        // MapRendered 상태에서만 SearchBar와 LocationButton 표시
        if (mapState.canUseUseCases) ...[
          SafeArea(
            child: Padding(
              padding: ResponsiveSizing.getResponsivePadding(context, top: 16),
              child: ref.watch(mapSearchBarProvider),
            ),
          ),
          Positioned(
            right: ResponsiveSizing.getValueByDevice(context, mobile: 36.0, tablet: 48.0),
            bottom: ResponsiveSizing.getValueByDevice(context, mobile: 36.0, tablet: 48.0),
            child: ref.watch(myLocationButtonProvider),
          ),
        ],
      ],
    );
  }
}
```

#### 2.2 콜백 인터페이스 활용 방안
```dart
// 옵션 A: 콜백 제거 (권장)
// - StateNotifier 패턴으로 충분히 상태 관리 가능
// - 콜백은 복잡성만 증가시킴

// 옵션 B: 콜백을 통한 외부 제어
class MapPageDelegate {
  final VoidCallback? onMapInitialized;
  final VoidCallback? onMapReady;
  final VoidCallback? onMapError;
  
  // 상태 변화에 따른 콜백 호출
}
```

### Phase 3: MapWidget 단순화

#### 3.1 MapWidget 책임 분리
```dart
class MapWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapNotifierProvider);
    final mapRenderer = ref.watch(mapRendererProvider);
    final mapNotifier = ref.read(mapNotifierProvider.notifier);

    return switch (mapState) {
      // 각 상태별 UI만 담당
      MapInitial() => _buildInitialUI(mapNotifier),
      MapRequestingPermission() => _buildLoadingUI('권한 요청 중...'),
      MapPermissionDenied() => _buildPermissionDeniedUI(mapState, mapNotifier),
      MapPermissionGranted() => _buildMapRenderer(mapState, mapRenderer, mapNotifier),
      MapRendering() => _buildLoadingUI('지도 로딩 중...'),
      MapRendered() => _buildMapRenderer(mapState, mapRenderer, mapNotifier),
      MapRenderFailed() => _buildErrorUI(mapState, mapNotifier),
    };
  }
}
```

#### 3.2 상태별 UI 메서드 분리
```dart
Widget _buildInitialUI(MapNotifier mapNotifier) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.location_on, size: 64, color: Colors.blue),
        const SizedBox(height: 16),
        const Text('위치 권한이 필요합니다'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => mapNotifier.initializeMap(),
          child: const Text('위치 권한 요청'),
        ),
      ],
    ),
  );
}
```

### Phase 4: 상태 기반 UI 렌더링

#### 4.1 MapPageDelegate에서 상태별 UI 제어
```dart
class MapPageDelegate extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapNotifierProvider);
    
    return Stack(
      children: [
        // Map Widget은 항상 렌더링
        ref.watch(mapWidgetProvider),
        
        // MapRendered 상태에서만 SearchBar와 LocationButton 표시
        if (mapState.canUseUseCases) ...[
          SafeArea(
            child: Padding(
              padding: ResponsiveSizing.getResponsivePadding(context, top: 16),
              child: ref.watch(mapSearchBarProvider),
            ),
          ),
          Positioned(
            right: ResponsiveSizing.getValueByDevice(context, mobile: 36.0, tablet: 48.0),
            bottom: ResponsiveSizing.getValueByDevice(context, mobile: 36.0, tablet: 48.0),
            child: ref.watch(myLocationButtonProvider),
          ),
        ],
      ],
    );
  }
}
```

#### 4.2 MyLocationButton 상태 기반 활성화
```dart
class MyLocationButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapNotifierProvider);
    final mapNotifier = ref.read(mapNotifierProvider.notifier);
    
    // MapRendered 상태에서만 활성화 (이미 MapPageDelegate에서 조건부 렌더링됨)
    final isEnabled = mapState.canUseUseCases;
    
    return Container(
      color: Colors.white, // 항상 활성화된 상태로 표시
      child: Material(
        child: InkWell(
          onTap: () => mapNotifier.moveToCurrentLocation(),
          child: SvgPicture.asset(
            'assets/icons/location_button_icon.svg',
          ),
        ),
      ),
    );
  }
}
```

## 구현 우선순위

### Phase 1: 핵심 상태 관리 개선 (필수)
1. **MapState 재설계** - 세분화된 상태 정의
2. **MapNotifier 개선** - 상태 전환 로직 구현
3. **canUseUseCases 정의** - MapRendered 상태에서만 true

### Phase 2: 아키텍처 패턴 적용 (권장)
1. **MapPageDelegate 리스너 패턴** - Auth 패턴 적용, 상태 변화에 따른 액션 정의
2. **콜백 인터페이스 정리** - 사용하지 않는 콜백 제거
3. **조건부 UI 렌더링** - MapRendered 상태에서만 SearchBar와 LocationButton 표시

### Phase 3: UI 컴포넌트 개선 (선택)
1. **MapWidget 단순화** - 책임 분리
2. **상태별 UI 메서드** - 가독성 향상
3. **에러 처리 개선** - 사용자 경험 향상

## 예상 효과

### 1. 명확한 상태 관리
- Map 초기화 과정의 각 단계가 명확히 표현됨
- `canUseUseCases`로 Map 로직 사용 가능 여부만 체크

### 2. 아키텍처 일관성
- Auth 도메인과 동일한 리스너 패턴 적용
- 상태 변화에 따른 액션을 `ref.listen`에서 중앙 집중 관리

### 3. 사용자 경험 개선
- MapRendered 상태에서만 SearchBar와 LocationButton 표시
- 상태에 따라 완전히 다른 화면이 노출됨

### 4. 유지보수성 향상
- 상태 전환 로직이 명확하고 예측 가능
- 새로운 상태나 액션 추가가 용이함

## 추가 고려사항

### 1. 성능 최적화
- 불필요한 상태 업데이트 방지
- 메모리 누수 방지를 위한 Controller 생명주기 관리

### 2. 테스트 용이성
- 각 상태별 단위 테스트 작성
- 상태 전환 로직 테스트

### 3. 확장성
- 새로운 Map 기능 추가 시 상태 확장
- 다른 Map Provider 지원 시 Renderer 패턴 활용

이 계획에 따라 단계적으로 구현하면 Map 도메인의 아키텍처가 더욱 명확하고 유지보수하기 쉬워질 것입니다.
