import 'package:flutter/material.dart';

import 'core/date_labels.dart';
import 'core/theme/app_theme.dart';
import 'data/studyflow_store.dart';
import 'screens/app_shell.dart';
import 'screens/auth_screen.dart';
import 'screens/onboarding_screen.dart';

class StudyFlowBootstrap extends StatefulWidget {
  const StudyFlowBootstrap({super.key});

  @override
  State<StudyFlowBootstrap> createState() => _StudyFlowBootstrapState();
}

class _StudyFlowBootstrapState extends State<StudyFlowBootstrap> {
  late final StudyFlowStore _store;

  @override
  void initState() {
    super.initState();
    _store = StudyFlowStore(nowProvider: DateTime.now);
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StudyFlowScope(
      notifier: _store,
      child: StudyFlowApp(store: _store),
    );
  }
}

class StudyFlowApp extends StatelessWidget {
  const StudyFlowApp({super.key, required this.store});

  final StudyFlowStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'StudyFlow',
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: store.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: switch (store.stage) {
            AppStage.onboarding => const OnboardingScreen(),
            AppStage.auth => const AuthScreen(),
            AppStage.home => const AppShell(),
          },
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.noScaling),
              child: child!,
            );
          },
          onGenerateTitle: (_) =>
              'StudyFlow · ${StudyDateLabels.weekdayShort(DateTime.now().weekday)}',
        );
      },
    );
  }
}
