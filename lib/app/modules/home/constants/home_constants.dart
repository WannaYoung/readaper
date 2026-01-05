// Flutter imports:
import 'package:flutter/material.dart';

/// 首页模块常量
///
/// - 统一收口首页筛选映射与侧边栏配置
class HomeConstants {
  /// 筛选 key => 请求参数映射（不包含分页/排序参数）
  static const Map<String, Map<String, dynamic>> filterParamsMap = {
    'all': {},
    'unread': {
      'read_status': ['unread']
    },
    'archive': {'is_archived': true},
    'favorite': {'is_marked': true},
    'video': {
      'type': ['video']
    },
  };

  /// 侧边栏菜单项
  static const List<Map<String, Object>> sidebarItems = [
    {'icon': Icons.all_inbox, 'title': 'all'},
    {'icon': Icons.mark_unread_chat_alt_outlined, 'title': 'unread'},
    {'icon': Icons.archive_outlined, 'title': 'archive'},
    {'icon': Icons.favorite_border, 'title': 'favorite'},
    {'icon': Icons.video_library_outlined, 'title': 'video'},
  ];
}
