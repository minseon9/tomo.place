import 'package:get_it/get_it.dart';
import 'app_module.dart';

final GetIt sl = GetIt.instance;

Future<void> initializeDependencies() async {
  await AppModule.register(sl);
}
