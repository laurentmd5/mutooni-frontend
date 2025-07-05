import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/achat.dart';
import '../../providers/achats_provider.dart';

class AchatForm extends ConsumerStatefulWidget {
  final Achat? initial;
  const AchatForm({super.key, this.initial});

  @override
  ConsumerState<AchatForm> createState() => _AchatFormState();
}

class _AchatFormState extends ConsumerState<AchatForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _montantCtrl;
  late DateTime _date;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _montantCtrl = TextEditingController(text: widget.initial?.montant.toString() ?? '');
    _date = widget.initial?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _montantCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Nouvel achat' : 'Modifier achat'),
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
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Montant obligatoire';
                  if (double.tryParse(v) == null) return 'Montant invalide';
                  return null;
                },
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
                  if (picked != null && mounted) {
                    setState(() => _date = picked);
                  }
                },
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
              ? const CircularProgressIndicator() 
              : const Text('Enregistrer'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _saving = true);

    try {
      final achat = Achat(
        id: widget.initial?.id ?? '',
        montant: double.parse(_montantCtrl.text),
        date: _date,
      );
      
      await ref.read(achatsProvider.notifier).save(
        achat, 
        isEdit: widget.initial != null
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