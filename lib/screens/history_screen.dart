import 'package:flutter/material.dart';
import 'package:camp_registry/data/database_helper.dart';
import 'package:camp_registry/data/child.dart';
import 'package:camp_registry/widgets/children_list.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? selectedDate;
  List<String> availableDates = [];
  List<Child> childrenOnDate = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDates();
  }

  Future<void> _loadDates() async {
    setState(() => isLoading = true);
    availableDates = await DatabaseHelper.instance.getAvailableDates();
    if (availableDates.isNotEmpty) {
      selectedDate = availableDates.first;
      await _loadChildrenForDate(selectedDate!);
    }
    setState(() => isLoading = false);
  }

  Future<void> _loadChildrenForDate(String date) async {
    setState(() => isLoading = true);
    childrenOnDate = await DatabaseHelper.instance.getChildrenByDate(date);
    setState(() => isLoading = false);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate != null
          ? DateFormat('yyyy-MM-dd').parse(selectedDate!)
          : DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      setState(() => selectedDate = formattedDate);
      await _loadChildrenForDate(formattedDate);
    }
  }

  String _formatDisplayDate(String date) {
    final parsedDate = DateFormat('yyyy-MM-dd').parse(date);
    return DateFormat('dd.MM.yyyy').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Історія відвідувань')),
      body: isLoading && availableDates.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : availableDates.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history_toggle_off_outlined,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Немає записів відвідувань',
                    style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_month,
                                color: Theme.of(context).colorScheme.primary,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Вибрати дату',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _selectDate,
                                  icon: const Icon(Icons.calendar_today),
                                  label: Text(
                                    selectedDate != null
                                        ? _formatDisplayDate(selectedDate!)
                                        : 'Вибрати дату',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedDate,
                              hint: const Text('Виберіть дату зі списку'),
                              underline: const SizedBox(),
                              icon: Icon(
                                Icons.arrow_drop_down_circle,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              dropdownColor: Theme.of(
                                context,
                              ).colorScheme.surface,
                              borderRadius: BorderRadius.circular(10),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 16,
                              ),
                              onChanged: (newValue) {
                                if (newValue != null &&
                                    newValue != selectedDate) {
                                  setState(() => selectedDate = newValue);
                                  _loadChildrenForDate(newValue);
                                }
                              },
                              items: availableDates.map((date) {
                                return DropdownMenuItem<String>(
                                  value: date,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Text(_formatDisplayDate(date)),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.people,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Кількість дітей:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${childrenOnDate.length}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                    child: Text(
                      selectedDate != null
                          ? 'Список дітей за ${_formatDisplayDate(selectedDate!)}'
                          : 'Список дітей',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ChildrenList(
                            children: childrenOnDate,
                            showActions: false,
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
