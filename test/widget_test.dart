import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:studentman/main.dart';
import 'package:studentman/providers/academic_provider.dart';
import 'package:studentman/providers/task_provider.dart';

void main() {
  testWidgets('StudentMan app boots smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AcademicProvider()),
          ChangeNotifierProvider(create: (_) => TaskProvider()),
        ],
        child: const StudentManApp(),
      ),
    );

    // Verify Dashboard title or Navigation bar elements exist
    expect(find.text('Dashboard'), findsWidgets);
  });
}
