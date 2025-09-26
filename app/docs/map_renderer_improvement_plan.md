# Map 도메인 아키텍처 개선 계획

## 요청된 작업
Map 도메인의 아키텍처 문제점을 해결하고, Auth 도메인과 같은 패턴으로 책임을 명확히 분리하며, Third-party 의존성을 적절히 추상화하는 리팩토링

## 핵심 아키텍처 문제점

### 1. Third-party 의존성의 도메인 침투
- **문제**: `GoogleMapController`가 도메인 레이어(`MapState`)에 직접 노출됨
- **영향**: 도메인이 특정 지도 라이브러리에 강하게 결합됨

### 2. UI 상태와 도메인 로직의 혼재
- **문제**: `MapNotifier`가 위치 조회, 권한 관리 등 도메인 로직을 직접 처리
- **영향**: UI 레이어가 비즈니스 로직을 담당하게 됨

### 3. Map Controller 초기화의 복잡성
- **문제**: `GoogleMap` 위젯을 통해서만 `GoogleMapController`를 얻을 수 있는 구조적 제약
- **영향**: 의존성 주입과 생명주기 관리의 복잡성 증가

## 아키텍처 솔루션

### 핵심 설계 원칙
1. **UI 상태는 UI 레이어에서만 관리**: `MapState`는 순수한 UI 상태만 포함
2. **도메인 로직은 UseCase로 분리**: 위치 조회, 권한 관리 등은 도메인 레이어에서 처리
3. **Third-party 의존성 추상화**: `GoogleMapController`를 도메인에서 완전히 격리
4. **Auth 도메인 패턴 적용**: 동일한 구조로 일관성 유지

### 1단계: 도메인 레이어 구축 (Auth 패턴 적용)

#### 1.1 UseCase 생성
```dart
// core/usecases/get_current_location_usecase.dart
class GetCurrentLocationUseCase {
  final LocationRepository _locationRepository;
  
  GetCurrentLocationUseCase(this._locationRepository);
  
  Future<LatLng> execute() async {
    final hasPermission = await _locationRepository.requestLocationPermission();
    if (!hasPermission) {
      throw LocationPermissionDeniedException();
    }
    
    final position = await _locationRepository.getCurrentLocation();
    if (position == null) {
      throw LocationNotFoundException();
    }
    
    return position;
  }
}

// core/usecases/move_to_location_usecase.dart  
class MoveToLocationUseCase {
  final MapControllerService _mapControllerService;
  
  MoveToLocationUseCase(this._mapControllerService);
  
  Future<void> execute(LatLng position) async {
    await _mapControllerService.moveToLocation(position);
  }
}
```

#### 1.2 Repository 인터페이스 정의
```dart
// core/repositories/location_repository.dart
abstract class LocationRepository {
  Future<LatLng?> getCurrentLocation();
  Future<bool> requestLocationPermission();
}

// core/services/map_controller_repository.dart
abstract class MapControllerService {
  Future<void> moveToLocation(LatLng position);
  Future<void> setZoom(double zoom);
  
  // Controller 생명주기 관리
  void setMapController(MapController controller);
}
```

