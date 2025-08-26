import 'package:flutter/material.dart';
import '../atoms/buttons/button_variants.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// 소셜 로그인용 버튼 컴포넌트
/// 
/// 아이콘과 텍스트를 조합한 소셜 로그인 전용 버튼입니다.
/// 여전히 순수 UI 컴포넌트로서 비즈니스 로직에 의존하지 않습니다.
class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
    this.labelVariant = SocialLabelVariant.signup,
  });

  final SocialProvider provider;
  final VoidCallback? onPressed;
  final bool isLoading;
  final SocialLabelVariant labelVariant;

  @override
  Widget build(BuildContext context) {
    final config = _getProviderConfig(provider, labelVariant);
    
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.buttonGap,
      ),
      child: config.buttonBuilder(
        onPressed: onPressed,
        isLoading: isLoading,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            config.icon,
            const SizedBox(width: 8),
            Text(
              config.text,
              style: AppTypography.buttonMedium,
            ),
          ],
        ),
      ),
    );
  }

  _SocialButtonConfig _getProviderConfig(SocialProvider provider, SocialLabelVariant variant) {
    switch (provider) {
      case SocialProvider.kakao:
        return _SocialButtonConfig(
          text: variant == SocialLabelVariant.login ? '카카오 로그인' : '카카오로 시작하기',
          icon: _buildIcon('💬', Colors.black),
          buttonBuilder: ButtonVariants.kakao,
        );
      case SocialProvider.apple:
        return _SocialButtonConfig(
          text: variant == SocialLabelVariant.login ? '애플 로그인' : '애플로 시작하기',
          icon: _buildIcon('🍎', Colors.black),
          buttonBuilder: ButtonVariants.outlined,
        );
      case SocialProvider.google:
        return _SocialButtonConfig(
          text: variant == SocialLabelVariant.login ? '구글 로그인' : '구글로 시작하기',
          icon: _buildIcon('G', Colors.black),
          buttonBuilder: ButtonVariants.outlined,
        );
      case SocialProvider.email:
        return _SocialButtonConfig(
          text: variant == SocialLabelVariant.login ? '이메일로 로그인' : '이메일로 시작하기',
          icon: const Icon(Icons.email, size: 20, color: Colors.black),
          buttonBuilder: ButtonVariants.outlined,
        );
    }
  }

  Widget _buildIcon(String emoji, Color color) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      child: Text(
        emoji,
        style: TextStyle(
          fontSize: 16,
          color: color,
        ),
      ),
    );
  }
}

/// 소셜 로그인 제공자 열거형
enum SocialProvider { 
  kakao, 
  apple, 
  google, 
  email,
}

/// 버튼 라벨 변형 (로그인/시작하기)
enum SocialLabelVariant { login, signup }

/// 소셜 버튼 설정을 위한 내부 클래스
class _SocialButtonConfig {
  final String text;
  final Widget icon;
  final Widget Function({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading,
    double? width,
  }) buttonBuilder;

  _SocialButtonConfig({
    required this.text,
    required this.icon,
    required this.buttonBuilder,
  });
}
