import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddSubjectScreen extends StatefulWidget {
  @override
  _AddSubjectScreenState createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  String _selectedDifficulty = "Easy"; // Default difficulty
  List<Map<String, dynamic>> _subjects = [];
  String? _generatedSchedule;

  final Map<String, int> _difficultyWeights = {
    "Easy": 1,
    "Medium": 2,
    "Hard": 3,
  };

  @override
  void initState() {
    super.initState();
    _loadSubjects();
    _loadGeneratedSchedule();
  }

  Future<void> _saveSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('subjects', jsonEncode(_subjects));
  }

  Future<void> _loadSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    String? subjectsJson = prefs.getString('subjects');
    if (subjectsJson != null) {
      setState(() {
        _subjects = List<Map<String, dynamic>>.from(jsonDecode(subjectsJson));
      });
    }
  }

  Future<void> _loadGeneratedSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedSchedule = prefs.getString('lastSchedule');
    if (savedSchedule != null) {
      setState(() {
        _generatedSchedule = savedSchedule;
      });
    }
  }

  void _addSubject() {
    if (_subjectController.text.isEmpty) return;

    setState(() {
      _subjects.add({
        'name': _subjectController.text,
        'difficulty': _selectedDifficulty,
        'weight': _difficultyWeights[_selectedDifficulty]!,
      });
      _subjectController.clear();
    });

    _saveSubjects();
  }

  void _removeSubject(int index) {
    setState(() {
      _subjects.removeAt(index);
    });
    _saveSubjects();
  }

  Future<void> _generateSchedule() async {
    if (_subjects.isEmpty || _hoursController.text.isEmpty) return;

    int totalHours = int.tryParse(_hoursController.text) ?? 0;
    if (totalHours <= 0) return;

    // Calculate total weight sum
    int totalWeight = _subjects.fold(0, (sum, subject) => sum + (subject['weight'] as int));

    // Distribute hours based on difficulty weight
    StringBuffer schedule = StringBuffer();
    for (var subject in _subjects) {
      int allocatedHours = ((subject['weight'] / totalWeight) * totalHours).floor();
      schedule.writeln("${subject['name']} - ${allocatedHours} hours (${subject['difficulty']})");
    }

    setState(() {
      _generatedSchedule = schedule.toString();
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastSchedule', _generatedSchedule!);
  }

  void _showGeneratedSchedule() {
    if (_generatedSchedule == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No schedule generated yet!")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Generated Schedule"),
        content: Text(_generatedSchedule!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Subjects")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(labelText: "Subject Name"),
            ),
            DropdownButton<String>(
              value: _selectedDifficulty,
              onChanged: (newValue) {
                setState(() {
                  _selectedDifficulty = newValue!;
                });
              },
              items: ["Easy", "Medium", "Hard"]
                  .map((difficulty) => DropdownMenuItem(
                        value: difficulty,
                        child: Text(difficulty),
                      ))
                  .toList(),
            ),
            ElevatedButton(
              onPressed: _addSubject,
              child: Text("Add Subject"),
            ),
            TextField(
              controller: _hoursController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Total Hours Available"),
            ),
            ElevatedButton(
              onPressed: _generateSchedule,
              child: Text("Generate Schedule"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _showGeneratedSchedule,
              child: Text("Show Generated Schedule"),
            ),
            SizedBox(height: 20),
            _generatedSchedule != null
                ? Text(
                    "Last Generated Schedule:\n$_generatedSchedule",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                : Container(),
            Expanded(
              child: ListView.builder(
                itemCount: _subjects.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_subjects[index]['name']!),
                    subtitle: Text("Difficulty: ${_subjects[index]['difficulty']}"),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeSubject(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
