import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student_task_model.dart';
import '../providers/task_provider.dart';

class AddTaskScreen extends StatefulWidget {
  final String? initialTitle;
  final String? initialDeadline;
  final String? initialNotes;
  final String initialCategory;

  const AddTaskScreen({
    super.key,
    this.initialTitle,
    this.initialDeadline,
    this.initialNotes,
    this.initialCategory = 'Tugas Kuliah',
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _courseController;
  late final TextEditingController _titleController;
  late final TextEditingController _deadlineController;
  late final TextEditingController _notesController;

  late String _selectedCategory;
  String _priority = 'Sedang';
  String _status = 'Pending';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _courseController = TextEditingController();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _deadlineController = TextEditingController(
      text: widget.initialDeadline ?? '',
    );
    _notesController = TextEditingController(text: widget.initialNotes ?? '');
  }

  @override
  void dispose() {
    _courseController.dispose();
    _titleController.dispose();
    _deadlineController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      final formatted =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        _deadlineController.text = formatted;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final rawCourse = _courseController.text.trim();
    final finalCourse = _selectedCategory == 'Kegiatan Kegiatan'
        ? '[Kegiatan] $rawCourse'
        : rawCourse;

    final newTask = StudentTaskModel(
      courseName: finalCourse,
      taskTitle: _titleController.text.trim(),
      deadlineDate: _deadlineController.text.trim(),
      priority: _priority,
      taskStatus: _status,
      notes: _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    final success = await context.read<TaskProvider>().createTask(newTask);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        final successMsg = _selectedCategory == 'Kegiatan Kegiatan'
            ? 'Agenda Kegiatan "$rawCourse" berhasil disimpan!'
            : 'Tugas kuliah berhasil disimpan ke database!';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMsg),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan jadwal. Silakan periksa koneksi.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOrg = _selectedCategory == 'Kegiatan Kegiatan';

    return Scaffold(
      appBar: AppBar(
        title: Text(isOrg ? 'Tambah Agenda Kegiatan' : 'Tambah Tugas Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pemilihan Tipe Jadwal (Tugas Kuliah vs Kegiatan Kegiatan)
              Text(
                'Pilih Kategori Jadwal:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'Tugas Kuliah',
                    icon: Icon(Icons.school_outlined),
                    label: Text('Tugas Kuliah'),
                  ),
                  ButtonSegment(
                    value: 'Kegiatan Kegiatan',
                    icon: Icon(Icons.groups_rounded),
                    label: Text('Kegiatan'),
                  ),
                ],
                selected: {_selectedCategory},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedCategory = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 20),
              // Field 1: Mata Kuliah ATAU Kegiatan
              TextFormField(
                controller: _courseController,
                decoration: InputDecoration(
                  labelText: isOrg
                      ? 'Nama Kegiatan / Divisi *'
                      : 'Mata Kuliah *',
                  hintText: isOrg
                      ? 'Contoh: BEM TRPL / HIMA / Divisi Acara'
                      : 'Contoh: Workshop Pemrograman Mobile',
                  prefixIcon: Icon(
                    isOrg ? Icons.groups_rounded : Icons.school_outlined,
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().length < 3) {
                    return isOrg
                        ? 'Nama Kegiatan minimal 3 karakter'
                        : 'Mata kuliah minimal 3 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Field 2: Judul Tugas ATAU Nama Agenda
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: isOrg
                      ? 'Nama Agenda / Kegiatan *'
                      : 'Judul Tugas *',
                  hintText: isOrg
                      ? 'Contoh: Rapat Pleno Koordinasi Acara'
                      : 'Contoh: Membuat Dokumen PRD dan CRUD',
                  prefixIcon: Icon(
                    isOrg
                        ? Icons.event_available_rounded
                        : Icons.assignment_outlined,
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().length < 5) {
                    return isOrg
                        ? 'Nama kegiatan minimal 5 karakter'
                        : 'Judul tugas minimal 5 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Field 3: Tanggal
              TextFormField(
                controller: _deadlineController,
                readOnly: true,
                onTap: _pickDeadline,
                decoration: InputDecoration(
                  labelText: isOrg
                      ? 'Tanggal Pelaksanaan Kegiatan *'
                      : 'Tenggat Waktu (Deadline) *',
                  hintText: isOrg
                      ? 'Pilih tanggal kegiatan'
                      : 'Pilih tanggal deadline',
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.date_range_rounded),
                    onPressed: _pickDeadline,
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Pilih tanggal kegiatan/deadline';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _priority,
                      decoration: const InputDecoration(
                        labelText: 'Prioritas',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Rendah',
                          child: Text('Rendah'),
                        ),
                        DropdownMenuItem(
                          value: 'Sedang',
                          child: Text('Sedang'),
                        ),
                        DropdownMenuItem(
                          value: 'Tinggi',
                          child: Text('Tinggi'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _priority = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Pending',
                          child: Text('Pending / Rencana'),
                        ),
                        DropdownMenuItem(
                          value: 'In Progress',
                          child: Text('In Progress / Berlangsung'),
                        ),
                        DropdownMenuItem(
                          value: 'Selesai',
                          child: Text('Selesai'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _status = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: isOrg
                      ? 'Catatan / Rundown Agenda'
                      : 'Catatan Tambahan',
                  hintText: isOrg
                      ? 'Lokasi ruangan, link Zoom, atau detail rundown...'
                      : 'Detail spesifikasi atau link referensi...',
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _saveTask,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          isOrg
                              ? Icons.event_available_rounded
                              : Icons.save_rounded,
                        ),
                  label: Text(
                    _isSubmitting
                        ? 'Menyimpan...'
                        : (isOrg ? 'Simpan Agenda Kegiatan' : 'Simpan Tugas'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
