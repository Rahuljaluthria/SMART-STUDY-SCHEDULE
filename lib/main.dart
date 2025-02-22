import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'screens/add_subject_screen.dart';
import 'screens/time_slot_screen.dart';
import 'splash_screen.dart';



import 'dart:async';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}

class StudyScheduleApp extends StatefulWidget {
  @override
  _StudyScheduleAppState createState() => _StudyScheduleAppState();
}

class _StudyScheduleAppState extends State<StudyScheduleApp> {
  ThemeMode _themeMode = ThemeMode.dark; // Default to dark mode

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool('darkMode') ?? true; // Default dark mode
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
         
        ),
      ),
      themeMode: _themeMode,
      home: StartPage(),
    );
  }
}

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  String _currentTime = DateFormat('hh:mm a').format(DateTime.now());
  Timer? _timer;
  String? _lastGeneratedSchedule;

  @override
  void initState() {
    super.initState();
    _startClock();
    _loadLastSchedule();
  }

  void _startClock() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateFormat('hh:mm a').format(DateTime.now());
      });
    });
  }

  void _loadLastSchedule() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastGeneratedSchedule = prefs.getString('lastSchedule') ?? "No schedule generated yet";
    });
  }

  void _updateSchedule() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastGeneratedSchedule = prefs.getString('lastSchedule') ?? "No schedule generated yet";
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Image.asset(
    'assets/appbar.png',
    height: 40,
  ),
  centerTitle: true,
  backgroundColor: Colors.black,
  actions: [
    IconButton(
      icon: Icon(Icons.settings, color: Colors.white), // Ensure it's visible in dark mode
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsPage()),
        );
      },
    ),
  ],
),

      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.grey.shade900,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(_currentTime, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 16),
                    TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: DateTime.now(),
                      calendarFormat: CalendarFormat.week,
                      headerStyle: HeaderStyle(titleTextStyle: TextStyle(color: Colors.white)),
                      daysOfWeekStyle: DaysOfWeekStyle(weekdayStyle: TextStyle(color: Colors.white)),
                      calendarStyle: CalendarStyle(defaultTextStyle: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              color: Colors.green.shade900,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text("Generated Schedule", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 10),
                    Text(_lastGeneratedSchedule ?? "No schedule generated yet", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TimeSlotScreen()),
                );
              },
              child: Text("Manage Study Time Slots"),
            ),
            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddSubjectScreen()),
                );
                _updateSchedule(); // Refresh schedule after returning
              },
              child: Text("Add Subject"),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  void _clearCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              _clearCache();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Cache cleared successfully")),
              );
            },
            child: Text("Clear Cache"),
          ),
        ),
      ),
    );
  }
}