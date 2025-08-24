import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_mvvm/core/storage/storage_manager.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';

/// 多语言管理器
/// 提供应用的多语言支持功能
class LocalizationManager {
  static final LocalizationManager _instance = LocalizationManager._internal();
  static LocalizationManager get instance => _instance;
  
  static const String _localeKey = 'app_locale';
  
  Locale _currentLocale = const Locale('zh', 'CN');
  
  LocalizationManager._internal();
  
  /// 初始化多语言管理器
  Future<void> init() async {
    try {
      await _loadLocaleFromStorage();
      LoggerUtil.i('多语言管理器初始化完成，当前语言: $_currentLocale');
    } catch (e) {
      LoggerUtil.e('多语言管理器初始化失败: $e');
      _currentLocale = const Locale('zh', 'CN');
    }
  }
  
  /// 获取当前语言
  Locale get currentLocale => _currentLocale;
  
  /// 设置语言
  Future<void> setLocale(Locale locale) async {
    try {
      if (_isSupportedLocale(locale)) {
        _currentLocale = locale;
        await _saveLocaleToStorage();
        LoggerUtil.i('语言已切换为: $locale');
      } else {
        LoggerUtil.w('不支持的语言: $locale');
      }
    } catch (e) {
      LoggerUtil.e('设置语言失败: $e');
    }
  }
  
  /// 设置中文
  Future<void> setChineseLocale() async {
    await setLocale(const Locale('zh', 'CN'));
  }
  
  /// 设置英文
  Future<void> setEnglishLocale() async {
    await setLocale(const Locale('en', 'US'));
  }
  
  /// 设置日文
  Future<void> setJapaneseLocale() async {
    await setLocale(const Locale('ja', 'JP'));
  }
  
  /// 设置韩文
  Future<void> setKoreanLocale() async {
    await setLocale(const Locale('ko', 'KR'));
  }
  
  /// 获取支持的语言列表
  List<Locale> get supportedLocales => AppLocalizations.supportedLocales;
  
  /// 检查是否支持指定语言
  bool _isSupportedLocale(Locale locale) {
    return supportedLocales.any((supportedLocale) =>
        supportedLocale.languageCode == locale.languageCode &&
        supportedLocale.countryCode == locale.countryCode);
  }
  
  /// 从存储中加载语言设置
  Future<void> _loadLocaleFromStorage() async {
    try {
      final localeString = await StorageManager.instance.getString(_localeKey);
      if (localeString != null) {
        final parts = localeString.split('_');
        if (parts.length == 2) {
          final locale = Locale(parts[0], parts[1]);
          if (_isSupportedLocale(locale)) {
            _currentLocale = locale;
          }
        }
      }
    } catch (e) {
      LoggerUtil.e('从存储加载语言失败: $e');
    }
  }
  
  /// 保存语言设置到存储
  Future<void> _saveLocaleToStorage() async {
    try {
      final localeString = '${_currentLocale.languageCode}_${_currentLocale.countryCode}';
      await StorageManager.instance.setString(_localeKey, localeString);
    } catch (e) {
      LoggerUtil.e('保存语言到存储失败: $e');
    }
  }
}

/// 语言提供者
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('zh', 'CN');
  
  Locale get locale => _locale;
  
  /// 初始化语言提供者
  Future<void> init() async {
    await LocalizationManager.instance.init();
    _locale = LocalizationManager.instance.currentLocale;
    notifyListeners();
  }
  
  /// 设置语言
  Future<void> setLocale(Locale locale) async {
    await LocalizationManager.instance.setLocale(locale);
    _locale = locale;
    notifyListeners();
  }
}

