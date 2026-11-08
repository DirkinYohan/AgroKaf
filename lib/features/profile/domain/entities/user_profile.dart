/// The farmer's profile. Only [userName] and [municipality] are required.
class UserProfile {
  const UserProfile({
    required this.userName,
    this.farmName = '',
    this.municipality = defaultMunicipality,
    this.coffeeVariety = '',
    this.profileImagePath,
  });

  final String userName;
  final String farmName;
  final String municipality;
  final String coffeeVariety;
  final String? profileImagePath;

  static const String defaultMunicipality = 'Taminango';
  static const String coffeeVarietyOther = 'Otra';

  static const int nameMinLength = 2;
  static const int nameMaxLength = 50;
  static const int textMaxLength = 60;

  static const List<String> coffeeVarieties = <String>[
    'Castillo',
    'Caturra',
    'Colombia',
    'Cenicafé 1',
    'Tabi',
    'Típica',
    'Borbón',
    coffeeVarietyOther,
  ];

  UserProfile copyWith({
    String? userName,
    String? farmName,
    String? municipality,
    String? coffeeVariety,
    String? profileImagePath,
    bool clearProfileImage = false,
  }) {
    return UserProfile(
      userName: userName ?? this.userName,
      farmName: farmName ?? this.farmName,
      municipality: municipality ?? this.municipality,
      coffeeVariety: coffeeVariety ?? this.coffeeVariety,
      profileImagePath: clearProfileImage
          ? null
          : profileImagePath ?? this.profileImagePath,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.userName == userName &&
        other.farmName == farmName &&
        other.municipality == municipality &&
        other.coffeeVariety == coffeeVariety &&
        other.profileImagePath == profileImagePath;
  }

  @override
  int get hashCode => Object.hash(
    userName,
    farmName,
    municipality,
    coffeeVariety,
    profileImagePath,
  );
}
