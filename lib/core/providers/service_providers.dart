import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agrokaf/core/services/database_service.dart';
import 'package:agrokaf/core/services/image_service.dart';
import 'package:agrokaf/core/services/legacy_data_cleaner.dart';
import 'package:agrokaf/core/services/photo_picker_service.dart';
import 'package:agrokaf/core/services/secure_key_store.dart';
import 'package:agrokaf/core/services/settings_service.dart';

/// App-wide singletons. Tests override these with fakes.
final Provider<SecureKeyStore> secureKeyStoreProvider =
    Provider<SecureKeyStore>((Ref ref) => SecureKeyStore());

final Provider<DatabaseService> databaseServiceProvider =
    Provider<DatabaseService>((Ref ref) => DatabaseService());

final Provider<SettingsService> settingsServiceProvider =
    Provider<SettingsService>(
      (Ref ref) => SettingsService(ref.watch(databaseServiceProvider)),
    );

final Provider<ImageService> imageServiceProvider = Provider<ImageService>(
  (Ref ref) => ImageService(),
);

final Provider<PhotoPickerService> photoPickerServiceProvider =
    Provider<PhotoPickerService>((Ref ref) => PhotoPickerService());

final Provider<LegacyDataCleaner> legacyDataCleanerProvider =
    Provider<LegacyDataCleaner>((Ref ref) => LegacyDataCleaner());
