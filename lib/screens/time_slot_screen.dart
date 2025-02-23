import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';


class TimeSlotScreen extends StatefulWidget {
  @override
  _TimeSlotScreenState createState() => _TimeSlotScreenState();
}

class _TimeSlotScreenState extends State<TimeSlotScreen> {
  List<Map<String, dynamic>> _timeSlots = [];

  @override
  void initState() {
    super.initState();
    _loadTimeSlots();
  }

  Future<void> _saveTimeSlots() async {
  final prefs = await SharedPreferences.getInstance();

  if (_timeSlots.isEmpty) {
    print("No time slots to save.");
    return;
  }

  List<Map<String, dynamic>> slotList = _timeSlots.map<Map<String, dynamic>>((slot) {
    try {
      // Trim to remove any extra spaces or hidden characters
      String startTrimmed = slot['start'].toString().trim();
      String endTrimmed = slot['end'].toString().trim();

      // Parse times using DateFormat.jm() correctly
      DateTime startTime = DateFormat('h:mm a').parseStrict(startTrimmed);
      DateTime endTime = DateFormat('h:mm a').parseStrict(endTrimmed);

      int duration = endTime.difference(startTime).inMinutes; // Calculate duration in minutes

      return {
        'start': startTrimmed,
        'end': endTrimmed,
        'duration': duration, // Store duration as an integer
      };
    } catch (e) {
      print("Error parsing time slot: ${slot['start']} - ${slot['end']}, Error: $e");
      return {}; // Skip invalid slots
    }
  }).where((slot) => slot.isNotEmpty).cast<Map<String, dynamic>>().toList(); // Ensure correct type

  if (slotList.isNotEmpty) {
    String encodedSlots = jsonEncode(slotList);
    print("Saving time slots: $encodedSlots");
    await prefs.setString('timeSlots', encodedSlots);
  } else {
    print("No valid time slots to save.");
  }
}



  Future<void> _loadTimeSlots() async {
  final prefs = await SharedPreferences.getInstance();
  String? slotsJson = prefs.getString('timeSlots');

  if (slotsJson == null || slotsJson.isEmpty) {
    print("No time slots found in SharedPreferences.");
    return;
  }

  List<dynamic> decodedList = jsonDecode(slotsJson);
  print("Loaded time slots: $decodedList");

  setState(() {
    _timeSlots = decodedList.map<Map<String, dynamic>>((item) {
      return {
        'start': item['start'] as String,
        'end': item['end'] as String,
        'duration': (item['duration'] as num?)?.toInt() ?? 0, // Ensure duration is an integer
      };
    }).toList();
  });
}


  Future<void> _pickTime(bool isStart, int? index) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        if (index != null) {
          if (isStart) {
            _timeSlots[index]['start'] = pickedTime.format(context);
          } else {
            _timeSlots[index]['end'] = pickedTime.format(context);
          }
        } else {
          _timeSlots.add({
            'start': pickedTime.format(context),
            'end': 'Set End Time', // Default value to avoid null
          });
        }
      });
      _saveTimeSlots();
    }
  }

  void _setEndTime(int index) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _timeSlots[index]['end'] = pickedTime.format(context);
      });
      _saveTimeSlots();
    }
  }

  void _removeTimeSlot(int index) {
    setState(() {
      _timeSlots.removeAt(index);
    });
    _saveTimeSlots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Set Study Time Slots")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _pickTime(true, null),
              child: Text("Add Time Slot"),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _timeSlots.isEmpty
                  ? Center(child: Text("No time slots added"))
                  : ListView.builder(
                      itemCount: _timeSlots.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(
                              "${_timeSlots[index]['start']} - ${_timeSlots[index]['end']}",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.access_time),
                                  onPressed: () => _setEndTime(index),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeTimeSlot(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            ElevatedButton(
              onPressed: () {
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
                                "${slot['start']} - ${slot['end']}",
                              ))
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
              },
              child: Text("See Time Slots"),
            ),
          ],
        ),
      ),
    );
  }
}
