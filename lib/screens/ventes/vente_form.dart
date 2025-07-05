import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/vente.dart';
import '../../providers/ventes_provider.dart';

class VenteForm extends ConsumerStatefulWidget {
  final Vente? initial;
  const VenteForm({super.key, this.initial});

  @override
  ConsumerState<VenteForm> createState() => _VenteFormState();
}

class _VenteFormState extends ConsumerState<VenteForm> {
  final _formKey = GlobalKey<FormState>();
  late final _montantCtrl = TextEditingController(text: widget.initial?.montant.toString());
  late DateTime _date = widget.initial?.date ?? DateTime.now();

  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Nouvelle vente' : 'Modifier vente'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _montantCtrl,
                decoration: const InputDecoration(labelText: 'Montant (CFA)*'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || double.tryParse(v) == null) ? 'Montant invalide' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text('${_date.day}/${_date.month}/${_date.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
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

    final vente = Vente(
      id: widget.initial?.id ?? '',
      montant: double.parse(_montantCtrl.text),
      date: _date,
    );
    await ref.read(ventesProvider.notifier).save(vente, isEdit: widget.initial != null);
    if (mounted) Navigator.pop(context);
  }
}