import 'package:agrokaf/features/profile/domain/entities/user_profile.dart';

/// Form validation rules for the profile (pure functions, unit-testable).
class ProfileValidators {
  ProfileValidators._();

  static const String nameRequired = 'Escribe tu nombre';
  static const String nameTooShort = 'Tu nombre debe tener al menos 2 letras';
  static const String nameTooLong = 'Tu nombre puede tener máximo 50 letras';
  static const String municipalityRequired = 'Escribe tu municipio';
  static const String otherVarietyRequired = 'Escribe la variedad de café';

  static String? name(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return nameRequired;
    if (v.length < UserProfile.nameMinLength) return nameTooShort;
    if (v.length > UserProfile.nameMaxLength) return nameTooLong;
    return null;
  }

  static String? municipality(String? value) =>
      (value ?? '').trim().isEmpty ? municipalityRequired : null;

  static String? otherVariety(String? value) =>
      (value ?? '').trim().isEmpty ? otherVarietyRequired : null;
}
