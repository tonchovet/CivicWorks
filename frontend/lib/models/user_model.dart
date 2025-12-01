class User {
  final int id;
  final String email;
  final String fullName;
  final String country;
  final String province;
  final String locality;
  final String address;
  final String role; // CITIZEN, COMPANY
  final double wallet;

  User({
    required this.id, required this.email, required this.fullName,
    required this.country, required this.province, required this.locality,
    required this.address,
    required this.role, required this.wallet
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      fullName: json['fullName'],
      country: json['country'] ?? 'Argentina',
      province: json['province'],
      locality: json['locality'],
      address: json['address'] ?? '',
      role: json['role'] ?? 'CITIZEN',
      wallet: json['walletBalance'] ?? 0.0,
    );
  }
  
  bool get isCompany => role == 'COMPANY';
  
  @override
  String toString() {
    return email;
  }
}