#### 1.3 Data 레이어 구현
```dart
// data/services/location_service.dart
abstract class LocationService {
  Future<LocationData?> getCurrentLocation();
  Future<bool> requestPermission();
  Future<bool> isServiceEnabled();
}

// data/services/google_location_service.dart
class GoogleLocationService implements LocationService {
  final Location _location = Location();
  
  @override
  Future<LocationData?> getCurrentLocation() async {
    try {
      return await _location.getLocation().timeout(
        const Duration(seconds: 15),
      );
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<bool> requestPermission() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return false;
    }

    return true;
  }
  
  @override
  Future<bool> isServiceEnabled() async {
    return await _location.serviceEnabled();
  }
}

// data/repositories/location_repository_impl.dart
class LocationRepositoryImpl implements LocationRepository {
  final LocationService _locationService;
  
  LocationRepositoryImpl(this._locationService);
  
  @override
  Future<LatLng?> getCurrentLocation() async {
    final locationData = await _locationService.getCurrentLocation();
    return locationData != null 
        ? LatLng(locationData.latitude!, locationData.longitude!)
        : null;
  }
  
  @override
  Future<bool> requestLocationPermission() async {
    return await _locationService.requestPermission();
  }
}

// data/services/map_controller_service_impl.dart
class MapControllerServiceImpl implements MapControllerService {
  // MapController는 MapNotifier에서 주입받음
  MapController? _mapController;
  
  @override
  void setMapController(MapController controller) {
    _mapController = controller;
  }
  
  @override
  Future<void> moveToLocation(LatLng position) async {
    if (_mapController == null) {
      throw MapControllerNotReadyException();
    }
    await _mapController!.moveToLocation(position);
  }
  
  @override
  Future<void> setZoom(double zoom) async {
    if (_mapController == null) {
      throw MapControllerNotReadyException();
    }
    await _mapController!.setZoom(zoom);
  }
}

// Map 관련 Exception 정의
class MapControllerNotReadyException implements ExceptionInterface {
  @override
  String get message => 'Map controller is not ready';
  
  @override
  String get userMessage => '지도가 아직 준비되지 않았습니다. 잠시 후 다시 시도해주세요.';
}
```

### 2단계: UI 레이어 단순화

#### 2.1 MapState를 UI 전용으로 변경
```dart
// presentation/models/map_state.dart (AuthState 패턴 적용)
abstract class MapState extends Equatable {
  const MapState();
}

class MapInitial extends MapState {
  const MapInitial();
  
  @override
  List<Object?> get props => [];
}

class MapLoading extends MapState {
  const MapLoading();
  
  @override
  List<Object?> get props => [];
}

class MapReady extends MapState {
  final LatLng currentPosition;
  
  const MapReady({required this.currentPosition});
  
  @override
  List<Object?> get props => [currentPosition];
}

class MapError extends MapState {
  final ExceptionInterface error;
  
  const MapError({required this.error});
  
  @override
  List<Object?> get props => [error];
}
```

#### 2.2 MapNotifier 리팩토링 (AuthNotifier 패턴 적용)
```dart
// presentation/controllers/map_notifier.dart
class MapNotifier extends StateNotifier<MapState> {
  MapNotifier(this._ref) : super(const MapInitial());
  
  final Ref _ref;
  
  GetCurrentLocationUseCase get _getCurrentLocation => 
      _ref.read(getCurrentLocationUseCaseProvider);
  MoveToLocationUseCase get _moveToLocation => 
      _ref.read(moveToLocationUseCaseProvider);
  MapControllerService get _mapControllerService => _ref.read(mapControllerServiceProvider);
  ExceptionNotifier get _effects => _ref.read(exceptionNotifierProvider.notifier);
  
  Future<void> initializeMap() async {
    state = const MapLoading();
    try {
      final position = await _getCurrentLocation.execute();
      // 위치 정보가 준비되면 MapReady 상태로 전환
      // Controller는 Command 패턴으로 대기열에서 처리
      state = MapReady(currentPosition: position);
    } catch (e) {
      final err = _toError(e);
      state = MapError(error: err);
      _effects.report(err);
    }
  }
  
  Future<void> moveToCurrentLocation() async {
    if (state is! MapReady) return;
    
    final currentState = state as MapReady;
    
    try {
      // MapRepository를 통해 지도 조작
      await _moveToLocation.execute(currentState.currentPosition);
    } catch (e) {
      final err = _toError(e);
      // Auth 패턴과 동일하게 ExceptionNotifier에 에러 전달
      _effects.report(err);
    }
  }
  
  void setMapController(MapController controller) {
    // MapControllerService에 Controller 설정
    _mapControllerService.setMapController(controller);
  }
  
  @override
  void dispose() {
    // MapController 생명주기 관리
    // GoogleMapController는 GoogleMap 위젯이 dispose될 때 자동으로 처리됨
    super.dispose();
  }
  
  ExceptionInterface _toError(dynamic e) {
    if (e is ExceptionInterface) {
      return e;
    } else {
      return UnknownException(message: e.toString());
    }
  }
}
```

### 3단계: Map Renderer 추상화

