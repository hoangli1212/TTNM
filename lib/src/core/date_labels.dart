import 'package:flutter/material.dart';

import '../data/studyflow_store.dart';

class StudyDateLabels {
  static const _weekdayShort = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  static const _weekdayLong = [
    'Thứ hai',
    'Thứ ba',
    'Thứ tư',
    'Thứ năm',
    'Thứ sáu',
    'Thứ bảy',
    'Chủ nhật',
  ];
  static const _month = [
    'tháng 1',
    'tháng 2',
    'tháng 3',
    'tháng 4',
    'tháng 5',
    'tháng 6',
    'tháng 7',
    'tháng 8',
    'tháng 9',
    'tháng 10',
    'tháng 11',
    'tháng 12',
  ];

  static String weekdayShort(int weekday) =>
      _weekdayShort[(weekday - 1).clamp(0, 6)];

  static String weekdayLong(int weekday) =>
      _weekdayLong[(weekday - 1).clamp(0, 6)];

  static String monthLabel(int month) => _month[(month - 1).clamp(0, 11)];

  static String fullDate(DateTime date) {
    return '${weekdayLong(date.weekday)}, ${date.day} ${monthLabel(date.month)}';
  }

  static String shortDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  static String clock(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String timeRange(ClassSlot slot) {
    final start =
        '${slot.startHour.toString().padLeft(2, '0')}:${slot.startMinute.toString().padLeft(2, '0')}';
    final end =
        '${slot.endHour.toString().padLeft(2, '0')}:${slot.endMinute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  static String dueLabel(DateTime date, DateTime now) {
    final today = DateUtils.dateOnly(now);
    final target = DateUtils.dateOnly(date);
    final diff = target.difference(today).inDays;
    if (diff == 0) return 'Hôm nay';
    if (diff == 1) return 'Ngày mai';
    if (diff == -1) return 'Hôm qua';
    if (diff > 1 && diff < 7) return 'Sau $diff ngày';
    if (diff < -1) return 'Trễ ${diff.abs()} ngày';
    return shortDate(date);
  }
}
