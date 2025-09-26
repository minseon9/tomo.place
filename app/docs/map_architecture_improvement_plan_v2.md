# Map 도메인 아키텍처 개선 계획 v2

## 현재 구조 분석

### 1. MapPage 추상화의 필요성 검토

#### 현재 구조
```dart
// map_page.dart
abstract class MapPage extends ConsumerStatefulWidget {
  void setOnInitialized(VoidCallback? onInitialized);
  void setOnMoveToCurrentLocation(VoidCallback? onMoveToCurrentLocation);
}

// home_page.dart
final mapPage = ref.watch(mapPageProvider);
return Scaffold(
  body: mapPage, // Provider로 주입받아 사용
);
```

#### 추상화의 장단점 분석

**장점:**
- 테스트 시 Mock 구현체 주입 가능
- 다른 Map 구현체로 교체 가능 (예: 다른 Map Provider)

**단점:**
- 현재는 MapPageDelegate 하나만 존재
- 콜백 메서드들이 실제로 사용되지 않음
- 불필요한 복잡성 증가

**결론: 현재 상황에서는 추상화가 오버엔지니어링**

### 2. 현재 MapState 분석

사용자가 수정한 MapState:
```dart
MapInitial -> MapLoading -> MapReady(currentPosition) / MapError
```

**문제점:**
- Map 초기화 과정의 세부 단계가 표현되지 않음
- 권한 요청, Map 렌더링, Controller 설정 등의 단계가 명확하지 않음
- `MapReady`가 `final currentPosition`을 가져 고정된 위치 문제
- **MapState 자체가 불필요**: 위치 권한 상태만 관리하면 충분

### 3. MapPageDelegate의 역할 재정의

현재 MapPageDelegate는 단순히 Stack을 렌더링하는 역할만 함. 하지만 상태에 따라 완전히 다른 UI를 보여줘야 함.

### 4. 위치 스트리밍 및 GoogleMap 제어 분석

**GoogleMap의 myLocationEnabled 제한사항:**
- `myLocationEnabled`는 런타임에 동적으로 변경 불가
- `myLocationButtonEnabled`도 동적으로 변경 불가
- 내장 위치 서비스와 location 패키지의 차이점 존재

**해결 방안:**
- GoogleMap의 내장 위치 기능을 모두 비활성화
- location 패키지를 사용한 커스텀 위치 스트리밍 구현
- 커스텀 마커로 위치 및 방향 표시

## 개선된 아키텍처 설계

### 1. MapPage 추상화 제거

```dart
// map_page_delegate.dart를 map_page.dart로 통합
class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

// home_page.dart에서 직접 사용
return Scaffold(
  body: const MapPage(), // 직접 인스턴스 생성
);
```

### 2. MapState 제거 및 LocationPermissionState 중심 아키텍처

**핵심 변경사항:**
- **MapState 완전 제거**: Map 렌더링은 항상 수행
- **LocationPermissionState 중심**: 권한 상태만 관리
- **권한 상태 기반 UI 제어**: 권한에 따라 UI 요소 활성화/비활성화

#### LocationPermissionState 설계
```dart
abstract class LocationPermissionState extends Equatable {
  const LocationPermissionState();
  
  // 위치 권한을 얻었는지 여부
  bool get hasLocationPermission => false;
  
  // 부분적으로 위치 권한을 얻었는지 여부 (iOS limited 등)
  bool get hasPartialPermission => false;
  
  // 앱 내에서 권한 요청 가능 여부 (true면 in-app 요청, false면 설정 모달)
  bool get canRequestInApp => false;
  
  // 사용자에게 표시할 메시지
  String? get message => null;
}

class LocationPermissionInitial extends LocationPermissionState {
  const LocationPermissionInitial();
  @override
  List<Object?> get props => [];
}

class LocationPermissionLoading extends LocationPermissionState {
  const LocationPermissionLoading();
  @override
  List<Object?> get props => [];
}

class LocationPermissionGranted extends LocationPermissionState {
  const LocationPermissionGranted();
  @override
  List<Object?> get props => [];
  
  @override
  bool get hasLocationPermission => true;
}

class LocationPermissionPartial extends LocationPermissionState {
  final String message;
  
  const LocationPermissionPartial({required this.message});
  @override
  List<Object?> get props => [message];
  
  @override
  bool get hasLocationPermission => true;
  @override
  bool get hasPartialPermission => true;
}

class LocationPermissionDenied extends LocationPermissionState {
  final String message;
  
  const LocationPermissionDenied({required this.message});
  @override
  List<Object?> get props => [message];
  
  @override
  bool get canRequestInApp => true;
}

class LocationPermissionPermanentlyDenied extends LocationPermissionState {
  final String message;
  
  const LocationPermissionPermanentlyDenied({required this.message});
  @override
  List<Object?> get props => [message];
  
  @override
  bool get canRequestInApp => false; // false이므로 설정 모달 표시
}

class LocationPermissionRestricted extends LocationPermissionState {
  final String message;
  
  const LocationPermissionRestricted({required this.message});
  @override
  List<Object?> get props => [message];
}
```

