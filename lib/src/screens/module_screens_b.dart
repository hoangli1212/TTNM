import 'package:flutter/material.dart';

import '../core/date_labels.dart';
import '../data/studyflow_store.dart';
import '../widgets/study_ui.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StudyFlowScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Phân tích tiến độ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    label: 'Tỷ lệ hoàn thành',
                    value: '${(store.completionRate * 100).round()}%',
                    icon: Icons.show_chart_rounded,
                    color: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    label: 'Chuỗi học',
                    value: '${store.streakDays} ngày',
                    icon: Icons.local_fire_department_rounded,
                    color: const Color(0xFFF97316),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Khối lượng học trong tuần',
                    subtitle: 'Biểu diễn nhanh theo từng ngày',
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (index) {
                      final height = 42.0 + (index * 14);
                      return Column(
                        children: [
                          Container(
                            width: 28,
                            height: height,
                            decoration: BoxDecoration(
                              color: index.isEven
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(StudyDateLabels.weekdayShort(index + 1)),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Thành tựu',
                    subtitle: 'Theo dõi mốc tiến bộ của bạn',
                  ),
                  const SizedBox(height: 16),
                  ...store.achievements.map(
                    (achievement) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: achievement.unlocked
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: achievement.unlocked
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              achievement.icon,
                              color: achievement.unlocked
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  achievement.title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  achievement.description,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: achievement.progress,
                                    minHeight: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StudyFlowScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Nhắc nhở')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showReminderComposer(context),
        icon: const Icon(Icons.alarm_add_rounded),
        label: const Text('Thêm nhắc nhở'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        children: store.reminders
            .map(
              (reminder) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: AppPanel(
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.alarm_rounded,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reminder.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              StudyDateLabels.clock(reminder.time),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: reminder.enabled,
                        onChanged: (_) => store.toggleReminder(reminder.id),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> _showReminderComposer(BuildContext context) async {
    final store = StudyFlowScope.of(context);
    final titleController = TextEditingController();
    var selectedTime = const TimeOfDay(hour: 20, minute: 0);

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
                    decoration: const InputDecoration(
                      labelText: 'Tên nhắc nhở',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setModalState(() => selectedTime = picked);
                      }
                    },
                    icon: const Icon(Icons.schedule_rounded),
                    label: Text(
                      'Giờ nhắc: ${StudyDateLabels.clock(selectedTime)}',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.trim().isEmpty) return;
                      store.addReminder(
                        title: titleController.text.trim(),
                        time: selectedTime,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Lưu nhắc nhở'),
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

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StudyFlowScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Thông báo')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        children: [
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Ưu tiên hôm nay',
                  subtitle: 'Những mục nên kiểm tra trước',
                ),
                const SizedBox(height: 16),
                ...store.overdueTasks.map(
                  (task) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFEF4444),
                    ),
                    title: Text(task.title),
                    subtitle: Text(
                      'Đã quá hạn · ${StudyDateLabels.shortDate(task.dueAt)}',
                    ),
                  ),
                ),
                if (store.overdueTasks.isEmpty)
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF10B981),
                    ),
                    title: Text('Không có deadline quá hạn'),
                    subtitle: Text('Tiếp tục giữ nhịp học rất tốt.'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Lịch nhắc sắp tới',
                  subtitle: 'Tổng hợp reminder và hoạt động gần đây',
                ),
                const SizedBox(height: 16),
                ...store.enabledReminders.map(
                  (reminder) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.alarm_rounded,
                      color: Color(0xFF7C3AED),
                    ),
                    title: Text(reminder.title),
                    subtitle: Text(StudyDateLabels.clock(reminder.time)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StudyFlowScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ & Cài đặt')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          AppPanel(
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      store.userName.characters.first.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF065F46),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.userName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        store.semesterName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppPanel(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Bật thông báo'),
                  subtitle: const Text('Nhắc trước giờ học và deadline'),
                  value: store.notificationsEnabled,
                  onChanged: store.toggleNotifications,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Giao diện tối'),
                  subtitle: const Text('Chuyển nhanh theme của ứng dụng'),
                  value: store.isDarkMode,
                  onChanged: store.toggleDarkMode,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: store.logout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Đăng xuất'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
        ],
      ),
    );
  }
}
