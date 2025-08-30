import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/design_system/tokens/colors.dart';
import '../../../../shared/design_system/tokens/spacing.dart';
import '../../consts/social_label_variant.dart';
import '../controllers/auth_controller.dart';
import '../widgets/social_login_section.dart';

/// 통합된 인증 화면
/// 
/// 로그인과 회원가입을 하나의 페이지에서 처리하는 통합된 인증 화면입니다.
/// OIDC 기반 소셜 로그인만 지원하며, 이메일 인증은 제거되었습니다.
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _isSignupMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: SafeArea(
        child: BlocConsumer<AuthController, AuthState>(
          listener: (context, state) {
            _handleStateChange(context, state);
          },
          builder: (context, state) {
            return _SignupPageContent(
              isSignupMode: _isSignupMode,
              onToggleMode: () {
                setState(() {
                  _isSignupMode = !_isSignupMode;
                });
              },
            );
          },
        ),
      ),
    );
  }

  /// 상태 변화에 따른 UI 처리
  void _handleStateChange(BuildContext context, AuthState state) {
    if (state is AuthSuccess) {
      // 인증 성공 시 홈 화면으로 이동
      // 토큰은 이미 AuthService에서 저장되었으므로 바로 이동
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (state is AuthFailure) {
      // 인증 실패 시 에러 메시지 표시
      _showErrorSnackBar(context, state.message);
    }
  }

  /// 에러 메시지 스낵바 표시
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: DesignTokens.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: '확인',
          textColor: Colors.white,
          onPressed: () => context.read<AuthController>().clearError(),
        ),
      ),
    );
  }
}

class _SignupPageContent extends StatelessWidget {
  const _SignupPageContent({
    required this.isSignupMode,
    required this.onToggleMode,
  });

  final bool isSignupMode;
  final VoidCallback onToggleMode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const Spacer(),
          Center(
            child: Column(
              children: [
                SocialLoginSection(
                  labelVariant: isSignupMode 
                      ? SocialLabelVariant.signup 
                      : SocialLabelVariant.login,
                  onProviderPressed: (provider) => 
                      context.read<AuthController>().signupWithProvider(provider),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}


