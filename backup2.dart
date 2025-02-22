import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddSubjectScreen extends StatefulWidget {
  @override
  _AddSubjectScreenState createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final TextEditingController _subjectController = TextEditingController();
  String _selectedDifficulty = "Easy"; // Default difficulty
  List<Map<String, String>> _subjects = [];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  // Save subjects to SharedPreferences
  Future<void> _saveSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('subjects', jsonEncode(_subjects));
  }

  // Load subjects from SharedPreferences
  Future<void> _loadSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    String? subjectsJson = prefs.getString('subjects');
    if (subjectsJson != null) {
      setState(() {
        _subjects = List<Map<String, String>>.from(jsonDecode(subjectsJson));
      });
    }
  }

  // Add subject to the list
  void _addSubject() {
    if (_subjectController.text.isEmpty) return;
    
    setState(() {
      _subjects.add({
        'name': _subjectController.text,
        'difficulty': _selectedDifficulty,
      });
      _subjectController.clear();
    });

    _saveSubjects(); // Save updated list
  }

  // Remove subject
  void _removeSubject(int index) {
    setState(() {
      _subjects.removeAt(index);
    });
    _saveSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Subjects")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Subject Name Input
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(labelText: "Subject Name"),
            ),
            
            // Difficulty Dropdown
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

            SizedBox(height: 10),

            // Add Button
            ElevatedButton(
              onPressed: _addSubject,
              child: Text("Add Subject"),
            ),

            SizedBox(height: 20),

            // Display List of Subjects
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
