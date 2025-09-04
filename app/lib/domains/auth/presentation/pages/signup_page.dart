import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/ui/design_system/tokens/colors.dart';
import '../../../../shared/ui/design_system/tokens/spacing.dart';
import '../../consts/social_label_variant.dart';
import '../controllers/auth_notifier.dart';
import '../widgets/social_login_section.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  bool _isSignupMode = true;

  @override
  Widget build(BuildContext context) {
    // ✅ app.dart에서 중앙화된 네비게이션 처리하므로 직접 네비게이션 제거
    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: SafeArea(
        child: _SignupPageContent(
          isSignupMode: _isSignupMode,
          onToggleMode: () {
            setState(() {
              _isSignupMode = !_isSignupMode;
            });
          },
          ref: ref,
        ),
      ),
    );
  }
}

class _SignupPageContent extends StatelessWidget {
  const _SignupPageContent({
    required this.isSignupMode,
    required this.onToggleMode,
    required this.ref,
  });

  final bool isSignupMode;
  final VoidCallback onToggleMode;
  final WidgetRef ref;

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
                  onProviderPressed: (provider) => ref
                      .read(authNotifierProvider.notifier)
                      .signupWithProvider(provider),
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
