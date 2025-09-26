# Map 도메인 Line Coverage 부족 코드 상세 분석

## 📊 **전체 Coverage 현황**
- **전체 프로젝트**: 77.9% (1099/1410 lines)
- **Map 도메인**: 대부분의 새로운 로직이 테스트되지 않음

---

## ❌ **Line Coverage가 되지 않는 부분들**

### **1. Core Layer - UseCase**

#### **1-1. GetCurrentLocationUseCase** - **0% Coverage**
**파일**: `lib/domains/map/core/usecases/get_current_location_usecase.dart`

**커버되지 않는 라인들**:
```dart
Line 16: throw LocationPermissionDeniedException(); // 0 hits
Line 19: throw LocationNotFoundException(); // 0 hits  
Line 30-39: LocationPermissionDeniedException 클래스 정의 // 0 hits
Line 40-49: LocationNotFoundException 클래스 정의 // 0 hits
```

**테스트 코드**: `test/domains/map/core/usecases/get_current_location_usecase_test.dart`
- ✅ 성공 시나리오 테스트 있음
- ❌ 권한 거부 시나리오 테스트 없음
- ❌ 위치 조회 실패 시나리오 테스트 없음
- ❌ Exception 클래스 속성 테스트 없음

---

#### **1-2. MoveToLocationUseCase** - **100% Coverage** ✅
**파일**: `lib/domains/map/core/usecases/move_to_location_usecase.dart`
- 모든 라인이 테스트됨

---

### **2. Data Layer - Service & Repository**

#### **2-1. MapControllerServiceImpl** - **0% Coverage**
**파일**: `lib/domains/map/data/services/map_controller_service_impl.dart`

**커버되지 않는 라인들**:
```dart
Line 12: void setMapController(MapController controller) // 0 hits
Line 14: _mapController = controller; // 0 hits
Line 17: Future<void> moveToLocation(LatLng position) async // 0 hits
Line 19: if (_mapController == null) // 0 hits
Line 20: throw MapControllerNotReadyException(); // 0 hits
Line 22: await _mapController!.moveToLocation(position); // 0 hits
Line 25: Future<void> setZoom(double zoom) async // 0 hits
Line 27: if (_mapController == null) // 0 hits
Line 28: throw MapControllerNotReadyException(); // 0 hits
Line 30: await _mapController!.setZoom(zoom); // 0 hits
Line 33-42: MapControllerNotReadyException 클래스 정의 // 0 hits
```

**테스트 코드**: `test/domains/map/data/services/map_controller_service_impl_test.dart`
- ❌ 모든 테스트가 실행되지 않음 (컴파일 오류 또는 테스트 실행 실패)

---

#### **2-2. GoogleLocationService** - **6% Coverage**
**파일**: `lib/domains/map/data/services/google_location_service.dart`

**커버되지 않는 라인들**:
```dart
Line 24-31: 권한 요청 실패 시나리오 // 0 hits
Line 28-30: 서비스 비활성화 시나리오 // 0 hits
Line 37-41: isServiceEnabled 메서드 // 0 hits
```

**테스트 코드**: `test/domains/map/data/services/google_location_service_test.dart`
- ✅ 기본 메서드 호출 테스트 있음
- ❌ 실제 Location 서비스 실패 시나리오 테스트 없음
- ❌ 권한 거부 시나리오 테스트 없음

---

#### **2-3. LocationRepositoryImpl** - **100% Coverage** ✅
**파일**: `lib/domains/map/data/repositories/location_repository_impl.dart`
- 모든 라인이 테스트됨

---

#### **2-4. GoogleMapRenderer** - **0% Coverage**
**파일**: `lib/domains/map/data/map/google_map_renderer.dart`

**커버되지 않는 라인들**:
```dart
Line 7-14: renderMap 메서드 // 0 hits
Line 15-18: GoogleMap 위젯 생성 // 0 hits
Line 22-25: GoogleMapControllerWrapper 생성자 // 0 hits
Line 27-33: moveToLocation 메서드 // 0 hits
Line 35-41: setZoom 메서드 // 0 hits
Line 43-49: getCurrentLocation 메서드 // 0 hits
Line 51-53: dispose 메서드 // 0 hits
```

**테스트 코드**: `test/domains/map/data/map/google_map_renderer_test.dart`
- ❌ 모든 테스트가 실행되지 않음 (Widget 테스트 환경 문제)

---

### **3. Presentation Layer**

#### **3-1. MapNotifier** - **34% Coverage**
**파일**: `lib/domains/map/presentation/controllers/map_notifier.dart`

**커버되지 않는 라인들**:
```dart
Line 24-27: 예외 처리 로직 // 0 hits
Line 25-26: UnknownException 변환 // 0 hits
Line 29: ExceptionNotifier.report 호출 // 0 hits
```

**테스트 코드**: `test/domains/map/presentation/controllers/map_notifier_test.dart`
- ✅ 기본 상태 변경 테스트 있음
- ❌ 예외 처리 시나리오 테스트 없음
- ❌ UnknownException 변환 테스트 없음

