import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/produit_request.dart';
import '../../providers/produits_provider.dart';

class ProduitForm extends ConsumerStatefulWidget {
  final void Function()? onSaved;
  const ProduitForm({super.key, this.onSaved});

  @override
  ConsumerState<ProduitForm> createState() => _ProduitFormState();
}

class _ProduitFormState extends ConsumerState<ProduitForm> {
  final _formKey = GlobalKey<FormState>();
  int? categorieId;
  String? nom;
  String? unite;
  String? prixUnitaire;
  int? seuilMin;
  int? stockActuel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Créer un produit'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nom'),
                onSaved: (val) => nom = val,
                validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Unité'),
                onSaved: (val) => unite = val,
                validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Prix unitaire'),
                keyboardType: TextInputType.number,
                onSaved: (val) => prixUnitaire = val,
                validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Seuil min'),
                keyboardType: TextInputType.number,
                onSaved: (val) => seuilMin = int.tryParse(val ?? ''),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Stock actuel'),
                keyboardType: TextInputType.number,
                onSaved: (val) => stockActuel = int.tryParse(val ?? ''),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              _formKey.currentState?.save();
              if (categorieId == null) return;
              final req = ProduitRequest(
                categorieId: categorieId!,
                nom: nom!,
                unite: unite!,
                prixUnitaire: prixUnitaire!,
                seuilMin: seuilMin,
                stockActuel: stockActuel,
              );
              await ref.read(produitsProvider.notifier).add(req);
              widget.onSaved?.call();
              if (mounted) Navigator.pop(context);
            }
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
