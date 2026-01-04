import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:pie_menu/pie_menu.dart';
import '../models/bookmark.dart';

class _ArticlePieMenuThemes {
  /// 默认样式
  final PieButtonTheme normal;

  /// 悬浮样式
  final PieButtonTheme hovered;

  /// 收藏样式
  final PieButtonTheme favorite;

  /// 归档样式
  final PieButtonTheme archive;

  /// 删除悬浮样式
  final PieButtonTheme deleteHovered;

  _ArticlePieMenuThemes({
    required this.normal,
    required this.hovered,
    required this.favorite,
    required this.archive,
    required this.deleteHovered,
  });

  /// 生成主题样式
  static _ArticlePieMenuThemes fromTheme(ThemeData theme) {
    final textColor = theme.textTheme.bodyMedium?.color ?? theme.hintColor;

    return _ArticlePieMenuThemes(
      normal: PieButtonTheme(
        iconColor: textColor,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      hovered: PieButtonTheme(
        iconColor: theme.colorScheme.onPrimary,
        backgroundColor: theme.primaryColor,
      ),
      favorite: PieButtonTheme(
        iconColor: const Color(0xFFE53935),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      archive: PieButtonTheme(
        iconColor: const Color(0xFFFF9800),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      deleteHovered: const PieButtonTheme(
        iconColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 239, 72, 60),
      ),
    );
  }
}

/// 构建文章卡片的 PieMenu actions
///
/// - 列表/瀑布流共用
List<PieAction> _buildArticlePieActions({
  /// 书签
  required Bookmark bookmark,

  /// 已读状态
  required bool isRead,

  /// 主题
  required _ArticlePieMenuThemes themes,

  /// 回调
  required Function(int)? onPieAction,
}) {
  return [
    PieAction(
      tooltip: Text('edit'.tr),
      onSelect: () => onPieAction?.call(0),
      buttonTheme: themes.normal,
      buttonThemeHovered: themes.hovered,
      child: const Icon(Icons.edit),
    ),
    PieAction(
      tooltip: Text(isRead ? 'markUnread'.tr : 'markRead'.tr),
      onSelect: () => onPieAction?.call(1),
      buttonTheme: themes.normal,
      buttonThemeHovered: themes.hovered,
      child: Icon(isRead ? Icons.markunread : Icons.done),
    ),
    PieAction(
      tooltip: Text(bookmark.isMarked ? 'unfavorite'.tr : 'favorite'.tr),
      onSelect: () => onPieAction?.call(2),
      buttonTheme: bookmark.isMarked ? themes.favorite : themes.normal,
      buttonThemeHovered: themes.hovered,
      child: Icon(
        bookmark.isMarked ? Icons.favorite : Icons.favorite_border_outlined,
      ),
    ),
    PieAction(
      tooltip: Text(bookmark.isArchived ? 'unarchive'.tr : 'archive'.tr),
      onSelect: () => onPieAction?.call(3),
      buttonTheme: bookmark.isArchived ? themes.archive : themes.normal,
      buttonThemeHovered: themes.hovered,
      child: Icon(
        bookmark.isArchived ? Icons.archive : Icons.archive_outlined,
      ),
    ),
    PieAction(
      tooltip: Text('delete'.tr),
      onSelect: () => onPieAction?.call(4),
      buttonTheme: themes.normal,
      buttonThemeHovered: themes.deleteHovered,
      child: const Icon(Icons.delete),
    ),
  ];
}

/// 首页文章卡片
///
/// - 展示书签标题/描述/站点信息
/// - 支持点击进入详情
/// - 支持长按（PieMenu）执行收藏/归档/分享/删除等操作
class ArticleListCard extends StatelessWidget {
  final Bookmark bookmark;
  final VoidCallback? onTap;
  final Function(int)? onPieAction;

  final bool showPreviewImage;
  final bool showSummary;
  final double titleFontSize;

  const ArticleListCard({
    super.key,
    required this.bookmark,
    this.onTap,
    this.onPieAction,
    this.showPreviewImage = true,
    this.showSummary = true,
    this.titleFontSize = 17,
  });

  String? _pickPreviewUrl() {
    return bookmark.thumbnailUrl ?? bookmark.imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryTextColor =
        (theme.textTheme.bodySmall?.color ?? theme.hintColor).withAlpha(170);
    final pieThemes = _ArticlePieMenuThemes.fromTheme(theme);

    final isRead = bookmark.readProgress >= 100;
    final siteText = (bookmark.siteName ?? bookmark.site ?? '').trim();
    final createdText = (bookmark.created ?? '').split('T').first;

    final previewUrl = _pickPreviewUrl();
    final hasPreview = previewUrl != null && previewUrl.trim().isNotEmpty;
    final showImage = showPreviewImage && hasPreview;
    final showDesc = showSummary && (bookmark.description ?? '').isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: PieMenu(
        onToggle: (isOpen) async {
          // 打开菜单时触发轻微震动反馈
          if (isOpen) {
            await Haptics.vibrate(HapticsType.selection);
          }
        },
        actions: _buildArticlePieActions(
          bookmark: bookmark,
          isRead: isRead,
          themes: pieThemes,
          onPieAction: onPieAction,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          elevation: 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bookmark.title ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: titleFontSize,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (showDesc) ...[
                          const SizedBox(height: 8),
                          Text(
                            bookmark.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            if (bookmark.iconUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: ExtendedImage.network(
                                  cache: true,
                                  bookmark.iconUrl!,
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            if (bookmark.iconUrl != null)
                              const SizedBox(width: 5),
                            if (siteText.isNotEmpty)
                              Expanded(
                                child: Text(
                                  siteText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 10),
                            if (createdText.isNotEmpty)
                              Text(
                                createdText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondaryTextColor,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (showImage) ...[
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: ExtendedImage.network(
                        cache: true,
                        previewUrl,
                        width: 92,
                        height: 68,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ArticleGridCard extends StatelessWidget {
  final Bookmark bookmark;
  final VoidCallback? onTap;
  final Function(int)? onPieAction;

  final bool showPreviewImage;
  final bool showSummary;
  final double titleFontSize;

  const ArticleGridCard({
    super.key,
    required this.bookmark,
    this.onTap,
    this.onPieAction,
    this.showPreviewImage = true,
    this.showSummary = true,
    this.titleFontSize = 16,
  });

  double? _calcAspectRatio() {
    final thumb = bookmark.resources?.thumbnail;
    if (thumb?.width != null && thumb?.height != null && thumb!.height! > 0) {
      return thumb.width! / thumb.height!;
    }
    final img = bookmark.resources?.image;
    if (img?.width != null && img?.height != null && img!.height! > 0) {
      return img.width! / img.height!;
    }
    return null;
  }

  String? _pickPreviewUrl() {
    return bookmark.thumbnailUrl ?? bookmark.imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryTextColor =
        (theme.textTheme.bodySmall?.color ?? theme.hintColor).withAlpha(170);
    final pieThemes = _ArticlePieMenuThemes.fromTheme(theme);

    final isRead = bookmark.readProgress >= 100;
    final siteText = (bookmark.siteName ?? bookmark.site ?? '').trim();
    final createdText = (bookmark.created ?? '').split('T').first;

    final previewUrl = _pickPreviewUrl();
    final hasPreview = previewUrl != null && previewUrl.trim().isNotEmpty;
    final showImage = showPreviewImage && hasPreview;
    final showDesc = showSummary && (bookmark.description ?? '').isNotEmpty;

    final cardRadius = BorderRadius.circular(8);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: PieMenu(
        onToggle: (isOpen) async {
          if (isOpen) {
            await Haptics.vibrate(HapticsType.selection);
          }
        },
        actions: _buildArticlePieActions(
          bookmark: bookmark,
          isRead: isRead,
          themes: pieThemes,
          onPieAction: onPieAction,
        ),
        child: Material(
          color: theme.cardColor,
          borderRadius: cardRadius,
          elevation: 0,
          child: InkWell(
            borderRadius: cardRadius,
            onTap: onTap,
            child: ClipRRect(
              borderRadius: cardRadius,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showImage)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                      child: AspectRatio(
                        aspectRatio: _calcAspectRatio() ?? 16 / 10,
                        child: ExtendedImage.network(
                          cache: true,
                          previewUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bookmark.title ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: titleFontSize,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (showDesc) ...[
                          const SizedBox(height: 8),
                          Text(
                            bookmark.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            if (bookmark.iconUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: ExtendedImage.network(
                                  cache: true,
                                  bookmark.iconUrl!,
                                  width: 18,
                                  height: 18,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            if (bookmark.iconUrl != null)
                              const SizedBox(width: 5),
                            if (siteText.isNotEmpty)
                              Expanded(
                                child: Text(
                                  siteText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            if (createdText.isNotEmpty)
                              Text(
                                createdText,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: secondaryTextColor,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