#### 3.1 Map Renderer를 순수 UI 컴포넌트로 변경
```dart
// data/map/map_renderer.dart
class MapRendererOptions {
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final bool zoomControlsEnabled;
  final bool mapToolbarEnabled;
  
  const MapRendererOptions({
    this.myLocationEnabled = true,
    this.myLocationButtonEnabled = false,
    this.zoomControlsEnabled = false,
    this.mapToolbarEnabled = false,
  });
}

abstract class MapRenderer {
  Widget renderMap({
    required LatLng initialPosition,
    required double zoom,
    required Function(MapController) onMapCreated,
    MapRendererOptions? options,
  });
}

// data/map/google_map_renderer.dart
class GoogleMapRenderer implements MapRenderer {
  @override
  Widget renderMap({
    required LatLng initialPosition,
    required double zoom,
    required Function(MapController) onMapCreated,
    MapRendererOptions? options,
  }) {
    return GoogleMap(
      onMapCreated: (controller) {
        onMapCreated(GoogleMapControllerWrapper(controller));
      },
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: zoom,
      ),
      myLocationEnabled: options?.myLocationEnabled ?? true,
      myLocationButtonEnabled: options?.myLocationButtonEnabled ?? false,
      zoomControlsEnabled: options?.zoomControlsEnabled ?? false,
      mapToolbarEnabled: options?.mapToolbarEnabled ?? false,
    );
  }
}
```

#### 3.2 MapWidget 단순화
```dart
// presentation/widgets/organisms/map_widget.dart
class MapWidget extends ConsumerWidget {
  const MapWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapNotifierProvider);
    final mapRenderer = ref.watch(mapRendererProvider);
    final mapNotifier = ref.read(mapNotifierProvider.notifier);

    if (mapState is MapLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // ExceptionNotifier를 통해 에러 처리 (Auth 패턴과 일관성)
    final exception = ref.watch(exceptionNotifierProvider);
    if (exception != null) {
      return Center(child: Text('Error: ${exception.message}'));
    }
    
    if (mapState is MapReady) {
      return mapRenderer.renderMap(
        initialPosition: mapState.currentPosition,
        zoom: 16,
        onMapCreated: (controller) {
          // GoogleMap 위젯에서 Controller를 받아서 MapNotifier에 전달
          mapNotifier.setMapController(controller);
        },
        options: const MapRendererOptions(
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
}
```

### 4단계: Provider 구조 (Auth 패턴 적용)

#### 4.1 UseCase 및 Service Provider
```dart
// presentation/providers/map_providers.dart
final locationServiceProvider = Provider<LocationService>((ref) {
  return GoogleLocationService();
});

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl(ref.read(locationServiceProvider));
});

final mapControllerServiceProvider = Provider<MapControllerService>((ref) {
  return MapControllerServiceImpl();
});

final getCurrentLocationUseCaseProvider = Provider<GetCurrentLocationUseCase>((ref) {
  return GetCurrentLocationUseCase(ref.read(locationRepositoryProvider));
});

final moveToLocationUseCaseProvider = Provider<MoveToLocationUseCase>((ref) {
  return MoveToLocationUseCase(ref.read(mapControllerServiceProvider));
});

final mapRendererProvider = Provider<MapRenderer>((ref) {
  return GoogleMapRenderer();
});

// MapNotifier Provider
final mapNotifierProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier(ref);
});
```

## 구현 순서

### Phase 1: 도메인 레이어 구축
1. **UseCase 생성**
   - `GetCurrentLocationUseCase` 생성
   - `MoveToLocationUseCase` 생성
   - 관련 Exception 클래스 생성

2. **Service 및 Repository 인터페이스 정의**
   - `LocationService` 인터페이스 생성
   - `LocationRepository` 인터페이스 생성
   - `MapControllerService` 인터페이스 생성

3. **Data 레이어 구현**
   - `GoogleLocationService` 구현
   - `LocationRepositoryImpl` 구현
   - `MapControllerServiceImpl` 구현

### Phase 2: UI 레이어 리팩토링
4. **MapState를 Auth 패턴으로 변경**
   - `MapInitial`, `MapLoading`, `MapReady`, `MapError` 상태 생성
   - 기존 `MapState` 클래스 제거