### 3. 권한 UseCase 분리 및 LocationPermissionResult 모델

#### 권한 UseCase 분리
```dart
// 권한 상태 확인 전용 UseCase
class CheckLocationPermissionUseCase {
  final LocationRepository _locationRepository;
  
  CheckLocationPermissionUseCase(this._locationRepository);
  
  Future<LocationPermissionResult> execute() async {
    return await _locationRepository.checkPermission();
  }
}

// 권한 요청 전용 UseCase
class RequestLocationPermissionUseCase {
  final LocationRepository _locationRepository;
  
  RequestLocationPermissionUseCase(this._locationRepository);
  
  Future<LocationPermissionResult> execute() async {
    return await _locationRepository.requestPermission();
  }
}
```

#### LocationPermissionResult 모델
```dart
class LocationPermissionResult {
  final bool hasLocationPermission;
  final bool hasPartialPermission;
  final bool canRequestInApp;
  final String? message;
  
  const LocationPermissionResult({
    required this.hasLocationPermission,
    required this.hasPartialPermission,
    required this.canRequestInApp,
    this.message,
  });
  
  // PermissionStatus를 LocationPermissionResult로 변환
  static LocationPermissionResult fromPermissionStatus(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return const LocationPermissionResult(
          hasLocationPermission: true,
          hasPartialPermission: false,
          canRequestInApp: false,
        );
        
      case PermissionStatus.denied:
        return const LocationPermissionResult(
          hasLocationPermission: false,
          hasPartialPermission: false,
          canRequestInApp: true,
          message: '위치 권한이 거부되었습니다.',
        );
        
      case PermissionStatus.permanentlyDenied:
        return const LocationPermissionResult(
          hasLocationPermission: false,
          hasPartialPermission: false,
          canRequestInApp: false,
          message: '위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.',
        );
        
      case PermissionStatus.restricted:
        return const LocationPermissionResult(
          hasLocationPermission: false,
          hasPartialPermission: false,
          canRequestInApp: false,
          message: '위치 권한이 제한되었습니다.',
        );
        
      case PermissionStatus.limited:
        return const LocationPermissionResult(
          hasLocationPermission: true,
          hasPartialPermission: true,
          canRequestInApp: false,
          message: '위치가 정확하지 않을 수 있습니다.',
        );
        
      case PermissionStatus.provisional:
        return const LocationPermissionResult(
          hasLocationPermission: true,
          hasPartialPermission: false,
          canRequestInApp: false,
        );
        
      default:
        return const LocationPermissionResult(
          hasLocationPermission: false,
          hasPartialPermission: false,
          canRequestInApp: false,
          message: '위치 권한 상태를 확인할 수 없습니다.',
        );
    }
  }
}
```

### 4. LocationPermissionNotifier 구현

```dart
class LocationPermissionNotifier extends StateNotifier<LocationPermissionState> {
  LocationPermissionNotifier(this._ref) : super(const LocationPermissionInitial()) {
    _setupAppLifecycleObserver();
  }

  final Ref _ref;
  
  // UseCase들
  CheckLocationPermissionUseCase get _checkPermission => 
      _ref.read(checkLocationPermissionUseCaseProvider);
  RequestLocationPermissionUseCase get _requestPermission =>
      _ref.read(requestLocationPermissionUseCaseProvider);

  void _setupAppLifecycleObserver() {
    WidgetsBinding.instance.addObserver(_AppLifecycleObserver(this));
  }

  /// 앱 시작 시 권한 상태 확인
  Future<void> checkPermission() async {
    state = const LocationPermissionLoading();
    
    try {
      final result = await _checkPermission.execute();
      _updateStateFromResult(result);
    } catch (e) {
      state = const LocationPermissionDenied(
        message: '위치 권한 상태를 확인할 수 없습니다.',
      );
    }
  }

  /// 앱 내에서 권한 요청
  Future<void> requestPermission() async {
    state = const LocationPermissionLoading();
    
    try {
      final result = await _requestPermission.execute();
      _updateStateFromResult(result);
    } catch (e) {
      state = const LocationPermissionDenied(
        message: '위치 권한 요청에 실패했습니다.',
      );
    }
  }

  /// 앱이 포그라운드로 돌아올 때 호출
  Future<void> onAppResumed() async {
    await checkPermission();
  }

  void _updateStateFromResult(LocationPermissionResult result) {
    if (result.hasLocationPermission) {
      if (result.hasPartialPermission) {
        state = LocationPermissionPartial(message: result.message ?? '');
      } else {
        state = const LocationPermissionGranted();
      }
    } else if (result.canRequestInApp) {
      state = LocationPermissionDenied(
        message: result.message ?? '',
      );
    } else {
      // canRequestInApp이 false이면 설정 모달이 필요한 상태
      state = LocationPermissionPermanentlyDenied(
        message: result.message ?? '',
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_AppLifecycleObserver(this));
    super.dispose();
  }
}

class _AppLifecycleObserver extends WidgetsBindingObserver {
  final LocationPermissionNotifier _notifier;
  
  _AppLifecycleObserver(this._notifier);
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _notifier.onAppResumed();
    }
  }
}
```

