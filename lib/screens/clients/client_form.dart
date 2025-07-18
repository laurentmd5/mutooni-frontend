import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/client.dart';
import '../../providers/client_provider.dart';

class ClientForm extends ConsumerStatefulWidget {
  final Client? initial;
  const ClientForm({super.key, this.initial});

  @override
  ConsumerState<ClientForm> createState() => _ClientFormState();
}

class _ClientFormState extends ConsumerState<ClientForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nomCtrl = TextEditingController(text: widget.initial?.nom);
  late final _emailCtrl = TextEditingController(text: widget.initial?.email);
  late final _telCtrl = TextEditingController(text: widget.initial?.telephone);
  late final _adresseCtrl = TextEditingController(text: widget.initial?.adresse);
  late final _soldeCtrl = TextEditingController(text: widget.initial?.solde ?? '0.00');
  bool _saving = false;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _emailCtrl.dispose();
    _telCtrl.dispose();
    _adresseCtrl.dispose();
    _soldeCtrl.dispose();
    super.dispose();
  }

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
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Nom obligatoire';
                    if (v.length > 120) return 'Max 120 caractères';
                    return null;
                  },
                  maxLength: 120,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  maxLength: 254,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telCtrl,
                  decoration: const InputDecoration(labelText: 'Téléphone'),
                  maxLength: 30,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _adresseCtrl,
                  decoration: const InputDecoration(labelText: 'Adresse'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _soldeCtrl,
                  decoration: const InputDecoration(labelText: 'Solde initial'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    if (!RegExp(r'^-?\d{0,10}(?:\.\d{0,2})?$').hasMatch(v)) {
                      return 'Format invalide (ex: 123.45)';
                    }
                    return null;
                  },
                ),
              ],
            ),
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

    final cli = Client(
      id: widget.initial?.id ?? 0,
      nom: _nomCtrl.text.trim(),
      email: _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : null,
      telephone: _telCtrl.text.trim().isNotEmpty ? _telCtrl.text.trim() : null,
      adresse: _adresseCtrl.text.trim().isNotEmpty ? _adresseCtrl.text.trim() : null,
      solde: _soldeCtrl.text.trim(),
    );

    try {
      await ref.read(clientProvider.notifier).save(cli, 
        isEdit: widget.initial != null,
        context: context,
      );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}