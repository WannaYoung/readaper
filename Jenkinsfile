pipeline {
  agent none

  // 通过参数控制是否执行各阶段，并选择 Google Play 的发布轨道。
  parameters {
    choice(name: 'ANDROID_TRACK', choices: ['internal', 'alpha', 'beta', 'production'], description: 'Google Play track')
    booleanParam(name: 'RUN_ANDROID_BUILD', defaultValue: true, description: 'Build Android')
    booleanParam(name: 'RUN_ANDROID_PLAY_UPLOAD', defaultValue: false, description: 'Upload Android to Google Play via fastlane')
    booleanParam(name: 'RUN_IOS_TESTFLIGHT', defaultValue: false, description: 'Build iOS and upload to TestFlight')
  }

  stages {
    stage('Android Build') {
      when {
        allOf {
          expression { return params.RUN_ANDROID_BUILD }
          tag pattern: 'v*', comparator: 'GLOB'
        }
      }
      // 需要 macOS 节点，并预先安装 Flutter，且系统可用 base64。
      agent { label 'mac' }
      environment {
        // Jenkins 工具配置中需要存在名为 'jdk17' 的 JDK 安装。
        JAVA_HOME = tool(name: 'jdk17', type: 'hudson.model.JDK')
        PATH = "${env.JAVA_HOME}/bin:${env.PATH}"
      }
      steps {
        checkout([
          $class: 'GitSCM',
          branches: scm.branches,
          userRemoteConfigs: scm.userRemoteConfigs,
          extensions: [
            [$class: 'CloneOption', shallow: true, depth: 1, noTags: true, timeout: 20]
          ]
        ])
        sh 'flutter --version'
        sh 'flutter pub get'

        // 需要在 Jenkins 中配置凭据（建议使用 String credentials）。
        // 若 ANDROID_KEYSTORE_BASE64 为空，Gradle 会回退为 debug 签名，避免构建直接失败。
        withCredentials([
          string(credentialsId: 'ANDROID_KEYSTORE_BASE64', variable: 'ANDROID_KEYSTORE_BASE64'),
          string(credentialsId: 'ANDROID_KEYSTORE_PASSWORD', variable: 'ANDROID_KEYSTORE_PASSWORD'),
          string(credentialsId: 'ANDROID_KEY_ALIAS', variable: 'ANDROID_KEY_ALIAS'),
          string(credentialsId: 'ANDROID_KEY_PASSWORD', variable: 'ANDROID_KEY_PASSWORD')
        ]) {
          sh '''
            export ANDROID_KEYSTORE_BASE64="$ANDROID_KEYSTORE_BASE64"
            export ANDROID_KEYSTORE_PASSWORD="$ANDROID_KEYSTORE_PASSWORD"
            export ANDROID_KEY_ALIAS="$ANDROID_KEY_ALIAS"
            export ANDROID_KEY_PASSWORD="$ANDROID_KEY_PASSWORD"

            flutter build apk --release
            flutter build appbundle --release
          '''
        }

        archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/*.apk, build/app/outputs/bundle/release/*.aab', fingerprint: true
      }
    }

    stage('Android Upload Google Play') {
      when {
        allOf {
          expression { return params.RUN_ANDROID_PLAY_UPLOAD }
          tag pattern: 'v*', comparator: 'GLOB'
        }
      }
      // 需要 macOS 节点，并预先安装 Flutter/Ruby，且允许安装 gem（fastlane）。
      agent { label 'mac' }
      environment {
        JAVA_HOME = tool(name: 'jdk17', type: 'hudson.model.JDK')
        PATH = "${env.JAVA_HOME}/bin:${env.PATH}"
      }
      steps {
        checkout([
          $class: 'GitSCM',
          branches: scm.branches,
          userRemoteConfigs: scm.userRemoteConfigs,
          extensions: [
            [$class: 'CloneOption', shallow: true, depth: 1, noTags: true, timeout: 20]
          ]
        ])
        sh 'flutter pub get'

        // GOOGLE_PLAY_SERVICE_ACCOUNT_JSON 必须是完整的服务账号 JSON 内容（用于上传 Google Play）。
        withCredentials([
          string(credentialsId: 'ANDROID_KEYSTORE_BASE64', variable: 'ANDROID_KEYSTORE_BASE64'),
          string(credentialsId: 'ANDROID_KEYSTORE_PASSWORD', variable: 'ANDROID_KEYSTORE_PASSWORD'),
          string(credentialsId: 'ANDROID_KEY_ALIAS', variable: 'ANDROID_KEY_ALIAS'),
          string(credentialsId: 'ANDROID_KEY_PASSWORD', variable: 'ANDROID_KEY_PASSWORD'),
          string(credentialsId: 'GOOGLE_PLAY_SERVICE_ACCOUNT_JSON', variable: 'GOOGLE_PLAY_SERVICE_ACCOUNT_JSON')
        ]) {
          sh '''
            export ANDROID_KEYSTORE_BASE64="$ANDROID_KEYSTORE_BASE64"
            export ANDROID_KEYSTORE_PASSWORD="$ANDROID_KEYSTORE_PASSWORD"
            export ANDROID_KEY_ALIAS="$ANDROID_KEY_ALIAS"
            export ANDROID_KEY_PASSWORD="$ANDROID_KEY_PASSWORD"

            flutter build appbundle --release
            AAB_PATH=$(ls -1 build/app/outputs/bundle/release/*.aab | head -n 1)
            if [ -z "$AAB_PATH" ]; then
              echo "No AAB found" >&2
              exit 1
            fi

            sudo gem install fastlane -NV

            export ANDROID_PACKAGE_NAME=cn.wannayoung.readaper
            export PLAY_TRACK="${ANDROID_TRACK}"
            export AAB_PATH="$AAB_PATH"

            cd android
            fastlane android play
          '''
        }
      }
    }

    stage('iOS TestFlight') {
      when {
        allOf {
          expression { return params.RUN_IOS_TESTFLIGHT }
          tag pattern: 'v*', comparator: 'GLOB'
        }
      }
      // 需要 macOS 节点：Xcode/Flutter/签名资产（证书与描述文件）。
      agent { label 'mac' }
      steps {
        checkout([
          $class: 'GitSCM',
          branches: scm.branches,
          userRemoteConfigs: scm.userRemoteConfigs,
          extensions: [
            [$class: 'CloneOption', shallow: true, depth: 1, noTags: true, timeout: 20]
          ]
        ])
        sh 'flutter --version'
        sh 'flutter pub get'

        // App Store Connect API Key 凭据。
        withCredentials([
          string(credentialsId: 'APP_STORE_CONNECT_KEY_ID', variable: 'APP_STORE_CONNECT_KEY_ID'),
          string(credentialsId: 'APP_STORE_CONNECT_ISSUER_ID', variable: 'APP_STORE_CONNECT_ISSUER_ID'),
          string(credentialsId: 'APP_STORE_CONNECT_PRIVATE_KEY', variable: 'APP_STORE_CONNECT_PRIVATE_KEY')
        ]) {
          sh '''
            sudo gem install fastlane -NV
            sudo gem install cocoapods -NV
            cd ios
            pod install
            cd ..

            flutter build ipa --release --export-method app-store

            export IOS_BUNDLE_ID=cn.wannayoung.readaper
            export APPLE_TEAM_ID=5L4C6674RT
            export IPA_PATH=build/ios/ipa/*.ipa

            cd ios
            fastlane ios testflight
          '''
        }

        archiveArtifacts artifacts: 'build/ios/ipa/*.ipa', fingerprint: true
      }
    }
  }
}
