import 'package:drift/drift.dart';

import 'database.dart';

/// Keys of the `settings` table.
abstract final class SettingKeys {
  static const librarySort = 'library.sort';
  static const paperTemplate = 'paper.template';
}

/// App preferences, stored as strings in the `settings` table.
class SettingsRepository {
  SettingsRepository(this._db);

  final MarginDatabase _db;

  Future<String?> get(String key) async {
    final row = await (_db.select(
      _db.settings,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> set(String key, String value) {
    return _db
        .into(_db.settings)
        .insert(
          SettingsCompanion.insert(key: key, value: value),
          mode: InsertMode.insertOrReplace,
        );
  }

  /// The stored enum value named under [key], or [fallback].
  Future<T> getEnum<T extends Enum>(String key, List<T> values, T fallback) {
    return get(key).then(
      (name) => values.where((v) => v.name == name).firstOrNull ?? fallback,
    );
  }
}
