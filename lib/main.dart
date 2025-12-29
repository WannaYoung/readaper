import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:readaper/app/services/translations.dart';
import 'app/routes/app_pages.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app/services/localization_service.dart';
import 'app/services/theme_service.dart';
import 'app/services/bookmark_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  final box = GetStorage();
  final hasToken = box.read('token') != null;

  // 初始化本地化服务
  final localizationService = LocalizationService();
  final themeService = ThemeService();

  // 初始化书签同步服务（前台定时）
  BookmarkSyncService().init();

  runApp(GetMaterialApp(
    title: "Readaper",
    getPages: AppPages.routes,
    builder: combineBuilder,
    debugShowCheckedModeBanner: false,
    initialRoute: hasToken ? Routes.HOME : Routes.LOGIN,
    theme: themeService.currentTheme,
    translations: AppTranslations(),
    locale: localizationService.getCurrentLocale(),
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    fallbackLocale: const Locale('zh', 'CN'),
    supportedLocales: const [
      Locale('zh', 'CN'),
      Locale('zh', 'TW'),
      Locale('en', 'US')
    ],
  ));

  Get.config(
    enableLog: true,
    defaultTransition: Transition.rightToLeft,
    defaultDurationTransition: const Duration(milliseconds: 150),
  );

  Future.delayed(const Duration(milliseconds: 10), () {
    configEasyLoading();
    configUiOverlayStyle();
  });
}

/// 组合全局 Builder
///
/// - 接入 EasyLoading
/// - 统一处理点击空白处收起键盘
Widget combineBuilder(BuildContext context, Widget? child) {
  Widget easyLoadingWrappedChild =
      EasyLoading.init(builder: (innerContext, innerWidget) {
    return MediaQuery(
      data: MediaQuery.of(innerContext)
          .copyWith(textScaler: const TextScaler.linear(1.0)),
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            FocusManager.instance.primaryFocus!.unfocus();
          }
        },
        child: innerWidget!,
      ),
    );
  })(context, child);
  return easyLoadingWrappedChild;
}

/// 配置状态栏/系统 UI 样式
void configUiOverlayStyle() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));
}

/// 配置全局 Loading 样式
void configEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorWidget = LoadingAnimationWidget.fourRotatingDots(
        color: const Color.fromARGB(255, 67, 67, 67), size: 60)
    ..loadingStyle = EasyLoadingStyle.custom
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.transparent
    ..boxShadow = []
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskType = EasyLoadingMaskType.custom
    ..maskColor = Colors.white.withAlpha(200)
    ..userInteractions = false
    ..dismissOnTap = false;
}
