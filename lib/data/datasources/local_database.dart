import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'local_database.g.dart';

@DataClassName('ItemRow')
class Items extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()(); // 'link', 'document', 'note'
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LinkRow')
class Links extends Table {
  TextColumn get id => text().references(Items, #id)();
  TextColumn get url => text()();
  TextColumn get faviconUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DocumentRow')
class Documents extends Table {
  TextColumn get id => text().references(Items, #id)();
  TextColumn get filePath => text()();
  TextColumn get fileType => text()();
  IntColumn get fileSize => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('NoteRow')
class Notes extends Table {
  TextColumn get id => text().references(Items, #id)();
  TextColumn get content => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TagRow')
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get color => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ItemTagRow')
class ItemTags extends Table {
  TextColumn get itemId => text().references(Items, #id)();
  TextColumn get tagId => text().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {itemId, tagId};
}

@DriftDatabase(tables: [Items, Links, Documents, Notes, Tags, ItemTags])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    // Also work around limitations on old Android versions
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    // Make sqlite3 pick a more suitable location for temporary files - the
    // one from the system may be inaccessible due to sandboxing.
    final cachebase = (await getTemporaryDirectory()).path;
    // We can't access /tmp on Android, which sqlite3 would try by default.
    // Explicitly tell it about the correct temporary directory.
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
