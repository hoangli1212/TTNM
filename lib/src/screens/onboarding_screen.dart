import 'package:flutter/material.dart';

import '../data/studyflow_store.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _pageIndex = 0;

  final List<_OnboardingItem> _items = const [
    _OnboardingItem(
      title: 'Quản lý lịch học thông minh',
      subtitle:
          'Theo dõi thời khóa biểu, môn học và deadline trong cùng một ứng dụng gọn gàng.',
      icon: Icons.calendar_month_rounded,
      accent: Color(0xFF10B981),
    ),
    _OnboardingItem(
      title: 'Không bỏ sót deadline quan trọng',
      subtitle:
          'Tạo việc cần làm, nhắc nhở nhiều mốc thời gian và xem tiến độ theo ngày, tuần, tháng.',
      icon: Icons.task_alt_rounded,
      accent: Color(0xFF2563EB),
    ),
    _OnboardingItem(
      title: 'Lên kế hoạch ôn tập dễ hơn',
      subtitle:
          'Pomodoro, ghi chú nhanh, thống kê chuỗi ngày học và báo cáo tiến độ cho cả học kỳ.',
      icon: Icons.insights_rounded,
      accent: Color(0xFFF97316),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = _items[_pageIndex];
    final store = StudyFlowScope.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              item.accent.withValues(alpha: 0.14),
              const Color(0xFFF8FAFC),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.menu_book_rounded, color: item.accent),
                          const SizedBox(width: 8),
                          const Text(
                            'StudyFlow',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: store.completeOnboarding,
                      child: const Text('Bỏ qua'),
                    ),
                  ],
                ),
                const Spacer(),
                Expanded(
                  flex: 4,
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _items.length,
                    onPageChanged: (value) =>
                        setState(() => _pageIndex = value),
                    itemBuilder: (context, index) =>
                        _OnboardingIllustration(item: _items[index]),
                  ),
                ),
                const Spacer(),
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 14),
                Text(
                  item.subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 24),
                Row(
                  children: List.generate(
                    _items.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      width: index == _pageIndex ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: index == _pageIndex
                            ? item.accent
                            : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_pageIndex == _items.length - 1) {
                      store.completeOnboarding();
                      return;
                    }
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: item.accent),
                  child: Text(
                    _pageIndex == _items.length - 1
                        ? 'Bắt đầu ngay'
                        : 'Tiếp tục',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingIllustration extends StatelessWidget {
  const _OnboardingIllustration({required this.item});

  final _OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: item.accent.withValues(alpha: 0.12),
          ),
        ),
        Container(
          width: 230,
          height: 230,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: item.accent.withValues(alpha: 0.2),
          ),
        ),
        Container(
          width: 170,
          height: 170,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: item.accent,
            boxShadow: [
              BoxShadow(
                color: item.accent.withValues(alpha: 0.28),
                blurRadius: 40,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Icon(item.icon, color: Colors.white, size: 72),
        ),
      ],
    );
  }
}

class _OnboardingItem {
  const _OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
}
