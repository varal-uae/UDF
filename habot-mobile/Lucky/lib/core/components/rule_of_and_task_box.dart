// EDBAA-037 — Rule of And Process Task Definition Box.
// Groups granular checkbox sub-tasks in Material cards, auto-unlocking subsequent inline cards upon completion.

import 'package:flutter/material.dart';

class SubTaskItem {
  SubTaskItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  bool isCompleted;
}

class RuleOfAndTaskBox extends StatefulWidget {
  const RuleOfAndTaskBox({
    super.key,
    required this.groupTitle,
    required this.tasks,
    required this.onAllCompleted,
  });

  final String groupTitle;
  final List<SubTaskItem> tasks;
  final VoidCallback onAllCompleted;

  @override
  State<RuleOfAndTaskBox> createState() => _RuleOfAndTaskBoxState();
}

class _RuleOfAndTaskBoxState extends State<RuleOfAndTaskBox> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.groupTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...List.generate(widget.tasks.length, (index) {
              final task = widget.tasks[index];
              // Auto-unlock rule: Task is enabled if it's the first task or previous task is completed
              final isUnlocked = index == 0 || widget.tasks[index - 1].isCompleted;

              return AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isUnlocked ? 1.0 : 0.4,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: task.isCompleted ? cs.secondaryContainer.withOpacity(0.4) : null,
                    borderRadius: BorderRadius.circular(8),
                    border: Border(
                      left: BorderSide(
                        color: task.isCompleted ? cs.secondary : cs.outlineVariant,
                        width: task.isCompleted ? 4 : 1, // Highlight completed rows with soft green/accent line
                      ),
                    ),
                  ),
                  child: CheckboxListTile(
                    value: task.isCompleted,
                    onChanged: isUnlocked
                        ? (val) {
                            setState(() {
                              task.isCompleted = val ?? false;
                            });
                            if (widget.tasks.every((t) => t.isCompleted)) {
                              widget.onAllCompleted();
                            }
                          }
                        : null,
                    title: Text(
                      task.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        fontWeight: isUnlocked ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