5. **MapNotifier 리팩토링**
   - UseCase 의존성 주입
   - AuthNotifier와 동일한 패턴 적용
   - MapController를 Service를 통해 관리

6. **MapWidget 단순화**
   - 상태 기반 렌더링 로직 적용
   - MapRenderer를 순수 UI 컴포넌트로 변경

### Phase 3: Provider 구조 개선
7. **Provider 의존성 설정**
   - Service Provider 생성
   - Repository Provider 생성
   - UseCase Provider 생성
   - MapRenderer Provider 생성

8. **의존성 주입 체인 구성**
   - UI → UseCase → Repository/Service → Data 순서로 의존성 설정

### Phase 4: 테스트 및 검증
9. **기존 테스트 수정**
   - 새로운 상태 구조에 맞게 테스트 수정
   - UseCase 및 Service 테스트 추가

10. **통합 테스트**
    - 전체 Map 기능 동작 확인
    - Auth 도메인과의 일관성 검증

## 테스트 계획

### 1. Unit 테스트

#### 1.1 UseCase 테스트
```dart
// test/domains/map/core/usecases/get_current_location_usecase_test.dart
void main() {
  group('GetCurrentLocationUseCase', () {
    late MockLocationRepository mockRepository;
    late GetCurrentLocationUseCase useCase;

    setUp(() {
      mockRepository = MockLocationRepository();
      useCase = GetCurrentLocationUseCase(mockRepository);
    });

    test('should return current location when permission granted', () async {
      // Given
      when(() => mockRepository.requestLocationPermission())
          .thenAnswer((_) async => true);
      when(() => mockRepository.getCurrentLocation())
          .thenAnswer((_) async => LatLng(37.579617, 126.977041));

      // When
      final result = await useCase.execute();

      // Then
      expect(result, equals(LatLng(37.579617, 126.977041)));
      verify(() => mockRepository.requestLocationPermission()).called(1);
      verify(() => mockRepository.getCurrentLocation()).called(1);
    });

    test('should throw exception when permission denied', () async {
      // Given
      when(() => mockRepository.requestLocationPermission())
          .thenAnswer((_) async => false);

      // When & Then
      expect(
        () => useCase.execute(),
        throwsA(isA<LocationPermissionDeniedException>()),
      );
    });
  });
}
```

#### 1.2 Service 테스트
```dart
// test/domains/map/data/services/map_controller_service_impl_test.dart
void main() {
  group('MapControllerServiceImpl', () {
    late MapControllerServiceImpl service;
    late MockMapController mockController;

    setUp(() {
      service = MapControllerServiceImpl();
      mockController = MockMapController();
    });

    test('should move to location when controller is ready', () async {
      // Given
      service.setMapController(mockController);
      when(() => mockController.moveToLocation(any()))
          .thenAnswer((_) async {});

      // When
      await service.moveToLocation(LatLng(37.579617, 126.977041));

      // Then
      verify(() => mockController.moveToLocation(LatLng(37.579617, 126.977041)))
          .called(1);
    });

    test('should throw exception when controller is not ready', () async {
      // When & Then
      expect(
        () => service.moveToLocation(LatLng(37.579617, 126.977041)),
        throwsA(isA<MapControllerNotReadyException>()),
      );
    });
  });
}
```

