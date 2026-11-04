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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, size: 54, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Suniaramana Mardana Putra',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'NIM: 2455011006 • Kelas TRPL 5A',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.school_outlined, color: Colors.blue),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Teknologi & Arsitektur',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Flutter 3 & Material Design 3\n'
                      '• Provider Pattern + ChangeNotifier\n'
                      '• Supabase Backend (PostgreSQL CRUD)\n'
                      '• REST API Integration (Academic Events & Holidays)\n'
                      '• Responsive UI Layout (< 600px & >= 600px)',
                      style: TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
