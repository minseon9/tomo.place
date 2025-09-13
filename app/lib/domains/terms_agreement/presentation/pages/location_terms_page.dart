import 'package:flutter/material.dart';

import '../widgets/organisms/terms_page_layout.dart';

class LocationTermsPage extends StatelessWidget {
  const LocationTermsPage({super.key});

  static const Map<String, String> _locationContents = {
    "수집·이용 목적":
        "• 사용자 위치 기반 서비스 제공 (주변 장소 추천, 지도 표시, 후기 작성 시 위치 태그)\n• 타인과 위치 공유 기능 제공 (회원이 명시적으로 설정한 경우에 한함)",
    "수집 항목": "• 단말기 위치정보(GPS, 기지국, Wi-Fi 등)",
    "제3자 제공":
        "1. 구글 지도 API 제공사: 지도 및 위치 기반 서비스 제공을 위해 위치정보가 구글 지도 API에 제공될 수 있습니다.\n2. 다른 회원: 회원이 위치공유 기능을 활성화하거나 특정 콘텐츠(후기, 사진 등)를 등록한 경우, 해당 위치정보는 다른 회원에게 공개될 수 있습니다.",
    "보유·이용 기간":
        "• 위치정보는 서비스 이용 목적 달성 후 즉시 파기\n• 단, 분쟁 해결 및 법적 대응을 위해 필요한 경우 n개월간 보관 가능",
    "동의 거부 권리 및 불이익":
        "• 이용자는 위치정보 수집·이용에 대한 동의를 거부할 수 있습니다.\n• 다만, 위치 기반 기능(지도, 위치 공유 등) 이용이 제한될 수 있습니다.",
  };

  @override
  Widget build(BuildContext context) {
    return TermsPageLayout(
      title: '위치 정보 수집·이용 및 제3자 제공 동의',
      contentMap: _locationContents,
      onAgree: () => Navigator.of(context).pop(),
    );
  }
}
