# AuthState 관리 패턴 가이드

## 개요

이 문서는 Flutter Riverpod를 사용한 인증 상태 관리의 일관된 패턴을 설명합니다. `AuthState`와 `AuthNotifier`를 통한 상태 관리 방식을 중심으로 작성되었습니다.

## 핵심 원칙

### 1. 단일 책임 원칙 (Single Responsibility Principle)

각 컴포넌트는 명확한 하나의 책임만 가집니다:

- **AuthState**: 인증 **상태**만 관리 (성공/실패/로딩/초기)
- **AuthToken**: 토큰 **데이터**만 관리
- **AuthNotifier**: 상태 **변경**만 관리
- **AuthRepository**: 토큰 **저장/조회**만 관리

### 2. 일관된 호출 패턴

모든 인증 관련 액션은 `AuthNotifier`를 통해 수행합니다:

```dart
// ✅ 올바른 방법
ref.read(authNotifierProvider.notifier).signupWithProvider(provider);
ref.read(authNotifierProvider.notifier).logout();
ref.read(authNotifierProvider.notifier).refreshToken();

// ❌ 잘못된 방법 - 상태 변화 감지 안됨
ref.read(signupWithSocialUseCaseProvider).execute(provider);
```

## 상태 관리 구조

### AuthState 정의

```dart
abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthState {
  const AuthLoading();
  @override
  List<Object?> get props => [];
}

class AuthSuccess extends AuthState {
  const AuthSuccess();
  @override
  List<Object?> get props => [];
}

class AuthFailure extends AuthState {
  const AuthFailure({required this.error});
  final ErrorInterface error;
  @override
  List<Object?> get props => [error];
}
```

### AuthNotifier 구현

```dart
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._signup, this._logout, this._refresh, this._effects)
    : super(const AuthInitial());

  final SignupWithSocialUseCase _signup;
  final LogoutUseCase _logout;
  final RefreshTokenUseCase _refresh;
  final ErrorEffects _effects;

  Future<void> signupWithProvider(SocialProvider provider) async {
    state = const AuthLoading();
    try {
      final AuthToken? token = await _signup.execute(provider);
      if (token == null) {
        state = const AuthInitial();
        return;
      }
      state = const AuthSuccess();
    } catch (e) {
      final err = _toError(e);
      state = AuthFailure(error: err);
      _effects.report(err);
    }
  }

  Future<void> logout() async {
    state = const AuthLoading();
    try {
      await _logout.execute();
      state = const AuthInitial();
    } catch (e) {
      final err = _toError(e);
      state = AuthFailure(error: err);
      _effects.report(err);
    }
  }

  Future<void> refreshToken() async {
    state = const AuthLoading();
    try {
      final AuthenticationResult result = await _refresh.execute();
      if (!result.isAuthenticated()) {
        state = const AuthInitial();
        return;
      }
      state = const AuthSuccess();
    } catch (e) {
      final err = _toError(e);
      state = AuthFailure(error: err);
      _effects.report(err);
    }
  }

  ErrorInterface _toError(dynamic e) {
    if (e is ErrorInterface) {
      return e;
    } else {
      return UnknownUiError(message: e.toString());
    }
  }
}
```

## 상태 감지 방법

### 1. ref.watch - UI에서 상태 표시용

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AuthState 변화를 감지하고 UI 자동 리빌드
    final authState = ref.watch(authNotifierProvider);
    
    return switch (authState) {
      AuthLoading() => CircularProgressIndicator(),
      AuthSuccess() => Text('로그인 성공!'),
      AuthFailure(:final error) => Text('에러: ${error.message}'),
      AuthInitial() => Text('로그인이 필요합니다'),
    };
  }
}
```

### 2. ref.listen - 사이드 이펙트용

```dart
class MyPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyPage> createState() => _MyPageState();
}

class _MyPageState extends ConsumerState<MyPage> {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AuthState 변화를 감지하고 사이드 이펙트 실행
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      switch (next) {
        case AuthSuccess():
          // 로그인 성공 시 홈으로 이동
          Navigator.of(context).pushReplacementNamed('/home');
        case AuthFailure(:final error):
          // 로그인 실패 시 에러 다이얼로그 표시
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('로그인 실패'),
              content: Text(error.message),
            ),
          );
        case _:
          // AuthLoading, AuthInitial은 무시
          break;
      }
    });
    
    return YourWidget();
  }
}
```

### 3. ref.read - 일회성 읽기

```dart
// 현재 상태를 한 번만 읽기 (상태 변화 감지 안함)
final currentState = ref.read(authNotifierProvider);

