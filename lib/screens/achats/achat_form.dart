import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/achats_provider.dart';
import '../../models/achat.dart';

class AchatForm extends ConsumerStatefulWidget {
  const AchatForm({super.key});

  @override
  ConsumerState<AchatForm> createState() => _AchatFormState();
}

class _AchatFormState extends ConsumerState<AchatForm> {
  final _formKey = GlobalKey<FormState>();
  final _fournisseurCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  final _payeCtrl = TextEditingController();
  AchatStatut _statut = AchatStatut.EN_ATTENTE;

  bool _saving = false;

  @override
  void dispose() {
    _fournisseurCtrl.dispose();
    _totalCtrl.dispose();
    _payeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvel achat'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /* Fournisseur */
              TextFormField(
                controller: _fournisseurCtrl,
                decoration: const InputDecoration(labelText: 'ID fournisseur*'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || int.tryParse(v) == null ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              /* Total */
              TextFormField(
                controller: _totalCtrl,
                decoration: const InputDecoration(labelText: 'Total*'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || double.tryParse(v) == null
                    ? 'Requis'
                    : null,
              ),
              const SizedBox(height: 16),
              /* Montant payé */
              TextFormField(
                controller: _payeCtrl,
                decoration: const InputDecoration(labelText: 'Montant payé'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              /* Statut */
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
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator())
              : const Text('Enregistrer'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      await ref.read(achatsProvider.notifier).create(
            fournisseurId: int.parse(_fournisseurCtrl.text),
            lignes: const [], // à ajouter si tu gères une table de lignes
            total: double.parse(_totalCtrl.text),
            montantPaye: _payeCtrl.text.isEmpty
                ? 0
                : double.parse(_payeCtrl.text),
            statut: _statut,
          );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
