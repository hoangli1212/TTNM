import 'package:flutter/material.dart';

import '../core/date_labels.dart';
import '../data/studyflow_store.dart';
import '../widgets/study_ui.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StudyFlowScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Môn học')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSubjectComposer(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm môn'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        itemCount: store.subjects.length,
        itemBuilder: (context, index) {
          final subject = store.subjects[index];
          final accent = Color(subject.colorValue);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.menu_book_rounded, color: accent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subject.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${subject.teacher} · ${subject.room}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (subject.slots.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: subject.slots
                          .map(
                            (slot) => PillTag(
                              label:
                                  '${StudyDateLabels.weekdayShort(slot.weekday)} · ${StudyDateLabels.timeRange(slot)}',
                              backgroundColor: accent.withValues(alpha: 0.1),
                              textColor: accent,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showSubjectComposer(BuildContext context) async {
    final store = StudyFlowScope.of(context);
    final nameController = TextEditingController();
    final teacherController = TextEditingController();
    final roomController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên môn học'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: teacherController,
                decoration: const InputDecoration(labelText: 'Giảng viên'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: roomController,
                decoration: const InputDecoration(labelText: 'Phòng học'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) return;
                  store.addSubject(
                    name: nameController.text.trim(),
                    teacher: teacherController.text.trim().isEmpty
                        ? 'Chưa cập nhật'
                        : teacherController.text.trim(),
                    room: roomController.text.trim().isEmpty
                        ? 'TBA'
                        : roomController.text.trim(),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Lưu môn học'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StudyFlowScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ghi chú')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoteComposer(context),
        icon: const Icon(Icons.note_add_rounded),
        label: const Text('Tạo ghi chú'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        children: [
          if (store.notes.isEmpty)
            const StudyEmptyState(
              icon: Icons.notes_rounded,
              title: 'Chưa có ghi chú nào',
              subtitle:
                  'Bạn có thể ghi lại ý tưởng, tóm tắt buổi học hoặc checklist ôn tập.',
            )
          else
            ...store.notes.map((note) {
              final subject = store.subjectById(note.subjectId);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: AppPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              note.title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          if (note.pinned)
                            const PillTag(
                              label: 'Ghim',
                              backgroundColor: Color(0xFFFFEDD5),
                              textColor: Color(0xFF9A3412),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        note.body,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(height: 1.5),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '${subject?.name ?? 'Khác'} · ${StudyDateLabels.shortDate(note.updatedAt)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Future<void> _showNoteComposer(BuildContext context) async {
    final store = StudyFlowScope.of(context);
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    var selectedSubjectId = store.subjects.first.id;

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
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Tiêu đề'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedSubjectId,
                    decoration: const InputDecoration(labelText: 'Môn học'),
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
                  const SizedBox(height: 12),
                  TextField(
                    controller: bodyController,
                    maxLines: 5,
                    decoration: const InputDecoration(labelText: 'Nội dung'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.trim().isEmpty ||
                          bodyController.text.trim().isEmpty) {
                        return;
                      }
                      store.addNote(
                        title: titleController.text.trim(),
                        body: bodyController.text.trim(),
                        subjectId: selectedSubjectId,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Lưu ghi chú'),
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
