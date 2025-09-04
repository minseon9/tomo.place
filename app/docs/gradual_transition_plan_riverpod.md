# Gradual Transition Plan: EventBus → Riverpod (Session & Errors)

## Goal
- EventBus 기반(세션/에러)을 Riverpod Provider 기반으로 점진 전환
- UI 루트에서 ref.listen으로 라우팅/알림 처리
- NavigationService/StreamBus 제거 경로 제시

## Current Baseline
- SessionEventBus + ErrorReporter 스트림 구독 (TomoPlaceApp.initState)
- AuthInterceptor → SessionEventBus.publish(SessionEvent.expired)
- AuthController → ErrorReporter.report(error)

## Target Architecture
- sessionStateProvider(StateNotifier) + SessionGateway
- errorEffectsProvider(StateNotifier)
- TomoPlaceApp: ref.listen(sessionStateProvider / errorEffectsProvider)

### Controllers/Services Migration (Overview)
- Controllers: Cubit → StateNotifier 전환, UI는 BlocConsumer → Consumer/ref.listen로 변경
- Services/UseCases: GetIt 등록 유지하되, Riverpod Provider로 팩토리 제공(브리지) → 최종적으로 GetIt 제거

## Step-by-step
1) Add Riverpod session providers [Pending]
- File: `app/lib/shared/session/session_notifier.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

sealed class SessionState { const SessionState(); }
class Authenticated extends SessionState { const Authenticated(); }
class Unauthenticated extends SessionState { final String? reason; const Unauthenticated(this.reason); }

abstract class SessionGateway { void markUnauthenticated(String? reason); void markAuthenticated(); }

class SessionNotifier extends StateNotifier<SessionState> implements SessionGateway {
  SessionNotifier() : super(const Unauthenticated(null));
  @override void markUnauthenticated(String? reason) { state = Unauthenticated(reason); }
  @override void markAuthenticated() { state = const Authenticated(); }
}

final sessionStateProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) => SessionNotifier());
```

2) Add Riverpod error effects provider [Pending]
- File: `app/lib/shared/errors/error_effects_provider.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../exceptions/exception_interface.dart';

class ErrorEffects extends StateNotifier<ErrorInterface?> {
  ErrorEffects() : super(null);
  void report(ErrorInterface error) => state = error;
  void clear() => state = null;
}

final errorEffectsProvider = StateNotifierProvider<ErrorEffects, ErrorInterface?>((ref) => ErrorEffects());
```

3) Bridge: Wire gateway from GetIt to Riverpod [Pending]
- Option A: Provide `SessionGateway` via GetIt using a Riverpod accessor
- File: `app/lib/app/di/shared/shared_module.dart`
```dart
// after ProviderScope is available, supply a lazy accessor if needed
```
- Option B: Inject SessionNotifier into Interceptor through a thin adapter

4) Update AuthInterceptor to use SessionGateway (keep current bus as fallback) [Pending]
- Replace SessionEventBus with SessionGateway in constructor; publish via Riverpod

5) Update AuthController to report via errorEffectsProvider (keep ErrorReporter fallback) [Pending]
- Replace ErrorReporter with ErrorEffects notifier access

6) TomoPlaceApp: switch from stream subscriptions to ref.listen [Pending]
```dart
ref.listen<SessionState>(sessionStateProvider, (prev, next) {
  switch (next) {
    case Unauthenticated(:final reason):
      ref.read(navigationActionsProvider).showSnackBar(reason ?? '세션 만료');
      ref.read(navigationActionsProvider).navigateToSignup();
    case Authenticated():
      // no-op
  }
});

ref.listen<ErrorInterface?>(errorEffectsProvider, (prev, next) {
  if (next != null) {
    final key = ref.read(navigatorKeyProvider);
    final ctx = key.currentContext;
    if (ctx != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(next.userMessage)));
    }
    ref.read(errorEffectsProvider.notifier).clear();
  }
});
```

7) Remove EventBus & ErrorReporter usages incrementally [Pending]
- Replace all `NavigationService.*` callsites with `navigationActionsProvider`
- Remove `SessionEventBus` and `ErrorReporter` registrations from SharedModule

8) Final cleanup [Pending]
- Remove `NavigationService`
- Remove deprecated `GlobalContext` if any
- Convert Auth Cubit → Riverpod StateNotifier

