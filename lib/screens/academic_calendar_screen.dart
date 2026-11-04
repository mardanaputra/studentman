import 'package:flutter/material.dart';
import 'academic_detail_screen.dart';

class AcademicCalendarScreen extends StatelessWidget {
  const AcademicCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sampleAgendas = [
      {
        'title': 'Pekan Ujian Tengah Semester (UTS)',
        'date': '2026-11-10',
        'category': 'Akademik',
        'description': 'Pelaksanaan UTS Semester Ganjil TA 2026/2027 seluruh program studi TRPL.',
      },
      {
        'title': 'Batas Pengumpulan Project Workshop Mobile',
        'date': '2026-11-14',
        'category': 'Tugas Kuliah',
        'description': 'Pengumpulan laporan, repository git minimal 16 commit, dan file APK rilis.',
      },
      {
        'title': 'Hari Raya & Libur Bersama',
        'date': '2026-11-20',
        'category': 'Libur Nasional',
        'description': 'Kegiatan perkuliahan diliburkan sesuai kalender libur nasional pemerintah.',
      },
      {
        'title': 'Batas Akhir Input Nilai UTS',
        'date': '2026-11-25',
        'category': 'Akademik',
        'description': 'Dosen menginput nilai UTS ke sistem informasi akademik kampus.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda & Kalender Akademik'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sampleAgendas.length,
        itemBuilder: (context, index) {
          final item = sampleAgendas[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(item['title']!),
              subtitle: Text("${item['date']} • ${item['category']}"),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AcademicDetailScreen(
                      title: item['title']!,
                      date: item['date']!,
                      category: item['category']!,
                      description: item['description']!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
