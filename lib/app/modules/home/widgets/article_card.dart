import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:pie_menu/pie_menu.dart';
import '../models/bookmark.dart';

/// 首页文章卡片
///
/// - 展示书签标题/描述/站点信息
/// - 支持点击进入详情
/// - 支持长按（PieMenu）执行收藏/归档/分享/删除等操作
class ArticleCard extends StatelessWidget {
  final Bookmark bookmark;
  final VoidCallback? onTap;
  final Function(int)? onPieAction;

  const ArticleCard({
    super.key,
    required this.bookmark,
    this.onTap,
    this.onPieAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color ?? theme.hintColor;
    final secondaryTextColor =
        (theme.textTheme.bodySmall?.color ?? theme.hintColor).withAlpha(170);
    final pieButtonTheme = PieButtonTheme(
      iconColor: textColor,
      backgroundColor: theme.scaffoldBackgroundColor,
    );
    final pieButtonThemeHovered = PieButtonTheme(
      iconColor: theme.colorScheme.onPrimary,
      backgroundColor: theme.primaryColor,
    );
    final favoriteButtonTheme = PieButtonTheme(
      iconColor: theme.colorScheme.onPrimary,
      backgroundColor: theme.primaryColor,
    );
    final archiveButtonTheme = PieButtonTheme(
      iconColor: theme.colorScheme.onPrimary,
      backgroundColor: theme.primaryColor,
    );

    final isRead = bookmark.readProgress >= 100;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: PieMenu(
        onToggle: (isOpen) async {
          // 打开菜单时触发轻微震动反馈
          if (isOpen) {
            await Haptics.vibrate(HapticsType.selection);
          }
        },
        actions: [
          PieAction(
            tooltip: Text('edit'.tr),
            onSelect: () => onPieAction?.call(0),
            buttonTheme: pieButtonTheme,
            buttonThemeHovered: pieButtonThemeHovered,
            child: const Icon(Icons.edit),
          ),
          PieAction(
            tooltip: Text(isRead ? 'markUnread'.tr : 'markRead'.tr),
            onSelect: () => onPieAction?.call(1),
            buttonTheme: pieButtonTheme,
            buttonThemeHovered: pieButtonThemeHovered,
            child: Icon(isRead ? Icons.markunread : Icons.done),
          ),
          PieAction(
            tooltip: Text(bookmark.isMarked ? 'unfavorite'.tr : 'favorite'.tr),
            onSelect: () => onPieAction?.call(2),
            buttonTheme:
                bookmark.isMarked ? favoriteButtonTheme : pieButtonTheme,
            buttonThemeHovered: pieButtonThemeHovered,
            child: const Icon(Icons.favorite),
          ),
          PieAction(
            tooltip: Text(bookmark.isArchived ? 'unarchive'.tr : 'archive'.tr),
            onSelect: () => onPieAction?.call(3),
            buttonTheme:
                bookmark.isArchived ? archiveButtonTheme : pieButtonTheme,
            buttonThemeHovered: pieButtonThemeHovered,
            child: const Icon(Icons.archive),
          ),
          PieAction(
            tooltip: Text('share'.tr),
            onSelect: () => onPieAction?.call(4),
            buttonTheme: pieButtonTheme,
            buttonThemeHovered: pieButtonThemeHovered,
            child: const Icon(Icons.share),
          ),
          PieAction(
            tooltip: Text('delete'.tr),
            onSelect: () => onPieAction?.call(5),
            buttonTheme: pieButtonTheme,
            buttonThemeHovered: PieButtonTheme(
              iconColor: Colors.white,
              backgroundColor: const Color.fromARGB(255, 239, 72, 60),
            ),
            child: const Icon(Icons.delete),
          ),
        ],
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          elevation: 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          bookmark.title ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if ((bookmark.description ?? '').isNotEmpty) ...[
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
                          borderRadius: BorderRadius.circular(8),
                          child: ExtendedImage.network(
                            cache: true,
                            bookmark.iconUrl!,
                            width: 20,
                            height: 20,
                            fit: BoxFit.cover,
                          ),
                        ),
                      if (bookmark.iconUrl != null) const SizedBox(width: 5),
                      if ((bookmark.site ?? '').isNotEmpty)
                        Expanded(
                          child: Text(
                            bookmark.site!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: secondaryTextColor,
                            ),
                          ),
                        ),
                      const SizedBox(width: 10),
                      if ((bookmark.created ?? '').isNotEmpty)
                        Text(
                          bookmark.created!,
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
          ),
        ),
      ),
    );
  }
}
