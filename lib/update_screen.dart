import 'package:flutter/material.dart';
import 'storage_service.dart';
import 'task.dart';

class UpdateScreen extends StatefulWidget {
  final Task task;
  const UpdateScreen({super.key, required this.task});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  late TextEditingController _infoController;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _infoController = TextEditingController(text: widget.task.info);
    _selectedDate = widget.task.date;

    // Parse "HH:mm" into TimeOfDay
    final parts = widget.task.time.split(":");
    if (parts.length == 2) {
      _selectedTime = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 0,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _updateTask() async {
    if (_selectedDate == null || _selectedTime == null || _infoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    final timeStr =
        "${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}";

    final updatedTask = Task(
      id: widget.task.id, // keep the same ID
      info: _infoController.text,
      date: _selectedDate!,
      time: timeStr,
    );

    await _storage.update(updatedTask);

    Navigator.pop(context, true); // return true so MainScreen reloads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Task")),
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
            ElevatedButton(onPressed: _updateTask, child: const Text("Update")),
          ],
        ),
      ),
    );
  }
}
