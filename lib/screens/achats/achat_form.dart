import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/achats_provider.dart';
import '../../models/achat.dart';
import '../../models/fournisseur.dart';
import '../../models/produit.dart';
import '../../core/api_service.dart';


class AchatForm extends ConsumerStatefulWidget {
  const AchatForm({super.key});

  @override
  ConsumerState<AchatForm> createState() => _AchatFormState();
}

class _AchatFormState extends ConsumerState<AchatForm> {
  final _formKey = GlobalKey<FormState>();
  int? _fournisseurId;
  final List<LigneAchatRequest> _lignes = [];
  double _montantPaye = 0;
  AchatStatut _statut = AchatStatut.EN_ATTENTE;
  bool _saving = false;
  bool _loading = true;
  String? _error;
  List<Fournisseur> _fournisseurs = [];
  List<Produit> _produits = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final fRes = await apiService.client.get('/fournisseurs/');
      final pRes = await apiService.client.get('/produits/');
      
      if (!mounted) return;
      
      setState(() {
        _fournisseurs = (fRes.data as List).map((e) => Fournisseur.fromJson(e)).toList();
        _produits = (pRes.data as List).map((e) => Produit.fromJson(e)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur de chargement: ${e.toString()}';
        _loading = false;
      });
    }
  }

  double get _calculatedTotal => _lignes.fold<double>(
    0,
    (sum, l) => sum + (l.quantite * l.prixUnitaire),
  );

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AlertDialog(
        content: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return AlertDialog(
        title: const Text('Erreur'),
        content: Text(_error!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('Nouvel achat'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Fournisseur*'),
                value: _fournisseurId,
                items: _fournisseurs
                    .map((f) => DropdownMenuItem(
                          value: f.id,
                          child: Text(f.nom),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _fournisseurId = v),
                validator: (v) => v == null ? 'Sélectionnez un fournisseur' : null,
              ),
              const SizedBox(height: 16),
              ..._lignes.asMap().entries.map((e) => _buildLigne(e.key, e.value)),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _addLigne,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter ligne'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Montant payé'),
                keyboardType: TextInputType.number,
                onChanged: (v) => _montantPaye = double.tryParse(v) ?? 0,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AchatStatut>(
                value: _statut,
                decoration: const InputDecoration(labelText: 'Statut'),
                items: AchatStatut.values
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _statut = v!),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Total: ${_calculatedTotal.toStringAsFixed(2)} CFA',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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

  Widget _buildLigne(int index, LigneAchatRequest ligne) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Produit*'),
              value: ligne.produitId,
              items: _produits
                  .map((p) => DropdownMenuItem(
                        value: p.id,
                        child: Text(p.nom),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => ligne.produitId = v!),
              validator: (v) => v == null ? 'Sélectionnez un produit' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: ligne.quantite.toStringAsFixed(2),
                    decoration: const InputDecoration(labelText: 'Quantité*'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || double.tryParse(v) == null
                        ? 'Quantité invalide'
                        : null,
                    onChanged: (v) => ligne.quantite = double.tryParse(v) ?? 0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: ligne.prixUnitaire.toStringAsFixed(2),
                    decoration: const InputDecoration(labelText: 'Prix unitaire*'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || double.tryParse(v) == null
                        ? 'Prix invalide'
                        : null,
                    onChanged: (v) => ligne.prixUnitaire = double.tryParse(v) ?? 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => setState(() => _lignes.removeAt(index)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addLigne() {
    setState(() {
      _lignes.add(LigneAchatRequest(
        produitId: _produits.isNotEmpty ? _produits.first.id : 0,
        quantite: 1,
        prixUnitaire: 0,
        achat: 0,
      ));
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fournisseurId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sélectionnez un fournisseur')),
        );
      }
      return;
    }
    if (_lignes.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ajoutez au moins une ligne')),
        );
      }
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(achatsProvider.notifier).create(
        fournisseurId: _fournisseurId!,
        lignes: _lignes,
        total: _calculatedTotal,
        montantPaye: _montantPaye,
        statut: _statut,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}