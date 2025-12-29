import 'package:flutter/material.dart';

class AppListView extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Future<void> Function()? onRefresh;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;

  const AppListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.onRefresh,
    this.controller,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final list = ListView.separated(
      controller: controller,
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
      itemBuilder: itemBuilder,
    );
    return onRefresh != null
        ? RefreshIndicator(onRefresh: onRefresh!, child: list)
        : list;
  }
}
