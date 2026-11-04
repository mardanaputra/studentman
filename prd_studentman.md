# Product Requirement Document (PRD)
## StudentMan - Student Task & Management Activity Schedule Reminder

---

### 1. Project Overview & Metadata

* **Project Name**: StudentMan
* **Repository / Folder Name**: `StudentMan_WorkshopMobile` (Folder lokal kerja: `studentman`)
* **Author / Developer**: Suniaramana Mardana Putra
* **NIM**: 2455011006
* **Class**: TRPL 5A
* **Course**: Pemrograman Mobile (Ujian Tengah Semester)
* **Lecturer**: Dr. Ir. I Ketut Resika Arthana, S.T., M.Kom
* **Teaching Assistant**: Made Yuda Sadewa, S.Pd.
* **Target Platform**: Android (Mobile APK) & Tablet/Desktop Responsive

---

### 2. Core Requirements & Rubric Compliance Matrix

| No | Modul / Komponen | Spesifikasi Minimum Dokumen UTS | Target Implementasi StudentMan |
| :--- | :--- | :--- | :--- |
| 1 | **Total Screen** | Minimal 6 screen fungsional (Splash tidak dihitung) | **7 Screen**: Home/Dashboard, Academic Calendar (API List), Calendar Event Detail, Task List (DB), Add Task (Form Create), Edit Task (Form Update), Profile Mahasiswa |
| 2 | **Reusable Widgets** | Minimal 3 reusable custom widgets | 1. `TaskCardItem` <br> 2. `PriorityStatusBadge` <br> 3. `StateFeedbackPlaceholder` (Loading/Empty/Error) |
| 3 | **Responsive Layout** | Minimal 2 kondisi layout (`compact` & `wide`) | Layar < 600px: Single-column vertical list.<br>Layar >= 600px: Multi-column grid / Two-pane master-detail via `LayoutBuilder`. Tidak boleh ada `RenderFlex overflow`. |
| 4 | **REST API** | Minimal 1 REST API, operasi GET, Dart Model | Mengambil data hari libur nasional / agenda akademik / quote motivasi belajar via HTTP GET. JSON diparsing ke Model `AcademicEventModel`. |
| 5 | **Database Backend** | Minimal 1 Backend DB (Supabase), 1 tabel $\ge$ 4 field + PK, Full CRUD | Supabase PostgreSQL: Tabel `student_tasks` (`id`, `course_name`, `task_title`, `deadline_date`, `priority`, `task_status`, `notes`, `created_at`). Full CRUD + Dialog konfirmasi hapus. |
| 6 | **State Management** | Provider + ChangeNotifier (Tidak full `setState`) | `TaskProvider` & `AcademicProvider`. Mengelola loading state, data state, error state, serta filter status tugas. |
| 7 | **Architecture** | Clean Architecture (Screen $\rightarrow$ Provider $\rightarrow$ Repository $\rightarrow$ Service $\rightarrow$ Data Source) | Strict Separation of Concerns: Screen tidak memanggil HTTP / Supabase secara langsung. |
| 8 | **Form & Feedback** | 1 Form validasi, 4 interaksi, SnackBar/Dialog | Validasi minimal 5 karakter, Date/Time picker, dropdown selector, SnackBar sukses/gagal, AlertDialog konfirmasi delete. |
| 9 | **Git Workflow** | Minimal 16 meaningful commits bertahap | 16 milestone commit terjadwal sesuai timeline pengembangan. |

---

### 3. Application Architecture & Folder Structure

Hierarki direktori di dalam workspace `studentman`:

```text
studentman/
├── android/
├── assets/
│   ├── icons/
│   └── images/
├── lib/
│   ├── models/
│   │   ├── academic_event_model.dart       # Model JSON REST API
│   │   └── student_task_model.dart         # Model CRUD Supabase
│   ├── services/
│   │   ├── api_service.dart                # Client HTTP (GET)
│   │   └── supabase_service.dart           # Client Supabase DB
│   ├── repositories/
│   │   ├── academic_repository.dart        # Abstraksi data event
│   │   └── task_repository.dart            # Abstraksi data task
│   ├── providers/
│   │   ├── academic_provider.dart          # State agenda/kalender
│   │   └── task_provider.dart              # State CRUD tasks & filter
│   ├── screens/
│   │   ├── main_navigation_shell.dart      # NavigationBar / Shell
│   │   ├── home_dashboard_screen.dart      # Screen 1: Dashboard
│   │   ├── academic_calendar_screen.dart   # Screen 2: List Agenda (API)
│   │   ├── academic_detail_screen.dart     # Screen 3: Detail Agenda
│   │   ├── task_list_screen.dart           # Screen 4: List Tasks (DB)
│   │   ├── add_task_screen.dart            # Screen 5: Form Add Task
│   │   ├── edit_task_screen.dart           # Screen 6: Form Edit Task
│   │   └── profile_screen.dart             # Screen 7: Info Mahasiswa
│   ├── widgets/
│   │   ├── task_card_item.dart             # Reusable Widget 1
│   │   ├── priority_status_badge.dart      # Reusable Widget 2
│   │   ├── state_feedback_placeholder.dart # Reusable Widget 3
│   │   └── responsive_layout_builder.dart  # Helper responsif
│   └── main.dart                           # Entry point & MultiProvider
├── .env.example
├── .gitignore
├── pubspec.yaml
└── README.md
```

