import 'package:flutter/material.dart';
import 'package:hulee_task/shift_details_screen.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'shift_service.dart';
import 'shift_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hulee Flutter Task',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ShiftCalendarScreen(title: 'My Shifts'),
    );
  }
}

class ShiftCalendarScreen extends StatefulWidget {
  const ShiftCalendarScreen({super.key, required this.title});

  final String title;

  @override
  State<ShiftCalendarScreen> createState() => _ShiftCalendarScreenState();
}

class _ShiftCalendarScreenState extends State<ShiftCalendarScreen> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  List<Shift> _shifts = [];

  @override
  void initState() {
    super.initState();
    _loadShifts();
  }

  void _changeMonth(int months) {
    setState(() {
      DateTime newDate = DateTime(_focusedDay.year, _focusedDay.month + months, 1);
      if (newDate.year == 2025) {
        _focusedDay = newDate;
      }
    });
  }

  Future<void> _loadShifts() async {
    final shifts = await ShiftService.fetchShifts();
    setState(() {
      _shifts = shifts.map((json) => Shift.fromJson(json)).toList();
    });
  }

  List<Shift> _getShiftsForSelectedDay(DateTime day) {
    return _shifts.where((shift) =>
      shift.date.year == day.year &&
      shift.date.month == day.month &&
      shift.date.day == day.day  
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: () => _changeMonth(-1),
                    icon: Icon(Icons.chevron_left, size: 32)),
                Text(
                  DateFormat('MMMM yyyy').format(_focusedDay),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(onPressed: () => _changeMonth(1),
                    icon: Icon(Icons.chevron_right, size: 32)),
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(51),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TableCalendar(
                calendarFormat: _calendarFormat,
                firstDay: DateTime(2025, 1, 1),
                lastDay: DateTime(2025, 12, 31),
                focusedDay: _focusedDay,
                eventLoader: (day) => _getShiftsForSelectedDay(day),
                onDaySelected: (selectedDay, focusedDay) {
                  final shiftsOnDay = _shifts.where((shift) =>
                  shift.date.year == selectedDay.year &&
                      shift.date.month == selectedDay.month &&
                      shift.date.day == selectedDay.day
                  ).toList();

                  if (shiftsOnDay.isNotEmpty) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ShiftDetailsScreen(shift: shiftsOnDay.first),
                        )
                    );
                  }
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle
                          ),
                          width: 6,
                          height: 6,
                        ),
                      );
                    }
                    return null;
                  }
                ),
                headerVisible: false,
              )
          )
        ],
      ),
    );
  }
}