### 5. 권한 상태별 UI 컴포넌트 분리

#### LocationPermissionOverlay 위젯
```dart
class LocationPermissionOverlay extends ConsumerWidget {
  final LocationPermissionState permissionState;
  
  const LocationPermissionOverlay({
    super.key,
    required this.permissionState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (permissionState) {
      LocationPermissionLoading() => _buildLoadingOverlay(),
      LocationPermissionDenied() => _buildPermissionRequestOverlay(context, ref, permissionState),
      LocationPermissionPermanentlyDenied() => _buildSettingsModalOverlay(context, ref, permissionState),
      LocationPermissionPartial() => _buildPartialServiceToast(context, permissionState),
      LocationPermissionRestricted() => _buildRestrictedToast(context, permissionState),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildPermissionRequestOverlay(BuildContext context, WidgetRef ref, LocationPermissionDenied state) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, size: 64, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                '위치 권한이 필요합니다',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.read(locationPermissionNotifierProvider.notifier).requestPermission(),
                child: const Text('위치 권한 요청'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsModalOverlay(BuildContext context, WidgetRef ref, LocationPermissionPermanentlyDenied state) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.settings, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                '설정에서 권한을 허용해주세요',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('취소'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      openAppSettings();
                    },
                    child: const Text('설정으로 이동'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartialServiceToast(BuildContext context, LocationPermissionPartial state) {
    // Toast 메시지로 표시 (Overlay가 아닌)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(state.message)),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    });
    
    return const SizedBox.shrink();
  }

  Widget _buildRestrictedToast(BuildContext context, LocationPermissionRestricted state) {
    // Toast 메시지로 표시 (Overlay가 아닌)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.block, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(state.message)),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    });
    
    return const SizedBox.shrink();
  }
}
```

#### LocationPermissionHandler 유틸리티 클래스
```dart
class LocationPermissionHandler {
  /// 권한 상태에 따른 액션 처리
  static void handlePermissionAction(
    BuildContext context,
    WidgetRef ref,
    LocationPermissionState permissionState,
  ) {
    final mapNotifier = ref.read(mapNotifierProvider.notifier);
    final locationPermissionNotifier = ref.read(locationPermissionNotifierProvider.notifier);
    
    switch (permissionState) {
      case LocationPermissionGranted():
      case LocationPermissionPartial():
        // 권한이 있으면 현재 위치로 이동
        mapNotifier.moveToCurrentLocation();
        break;
        
      case LocationPermissionDenied():
        // in-app에서 권한 요청
        locationPermissionNotifier.requestPermission();
        break;
        
      case LocationPermissionPermanentlyDenied():
        // 설정으로 이동하는 모달 표시
        _showSettingsModal(context, permissionState.message);
        break;
        
      case LocationPermissionRestricted():
        // 위치 서비스 사용 불가 toast 메시지
        _showRestrictedToast(context, permissionState.message);
        break;
        
      default:
        // 다른 상태에서는 아무것도 하지 않음
        break;
    }
  }

  static void _showSettingsModal(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('위치 권한 필요'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }

  static void _showRestrictedToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.block, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
```

### 6. MapPage에서 LocationPermissionState 기반 UI 처리

```dart
class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 앱 시작 시 권한 상태 확인
      ref.read(locationPermissionNotifierProvider.notifier).checkPermission();
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Map은 항상 렌더링, 권한 상태에 따라 UI만 변경
    return Stack(
      children: [
        // Map은 항상 렌더링
        const MapWidget(),
        
        // 위치 스트리밍 위젯 (보이지 않음)
        const LocationStreamWidget(),
        
        // Search Bar는 항상 표시
        SafeArea(
          child: Padding(
            padding: ResponsiveSizing.getResponsivePadding(context, top: 16),
            child: ref.watch(mapSearchBarProvider),
          ),
        ),
        
        // MyLocationButton은 권한 상태에 따라 다르게 표시
        Positioned(
          right: ResponsiveSizing.getValueByDevice(context, mobile: 36.0, tablet: 48.0),
          bottom: ResponsiveSizing.getValueByDevice(context, mobile: 36.0, tablet: 48.0),
          child: ref.watch(myLocationButtonProvider),
        ),
        
        // 권한 상태에 따른 오버레이 UI 관리
        const LocationPermissionOverlayManager(),
      ],
    );
  }
}
```

### 6. 위치 스트리밍 서비스 아키텍처

#### LocationStreamService 인터페이스
```dart
abstract class LocationStreamService {
  /// 위치 스트리밍을 시작합니다
  Future<void> startStream();
  
  /// 위치 스트리밍을 중지합니다
  void stopStream();
  
  /// 위치 스트림을 반환합니다
  Stream<LatLng> get locationStream;
  
  /// 나침반 방향 스트림을 반환합니다
  Stream<double> get headingStream;
  
  /// 스트리밍 상태를 반환합니다
  bool get isStreaming;
}
```