// 액션 호출
ref.read(authNotifierProvider.notifier).signupWithProvider(provider);
```

## 상태 전파 구조

### 계층화된 상태 관리
AuthState (인증 액션 상태) → SessionState (앱 세션 상태) → UI 네비게이션

### app.dart에서의 중앙화된 처리

```dart
class TomoPlaceApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigatorKey = ref.watch(navigatorKeyProvider);
    
    // SessionState 변화에 따른 네비게이션 처리
    ref.listen<SessionState>(sessionStateProvider, (prev, next) {
      switch (next) {
        case Unauthenticated(:final reason):
          ref.read(navigationActionsProvider).showSnackBar(
              reason ?? '로그인 세션이 만료되었습니다');
          ref.read(navigationActionsProvider).navigateToSignup();
        case Authenticated():
          // ✅ 로그인 성공 시 홈으로 이동
          ref.read(navigationActionsProvider).navigateToHome();
      }
    });

    // ✅ AuthState 변화는 SessionState로 변환 (필수!)
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      switch (next) {
        case AuthSuccess():
          ref.read(sessionStateProvider.notifier).markAuthenticated();
        case AuthFailure():
          ref.read(sessionStateProvider.notifier).markUnauthenticated('인증에 실패했습니다');
        case _:
          // AuthInitial, AuthLoading은 무시
          break;
      }
    });

    return MaterialApp(
      // ... 앱 설정
    );
  }
}
```

**중요**: `AuthState` → `SessionState` 변환 로직이 없으면 인증 성공 후 네비게이션이 작동하지 않습니다.

## 실제 사용 예시

### 로그인 페이지

```dart
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    
    return Scaffold(
      body: Column(
        children: [
          // 상태에 따른 UI 표시
          switch (authState) {
            AuthLoading() => CircularProgressIndicator(),
            AuthFailure(:final error) => Text(
              '로그인 실패: ${error.message}',
              style: TextStyle(color: Colors.red),
            ),
            _ => SizedBox.shrink(),
          },
          
          // 로그인 버튼
          ElevatedButton(
            onPressed: authState is AuthLoading 
              ? null  // 로딩 중일 때는 비활성화
              : () => ref.read(authNotifierProvider.notifier)
                  .signupWithProvider(SocialProvider.google),
            child: Text('구글 로그인'),
          ),
        ],
      ),
    );
  }
}
```

### 스플래시 페이지
```dart
class SplashPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
  }

  Future<void> _checkAuthenticationStatus() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      // ✅ AuthNotifier를 통한 일관된 호출
      await ref.read(authNotifierProvider.notifier).refreshToken();
    } catch (e) {
      if (!mounted) return;
      GracefulLogoutHandler.handleAuthError(e.toString(), ref: ref);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ AuthState 변화 감지
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      switch (next) {
        case AuthSuccess():
          ref.read(sessionStateProvider.notifier).markAuthenticated();
        case AuthFailure():
          ref.read(sessionStateProvider.notifier).markUnauthenticated('로그인이 필요합니다');
        case _:
          // AuthInitial, AuthLoading은 무시
          break;
      }
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
```

## 주의사항

### 1. ref.listen 사용 위치

```dart
// ✅ 올바른 방법 - build 메서드 내에서만 사용
@override
Widget build(BuildContext context, WidgetRef ref) {
  ref.listen<AuthState>(authNotifierProvider, (prev, next) {
    // 사이드 이펙트
  });
  return YourWidget();
}

// ❌ 잘못된 방법 - didChangeDependencies에서 사용
@override
void didChangeDependencies() {
  ref.listen<AuthState>(authNotifierProvider, (prev, next) {
    // 오류 발생!
  });
}
```

### 2. 순환 의존성 방지

```dart
// ✅ 순환 의존성 방지
final authDomainAdapterProvider = Provider<AuthDomainPort>((ref) {
  // 직접 UseCase를 생성하여 순환 의존성 방지
  final authRepository = ref.read(authRepositoryProvider);
  final authTokenRepository = ref.read(authTokenRepositoryProvider);
  final startupRefreshTokenUseCase = RefreshTokenUseCase(
    authRepository,
    authTokenRepository,
  );

  return AuthDomainAdapter(
    startupRefreshTokenUseCase,
    ref.read(sessionStateProvider.notifier),
  );
});
```

## 베스트 프랙티스

### 1. 상태별 UI 표시는 ref.watch 사용
### 2. 네비게이션, 다이얼로그 등 사이드 이펙트는 ref.listen 사용
### 3. 액션 호출은 ref.read 사용
### 4. 모든 인증 액션은 AuthNotifier를 통해 수행
### 5. 상태와 데이터는 명확히 분리
### 6. 네비게이션 로직은 app.dart에서 중앙화

## 테스트 예시

### AuthNotifier 테스트

```dart
test('should emit AuthSuccess when authentication succeeds', () {
  // Given
  when(mockUseCase.execute()).thenAnswer((_) async => successResult);
  
  // When
  notifier.refreshToken();
  
  // Then
  expect(notifier.state, isA<AuthSuccess>());
});

test('should emit AuthFailure when authentication fails', () {
  // Given
  when(mockUseCase.execute()).thenThrow(Exception('Network error'));
  
  // When
  notifier.refreshToken();
  
  // Then
  expect(notifier.state, isA<AuthFailure>());
});
```

## 결론

이 패턴을 따르면:

1. **일관성**: 모든 인증 액션이 동일한 방식으로 처리됩니다
2. **예측 가능성**: 상태 변화가 명확하게 추적됩니다
3. **유지보수성**: 각 컴포넌트의 책임이 명확합니다
4. **테스트 용이성**: 각 컴포넌트를 독립적으로 테스트할 수 있습니다
5. **확장성**: 새로운 인증 방식 추가가 용이합니다

이 문서를 참고하여 일관된 인증 상태 관리를 구현하시기 바랍니다.



## 추가 고려사항

### 1. **스플래시 페이지 수정**

현재 `splash_page.dart`에서 `AuthState` → `SessionState` 변환을 하고 있다면, `app.dart`로 이동해야 합니다:

```dart
// ❌ splash_page.dart에서 중복 처리
ref.listen<AuthState>(authNotifierProvider, (prev, next) {
  switch (next) {
    case AuthSuccess():
      ref.read(sessionStateProvider.notifier).markAuthenticated();
    // ...
  }
});

// ✅ app.dart에서 중앙화된 처리
```

### 2. **signup_page.dart 간소화**

`app.dart`에서 네비게이션을 처리하므로 `signup_page.dart`에서 직접 네비게이션을 제거해야 합니다:

```dart
// ❌ signup_page.dart에서 직접 네비게이션
ref.listen<AuthState>(authNotifierProvider, (prev, next) {
  if (next is AuthSuccess) {
    Navigator.of(context).pushReplacementNamed('/home');
  }
});

// ✅ app.dart에서 중앙화된 네비게이션 처리
```
