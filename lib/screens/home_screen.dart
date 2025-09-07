import 'package:camp_registry/utils/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:camp_registry/data/database_helper.dart';
import 'package:camp_registry/data/child.dart';
import 'package:camp_registry/screens/history_screen.dart';
import 'package:camp_registry/widgets/children_list.dart';
import 'package:camp_registry/widgets/duplicate_name_dialog.dart';
import 'package:intl/intl.dart';
import 'dart:developer';

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
    _checkCurrentDate(); // перевірка поточної дати

    // 1. Шукаємо дитину по ПІБ
    final existingChild = await DatabaseHelper.instance.getChildByFullName(
      fullName,
    );

    int? childId;

    if (existingChild == null) {
      // Дитини немає — додаємо в children
      childId = await DatabaseHelper.instance.insertChild(
        Child(fullName: fullName, age: age),
      );

      if (childId < 0) {
        if (!mounted) return;

        // якщо помилка унікальності
        if (childId == -1) {
          // Знаходимо дублікат для показу в діалозі
          final duplicateChild = await DatabaseHelper.instance
              .getChildByFullName(fullName);
          if (duplicateChild != null && duplicateChild.age != age) {
            // Показуємо діалог тільки якщо вік відрізняється
            if (!mounted) return;
            final updatedName = await showDialog<String>(
              context: context,
              builder: (context) => DuplicateNameDialog(
                existingFullName: duplicateChild.fullName,
                existingAge: duplicateChild.age,
                newAge: age,
              ),
            );

            if (updatedName != null) {
              // Спроба додати з уточненим ПІБ
              childId = await DatabaseHelper.instance.insertChild(
                Child(fullName: updatedName, age: age),
              );

              if (childId <= 0) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Помилка додавання особи')),
                );
                return;
              }
            } else {
              // скасувавання діалогу
              return;
            }
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Особа з таким ПІБ вже існує!')),
            );
            return;
          }
        } else {
          // Інші помилки БД
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Помилка додавання особи')),
          );
          return;
        }
      }
    } else {
      // Дитина існує та перевіряємо вік
      if (existingChild.age != age) {
        // якщо вік відрізняється - показуємо діалог для уточнення
        if (!mounted) return;
        final updatedName = await showDialog<String>(
          context: context,
          builder: (context) => DuplicateNameDialog(
            existingFullName: existingChild.fullName,
            existingAge: existingChild.age,
            newAge: age,
          ),
        );

        if (updatedName != null) {
          // Додаємо нову дитину з уточненим ПІБ
          childId = await DatabaseHelper.instance.insertChild(
            Child(fullName: updatedName, age: age),
          );

          if (childId <= 0) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Помилка додавання особи')),
            );
            return;
          }
        } else {
          // Скасування діалогу
          return;
        }
      } else {
        // Вік однаковий, використовуємо існуючий запис
        childId = existingChild.id!;

        // Перевіряємо, чи вже є у attendance на сьогодні
        final alreadyPresent = await DatabaseHelper.instance
            .isChildAlreadyPresentToday(childId, today);
        if (alreadyPresent) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Особа вже є у списку на сьогодні!')),
          );
          return;
        }
      }
    }

    // 2. Додаємо в attendance
    await DatabaseHelper.instance.insertAttendance(childId, today);
    await _loadChildren();
  }

  void _checkCurrentDate() {
    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (currentDate != today) {
      setState(() {
        today = currentDate;
      });
      _loadChildren();

      // повідомлення про зміну дати
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Дату оновлено на поточну: ${DateFormat('dd.MM.yyyy').format(DateTime.now())}',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _removeChild(int childId) async {
    await DatabaseHelper.instance.deleteAttendance(childId, today);
    await _loadChildren();
  }

  Future<void> _editChild(Child child, String newFullName, int newAge) async {
    final updated = Child(id: child.id, fullName: newFullName, age: newAge);
    try {
      final result = await DatabaseHelper.instance.updateChild(updated);
      if (result == 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Зміни не збережено: такий ПІБ вже існує або дані не змінилися!',
              //style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        );
        return;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Зміни не збережено: такий ПІБ вже існує!'),
        ),
      );
      return;
    }
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
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const HistoryScreen();
                  },
                ),
              );
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
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                            bottom: 8.0,
                          ),
                          child: Text(
                            'Список на сьогодні (${DateFormat('dd.MM.yyyy').format(DateTime.now())}):',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ChildrenList(
                            children: childrenToday,
                            onDelete: _removeChild,
                            onEdit: _editChild,
                          ),
                        ),
                      ],
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
  final FocusNode fullNameFocusNode = FocusNode();

  String? _fullNameError;
  String? _ageError;

  List<Child> _suggestions = [];
  bool _isLoading = false;
  bool _suppressSearch = false; // для надмірних запитів
  final _debouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    fullNameController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    fullNameController.removeListener(_onSearchChanged);
    fullNameController.dispose();
    ageController.dispose();
    fullNameFocusNode.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_suppressSearch) return;
    //Використ. debouncer для запобігання надмірних запитів
    _debouncer(() async {
      if (fullNameController.text.length >= 2) {
        setState(() => _isLoading = true);

        try {
          final results = await DatabaseHelper.instance
              .searchChildrenByPartialName(fullNameController.text);

          if (mounted) {
            setState(() {
              _suggestions = results;
              _isLoading = false;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _suggestions = [];
              _isLoading = false;
            });
          }
        }
      } else {
        setState(() => _suggestions = []);
      }
    });
  }

  void _selectSuggestion(Child child) {
    _suppressSearch = true;
    fullNameController.text = child.fullName;
    ageController.text = child.age.toString();
    setState(() {
      _suggestions = [];
      // розблоковуємо пошук з невеликою затримкою
      Future.delayed(const Duration(milliseconds: 300), () {
        _suppressSearch = false;
      });
    });
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Future<void> _validateAndAdd() async {
    setState(() {
      _fullNameError = null;
      _ageError = null;
    });

    String fullName = fullNameController.text.trim();
    // реплейс кількох пробілів на один
    fullName = fullName.replaceAll(RegExp(r'\s+'), ' ');

    if (fullName.isEmpty || fullName.length < 3) {
      setState(() => _fullNameError = 'ПІБ має містити мінімум 3 символи');
      return;
    }

    //  наявність мінімум двох слів (прізвище та ім'я)
    final nameParts = fullName
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList();
    if (nameParts.length < 2) {
      setState(() => _fullNameError = 'Введіть прізвище та ім\'я');
      return;
    }

    // допустимі символи (укр, латинські літери, апостроф, дефіс, круглі дужки)
    final nameRegExp = RegExp(r"^[a-zA-Zа-яА-ЯёЁіІїЇєЄґҐ''\-()\s]+$");
    if (!nameRegExp.hasMatch(fullName)) {
      setState(
        () => _fullNameError =
            'ПІБ може містити тільки літери, пробіли, дефіси, апострофи, круглі дужки',
      );
      return;
    }

    final ageText = ageController.text.trim();
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_add_alt_1,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Додати дитину',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: fullNameController,
                  focusNode: fullNameFocusNode,
                  decoration: InputDecoration(
                    labelText: 'ПІБ дитини',
                    errorText: _fullNameError,
                    prefixIcon: const Icon(Icons.person, size: 22),
                    suffixIcon: _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          )
                        : fullNameController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _suppressSearch = true;
                              fullNameController.clear();
                              setState(() {
                                _suggestions = [];
                                Future.delayed(
                                  const Duration(milliseconds: 300),
                                  () {
                                    _suppressSearch = false;
                                  },
                                );
                              });
                            },
                            icon: const Icon(Icons.clear, size: 22),
                          )
                        : null,
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
                if (_suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.8),
                            foregroundColor: Colors.white,
                            child: const Icon(Icons.person, size: 18),
                          ),
                          title: Text(suggestion.fullName),
                          subtitle: Text('Вік: ${suggestion.age}'),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          //dense: true,
                          onTap: () {
                            _selectSuggestion(suggestion);
                            // Встановлюємо фокус на поле віку після вибору підказки
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ageController,
              decoration: InputDecoration(
                labelText: 'Вік',
                errorText: _ageError,
                prefixIcon: const Icon(Icons.cake, size: 22),
              ),
              keyboardType: TextInputType.number,
              maxLength: 2,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _validateAndAdd,
                  icon: const Icon(Icons.add_circle, size: 22),
                  label: const Text('Додати дитину'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