9) Controllers Migration Details [Pending]
- New file: `app/lib/domains/auth/presentation/controllers/auth_notifier.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/exceptions/exception_interface.dart';
import '../../consts/social_provider.dart';
import '../../core/entities/auth_token.dart';
import '../../core/usecases/logout_usecase.dart';
import '../../core/usecases/signup_with_social_usecase.dart';

sealed class AuthState { const AuthState(); }
class AuthInitial extends AuthState { const AuthInitial(); }
class AuthLoading extends AuthState { const AuthLoading(); }
class AuthSuccess extends AuthState { const AuthSuccess(); }
class AuthFailure extends AuthState { final ErrorInterface error; const AuthFailure(this.error); }

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._signup, this._logout, this._errorEffects) : super(const AuthInitial());
  final SignupWithSocialUseCase _signup;
  final LogoutUseCase _logout;
  final ErrorEffects _errorEffects; // from errorEffectsProvider.notifier

  Future<void> signupWithProvider(SocialProvider provider) async {
    state = const AuthLoading();
    try {
      final AuthToken? token = await _signup.execute(provider);
      if (token == null) { state = const AuthInitial(); return; }
      state = const AuthSuccess();
    } catch (e) {
      final err = mapToUiError(e);
      state = AuthFailure(err);
      _errorEffects.report(err);
    }
  }

  Future<void> logout() async {
    state = const AuthLoading();
    try {
      await _logout.execute();
      state = const AuthInitial();
    } catch (e) {
      final err = mapToUiError(e);
      state = AuthFailure(err);
      _errorEffects.report(err);
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(signupWithSocialUseCaseProvider),
    ref.read(logoutUseCaseProvider),
    ref.read(errorEffectsProvider.notifier),
  );
});
```

10) UI Migration Details [Pending]
- `SignupPage`: BlocConsumer 제거 → `ref.listen(authNotifierProvider, ...)` + 버튼에서 `ref.read(authNotifierProvider.notifier).signupWithProvider(...)`
- Navigation은 기존과 동일하게 `navigationActionsProvider` 사용

11) Providers across shared/network/storage/auth [Pending]
- shared/storage
  - File: `app/lib/shared/infrastructure/storage/token_storage_provider.dart`
  - Provide `TokenStorageService` as `Provider<TokenStorageService>`
  - Provide `AccessTokenMemoryStore` as `Provider<AccessTokenMemoryStore>`
- shared/network
  - File: `app/lib/shared/infrastructure/network/api_client_provider.dart`
  - Provide `ApiClient` with constructor that adds `AuthInterceptor`
  - Provide `AuthInterceptor` with deps from providers
- auth/data & domain
  - Files: `auth_api_data_source_provider.dart`, `auth_storage_data_source_provider.dart`, `auth_repository_provider.dart`, `auth_token_repository_provider.dart`, `usecases_providers.dart`
  - Each maps GetIt registrations to Riverpod Providers
- Wiring
  - Keep GetIt registrations during transition; providers internally call GetIt or vice versa (adapter), then flip dependency direction and remove GetIt later

12) Replace NavigationService usages [Pending]
- Files: `app/lib/app/pages/splash_page.dart`, any others using `NavigationService.*`
- Replace with `ref.read(navigationActionsProvider).*` or session state emissions

13) Retire GetIt modules [Pending]
- After providers are in place and callsites migrated, remove `app/lib/app/di/*` modules
- Update `main.dart` to drop `initializeDependencies()` when fully migrated

14) Tests [Pending]
- Provider wiring tests (override providers)
- Interceptor behavior tests (401 → session state emission)
- Error effects tests (report → snackbar/dialog effect)

## Risks & Mitigations
- Mixed DI (GetIt + Riverpod): keep a thin adapter during transition
- Navigator context availability: always use `navigatorKeyProvider`
- Event duplication: debounce in providers if needed

## Progress Status
1. Create session provider [Pending]
2. Create error effects provider [Pending]
3. Wire gateway (adapter) [Pending]
4. Interceptor to SessionGateway [Pending]
5. Controller to errorEffects [Pending]
6. TomoPlaceApp ref.listen 적용 [Pending]
7. Remove buses and global services [Pending]
8. Cleanup and StateNotifier migration [Pending]
