import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/ui/design_system/tokens/colors.dart';
import '../../../../shared/ui/responsive/responsive_sizing.dart';
import '../../../../shared/ui/responsive/responsive_spacing.dart';
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
      backgroundColor: AppColors.background,
      body: SafeArea(child: _SignupPageContent(ref: ref)),
    );
  }
}

class _SignupPageContent extends StatelessWidget {
  const _SignupPageContent({required this.ref});

  final WidgetRef ref;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ResponsiveSizing.getResponsiveEdge(
        context,
        left: 24,
        top: 24,
        right: 24,
        bottom: 24,
      ),
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
          SizedBox(height: ResponsiveSpacing.getResponsive(context, 32)),
          SizedBox(height: ResponsiveSpacing.getResponsive(context, 24)),
        ],
      ),
    );
  }

  void _showTermsAgreementModal(SocialProvider provider) {
    showModalBottomSheet(
      context: ref.context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => TermsAgreementModal(
        onResult: (result) {
          Navigator.pop(context);

          switch (result) {
            case TermsAgreementResult.agreed:
              ref.read(authNotifierProvider.notifier).signupWithProvider(provider);
              break;
            case TermsAgreementResult.dismissed:
              break;
          }
        },
      ),
    );
  }
}
