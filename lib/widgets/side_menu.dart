import 'package:flutter/material.dart';
import 'package:mutooni_frontend/core/app_theme.dart';
import 'package:go_router/go_router.dart';

/// Menu latéral principal.
class SideMenu extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTap;
  const SideMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Tableau de bord', Icons.dashboard, '/'),
      ('Ventes', Icons.point_of_sale, '/ventes'),
      ('Achats', Icons.shopping_bag, '/achats'),
      ('Clients', Icons.people, '/clients'),
      ('RH', Icons.badge, '/rh'),
      ('Rapports', Icons.bar_chart, '/rapports'),
      ('Paramètres', Icons.settings, '/settings'),
    ];

    return Container(
      width: 220,
      color: AppColors.sidebarBg,
      child: Column(
        children: [
          const SizedBox(height: 32),
          const Text('Mutooni',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) {
                final (label, iconData, route) = items[i];
                final selected = i == selectedIndex;
                return ListTile(
                  leading: Icon(iconData,
                      color: selected ? Colors.white : AppColors.primaryBlue),
                  title: Text(label,
                      style: TextStyle(
                          color: selected
                              ? Colors.white
                              : AppColors.sidebarText)),
                  selected: selected,
                  selectedTileColor: AppColors.sidebarSelected,
                  onTap: () {
                    onItemTap(i);
                    context.go(route);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
