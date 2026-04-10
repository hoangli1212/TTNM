import 'package:flutter/material.dart';

import '../core/date_labels.dart';
import '../data/studyflow_store.dart';
import '../widgets/study_ui.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StudyFlowScope.of(context);
    final selectedDate = store.selectedDate;

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch học')),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theo dõi kế hoạch theo ngày, tuần và tháng',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      StudyDateLabels.fullDate(selectedDate),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 18),
                    SegmentedButton<CalendarViewMode>(
                      segments: const [
                        ButtonSegment(
                          value: CalendarViewMode.day,
                          label: Text('Ngày'),
                        ),
                        ButtonSegment(
                          value: CalendarViewMode.week,
                          label: Text('Tuần'),
                        ),
                        ButtonSegment(
                          value: CalendarViewMode.month,
                          label: Text('Tháng'),
                        ),
                      ],
                      selected: {store.calendarMode},
                      onSelectionChanged: (selection) =>
                          store.setCalendarMode(selection.first),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 88,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 7,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final date = DateUtils.dateOnly(
                            selectedDate
                                .subtract(
                                  Duration(days: selectedDate.weekday - 1),
                                )
                                .add(Duration(days: index)),
                          );
                          final selected = DateUtils.isSameDay(
                            date,
                            selectedDate,
                          );
                          return GestureDetector(
                            onTap: () => store.setSelectedDate(date),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 72,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFF0F9F73)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: selected
                                      ? Colors.transparent
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    StudyDateLabels.weekdayShort(date.weekday),
                                    style: TextStyle(
                                      color: selected
                                          ? Colors.white70
                                          : const Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      color: selected
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 22,
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
              const SizedBox(height: 18),
              switch (store.calendarMode) {
                CalendarViewMode.day => _DayView(date: selectedDate),
                CalendarViewMode.week => _WeekView(anchorDate: selectedDate),
                CalendarViewMode.month => _MonthView(anchorDate: selectedDate),
              },
            ],
          ),
        ),
      ),
    );
  }
}

class _DayView extends StatelessWidget {
  const _DayView({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final store = StudyFlowScope.of(context);
    final classes = store.classesFor(date);
    final tasks = store.tasksForDay(date);

    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Lịch trong ngày',
            subtitle: 'Buổi học và deadline theo ngày đã chọn',
          ),
          const SizedBox(height: 16),
          if (classes.isEmpty && tasks.isEmpty)
            const StudyEmptyState(
              icon: Icons.event_available_rounded,
              title: 'Ngày này đang trống',
              subtitle:
                  'Bạn có thể dùng để ôn tập, bổ sung ghi chú hoặc lên kế hoạch học mới.',
            )
          else ...[
            ...classes.map((entry) {
              final accent = Color(entry.subject.colorValue);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.school_rounded, color: accent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.subject.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${StudyDateLabels.timeRange(entry.slot)} · ${entry.subject.room}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            ...tasks.map((task) {
              final subject = store.subjectById(task.subjectId);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.assignment_rounded,
                      color: Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(subject?.name ?? 'Khác'),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: task.isDone,
                      onChanged: (_) => store.toggleTaskCompletion(task.id),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _WeekView extends StatelessWidget {
  const _WeekView({required this.anchorDate});

  final DateTime anchorDate;

  @override
  Widget build(BuildContext context) {
    final store = StudyFlowScope.of(context);
    final start = anchorDate.subtract(Duration(days: anchorDate.weekday - 1));

    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Tổng quan tuần',
            subtitle: 'Khối lượng học tập trong 7 ngày',
          ),
          const SizedBox(height: 16),
          ...List.generate(7, (index) {
            final date = DateUtils.dateOnly(start.add(Duration(days: index)));
            final classes = store.classesFor(date);
            final tasks = store.tasksForDay(date);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DateUtils.isSameDay(date, store.now)
                    ? const Color(0xFFECFDF5)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          StudyDateLabels.weekdayShort(date.weekday),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          StudyDateLabels.shortDate(date),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        PillTag(
                          label: '${classes.length} buổi học',
                          backgroundColor: const Color(0xFFDBEAFE),
                          textColor: const Color(0xFF1D4ED8),
                        ),
                        PillTag(
                          label: '${tasks.length} deadline',
                          backgroundColor: const Color(0xFFFFEDD5),
                          textColor: const Color(0xFF9A3412),
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
    );
  }
}

class _MonthView extends StatelessWidget {
  const _MonthView({required this.anchorDate});

  final DateTime anchorDate;

  @override
  Widget build(BuildContext context) {
    final store = StudyFlowScope.of(context);
    final monthStart = DateTime(anchorDate.year, anchorDate.month);
    final gridStart = monthStart.subtract(
      Duration(days: monthStart.weekday - 1),
    );

    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Tháng ${anchorDate.month}/${anchorDate.year}',
            subtitle: 'Chạm vào một ngày để xem lịch chi tiết',
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              7,
              (index) => Expanded(
                child: Center(
                  child: Text(
                    StudyDateLabels.weekdayShort(index + 1),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 35,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final date = DateUtils.dateOnly(
                gridStart.add(Duration(days: index)),
              );
              final classes = store.classesFor(date).length;
              final tasks = store.tasksForDay(date).length;
              final selected = DateUtils.isSameDay(date, store.selectedDate);
              final inMonth = date.month == anchorDate.month;
              return GestureDetector(
                onTap: () {
                  store.setSelectedDate(date);
                  store.setCalendarMode(CalendarViewMode.day);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF0F9F73)
                        : inMonth
                        ? const Color(0xFFF8FAFC)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: selected
                              ? Colors.white
                              : inMonth
                              ? const Color(0xFF0F172A)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                      const Spacer(),
                      if (classes > 0)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.white
                                : const Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                        ),
                      if (tasks > 0) const SizedBox(height: 4),
                      if (tasks > 0)
                        Container(
                          width: 18,
                          height: 4,
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.white70
                                : const Color(0xFFF97316),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
