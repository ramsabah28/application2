class AdressModel {
  final String uid;
  final String name;
  final String username;
  final String surname;
  final String street;
  final String zip;
  final String city;
  final int phoneNumber;

  const AdressModel({
    required this.name, required this.city,
    required this.phoneNumber, required this.street,
    required this.surname, required this.uid,
    required this.username, required this.zip
});
}