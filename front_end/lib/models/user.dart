class User {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? address;
  final DateTime? dateOfBirth;
  final bool isAdmin;
  final String? imgUrl;

  User(
      {required this.id,
      required this.email,
      required this.name,
      this.phoneNumber,
      this.address,
      this.dateOfBirth,
      this.isAdmin = false,
      this.imgUrl});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
              .toLocal()
              .toUtc()
              .subtract(Duration(
                hours: DateTime.parse(json['dateOfBirth']).hour,
                minutes: DateTime.parse(json['dateOfBirth']).minute,
                seconds: DateTime.parse(json['dateOfBirth']).second,
              )) // Lấy ngày, tháng, năm và bỏ giờ
          : null,
      isAdmin: json['isAdmin'] ?? false,
      imgUrl: json['imgUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth != null
          ? "${dateOfBirth!.year}-${dateOfBirth!.month.toString().padLeft(2, '0')}-${dateOfBirth!.day.toString().padLeft(2, '0')}"
          : null,
      'address': address,
      'isAdmin': isAdmin,
      'imgUrl': imgUrl
    };
  }

  User? copyWith(
      {required avatar,
      required String name,
      String? address,
      required String email}) {
    return null;
  }
}
