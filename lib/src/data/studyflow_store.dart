import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

enum AppStage { onboarding, auth, home }

enum CalendarViewMode { day, week, month }

class Subject {
  Subject({
    required this.id,
    required this.name,
    required this.teacher,
    required this.room,
    required this.colorValue,
    required this.slots,
  });

  final String id;
  final String name;
  final String teacher;
  final String room;
  final int colorValue;
  final List<ClassSlot> slots;
}

class ClassSlot {
  const ClassSlot({
    required this.weekday,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  final int weekday;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
}

class ClassEntry {
  ClassEntry({required this.subject, required this.slot, required this.date});

  final Subject subject;
  final ClassSlot slot;
  final DateTime date;
}

class StudyTask {
  StudyTask({
    required this.id,
    required this.title,
    required this.subjectId,
    required this.dueAt,
    required this.progress,
    required this.type,
    this.isDone = false,
  });

  final String id;
  final String title;
  final String subjectId;
  final DateTime dueAt;
  final double progress;
  final String type;
  final bool isDone;

  StudyTask copyWith({
    String? id,
    String? title,
    String? subjectId,
    DateTime? dueAt,
    double? progress,
    String? type,
    bool? isDone,
  }) {
    return StudyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      subjectId: subjectId ?? this.subjectId,
      dueAt: dueAt ?? this.dueAt,
      progress: progress ?? this.progress,
      type: type ?? this.type,
      isDone: isDone ?? this.isDone,
    );
  }
}

class StudyNote {
  StudyNote({
    required this.id,
    required this.title,
    required this.body,
    required this.subjectId,
    required this.updatedAt,
    this.pinned = false,
  });

  final String id;
  final String title;
  final String body;
  final String subjectId;
  final DateTime updatedAt;
  final bool pinned;
}

class StudyReminder {
  StudyReminder({
    required this.id,
    required this.title,
    required this.time,
    this.enabled = true,
  });

  final String id;
  final String title;
  final TimeOfDay time;
  final bool enabled;

  StudyReminder copyWith({
    String? id,
    String? title,
    TimeOfDay? time,
    bool? enabled,
  }) {
    return StudyReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      enabled: enabled ?? this.enabled,
    );
  }
}

class StudySession {
  StudySession({
    required this.id,
    required this.startedAt,
    required this.durationMinutes,
    required this.label,
    this.completed = true,
  });

  final String id;
  final DateTime startedAt;
  final int durationMinutes;
  final String label;
  final bool completed;
}

class StudyAchievement {
  StudyAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.progress,
    required this.unlocked,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final double progress;
  final bool unlocked;
}

class StudyFlowStore extends ChangeNotifier {
  StudyFlowStore({required DateTime Function() nowProvider})
    : _nowProvider = nowProvider {
    selectedDate = DateUtils.dateOnly(_nowProvider());
    _subjects = _seedSubjects();
    _tasks = _seedTasks();
    _notes = _seedNotes();
    _reminders = _seedReminders();
    _sessions = _seedSessions();
    _achievements = _seedAchievements();
  }

  final DateTime Function() _nowProvider;
  final Random _random = Random();

  AppStage stage = AppStage.onboarding;
  int selectedTab = 0;
  CalendarViewMode calendarMode = CalendarViewMode.day;
  late DateTime selectedDate;
  bool notificationsEnabled = true;
  bool isDarkMode = false;
  String userName = 'Minh Anh';
  String semesterName = 'Học kỳ 2 · 2026';
  int _focusPresetMinutes = 25;
  int _focusRemainingSeconds = 25 * 60;
  bool _isFocusRunning = false;
  Timer? _focusTimer;

  late List<Subject> _subjects;
  late List<StudyTask> _tasks;
  late List<StudyNote> _notes;
  late List<StudyReminder> _reminders;
  late List<StudySession> _sessions;
  late List<StudyAchievement> _achievements;

  List<Subject> get subjects => List.unmodifiable(_subjects);
  List<StudyTask> get tasks => List.unmodifiable(_tasks);
  List<StudyNote> get notes => List.unmodifiable(_notes);
  List<StudyReminder> get reminders => List.unmodifiable(_reminders);
  List<StudySession> get sessions => List.unmodifiable(_sessions);
  List<StudyAchievement> get achievements => List.unmodifiable(_achievements);
  int get focusRemainingSeconds => _focusRemainingSeconds;
  int get focusPresetMinutes => _focusPresetMinutes;
  bool get isFocusRunning => _isFocusRunning;
  DateTime get now => _nowProvider();

  double get completionRate {
    if (_tasks.isEmpty) return 0;
    return completedTasksCount / _tasks.length;
  }

