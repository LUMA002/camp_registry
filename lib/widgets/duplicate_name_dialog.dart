import 'package:flutter/material.dart';

class DuplicateNameDialog extends StatefulWidget {
  final String existingFullName;
  final int existingAge;
  final int newAge;

  const DuplicateNameDialog({
    super.key,
    required this.existingFullName,
    required this.existingAge,
    required this.newAge,
  });

  @override
  State<DuplicateNameDialog> createState() => _DuplicateNameDialogState();
}

class _DuplicateNameDialogState extends State<DuplicateNameDialog> {
  final TextEditingController additionalInfoController =
      TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    additionalInfoController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final additionalInfo = additionalInfoController.text.trim();
    final nameRegExp = RegExp(r"^[a-zA-Zа-яА-ЯёЁіІїЇєЄґҐ''\-()\s]+$");

    if (additionalInfo.isEmpty) {
      setState(() => _errorText = 'Поле не може бути порожнім');
      return;
    }

    if (!nameRegExp.hasMatch(additionalInfo)) {
      setState(
        () => _errorText =
            'Можна використовувати лише літери, пробіли, дефіси, апострофи та круглі дужки',
      );
      return;
    }

    // Повертаємо уточнене ПІБ
    final updatedFullName =
        '${widget.existingFullName} (${additionalInfo.trim()})';
    Navigator.of(context).pop(updatedFullName);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.error,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text('Дублікат імені'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'У базі вже є особа з таким ПІБ:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: .3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.existingFullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text('Вік: ${widget.existingAge}'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ви вказали вік: ${widget.newAge}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Додайте уточнення для ідентифікації цієї особи:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Наприклад: по-батькові, прізвисько або уточнення',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: additionalInfoController,
            decoration: InputDecoration(
              labelText: 'Уточнення',
              errorText: _errorText,
              prefixIcon: const Icon(Icons.edit),
              hintText: 'Наприклад: "Михайлович" або "молодший"',
            ),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: () => Navigator.of(context).pop(null),
          icon: const Icon(Icons.cancel),
          label: const Text('Скасувати'),
        ),
        ElevatedButton.icon(
          onPressed: _validateAndSubmit,
          icon: const Icon(Icons.check_circle),
          label: const Text('Додати з уточненням'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}
