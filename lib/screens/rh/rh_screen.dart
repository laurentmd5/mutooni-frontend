import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mutooni_frontend/widgets/main_layout.dart';
import 'package:mutooni_frontend/providers/rh_provider.dart';
//import 'package:mutooni_frontend/models/employe.dart';
import 'employe_form.dart';
import 'package:go_router/go_router.dart';


class RhScreen extends ConsumerWidget {
  const RhScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employes = ref.watch(rhProvider);
    final selectedIndex = 4; // RH est à l'index 4

    return MainLayout(
      selectedIndex: selectedIndex,
      onItemTap: (i) => _navigate(context, i),
      title: 'Ressources Humaines',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const EmployeForm(),
          ),
        ),
      ],
      child: employes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur: $err')),
        data: (employes) => ListView.separated(
          itemCount: employes.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) {
            final e = employes[i];
            return ListTile(
              title: Text(e.nom),
              subtitle: Text(e.poste),
              trailing: Text('${e.salaire} CFA'),
              onTap: () => showDialog(
                context: context,
                builder: (_) => EmployeForm(initial: e),
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigate(BuildContext context, int index) {
    final routes = ['/', '/ventes', '/achats', '/clients', '/rapports', '/settings'];
    context.go(routes[index]);
  }
}