#### GoogleLocationStreamService 구현
```dart
class GoogleLocationStreamService implements LocationStreamService {
  final LocationService _locationService;
  StreamController<LatLng>? _locationController;
  StreamController<double>? _headingController;
  bool _isStreaming = false;
  
  GoogleLocationStreamService(this._locationService);
  
  @override
  Future<void> startStream() async {
    if (_isStreaming) return;
    
    _locationController = StreamController<LatLng>.broadcast();
    _headingController = StreamController<double>.broadcast();
    _isStreaming = true;
    
    // 위치 스트리밍 시작 (권한 확인 없이)
    _startLocationStreaming();
  }
  
  @override
  void stopStream() {
    _locationController?.close();
    _headingController?.close();
    _locationController = null;
    _headingController = null;
    _isStreaming = false;
  }
  
  @override
  Stream<LatLng> get locationStream => 
      _locationController?.stream ?? const Stream.empty();
  
  @override
  Stream<double> get headingStream => 
      _headingController?.stream ?? const Stream.empty();
  
  @override
  bool get isStreaming => _isStreaming;
  
  void _startLocationStreaming() {
    // location 패키지의 스트리밍 기능 사용
    // 권한 확인은 하지 않음 (상위 레이어에서 처리)
    _locationService.getLocationStream().listen(
      (locationData) {
        if (locationData.latitude != null && locationData.longitude != null) {
          _locationController?.add(LatLng(locationData.latitude!, locationData.longitude!));
        }
        if (locationData.heading != null) {
          _headingController?.add(locationData.heading!);
        }
      },
      onError: (error) {
        // 에러 처리 (권한 관련 에러는 상위 레이어에서 처리)
        _locationController?.addError(error);
      },
    );
  }
}
```

#### LocationService 확장
```dart
abstract class LocationService {
  /// 현재 위치를 가져옵니다
  Future<LocationData?> getCurrentLocation();
  
  /// 위치 권한을 요청합니다
  Future<bool> requestPermission();
  
  /// 위치 서비스가 활성화되어 있는지 확인합니다
  Future<bool> isServiceEnabled();
  
  /// 위치 스트림을 반환합니다
  Stream<LocationData> getLocationStream();
  
  /// 나침반 방향 스트림을 반환합니다
  Stream<double> getHeadingStream();
}

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
  
  @override
  Stream<LocationData> getLocationStream() {
    return _location.onLocationChanged;
  }
  
  @override
  Stream<double> getHeadingStream() {
    return _location.onLocationChanged.map((data) => data.heading ?? 0.0);
  }
}
```

### 7. MapNotifier 제거 및 UseCase 직접 사용

**MapNotifier 완전 제거**: MapState가 없으므로 MapNotifier도 불필요

#### UseCase에서 직접 ExceptionNotifier 사용
```dart
// GetCurrentLocationUseCase
class GetCurrentLocationUseCase {
  final LocationService _locationService;
  final ExceptionNotifier _exceptionNotifier;
  
  GetCurrentLocationUseCase(this._locationService, this._exceptionNotifier);
  
  Future<LatLng?> execute() async {
    try {
      final locationData = await _locationService.getCurrentLocation();
      if (locationData?.latitude != null && locationData?.longitude != null) {
        return LatLng(locationData!.latitude!, locationData!.longitude!);
      }
      return null;
    } catch (e) {
      _exceptionNotifier.report(_toError(e));
      rethrow;
    }
  }
  
  ExceptionInterface _toError(dynamic e) {
    if (e is ExceptionInterface) return e;
    return UnknownException(message: e.toString());
  }
}

// MoveToCurrentLocationUseCase
class MoveToCurrentLocationUseCase {
  final GetCurrentLocationUseCase _getCurrentLocation;
  final GetMapControllerUseCase _getMapController;
  final ExceptionNotifier _exceptionNotifier;
  
  MoveToCurrentLocationUseCase(
    this._getCurrentLocation,
    this._getMapController,
    this._exceptionNotifier,
  );
  
  Future<void> execute() async {
    try {
      final currentLocation = await _getCurrentLocation.execute();
      if (currentLocation == null) {
        throw LocationNotFoundException('현재 위치를 가져올 수 없습니다.');
      }
      
      final mapController = _getMapController.execute();
      if (mapController == null) {
        throw MapControllerNotReadyException('Map Controller가 준비되지 않았습니다.');
      }
      
      await mapController.animateCamera(
        CameraUpdate.newLatLngZoom(currentLocation, 16),
      );
    } catch (e) {
      _exceptionNotifier.report(_toError(e));
      rethrow;
    }
  }
  
  ExceptionInterface _toError(dynamic e) {
    if (e is ExceptionInterface) return e;
    return UnknownException(message: e.toString());
  }
}
```

### 8. LocationStreamWidget 분리 및 Provider 기반 마커 관리

