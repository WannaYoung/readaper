import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InAppBrowserPage extends StatefulWidget {
  final String url;
  final String? title;

  const InAppBrowserPage({
    super.key,
    required this.url,
    this.title,
  });

  @override
  State<InAppBrowserPage> createState() => _InAppBrowserPageState();
}

class _InAppBrowserPageState extends State<InAppBrowserPage> {
  late final WebViewController _controller;
  var _progress = 0;

  @override
  void initState() {
    super.initState();

    // 初始化 WebView 控制器
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            // 加载进度：用于顶部进度条展示
            if (!mounted) return;
            setState(() {
              _progress = progress;
            });
          },
        ),
      )
      ..loadRequest(_safeParseUrl(widget.url));
  }

  /// 解析 URL 的兜底逻辑
  ///
  /// - 避免传入非法 URL 导致页面崩溃
  /// - 如果缺少 scheme，默认补全 https
  Uri _safeParseUrl(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return Uri.parse('about:blank');

    try {
      final uri = Uri.parse(text);
      if (uri.hasScheme) return uri;
      return Uri.parse('https://$text');
    } catch (_) {
      return Uri.parse('about:blank');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? '',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            // 刷新当前页面
            onPressed: () => _controller.reload(),
          ),
        ],
        bottom: _progress >= 100
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(
                  value: _progress / 100.0,
                  backgroundColor: theme.colorScheme.surface,
                  color: theme.colorScheme.primary,
                  minHeight: 2,
                ),
              ),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
