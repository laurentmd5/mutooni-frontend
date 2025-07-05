import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/rapport.dart';
import '../../providers/rapports_provider.dart';

class RapportForm extends ConsumerStatefulWidget {
  final Rapport? initial;
  const RapportForm({super.key, this.initial});

  @override
  ConsumerState<RapportForm> createState() => _RapportFormState();
}

class _RapportFormState extends ConsumerState<RapportForm> {
  final _formKey = GlobalKey<FormState>();
  late final _titreCtrl = TextEditingController(text: widget.initial?.titre);
  late final _contenuCtrl = TextEditingController(text: widget.initial?.contenu);

  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Nouveau rapport' : 'Modifier rapport'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titreCtrl,
                decoration: const InputDecoration(labelText: 'Titre*'),
                validator: (v) => (v == null || v.isEmpty) ? 'Obligatoire' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contenuCtrl,
                decoration: const InputDecoration(labelText: 'Contenu*'),
                maxLines: 5,
                validator: (v) => (v == null || v.isEmpty) ? 'Obligatoire' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Annuler')),
        ElevatedButton(
          onPressed: _saving ? null : _submit,
          child: _saving ? const CircularProgressIndicator() : const Text('Enregistrer'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final rapport = Rapport(
      id: widget.initial?.id ?? '',
      titre: _titreCtrl.text,
      contenu: _contenuCtrl.text,
      dateCreation: widget.initial?.dateCreation ?? DateTime.now(),
      auteur: 'Admin', // À remplacer par l'utilisateur connecté
    );
    await ref.read(rapportsProvider.notifier).save(rapport, isEdit: widget.initial != null);
    if (mounted) Navigator.pop(context);
  }
}