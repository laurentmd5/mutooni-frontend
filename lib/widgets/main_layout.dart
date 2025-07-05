import 'package:flutter/material.dart';
import 'package:mutooni_frontend/widgets/side_menu.dart';
import 'package:mutooni_frontend/widgets/header_bar.dart';


class MainLayout extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTap;
  final String title;
  final Widget child;
  final List<Widget>? actions;

  const MainLayout({
    super.key,
    required this.selectedIndex,
    required this.onItemTap,
    required this.title,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: isDesktop ? null : AppBar(title: Text(title), actions: actions),
      drawer: isDesktop ? null : Drawer(child: SideMenu(selectedIndex: selectedIndex, onItemTap: onItemTap)),
      body: Row(
        children: [
          if (isDesktop) SideMenu(selectedIndex: selectedIndex, onItemTap: onItemTap),
          Expanded(
            child: Column(
              children: [
                if (isDesktop) HeaderBar(title: title, actions: actions),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}