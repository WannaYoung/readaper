# Readaper

Readaper 是一个现代化的稍后读应用程序，基于 Flutter 构建，采用 GetX 状态管理框架，提供流畅的阅读体验和丰富的功能特性。

[![pEzewb4.jpg](https://s21.ax1x.com/2025/05/22/pEzewb4.jpg)](https://imgse.com/i/pEzewb4)
[![pEzeBVJ.jpg](https://s21.ax1x.com/2025/05/22/pEzeBVJ.jpg)](https://imgse.com/i/pEzeBVJ)



## 主要特性

#### 1. 用户认证系统
- 自定义服务器地址
- 用户名和密码登录
- 安全的令牌管理
- 自动登录功能

#### 2. 国际化支持
- 支持简体中文 (zh_CN)
- 支持繁体中文 (zh_TW)
- 支持英语 (en_US)

#### 3. 主题定制
- 内置主题管理服务
- 支持动态主题切换
- 自定义UI样式

#### 4. 阅读体验
- 响应式设计
- 自定义阅读样式
- 全面的数据导入导出

## 技术栈
- Flutter
- GetX 状态管理
- GetStorage 数据持久化
- EasyLoading 加载提示



## 开始使用

- #### Readaper 安装

- #### 本地运行

  1. 确保已安装 Flutter 开发环境
  2. 克隆项目到本地
  3. 运行 `flutter pub get` 安装依赖
  4. 运行 `flutter run` 启动应用

- #### 安装包下载

  1. Android版本：https://github.com/WannaYoung/readaper/releases
  2. iOS版本：等待后续开发上架



## Readaper 后端部署

- 下载地址
https://readeck.org/en/download
- 安装文档
https://readeck.org/en/docs/
- 官方浏览器插件
https://chromewebstore.google.com/detail/readeck/jnmcpmfimecibicbojhopfkcbmkafhee
- 官方 Compose File
https://readeck.org/en/docs/compose
- 示例 Compose File
```
services:
  app:
    image: codeberg.org/readeck/readeck:latest
    container_name: Readeck
    ports:
      - 8300:8000
    environment:
      - READECK_LOG_LEVEL=info
      - READECK_SERVER_HOST=0.0.0.0
      - READECK_SERVER_PORT=8000
    volumes:
      - /vol1/1000/Docker/readeck:/readeck
    restart: always
    healthcheck:
      test: ["CMD", "/bin/readeck", "healthcheck", "-config", "config.toml"]
      interval: 30s
      timeout: 2s
      retries: 3
```
- 试用后端
服务器地址：https://wyread.tocmcc.cn
用户名：readeck
密码：readeck123

## 未来规划

#### 1. 功能增强

- [ ] 支持手动创建
- [ ] 添加离线阅读支持
- [ ] 实现标签管理和筛选
- [ ] 添加阅读进度同步
- [ ] 支持高亮功能
- [ ] 集成搜索功能
- [ ] 支持数据导出
- [ ] 添加iOS版本

#### 2. 阅读体验

- [ ] 自定义字体和样式
- [ ] 实现更多阅读主题
- [ ] 优化夜间模式
- [ ] 适配大屏设备

#### 3. 技术优化

- [ ] 性能优化
- [ ] 缓存机制改进
- [ ] 网络请求优化



## 许可证

本项目采用 GNU General Public License v3.0 (GPL-3.0) 许可证。这意味着您可以：

- 自由使用、修改和分发本软件
- 必须开放源代码
- 修改后的版本必须使用相同的许可证
- 商业使用需要获得授权

详细信息请参阅 [LICENSE](LICENSE) 文件。
