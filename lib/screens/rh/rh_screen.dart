import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/rh_provider.dart';
import '../../widgets/main_layout.dart';
import 'employe_form.dart';
import 'salaires_screen.dart';

class RhScreen extends ConsumerStatefulWidget {
  const RhScreen({super.key});

  @override
  ConsumerState<RhScreen> createState() => _RhScreenState();
}

class _RhScreenState extends ConsumerState<RhScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final employes = ref.watch(rhProvider(_search));
    return MainLayout(
      selectedIndex: 5,
      title: 'Ressources Humaines',
      onItemTap: (i) {},
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const EmployeForm(),
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Recherche',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: employes.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erreur: $e')),
                data: (list) => ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, i) {
                    final e = list[i];
                    return ListTile(
                      title: Text(e.nom),
                      subtitle: Text(e.poste),
                      trailing: Wrap(
                        spacing: 12,
                        children: [
                          Text('${e.salaireBase} CFA'),
                          IconButton(
                            icon: const Icon(Icons.payments),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SalairesScreen(
                                  employeId: int.parse(e.id),
                                  employeNom: e.nom,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => EmployeForm(initial: e),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}