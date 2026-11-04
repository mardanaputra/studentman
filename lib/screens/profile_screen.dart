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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            // User Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF2563EB), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: const Color(0xFFEFF6FF),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 56,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.check, size: 12, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Suniaramana Mardana Putra',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'NIM: 2455011006 • Kelas TRPL 5A',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Akademik Details
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildProfileTile(
                    icon: Icons.school_outlined,
                    iconColor: const Color(0xFF2563EB),
                    bgColor: const Color(0xFFEFF6FF),
                    title: 'Program Studi',
                    subtitle: 'Teknologi Rekayasa Perangkat Lunak',
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF1F5F9)),
                  _buildProfileTile(
                    icon: Icons.laptop_chromebook_rounded,
                    iconColor: const Color(0xFF7C3AED),
                    bgColor: const Color(0xFFF5F3FF),
                    title: 'Mata Kuliah',
                    subtitle: 'Workshop Pemrograman Mobile (UTS)',
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF1F5F9)),
                  _buildProfileTile(
                    icon: Icons.person_pin_outlined,
                    iconColor: const Color(0xFF059669),
                    bgColor: const Color(0xFFECFDF5),
                    title: 'Dosen Pengampu',
                    subtitle: 'Dr. Ir. I Ketut Resika Arthana, S.T., M.Kom',
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF1F5F9)),
                  _buildProfileTile(
                    icon: Icons.support_agent_rounded,
                    iconColor: const Color(0xFFD97706),
                    bgColor: const Color(0xFFFFFBEB),
                    title: 'Asisten Dosen',
                    subtitle: 'Made Yuda Sadewa, S.Pd.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Teknologi & Arsitektur
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDFA),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.architecture_rounded, color: Color(0xFF0D9488), size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Arsitektur & Spesifikasi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildBadgeRow('Framework', 'Flutter 3 & Dart'),
                  _buildBadgeRow('State Management', 'Provider + ChangeNotifier'),
                  _buildBadgeRow('Database Backend', 'Supabase Cloud (PostgreSQL CRUD)'),
                  _buildBadgeRow('External API', 'Nager.Date v3 & Vercel API'),
                  _buildBadgeRow('Responsive Layout', 'Compact (< 600px) & Wide (>= 600px)'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Footer App version
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF64748B)),
                  SizedBox(width: 10),
                  Text(
                    'StudentMan v1.0.0 • Pemrograman Mobile TRPL',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF0D9488),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4),
                children: [
                  TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