#### LocationStreamWidget (위치 스트리밍 전용)
```dart
class LocationStreamWidget extends ConsumerStatefulWidget {
  const LocationStreamWidget({super.key});

  @override
  ConsumerState<LocationStreamWidget> createState() => _LocationStreamWidgetState();
}

class _LocationStreamWidgetState extends ConsumerState<LocationStreamWidget> {
  LatLng? _currentLocation;
  double _heading = 0.0;
  
  @override
  void initState() {
    super.initState();
    _setupLocationStream();
  }
  
  void _setupLocationStream() {
    // 권한 상태 변화 리스너
    ref.listen<LocationPermissionState>(locationPermissionNotifierProvider, (prev, next) {
      if (prev.hasLocationPermission != next.hasLocationPermission) {
        _handlePermissionStateChange(next);
      }
    });
    
    // 초기 권한 상태 확인
    final initialPermissionState = ref.read(locationPermissionNotifierProvider);
    _handlePermissionStateChange(initialPermissionState);
  }
  
  void _handlePermissionStateChange(LocationPermissionState permissionState) {
    final locationStreamService = ref.read(locationStreamServiceProvider);
    
    if (permissionState.hasLocationPermission) {
      _startLocationStream(locationStreamService);
    } else {
      _stopLocationStream(locationStreamService);
    }
  }
  
  void _startLocationStream(LocationStreamService service) {
    service.startStream();
    
    // 위치 스트림 리스너
    service.locationStream.listen((location) {
      setState(() {
        _currentLocation = location;
        _updateMarkers();
      });
    });
    
    // 방향 스트림 리스너
    service.headingStream.listen((heading) {
      setState(() {
        _heading = heading;
        _updateMarkers();
      });
    });
  }
  
  void _stopLocationStream(LocationStreamService service) {
    service.stopStream();
    setState(() {
      _currentLocation = null;
      _heading = 0.0;
    });
    // Provider를 통해 마커 초기화
    ref.read(locationMarkersProvider.notifier).state = {};
  }
  
  void _updateMarkers() {
    if (_currentLocation != null) {
      final markers = {
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: '내 위치'),
        ),
        Marker(
          markerId: const MarkerId('direction_marker'),
          position: _currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          anchor: const Offset(0.5, 0.5),
          rotation: _heading,
        ),
      };
      // Provider를 통해 마커 업데이트
      ref.read(locationMarkersProvider.notifier).state = markers;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // 보이지 않는 위젯 (위치 스트리밍만 담당)
    return const SizedBox.shrink();
  }
  
  @override
  void dispose() {
    ref.read(locationStreamServiceProvider).stopStream();
    super.dispose();
  }
}
```

#### MapWidget 단순화 (Provider 기반 마커 사용)
```dart
class MapWidget extends ConsumerWidget {
  const MapWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapRenderer = ref.watch(mapRendererProvider);
    final setMapControllerUseCase = ref.read(setMapControllerUseCaseProvider);
    final locationMarkers = ref.watch(locationMarkersProvider);

    return mapRenderer.renderMap(
      initialPosition: const LatLng(37.5665, 126.9780),
      zoom: 16,
      onMapCreated: (controller) {
        setMapControllerUseCase.execute(controller);
      },
      options: const MapRendererOptions(
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
      ),
      markers: locationMarkers, // Provider에서 마커 가져오기
    );
  }
}
```

### 9. MyLocationButton 개선 (LocationPermissionState 기반)

```dart
class MyLocationButton extends ConsumerWidget {
  const MyLocationButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionState = ref.watch(locationPermissionNotifierProvider);
    
    final buttonSize = ResponsiveSizing.getValueByDevice(
      context,
      mobile: 36.0,
      tablet: 42.0,
    );
    
    // 권한 상태에 따른 UI 결정
    final hasPermission = permissionState.hasLocationPermission;
    final isEnabled = permissionState.hasLocationPermission || 
                     permissionState.canRequestInApp;
    
    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hasPermission ? Colors.white : Colors.grey[300],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: ResponsiveSizing.getValueByDevice(
              context,
              mobile: 8.0,
              tablet: 10.0,
            ),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(buttonSize / 2),
          onTap: isEnabled 
            ? () => LocationPermissionHandler.handlePermissionAction(context, ref, permissionState)
            : null,
          child: Center(
            child: SvgPicture.asset(
              // 권한 상태에 따라 다른 아이콘
              hasPermission 
                ? 'assets/icons/location_button_icon.svg'
                : 'assets/icons/location_button_disabled_icon.svg',
              width: buttonSize,
              height: buttonSize,
              colorFilter: hasPermission 
                ? null 
                : ColorFilter.mode(Colors.grey[600]!, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}
```

#### LocationPermissionHandler 업데이트 (UseCase 직접 사용)
```dart
class LocationPermissionHandler {
  /// 권한 상태에 따른 액션 처리
  static void handlePermissionAction(
    BuildContext context,
    WidgetRef ref,
    LocationPermissionState permissionState,
  ) {
    final moveToCurrentLocationUseCase = ref.read(moveToCurrentLocationUseCaseProvider);
    final locationPermissionNotifier = ref.read(locationPermissionNotifierProvider.notifier);
    
    switch (permissionState) {
      case LocationPermissionGranted():
      case LocationPermissionPartial():
        // 권한이 있으면 현재 위치로 이동
        moveToCurrentLocationUseCase.execute();
        break;
        
      case LocationPermissionDenied():
        // in-app에서 권한 요청
        locationPermissionNotifier.requestPermission();
        break;
        
      case LocationPermissionPermanentlyDenied():
        // 설정으로 이동하는 모달 표시
        _showSettingsModal(context, permissionState.message);
        break;
        
      case LocationPermissionRestricted():
        // 위치 서비스 사용 불가 toast 메시지
        _showRestrictedToast(context, permissionState.message);
        break;
        
      default:
        // 다른 상태에서는 아무것도 하지 않음
        break;
    }
  }

  static void _showSettingsModal(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('위치 권한 필요'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }

  static void _showRestrictedToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.block, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
```

