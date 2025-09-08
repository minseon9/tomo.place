import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/application/routes/routes.dart';
import '../../../../shared/ui/design_system/tokens/colors.dart';
import '../../../../shared/ui/design_system/tokens/spacing.dart';
import '../../../terms_agreement/presentation/widgets/organisms/terms_agreement_modal.dart';
import '../../consts/social_provider.dart';
import '../controllers/auth_notifier.dart';
import '../widgets/social_login_section.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: SafeArea(child: _SignupPageContent(ref: ref)),
    );
  }
}

class _SignupPageContent extends StatelessWidget {
  const _SignupPageContent({required this.ref});

  final WidgetRef ref;

  void _showTermsAgreementModal(SocialProvider provider) {
    showModalBottomSheet(
      context: ref.context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => TermsAgreementModal(
        onAgreeAll: () {
          Navigator.pop(context);
          ref.read(authNotifierProvider.notifier).signupWithProvider(provider);
        },
        onTermsTap: () {
          Navigator.pushNamed(context, Routes.termsOfService);
        },
        onPrivacyTap: () {
          Navigator.pushNamed(context, Routes.privacyPolicy);
        },
        onLocationTap: () {
          Navigator.pushNamed(context, Routes.locationTerms);
        },
        onDismiss: () {
          Navigator.pop(context);
        },
      ),
    );
  }

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
                  onProviderPressed: (provider) =>
                      _showTermsAgreementModal(provider),
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
