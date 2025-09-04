# Execution Plan

## Requested Task

- Riverpod으로 전역 컨텍스트/내비게이션 및 상태관리 마이그레이션
- 인프라 레이어(`app/lib/shared/infrastructure/network/auth_interceptor.dart`)의 네비게이션/스낵바 직접 호출 제거 → 상태/이벤트 표출로 개선
- 예외 처리(다이얼로그/스낵바) 글로벌 핸들러 도입으로 일원화

## Identified Context

- 상태관리: 현재 `flutter_bloc` + `Cubit` 사용. Riverpod 미도입
- DI: `GetIt` 기반 모듈(`app/lib/app/di/*`)
- 내비게이션: `MaterialApp` + `onGenerateRoute`, 전역 키는 `NavigationService.navigatorKey`
- `GlobalContext` 유틸은 있으나 실사용은 `NavigationService`
- 인증 흐름: `AuthInterceptor`가 토큰 검사/리프레시 실패 시 네비게이션 및 스낵바를 직접 실행
- 선호 정책: 인프라/도메인에서 UI를 모르는 상태/이벤트만 표출, UI 루트에서 라우팅/알림 처리

## Execution Plan

1) Riverpod 도입 및 전역 내비게이션 Provider화 [Done]

- 의존성 추가: `flutter_riverpod`
    - `pubspec.yaml`
      ```yaml
      dependencies:
        flutter_riverpod: ^2.5.1
      ```
- `main.dart`에서 `ProviderScope` 래핑
    - 파일: `app/lib/main.dart`
      ```dart
      import 'package:flutter_riverpod/flutter_riverpod.dart';
      
      void main() async {
        WidgetsFlutterBinding.ensureInitialized();
        await di.initializeDependencies();
        runApp(const ProviderScope(child: TomoPlaceApp()));
      }
      ```
- 전역 `navigatorKeyProvider` 및 액션 Provider 추가
    - 새 파일: `app/lib/shared/navigation/navigation_providers.dart`
      ```dart
      import 'package:flutter/material.dart';
      import 'package:flutter_riverpod/flutter_riverpod.dart';
  
      final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
        (ref) => GlobalKey<NavigatorState>(),
      );
  
      class NavigationActions {
        NavigationActions(this._key);
        final GlobalKey<NavigatorState> _key;
  
        void navigateToSignup() {
          _key.currentState?.pushNamedAndRemoveUntil('/signup', (route) => false);
        }
  
        void navigateToHome() {
          _key.currentState?.pushNamedAndRemoveUntil('/home', (route) => false);
        }
  
        void showSnackBar(String message) {
          final ctx = _key.currentContext;
          if (ctx != null) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
            );
          }
        }
      }
  
      final navigationActionsProvider = Provider<NavigationActions>(
        (ref) => NavigationActions(ref.watch(navigatorKeyProvider)),
      );
      ```
- `TomoPlaceApp`을 `ConsumerWidget`으로 변경하고 `MaterialApp.navigatorKey`를 Provider로 교체
    - 파일: `app/lib/app/app.dart`
      ```dart
      import 'package:flutter_riverpod/flutter_riverpod.dart';
      import '../shared/navigation/navigation_providers.dart';
  
      class TomoPlaceApp extends ConsumerWidget {
        const TomoPlaceApp({super.key});
  
        @override
        Widget build(BuildContext context, WidgetRef ref) {
          final navigatorKey = ref.watch(navigatorKeyProvider);
          // 임시 브릿지: 기존 NavigationService와 키 동기화(점진 교체)
          NavigationService.navigatorKey = navigatorKey;
  
          return MultiBlocProvider(
            providers: [BlocProvider<AuthController>(create: (_) => di.sl<AuthController>())],
            child: MaterialApp(
              navigatorKey: navigatorKey,
              onGenerateRoute: AppRouter.generateRoute,
              initialRoute: '/splash',
            ),
          );
        }
      }
      ```
- `GlobalContext`는 Deprecated 처리 후 제거(후속 단계)

2) AuthInterceptor에서 네비게이션 제거, 상태 표출로 개선 [Done]

