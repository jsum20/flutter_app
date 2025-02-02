import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'shift_model.dart';
import 'package:intl/intl.dart';

class ShiftDetailsScreen extends StatefulWidget {
  final Shift shift;

  const ShiftDetailsScreen({super.key, required this.shift});

  @override
  State<ShiftDetailsScreen> createState() => _ShiftDetailsScreenState();
}

class _ShiftDetailsScreenState extends State<ShiftDetailsScreen> {
  bool _isWithinRadius = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    try {
      bool hasPermission = await _checkLocationPermissions();
      if (!hasPermission) return;

      Position userPosition = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
              accuracy: LocationAccuracy.high, distanceFilter: 10));

      double distance = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        widget.shift.latitude,
        widget.shift.longitude,
      );

      setState(() {
        _isWithinRadius = distance <= 500;
        _error =
            _isWithinRadius ? null : 'You are too far from the shift location';
      });
    } catch (e) {
      setState(() => _error = 'Error: $e');
    }
  }

  Future<bool> _checkLocationPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  bool _isClockInAllowed() {
    final now = DateTime.now();
    final shiftStart = DateFormat('HH:mm').parse(widget.shift.startTime);
    final shiftStartTime = DateTime(
        now.year, now.month, now.day, shiftStart.hour, shiftStart.minute);
    final allowedStartTime = shiftStartTime.subtract(Duration(minutes: 15));

    return now.isAfter(allowedStartTime) && now.isBefore(shiftStartTime);
  }

  bool _isClockOutAllowed() {
    final now = DateTime.now();
    final shiftEnd = DateFormat('HH:mm').parse(widget.shift.finishTime);
    final shiftEndTime =
    DateTime(now.year, now.month, now.day, shiftEnd.hour, shiftEnd.minute);

    final allowedStartTime = shiftEndTime.subtract(Duration(minutes: 15));
    final allowedEndTime = shiftEndTime.add(Duration(minutes: 15));

    return now.isAfter(allowedStartTime) && now.isBefore(allowedEndTime);
  }

  void _showConfirmationMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Clock-In Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('d MMMM y').format(widget.shift.date);

    return Scaffold(
      appBar: AppBar(title: Text('Shift Details')),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formattedDate),
            Text('${widget.shift.title} - ${widget.shift.role}',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline)),
            SizedBox(height: 20),
            Text('Name: ${widget.shift.name}', style: TextStyle(fontSize: 18)),
            Text('Start Time: ${widget.shift.startTime}',
                style: TextStyle(fontSize: 18)),
            Text('End Time: ${widget.shift.finishTime}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text(
                'Shift Location: ${widget.shift.locationName}, ${widget.shift.locationPostCode}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildClockInButton(),
                SizedBox(width: 16),
                _buildClockOutButton(),
              ],
            ),
            _error != null
                ? Center(
                    child: Text(
                      'Clock in disabled: ${_error!}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : SizedBox.shrink()
          ],
        ),
      ),
    );
  }

  Widget _buildClockInButton() {
    bool isEnabled = _isWithinRadius;

    return ElevatedButton(
      onPressed: isEnabled
          ? () {
        if (_isClockInAllowed()) {
          _showConfirmationMessage("Clocked In!");
        } else {
          _showErrorDialog(
              "Clock-in not allowed. You can clock in only 15 minutes before your shift.");
        }
      }
          : null,
      child: Text('Clock In'),
    );
  }

  Widget _buildClockOutButton() {
    bool isEnabled = _isWithinRadius;

    return ElevatedButton(
      onPressed: isEnabled
          ? () {
        if (_isClockOutAllowed()) {
          _showConfirmationMessage("Clocked Out! Goodbye!");
        } else {
          _showErrorDialog(
              "Clock-out not allowed. You can clock out within 15 minutes of your shift's end time.");
        }
      }
          : null, // Disabled when isEnabled is false
      child: Text('Clock Out'),
    );
  }
}
