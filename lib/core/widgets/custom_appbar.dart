import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool withBackButton;
  const CustomAppBar({
    super.key,
    required this.title,
    this.withBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: withBackButton,
      title: Text(title),
      // bottom: const PreferredSize(
      //   preferredSize: Size.fromHeight(1.0),
      //   child: Divider(),
      // ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
