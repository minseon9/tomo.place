import 'package:flutter/material.dart';
import '../../../../../shared/ui/responsive/responsive_sizing.dart';
import '../atoms/bottom_navigation_tab.dart';


class BottomNavigationBar extends StatelessWidget {
  final int? currentIndex;

  const BottomNavigationBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ResponsiveSizing.getValueByDevice(
        context,
        mobile: 88.0,
        tablet: 96.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          // Top shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            offset: const Offset(0, -1),
            blurRadius: ResponsiveSizing.getValueByDevice(
              context,
              mobile: 4.0,
              tablet: 5.0,
            ),
            spreadRadius: 0,
          ),
          // Bottom shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            offset: const Offset(0, 4),
            blurRadius: ResponsiveSizing.getValueByDevice(
              context,
              mobile: 4.0,
              tablet: 5.0,
            ),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: BottomNavigationTab(
              iconPath: 'assets/icons/location_share_icon.svg',
              label: '위치 공유',
              isSelected: currentIndex == 0,
              onTap: () => _handleLocationShareTap(context),
            ),
          ),
          Expanded(
            child: BottomNavigationTab(
              iconPath: 'assets/icons/place_folder_icon.svg',
              label: '모음집',
              isSelected: currentIndex == 1,
              onTap: () => _handlePlaceFolderTap(context),
            ),
          ),
          Expanded(
            child: BottomNavigationTab(
              iconPath: 'assets/icons/my_icon.svg',
              label: '마이',
              isSelected: currentIndex == 2,
              onTap: () => _handleMyTap(context),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLocationShareTap(BuildContext context) {
    // TODO: 위치 공유 모달 또는 페이지 이동 구현
    print('위치 공유 탭 클릭');
  }

  void _handlePlaceFolderTap(BuildContext context) {
    // TODO: 모음집 모달 또는 페이지 이동 구현
    print('모음집 탭 클릭');
  }

  void _handleMyTap(BuildContext context) {
    // TODO: 마이 모달 또는 페이지 이동 구현
    print('마이 탭 클릭');
  }
}