---

### 4. Data Specification & Database Schema

#### A. REST API (Katalog Global / GET)
* **Endpoint Referensi**: Public API Hari Libur Nasional Indonesia / Kalender Akademik JSON:
  * URL Alternatif: `https://api-harilibur.vercel.app/api` atau MockAPI custom endpoint.
* **Struktur Data Model (`academic_event_model.dart`)**:
  ```dart
  class AcademicEventModel {
    final String id;
    final String title;
    final String eventDate;
    final String category;
    final String description;

    AcademicEventModel({
      required this.id,
      required this.title,
      required this.eventDate,
      required this.category,
      required this.description,
    });

    factory AcademicEventModel.fromJson(Map<String, dynamic> json) { ... }
  }
  ```

#### B. Supabase PostgreSQL Schema (`student_tasks`)
Jalankan query DDL ini di Supabase SQL Editor:
```sql
CREATE TABLE student_tasks (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  course_name VARCHAR(100) NOT NULL,
  task_title VARCHAR(150) NOT NULL,
  deadline_date VARCHAR(50) NOT NULL,
  priority VARCHAR(20) NOT NULL DEFAULT 'Sedang',
  task_status VARCHAR(20) NOT NULL DEFAULT 'Pending',
  notes TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Kebijakan RLS (Row Level Security) untuk akses anonim tugas UTS
ALTER TABLE student_tasks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow anon read, insert, update, delete"
ON student_tasks FOR ALL
USING (true)
WITH CHECK (true);
```

---

### 5. Screen Specifications & User Flow

```
[Bottom Navigation Bar]
  ├── Tab 1: Home Dashboard Screen
  │     ├── Ringkasan Statistik Tugas (Pending, In Progress, Selesai)
  │     ├── Banner Pengingat Deadline Terdekat
  │     └── Quick List 2 Event Akademik Terdekat (dari REST API)
  │
  ├── Tab 2: Academic Calendar Screen (REST API GET)
  │     ├── List / Grid responsif agenda akademik & libur nasional
  │     ├── Filter kategori
  │     └── Tap Card ➔ Academic Detail Screen
  │           └── Fitur: "Buat Pengingat Terkait" ➔ Direct ke Add Task Screen
  │
  ├── Tab 3: Task List Screen (Supabase CRUD)
  │     ├── Filter bar status (Semua, Pending, In Progress, Completed)
  │     ├── Floating Action Button (FAB) ➔ Add Task Screen (Create)
  │     ├── Tombol Edit per Card ➔ Edit Task Screen (Update)
  │     └── Tombol Hapus per Card ➔ AlertDialog Konfirmasi ➔ Delete dari Supabase
  │
  └── Tab 4: Profile Mahasiswa Screen
        ├── Nama: Suniaramana Mardana Putra
        ├── NIM: 2455011006 | Kelas: TRPL 5A
        └── Keterangan Teknologi & Arsitektur UTS
```

---

### 6. Security & Credential Rules (Sangat Penting)

* **Dilarang keras melakukan commit `service_role` secret key!**
* Gunakan hanya **Project URL** dan **Anon Public Key** Supabase.
* Simpan konfigurasi koneksi di file konfigurasi terisolasi (misal `lib/services/supabase_service.dart` atau `.env`).

---

### 7. Meaningful Commits Roadmap (Wajib Minimal 16 Commit)

Lakukan commit satu per satu saat setiap fase selesai di Antigravity:

| Step | Milestone | Perintah Git & Pesan Commit |
| :---: | :--- | :--- |
| **1** | Project Initialization | `git commit -m "Initialize Flutter UTS project"` |
| **2** | Architecture Setup | `git commit -m "Setup project architecture and folders"` |
| **3** | Basic UI Shell | `git commit -m "Build initial application UI"` |
| **4** | Responsive Layout | `git commit -m "Implement responsive layouts"` |
| **5** | Navigation Flow | `git commit -m "Add application navigation"` |
| **6** | Data Models | `git commit -m "Add application data models"` |
| **7** | State Management | `git commit -m "Implement application state management"` |
| **8** | REST API Integration | `git commit -m "Integrate REST API"` |
| **9** | Database Integration | `git commit -m "Integrate backend database"` |
| **10** | Create Feature | `git commit -m "Implement create data feature"` |
| **11** | Update Feature | `git commit -m "Implement update data feature"` |
| **12** | Delete Feature | `git commit -m "Implement delete data feature"` |
| **13** | User Interaction | `git commit -m "Add interaction and user feedback"` |
| **14** | Error Handling | `git commit -m "Add loading and error handling"` |
| **15** | UI Refinement | `git commit -m "Improve UI and responsive behavior"` |
| **16** | Final Release | `git commit -m "Finalize UTS mobile application"` |

---

### 8. Final Deliverables Checklist

- [ ] Repository GitHub publik dengan nama `UTS_2455011006_Suniaramana`.
- [ ] Riwayat `git log --oneline` menunjukkan $\ge$ 16 commit bertahap.
- [ ] File APK rilis dengan nama `UTS_2455011006_Suniaramana.apk`.
- [ ] Dokumen laporan PDF `UTS_2455011006_Suniaramana.pdf` berisi screenshot 7 screen dan arsitektur.
- [ ] `README.md` lengkap di root repository.