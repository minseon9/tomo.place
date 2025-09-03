import 'package:get_it/get_it.dart';

import '../../shared/config/app_config.dart';
import 'domains/auth/auth_module.dart';
import 'shared/shared_module.dart';

class AppModule {
  static Future<void> register(GetIt sl) async {
    // Shared Module 등록
    SharedModule.register(sl);

    // Domain Modules 등록
    AuthModule.register(sl);

    // 앱 설정 초기화
    await AppConfig.initialize();
  }
}
