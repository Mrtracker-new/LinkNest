// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $ItemsTable extends Items with TableInfo<$ItemsTable, ItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, type, title, description, createdAt, updatedAt, isFavorite];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(Insertable<ItemRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class ItemRow extends DataClass implements Insertable<ItemRow> {
  final String id;
  final String type;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  const ItemRow(
      {required this.id,
      required this.type,
      required this.title,
      this.description,
      required this.createdAt,
      required this.updatedAt,
      required this.isFavorite});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_favorite'] = Variable<bool>(isFavorite);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      type: Value(type),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isFavorite: Value(isFavorite),
    );
  }

  factory ItemRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isFavorite': serializer.toJson<bool>(isFavorite),
    };
  }

  ItemRow copyWith(
          {String? id,
          String? type,
          String? title,
          Value<String?> description = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isFavorite}) =>
      ItemRow(
        id: id ?? this.id,
        type: type ?? this.type,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isFavorite: isFavorite ?? this.isFavorite,
      );
  ItemRow copyWithCompanion(ItemsCompanion data) {
    return ItemRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isFavorite: $isFavorite')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, type, title, description, createdAt, updatedAt, isFavorite);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.title == this.title &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isFavorite == this.isFavorite);
}

class ItemsCompanion extends UpdateCompanion<ItemRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isFavorite;
  final Value<int> rowid;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsCompanion.insert({
    required String id,
    required String type,
    required String title,
    this.description = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isFavorite = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        title = Value(title),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ItemRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isFavorite,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<String>? title,
      Value<String?>? description,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isFavorite,
      Value<int>? rowid}) {
    return ItemsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LinksTable extends Links with TableInfo<$LinksTable, LinkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES items (id)'));
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _faviconUrlMeta =
      const VerificationMeta('faviconUrl');
  @override
  late final GeneratedColumn<String> faviconUrl = GeneratedColumn<String>(
      'favicon_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, url, faviconUrl];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'links';
  @override
  VerificationContext validateIntegrity(Insertable<LinkRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('favicon_url')) {
      context.handle(
          _faviconUrlMeta,
          faviconUrl.isAcceptableOrUnknown(
              data['favicon_url']!, _faviconUrlMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LinkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LinkRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      faviconUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}favicon_url']),
    );
  }

  @override
  $LinksTable createAlias(String alias) {
    return $LinksTable(attachedDatabase, alias);
  }
}

class LinkRow extends DataClass implements Insertable<LinkRow> {
  final String id;
  final String url;
  final String? faviconUrl;
  const LinkRow({required this.id, required this.url, this.faviconUrl});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || faviconUrl != null) {
      map['favicon_url'] = Variable<String>(faviconUrl);
    }
    return map;
  }

  LinksCompanion toCompanion(bool nullToAbsent) {
    return LinksCompanion(
      id: Value(id),
      url: Value(url),
      faviconUrl: faviconUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(faviconUrl),
    );
  }

  factory LinkRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LinkRow(
      id: serializer.fromJson<String>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      faviconUrl: serializer.fromJson<String?>(json['faviconUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'url': serializer.toJson<String>(url),
      'faviconUrl': serializer.toJson<String?>(faviconUrl),
    };
  }

  LinkRow copyWith(
          {String? id,
          String? url,
          Value<String?> faviconUrl = const Value.absent()}) =>
      LinkRow(
        id: id ?? this.id,
        url: url ?? this.url,
        faviconUrl: faviconUrl.present ? faviconUrl.value : this.faviconUrl,
      );
  LinkRow copyWithCompanion(LinksCompanion data) {
    return LinkRow(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      faviconUrl:
          data.faviconUrl.present ? data.faviconUrl.value : this.faviconUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LinkRow(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('faviconUrl: $faviconUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, url, faviconUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LinkRow &&
          other.id == this.id &&
          other.url == this.url &&
          other.faviconUrl == this.faviconUrl);
}

class LinksCompanion extends UpdateCompanion<LinkRow> {
  final Value<String> id;
  final Value<String> url;
  final Value<String?> faviconUrl;
  final Value<int> rowid;
  const LinksCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.faviconUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LinksCompanion.insert({
    required String id,
    required String url,
    this.faviconUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        url = Value(url);
  static Insertable<LinkRow> custom({
    Expression<String>? id,
    Expression<String>? url,
    Expression<String>? faviconUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (faviconUrl != null) 'favicon_url': faviconUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LinksCompanion copyWith(
      {Value<String>? id,
      Value<String>? url,
      Value<String?>? faviconUrl,
      Value<int>? rowid}) {
    return LinksCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (faviconUrl.present) {
      map['favicon_url'] = Variable<String>(faviconUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LinksCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('faviconUrl: $faviconUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentsTable extends Documents
    with TableInfo<$DocumentsTable, DocumentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES items (id)'));
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fileTypeMeta =
      const VerificationMeta('fileType');
  @override
  late final GeneratedColumn<String> fileType = GeneratedColumn<String>(
      'file_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fileSizeMeta =
      const VerificationMeta('fileSize');
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
      'file_size', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, filePath, fileType, fileSize];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'documents';
  @override
  VerificationContext validateIntegrity(Insertable<DocumentRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('file_type')) {
      context.handle(_fileTypeMeta,
          fileType.isAcceptableOrUnknown(data['file_type']!, _fileTypeMeta));
    } else if (isInserting) {
      context.missing(_fileTypeMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(_fileSizeMeta,
          fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta));
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DocumentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      fileType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_type'])!,
      fileSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size'])!,
    );
  }

  @override
  $DocumentsTable createAlias(String alias) {
    return $DocumentsTable(attachedDatabase, alias);
  }
}

class DocumentRow extends DataClass implements Insertable<DocumentRow> {
  final String id;
  final String filePath;
  final String fileType;
  final int fileSize;
  const DocumentRow(
      {required this.id,
      required this.filePath,
      required this.fileType,
      required this.fileSize});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['file_path'] = Variable<String>(filePath);
    map['file_type'] = Variable<String>(fileType);
    map['file_size'] = Variable<int>(fileSize);
    return map;
  }

  DocumentsCompanion toCompanion(bool nullToAbsent) {
    return DocumentsCompanion(
      id: Value(id),
      filePath: Value(filePath),
      fileType: Value(fileType),
      fileSize: Value(fileSize),
    );
  }

  factory DocumentRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentRow(
      id: serializer.fromJson<String>(json['id']),
      filePath: serializer.fromJson<String>(json['filePath']),
      fileType: serializer.fromJson<String>(json['fileType']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'filePath': serializer.toJson<String>(filePath),
      'fileType': serializer.toJson<String>(fileType),
      'fileSize': serializer.toJson<int>(fileSize),
    };
  }

  DocumentRow copyWith(
          {String? id, String? filePath, String? fileType, int? fileSize}) =>
      DocumentRow(
        id: id ?? this.id,
        filePath: filePath ?? this.filePath,
        fileType: fileType ?? this.fileType,
        fileSize: fileSize ?? this.fileSize,
      );
  DocumentRow copyWithCompanion(DocumentsCompanion data) {
    return DocumentRow(
      id: data.id.present ? data.id.value : this.id,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      fileType: data.fileType.present ? data.fileType.value : this.fileType,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentRow(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('fileType: $fileType, ')
          ..write('fileSize: $fileSize')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, filePath, fileType, fileSize);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentRow &&
          other.id == this.id &&
          other.filePath == this.filePath &&
          other.fileType == this.fileType &&
          other.fileSize == this.fileSize);
}

class DocumentsCompanion extends UpdateCompanion<DocumentRow> {
  final Value<String> id;
  final Value<String> filePath;
  final Value<String> fileType;
  final Value<int> fileSize;
  final Value<int> rowid;
  const DocumentsCompanion({
    this.id = const Value.absent(),
    this.filePath = const Value.absent(),
    this.fileType = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentsCompanion.insert({
    required String id,
    required String filePath,
    required String fileType,
    required int fileSize,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        filePath = Value(filePath),
        fileType = Value(fileType),
        fileSize = Value(fileSize);
  static Insertable<DocumentRow> custom({
    Expression<String>? id,
    Expression<String>? filePath,
    Expression<String>? fileType,
    Expression<int>? fileSize,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (filePath != null) 'file_path': filePath,
      if (fileType != null) 'file_type': fileType,
      if (fileSize != null) 'file_size': fileSize,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? filePath,
      Value<String>? fileType,
      Value<int>? fileSize,
      Value<int>? rowid}) {
    return DocumentsCompanion(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (fileType.present) {
      map['file_type'] = Variable<String>(fileType.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentsCompanion(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('fileType: $fileType, ')
          ..write('fileSize: $fileSize, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, NoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES items (id)'));
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, content];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(Insertable<NoteRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class NoteRow extends DataClass implements Insertable<NoteRow> {
  final String id;
  final String content;
  const NoteRow({required this.id, required this.content});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['content'] = Variable<String>(content);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      content: Value(content),
    );
  }

  factory NoteRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteRow(
      id: serializer.fromJson<String>(json['id']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'content': serializer.toJson<String>(content),
    };
  }

  NoteRow copyWith({String? id, String? content}) => NoteRow(
        id: id ?? this.id,
        content: content ?? this.content,
      );
  NoteRow copyWithCompanion(NotesCompanion data) {
    return NoteRow(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteRow(')
          ..write('id: $id, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteRow &&
          other.id == this.id &&
          other.content == this.content);
}

class NotesCompanion extends UpdateCompanion<NoteRow> {
  final Value<String> id;
  final Value<String> content;
  final Value<int> rowid;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    required String id,
    required String content,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        content = Value(content);
  static Insertable<NoteRow> custom({
    Expression<String>? id,
    Expression<String>? content,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith(
      {Value<String>? id, Value<String>? content, Value<int>? rowid}) {
    return NotesCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, TagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
      'color', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name, color];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(Insertable<TagRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color']),
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class TagRow extends DataClass implements Insertable<TagRow> {
  final String id;
  final String name;
  final int? color;
  const TagRow({required this.id, required this.name, this.color});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
    );
  }

  factory TagRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int?>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int?>(color),
    };
  }

  TagRow copyWith(
          {String? id,
          String? name,
          Value<int?> color = const Value.absent()}) =>
      TagRow(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color.present ? color.value : this.color,
      );
  TagRow copyWithCompanion(TagsCompanion data) {
    return TagRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color);
}

class TagsCompanion extends UpdateCompanion<TagRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int?> color;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<TagRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? color,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int?>? color,
      Value<int>? rowid}) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemTagsTable extends ItemTags
    with TableInfo<$ItemTagsTable, ItemTagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES items (id)'));
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tags (id)'));
  @override
  List<GeneratedColumn> get $columns => [itemId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_tags';
  @override
  VerificationContext validateIntegrity(Insertable<ItemTagRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId, tagId};
  @override
  ItemTagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemTagRow(
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_id'])!,
    );
  }

  @override
  $ItemTagsTable createAlias(String alias) {
    return $ItemTagsTable(attachedDatabase, alias);
  }
}

class ItemTagRow extends DataClass implements Insertable<ItemTagRow> {
  final String itemId;
  final String tagId;
  const ItemTagRow({required this.itemId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  ItemTagsCompanion toCompanion(bool nullToAbsent) {
    return ItemTagsCompanion(
      itemId: Value(itemId),
      tagId: Value(tagId),
    );
  }

  factory ItemTagRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemTagRow(
      itemId: serializer.fromJson<String>(json['itemId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  ItemTagRow copyWith({String? itemId, String? tagId}) => ItemTagRow(
        itemId: itemId ?? this.itemId,
        tagId: tagId ?? this.tagId,
      );
  ItemTagRow copyWithCompanion(ItemTagsCompanion data) {
    return ItemTagRow(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemTagRow(')
          ..write('itemId: $itemId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemTagRow &&
          other.itemId == this.itemId &&
          other.tagId == this.tagId);
}

class ItemTagsCompanion extends UpdateCompanion<ItemTagRow> {
  final Value<String> itemId;
  final Value<String> tagId;
  final Value<int> rowid;
  const ItemTagsCompanion({
    this.itemId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemTagsCompanion.insert({
    required String itemId,
    required String tagId,
    this.rowid = const Value.absent(),
  })  : itemId = Value(itemId),
        tagId = Value(tagId);
  static Insertable<ItemTagRow> custom({
    Expression<String>? itemId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemTagsCompanion copyWith(
      {Value<String>? itemId, Value<String>? tagId, Value<int>? rowid}) {
    return ItemTagsCompanion(
      itemId: itemId ?? this.itemId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemTagsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $LinksTable links = $LinksTable(this);
  late final $DocumentsTable documents = $DocumentsTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $ItemTagsTable itemTags = $ItemTagsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [items, links, documents, notes, tags, itemTags];
}

typedef $$ItemsTableCreateCompanionBuilder = ItemsCompanion Function({
  required String id,
  required String type,
  required String title,
  Value<String?> description,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> isFavorite,
  Value<int> rowid,
});
typedef $$ItemsTableUpdateCompanionBuilder = ItemsCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<String> title,
  Value<String?> description,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isFavorite,
  Value<int> rowid,
});

final class $$ItemsTableReferences
    extends BaseReferences<_$AppDatabase, $ItemsTable, ItemRow> {
  $$ItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LinksTable, List<LinkRow>> _linksRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.links,
          aliasName: $_aliasNameGenerator(db.items.id, db.links.id));

  $$LinksTableProcessedTableManager get linksRefs {
    final manager = $$LinksTableTableManager($_db, $_db.links)
        .filter((f) => f.id.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_linksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DocumentsTable, List<DocumentRow>>
      _documentsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.documents,
              aliasName: $_aliasNameGenerator(db.items.id, db.documents.id));

  $$DocumentsTableProcessedTableManager get documentsRefs {
    final manager = $$DocumentsTableTableManager($_db, $_db.documents)
        .filter((f) => f.id.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_documentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$NotesTable, List<NoteRow>> _notesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.notes,
          aliasName: $_aliasNameGenerator(db.items.id, db.notes.id));

  $$NotesTableProcessedTableManager get notesRefs {
    final manager = $$NotesTableTableManager($_db, $_db.notes)
        .filter((f) => f.id.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_notesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ItemTagsTable, List<ItemTagRow>>
      _itemTagsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.itemTags,
              aliasName: $_aliasNameGenerator(db.items.id, db.itemTags.itemId));

  $$ItemTagsTableProcessedTableManager get itemTagsRefs {
    final manager = $$ItemTagsTableTableManager($_db, $_db.itemTags)
        .filter((f) => f.itemId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_itemTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ItemsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isFavorite => $state.composableBuilder(
      column: $state.table.isFavorite,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter linksRefs(
      ComposableFilter Function($$LinksTableFilterComposer f) f) {
    final $$LinksTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.links,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$LinksTableFilterComposer(
            ComposerState(
                $state.db, $state.db.links, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter documentsRefs(
      ComposableFilter Function($$DocumentsTableFilterComposer f) f) {
    final $$DocumentsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.documents,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$DocumentsTableFilterComposer(ComposerState(
                $state.db, $state.db.documents, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter notesRefs(
      ComposableFilter Function($$NotesTableFilterComposer f) f) {
    final $$NotesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.notes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$NotesTableFilterComposer(
            ComposerState(
                $state.db, $state.db.notes, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter itemTagsRefs(
      ComposableFilter Function($$ItemTagsTableFilterComposer f) f) {
    final $$ItemTagsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.itemTags,
        getReferencedColumn: (t) => t.itemId,
        builder: (joinBuilder, parentComposers) =>
            $$ItemTagsTableFilterComposer(ComposerState(
                $state.db, $state.db.itemTags, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$ItemsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isFavorite => $state.composableBuilder(
      column: $state.table.isFavorite,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$ItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ItemsTable,
    ItemRow,
    $$ItemsTableFilterComposer,
    $$ItemsTableOrderingComposer,
    $$ItemsTableCreateCompanionBuilder,
    $$ItemsTableUpdateCompanionBuilder,
    (ItemRow, $$ItemsTableReferences),
    ItemRow,
    PrefetchHooks Function(
        {bool linksRefs,
        bool documentsRefs,
        bool notesRefs,
        bool itemTagsRefs})> {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ItemsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ItemsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemsCompanion(
            id: id,
            type: type,
            title: title,
            description: description,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isFavorite: isFavorite,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            required String title,
            Value<String?> description = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> isFavorite = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemsCompanion.insert(
            id: id,
            type: type,
            title: title,
            description: description,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isFavorite: isFavorite,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ItemsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {linksRefs = false,
              documentsRefs = false,
              notesRefs = false,
              itemTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (linksRefs) db.links,
                if (documentsRefs) db.documents,
                if (notesRefs) db.notes,
                if (itemTagsRefs) db.itemTags
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (linksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ItemsTableReferences._linksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ItemsTableReferences(db, table, p0).linksRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) =>
                                referencedItems.where((e) => e.id == item.id),
                        typedResults: items),
                  if (documentsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ItemsTableReferences._documentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ItemsTableReferences(db, table, p0).documentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) =>
                                referencedItems.where((e) => e.id == item.id),
                        typedResults: items),
                  if (notesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ItemsTableReferences._notesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ItemsTableReferences(db, table, p0).notesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) =>
                                referencedItems.where((e) => e.id == item.id),
                        typedResults: items),
                  if (itemTagsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ItemsTableReferences._itemTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ItemsTableReferences(db, table, p0).itemTagsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.itemId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ItemsTable,
    ItemRow,
    $$ItemsTableFilterComposer,
    $$ItemsTableOrderingComposer,
    $$ItemsTableCreateCompanionBuilder,
    $$ItemsTableUpdateCompanionBuilder,
    (ItemRow, $$ItemsTableReferences),
    ItemRow,
    PrefetchHooks Function(
        {bool linksRefs,
        bool documentsRefs,
        bool notesRefs,
        bool itemTagsRefs})>;
typedef $$LinksTableCreateCompanionBuilder = LinksCompanion Function({
  required String id,
  required String url,
  Value<String?> faviconUrl,
  Value<int> rowid,
});
typedef $$LinksTableUpdateCompanionBuilder = LinksCompanion Function({
  Value<String> id,
  Value<String> url,
  Value<String?> faviconUrl,
  Value<int> rowid,
});

final class $$LinksTableReferences
    extends BaseReferences<_$AppDatabase, $LinksTable, LinkRow> {
  $$LinksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ItemsTable _idTable(_$AppDatabase db) =>
      db.items.createAlias($_aliasNameGenerator(db.links.id, db.items.id));

  $$ItemsTableProcessedTableManager? get id {
    if ($_item.id == null) return null;
    final manager = $$ItemsTableTableManager($_db, $_db.items)
        .filter((f) => f.id($_item.id!));
    final item = $_typedResult.readTableOrNull(_idTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$LinksTableFilterComposer
    extends FilterComposer<_$AppDatabase, $LinksTable> {
  $$LinksTableFilterComposer(super.$state);
  ColumnFilters<String> get url => $state.composableBuilder(
      column: $state.table.url,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get faviconUrl => $state.composableBuilder(
      column: $state.table.faviconUrl,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ItemsTableFilterComposer get id {
    final $$ItemsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.items,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$ItemsTableFilterComposer(
            ComposerState(
                $state.db, $state.db.items, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$LinksTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $LinksTable> {
  $$LinksTableOrderingComposer(super.$state);
  ColumnOrderings<String> get url => $state.composableBuilder(
      column: $state.table.url,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get faviconUrl => $state.composableBuilder(
      column: $state.table.faviconUrl,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ItemsTableOrderingComposer get id {
    final $$ItemsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.items,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$ItemsTableOrderingComposer(
            ComposerState(
                $state.db, $state.db.items, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$LinksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LinksTable,
    LinkRow,
    $$LinksTableFilterComposer,
    $$LinksTableOrderingComposer,
    $$LinksTableCreateCompanionBuilder,
    $$LinksTableUpdateCompanionBuilder,
    (LinkRow, $$LinksTableReferences),
    LinkRow,
    PrefetchHooks Function({bool id})> {
  $$LinksTableTableManager(_$AppDatabase db, $LinksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$LinksTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$LinksTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<String?> faviconUrl = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LinksCompanion(
            id: id,
            url: url,
            faviconUrl: faviconUrl,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String url,
            Value<String?> faviconUrl = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LinksCompanion.insert(
            id: id,
            url: url,
            faviconUrl: faviconUrl,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$LinksTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({id = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (id) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.id,
                    referencedTable: $$LinksTableReferences._idTable(db),
                    referencedColumn: $$LinksTableReferences._idTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$LinksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LinksTable,
    LinkRow,
    $$LinksTableFilterComposer,
    $$LinksTableOrderingComposer,
    $$LinksTableCreateCompanionBuilder,
    $$LinksTableUpdateCompanionBuilder,
    (LinkRow, $$LinksTableReferences),
    LinkRow,
    PrefetchHooks Function({bool id})>;
typedef $$DocumentsTableCreateCompanionBuilder = DocumentsCompanion Function({
  required String id,
  required String filePath,
  required String fileType,
  required int fileSize,
  Value<int> rowid,
});
typedef $$DocumentsTableUpdateCompanionBuilder = DocumentsCompanion Function({
  Value<String> id,
  Value<String> filePath,
  Value<String> fileType,
  Value<int> fileSize,
  Value<int> rowid,
});

final class $$DocumentsTableReferences
    extends BaseReferences<_$AppDatabase, $DocumentsTable, DocumentRow> {
  $$DocumentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ItemsTable _idTable(_$AppDatabase db) =>
      db.items.createAlias($_aliasNameGenerator(db.documents.id, db.items.id));

  $$ItemsTableProcessedTableManager? get id {
    if ($_item.id == null) return null;
    final manager = $$ItemsTableTableManager($_db, $_db.items)
        .filter((f) => f.id($_item.id!));
    final item = $_typedResult.readTableOrNull(_idTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DocumentsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableFilterComposer(super.$state);
  ColumnFilters<String> get filePath => $state.composableBuilder(
      column: $state.table.filePath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get fileType => $state.composableBuilder(
      column: $state.table.fileType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get fileSize => $state.composableBuilder(
      column: $state.table.fileSize,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ItemsTableFilterComposer get id {
    final $$ItemsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.items,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$ItemsTableFilterComposer(
            ComposerState(
                $state.db, $state.db.items, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$DocumentsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get filePath => $state.composableBuilder(
      column: $state.table.filePath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get fileType => $state.composableBuilder(
      column: $state.table.fileType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get fileSize => $state.composableBuilder(
      column: $state.table.fileSize,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ItemsTableOrderingComposer get id {
    final $$ItemsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.items,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$ItemsTableOrderingComposer(
            ComposerState(
                $state.db, $state.db.items, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$DocumentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DocumentsTable,
    DocumentRow,
    $$DocumentsTableFilterComposer,
    $$DocumentsTableOrderingComposer,
    $$DocumentsTableCreateCompanionBuilder,
    $$DocumentsTableUpdateCompanionBuilder,
    (DocumentRow, $$DocumentsTableReferences),
    DocumentRow,
    PrefetchHooks Function({bool id})> {
  $$DocumentsTableTableManager(_$AppDatabase db, $DocumentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$DocumentsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$DocumentsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<String> fileType = const Value.absent(),
            Value<int> fileSize = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DocumentsCompanion(
            id: id,
            filePath: filePath,
            fileType: fileType,
            fileSize: fileSize,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String filePath,
            required String fileType,
            required int fileSize,
            Value<int> rowid = const Value.absent(),
          }) =>
              DocumentsCompanion.insert(
            id: id,
            filePath: filePath,
            fileType: fileType,
            fileSize: fileSize,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DocumentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({id = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (id) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.id,
                    referencedTable: $$DocumentsTableReferences._idTable(db),
                    referencedColumn:
                        $$DocumentsTableReferences._idTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$DocumentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DocumentsTable,
    DocumentRow,
    $$DocumentsTableFilterComposer,
    $$DocumentsTableOrderingComposer,
    $$DocumentsTableCreateCompanionBuilder,
    $$DocumentsTableUpdateCompanionBuilder,
    (DocumentRow, $$DocumentsTableReferences),
    DocumentRow,
    PrefetchHooks Function({bool id})>;
typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({
  required String id,
  required String content,
  Value<int> rowid,
});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({
  Value<String> id,
  Value<String> content,
  Value<int> rowid,
});

final class $$NotesTableReferences
    extends BaseReferences<_$AppDatabase, $NotesTable, NoteRow> {
  $$NotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ItemsTable _idTable(_$AppDatabase db) =>
      db.items.createAlias($_aliasNameGenerator(db.notes.id, db.items.id));

  $$ItemsTableProcessedTableManager? get id {
    if ($_item.id == null) return null;
    final manager = $$ItemsTableTableManager($_db, $_db.items)
        .filter((f) => f.id($_item.id!));
    final item = $_typedResult.readTableOrNull(_idTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$NotesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer(super.$state);
  ColumnFilters<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ItemsTableFilterComposer get id {
    final $$ItemsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.items,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$ItemsTableFilterComposer(
            ComposerState(
                $state.db, $state.db.items, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$NotesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ItemsTableOrderingComposer get id {
    final $$ItemsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.items,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$ItemsTableOrderingComposer(
            ComposerState(
                $state.db, $state.db.items, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$NotesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotesTable,
    NoteRow,
    $$NotesTableFilterComposer,
    $$NotesTableOrderingComposer,
    $$NotesTableCreateCompanionBuilder,
    $$NotesTableUpdateCompanionBuilder,
    (NoteRow, $$NotesTableReferences),
    NoteRow,
    PrefetchHooks Function({bool id})> {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$NotesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$NotesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotesCompanion(
            id: id,
            content: content,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String content,
            Value<int> rowid = const Value.absent(),
          }) =>
              NotesCompanion.insert(
            id: id,
            content: content,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$NotesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({id = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (id) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.id,
                    referencedTable: $$NotesTableReferences._idTable(db),
                    referencedColumn: $$NotesTableReferences._idTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$NotesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NotesTable,
    NoteRow,
    $$NotesTableFilterComposer,
    $$NotesTableOrderingComposer,
    $$NotesTableCreateCompanionBuilder,
    $$NotesTableUpdateCompanionBuilder,
    (NoteRow, $$NotesTableReferences),
    NoteRow,
    PrefetchHooks Function({bool id})>;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  required String id,
  required String name,
  Value<int?> color,
  Value<int> rowid,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int?> color,
  Value<int> rowid,
});

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, TagRow> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ItemTagsTable, List<ItemTagRow>>
      _itemTagsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.itemTags,
              aliasName: $_aliasNameGenerator(db.tags.id, db.itemTags.tagId));

  $$ItemTagsTableProcessedTableManager get itemTagsRefs {
    final manager = $$ItemTagsTableTableManager($_db, $_db.itemTags)
        .filter((f) => f.tagId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_itemTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TagsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter itemTagsRefs(
      ComposableFilter Function($$ItemTagsTableFilterComposer f) f) {
    final $$ItemTagsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.itemTags,
        getReferencedColumn: (t) => t.tagId,
        builder: (joinBuilder, parentComposers) =>
            $$ItemTagsTableFilterComposer(ComposerState(
                $state.db, $state.db.itemTags, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$TagsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$TagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TagsTable,
    TagRow,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (TagRow, $$TagsTableReferences),
    TagRow,
    PrefetchHooks Function({bool itemTagsRefs})> {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TagsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TagsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int?> color = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion(
            id: id,
            name: name,
            color: color,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<int?> color = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion.insert(
            id: id,
            name: name,
            color: color,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TagsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({itemTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (itemTagsRefs) db.itemTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (itemTagsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$TagsTableReferences._itemTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TagsTableReferences(db, table, p0).itemTagsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.tagId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TagsTable,
    TagRow,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (TagRow, $$TagsTableReferences),
    TagRow,
    PrefetchHooks Function({bool itemTagsRefs})>;
typedef $$ItemTagsTableCreateCompanionBuilder = ItemTagsCompanion Function({
  required String itemId,
  required String tagId,
  Value<int> rowid,
});
typedef $$ItemTagsTableUpdateCompanionBuilder = ItemTagsCompanion Function({
  Value<String> itemId,
  Value<String> tagId,
  Value<int> rowid,
});

final class $$ItemTagsTableReferences
    extends BaseReferences<_$AppDatabase, $ItemTagsTable, ItemTagRow> {
  $$ItemTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ItemsTable _itemIdTable(_$AppDatabase db) => db.items
      .createAlias($_aliasNameGenerator(db.itemTags.itemId, db.items.id));

  $$ItemsTableProcessedTableManager? get itemId {
    if ($_item.itemId == null) return null;
    final manager = $$ItemsTableTableManager($_db, $_db.items)
        .filter((f) => f.id($_item.itemId!));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias($_aliasNameGenerator(db.itemTags.tagId, db.tags.id));

  $$TagsTableProcessedTableManager? get tagId {
    if ($_item.tagId == null) return null;
    final manager = $$TagsTableTableManager($_db, $_db.tags)
        .filter((f) => f.id($_item.tagId!));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ItemTagsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ItemTagsTable> {
  $$ItemTagsTableFilterComposer(super.$state);
  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.itemId,
        referencedTable: $state.db.items,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$ItemsTableFilterComposer(
            ComposerState(
                $state.db, $state.db.items, joinBuilder, parentComposers)));
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $state.db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$TagsTableFilterComposer(
            ComposerState(
                $state.db, $state.db.tags, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ItemTagsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ItemTagsTable> {
  $$ItemTagsTableOrderingComposer(super.$state);
  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.itemId,
        referencedTable: $state.db.items,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$ItemsTableOrderingComposer(
            ComposerState(
                $state.db, $state.db.items, joinBuilder, parentComposers)));
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $state.db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$TagsTableOrderingComposer(
            ComposerState(
                $state.db, $state.db.tags, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ItemTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ItemTagsTable,
    ItemTagRow,
    $$ItemTagsTableFilterComposer,
    $$ItemTagsTableOrderingComposer,
    $$ItemTagsTableCreateCompanionBuilder,
    $$ItemTagsTableUpdateCompanionBuilder,
    (ItemTagRow, $$ItemTagsTableReferences),
    ItemTagRow,
    PrefetchHooks Function({bool itemId, bool tagId})> {
  $$ItemTagsTableTableManager(_$AppDatabase db, $ItemTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ItemTagsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ItemTagsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> itemId = const Value.absent(),
            Value<String> tagId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemTagsCompanion(
            itemId: itemId,
            tagId: tagId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String itemId,
            required String tagId,
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemTagsCompanion.insert(
            itemId: itemId,
            tagId: tagId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ItemTagsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({itemId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (itemId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.itemId,
                    referencedTable: $$ItemTagsTableReferences._itemIdTable(db),
                    referencedColumn:
                        $$ItemTagsTableReferences._itemIdTable(db).id,
                  ) as T;
                }
                if (tagId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.tagId,
                    referencedTable: $$ItemTagsTableReferences._tagIdTable(db),
                    referencedColumn:
                        $$ItemTagsTableReferences._tagIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ItemTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ItemTagsTable,
    ItemTagRow,
    $$ItemTagsTableFilterComposer,
    $$ItemTagsTableOrderingComposer,
    $$ItemTagsTableCreateCompanionBuilder,
    $$ItemTagsTableUpdateCompanionBuilder,
    (ItemTagRow, $$ItemTagsTableReferences),
    ItemTagRow,
    PrefetchHooks Function({bool itemId, bool tagId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$LinksTableTableManager get links =>
      $$LinksTableTableManager(_db, _db.links);
  $$DocumentsTableTableManager get documents =>
      $$DocumentsTableTableManager(_db, _db.documents);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$ItemTagsTableTableManager get itemTags =>
      $$ItemTagsTableTableManager(_db, _db.itemTags);
}
