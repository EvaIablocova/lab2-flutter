import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';
import 'task.dart';

class StorageService {
  // Name of the XML file
  static const String _fileName = 'tasks2.xml';

  // Get the file in the app's documents directory (safe on iOS/Android)
  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');
    if (!await file.exists()) {
      await file.writeAsString('<tasks></tasks>');
    }
    return file;
  }

  // Create a new task. If task.id is empty, generate one.
  Future<Task> create(Task task) async {
    final file = await _getFile();
    final doc = XmlDocument.parse(await file.readAsString());

    final String id = (task.id.isEmpty)
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : task.id;

    final builder = XmlBuilder();
    builder.element('task', attributes: {'id': id}, nest: () {
      builder.element('date', nest: task.date.toIso8601String());
      builder.element('time', nest: task.time);
      builder.element('info', nest: task.info);
    });

    doc.rootElement.children.add(builder.buildFragment());
    await file.writeAsString(doc.toXmlString(pretty: true));

    return Task(id: id, info: task.info, date: task.date, time: task.time);
  }

  // Read all tasks
  Future<List<Task>> readAll() async {
    final file = await _getFile();
    final doc = XmlDocument.parse(await file.readAsString());

    return doc.findAllElements('task').map((t) {
      final id = t.getAttribute('id') ?? '';
      final info = t.getElement('info')?.innerText ?? '';
      final time = t.getElement('time')?.innerText ?? '';
      final dateText = t.getElement('date')?.innerText ?? DateTime.now().toIso8601String();
      final date = DateTime.parse(dateText);

      return Task(id: id, info: info, date: date, time: time);
    }).toList();
  }

  // Read a single task by id
  Future<Task?> readById(String id) async {
    final file = await _getFile();
    final doc = XmlDocument.parse(await file.readAsString());

    final matches = doc.findAllElements('task').where((e) => e.getAttribute('id') == id);
    if (matches.isEmpty) return null;

    final t = matches.first;
    final info = t.getElement('info')?.innerText ?? '';
    final time = t.getElement('time')?.innerText ?? '';
    final dateText = t.getElement('date')?.innerText ?? DateTime.now().toIso8601String();
    final date = DateTime.parse(dateText);

    return Task(id: id, info: info, date: date, time: time);
  }

  // Update an existing task (matched by id)
  Future<void> update(Task task) async {
    final file = await _getFile();
    final doc = XmlDocument.parse(await file.readAsString());

    final node = doc.findAllElements('task').firstWhere(
          (e) => e.getAttribute('id') == task.id,
      orElse: () => throw Exception('Task not found: ${task.id}'),
    );

    node.getElement('date')?.innerText = task.date.toIso8601String();
    node.getElement('time')?.innerText = task.time;
    node.getElement('info')?.innerText = task.info;

    await file.writeAsString(doc.toXmlString(pretty: true));
  }

  // Delete a task by id
  Future<void> delete(String id) async {
    final file = await _getFile();
    final doc = XmlDocument.parse(await file.readAsString());

    final nodes = doc.findAllElements('task').where((e) => e.getAttribute('id') == id).toList();
    if (nodes.isEmpty) return;

    for (final n in nodes) {
      n.parent?.children.remove(n);
    }

    await file.writeAsString(doc.toXmlString(pretty: true));
  }

  // Optional: clear all tasks (resets file)
  Future<void> clear() async {
    final file = await _getFile();
    await file.writeAsString('<tasks></tasks>');
  }

}

