import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/produit.dart'; // Import ajouté
import '../../models/produit_request.dart';
import '../../models/categorie_produit.dart'; // Import ajouté
import '../../providers/produits_provider.dart';

class ProduitForm extends ConsumerStatefulWidget {
  final Produit? initial;
  const ProduitForm({super.key, this.initial});

  @override
  ConsumerState<ProduitForm> createState() => _ProduitFormState();
}

class _ProduitFormState extends ConsumerState<ProduitForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nomCtrl = TextEditingController(text: widget.initial?.nom);
  late final _uniteCtrl = TextEditingController(text: widget.initial?.unite);
  late final _prixCtrl = TextEditingController(text: widget.initial?.prixUnitaire);
  late final _seuilCtrl = TextEditingController(text: widget.initial?.seuilMin.toString());
  late final _stockCtrl = TextEditingController(text: widget.initial?.stockActuel.toString());
  int? _categorieId;
  bool _saving = false;

  Future<List<CategorieProduit>> _fetchCategories() async {
    // Implémentez cette méthode pour récupérer les catégories
    // depuis votre API ou provider
    return [];
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _uniteCtrl.dispose();
    _prixCtrl.dispose();
    _seuilCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Nouveau produit' : 'Modifier produit'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder<List<CategorieProduit>>(
                future: _fetchCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Erreur: ${snapshot.error}');
                  }
                  final categories = snapshot.data ?? [];
                  return DropdownButtonFormField<int>(
                    value: _categorieId ?? widget.initial?.categorie.id,
                    decoration: const InputDecoration(labelText: 'Catégorie*'),
                    items: categories.map((categorie) {
                      return DropdownMenuItem<int>(
                        value: categorie.id,
                        child: Text(categorie.nom),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _categorieId = value),
                    validator: (value) => value == null ? 'Champ obligatoire' : null,
                  );
                },
              ),
              TextFormField(
                controller: _nomCtrl,
                decoration: const InputDecoration(labelText: 'Nom*'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Champ obligatoire';
                  if (v.length > 150) return 'Max 150 caractères';
                  return null;
                },
                maxLength: 150,
              ),
              TextFormField(
                controller: _uniteCtrl,
                decoration: const InputDecoration(labelText: 'Unité*'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Champ obligatoire';
                  if (v.length > 20) return 'Max 20 caractères';
                  return null;
                },
                maxLength: 20,
              ),
              TextFormField(
                controller: _prixCtrl,
                decoration: const InputDecoration(labelText: 'Prix unitaire*'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Champ obligatoire';
                  if (!RegExp(r'^\d{0,8}(?:\.\d{0,2})?$').hasMatch(v)) {
                    return 'Format invalide (ex: 123.45)';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _seuilCtrl,
                decoration: const InputDecoration(labelText: 'Seuil minimum'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _stockCtrl,
                decoration: const InputDecoration(labelText: 'Stock actuel'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enregistrer'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final request = ProduitRequest(
      categorieId: _categorieId ?? widget.initial?.categorie.id ?? 0,
      nom: _nomCtrl.text.trim(),
      unite: _uniteCtrl.text.trim(),
      prixUnitaire: _prixCtrl.text.trim(),
      seuilMin: int.tryParse(_seuilCtrl.text),
      stockActuel: int.tryParse(_stockCtrl.text),
    );

    try {
      if (widget.initial == null) {
        await ref.read(produitsProvider.notifier).addProduit(request, context);
      } else {
        await ref.read(produitsProvider.notifier).updateProduit(
              widget.initial!.id,
              request,
              context,
            );
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}