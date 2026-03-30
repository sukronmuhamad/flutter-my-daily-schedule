import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Penting untuk mengolah data JSON

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  List<Map<String, dynamic>> _todoList = [];
  final TextEditingController _titleController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _loadData(); // Panggil data dari memori saat aplikasi dibuka
  }

  // --- LOGIKA PENYIMPANAN DATA ---

  // 1. Fungsi Membaca Data dari Memori HP
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('saved_schedules');

    if (savedData != null) {
      setState(() {
        // Mengubah String kembali menjadi List
        _todoList = List<Map<String, dynamic>>.from(json.decode(savedData));
      });
    }
  }

  // 2. Fungsi Menyimpan Data ke Memori HP
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    // Mengubah List menjadi String agar bisa disimpan
    final String encodedData = json.encode(_todoList);
    await prefs.setString('saved_schedules', encodedData);
  }

  // --- LOGIKA INTERAKSI ---

  void _addTodo(String title) {
    if (title.isEmpty) return;
    setState(() {
      _todoList.insert(0, {
        'title': title,
        'time': _selectedTime.format(context),
        'isDone': false,
      });
    });
    _saveData(); // Simpan setiap kali ada data baru
    _titleController.clear();
    _selectedTime = TimeOfDay.now();
    Navigator.pop(context);
  }

  void _toggleDone(int index) {
    setState(() {
      _todoList[index]['isDone'] = !_todoList[index]['isDone'];
    });
    _saveData(); // Simpan perubahan status centang
  }

  void _deleteTodo(int index) {
    setState(() {
      _todoList.removeAt(index);
    });
    _saveData(); // Simpan setelah penghapusan
  }

  // ... (Sisa kode UI build Anda tetap sama seperti sebelumnya) ...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'My Schedule',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: _todoList.isEmpty
                ? const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.alarm_add, size: 80, color: Colors.grey),
                          SizedBox(height: 10),
                          Text(
                            'Belum ada jadwal. Klik tombol +',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = _todoList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: IconButton(
                            icon: Icon(
                              item['isDone']
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: item['isDone']
                                  ? Colors.green
                                  : Colors.indigo,
                            ),
                            onPressed: () => _toggleDone(index),
                          ),
                          title: Text(
                            item['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: item['isDone']
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(item['time']),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _deleteTodo(index),
                          ),
                        ),
                      );
                    }, childCount: _todoList.length),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(),
        label: const Text('Add Task', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF2575FC),
      ),
    );
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 25,
            right: 25,
            top: 25,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tambah Jadwal',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Nama kegiatan...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ListTile(
                tileColor: Colors.indigo.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                leading: const Icon(Icons.access_time, color: Colors.indigo),
                title: const Text('Waktu Pelaksanaan'),
                trailing: Text(
                  _selectedTime.format(context),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                    fontSize: 16,
                  ),
                ),
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (picked != null) {
                    setModalState(() => _selectedTime = picked);
                    setState(() => _selectedTime = picked);
                  }
                },
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () => _addTodo(_titleController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2575FC),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text('Simpan'),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
