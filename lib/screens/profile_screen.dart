import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Mahasiswa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Suniaramana Mardana Putra',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'NIM: 2455011006 • Kelas TRPL 5A',
              style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.school_outlined, color: Colors.blue),
                    title: Text('Program Studi'),
                    subtitle: Text('Teknologi Rekayasa Perangkat Lunak (TRPL)'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.menu_book_rounded, color: Colors.deepPurple),
                    title: Text('Mata Kuliah'),
                    subtitle: Text('Workshop Pemrograman Mobile (UTS)'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.person_pin_outlined, color: Colors.green),
                    title: Text('Dosen Pengampu'),
                    subtitle: Text('Dr. Ir. I Ketut Resika Arthana, S.T., M.Kom'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.support_agent_outlined, color: Colors.orange),
                    title: Text('Asisten Dosen'),
                    subtitle: Text('Made Yuda Sadewa, S.Pd.'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.architecture_rounded, color: Colors.teal),
                        SizedBox(width: 8),
                        Text(
                          'Teknologi & Arsitektur Aplikasi',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      '• Framework: Flutter 3 & Dart\n'
                      '• UI Kit: Material Design 3 Responsive Layout (< 600px & >= 600px)\n'
                      '• State Management: Provider Pattern + ChangeNotifier\n'
                      '• Database: Supabase PostgreSQL (Full CRUD Operations)\n'
                      '• Web API: HTTP GET Kalender Akademik & Libur Nasional\n'
                      '• Clean Architecture: Screen -> Provider -> Repository -> Service',
                      style: TextStyle(height: 1.6),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const ListTile(
                leading: Icon(Icons.info_outline_rounded, color: Colors.blueAccent),
                title: Text('Aplikasi StudentMan v1.0.0'),
                subtitle: Text('UTS Pemrograman Mobile © 2026 Suniaramana Mardana Putra'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