### 10. Provider 설정 및 의존성 주입

**Provider는 별도 파일이 아닌 구현체가 있는 파일의 가장 하단에 추가**

#### GoogleLocationService 파일 하단
```dart
// ... GoogleLocationService 구현체 ...

// Provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return GoogleLocationService();
});
```

#### GoogleLocationStreamService 파일 하단
```dart
// ... GoogleLocationStreamService 구현체 ...

// Provider
final locationStreamServiceProvider = Provider<LocationStreamService>((ref) {
  final locationService = ref.read(locationServiceProvider);
  return GoogleLocationStreamService(locationService);
});
```

#### LocationPermissionNotifier 파일 하단
```dart
// ... LocationPermissionNotifier 구현체 ...

// Provider
final locationPermissionNotifierProvider = StateNotifierProvider<LocationPermissionNotifier, LocationPermissionState>((ref) {
  return LocationPermissionNotifier(ref);
});
```

#### CheckLocationPermissionUseCase 파일 하단
```dart
// ... CheckLocationPermissionUseCase 구현체 ...

// Provider
final checkLocationPermissionUseCaseProvider = Provider<CheckLocationPermissionUseCase>((ref) {
  final locationRepository = ref.read(locationRepositoryProvider);
  return CheckLocationPermissionUseCase(locationRepository);
});
```

#### RequestLocationPermissionUseCase 파일 하단
```dart
// ... RequestLocationPermissionUseCase 구현체 ...

// Provider
final requestLocationPermissionUseCaseProvider = Provider<RequestLocationPermissionUseCase>((ref) {
  final locationRepository = ref.read(locationRepositoryProvider);
  return RequestLocationPermissionUseCase(locationRepository);
});
```

#### MapController Provider (새로 추가)
```dart
// map_controller.dart 파일 하단

// Provider
final mapControllerProvider = StateProvider<GoogleMapController?>((ref) => null);

final setMapControllerUseCaseProvider = Provider<SetMapControllerUseCase>((ref) {
  return SetMapControllerUseCase();
});

final getMapControllerUseCaseProvider = Provider<GetMapControllerUseCase>((ref) {
  return GetMapControllerUseCase();
});
```

#### LocationMarkers Provider (새로 추가)
```dart
// current_location_marker_widget.dart 파일 하단

// Provider
final locationMarkersProvider = StateProvider<Set<Marker>>((ref) => {});
```

#### LocationPermissionOverlayManager (새로 추가)
```dart
class LocationPermissionOverlayManager extends ConsumerWidget {
  const LocationPermissionOverlayManager({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionState = ref.watch(locationPermissionNotifierProvider);
    
    // Loading, Denied, PermanentlyDenied 상태에서만 오버레이 표시
    return switch (permissionState) {
      LocationPermissionLoading() ||
      LocationPermissionDenied() ||
      LocationPermissionPermanentlyDenied() =>
        LocationPermissionOverlay(permissionState: permissionState),
      _ => const SizedBox.shrink(),
    };
  }
}
```

### 11. 앱 생명주기 이벤트 처리 및 외부 권한 변경 감지

#### LocationPermissionNotifier에 앱 생명주기 통합
```dart
class LocationPermissionNotifier extends StateNotifier<LocationPermissionState> {
  LocationPermissionNotifier(this._ref) : super(const LocationPermissionInitial()) {
    _setupAppLifecycleObserver();
  }

  final Ref _ref;
  late final _AppLifecycleObserver _lifecycleObserver;
  
  // UseCase들
  CheckLocationPermissionUseCase get _checkPermission => 
      _ref.read(checkLocationPermissionUseCaseProvider);
  RequestLocationPermissionUseCase get _requestPermission =>
      _ref.read(requestLocationPermissionUseCaseProvider);

  void _setupAppLifecycleObserver() {
    _lifecycleObserver = _AppLifecycleObserver(this);
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
  }

  /// 앱 시작 시 권한 상태 확인
  Future<void> checkPermission() async {
    state = const LocationPermissionLoading();
    
    try {
      final result = await _checkPermission.execute();
      _updateStateFromResult(result);
    } catch (e) {
      state = const LocationPermissionDenied(
        message: '위치 권한 상태를 확인할 수 없습니다.',
      );
    }
  }

  /// 앱 내에서 권한 요청
  Future<void> requestPermission() async {
    state = const LocationPermissionLoading();
    
    try {
      final result = await _requestPermission.execute();
      _updateStateFromResult(result);
    } catch (e) {
      state = const LocationPermissionDenied(
        message: '위치 권한 요청에 실패했습니다.',
      );
    }
  }

  /// 앱이 포그라운드로 돌아올 때 호출 (외부 권한 변경 감지)
  Future<void> onAppResumed() async {
    // 앱이 백그라운드에서 포그라운드로 돌아올 때 권한 상태 재확인
    // 사용자가 설정에서 권한을 변경했을 수 있음
    await checkPermission();
  }

  void _updateStateFromResult(LocationPermissionResult result) {
    if (result.canUseService) {
      if (result.isPartialService) {
        state = LocationPermissionPartial(message: result.message ?? '');
      } else {
        state = const LocationPermissionGranted();
      }
    } else if (result.shouldShowSettingsModal) {
      state = LocationPermissionPermanentlyDenied(
        message: result.message ?? '',
      );
    } else if (result.canRequestInApp) {
      state = LocationPermissionDenied(
        message: result.message ?? '',
      );
    } else {
      state = LocationPermissionRestricted(
        message: result.message ?? '',
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }
}

class _AppLifecycleObserver extends WidgetsBindingObserver {
  final LocationPermissionNotifier _notifier;
  
  _AppLifecycleObserver(this._notifier);
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 포그라운드로 돌아올 때 권한 상태 재확인
      _notifier.onAppResumed();
    }
  }
}
```

