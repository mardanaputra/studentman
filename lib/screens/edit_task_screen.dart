import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student_task_model.dart';
import '../providers/task_provider.dart';

class EditTaskScreen extends StatefulWidget {
  final int? taskId;
  final String courseName;
  final String title;
  final String deadlineDate;
  final String priority;
  final String status;
  final String notes;

  const EditTaskScreen({
    super.key,
    this.taskId,
    required this.courseName,
    required this.title,
    required this.deadlineDate,
    required this.priority,
    required this.status,
    required this.notes,
  });

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _courseController;
  late final TextEditingController _titleController;
  late final TextEditingController _deadlineController;
  late final TextEditingController _notesController;

  late String _selectedCategory;
  late String _priority;
  late String _status;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final isOrg = widget.courseName.startsWith('[Kegiatan]');
    _selectedCategory = isOrg ? 'Kegiatan Kegiatan' : 'Tugas Kuliah';

    final cleanCourse = widget.courseName
        .replaceFirst('[Kegiatan] ', '')
        .replaceFirst('[Kegiatan]', '');

    _courseController = TextEditingController(text: cleanCourse);
    _titleController = TextEditingController(text: widget.title);
    _deadlineController = TextEditingController(text: widget.deadlineDate);
    _notesController = TextEditingController(text: widget.notes);
    _priority = widget.priority;
    _status = widget.status;
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

  Future<void> _updateTask() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final rawCourse = _courseController.text.trim();
    final finalCourse = _selectedCategory == 'Kegiatan Kegiatan'
        ? '[Kegiatan] $rawCourse'
        : rawCourse;

    final updatedTask = StudentTaskModel(
      id: widget.taskId,
      courseName: finalCourse,
      taskTitle: _titleController.text.trim(),
      deadlineDate: _deadlineController.text.trim(),
      priority: _priority,
      taskStatus: _status,
      notes: _notesController.text.trim(),
    );

    final success = await context.read<TaskProvider>().updateTask(updatedTask);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perubahan berhasil diperbarui di database!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memperbarui jadwal. Silakan periksa koneksi.'),
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
        title: Text(isOrg ? 'Edit Agenda Kegiatan' : 'Edit Tugas'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Segmented selector
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
              TextFormField(
                controller: _courseController,
                decoration: InputDecoration(
                  labelText: isOrg
                      ? 'Nama Kegiatan / Divisi *'
                      : 'Mata Kuliah *',
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
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: isOrg
                      ? 'Nama Agenda / Kegiatan *'
                      : 'Judul Tugas *',
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
              TextFormField(
                controller: _deadlineController,
                readOnly: true,
                onTap: _pickDeadline,
                decoration: InputDecoration(
                  labelText: isOrg
                      ? 'Tanggal Pelaksanaan Kegiatan *'
                      : 'Tenggat Waktu (Deadline) *',
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
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _updateTask,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline_rounded),
                  label: Text(
                    _isSubmitting ? 'Menyimpan...' : 'Simpan Perubahan',
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
