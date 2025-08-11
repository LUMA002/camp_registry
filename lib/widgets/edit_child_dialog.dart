import 'package:flutter/material.dart';
import 'package:camp_registry/data/child.dart';

class EditChildDialog extends StatefulWidget {
  final Child child;
  const EditChildDialog({super.key, required this.child});

  @override
  State<EditChildDialog> createState() => _EditChildDialogState();
}

class _EditChildDialogState extends State<EditChildDialog> {
  late TextEditingController fullNameController;
  late TextEditingController ageController;
  String? _fullNameError;
  String? _ageError;

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController(text: widget.child.fullName);
    ageController = TextEditingController(text: widget.child.age.toString());
  }

  @override
  void dispose() {
    fullNameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  void _validateAndSave() {
    setState(() {
      _fullNameError = null;
      _ageError = null;
    });

    final fullName = fullNameController.text.trim();
    final nameRegExp = RegExp(r"^[a-zA-Zа-яА-ЯёЁіІїЇєЄґҐ''\-()\s]+$");
    final ageText = ageController.text.trim();

    if (fullName.isEmpty || fullName.split(' ').length < 2) {
      setState(() => _fullNameError = 'Введіть прізвище та ім\'я');
      return;
    }
    if (!nameRegExp.hasMatch(fullName)) {
      setState(
        () => _fullNameError =
            'ПІБ може містити тільки літери, пробіли, дефіси, апострофи, круглі дужки',
      );
      return;
    }

    final age = int.tryParse(ageText);
    if (age == null || age < 3 || age > 99) {
      setState(() => _ageError = 'Вік має бути числом від 3 до 99');
      return;
    }

    Navigator.of(context).pop({'fullName': fullName, 'age': age});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.edit_note,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text('Редагувати дитину'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: fullNameController,
            decoration: InputDecoration(
              labelText: 'ПІБ дитини',
              errorText: _fullNameError,
              prefixIcon: const Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: ageController,
            decoration: InputDecoration(
              labelText: 'Вік',
              errorText: _ageError,
              prefixIcon: const Icon(Icons.cake),
            ),
            keyboardType: TextInputType.number,
            maxLength: 2,
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.cancel),
          label: const Text('Скасувати'),
        ),
        ElevatedButton.icon(
          onPressed: _validateAndSave,
          icon: const Icon(Icons.save),
          label: const Text('Зберегти'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}
