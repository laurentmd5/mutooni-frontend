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

  late TextEditingController _nomCtrl;
  late TextEditingController _posteCtrl;
  late TextEditingController _salaireCtrl;
  late DateTime _dateEmbauche;
  late bool _actif;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nomCtrl = TextEditingController(text: widget.initial?.nom ?? '');
    _posteCtrl = TextEditingController(text: widget.initial?.poste ?? '');
    _salaireCtrl = TextEditingController(text: widget.initial?.salaireBase ?? '');
    _dateEmbauche = widget.initial?.dateEmbauche ?? DateTime.now();
    _actif = widget.initial?.actif ?? true;
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _posteCtrl.dispose();
    _salaireCtrl.dispose();
    super.dispose();
  }

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
                controller: _salaireCtrl,
                decoration: const InputDecoration(labelText: 'Salaire de base (CFA)*'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final value = double.tryParse(v ?? '');
                  return (value == null || value < 0) ? 'Salaire invalide' : null;
                },
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
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _dateEmbauche = picked);
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Actif'),
                value: _actif,
                onChanged: (v) => setState(() => _actif = v),
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
      salaireBase: _salaireCtrl.text,
      dateEmbauche: _dateEmbauche,
      actif: _actif,
    );

    await ref.read(rhControllerProvider.notifier).save(employe, isEdit: widget.initial != null);
    if (mounted) Navigator.pop(context);
  }
}