### 12. iOS 권한 처리 구현

```dart
// LocationRepository에서 권한 처리
class GoogleLocationRepository implements LocationRepository {
  @override
  Future<LocationPermissionResult> checkPermission() async {
    final permission = await Permission.location.status;
    return LocationPermissionResult.fromPermissionStatus(permission);
  }
  
  @override
  Future<LocationPermissionResult> requestPermission() async {
    final permission = await Permission.location.request();
    return LocationPermissionResult.fromPermissionStatus(permission);
  }
}

// LocationPermissionResult의 fromPermissionStatus 메서드
static LocationPermissionResult fromPermissionStatus(PermissionStatus status) {
  switch (status) {
    case PermissionStatus.granted:
      return const LocationPermissionResult(
        canUseService: true,
        isPartialService: false,
        canRequestInApp: false,
        shouldShowSettingsModal: false,
      );
      
    case PermissionStatus.denied:
      return const LocationPermissionResult(
        canUseService: false,
        isPartialService: false,
        canRequestInApp: true,
        shouldShowSettingsModal: false,
        message: '위치 권한이 거부되었습니다.',
      );
      
    case PermissionStatus.permanentlyDenied:
      return const LocationPermissionResult(
        canUseService: false,
        isPartialService: false,
        canRequestInApp: false,
        shouldShowSettingsModal: true,
        message: '위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.',
      );
      
    case PermissionStatus.restricted:
      return const LocationPermissionResult(
        canUseService: false,
        isPartialService: false,
        canRequestInApp: false,
        shouldShowSettingsModal: false,
        message: '위치 권한이 제한되었습니다.',
      );
      
    case PermissionStatus.limited:
      return const LocationPermissionResult(
        canUseService: true,
        isPartialService: true,
        canRequestInApp: false,
        shouldShowSettingsModal: false,
        message: '위치가 정확하지 않을 수 있습니다.',
      );
      
    case PermissionStatus.provisional:
      return const LocationPermissionResult(
        canUseService: true,
        isPartialService: false,
        canRequestInApp: false,
        shouldShowSettingsModal: false,
      );
      
    default:
      return const LocationPermissionResult(
        canUseService: false,
        isPartialService: false,
        canRequestInApp: false,
        shouldShowSettingsModal: false,
        message: '위치 권한 상태를 확인할 수 없습니다.',
      );
  }
}
```

## 구현 우선순위

### Phase 1: 핵심 구조 개선 (필수)
1. **MapState 및 MapNotifier 제거** - MapState 완전 제거, LocationPermissionState 중심으로 전환
2. **LocationPermissionState 구현** - 6개 상태로 권한 상태 세분화
3. **권한 UseCase 분리** - CheckLocationPermissionUseCase, RequestLocationPermissionUseCase 분리
4. **LocationPermissionNotifier 구현** - 권한 상태 전용 Notifier 생성
5. **UseCase에서 ExceptionNotifier 직접 사용** - GetCurrentLocationUseCase, MoveToCurrentLocationUseCase 업데이트

### Phase 2: Provider 기반 마커 관리 구현 (권장)
1. **LocationStreamWidget 분리** - 위치 스트리밍 전용 위젯 생성
2. **Provider 기반 마커 관리** - locationMarkersProvider로 마커 상태 관리
3. **MapWidget 단순화** - Provider에서 마커를 가져와서 렌더링만 담당
4. **LocationPermissionOverlayManager** - 권한 상태 기반 오버레이 관리

### Phase 3: 위치 스트리밍 서비스 구현 (권장)
1. **LocationStreamService 구현** - 위치 스트리밍 전용 서비스
2. **LocationService 확장** - location 패키지와의 의존성 추상화
3. **커스텀 마커 구현** - 위치 및 방향 표시용 커스텀 마커
4. **MapController Provider** - StateProvider로 GoogleMapController 관리

