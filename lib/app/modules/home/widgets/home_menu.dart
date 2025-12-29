import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 首页菜单
///
/// - 用于展示简单的菜单列表
/// - 点击后会自动关闭弹层，并回调点击索引
class HomeMenu extends StatelessWidget {
  final void Function(int index)? onTap;

  const HomeMenu({
    super.key,
    this.onTap,
  });

  // 菜单标题
  static const List<String> _titles = [
    'filter',
    'settings',
    'exit',
  ];

  // 菜单图标（与 _titles 一一对应）
  static const List<IconData> _icons = [
    Icons.filter_list,
    Icons.settings,
    Icons.exit_to_app,
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
      itemCount: _titles.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(_icons[index]),
          title: Text(
            _titles[index].tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () {
            // 关闭菜单弹层
            Get.back();
            onTap?.call(index);
          },
        );
      },
    );
  }
}
