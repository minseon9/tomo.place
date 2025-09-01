import 'package:flutter/material.dart';

/// 전역 컨텍스트 관리 유틸리티
/// 
/// 앱 전체에서 사용할 수 있는 BuildContext를 관리합니다.
class GlobalContext {
  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  
  /// Navigator Key (MaterialApp에서 사용)
  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
  
  /// 전역 컨텍스트 가져오기
  static BuildContext get context {
    final context = _navigatorKey.currentContext;
    if (context == null) {
      throw Exception('전역 컨텍스트가 초기화되지 않았습니다.');
    }
    return context;
  }
  
  /// Navigator 가져오기
  static NavigatorState get navigator {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) {
      throw Exception('Navigator가 초기화되지 않았습니다.');
    }
    return navigator;
  }
}
