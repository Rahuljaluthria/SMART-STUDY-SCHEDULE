import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
    await prefs.setString('timeSlots', jsonEncode(_timeSlots));
  }

  Future<void> _loadTimeSlots() async {
    final prefs = await SharedPreferences.getInstance();
    String? slotsJson = prefs.getString('timeSlots');
    
    if (slotsJson != null) {
      List<dynamic> decodedList = jsonDecode(slotsJson);
      setState(() {
        _timeSlots = decodedList
            .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
            .toList();
      });
    }
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
            'end': '',
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
                              "${_timeSlots[index]['start']} - ${_timeSlots[index]['end'].isEmpty ? 'Set End Time' : _timeSlots[index]['end']}"
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
          ],
        ),
      ),
    );
  }
}
