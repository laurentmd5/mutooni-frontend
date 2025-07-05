import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mutooni_frontend/widgets/side_menu.dart';
import 'package:mutooni_frontend/providers/dashboard_provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardProvider()..fetchStats(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final dp = context.watch<DashboardProvider>();

    return Scaffold(
      drawer: isDesktop ? null : Drawer(child: SideMenu(selectedIndex: _selected, onItemTap: _onTap)),
      body: Row(
        children: [
          if (isDesktop) SideMenu(selectedIndex: _selected, onItemTap: _onTap),
          Expanded(
            child: dp.loading
                ? const Center(child: CircularProgressIndicator())
                : _body(context, dp),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, DashboardProvider dp) {
    final stats = dp.stats;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tableau de Bord', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _statCard(Icons.point_of_sale, 'Ventes',  stats?.totalVente ?? 0, 'Ce mois‑ci'),
              _statCard(Icons.shopping_bag, 'Achats',   stats?.totalAchat ?? 0, 'Ce mois‑ci'),
              _statCard(Icons.inventory,    'Stocks',   stats?.totalStock ?? 0, 'Articles'),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _chartPlaceholder()),
                const SizedBox(width: 16),
                Expanded(child: _chartPlaceholder()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String title, num value, String subtitle) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: Theme.of(context).primaryColor),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('$value',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  /// Placeholder chart (démo)
  Widget _chartPlaceholder() {
    final bars = List.generate(
      6,
      (i) => BarChartGroupData(x: i, barRods: [BarChartRodData(toY: (i + 4).toDouble(), width: 18)]),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            barGroups: bars,
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(show: false),
          ),
        ),
      ),
    );
  }

  void _onTap(int i) => setState(() => _selected = i);
}
