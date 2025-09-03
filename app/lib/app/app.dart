import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'di/injection_container.dart' as di;
import 'router/app_router.dart';
import '../shared/design_system/tokens/colors.dart';
import 'services/navigation_service.dart';
import '../shared/navigation/navigation_providers.dart';
import '../shared/services/session_event_bus.dart';
import '../shared/services/error_reporter.dart';
import '../shared/exceptions/error_interface.dart';
import '../domains/auth/presentation/controllers/auth_controller.dart';


class TomoPlaceApp extends ConsumerWidget {
  const TomoPlaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigatorKey = ref.watch(navigatorKeyProvider);
    // 임시 브릿지: 기존 NavigationService와 키 동기화(점진 교체)
    NavigationService.navigatorKey = navigatorKey;
    final sessionBus = di.sl<SessionEventBus>();

    final errorReporter = di.sl<ErrorReporter>();

    return StreamBuilder<SessionEvent>(
      stream: sessionBus.stream,
      builder: (context, sessionSnapshot) {
        if (sessionSnapshot.hasData) {
          switch (sessionSnapshot.data!) {
            case SessionEvent.expired:
              ref.read(navigationActionsProvider).showSnackBar('로그인 세션이 만료되었습니다');
              ref.read(navigationActionsProvider).navigateToSignup();
              break;
            case SessionEvent.signedOut:
              ref.read(navigationActionsProvider).navigateToSignup();
              break;
          }
        }

        return StreamBuilder<ErrorInterface>(
          stream: errorReporter.stream,
          builder: (context, errorSnapshot) {
            if (errorSnapshot.hasData) {
              // 전역 에러 다이얼로그/스낵바 처리: 기본 다이얼로그로 처리 예시
              // ErrorDialog는 context 필요 → navigatorKey currentContext 사용 권장
              final ctx = navigatorKey.currentContext;
              if (ctx != null) {
                // 기본 스낵바 처리. 필요 시 ErrorDialog.show로 변경 가능
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text(errorSnapshot.data!.userMessage)),
                );
              }
            }

            return MultiBlocProvider(
              providers: [
                BlocProvider<AuthController>(
                  create: (context) => di.sl<AuthController>(),
                ),
              ],
              child: MaterialApp(
                title: 'Tomo Place',
                debugShowCheckedModeBanner: false,
                navigatorKey: navigatorKey,
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: DesignTokens.appColors['primary_200']!,
                  ),
                  useMaterial3: true,
                  scaffoldBackgroundColor: DesignTokens.appColors['background'],
                ),
                onGenerateRoute: AppRouter.generateRoute,
                initialRoute: '/splash',
              ),
            );
          },
        );
      },
    );
  }
}