/// 应用本地化配置
class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  /// 支持的语言列表
  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'), // 中文
    Locale('en', 'US'), // 英文
    Locale('ja', 'JP'), // 日文
    Locale('ko', 'KR'), // 韩文
  ];
  
  /// 获取本地化字符串
  String getString(String key) {
    return _localizedStrings[locale.languageCode]?[key] ?? key;
  }
  
  // 常用字符串的便捷方法
  String get appName => getString('app_name');
  String get loading => getString('loading');
  String get error => getString('error');
  String get success => getString('success');
  String get cancel => getString('cancel');
  String get confirm => getString('confirm');
  String get retry => getString('retry');
  String get networkError => getString('network_error');
  String get serverError => getString('server_error');
  String get unknownError => getString('unknown_error');
  String get noData => getString('no_data');
  String get loadMore => getString('load_more');
  String get refresh => getString('refresh');
  String get login => getString('login');
  String get logout => getString('logout');
  String get register => getString('register');
  String get username => getString('username');
  String get password => getString('password');
  String get email => getString('email');
  String get phone => getString('phone');
  String get settings => getString('settings');
  String get profile => getString('profile');
  String get about => getString('about');
  String get version => getString('version');
  String get theme => getString('theme');
  String get language => getString('language');
  String get lightTheme => getString('light_theme');
  String get darkTheme => getString('dark_theme');
  String get systemTheme => getString('system_theme');
  
  /// 本地化字符串映射
  static const Map<String, Map<String, String>> _localizedStrings = {
    'zh': {
      'app_name': 'Flutter MVVM',
      'loading': '加载中...',
      'error': '错误',
      'success': '成功',
      'cancel': '取消',
      'confirm': '确认',
      'retry': '重试',
      'network_error': '网络连接失败',
      'server_error': '服务器错误',
      'unknown_error': '未知错误',
      'no_data': '暂无数据',
      'load_more': '加载更多',
      'refresh': '刷新',
      'login': '登录',
      'logout': '退出登录',
      'register': '注册',
      'username': '用户名',
      'password': '密码',
      'email': '邮箱',
      'phone': '手机号',
      'settings': '设置',
      'profile': '个人资料',
      'about': '关于',
      'version': '版本',
      'theme': '主题',
      'language': '语言',
      'light_theme': '浅色主题',
      'dark_theme': '深色主题',
      'system_theme': '跟随系统',
    },
    'en': {
      'app_name': 'Flutter MVVM',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'retry': 'Retry',
      'network_error': 'Network connection failed',
      'server_error': 'Server error',
      'unknown_error': 'Unknown error',
      'no_data': 'No data',
      'load_more': 'Load more',
      'refresh': 'Refresh',
      'login': 'Login',
      'logout': 'Logout',
      'register': 'Register',
      'username': 'Username',
      'password': 'Password',
      'email': 'Email',
      'phone': 'Phone',
      'settings': 'Settings',
      'profile': 'Profile',
      'about': 'About',
      'version': 'Version',
      'theme': 'Theme',
      'language': 'Language',
      'light_theme': 'Light Theme',
      'dark_theme': 'Dark Theme',
      'system_theme': 'System Theme',
    },
    'ja': {
      'app_name': 'Flutter MVVM',
      'loading': '読み込み中...',
      'error': 'エラー',
      'success': '成功',
      'cancel': 'キャンセル',
      'confirm': '確認',
      'retry': '再試行',
      'network_error': 'ネットワーク接続に失敗しました',
      'server_error': 'サーバーエラー',
      'unknown_error': '不明なエラー',
      'no_data': 'データがありません',
      'load_more': 'もっと読み込む',
      'refresh': '更新',
      'login': 'ログイン',
      'logout': 'ログアウト',
      'register': '登録',
      'username': 'ユーザー名',
      'password': 'パスワード',
      'email': 'メール',
      'phone': '電話番号',
      'settings': '設定',
      'profile': 'プロフィール',
      'about': 'について',
      'version': 'バージョン',
      'theme': 'テーマ',
      'language': '言語',
      'light_theme': 'ライトテーマ',
      'dark_theme': 'ダークテーマ',
      'system_theme': 'システムテーマ',
    },
    'ko': {
      'app_name': 'Flutter MVVM',
      'loading': '로딩 중...',
      'error': '오류',
      'success': '성공',
      'cancel': '취소',
      'confirm': '확인',
      'retry': '다시 시도',
      'network_error': '네트워크 연결 실패',
      'server_error': '서버 오류',
      'unknown_error': '알 수 없는 오류',
      'no_data': '데이터 없음',
      'load_more': '더 보기',
      'refresh': '새로고침',
      'login': '로그인',
      'logout': '로그아웃',
      'register': '회원가입',
      'username': '사용자명',
      'password': '비밀번호',
      'email': '이메일',
      'phone': '전화번호',
      'settings': '설정',
      'profile': '프로필',
      'about': '정보',
      'version': '버전',
      'theme': '테마',
      'language': '언어',
      'light_theme': '라이트 테마',
      'dark_theme': '다크 테마',
      'system_theme': '시스템 테마',
    },
  };
}

/// 本地化委托
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any((supportedLocale) =>
        supportedLocale.languageCode == locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// 本地化扩展
extension LocalizationExtension on BuildContext {
  AppLocalizations? get l10n => AppLocalizations.of(this);
  
  String getString(String key) {
    return l10n?.getString(key) ?? key;
  }
}