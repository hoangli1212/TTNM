import 'package:flutter/material.dart';

import '../core/date_labels.dart';
import '../data/studyflow_store.dart';
import '../widgets/study_ui.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StudyFlowScope.of(context);
    final classes = store.classesFor(store.now);
    final tasks = store.upcomingTasks.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFDCFCE7),
              child: Text(
                store.userName.characters.first.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF065F46),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào, ${store.userName}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      StudyDateLabels.fullDate(store.now),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F9F73), Color(0xFF2563EB)],
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Học kỳ hiện tại',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  store.semesterName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${store.pendingTasksCount} deadline đang chờ · ${store.streakDays} ngày học liên tục',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 42,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.25,
                children: [
                  MetricCard(
                    label: 'Hoàn thành',
                    value: '${(store.completionRate * 100).round()}%',
                    icon: Icons.task_alt_rounded,
                    color: const Color(0xFF0F9F73),
                  ),
                  MetricCard(
                    label: 'Focus tuần này',
                    value: '${store.focusMinutesThisWeek}p',
                    icon: Icons.timer_rounded,
                    color: const Color(0xFF2563EB),
                  ),
                  MetricCard(
                    label: 'Deadline trễ',
                    value: '${store.overdueTasksCount}',
                    icon: Icons.warning_amber_rounded,
                    color: const Color(0xFFF97316),
                  ),
                  MetricCard(
                    label: 'Thông báo',
                    value: '${store.notificationCount}',
                    icon: Icons.notifications_active_rounded,
                    color: const Color(0xFF8B5CF6),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      title: 'Lịch học hôm nay',
                      subtitle: 'Các buổi học sắp diễn ra trong ngày',
                    ),
                    const SizedBox(height: 16),
                    if (classes.isEmpty)
                      const StudyEmptyState(
                        icon: Icons.free_breakfast_rounded,
                        title: 'Không có buổi học nào',
                        subtitle:
                            'Bạn có thể dùng khoảng thời gian này để ôn tập hoặc xử lý deadline.',
                      )
                    else
                      ...classes.map((entry) {
                        final subjectColor = Color(entry.subject.colorValue);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: subjectColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: subjectColor,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.subject.name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${StudyDateLabels.timeRange(entry.slot)} · ${entry.subject.room}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      entry.subject.teacher,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      title: 'Deadline sắp tới',
                      subtitle: 'Ưu tiên những việc quan trọng trước',
                    ),
                    const SizedBox(height: 16),
                    ...tasks.map((task) {
                      final subject = store.subjectById(task.subjectId);
                      final accent = subject == null
                          ? Colors.blue
                          : Color(subject.colorValue);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: task.isDone,
                              onChanged: (_) =>
                                  store.toggleTaskCompletion(task.id),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          task.title,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
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
                                  const SizedBox(height: 4),
                                  Text(
                                    '${subject?.name ?? 'Khác'} · ${StudyDateLabels.dueLabel(task.dueAt, store.now)}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: LinearProgressIndicator(
                                      value: task.progress,
                                      minHeight: 8,
                                      backgroundColor: accent.withValues(
                                        alpha: 0.15,
                                      ),
                                      color: accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
