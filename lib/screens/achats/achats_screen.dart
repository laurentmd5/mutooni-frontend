import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/achat.dart';
import '../../providers/achats_provider.dart';
import '../../widgets/main_layout.dart';
import 'achat_form.dart';
import 'fournisseurs_tab.dart';

class AchatsScreen extends ConsumerStatefulWidget {
  const AchatsScreen({super.key});

  @override
  ConsumerState<AchatsScreen> createState() => _AchatsScreenState();
}

class _AchatsScreenState extends ConsumerState<AchatsScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      selectedIndex: 2, // Position du menu Achats dans votre sidebar
      onItemTap: (i) => _navigate(context, i),
      title: 'Achats',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showAchatForm(context),
        ),
      ],
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Commandes'),
              Tab(text: 'Fournisseurs'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                AchatsListTab(),
                FournisseursTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAchatForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AchatForm(),
      barrierDismissible: false,
    );
  }

  void _navigate(BuildContext context, int index) {
    const routes = ['/', '/ventes', '/achats', '/clients', '/rh', '/rapports'];
    if (index < routes.length) context.go(routes[index]);
  }
}

class AchatsListTab extends ConsumerWidget {
  const AchatsListTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achatsAsync = ref.watch(achatsProvider);
    
    return achatsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Erreur: ${err.toString()}')),
      data: (achats) => _buildAchatsList(context, ref, achats),
    );
  }

  Widget _buildAchatsList(BuildContext context, WidgetRef ref, List<Achat> achats) {
    if (achats.isEmpty) {
      return const Center(child: Text('Aucun achat trouvé'));
    }

    return ListView.builder(
      itemCount: achats.length,
      itemBuilder: (context, index) {
        final achat = achats[index];
        return ListTile(
          title: Text(achat.fournisseur),
          subtitle: Text('${achat.total.toStringAsFixed(2)} CFA'),
          trailing: Text(achat.date.toString()),
        );
      },
    );
  }
}