### Phase 4: UI 처리 개선 (권장)
1. **권한 상태별 UI 컴포넌트 분리** - LocationPermissionOverlay, LocationPermissionHandler 구현
2. **MapPage 오버레이 UI 처리** - 재사용 가능한 컴포넌트 사용
3. **MyLocationButton 개선** - LocationPermissionHandler 통합 사용
4. **iOS 권한 처리 구현** - 설정으로 이동하는 모달 처리
5. **앱 생명주기 이벤트 통합** - 외부 권한 변경 감지

## 예상 효과

### 1. 구조 대폭 단순화
- **MapState 및 MapNotifier 완전 제거**: 불필요한 Map 상태 관리 제거
- **LocationPermissionState 중심**: 권한 상태만 관리하는 명확한 구조
- **책임 분리**: 권한 관리, 위치 스트리밍, Map 렌더링 완전 분리
- **Provider 기반 마커 관리**: Riverpod 패턴으로 일관된 상태 관리

### 2. 위치 서비스 완전 제어
- **GoogleMap 내장 기능 비활성화**: myLocationEnabled, myLocationButtonEnabled 모두 false
- **커스텀 위치 스트리밍**: location 패키지 기반 실시간 위치 및 방향 스트리밍
- **권한 상태 기반 제어**: 권한 상태에 따른 동적 스트리밍 시작/중지

### 3. 권한 상태 세분화
- **6개 권한 상태**: Initial, Loading, Granted, Partial, Denied, PermanentlyDenied, Restricted
- **플랫폼별 권한 처리**: iOS limited, restricted 등 플랫폼 특화 상태 처리
- **명확한 액션 정의**: 각 상태별 가능한 액션 명확히 정의
- **단순화된 필드**: canRequestInApp 하나로 in-app 요청과 설정 모달 구분

### 4. 의존성 추상화
- **LocationService 인터페이스**: location 패키지와의 의존성 추상화
- **LocationStreamService 인터페이스**: 위치 스트리밍 로직 추상화
- **테스트 용이성**: Mock 객체로 쉽게 테스트 가능

### 5. 외부 권한 변경 감지
- **앱 생명주기 이벤트**: AppLifecycleState.resumed에서 권한 상태 재확인
- **자동 동기화**: 사용자가 설정에서 권한 변경 시 자동 감지 및 UI 업데이트
- **실시간 반영**: 권한 변경 즉시 MapWidget의 위치 스트리밍 상태 변경

### 6. 사용자 경험 개선
- **Map 항상 렌더링**: 권한 상태와 관계없이 Map 즉시 표시
- **동적 UI**: 권한 상태에 따른 MyLocationButton UI/동작 변경
- **직관적 오버레이**: 권한 상태별 적절한 오버레이 UI 표시
- **실시간 위치 표시**: 권한 허용 시 실시간 위치 및 방향 마커 표시
- **일관된 권한 처리**: MapPage와 MyLocationButton에서 동일한 권한 상태별 처리
- **Toast 메시지**: Partial, Restricted 상태에서 간단한 알림 표시

### 7. 유지보수성 향상
- **단일 책임 원칙**: 각 클래스가 명확한 단일 책임 (MapWidget은 렌더링만, LocationStreamWidget은 스트리밍만)
- **의존성 역전**: 인터페이스 기반 의존성 주입
- **테스트 용이성**: Mock 객체로 각 레이어 독립 테스트 가능
- **확장성**: 새로운 위치 서비스 구현체 쉽게 추가 가능
- **재사용성**: LocationPermissionOverlay, LocationPermissionHandler로 권한 처리 로직 재사용
- **일관성**: 동일한 권한 상태에 대해 동일한 UI/동작 보장
- **Provider 패턴**: Riverpod의 일관된 상태 관리 패턴으로 코드 일관성 향상

### 8. 성능 최적화
- **권한 기반 스트리밍**: 권한이 없을 때 불필요한 위치 스트리밍 방지
- **리소스 관리**: 스트리밍 시작/중지로 배터리 및 네트워크 리소스 최적화
- **메모리 효율성**: 불필요한 상태 관리 제거로 메모리 사용량 감소
- **Provider 기반 최적화**: 필요한 위젯만 리빌드되도록 세밀한 상태 관리
- **위젯 분리**: MapWidget과 LocationStreamWidget 분리로 불필요한 리빌드 방지

### 9. Provider 기반 아키텍처의 장점
- **일관된 상태 관리**: Riverpod 패턴으로 모든 상태를 Provider로 관리
- **테스트 용이성**: Provider를 Mock으로 교체하여 쉽게 테스트
- **상태 공유**: 다른 위젯에서도 마커 정보나 권한 상태 쉽게 접근
- **타입 안전성**: Provider의 타입 안전성으로 런타임 에러 방지
- **디버깅 용이성**: Riverpod Inspector로 상태 변화 추적 가능

이 구조로 구현하면 Map은 항상 렌더링되고, 권한 상태에 따라 실시간 위치 스트리밍이 동적으로 제어되며, iOS의 다양한 권한 설정에 완벽하게 대응할 수 있습니다. Provider 기반 마커 관리로 더욱 깔끔하고 유지보수하기 쉬운 구조가 됩니다.
