# Readaper CI/CD（GitHub Actions + Fastlane + Jenkins）

本文档面向 Flutter 项目（根目录包含 `pubspec.yaml`，并包含 `android/`、`ios/`）。

> 目标
>
> - Android：构建 APK/AAB；并支持上传 Google Play（internal/alpha/beta/production）。
> - iOS：构建 IPA；并上传 TestFlight。
> - 同时支持 GitHub Actions 与 Jenkins 两套集成。

---

## 1. 仓库内已落地的文件

### 1.1 GitHub Actions Workflows

- `.github/workflows/android_release.yml`
  - 构建：`flutter build apk --release` + `flutter build appbundle --release`
  - 产物：上传到 Actions Artifacts

- `.github/workflows/android_google_play.yml`
  - 构建：`flutter build appbundle --release`
  - 发布：通过 **fastlane supply** 上传到 Google Play

- `.github/workflows/ios_testflight.yml`
  - 构建：`flutter build ipa --release --export-method app-store`
  - 发布：通过 **fastlane pilot** 上传到 TestFlight

### 1.2 Fastlane

- iOS fastlane：`ios/fastlane/`
  - `ios/fastlane/Fastfile`
  - `ios/fastlane/Appfile`

- Android fastlane：`android/fastlane/`
  - `android/fastlane/Fastfile`

### 1.3 Jenkins

- `Jenkinsfile`
  - 支持 Android 构建、Android 上传 Google Play（fastlane）、iOS 上传 TestFlight（fastlane）

---

## 2. Fastlane 目录应该放哪里？（Flutter 项目常见组织方式）

Fastlane **可以**放在 Flutter 根目录，也可以放在 `ios/` 与 `android/` 下。

### 2.1 放在 `ios/fastlane` 与 `android/fastlane`（本项目当前做法）

- 优点
  - 与平台工程强绑定，路径最少坑
  - iOS lane 在 `ios` 目录执行，默认能找到 Xcode 工程、Pods、workspace
  - Android lane 在 `android` 目录执行，默认能找到 Gradle
- 缺点
  - iOS 与 Android 分散在两个 fastlane 目录

### 2.2 放在 Flutter 根目录 `fastlane/`（可选）

- 优点
  - 一个入口统一管理 iOS/Android lanes
- 缺点
  - 需要在 lane 内手动处理 `Dir.chdir("ios")` / `Dir.chdir("android")` 以及产物路径

结论：两种都对；如果你希望“最省心”，推荐分平台放置（即当前做法）。

---

## 3. Android：签名与构建

### 3.1 Gradle release 签名策略（已实现）

文件：`android/app/build.gradle`

- 通过环境变量注入 release keystore（适配 GitHub Actions / Jenkins）
- 当环境变量为空或未配置时，release 会回退为 debug signing，避免构建直接失败

环境变量：

- `ANDROID_KEYSTORE_PATH`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

> 注意：在 CI 上，空字符串和 null 的差异很常见，Gradle 中已使用 Groovy truthy 判断规避误判。

### 3.2 Android 产物路径

- APK：`build/app/outputs/flutter-apk/*.apk`
- AAB：`build/app/outputs/bundle/release/*.aab`

---

## 4. Android：上传 Google Play（fastlane supply）

### 4.1 使用的 lane

文件：`android/fastlane/Fastfile`

- lane：`android play`
- 依赖：fastlane 的 `supply`（由 fastlane 提供）

运行方式（示例）：

```bash
cd android
PLAY_TRACK=internal \
ANDROID_PACKAGE_NAME=cn.wannayoung.readaper \
AAB_PATH=../build/app/outputs/bundle/release/app-release.aab \
GOOGLE_PLAY_SERVICE_ACCOUNT_JSON='{"type":"service_account",...}' \
fastlane android play
```

### 4.2 Google Play 服务账号

你需要在 Google Play Console 创建服务账号并授予权限，并在 CI 中注入 JSON。

- GitHub Actions Secret：`GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`
- Jenkins Credential（String）：`GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`

---

## 5. iOS：构建与上传 TestFlight（fastlane pilot）

### 5.1 使用的 lane

文件：`ios/fastlane/Fastfile`

- lane：`ios testflight`
- 使用 App Store Connect API Key
- 需要的环境变量：
  - `APP_STORE_CONNECT_KEY_ID`
  - `APP_STORE_CONNECT_ISSUER_ID`
  - `APP_STORE_CONNECT_PRIVATE_KEY`
  - `IPA_PATH`
  - `IOS_BUNDLE_ID`
  - `APPLE_TEAM_ID`

运行方式（示例）：

```bash
cd ios
APP_STORE_CONNECT_KEY_ID=xxxx \
APP_STORE_CONNECT_ISSUER_ID=yyyy \
APP_STORE_CONNECT_PRIVATE_KEY='-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----' \
IOS_BUNDLE_ID=cn.wannayoung.readaper \
APPLE_TEAM_ID=5L4C6674RT \
IPA_PATH=../build/ios/ipa/*.ipa \
fastlane ios testflight
```

### 5.2 iOS 签名注意事项（最重要）

即使 TestFlight 上传使用 API Key，不代表构建 IPA 不需要签名。

