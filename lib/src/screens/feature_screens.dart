import 'package:flutter/material.dart';

import '../data/studyflow_store.dart';
import '../widgets/study_ui.dart';
import 'module_screens_a.dart';
import 'module_screens_b.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StudyFlowScope.of(context);
    final cards = [
      _FeatureCardData(
        title: 'Môn học',
        subtitle: '${store.subjects.length} môn đang theo dõi',
        icon: Icons.menu_book_rounded,
        accent: const Color(0xFF10B981),
        builder: (_) => const SubjectsScreen(),
      ),
      _FeatureCardData(
        title: 'Ghi chú',
        subtitle: '${store.notes.length} ghi chú học tập',
        icon: Icons.sticky_note_2_rounded,
        accent: const Color(0xFF2563EB),
        builder: (_) => const NotesScreen(),
      ),
      _FeatureCardData(
        title: 'Phân tích',
        subtitle: 'Theo dõi tiến độ và thành tựu',
        icon: Icons.insights_rounded,
        accent: const Color(0xFFF97316),
        builder: (_) => const AnalyticsScreen(),
      ),
      _FeatureCardData(
        title: 'Nhắc nhở',
        subtitle: '${store.enabledReminders.length} nhắc nhở đang bật',
        icon: Icons.alarm_rounded,
        accent: const Color(0xFF8B5CF6),
        builder: (_) => const RemindersScreen(),
      ),
      _FeatureCardData(
        title: 'Thông báo',
        subtitle: '${store.notificationCount} mục cần xem',
        icon: Icons.notifications_active_rounded,
        accent: const Color(0xFFEF4444),
        builder: (_) => const NotificationsScreen(),
      ),
      _FeatureCardData(
        title: 'Hồ sơ',
        subtitle: 'Cài đặt, giao diện và tài khoản',
        icon: Icons.person_rounded,
        accent: const Color(0xFF0F172A),
        builder: (_) => const ProfileScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Tất cả tính năng')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
          children: [
            AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mở rộng StudyFlow',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Từ đây bạn có thể đi tới các module hỗ trợ học tập, từ môn học, ghi chú đến phân tích tiến độ.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cards.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.98,
              ),
              itemBuilder: (context, index) {
                final card = cards[index];
                return GestureDetector(
                  onTap: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: card.builder)),
                  child: AppPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: card.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(card.icon, color: card.accent),
                        ),
                        const Spacer(),
                        Text(
                          card.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          card.subtitle,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCardData {
  const _FeatureCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final WidgetBuilder builder;
}