  int get completedTasksCount => _tasks.where((task) => task.isDone).length;
  int get pendingTasksCount => _tasks.where((task) => !task.isDone).length;

  int get overdueTasksCount => _tasks.where((task) {
    return !task.isDone &&
        DateUtils.dateOnly(task.dueAt).isBefore(DateUtils.dateOnly(now));
  }).length;

  int get focusMinutesThisWeek {
    final weekAgo = now.subtract(const Duration(days: 7));
    return _sessions
        .where((session) => session.startedAt.isAfter(weekAgo))
        .fold<int>(0, (sum, item) => sum + item.durationMinutes);
  }

  int get streakDays =>
      9 + (_sessions.where((session) => session.completed).length ~/ 2);

  int get notificationCount =>
      overdueTasksCount +
      _reminders.where((reminder) => reminder.enabled).length;

  Subject? subjectById(String id) {
    for (final subject in _subjects) {
      if (subject.id == id) return subject;
    }
    return null;
  }

  List<ClassEntry> classesFor(DateTime date) {
    final result = <ClassEntry>[];
    for (final subject in _subjects) {
      for (final slot in subject.slots.where(
        (slot) => slot.weekday == date.weekday,
      )) {
        result.add(ClassEntry(subject: subject, slot: slot, date: date));
      }
    }
    result.sort((a, b) {
      final lhs = a.slot.startHour * 60 + a.slot.startMinute;
      final rhs = b.slot.startHour * 60 + b.slot.startMinute;
      return lhs.compareTo(rhs);
    });
    return result;
  }

  List<StudyTask> tasksForDay(DateTime date) {
    return _tasks
        .where((task) => DateUtils.isSameDay(task.dueAt, date))
        .toList()
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
  }

  List<StudyTask> get upcomingTasks {
    final nowDate = DateUtils.dateOnly(now);
    return _tasks
        .where(
          (task) =>
              !task.isDone && !DateUtils.dateOnly(task.dueAt).isBefore(nowDate),
        )
        .toList()
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
  }

  List<StudyTask> get overdueTasks {
    final nowDate = DateUtils.dateOnly(now);
    return _tasks
        .where(
          (task) =>
              !task.isDone && DateUtils.dateOnly(task.dueAt).isBefore(nowDate),
        )
        .toList()
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
  }

  List<StudyTask> get todayTasks {
    return tasksForDay(now).where((task) => !task.isDone).toList();
  }

  List<StudyNote> get pinnedNotes =>
      _notes.where((note) => note.pinned).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  List<StudyReminder> get enabledReminders =>
      _reminders.where((reminder) => reminder.enabled).toList();

  void completeOnboarding() {
    stage = AppStage.auth;
    notifyListeners();
  }

  void login({required String displayName, required String email}) {
    final trimmedName = displayName.trim();
    final trimmedEmail = email.trim();
    if (trimmedName.isNotEmpty) {
      userName = trimmedName;
    } else if (trimmedEmail.contains('@')) {
      userName = trimmedEmail.split('@').first;
    }
    stage = AppStage.home;
    notifyListeners();
  }

  void logout() {
    stage = AppStage.auth;
    selectedTab = 0;
    pauseFocus();
    notifyListeners();
  }

  void selectTab(int index) {
    if (selectedTab == index) return;
    selectedTab = index;
    notifyListeners();
  }

  void setCalendarMode(CalendarViewMode mode) {
    if (calendarMode == mode) return;
    calendarMode = mode;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    selectedDate = DateUtils.dateOnly(date);
    notifyListeners();
  }

  void toggleNotifications(bool enabled) {
    notificationsEnabled = enabled;
    notifyListeners();
  }

  void toggleDarkMode(bool enabled) {
    isDarkMode = enabled;
    notifyListeners();
  }

  void resetFocus({int? minutes}) {
    pauseFocus();
    if (minutes != null) {
      _focusPresetMinutes = minutes;
    }
    _focusRemainingSeconds = _focusPresetMinutes * 60;
    notifyListeners();
  }

