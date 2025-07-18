import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/fournisseur.dart';
import '../../providers/fournisseurs_provider.dart';


class FournisseurForm extends ConsumerStatefulWidget {
  final Fournisseur? initial;
  const FournisseurForm({super.key, this.initial});

  @override
  ConsumerState<FournisseurForm> createState() => _FournisseurFormState();
}

class _FournisseurFormState extends ConsumerState<FournisseurForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _adresseController = TextEditingController();
  final _soldeController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _nomController.text = widget.initial!.nom;
      _telephoneController.text = widget.initial!.telephone;
      _emailController.text = widget.initial!.email ?? '';
      _adresseController.text = widget.initial!.adresse;
      _soldeController.text = widget.initial!.solde.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _adresseController.dispose();
    _soldeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Nouveau fournisseur' : 'Modifier fournisseur'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom*'),
                validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telephoneController,
                decoration: const InputDecoration(labelText: 'Téléphone*'),
                keyboardType: TextInputType.phone,
                validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _adresseController,
                decoration: const InputDecoration(labelText: 'Adresse*'),
                validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _soldeController,
                decoration: const InputDecoration(labelText: 'Solde initial*'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
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
    try {
      final request = FournisseurRequest(
        nom: _nomController.text,
        telephone: _telephoneController.text,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        adresse: _adresseController.text,
        solde: double.tryParse(_soldeController.text) ?? 0,
      );

      final notifier = ref.read(fournisseursProvider.notifier);
      
      if (widget.initial == null) {
        await notifier.create(request);
      } else {
        await notifier.updateItem(widget.initial!.id, request);
      }

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