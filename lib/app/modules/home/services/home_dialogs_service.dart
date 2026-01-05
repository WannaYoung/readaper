// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../widgets/add_bookmark_dialog.dart';
import '../widgets/edit_bookmark_dialog.dart';

/// 首页弹窗服务
///
/// - 统一管理首页相关弹窗打开逻辑
/// - 将弹窗实现细节与 HomeController 解耦
class HomeDialogsService {
  /// 打开“新增书签”弹窗
  Future<AddBookmarkDialogResult?> openAddBookmarkDialog(
    BuildContext context, {
    String? initialUrl,
  }) async {
    return showAddBookmarkDialog(context, initialUrl: initialUrl);
  }

  /// 打开“编辑标题”弹窗
  Future<String?> openEditTitleDialog(
    BuildContext context, {
    required String initialTitle,
  }) async {
    return showEditBookmarkTitleDialog(context, initialTitle: initialTitle);
  }
}
