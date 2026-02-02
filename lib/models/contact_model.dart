class ContactModel {
  final int? id;
  final String name;
  final String surname;
  final String email;
  final String phoneNumber;

  const ContactModel({
    this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.phoneNumber,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'],
      name: json['name'],
      surname: json['surname'],
      email: json['email'],
      phoneNumber: json['phone_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'surname': surname,
      'email': email,
      'phone_number': phoneNumber,
    };
  }

  String get fullName => '$name $surname';

  ContactModel copyWith({
    int? id,
    String? name,
    String? surname,
    String? email,
    String? phoneNumber,
  }) {
    return ContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
