import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/client.dart';
import '../../providers/client_provider.dart';

class ClientForm extends ConsumerStatefulWidget {
  final Client? initial;   // null = création, non‑null = édition
  const ClientForm({super.key, this.initial});

  @override
  ConsumerState<ClientForm> createState() => _ClientFormState();
}

class _ClientFormState extends ConsumerState<ClientForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nomCtrl        = TextEditingController(text: widget.initial?.nom);
  late final _emailCtrl      = TextEditingController(text: widget.initial?.email);
  late final _telCtrl        = TextEditingController(text: widget.initial?.telephone);
  late final _adresseCtrl    = TextEditingController(text: widget.initial?.adresse);

  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Nouveau client' : 'Modifier client'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nomCtrl,
                  decoration: const InputDecoration(labelText: 'Nom*'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nom obligatoire' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telCtrl,
                  decoration: const InputDecoration(labelText: 'Téléphone'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _adresseCtrl,
                  decoration: const InputDecoration(labelText: 'Adresse'),
                ),
              ],
            ),
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

    final cli = Client(
      id: widget.initial?.id ?? '',
      nom: _nomCtrl.text,
      email: _emailCtrl.text,
      telephone: _telCtrl.text,
      adresse: _adresseCtrl.text,
      dateInscription: widget.initial?.dateInscription ?? DateTime.now(),
    );
    await ref.read(clientProvider.notifier).save(cli, isEdit: widget.initial != null);
    if (mounted) Navigator.pop(context);
  }
}
