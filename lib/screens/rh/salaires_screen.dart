import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/salaire_provider.dart';

class SalairesScreen extends ConsumerWidget {
  final int employeId;
  final String employeNom;

  const SalairesScreen({super.key, required this.employeId, required this.employeNom});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salaires = ref.watch(salairesProvider(employeId));

    return Scaffold(
      appBar: AppBar(title: Text('Salaires: $employeNom')),
      body: salaires.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur: $err')),
        data: (list) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) {
            final s = list[i];
            return ListTile(
              title: Text('Période: ${s.periode}'),
              subtitle: Text('Brut: ${s.brut} | Net: ${s.net}'),
              trailing: Text('${s.montantPaye} CFA'),
            );
          },
        ),
      ),
    );
  }
}