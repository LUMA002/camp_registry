import 'package:flutter/material.dart';
import 'package:camp_registry/data/child.dart';
import 'package:camp_registry/widgets/edit_child_dialog.dart';

class ChildrenList extends StatelessWidget {
  final List<Child> children;
  final Future<void> Function(int childId)? onDelete;
  final Future<void> Function(Child child, String newFullName, int newAge)? onEdit;
  final bool showActions;

  const ChildrenList({
    super.key,
    required this.children,
    this.onDelete,
    this.onEdit,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: children.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_off_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Немає дітей у списку',
                      style: TextStyle(
                        fontSize: 18, 
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              itemCount: children.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final child = children[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                    foregroundColor: Colors.white,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  title: Text(
                    child.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      'Вік: ${child.age}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  trailing: showActions
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (onEdit != null)
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: IconButton(
                                  icon: const Icon(Icons.edit, size: 24),
                                  color: Theme.of(context).colorScheme.primary,
                                  tooltip: 'Редагувати',
                                  onPressed: () async {
                                    final result = await showDialog<Map<String, dynamic>>(
                                      context: context,
                                      builder: (context) => EditChildDialog(child: child),
                                    );
                                    if (result != null) {
                                      await onEdit!(child, result['fullName'], result['age']);
                                    }
                                  },
                                ),
                              ),
                            if (onDelete != null)
                              IconButton(
                                icon: const Icon(Icons.delete, size: 24),
                                color: Theme.of(context).colorScheme.error,
                                tooltip: 'Видалити',
                                onPressed: () => _confirmDelete(context, child),
                              ),
                          ],
                        )
                      : null,
                );
              },
            ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Child child) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Підтвердження'),
        content: Text('Ви дійсно хочете видалити ${child.fullName} зі списку?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Видалити'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && onDelete != null) {
      await onDelete!(child.id!);
    }
  }
}