class User {
  final bool success;
  final String lastLogin;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final bool isActive;
  final bool emailVerified;
  final bool conditionAccepted;
  final String plan;
  final String dateRenew;
  final bool changePassword;
  final String description;
  final String picture;

  User({
    required this.success,
    required this.lastLogin,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.isActive,
    required this.emailVerified,
    required this.conditionAccepted,
    required this.plan,
    required this.dateRenew,
    required this.changePassword,
    required this.description,
    required this.picture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      success: json['success'],
      lastLogin: json['lastLogin'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      role: json['role'],
      isActive: json['isActive'],
      emailVerified: json['emailVerified'],
      conditionAccepted: json['conditionAccepted'],
      plan: json['plan'],
      dateRenew: json['dateRenew'],
      changePassword: json['changePassword'],
      description: json['description'],
      picture: json['picture'],
    );
  }
}
