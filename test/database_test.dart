import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:agrokaf/core/models/diagnosis_status.dart';
import 'package:agrokaf/core/services/image_service.dart';
import 'package:agrokaf/core/services/settings_service.dart';
import 'package:agrokaf/features/analysis/data/analysis_repository.dart';
import 'package:agrokaf/features/analysis/domain/analysis.dart';
import 'package:agrokaf/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:agrokaf/features/profile/domain/entities/user_profile.dart';

import 'helpers/test_database.dart';

void main() {
  late TestStorage storage;

  setUp(() async => storage = await TestStorage.create());
  tearDown(() => storage.dispose());

  group('SettingsService', () {
    test('onboarding flag and privacy consent are persisted', () async {
      final SettingsService settings = SettingsService(storage.database);
      expect(await settings.isOnboardingCompleted(), isFalse);
      expect(await settings.getPrivacyConsent(), isNull);

      await settings.setOnboardingCompleted();
      final PrivacyConsent saved = await settings.savePrivacyConsent('1.0');

      expect(await settings.isOnboardingCompleted(), isTrue);
      final PrivacyConsent? loaded = await settings.getPrivacyConsent();
      expect(loaded?.policyVersion, '1.0');
      expect(
        loaded?.acceptedAt.toIso8601String(),
        saved.acceptedAt.toIso8601String(),
      );
    });
  });

  group('ProfileRepositoryImpl', () {
    test(
      'creates, updates and replaces the photo (old file deleted)',
      () async {
        final ProfileRepositoryImpl repo = ProfileRepositoryImpl(
          storage.database,
          storage.images,
        );
        expect(await repo.getProfile(), isNull);

        final UserProfile first = await repo.saveProfile(
          const UserProfile(userName: 'María Pérez', coffeeVariety: 'Castillo'),
          newPhotoSourcePath: storage.writePickedPhoto('a.jpg').path,
        );
        final String firstPhoto = first.profileImagePath!;
        expect(File(firstPhoto).existsSync(), isTrue);

        final UserProfile second = await repo.saveProfile(
          first.copyWith(farmName: 'La Esperanza'),
          newPhotoSourcePath: storage.writePickedPhoto('b.jpg').path,
        );
        expect(
          File(firstPhoto).existsSync(),
          isFalse,
          reason: 'old photo removed',
        );
        expect(File(second.profileImagePath!).existsSync(), isTrue);

        final UserProfile? loaded = await repo.getProfile();
        expect(loaded?.userName, 'María Pérez');
        expect(loaded?.farmName, 'La Esperanza');
        expect(loaded?.municipality, UserProfile.defaultMunicipality);
      },
    );

    test('removing the photo deletes the file', () async {
      final ProfileRepositoryImpl repo = ProfileRepositoryImpl(
        storage.database,
        storage.images,
      );
      final UserProfile withPhoto = await repo.saveProfile(
        const UserProfile(userName: 'Ana'),
        newPhotoSourcePath: storage.writePickedPhoto('c.jpg').path,
      );
      await repo.saveProfile(withPhoto.copyWith(clearProfileImage: true));
      expect(File(withPhoto.profileImagePath!).existsSync(), isFalse);
      expect((await repo.getProfile())?.profileImagePath, isNull);
    });
  });

  group('AnalysisRepository', () {
    Future<Analysis> saveOne(
      AnalysisRepository repo,
      DiagnosisStatus status,
      DateTime when,
    ) async {
      final String photo = await storage.images.savePrivateImage(
        storage.writePickedPhoto('${when.millisecondsSinceEpoch}.jpg').path,
        ImageFolder.analyses,
      );
      return repo.insert(
        Analysis(
          imagePath: photo,
          status: status,
          healthyProbability: status == DiagnosisStatus.healthy ? 0.9 : 0.1,
          phomaProbability: status == DiagnosisStatus.healthy ? 0.1 : 0.9,
          confidence: 0.9,
          inferenceMs: 42,
          createdAt: when,
          lotName: 'Lote 1',
          note: '  ',
        ),
      );
    }

    test('insert, list newest first, round-trip fields', () async {
      final AnalysisRepository repo = AnalysisRepository(
        storage.database,
        storage.images,
      );
      await saveOne(repo, DiagnosisStatus.healthy, DateTime(2026, 11, 1));
      await saveOne(repo, DiagnosisStatus.phoma, DateTime(2026, 11, 2));

      final List<Analysis> all = await repo.getAll();
      expect(all.map((Analysis a) => a.status), <DiagnosisStatus>[
        DiagnosisStatus.phoma,
        DiagnosisStatus.healthy,
      ]);
      expect(all.first.inferenceMs, 42);
      expect(all.first.lotName, 'Lote 1');
      expect(all.first.note, '', reason: 'blank notes are stored as empty');
      expect(AnalysisStats.of(all).phoma, 1);
    });

    test('delete and deleteAll also remove the photos', () async {
      final AnalysisRepository repo = AnalysisRepository(
        storage.database,
        storage.images,
      );
      final Analysis a = await saveOne(
        repo,
        DiagnosisStatus.healthy,
        DateTime(2026, 1, 1),
      );
      final Analysis b = await saveOne(
        repo,
        DiagnosisStatus.phoma,
        DateTime(2026, 1, 2),
      );

      await repo.delete(a);
      expect(File(a.imagePath).existsSync(), isFalse);
      expect((await repo.getAll()).length, 1);

      await repo.deleteAll();
      expect(File(b.imagePath).existsSync(), isFalse);
      expect(await repo.getAll(), isEmpty);
    });

    test('photos of analyses never saved are cleaned up', () async {
      final AnalysisRepository repo = AnalysisRepository(
        storage.database,
        storage.images,
      );
      final Analysis kept = await saveOne(
        repo,
        DiagnosisStatus.healthy,
        DateTime(2026, 2, 1),
      );
      final String orphan = await storage.images.savePrivateImage(
        storage.writePickedPhoto('orphan.jpg').path,
        ImageFolder.analyses,
      );

      await repo.deleteOrphanImages();
      expect(File(orphan).existsSync(), isFalse);
      expect(File(kept.imagePath).existsSync(), isTrue);
    });
  });
}