#### 1.3 Notifier 테스트
```dart
// test/domains/map/presentation/controllers/map_notifier_test.dart
void main() {
  group('MapNotifier', () {
    late MockRef mockRef;
    late MockGetCurrentLocationUseCase mockGetLocationUseCase;
    late MockMoveToLocationUseCase mockMoveLocationUseCase;
    late MockMapControllerService mockMapControllerService;
    late MockExceptionNotifier mockExceptionNotifier;
    late MapNotifier notifier;

    setUp(() {
      mockRef = MockRef();
      mockGetLocationUseCase = MockGetCurrentLocationUseCase();
      mockMoveLocationUseCase = MockMoveToLocationUseCase();
      mockMapControllerService = MockMapControllerService();
      mockExceptionNotifier = MockExceptionNotifier();
      
      when(() => mockRef.read(getCurrentLocationUseCaseProvider))
          .thenReturn(mockGetLocationUseCase);
      when(() => mockRef.read(moveToLocationUseCaseProvider))
          .thenReturn(mockMoveLocationUseCase);
      when(() => mockRef.read(mapControllerServiceProvider))
          .thenReturn(mockMapControllerService);
      when(() => mockRef.read(exceptionNotifierProvider.notifier))
          .thenReturn(mockExceptionNotifier);

      notifier = MapNotifier(mockRef);
    });

    test('should initialize map successfully', () async {
      // Given
      when(() => mockGetLocationUseCase.execute())
          .thenAnswer((_) async => LatLng(37.579617, 126.977041));

      // When
      await notifier.initializeMap();

      // Then
      expect(notifier.state, isA<MapReady>());
      expect((notifier.state as MapReady).currentPosition, 
             equals(LatLng(37.579617, 126.977041)));
    });

    test('should handle initialization error', () async {
      // Given
      when(() => mockGetLocationUseCase.execute())
          .thenThrow(Exception('Location error'));

      // When
      await notifier.initializeMap();

      // Then
      expect(notifier.state, isA<MapError>());
      verify(() => mockExceptionNotifier.report(any())).called(1);
    });
  });
}
```

### 2. Widget 테스트

#### 2.1 MapWidget 테스트
```dart
// test/domains/map/presentation/widgets/organisms/map_widget_test.dart
void main() {
  group('MapWidget', () {
    testWidgets('should show loading indicator when map is loading', (tester) async {
      // Given
      final mockNotifier = MockMapNotifier();
      when(() => mockNotifier.state).thenReturn(const MapLoading());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mapNotifierProvider.overrideWithValue(mockNotifier),
          ],
          child: const MaterialApp(home: MapWidget()),
        ),
      );

      // Then
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should render map when ready', (tester) async {
      // Given
      final mockNotifier = MockMapNotifier();
      final mockRenderer = MockMapRenderer();
      
      when(() => mockNotifier.state)
          .thenReturn(MapReady(currentPosition: LatLng(37.579617, 126.977041)));
      when(() => mockRenderer.renderMap(
        initialPosition: any(named: 'initialPosition'),
        zoom: any(named: 'zoom'),
        onMapCreated: any(named: 'onMapCreated'),
        options: any(named: 'options'),
      )).thenReturn(Container());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mapNotifierProvider.overrideWithValue(mockNotifier),
            mapRendererProvider.overrideWithValue(mockRenderer),
          ],
          child: const MaterialApp(home: MapWidget()),
        ),
      );

      // Then
      verify(() => mockRenderer.renderMap(
        initialPosition: LatLng(37.579617, 126.977041),
        zoom: 16,
        onMapCreated: any(named: 'onMapCreated'),
        options: any(named: 'options'),
      )).called(1);
    });
  });
}
```

### 3. Integration 테스트

#### 3.1 전체 Map 기능 테스트
```dart
// test/integration/map_integration_test.dart
void main() {
  group('Map Integration Tests', () {
    testWidgets('should complete full map flow', (tester) async {
      // Given
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(home: MapPage()),
        ),
      );

      // When - Map 초기화
      await tester.pumpAndSettle();

      // Then - 지도가 렌더링되었는지 확인
      expect(find.byType(GoogleMap), findsOneWidget);

      // When - 현재 위치로 이동 버튼 클릭
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Then - 지도가 현재 위치로 이동했는지 확인
      // (실제 Google Maps API와 연동하여 테스트)
    });
  });
}
```

### 4. Mock Factory 확장

#### 4.1 Map 도메인 Mock Factory
```dart
// test/utils/mock_factory/map_mock_factory.dart
class MapMockFactory {
  MapMockFactory._();

  // Service Mocks
  static MockLocationService createLocationService() => MockLocationService();
  static MockMapControllerService createMapControllerService() => MockMapControllerService();

  // Repository Mocks
  static MockLocationRepository createLocationRepository() => MockLocationRepository();

  // UseCase Mocks
  static MockGetCurrentLocationUseCase createGetCurrentLocationUseCase() => MockGetCurrentLocationUseCase();
  static MockMoveToLocationUseCase createMoveToLocationUseCase() => MockMoveToLocationUseCase();

  // Notifier Mocks
  static MockMapNotifier createMapNotifier() => MockMapNotifier();

  // Fake Objects
  static FakeMapNotifier createFakeMapNotifier() => FakeMapNotifier();
  static FakeMapControllerService createFakeMapControllerService() => FakeMapControllerService();
}
```

