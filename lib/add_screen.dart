import 'package:flutter/material.dart';
import 'storage_service.dart';
import 'task.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController _infoController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final StorageService _storage = StorageService();

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _saveTask() async {
    if (_selectedDate == null || _selectedTime == null || _infoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    final timeStr =
        "${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}";

    final newTask = Task(
      id: "", // empty → StorageService will generate
      info: _infoController.text,
      date: _selectedDate!,
      time: timeStr,
    );

    await _storage.create(newTask);

    Navigator.pop(context, true); // return true so MainScreen reloads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Task")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _infoController,
              decoration: const InputDecoration(labelText: "Task info"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _pickDate, child: const Text("Pick Date")),
            ElevatedButton(onPressed: _pickTime, child: const Text("Pick Time")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveTask, child: const Text("Save")),
          ],
        ),
      ),
    );
  }
}
