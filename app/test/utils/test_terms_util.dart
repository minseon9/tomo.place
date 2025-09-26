import 'package:flutter/material.dart';
import 'package:tomo_place/domains/terms_agreement/presentation/widgets/organisms/terms_agreement_modal.dart';

class TermsTestUtil {
  TermsTestUtil._();

  static Widget buildModal({
    required void Function(TermsAgreementResult) onResult,
    Size screenSize = const Size(390.0, 844.0),
  }) {
    return MaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(size: screenSize),
          child: TermsAgreementModal(onResult: onResult),
        ),
      ),
    );
  }

  static const String termsTitle = '이용 약관 동의';
  static const String privacyTitle = '개인정보 보호 방침 동의';
  static const String locationTitle = '위치정보 수집·이용 및 제3자 제공 동의';
  static const String ageTitle = '만 14세 이상입니다';
  static const String agreeAllButton = '모두 동의합니다 !';

  static Finder findTermsTitle() => find.text(termsTitle);
  static Finder findPrivacyTitle() => find.text(privacyTitle);
  static Finder findLocationTitle() => find.text(locationTitle);
  static Finder findAgeTitle() => find.text(ageTitle);
  static Finder findAgreeAllButton() => find.text(agreeAllButton);
}