---

#### **3-2. MapWidget** - **64% Coverage**
**파일**: `lib/domains/map/presentation/widgets/organisms/map_widget.dart`

**커버되지 않는 라인들**:
```dart
Line 25: MapError 상태 처리 // 0 hits
Line 29: 기타 상태 처리 (SizedBox.shrink) // 0 hits
```

**테스트 코드**: `test/domains/map/presentation/widgets/organisms/map_widget_test.dart`
- ✅ MapLoading, MapReady 상태 테스트 있음
- ❌ MapError 상태 테스트 없음
- ❌ 기타 상태 테스트 없음

---

#### **3-3. MapProviders** - **73% Coverage**
**파일**: `lib/domains/map/presentation/providers/map_providers.dart`

**커버되지 않는 라인들**:
```dart
Line 22-23: Provider 의존성 검증 // 0 hits
Line 36-37: Provider 생명주기 테스트 // 0 hits
```

**테스트 코드**: `test/domains/map/presentation/providers/map_providers_test.dart`
- ✅ 기본 Provider 생성 테스트 있음
- ❌ Provider 의존성 검증 테스트 없음
- ❌ Provider 생명주기 테스트 없음

---

### **4. Core Layer - Entity**

#### **4-1. CategoryModel** - **5% Coverage**
**파일**: `lib/domains/map/core/entities/category_model.dart`

**커버되지 않는 라인들**:
```dart
Line 14-19: copyWith 메서드 // 0 hits
Line 20-23: equality 관련 메서드 // 0 hits
Line 24-28: toString 메서드 // 0 hits
Line 31-32: 불변성 검증 // 0 hits
```

**테스트 코드**: `test/domains/map/core/entities/category_model_test.dart`
- ✅ 기본 생성자 테스트 있음
- ❌ copyWith 메서드 테스트 없음
- ❌ equality 테스트 없음
- ❌ toString 테스트 없음

---

### **5. 기타 파일들**

#### **5-1. MapPageInterface** - **0% Coverage**
**파일**: `lib/domains/map/presentation/pages/map_page_interface.dart`
```dart
Line 5: abstract class MapPageInterface // 0 hits
```

#### **5-2. MapPage** - **91% Coverage**
**파일**: `lib/domains/map/presentation/pages/map_page.dart`
```dart
Line 18: 에러 상태 처리 // 0 hits
Line 23: 기타 상태 처리 // 0 hits
```

---

## **Coverage 부족 원인 분석**

### **1. 테스트 실행 실패**
- **MapControllerServiceImpl**: 테스트 코드는 있지만 실행되지 않음
- **GoogleMapRenderer**: Widget 테스트 환경 문제로 실행되지 않음

### **2. 테스트 시나리오 부족**
- **예외 처리**: 권한 거부, 위치 조회 실패, MapController 미설정 등
- **에러 상태**: MapError, 기타 상태 처리
- **Entity 메서드**: copyWith, equality, toString 등

### **3. 외부 의존성 제한**
- **GoogleLocationService**: 테스트 환경에서 실제 Location 서비스 제한
- **GoogleMapRenderer**: 실제 GoogleMap 위젯 렌더링 제한

### **4. Provider 테스트 부족**
- **의존성 검증**: Provider 간 의존성 확인
- **생명주기**: Container dispose 시 정리 확인

---

## **우선순위별 해결 방안**

### **우선순위 1: 핵심 비즈니스 로직 (즉시 해결 가능)**
1. **GetCurrentLocationUseCase** - 예외 처리 시나리오 추가
2. **MapNotifier** - 예외 처리 및 UnknownException 변환 테스트
3. **CategoryModel** - Entity 메서드 테스트 추가

### **우선순위 2: UI 상태 관리 (즉시 해결 가능)**
4. **MapWidget** - MapError 및 기타 상태 테스트
5. **MapProviders** - Provider 의존성 및 생명주기 테스트

### **우선순위 3: 외부 의존성 (제한적 해결)**
6. **GoogleLocationService** - Mock을 통한 실패 시나리오 테스트
7. **GoogleMapRenderer** - Widget 테스트 환경 개선

### **우선순위 4: 테스트 실행 문제 (기술적 해결)**
8. **MapControllerServiceImpl** - 테스트 실행 오류 수정
9. **GoogleMapRenderer** - Widget 테스트 환경 문제 해결

---

## **현재 달성률**
- **Core Layer**: 50% (2/4 파일)
- **Data Layer**: 25% (1/4 파일)  
- **Presentation Layer**: 67% (2/3 파일)
- **전체 Map 도메인**: **약 40%**

---

## **다음 단계**
1. 우선순위 1-2 항목들을 먼저 해결하여 핵심 비즈니스 로직의 coverage를 100%로 달성
2. 우선순위 3-4 항목들은 기술적 제약사항을 고려하여 점진적으로 개선
3. 전체 Map 도메인의 coverage를 90% 이상으로 달성하는 것을 목표로 설정
