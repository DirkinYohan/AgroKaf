class UserProfile {
  const UserProfile({
    this.userName = '',
    this.farmName = '',
    this.municipality = '',
    this.coffeeVariety = '',
    this.profileImagePath,
  });

  final String userName;
  final String farmName;
  final String municipality;
  final String coffeeVariety;
  final String? profileImagePath;

  static const String coffeeVarietyOther = 'Otra';

  static const List<String> coffeeVarieties = <String>[
    'Castillo',
    'Caturra',
    'Colombia',
    'Tabi',
    'Bourb\u00f3n',
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
