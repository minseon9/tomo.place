import 'package:go_router/go_router.dart';
import '../pages/login_page.dart';
import '../pages/signup_page.dart';
import '../pages/email_login_page.dart';
import '../../consts/routes.dart';

/// Auth 도메인 라우트 정의
final List<GoRoute> authRoutes = [
  GoRoute(
    path: AuthRoutes.login,
    builder: (context, state) => const LoginPage(),
  ),
  GoRoute(
    path: AuthRoutes.signup,
    builder: (context, state) => const SignupPage(),
  ),
  GoRoute(
    path: AuthRoutes.emailLogin,
    builder: (context, state) => const EmailLoginPage(),
  ),
];
