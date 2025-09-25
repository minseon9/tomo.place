import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tomo_place/shared/ui/design_system/tokens/typography.dart';
import 'package:tomo_place/shared/ui/design_system/tokens/colors.dart';

class PermissionSettingsModal {
  static void showSettingsModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (context) => Center(
        child: Container(
          width: 300,
          height: 190,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(64),
                blurRadius: 5,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // 상단 텍스트 영역 (150px)
              Container(
                height: 150,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '위치 서비스 사용',
                      style: AppTypography.body.copyWith(
                        color: AppColors.tomoBlack,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppTypography.caption.copyWith(
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(
                            text: '위치서비스를 사용할 수 없습니다.\n',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.tomoBlack,
                            ),
                          ),
                          TextSpan(
                            text: '기기의 ',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.tomoBlack,
                            ),
                          ),
                          TextSpan(
                            text: '설정 > 개인 정보 보호',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.bluePrimary,
                            ),
                          ),
                          TextSpan(
                            text: '에서 위치 접근을 허용해주세요.',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.tomoBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 하단 버튼 영역 (40px)
              Container(
                height: 40,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.tomoBlack, width: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        child: Text(
                          '취소',
                          style: AppTypography.button.copyWith(
                            color: AppColors.tomoBlack,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 0.2,
                      color: AppColors.tomoBlack,
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          AppSettings.openAppSettings();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        child: Text(
                          '설정으로 이동',
                          style: AppTypography.button.copyWith(
                            color: AppColors.bluePrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final permissionSettingModalProvider = Provider<PermissionSettingsModal>((ref) {
  return PermissionSettingsModal();
});