### 5. Provider 테스트 지원

#### 5.1 Provider 오버라이드 테스트
```dart
// test/utils/provider_test_utils.dart
class ProviderTestUtils {
  static List<Override> createMapTestOverrides({
    LocationService? locationService,
    MapControllerService? mapControllerService,
    GetCurrentLocationUseCase? getCurrentLocationUseCase,
    MoveToLocationUseCase? moveToLocationUseCase,
    MapNotifier? mapNotifier,
  }) {
    return [
      if (locationService != null)
        locationServiceProvider.overrideWithValue(locationService),
      if (mapControllerService != null)
        mapControllerServiceProvider.overrideWithValue(mapControllerService),
      if (getCurrentLocationUseCase != null)
        getCurrentLocationUseCaseProvider.overrideWithValue(getCurrentLocationUseCase),
      if (moveToLocationUseCase != null)
        moveToLocationUseCaseProvider.overrideWithValue(moveToLocationUseCase),
      if (mapNotifier != null)
        mapNotifierProvider.overrideWithValue(mapNotifier),
    ];
  }
}
```

## 테스트 실행 전략

### 1. **Unit 테스트 (빠른 피드백)**
- UseCase, Service, Repository 개별 테스트
- Mock 객체 사용으로 외부 의존성 제거
- CI/CD 파이프라인에서 빠른 실행

### 2. **Widget 테스트 (UI 로직 검증)**
- MapWidget, MapRenderer UI 컴포넌트 테스트
- Mock Renderer 사용으로 Google Maps API 의존성 제거
- 상태별 렌더링 로직 검증

### 3. **Integration 테스트 (전체 플로우 검증)**
- 실제 Google Maps API와 연동
- End-to-End 시나리오 테스트
- 주기적 실행 (매일 또는 주간)

### 4. **테스트 커버리지 목표**
- **Unit 테스트**: 90% 이상
- **Widget 테스트**: 80% 이상
- **Integration 테스트**: 주요 시나리오 100%

## 핵심 개선 효과

### 1. 아키텍처 일관성
- **Auth 도메인과 동일한 패턴**: 일관된 아키텍처로 유지보수성 향상
- **Clean Architecture 완전 준수**: 각 레이어의 책임이 명확히 분리됨

### 2. Third-party 의존성 격리
- **GoogleMapController 완전 격리**: 도메인 레이어에서 Third-party 의존성 제거
- **Service를 통한 추상화**: 지도 조작 로직을 Service 레이어에서 관리

### 3. 상태 관리 단순화
- **AuthState 패턴 적용**: 명확한 상태 전환과 에러 처리
- **UI 상태와 도메인 로직 분리**: 각각의 책임이 명확해짐

### 4. 테스트 용이성
- **UseCase 독립 테스트**: 비즈니스 로직을 독립적으로 테스트 가능
- **Repository Mock 가능**: 외부 의존성을 쉽게 Mock 처리

## 진행 상태
- [x] Marker 로직 제거 완료
- [ ] Phase 1: 도메인 레이어 구축
- [ ] Phase 2: UI 레이어 리팩토링  
- [ ] Phase 3: Provider 구조 개선
- [ ] Phase 4: 테스트 및 검증

## App 레벨 에러 처리 (Auth 패턴 적용)

```dart
// app.dart에서 Map 에러도 처리
ref.listen<ExceptionInterface?>(exceptionNotifierProvider, (prev, next) {
  if (next != null) {
    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text(next.userMessage))
      );
    }
    ref.read(exceptionNotifierProvider.notifier).clear();
  }
});
```

## 제안된 다음 작업
1. **위치 기반 서비스 확장**: POI 검색, 경로 안내 등 추가 기능
2. **오프라인 지도 지원**: 캐싱 및 오프라인 모드 구현
3. **성능 최적화**: 지도 렌더링 및 메모리 사용량 최적화
4. **접근성 개선**: 지도 컨트롤의 접근성 기능 추가
