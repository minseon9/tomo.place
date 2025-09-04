# Event-driven UI, Session Bus, Riverpod, Listener 개념 정리

## 1. Event-driven Architecture (이벤트 주도 아키텍처)
- **핵심 개념**: 구성 요소들이 서로 직접 호출하지 않고, 이벤트를 발행/구독하는 방식으로 결합도를 낮추는 아키텍처.
- **장점**
  - **낮은 결합도**: 발행자는 구독자의 존재를 몰라도 됨
  - **확장성**: 새로운 리스너를 추가해도 발행자 수정 불필요
  - **관심사 분리**: 도메인/인프라와 UI 로직 분리
- **단점/유의점**
  - 디버깅 난이도↑ (흐름 추적 필요)
  - 이벤트 남발 시 상태 일관성 관리 어려움 → 명확한 이벤트 정의와 스코프 필요

### 간단 예시 (Dart)
```dart
final controller = StreamController<String>.broadcast();

// Listener
controller.stream.listen((e) => print('Received: $e'));

// Publisher
controller.add('EVENT_LOGIN_EXPIRED');
```

---

## 2. Session Bus (세션 이벤트 버스)
- **정의**: 인증/세션 관련 전역 이벤트(예: expired, signedOut)를 방송하는 전역 채널.
- **목적**: 네트워크/인프라 레이어가 UI를 몰라도 세션 상태 변화를 “알릴” 수 있게 함.
- **동작**
  1) 인프라(예: Interceptor) → `SessionEventBus.publish(SessionEvent.expired)`
  2) UI 루트 → `stream`을 구독하고 라우팅/스낵바 처리
- **예시**
```dart
enum SessionEvent { expired, signedOut }
class SessionEventBus {
  final _c = StreamController<SessionEvent>.broadcast();
  Stream<SessionEvent> get stream => _c.stream;
  void publish(SessionEvent e) => _c.add(e);
  void dispose() => _c.close();
}
```

---

## 3. Event Stream (이벤트 스트림)
- **정의**: 비동기 이벤트의 시퀀스를 나타내는 스트림. 여러 리스너가 동시에 구독 가능(broadcast).
- **사용처**
  - 글로벌 토스트/다이얼로그 트리거
  - 세션/권한 전이 알림
  - 로깅/모니터링
- **주의**
  - backpressure 고려(필요 시 버퍼링/디바운스)
  - 생명주기: 앱 종료 시 `close()`

---

## 4. Riverpod
- **핵심 개념**: DI + 상태관리를 선언적으로 제공하는 프레임워크. 전역 공유 가능하지만 테스트/스코프 제어가 쉬움.
- **주요 타입**
  - `Provider<T>`: 불변/DI 객체 제공
  - `StateProvider<T>`: 간단한 상태
  - `StateNotifierProvider<TNotifier, TState>`: 비즈니스 로직 포함된 상태 기계
  - `FutureProvider/StreamProvider`: 비동기 데이터
- **장점**
  - Compile-time safety, 명확한 의존성 그래프
  - `ref.listen`/`ref.watch`를 통한 선언적 리액티브 UI

### 간단 예시
```dart
final counterProvider = StateNotifierProvider<Counter, int>((ref) => Counter());
class Counter extends StateNotifier<int> { Counter(): super(0); void inc()=>state++; }

class CounterText extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(counterProvider);
    return Text('$value');
  }
}
```

---

## 5. Listener (ProviderListener / StreamListener)
- **정의**: 상태 변화나 이벤트를 “관찰”하여, UI 부수효과(side effect: 네비게이션, 다이얼로그 등)를 실행하는 구성 요소.
- **종류**
  - Riverpod: `ref.listen(provider, (prev, next) { ... })`
  - Stream: `stream.listen((event) { ... })`
- **역할 분리**
  - 상태 전이는 Notifier/UseCase에서 수행
  - UI 효과는 Listener에서만 수행(네비게이션/스낵바/다이얼로그)

### 간단 예시 (세션/에러 리스너)
```dart
// 세션
ref.listen<SessionState>(sessionStateProvider, (prev, next) {
  switch (next) {
    case Unauthenticated(:final reason):
      ref.read(navigationActionsProvider).showSnackBar(reason ?? '세션 만료');
      ref.read(navigationActionsProvider).navigateToSignup();
    case Authenticated():
      // no-op
  }
});

// 에러
ref.listen<ErrorInterface?>(errorEffectsProvider, (prev, next) {
  if (next != null) {
    ErrorDialog.show(context: context, error: next);
    ref.read(errorEffectsProvider.notifier).clear();
  }
});
```

---

## 6. Global Error Handling (전역 에러 처리)
- **아이디어**: 페이지에서 다이얼로그 직접 호출 금지. 전역 채널에 `report(error)`만 수행.
- **경로**
  - 단기: `ErrorReporter`(Stream) → 루트에서 구독해 `ErrorDialog`/`SnackBar` 표준화
  - 중기: `errorEffectsProvider`(Riverpod)로 일원화 → `ref.listen`으로 효과 처리
- **예시**
```dart
class ErrorReporter {
  final _c = StreamController<ErrorInterface>.broadcast();
  Stream<ErrorInterface> get stream => _c.stream;
  void report(ErrorInterface e) => _c.add(e);
}

// 루트
StreamBuilder<ErrorInterface>(
  stream: errorReporter.stream,
  builder: (context, s) {
    if (s.hasData) ErrorDialog.show(context: context, error: s.data!);
    return MaterialApp(...);
  },
);
```

---

## 7. Interceptor와 UI 디커플링
- **문제**: 인프라 레이어(Interceptor)가 Navigator/Context를 직접 호출 → 강결합/테스트 어려움
- **해결**
  - 이벤트 버스 or 게이트웨이(SessionGateway)로 상태만 표출
  - UI 루트 Listener가 네비게이션/알림 처리
- **장점**: 책임 분리, 테스트 용이성 증가, 정책 변경(스낵바→다이얼로그) 시 UI만 수정

---

## 8. 권장 설계 원칙
- **단방향 흐름**: 도메인/인프라 → (이벤트/상태) → UI Listener → 부수효과
- **경계 존중**: 인프라/도메인은 UI API(BuildContext/Navigator)를 모름
- **일관된 UX**: 전역 에러/세션 처리를 표준 컴포넌트로 통일
- **점진 전환**: EventBus(단기) → Riverpod Provider(중기)로 자연스러운 이행

---

## 9. 체크리스트
- [ ] Interceptor에 UI 호출이 남아있지 않은가?
- [ ] 전역 에러/세션 채널이 존재하며 루트에서 구독하는가?
- [ ] 페이지에서 에러 다이얼로그 직접 호출을 제거했는가?
- [ ] 네비게이션은 전역 `navigatorKey`/Provider를 통해 일관되게 수행되는가?
- [ ] 테스트에서 Listener를 쉽게 목킹/검증 가능한가?

---

## 10. 참조 구현 링크(파일)
- `app/docs/execution_plan_riverpod_navigation_error.md`
- `app/lib/shared/navigation/navigation_providers.dart` (예정)
- `app/lib/shared/services/session_event_bus.dart` (예정)
- `app/lib/shared/services/error_reporter.dart` (예정)
- `app/lib/shared/session/session_notifier.dart` (예정)
- `app/lib/shared/errors/error_effects_provider.dart` (예정)
