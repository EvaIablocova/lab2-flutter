import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'add_screen.dart';
import 'update_screen.dart';
import 'storage_service.dart';
import 'task.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final StorageService _storage = StorageService();
  List<Task> _tasks = [];

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _storage.readAll();
    setState(() => _tasks = tasks);
  }

  Future<void> _deleteTask(String id) async {
    await _storage.delete(id);
    _loadTasks();
  }

  // Фильтруем задачи по выбранному дню
  List<Task> get _tasksForSelectedDay {
    if (_selectedDay == null) return [];
    return _tasks.where((t) {
      return t.date.year == _selectedDay!.year &&
          t.date.month == _selectedDay!.month &&
          t.date.day == _selectedDay!.day;
    }).toList()
      ..sort((a, b) => a.time.compareTo(b.time)); // сортировка по времени
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task organizer"),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            headerStyle: const HeaderStyle(formatButtonVisible: false),
          ),
          const Divider(),
          Expanded(
            child: _tasksForSelectedDay.isEmpty
                ? const Center(child: Text("No tasks for this day"))
                : ListView.builder(
              itemCount: _tasksForSelectedDay.length,
              itemBuilder: (context, index) {
                final task = _tasksForSelectedDay[index];
                return Card(
                  child: ListTile(
                    title: Text(task.info),
                    subtitle: Text(
                        "${task.date.toLocal().toString().split(' ')[0]} at ${task.time}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UpdateScreen(task: task),
                              ),
                            );
                            if (updated == true) _loadTasks();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTask(task.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddScreen()),
          );
          if (added == true) _loadTasks();
        },
      ),
    );
  }
}
