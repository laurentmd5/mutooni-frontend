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
  List<Client> _clients = [];
  List<Produit> _produits = [];

  @override
  void initState() {
    super.initState();
    _loadClientsEtProduits();
  }

  Future<void> _loadClientsEtProduits() async {
    final cRes = await apiService.client.get(Constants.clients);
    final pRes = await apiService.client.get(Constants.produits);
    if (!mounted) return;
    setState(() {
      _clients = (cRes.data as List).map((e) => Client.fromJson(e)).toList();
      _produits = (pRes.data as List).map((e) => Produit.fromJson(e)).toList();
    });
  }

  double get _total => _lignes.fold<double>(
        0,
        (double sum, LigneVenteRequest l) => sum +
            (double.parse(l.quantite) * double.parse(l.prixUnitaire)) -
            double.parse(l.remise),
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvelle vente'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Client',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                value: _clientId,
                items: _clients
                    .map((c) => DropdownMenuItem<int>(
                          value: c.id,
                          child: Text(c.nom),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _clientId = val),
                validator: (v) => v == null ? 'Client requis' : null,
                isExpanded: true,
              ),
              const SizedBox(height: 16),
              ..._lignes
                  .asMap()
                  .entries
                  .map((entry) => _buildLigne(entry.key, entry.value)),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _addLigne,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter ligne'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Montant payé',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => _montantPaye = double.tryParse(v) ?? 0,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Mode de paiement',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  textAlign: TextAlign.center,
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
              : const Text('Valider'),
        ),
      ],
    );
  }

  Widget _buildLigne(int index, LigneVenteRequest ligne) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Produit',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: ligne.produitId,
              items: _produits
                  .map((p) => DropdownMenuItem<int>(
                        value: p.id,
                        child: Text(p.nom),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => ligne.produitId = val!),
              isExpanded: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: ligne.quantite,
                    decoration: const InputDecoration(
                      labelText: 'Quantité',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => ligne.quantite = v,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: ligne.prixUnitaire,
                    decoration: const InputDecoration(
                      labelText: 'Prix unitaire',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
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
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              keyboardType: TextInputType.number,
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
        produitId: _produits.first.id,
        quantite: "1.00",
        prixUnitaire: "0.00",
        remise: "0.00",
        vente: 1,
      ));
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_lignes.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins une ligne.')),
      );
      return;
    }

    final req = VenteRequest(
      clientId: _clientId!,
      lignes: _lignes,
      total: _total.toStringAsFixed(2),
      montantPaye: _montantPaye.toStringAsFixed(2),
      modePaiement: _modePaiement,
      statut: _statut,
    );

    setState(() => _saving = true);
    await ref.read(ventesProvider.notifier).create(req);
    if (!mounted) return;
    Navigator.pop(context);
  }
}