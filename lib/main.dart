import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/academic_provider.dart';
import 'providers/task_provider.dart';
import 'screens/main_navigation_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AcademicProvider()..loadInitialData()),
        ChangeNotifierProvider(create: (_) => TaskProvider()..loadInitialData()),
      ],
      child: const StudentManApp(),
    ),
  );
}

class StudentManApp extends StatelessWidget {
  const StudentManApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudentMan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const MainNavigationShell(),
    );
  }
}