- 단기: EventBus 스타일의 `SessionEventBus` 도입(변경 최소화)
    - 새 파일: `app/lib/shared/services/session_event_bus.dart`
      ```dart
      import 'dart:async';
  
      enum SessionEvent { expired, signedOut }
  
      class SessionEventBus {
        final StreamController<SessionEvent> _controller = StreamController.broadcast();
        Stream<SessionEvent> get stream => _controller.stream;
        void publish(SessionEvent event) => _controller.add(event);
        void dispose() => _controller.close();
      }
      ```
    - DI 등록: `app/lib/app/di/shared/shared_module.dart`
      ```dart
      sl.registerLazySingleton<SessionEventBus>(() => SessionEventBus());
      ```
    - `AuthInterceptor` 수정: 네비/스낵바 제거 → 이벤트 발행 + 401 reject
        - 파일: `app/lib/shared/infrastructure/network/auth_interceptor.dart`
      ```dart
      import 'package:dio/dio.dart';
      import '../../services/session_event_bus.dart';
      // ... 생략(import 정리)
  
      class AuthInterceptor extends Interceptor {
        AuthInterceptor(this._memoryStore, this._refreshUseCase, this._eventBus);
        final AccessTokenMemoryStore _memoryStore;
        final StartupRefreshTokenUseCase _refreshUseCase;
        final SessionEventBus _eventBus;
  
        @override
        Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
          final result = await _refreshUseCase.execute();
          if (!result.isAuthenticated()) {
            _eventBus.publish(SessionEvent.expired);
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                response: Response(requestOptions: options, statusCode: 401, data: {'message': result.message}),
              ),
              true,
            );
            return;
          }
          final token = _memoryStore.token;
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        }
      }
      ```
    - 루트에서 이벤트 구독 → 라우팅/스낵바 실행
        - 파일: `app/lib/app/app.dart`
      ```dart
      final eventBus = di.sl<SessionEventBus>();
  
      return StreamBuilder<SessionEvent>(
        stream: eventBus.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            switch (snapshot.data!) {
              case SessionEvent.expired:
                ref.read(navigationActionsProvider).showSnackBar('로그인 세션이 만료되었습니다');
                ref.read(navigationActionsProvider).navigateToSignup();
                break;
              case SessionEvent.signedOut:
                ref.read(navigationActionsProvider).navigateToSignup();
                break;
            }
          }
          return MaterialApp(
            navigatorKey: ref.watch(navigatorKeyProvider),
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: '/splash',
          );
        },
      );
      ```
- 중기: Riverpod `SessionGateway`/`sessionStateProvider`로 이관(EventBus 제거)
    - 계약: `app/lib/domains/auth/core/ports/session_gateway.dart`
      ```dart
      abstract class SessionGateway {
        void markUnauthenticated(String? reason);
        void markAuthenticated();
      }
      ```
    - 구현: `app/lib/shared/session/session_notifier.dart`
      ```dart
      import 'package:flutter_riverpod/flutter_riverpod.dart';
  
      sealed class SessionState { const SessionState(); }
      class Authenticated extends SessionState { const Authenticated(); }
      class Unauthenticated extends SessionState { final String? reason; const Unauthenticated(this.reason); }
  
      class SessionNotifier extends StateNotifier<SessionState> implements SessionGateway {
        SessionNotifier() : super(const Unauthenticated(null));
        @override
        void markUnauthenticated(String? reason) { state = Unauthenticated(reason); }
        @override
        void markAuthenticated() { state = const Authenticated(); }
      }
  
      final sessionStateProvider = StateNotifierProvider<SessionNotifier, SessionState>(
        (ref) => SessionNotifier(),
      );
      ```
    - Interceptor는 `SessionGateway`에만 의존
      ```dart
      class AuthInterceptor extends Interceptor {
        AuthInterceptor(this._memoryStore, this._refreshUseCase, this._sessionGateway);
        final AccessTokenMemoryStore _memoryStore;
        final StartupRefreshTokenUseCase _refreshUseCase;
        final SessionGateway _sessionGateway;
        @override
        Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
          final result = await _refreshUseCase.execute();
          if (!result.isAuthenticated()) {
            _sessionGateway.markUnauthenticated(result.message);
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                response: Response(requestOptions: options, statusCode: 401, data: {'message': result.message}),
              ),
              true,
            );
            return;
          }
          final token = _memoryStore.token;
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        }
      }
      ```
    - 루트 리스너: `ref.listen(sessionStateProvider, ...)`로 라우팅/알림 처리

3) 예외 처리 글로벌 핸들러 도입 [Done]

