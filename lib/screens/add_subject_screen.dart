import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;



class AddSubjectScreen extends StatefulWidget {
  @override
  _AddSubjectScreenState createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final TextEditingController _subjectController = TextEditingController();
  String _selectedDifficulty = "Easy";
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _timeSlots = [];
  Map<String, String> _schedule = {};

  final Map<String, int> _difficultyWeights = {
    "Easy": 1,
    "Medium": 2,
    "Hard": 3,
  };

  @override
  void initState() {
    super.initState();
    _loadSubjects();
    _loadTimeSlots();
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

  Future<void> _loadTimeSlots() async {
    final prefs = await SharedPreferences.getInstance();
    String? slotsJson = prefs.getString('timeSlots');

    if (slotsJson != null) {
      List<dynamic> decodedList = jsonDecode(slotsJson);

      setState(() {
        _timeSlots = decodedList.map<Map<String, dynamic>>((item) {
          return {
            'start': item['start'],
            'end': item['end'],
            'duration': item['duration']
          };
        }).toList();
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
  if (_subjects.isEmpty || _timeSlots.isEmpty) return;

  final String apiUrl = "https://llama8b.gaia.domains/v1"; // Replace with actual API URL
  final String apiKey = "gaia-MjY5ODYyNmUtMDkwMC00NWNiLWIwOGMtOWI4YjI0ZjJjOTAw-cguhPB181yZYWb-3"; // Replace with your API key

  List<Map<String, dynamic>> subjectsList = _subjects.map((subject) {
    return {
      'name': subject['name'],
      'difficulty': subject['difficulty'],
      'weight': subject['weight'],
    };
  }).toList();

  List<Map<String, dynamic>> timeSlotsList = _timeSlots.map((slot) {
    return {
      'start': slot['start'],
      'end': slot['end'],
      'duration': slot['duration'],
    };
  }).toList();

  final requestBody = jsonEncode({
    "subjects": subjectsList,
    "timeSlots": timeSlotsList
  });

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey"
      },
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        _schedule = Map<String, String>.from(responseData['schedule']);
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('schedule', jsonEncode(_schedule));

    } else {
      throw Exception("Failed to generate schedule: ${response.body}");
    }
  } catch (error) {
    print("Error generating schedule: $error");
  }
}

  void _showGeneratedSchedule() {
  if (_schedule.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("No schedule generated yet!")),
    );
    return;
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Generated Schedule"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _schedule.entries.map((entry) => Text("${entry.key} - ${entry.value}")).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("OK"),
        ),
      ],
    ),
  );
}


  void _showTimeSlots() {
    if (_timeSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No time slots added!")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Saved Time Slots"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _timeSlots
              .map((slot) => Text(
                  '${slot['start']} - ${slot['end']} (${slot['duration']} min)'))
              .toList(),
        ),
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
            ElevatedButton(
              onPressed: _generateSchedule,
              child: Text("Generate Schedule"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _showGeneratedSchedule,
              child: Text("Show Generated Schedule"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _showTimeSlots,
              child: Text("See Time Slots"),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _subjects.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_subjects[index]['name']!),
                    subtitle:
                        Text("Difficulty: ${_subjects[index]['difficulty']}"),
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
