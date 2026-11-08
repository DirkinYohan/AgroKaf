import 'package:flutter_test/flutter_test.dart';

import 'package:agrokaf/features/profile/domain/profile_validators.dart';

void main() {
  group('ProfileValidators.name', () {
    test('is required', () {
      expect(ProfileValidators.name(''), ProfileValidators.nameRequired);
      expect(ProfileValidators.name('   '), ProfileValidators.nameRequired);
    });

    test('needs 2 to 50 characters', () {
      expect(ProfileValidators.name('A'), ProfileValidators.nameTooShort);
      expect(ProfileValidators.name('Al'), isNull);
      expect(ProfileValidators.name('a' * 50), isNull);
      expect(ProfileValidators.name('a' * 51), ProfileValidators.nameTooLong);
    });
  });

  test('municipality is required', () {
    expect(
      ProfileValidators.municipality(''),
      ProfileValidators.municipalityRequired,
    );
    expect(ProfileValidators.municipality('Taminango'), isNull);
  });
}
