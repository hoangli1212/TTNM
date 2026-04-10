import 'package:flutter/material.dart';

import '../core/date_labels.dart';
import '../data/studyflow_store.dart';
import '../widgets/study_ui.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StudyFlowScope.of(context);
    final minutes = (store.focusRemainingSeconds ~/ 60).toString().padLeft(
      2,
      '0',
    );
    final seconds = (store.focusRemainingSeconds % 60).toString().padLeft(
      2,
      '0',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Focus Timer')),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
          child: Column(
            children: [
              AppPanel(
                child: Column(
                  children: [
                    const SectionHeader(
                      title: 'Pomodoro',
                      subtitle:
                          'Tập trung vào một việc quan trọng trong khoảng thời gian ngắn',
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F9F73), Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF0F9F73,
                            ).withValues(alpha: 0.26),
                            blurRadius: 28,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$minutes:$seconds',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Chế độ ${store.focusPresetMinutes} phút',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 10,
                      children: [25, 50, 90]
                          .map(
                            (minutes) => ChoiceChip(
                              label: Text('$minutes phút'),
                              selected: store.focusPresetMinutes == minutes,
                              onSelected: (_) =>
                                  store.resetFocus(minutes: minutes),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: store.isFocusRunning
                                ? store.pauseFocus
                                : store.startFocus,
                            icon: Icon(
                              store.isFocusRunning
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                            ),
                            label: Text(
                              store.isFocusRunning ? 'Tạm dừng' : 'Bắt đầu',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => store.resetFocus(),
                            icon: const Icon(Icons.restart_alt_rounded),
                            label: const Text('Làm lại'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      label: 'Chuỗi hiện tại',
                      value: '${store.streakDays} ngày',
                      icon: Icons.local_fire_department_rounded,
                      color: const Color(0xFFF97316),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricCard(
                      label: 'Tổng phút tuần',
                      value: '${store.focusMinutesThisWeek}',
                      icon: Icons.bolt_rounded,
                      color: const Color(0xFF2563EB),
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
                      title: 'Lịch sử phiên học',
                      subtitle: 'Những phiên gần nhất được lưu cục bộ',
                    ),
                    const SizedBox(height: 16),
                    ...store.sessions
                        .take(5)
                        .map(
                          (session) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.timer_rounded,
                                    color: Color(0xFF0F9F73),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        session.label,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${session.durationMinutes} phút · ${StudyDateLabels.shortDate(session.startedAt)}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
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
      ),
    );
  }
}
