import 'package:flutter/material.dart';
import 'package:camp_registry/app/theme.dart';
import 'package:camp_registry/data/database_helper.dart';
import 'package:camp_registry/data/child.dart';
import 'package:intl/intl.dart';
import 'dart:developer';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camp Registry',
      theme: AppTheme.theme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String today;
  List<Child> childrenToday = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    setState(() => isLoading = true);
    try {
      childrenToday = await DatabaseHelper.instance.getChildrenByDate(today);
      log('childrenToday: ${childrenToday.length}');
    } catch (e) {
      log('Error loading children: $e');
    }
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _addChild(String fullName, int age) async {
    // Додаємо|оновлюємо дитину
    await DatabaseHelper.instance.insertChild(
      Child(fullName: fullName, age: age),
    );
    final realChild = await DatabaseHelper.instance.getChildByFullName(
      fullName,
    );
    if (realChild == null) return;

    final alreadyPresent = await DatabaseHelper.instance
        .isChildAlreadyPresentToday(realChild.id!, today);
    if (alreadyPresent) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Дитина вже є у списку на сьогодні!')),
      );
      return;
    }

    await DatabaseHelper.instance.insertAttendance(realChild.id!, today);
    await _loadChildren();
  }

  Future<void> _removeChild(int childId) async {
    await DatabaseHelper.instance.deleteAttendance(childId, today);
    await _loadChildren();
  }

  Future<void> _editChild(Child child, String newFullName, int newAge) async {
    final updated = Child(id: child.id, fullName: newFullName, age: newAge);
    await DatabaseHelper.instance.updateChild(updated);
    await _loadChildren();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Реєстрація дітей'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Перехід на екран історії
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Add form
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _AddChildForm(onAdd: _addChild),
            ),
          ),
          // Список дітей
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _ChildrenList(
                      children: childrenToday,
                      onDelete: _removeChild,
                      onEdit: _editChild,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// Add form
class _AddChildForm extends StatefulWidget {
  final Future<void> Function(String, int) onAdd;
  const _AddChildForm({required this.onAdd});

  @override
  State<_AddChildForm> createState() => _AddChildFormState();
}

class _AddChildFormState extends State<_AddChildForm> {
  final fullNameController = TextEditingController();
  final ageController = TextEditingController();

  String? _fullNameError;
  String? _ageError;

  Future<void> _validateAndAdd() async {
    setState(() {
      _fullNameError = null;
      _ageError = null;
    });

    final fullName = fullNameController.text.trim();
    final ageText = ageController.text.trim();

    if (fullName.isEmpty || fullName.split(' ').length < 2) {
      setState(() => _fullNameError = 'Введіть прізвище та ім\'я');
      return;
    }

    final age = int.tryParse(ageText);
    if (age == null || age < 3 || age > 99) {
      setState(() => _ageError = 'Вік має бути числом від 3 до 99');
      return;
    }

    await widget.onAdd(fullName, age);
    fullNameController.clear();
    ageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(
                labelText: 'ПІБ дитини',
                errorText: _fullNameError,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ageController,
              decoration: InputDecoration(
                labelText: 'Вік',
                errorText: _ageError,
              ),
              keyboardType: TextInputType.number,
              maxLength: 2,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _validateAndAdd,
              child: const Text('Додати дитину'),
            ),
          ],
        ),
      ),
    );
  }
}

// Список дітей
class _ChildrenList extends StatelessWidget {
  final List<Child> children;
  final Future<void> Function(int childId) onDelete;
  final Future<void> Function(Child child, String newFullName, int newAge)
  onEdit;

  const _ChildrenList({
    required this.children,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListView.separated(
        itemCount: children.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final child = children[index];
          return ListTile(
            leading: Text(
              '${index + 1}.',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            title: Text(
              child.fullName,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Вік: ${child.age}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () async {
                    final result = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (context) => _EditChildDialog(child: child),
                    );
                    if (result != null) {
                      await onEdit(child, result['fullName'], result['age']);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onDelete(child.id!),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Dialog для редагування дитини
class _EditChildDialog extends StatefulWidget {
  final Child child;
  const _EditChildDialog({required this.child});

  @override
  State<_EditChildDialog> createState() => _EditChildDialogState();
}

class _EditChildDialogState extends State<_EditChildDialog> {
  late TextEditingController fullNameController;
  late TextEditingController ageController;

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController(text: widget.child.fullName);
    ageController = TextEditingController(text: widget.child.age.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Редагувати дитину'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: fullNameController,
            decoration: const InputDecoration(labelText: 'ПІБ дитини'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ageController,
            decoration: const InputDecoration(labelText: 'Вік'),
            keyboardType: TextInputType.number,
            maxLength: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Скасувати'),
        ),
        ElevatedButton(
          onPressed: () {
            final newFullName = fullNameController.text.trim();
            final newAge =
                int.tryParse(ageController.text.trim()) ?? widget.child.age;
            Navigator.of(context).pop({'fullName': newFullName, 'age': newAge});
          },
          child: const Text('Зберегти'),
        ),
      ],
    );
  }
}