  void startFocus() {
    if (_isFocusRunning) return;
    _isFocusRunning = true;
    _focusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_focusRemainingSeconds <= 1) {
        _finishFocusCycle();
        return;
      }
      _focusRemainingSeconds -= 1;
      notifyListeners();
    });
    notifyListeners();
  }

  void pauseFocus() {
    _focusTimer?.cancel();
    _focusTimer = null;
    _isFocusRunning = false;
    notifyListeners();
  }

  void _finishFocusCycle() {
    _focusTimer?.cancel();
    _focusTimer = null;
    _isFocusRunning = false;
    _sessions = [
      StudySession(
        id: 'session-${DateTime.now().millisecondsSinceEpoch}',
        startedAt: now,
        durationMinutes: _focusPresetMinutes,
        label: 'Pomodoro $_focusPresetMinutes phút',
      ),
      ..._sessions,
    ];
    _focusRemainingSeconds = _focusPresetMinutes * 60;
    notifyListeners();
  }

  void toggleTaskCompletion(String taskId) {
    _tasks = _tasks
        .map(
          (task) => task.id == taskId
              ? task.copyWith(
                  isDone: !task.isDone,
                  progress: task.isDone ? 0.5 : 1,
                )
              : task,
        )
        .toList();
    notifyListeners();
  }

  void addTask({
    required String title,
    required String subjectId,
    required DateTime dueAt,
  }) {
    _tasks = [
      StudyTask(
        id: 'task-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        subjectId: subjectId,
        dueAt: dueAt,
        progress: 0,
        type: 'Bài tập',
      ),
      ..._tasks,
    ];
    notifyListeners();
  }

  void addSubject({
    required String name,
    required String teacher,
    required String room,
  }) {
    const palette = <int>[
      0xFF10B981,
      0xFF2563EB,
      0xFFF97316,
      0xFF8B5CF6,
      0xFFEF4444,
    ];
    _subjects = [
      ..._subjects,
      Subject(
        id: 'subject-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        teacher: teacher,
        room: room,
        colorValue: palette[_random.nextInt(palette.length)],
        slots: const [],
      ),
    ];
    notifyListeners();
  }

  void addNote({
    required String title,
    required String body,
    required String subjectId,
  }) {
    _notes = [
      StudyNote(
        id: 'note-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        body: body,
        subjectId: subjectId,
        updatedAt: now,
      ),
      ..._notes,
    ];
    notifyListeners();
  }

  void addReminder({required String title, required TimeOfDay time}) {
    _reminders = [
      ..._reminders,
      StudyReminder(
        id: 'reminder-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        time: time,
      ),
    ];
    notifyListeners();
  }

  void toggleReminder(String reminderId) {
    _reminders = _reminders
        .map(
          (reminder) => reminder.id == reminderId
              ? reminder.copyWith(enabled: !reminder.enabled)
              : reminder,
        )
        .toList();
    notifyListeners();
  }

  List<Subject> _seedSubjects() {
    return [
      Subject(
        id: 'uxui',
        name: 'Thiết kế UX/UI',
        teacher: 'Cô Trần Thùy Linh',
        room: 'B3.204',
        colorValue: 0xFF10B981,
        slots: const [
          ClassSlot(
            weekday: DateTime.monday,
            startHour: 7,
            startMinute: 30,
            endHour: 9,
            endMinute: 30,
          ),
          ClassSlot(
            weekday: DateTime.wednesday,
            startHour: 13,
            startMinute: 0,
            endHour: 15,
            endMinute: 0,
          ),
        ],
      ),
      Subject(
        id: 'flutter',
        name: 'Phát triển ứng dụng Flutter',
        teacher: 'Thầy Nguyễn Huy Hoàng',
        room: 'A2.503',
        colorValue: 0xFF2563EB,
        slots: const [
          ClassSlot(
            weekday: DateTime.tuesday,
            startHour: 9,
            startMinute: 45,
            endHour: 11,
            endMinute: 45,
          ),
          ClassSlot(
            weekday: DateTime.thursday,
            startHour: 7,
            startMinute: 30,
            endHour: 9,
            endMinute: 30,
          ),
        ],
      ),
      Subject(
        id: 'pm',
        name: 'Quản lý dự án phần mềm',
        teacher: 'Thầy Phạm Quốc Bảo',
        room: 'C1.102',
        colorValue: 0xFFF97316,
        slots: const [
          ClassSlot(
            weekday: DateTime.friday,
            startHour: 13,
            startMinute: 30,
            endHour: 15,
            endMinute: 30,
          ),
        ],
      ),
      Subject(
        id: 'db',
        name: 'Cơ sở dữ liệu',
        teacher: 'Cô Nguyễn Mai Chi',
        room: 'A1.305',
        colorValue: 0xFF8B5CF6,
        slots: const [
          ClassSlot(
            weekday: DateTime.tuesday,
            startHour: 13,
            startMinute: 0,
            endHour: 15,
            endMinute: 0,
          ),
        ],
      ),
    ];
  }

  List<StudyTask> _seedTasks() {
    final now = _nowProvider();
    return [
      StudyTask(
        id: 'task-1',
        title: 'Hoàn thiện wireframe đăng nhập và onboarding',
        subjectId: 'uxui',
        dueAt: now.add(const Duration(days: 1)),
        progress: 0.65,
        type: 'Thiết kế',
      ),
      StudyTask(
        id: 'task-2',
        title: 'Dựng prototype luồng quản lý deadline',
        subjectId: 'uxui',
        dueAt: now.add(const Duration(days: 3)),
        progress: 0.35,
        type: 'Prototype',
      ),
      StudyTask(
        id: 'task-3',
        title: 'Code màn dashboard và lịch học',
        subjectId: 'flutter',
        dueAt: now.add(const Duration(days: 2)),
        progress: 0.45,
        type: 'Code',
      ),
      StudyTask(
        id: 'task-4',
        title: 'Báo cáo usability testing vòng 1',
        subjectId: 'pm',
        dueAt: now.subtract(const Duration(days: 1)),
        progress: 0.8,
        type: 'Báo cáo',
      ),
      StudyTask(
        id: 'task-5',
        title: 'Chuẩn bị thuyết trình sprint review',
        subjectId: 'pm',
        dueAt: now,
        progress: 1,
        type: 'Thuyết trình',
        isDone: true,
      ),
    ];
  }

  List<StudyNote> _seedNotes() {
    final now = _nowProvider();
    return [
      StudyNote(
        id: 'note-1',
        title: 'Checklist trước buổi review',
        body:
            'Kiểm tra luồng onboarding, nhập deadline, lịch tuần và focus timer trước khi demo.',
        subjectId: 'pm',
        updatedAt: now.subtract(const Duration(hours: 4)),
        pinned: true,
      ),
      StudyNote(
        id: 'note-2',
        title: 'Ý tưởng cải thiện calendar',
        body:
            'Nên có thêm bộ lọc theo môn học và hiển thị task chồng lớp trong tuần.',
        subjectId: 'uxui',
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      StudyNote(
        id: 'note-3',
        title: 'Lưu ý state management',
        body:
            'Tách store cho task, note và reminder nếu app mở rộng sang backend thật.',
        subjectId: 'flutter',
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  List<StudyReminder> _seedReminders() {
    return [
      StudyReminder(
        id: 'reminder-1',
        title: 'Nhắc học buổi sáng',
        time: const TimeOfDay(hour: 6, minute: 45),
      ),
      StudyReminder(
        id: 'reminder-2',
        title: 'Kiểm tra deadline cuối ngày',
        time: const TimeOfDay(hour: 21, minute: 0),
      ),
      StudyReminder(
        id: 'reminder-3',
        title: 'Pomodoro buổi tối',
        time: const TimeOfDay(hour: 19, minute: 30),
        enabled: false,
      ),
    ];
  }

  List<StudySession> _seedSessions() {
    final now = _nowProvider();
    return [
      StudySession(
        id: 'session-1',
        startedAt: now.subtract(const Duration(hours: 2)),
        durationMinutes: 50,
        label: 'Ôn tập deadline Flutter',
      ),
      StudySession(
        id: 'session-2',
        startedAt: now.subtract(const Duration(days: 1, hours: 3)),
        durationMinutes: 25,
        label: 'Pomodoro nhanh trước giờ học',
      ),
      StudySession(
        id: 'session-3',
        startedAt: now.subtract(const Duration(days: 2)),
        durationMinutes: 45,
        label: 'Tổng hợp note UX/UI',
      ),
    ];
  }

  List<StudyAchievement> _seedAchievements() {
    return [
      StudyAchievement(
        id: 'ach-1',
        title: 'Chuỗi 7 ngày',
        description: 'Học liên tục 7 ngày không gián đoạn',
        icon: Icons.local_fire_department_rounded,
        progress: 1,
        unlocked: true,
      ),
      StudyAchievement(
        id: 'ach-2',
        title: 'Deadline Master',
        description: 'Hoàn thành 10 deadline đúng hạn',
        icon: Icons.workspace_premium_rounded,
        progress: 0.7,
        unlocked: false,
      ),
      StudyAchievement(
        id: 'ach-3',
        title: 'Pomodoro Pro',
        description: 'Tích lũy 20 phiên tập trung',
        icon: Icons.timer_rounded,
        progress: 0.55,
        unlocked: false,
      ),
    ];
  }

  @override
  void dispose() {
    _focusTimer?.cancel();
    super.dispose();
  }
}

class StudyFlowScope extends InheritedNotifier<StudyFlowStore> {
  const StudyFlowScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static StudyFlowStore of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<StudyFlowScope>();
    assert(widget != null, 'StudyFlowScope không tồn tại trong context này.');
    return widget!.notifier!;
  }
}
