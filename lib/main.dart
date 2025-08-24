import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/base/app_config.dart';
import 'core/cache/cache_manager.dart';
import 'core/database/database_manager.dart';
import 'core/network/network_manager.dart';
import 'core/permissions/permission_manager.dart';
import 'core/storage/storage_manager.dart';
import 'core/theme/theme_manager.dart';
import 'core/localization/localization_manager.dart';
import 'core/router/router_manager.dart';
import 'core/screen/screen_adapter.dart';
import 'core/widgets/loading_dialog.dart';
import 'core/utils/logger_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化Hive
  await Hive.initFlutter();
  
  // 初始化核心服务
  await _initCoreServices();
  
  // 设置系统UI样式
  _setSystemUIStyle();
  
  runApp(const MyApp());
}

/// 初始化核心服务
Future<void> _initCoreServices() async {
  try {
    // 初始化日志工具
    LoggerUtil.init();
    
    // 初始化存储管理器
    await StorageManager.instance.init();
    
    // 初始化缓存管理器
    await CacheManager.instance.init();
    
    // 初始化数据库管理器
    await DatabaseManager.instance.init();
    
    // 初始化网络管理器
    await NetworkManager.instance.init();
    
    // 初始化权限管理器
    await PermissionManager.instance.init();
    
    // 初始化路由管理器
    RouterManager.instance.init();
    
    // 初始化屏幕适配
    await ScreenAdapter.init();
    
    // 初始化加载弹窗
    LoadingDialog.init();
    
    LoggerUtil.i('核心服务初始化完成');
  } catch (e) {
    LoggerUtil.e('核心服务初始化失败: $e');
  }
}

/// 设置系统UI样式
void _setSystemUIStyle() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      navigationBarColor: Colors.white,
      navigationBarIconBrightness: Brightness.dark,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..init()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()..init()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return GetMaterialApp(
                title: AppConfig.appName,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeProvider.themeMode,
                locale: localeProvider.locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                initialRoute: AppRoutes.initialRoute,
                getPages: AppRoutes.pages,
                builder: EasyLoading.init(),
                unknownRoute: GetPage(
                  name: '/notfound',
                  page: () => const Scaffold(
                    body: Center(
                      child: Text('页面未找到'),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}