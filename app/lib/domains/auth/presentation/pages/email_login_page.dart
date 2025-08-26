import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controllers/auth_controller.dart';
import '../../../../shared/design_system/tokens/colors.dart';
import '../../../../shared/design_system/tokens/spacing.dart';
import '../../../../shared/design_system/tokens/typography.dart';
import '../../../../shared/design_system/atoms/buttons/button_variants.dart';

/// 이메일 로그인 화면
/// 
/// 이메일과 비밀번호를 입력받아 로그인하는 페이지입니다.
/// 추후 완전히 구현될 예정이며, 현재는 기본 구조만 제공합니다.
class EmailLoginPage extends StatefulWidget {
  const EmailLoginPage({super.key});

  @override
  State<EmailLoginPage> createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '이메일 로그인',
          style: AppTypography.h3.copyWith(
            color: DesignTokens.appColors['text_primary'],
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<AuthController, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: DesignTokens.appColors['error'],
                ),
              );
            }
          },
          builder: (context, state) {
            return _buildContent(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AuthState state) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 안내 텍스트
                  Text(
                    '이메일과 비밀번호를 입력해주세요',
                    style: AppTypography.bodyLarge.copyWith(
                      color: DesignTokens.appColors['text_secondary'],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  
                  // 이메일 입력 필드
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: '이메일',
                      hintText: 'example@email.com',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이메일을 입력해주세요';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return '올바른 이메일 형식을 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // 비밀번호 입력 필드
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '비밀번호',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 입력해주세요';
                      }
                      if (value.length < 6) {
                        return '비밀번호는 6자 이상이어야 합니다';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  
                  // 로그인 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ButtonVariants.primary(
                      onPressed: () => _handleLogin(context),
                      isLoading: state is AuthLoading,
                      child: Text(
                        '로그인',
                        style: AppTypography.buttonLarge,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 하단 링크들
            Column(
              children: [
                TextButton(
                  onPressed: () {
                    // TODO: 비밀번호 찾기 구현
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('비밀번호 찾기는 준비 중입니다.')),
                    );
                  },
                  child: Text(
                    '비밀번호를 잊으셨나요?',
                    style: AppTypography.bodyMedium.copyWith(
                      color: DesignTokens.appColors['text_secondary'],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '아직 계정이 없으신가요? ',
                      style: AppTypography.bodyMedium.copyWith(
                        color: DesignTokens.appColors['text_secondary'],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: 회원가입 페이지 구현
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('회원가입 페이지는 준비 중입니다.')),
                        );
                      },
                      child: Text(
                        '회원가입',
                        style: AppTypography.bodyMedium.copyWith(
                          color: DesignTokens.tomoPrimary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthController>().loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }
}
