class Shift {
  final String id;
  final String name;
  final DateTime date;
  final String startTime;
  final String finishTime;
  final String locationName;
  final String locationPostCode;
  final double latitude;
  final double longitude;
  final String title;
  final String role;

  Shift({
    required this.id,
    required this.name,
    required this.date,
    required this.startTime,
    required this.finishTime,
    required this.locationName,
    required this.locationPostCode,
    required this.latitude,
    required this.longitude,
    required this.title,
    required this.role,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {

    return Shift(
      id: json['_id'],
      name: json['user']['name'],
      date: DateTime.parse(json['date']),
      startTime: json['startTime'],
      finishTime: json['finishTime'],
      locationName: json['location']['name'],
      locationPostCode: json['location']['postCode'],
      latitude: json['location']['cordinates']['latitude'],
      longitude: json['location']['cordinates']['longitude'],
      title: json['title'],
      role: json['role'],
    );
  }
}