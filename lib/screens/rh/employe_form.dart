import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/employe.dart';
import '../../providers/rh_provider.dart';

class EmployeForm extends ConsumerStatefulWidget {
  final Employe? initial;
  const EmployeForm({super.key, this.initial});

  @override
  ConsumerState<EmployeForm> createState() => _EmployeFormState();
}

class _EmployeFormState extends ConsumerState<EmployeForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nomCtrl = TextEditingController(text: widget.initial?.nom);
  late final _posteCtrl = TextEditingController(text: widget.initial?.poste);
  late final _emailCtrl = TextEditingController(text: widget.initial?.email);
  late final _salaireCtrl = TextEditingController(text: widget.initial?.salaire.toString());
  late DateTime _dateEmbauche = widget.initial?.dateEmbauche ?? DateTime.now();

  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Nouvel employé' : 'Modifier employé'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomCtrl,
                decoration: const InputDecoration(labelText: 'Nom complet*'),
                validator: (v) => (v == null || v.isEmpty) ? 'Obligatoire' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _posteCtrl,
                decoration: const InputDecoration(labelText: 'Poste*'),
                validator: (v) => (v == null || v.isEmpty) ? 'Obligatoire' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _salaireCtrl,
                decoration: const InputDecoration(labelText: 'Salaire (CFA)*'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || double.tryParse(v) == null) ? 'Invalide' : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Date d\'embauche'),
                subtitle: Text('${_dateEmbauche.day}/${_dateEmbauche.month}/${_dateEmbauche.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dateEmbauche,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _dateEmbauche = picked);
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

    final employe = Employe(
      id: widget.initial?.id ?? '',
      nom: _nomCtrl.text,
      poste: _posteCtrl.text,
      email: _emailCtrl.text,
      salaire: double.parse(_salaireCtrl.text),
      dateEmbauche: _dateEmbauche,
    );
    await ref.read(rhProvider.notifier).save(employe, isEdit: widget.initial != null);
    if (mounted) Navigator.pop(context);
  }
}