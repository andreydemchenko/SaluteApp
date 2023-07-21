class City {
  final String name;
  final String subject;

  City({required this.name, required this.subject});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'] as String,
      subject: json['subject'] as String,
    );
  }
}