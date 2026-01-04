import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 阅读页 AppBar 右上角弹窗按钮
///
/// - 点击后以 Overlay 的形式弹出菜单
/// - 动画从按钮右下角起始，向左下展开
/// - 支持与首页侧边栏一致的 masking（点击遮罩关闭）
class ReadingAppBarPopup extends StatefulWidget {
  /// 弹窗背景色
  final Color backgroundColor;

  /// 分享回调
  final VoidCallback onShare;

  /// 打开来源回调
  final VoidCallback onOpenSource;

  const ReadingAppBarPopup({
    super.key,
    required this.backgroundColor,
    required this.onShare,
    required this.onOpenSource,
  });

  @override
  State<ReadingAppBarPopup> createState() => _ReadingAppBarPopupState();
}

class _ReadingAppBarPopupState extends State<ReadingAppBarPopup>
    with SingleTickerProviderStateMixin {
  /// 按钮锚点
  final GlobalKey _anchorKey = GlobalKey();

  /// Overlay 实例
  OverlayEntry? _overlayEntry;

  /// 动画控制器
  late final AnimationController _controller;

  /// 动画曲线
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _removeOverlay(immediately: true);
    _controller.dispose();
    super.dispose();
  }

  /// 切换弹窗
  void _toggle() {
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }
    _showOverlay();
  }

  /// 展示弹窗
  void _showOverlay() {
    final anchorContext = _anchorKey.currentContext;
    if (anchorContext == null) return;

    final renderBox = anchorContext.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final anchorOffset = renderBox.localToGlobal(Offset.zero);
    final anchorRect = anchorOffset & renderBox.size;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    final screenSize = MediaQuery.of(context).size;
    final popupWidth = screenSize.width * 0.5;

    // 菜单顶部与 AppBar/按钮底部间距
    final top = anchorRect.bottom + 12;

    // 菜单右侧与按钮右侧对齐
    var right = screenSize.width - anchorRect.right;
    if (right < 0) right = 0;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final ratio = _animation.value;
                  return IgnorePointer(
                    ignoring: ratio <= 0,
                    child: GestureDetector(
                      onTap: _removeOverlay,
                      child: Container(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha((70 * ratio).round()),
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                top: top,
                right: right,
                child: FadeTransition(
                  opacity: _animation,
                  child: ScaleTransition(
                    alignment: Alignment.topRight,
                    scale: _animation,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: popupWidth,
                        minWidth: popupWidth,
                      ),
                      child: Material(
                        color: widget.backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        elevation: 8,
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _PopupActionTile(
                              icon: Icons.share_outlined,
                              title: 'shareArticle'.tr,
                              onTap: () async {
                                await _removeOverlay();
                                widget.onShare();
                              },
                            ),
                            Divider(
                              height: 1,
                              color:
                                  Theme.of(context).dividerColor.withAlpha(80),
                            ),
                            _PopupActionTile(
                              icon: Icons.open_in_browser_outlined,
                              title: 'openSource'.tr,
                              onTap: () async {
                                await _removeOverlay();
                                widget.onOpenSource();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);
    _controller.forward(from: 0);
  }

  /// 关闭弹窗
  Future<void> _removeOverlay({bool immediately = false}) async {
    final entry = _overlayEntry;
    if (entry == null) return;

    _overlayEntry = null;
    if (immediately) {
      entry.remove();
      return;
    }

    try {
      await _controller.reverse();
    } catch (_) {}
    entry.remove();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: _anchorKey,
      icon: const Icon(Icons.more_vert),
      onPressed: _toggle,
    );
  }
}

class _PopupActionTile extends StatelessWidget {
  /// 图标
  final IconData icon;

  /// 标题
  final String title;

  /// 点击
  final VoidCallback onTap;

  const _PopupActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.iconTheme.color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ) ??
                    TextStyle(color: theme.colorScheme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