- 단기: 전역 `ErrorReporter`(Stream) 도입 및 루트 구독 → 페이지 직접 다이얼로그 호출 제거
    - 새 파일: `app/lib/shared/services/error_reporter.dart`
      ```dart
      import 'dart:async';
      import '../exceptions/exception_interface.dart';
  
      class ErrorReporter {
        final StreamController<ErrorInterface> _controller = StreamController.broadcast();
        Stream<ErrorInterface> get stream => _controller.stream;
        void report(ErrorInterface error) => _controller.add(error);
        void dispose() => _controller.close();
      }
      ```
    - DI 등록: `app/lib/app/di/shared/shared_module.dart`
      ```dart
      sl.registerLazySingleton<ErrorReporter>(() => ErrorReporter());
      ```
    - 루트 구독: `TomoPlaceApp`에서 다이얼로그/스낵바 표준화
      ```dart
      final errorReporter = di.sl<ErrorReporter>();
      return StreamBuilder<ErrorInterface>(
        stream: errorReporter.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            ErrorDialog.show(context: context, error: snapshot.data!);
          }
          return MaterialApp(
            navigatorKey: ref.watch(navigatorKeyProvider),
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: '/splash',
          );
        },
      );
      ```
    - 페이지 수정: `SignupPage`에서 직접 `ErrorDialog.show` 제거
        - 파일: `app/lib/domains/auth/presentation/pages/signup_page.dart`
      ```dart
      void _handleStateChange(BuildContext context, AuthState state) {
        if (state is AuthSuccess) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
        // AuthFailure는 컨트롤러가 ErrorReporter.report 호출 → 루트에서 다이얼로그 처리
      }
      ```
    - 컨트롤러에서 실패 시 보고(예)
      ```dart
      _errorReporter.report(state.error); // ErrorInterface
      ```
- 중기: Riverpod `errorEffectsProvider`로 이관, 루트 ProviderListener로 일원화
    - 새 파일: `app/lib/shared/errors/error_effects_provider.dart`
      ```dart
      import 'package:flutter_riverpod/flutter_riverpod.dart';
      import '../exceptions/exception_interface.dart';
  
      final errorEffectsProvider = StateNotifierProvider<ErrorEffects, ErrorInterface?>(
        (ref) => ErrorEffects(),
      );
  
      class ErrorEffects extends StateNotifier<ErrorInterface?> {
        ErrorEffects() : super(null);
        void report(ErrorInterface error) => state = error;
        void clear() => state = null;
      }
      ```
    - 루트 리스닝
      ```dart
      ref.listen<ErrorInterface?>(errorEffectsProvider, (prev, next) {
        if (next != null) {
          ErrorDialog.show(context: context, error: next);
          ref.read(errorEffectsProvider.notifier).clear();
        }
      });
      ```

4) 점진 전환 및 정리 [Pending]

- `NavigationService` 사용처를 `navigationActionsProvider`로 교체 후 제거
- `GlobalContext` 제거
- `AuthController`(Cubit) → Riverpod `StateNotifier` 전환(후속 작업)
- GetIt 등록 항목 중 Riverpod로 이관 가능한 항목 단계적 이동

5) 검증 및 품질 [Pending]

- 스모크 테스트: 세션 만료/401, 로그인 성공/실패 플로우, 네트워크 오류
- 다이얼로그/스낵바 중복 방지(이벤트 디바운스) 확인
- 비정상 시 롤백/핫픽스 루틴 준비

## Progress Status

1. 계획 문서 작성 및 저장 [Done]
2. Riverpod 의존성 추가 및 ProviderScope 적용 [Done]
3. navigatorKey Provider/Actions 도입 및 `MaterialApp` 연결 [Done]
4. AuthInterceptor 이벤트화(단기) 및 루트 리스닝 적용 [Done]
5. 예외 전역 핸들러 도입 및 페이지 직접 호출 제거 [Done]
6. 중기: SessionGateway/Provider 및 ErrorEffects Provider 이관 [Pending]
7. 점진 전환(서비스 제거/리팩토링) [In Progress]
8. 스모크 테스트 및 QA [Pending]

## Suggested Next Tasks

- 의존성 추가와 ProviderScope 적용부터 착수 → 내비게이션 Provider 연결
- 단기 EventBus로 Interceptor 디커플링 → 401 플로우 검증
- 전역 ErrorReporter 도입 → 페이지 직접 다이얼로그 호출 제거
- 이후 중기 목표로 Riverpod Provider들(Session/Errors)로 일원화하고 GetIt 등록 일부 이관
