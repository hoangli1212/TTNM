import 'package:flutter_test/flutter_test.dart';

import 'package:studyflow_flutter/src/app.dart';

void main() {
  testWidgets('StudyFlow renders onboarding screen', (tester) async {
    await tester.pumpWidget(const StudyFlowBootstrap());

    expect(find.text('StudyFlow'), findsOneWidget);
    expect(find.text('Quản lý lịch học thông minh'), findsOneWidget);
  });
}
