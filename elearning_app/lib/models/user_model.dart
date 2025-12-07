class UserModel {
  final int id;
  final String username;
  final String email;
  final String? niveauInitial; // Champ ajouté pour la personnalisation

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.niveauInitial,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) {
    return UserModel(
      id: j['id'],
      username: j['username'],
      email: j['email'],
      // Assurez-vous que le nom du champ correspond à celui de Django (niveau_initial)
      niveauInitial: j['niveau_initial'], 
    );
  }
}