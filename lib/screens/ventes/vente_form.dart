import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/vente.dart';
import '../../providers/ventes_provider.dart';
import '../../models/client.dart';
import '../../models/produit.dart';
import '../../core/constants.dart';
import '../../core/api_service.dart';

class VenteForm extends ConsumerStatefulWidget {
  final Vente? initial;
  const VenteForm({super.key, this.initial});

  @override
  ConsumerState<VenteForm> createState() => _VenteFormState();
}

class _VenteFormState extends ConsumerState<VenteForm> {
  final _formKey = GlobalKey<FormState>();
  int? _clientId;
  final List<LigneVenteRequest> _lignes = [];
  double _montantPaye = 0;
  String _modePaiement = "espèces";
  VenteStatut _statut = VenteStatut.enCours;
  bool _saving = false;
  bool _loading = true;
  String? _error;
  List<Client> _clients = [];
  List<Produit> _produits = [];

  @override
  void initState() {
    super.initState();
    _loadClientsEtProduits();
    if (widget.initial != null) {
      _initFormWithVente(widget.initial!);
    }
  }

  Future<void> _loadClientsEtProduits() async {
    try {
      final cRes = await apiService.client.get(Constants.clients);
      final pRes = await apiService.client.get(Constants.produits);
      
      if (!mounted) return;
      
      setState(() {
        _clients = (cRes.data as List).map((e) => Client.fromJson(e)).toList();
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

  void _initFormWithVente(Vente vente) {
    setState(() {
      _clientId = _clients.firstWhere((c) => c.nom == vente.client).id;
      _lignes.addAll(vente.lignes.map((l) => LigneVenteRequest(
            produitId: _produits.firstWhere((p) => p.nom == l.produit).id,
            quantite: l.quantite,
            prixUnitaire: l.prixUnitaire,
            remise: l.remise,
            vente: l.vente,
          )));
      _montantPaye = vente.montantPaye;
      _modePaiement = vente.modePaiement;
      _statut = vente.statut;
    });
  }

  double get _total => _lignes.fold<double>(
        0,
        (sum, l) => sum +
            (double.tryParse(l.quantite) ?? 0) * 
            (double.tryParse(l.prixUnitaire) ?? 0) -
            (double.tryParse(l.remise) ?? 0),
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
      title: Text(widget.initial == null ? 'Nouvelle vente' : 'Modifier vente'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Client*',
                  border: OutlineInputBorder(),
                ),
                value: _clientId,
                items: _clients
                    .map((c) => DropdownMenuItem<int>(
                          value: c.id,
                          child: Text(c.nom),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _clientId = val),
                validator: (v) => v == null ? 'Sélectionnez un client' : null,
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
                decoration: const InputDecoration(
                  labelText: 'Montant payé',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                initialValue: _montantPaye.toStringAsFixed(2),
                validator: (v) => v == null || double.tryParse(v) == null
                    ? 'Montant invalide'
                    : null,
                onChanged: (v) => _montantPaye = double.tryParse(v) ?? 0,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Mode de paiement',
                  border: OutlineInputBorder(),
                ),
                value: _modePaiement,
                items: const [
                  DropdownMenuItem(value: "espèces", child: Text("Espèces")),
                  DropdownMenuItem(value: "carte", child: Text("Carte")),
                  DropdownMenuItem(value: "chèque", child: Text("Chèque")),
                  DropdownMenuItem(value: "virement", child: Text("Virement")),
                ],
                onChanged: (val) => setState(() => _modePaiement = val!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<VenteStatut>(
                decoration: const InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(),
                ),
                value: _statut,
                items: VenteStatut.values
                    .map((s) => DropdownMenuItem<VenteStatut>(
                          value: s,
                          child: Text(s.name),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _statut = val!),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Total: ${_total.toStringAsFixed(2)} CFA',
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

  Widget _buildLigne(int index, LigneVenteRequest ligne) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Produit*',
                border: OutlineInputBorder(),
              ),
              value: ligne.produitId,
              items: _produits
                  .map((p) => DropdownMenuItem<int>(
                        value: p.id,
                        child: Text(p.nom),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => ligne.produitId = val!),
              validator: (v) => v == null ? 'Sélectionnez un produit' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: ligne.quantite,
                    decoration: const InputDecoration(
                      labelText: 'Quantité*',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || double.tryParse(v) == null
                        ? 'Quantité invalide'
                        : null,
                    onChanged: (v) => ligne.quantite = v,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: ligne.prixUnitaire,
                    decoration: const InputDecoration(
                      labelText: 'Prix unitaire*',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || double.tryParse(v) == null
                        ? 'Prix invalide'
                        : null,
                    onChanged: (v) => ligne.prixUnitaire = v,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: ligne.remise,
              decoration: const InputDecoration(
                labelText: 'Remise',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v != null && double.tryParse(v) == null
                  ? 'Montant invalide'
                  : null,
              onChanged: (v) => ligne.remise = v,
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
      _lignes.add(LigneVenteRequest(
        produitId: _produits.isNotEmpty ? _produits.first.id : 0,
        quantite: "1",
        prixUnitaire: "0",
        remise: "0",
        vente: 0,
      ));
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_clientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez un client')),
      );
      return;
    }
    if (_lignes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins une ligne')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final req = VenteRequest(
        clientId: _clientId!,
        lignes: _lignes,
        total: _total.toStringAsFixed(2),
        montantPaye: _montantPaye.toStringAsFixed(2),
        modePaiement: _modePaiement,
        statut: _statut,
      );

      if (widget.initial == null) {
        await ref.read(ventesProvider.notifier).create(req);
      } else {
        await ref.read(ventesProvider.notifier)
          .updateVente(widget.initial!.id, req);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}