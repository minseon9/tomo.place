import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/design_system/tokens/colors.dart';
import '../../../../shared/design_system/tokens/spacing.dart';
import '../../../../shared/widgets/error_dialog.dart';
import '../../consts/social_label_variant.dart';
import '../controllers/auth_controller.dart';
import '../models/auth_state.dart';
import '../widgets/social_login_section.dart';

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

  void _handleStateChange(BuildContext context, AuthState state) {
    if (state is AuthSuccess) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (state is AuthFailure) {
      ErrorDialog.show(
        context: context,
        error: state.error,
        onDismiss: () => context.read<AuthController>().clearError(),
      );
    }
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
                  onProviderPressed: (provider) => context
                      .read<AuthController>()
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