- 如果你的 CI 机器（GitHub macOS runner 或 Jenkins mac 节点）没有可用的签名证书/配置文件，`flutter build ipa` 仍可能失败。
- 若要 100% 稳定，建议后续引入：
  - `fastlane match`（推荐标准方案）
  - 或在 CI 中导入 `p12 + mobileprovision`

---

## 6. GitHub Actions：工作流说明

### 6.1 Android Release Build

文件：`.github/workflows/android_release.yml`

触发：
- `push` 到 `main`
- `workflow_dispatch`

步骤概览：
- checkout
- 安装 Flutter（3.35.0）
- 安装 Java 17
- `flutter pub get`
- 若配置 `ANDROID_KEYSTORE_BASE64`，则解码生成 `android/app/upload-keystore.jks`
- 构建 apk/aab
- 上传 artifacts

### 6.2 Android Google Play（fastlane）

文件：`.github/workflows/android_google_play.yml`

触发：
- `workflow_dispatch`（手动触发）

参数：
- `track`：internal/alpha/beta/production

步骤概览：
- checkout
- Flutter + Java 17
- 生成 keystore（可选）
- 构建 aab
- 安装 fastlane
- `cd android && fastlane android play`

### 6.3 iOS TestFlight

文件：`.github/workflows/ios_testflight.yml`

触发：
- `push` 到 `main`
- `workflow_dispatch`

步骤概览：
- checkout
- Flutter
- `flutter pub get`
- 安装 fastlane/cocoapods
- `pod install`
- `flutter build ipa`
- `fastlane ios testflight`

---

## 7. GitHub Secrets 清单

进入：GitHub Repo -> Settings -> Secrets and variables -> Actions

### 7.1 Android（建议）

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

### 7.2 Google Play（必需：若上传 Play）

- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`

### 7.3 iOS TestFlight（必需）

- `APP_STORE_CONNECT_KEY_ID`
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_PRIVATE_KEY`

---

## 8. Jenkins 集成说明

你需要准备 Jenkins 节点能力：

- Linux 节点（label：`linux`）
  - Flutter SDK
  - JDK 17（在 Jenkins 工具配置中命名为 `jdk17`）
  - Ruby（用于安装 fastlane）

- mac 节点（label：`mac`）（仅 iOS 流程需要）
  - Flutter SDK
  - Xcode
  - Ruby
  - CocoaPods

### 8.1 Jenkins Credentials（建议用 String 类型）

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`
- `APP_STORE_CONNECT_KEY_ID`
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_PRIVATE_KEY`

### 8.2 Jenkinsfile 参数

- `ANDROID_TRACK`：internal/alpha/beta/production
- `RUN_ANDROID_BUILD`
- `RUN_ANDROID_PLAY_UPLOAD`
- `RUN_IOS_TESTFLIGHT`

### 8.3 Jenkinsfile 运行逻辑

- Android Build
  - 构建 apk/aab 并归档
- Android Upload Google Play
  - 构建 aab 后执行 `fastlane android play`
- iOS TestFlight
  - 构建 ipa 后执行 `fastlane ios testflight`

---

## 9. 常见问题排查

### 9.1 Android：keystore 空值导致构建失败

- 确认 `ANDROID_KEYSTORE_BASE64` 是否真的配置
- 确认 base64 解码后生成了 `android/app/upload-keystore.jks`

### 9.2 Android：Google Play 上传失败

- 包名必须与 Play Console 中创建的 App 一致：`cn.wannayoung.readaper`
- 服务账号需要被授予发布权限
- track 参数需合法

### 9.3 iOS：`flutter build ipa` 签名失败

- CI 机器上缺少证书/配置文件是最常见原因
- 推荐后续引入 `fastlane match` 做签名资产管理

### 9.4 iOS：`pod install` 失败（最低 iOS 版本过低）

现象（GitHub Actions / Jenkins mac 节点常见）：

- 报错提示类似：
  - `Automatically assigning platform iOS with version 12.0 ... because no platform was specified`
  - `CocoaPods could not find compatible versions for pod "webview_flutter_wkwebview"`
  - `... required a higher minimum deployment target`

原因：

- Podfile 未显式设置 `platform :ios, 'x.y'` 时，CocoaPods 可能自动按较低版本（例如 12.0）处理。
- 某些 Flutter 插件（例如 `webview_flutter_wkwebview`）已要求更高的 iOS 最低版本，因此在 `pod install` 阶段直接失败。

本项目当前修复方式：

- 在 `ios/Podfile` 显式设置：`platform :ios, '13.0'`
- 同步将 Xcode 工程的 `IPHONEOS_DEPLOYMENT_TARGET` 更新为 `13.0`，保持与 Podfile 一致：
  - `ios/Runner.xcodeproj/project.pbxproj`

注意：

- 提升最低 iOS 版本会影响你支持的最旧系统版本范围，请在发布前确认你的用户群是否接受。

---

## 10. 下一步可选增强

- iOS：引入 `fastlane match`（CI 全自动签名）
- Android：Play 上传前自动生成/上传 changelog、版本管理
- 增加 workflow 的触发策略：只允许 tag 发布/或只允许手动发布 production
