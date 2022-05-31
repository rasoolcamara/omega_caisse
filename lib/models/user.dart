class User {
  User({
    this.id,
    this.name,
    this.address,
    this.phone,
    this.profileId,
    this.teamId,
    this.categoryId,
    this.suscription,
    this.balance,
  });

  int id;
  String name;
  String address;
  String phone;
  int profileId;
  int teamId;
  int categoryId;
  int suscription;
  int balance;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      profileId: json['profile_id'] as int,
      teamId: json['team_id'] as int,
      categoryId: json['category_id'] as int,
      suscription: json['suscription'] as int,
      balance: json['balance'] as int,
    );
  }
}
