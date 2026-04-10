import 'package:flutter/material.dart';

import '../core/date_labels.dart';
import '../data/studyflow_store.dart';
import '../widgets/study_ui.dart';

enum TaskFilter { all, today, overdue, completed }

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  TaskFilter _filter = TaskFilter.all;

  @override
  Widget build(BuildContext context) {
    final store = StudyFlowScope.of(context);
    final items = switch (_filter) {
      TaskFilter.all => store.tasks,
      TaskFilter.today =>
        store.tasks
            .where((task) => DateUtils.isSameDay(task.dueAt, store.now))
            .toList(),
      TaskFilter.overdue => store.overdueTasks,
      TaskFilter.completed => store.tasks.where((task) => task.isDone).toList(),
    }..sort((a, b) => a.dueAt.compareTo(b.dueAt));

    return Scaffold(
      appBar: AppBar(title: const Text('Deadline & Bài tập')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskComposer(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm deadline'),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
              child: AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      title: 'Quản lý deadline',
                      subtitle:
                          'Theo dõi bài tập, bài nộp và các hạng mục cần hoàn thành',
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _FilterChip(
                          label: 'Tất cả',
                          selected: _filter == TaskFilter.all,
                          onTap: () => setState(() => _filter = TaskFilter.all),
                        ),
                        _FilterChip(
                          label: 'Hôm nay',
                          selected: _filter == TaskFilter.today,
                          onTap: () =>
                              setState(() => _filter = TaskFilter.today),
                        ),
                        _FilterChip(
                          label: 'Quá hạn',
                          selected: _filter == TaskFilter.overdue,
                          onTap: () =>
                              setState(() => _filter = TaskFilter.overdue),
                        ),
                        _FilterChip(
                          label: 'Đã xong',
                          selected: _filter == TaskFilter.completed,
                          onTap: () =>
                              setState(() => _filter = TaskFilter.completed),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: StudyEmptyState(
                        icon: Icons.assignment_turned_in_rounded,
                        title: 'Không có deadline nào',
                        subtitle:
                            'Thêm công việc mới để bắt đầu theo dõi tiến độ học tập.',
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final task = items[index];
                        final subject = store.subjectById(task.subjectId);
                        final accent = subject == null
                            ? const Color(0xFF2563EB)
                            : Color(subject.colorValue);
                        final isOverdue =
                            !task.isDone &&
                            DateUtils.dateOnly(
                              task.dueAt,
                            ).isBefore(DateUtils.dateOnly(store.now));
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: AppPanel(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: task.isDone,
                                  onChanged: (_) =>
                                      store.toggleTaskCompletion(task.id),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              task.title,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    decoration: task.isDone
                                                        ? TextDecoration
                                                              .lineThrough
                                                        : null,
                                                  ),
                                            ),
                                          ),
                                          PillTag(
                                            label: task.type,
                                            backgroundColor: accent.withValues(
                                              alpha: 0.12,
                                            ),
                                            textColor: accent,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${subject?.name ?? 'Khác'} · ${StudyDateLabels.dueLabel(task.dueAt, store.now)}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                      const SizedBox(height: 12),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        child: LinearProgressIndicator(
                                          value: task.progress,
                                          minHeight: 8,
                                          backgroundColor: accent.withValues(
                                            alpha: 0.12,
                                          ),
                                          color: isOverdue
                                              ? const Color(0xFFEF4444)
                                              : accent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTaskComposer(BuildContext context) async {
    final store = StudyFlowScope.of(context);
    final titleController = TextEditingController();
    var selectedSubjectId = store.subjects.first.id;
    var dueDate = DateUtils.dateOnly(store.now.add(const Duration(days: 1)));

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thêm deadline mới',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Tên công việc',
                      prefixIcon: Icon(Icons.edit_note_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedSubjectId,
                    decoration: const InputDecoration(
                      labelText: 'Môn học',
                      prefixIcon: Icon(Icons.menu_book_rounded),
                    ),
                    items: store.subjects
                        .map(
                          (subject) => DropdownMenuItem<String>(
                            value: subject.id,
                            child: Text(subject.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() => selectedSubjectId = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(store.now.year - 1),
                        lastDate: DateTime(store.now.year + 1),
                        initialDate: dueDate,
                      );
                      if (picked != null) {
                        setModalState(() => dueDate = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_month_rounded),
                    label: Text(
                      'Hạn nộp: ${StudyDateLabels.shortDate(dueDate)}',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.trim().isEmpty) return;
                      store.addTask(
                        title: titleController.text.trim(),
                        subjectId: selectedSubjectId,
                        dueAt: dueDate,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Lưu deadline'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? const Color(0xFF065F46) : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
