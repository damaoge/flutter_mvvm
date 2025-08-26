import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'service_locator.config.dart';

/// 全局服务定位器实例
final GetIt getIt = GetIt.instance;

/// 配置依赖注入
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() => getIt.init();

/// 重置依赖注入（主要用于测试）
void resetDependencies() {
  getIt.reset();
}

/// 注册测试依赖（用于单元测试）
void configureTestDependencies() {
  // 在测试中可以注册mock实现
  // 例如：getIt.registerLazySingleton<AuthService>(() => MockAuthService());
}