// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SubjectsTable extends Subjects with TableInfo<$SubjectsTable, Subject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, color, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subjects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subject(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $SubjectsTable createAlias(String alias) {
    return $SubjectsTable(attachedDatabase, alias);
  }
}

class Subject extends DataClass implements Insertable<Subject> {
  final String id;
  final String name;

  /// ARGB color value.
  final int color;
  final int sortOrder;
  const Subject({
    required this.id,
    required this.name,
    required this.color,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  SubjectsCompanion toCompanion(bool nullToAbsent) {
    return SubjectsCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      sortOrder: Value(sortOrder),
    );
  }

  factory Subject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subject(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Subject copyWith({String? id, String? name, int? color, int? sortOrder}) =>
      Subject(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  Subject copyWithCompanion(SubjectsCompanion data) {
    return Subject(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subject(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subject &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.sortOrder == this.sortOrder);
}

class SubjectsCompanion extends UpdateCompanion<Subject> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> color;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const SubjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubjectsCompanion.insert({
    required String id,
    required String name,
    required int color,
    required int sortOrder,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       color = Value(color),
       sortOrder = Value(sortOrder);
  static Insertable<Subject> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? color,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? color,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return SubjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PdfFilesTable extends PdfFiles with TableInfo<$PdfFilesTable, PdfFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PdfFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, path, pageCount, sha256];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pdf_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<PdfFile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    } else if (isInserting) {
      context.missing(_pageCountMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PdfFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PdfFile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
    );
  }

  @override
  $PdfFilesTable createAlias(String alias) {
    return $PdfFilesTable(attachedDatabase, alias);
  }
}

class PdfFile extends DataClass implements Insertable<PdfFile> {
  final String id;

  /// Path of the copy inside app storage.
  final String path;
  final int pageCount;
  final String sha256;
  const PdfFile({
    required this.id,
    required this.path,
    required this.pageCount,
    required this.sha256,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['path'] = Variable<String>(path);
    map['page_count'] = Variable<int>(pageCount);
    map['sha256'] = Variable<String>(sha256);
    return map;
  }

  PdfFilesCompanion toCompanion(bool nullToAbsent) {
    return PdfFilesCompanion(
      id: Value(id),
      path: Value(path),
      pageCount: Value(pageCount),
      sha256: Value(sha256),
    );
  }

  factory PdfFile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PdfFile(
      id: serializer.fromJson<String>(json['id']),
      path: serializer.fromJson<String>(json['path']),
      pageCount: serializer.fromJson<int>(json['pageCount']),
      sha256: serializer.fromJson<String>(json['sha256']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'path': serializer.toJson<String>(path),
      'pageCount': serializer.toJson<int>(pageCount),
      'sha256': serializer.toJson<String>(sha256),
    };
  }

  PdfFile copyWith({
    String? id,
    String? path,
    int? pageCount,
    String? sha256,
  }) => PdfFile(
    id: id ?? this.id,
    path: path ?? this.path,
    pageCount: pageCount ?? this.pageCount,
    sha256: sha256 ?? this.sha256,
  );
  PdfFile copyWithCompanion(PdfFilesCompanion data) {
    return PdfFile(
      id: data.id.present ? data.id.value : this.id,
      path: data.path.present ? data.path.value : this.path,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PdfFile(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('pageCount: $pageCount, ')
          ..write('sha256: $sha256')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, path, pageCount, sha256);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PdfFile &&
          other.id == this.id &&
          other.path == this.path &&
          other.pageCount == this.pageCount &&
          other.sha256 == this.sha256);
}

class PdfFilesCompanion extends UpdateCompanion<PdfFile> {
  final Value<String> id;
  final Value<String> path;
  final Value<int> pageCount;
  final Value<String> sha256;
  final Value<int> rowid;
  const PdfFilesCompanion({
    this.id = const Value.absent(),
    this.path = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PdfFilesCompanion.insert({
    required String id,
    required String path,
    required int pageCount,
    required String sha256,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       path = Value(path),
       pageCount = Value(pageCount),
       sha256 = Value(sha256);
  static Insertable<PdfFile> custom({
    Expression<String>? id,
    Expression<String>? path,
    Expression<int>? pageCount,
    Expression<String>? sha256,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (path != null) 'path': path,
      if (pageCount != null) 'page_count': pageCount,
      if (sha256 != null) 'sha256': sha256,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PdfFilesCompanion copyWith({
    Value<String>? id,
    Value<String>? path,
    Value<int>? pageCount,
    Value<String>? sha256,
    Value<int>? rowid,
  }) {
    return PdfFilesCompanion(
      id: id ?? this.id,
      path: path ?? this.path,
      pageCount: pageCount ?? this.pageCount,
      sha256: sha256 ?? this.sha256,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PdfFilesCompanion(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('pageCount: $pageCount, ')
          ..write('sha256: $sha256, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotebooksTable extends Notebooks
    with TableInfo<$NotebooksTable, Notebook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotebooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subjects (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<NotebookKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<NotebookKind>($NotebooksTable.$converterkind);
  static const VerificationMeta _pdfFileIdMeta = const VerificationMeta(
    'pdfFileId',
  );
  @override
  late final GeneratedColumn<String> pdfFileId = GeneratedColumn<String>(
    'pdf_file_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pdf_files (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> pageIds =
      GeneratedColumn<String>(
        'page_ids',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($NotebooksTable.$converterpageIds);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($NotebooksTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($NotebooksTable.$converterupdatedAt);
  static const VerificationMeta _lastPageIdMeta = const VerificationMeta(
    'lastPageId',
  );
  @override
  late final GeneratedColumn<String> lastPageId = GeneratedColumn<String>(
    'last_page_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastZoomMeta = const VerificationMeta(
    'lastZoom',
  );
  @override
  late final GeneratedColumn<double> lastZoom = GeneratedColumn<double>(
    'last_zoom',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    subjectId,
    title,
    kind,
    pdfFileId,
    pageIds,
    createdAt,
    updatedAt,
    lastPageId,
    lastZoom,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notebooks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Notebook> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('pdf_file_id')) {
      context.handle(
        _pdfFileIdMeta,
        pdfFileId.isAcceptableOrUnknown(data['pdf_file_id']!, _pdfFileIdMeta),
      );
    }
    if (data.containsKey('last_page_id')) {
      context.handle(
        _lastPageIdMeta,
        lastPageId.isAcceptableOrUnknown(
          data['last_page_id']!,
          _lastPageIdMeta,
        ),
      );
    }
    if (data.containsKey('last_zoom')) {
      context.handle(
        _lastZoomMeta,
        lastZoom.isAcceptableOrUnknown(data['last_zoom']!, _lastZoomMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Notebook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Notebook(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      kind: $NotebooksTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      pdfFileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pdf_file_id'],
      ),
      pageIds: $NotebooksTable.$converterpageIds.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}page_ids'],
        )!,
      ),
      createdAt: $NotebooksTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $NotebooksTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      lastPageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_page_id'],
      ),
      lastZoom: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}last_zoom'],
      )!,
    );
  }

  @override
  $NotebooksTable createAlias(String alias) {
    return $NotebooksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<NotebookKind, String, String> $converterkind =
      const EnumNameConverter<NotebookKind>(NotebookKind.values);
  static TypeConverter<List<String>, String> $converterpageIds =
      const StringListConverter();
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const MillisDateTimeConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const MillisDateTimeConverter();
}

class Notebook extends DataClass implements Insertable<Notebook> {
  final String id;
  final String? subjectId;
  final String title;
  final NotebookKind kind;
  final String? pdfFileId;

  /// Page order. Reordering pages rewrites only this column.
  final List<String> pageIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastPageId;
  final double lastZoom;
  const Notebook({
    required this.id,
    this.subjectId,
    required this.title,
    required this.kind,
    this.pdfFileId,
    required this.pageIds,
    required this.createdAt,
    required this.updatedAt,
    this.lastPageId,
    required this.lastZoom,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || subjectId != null) {
      map['subject_id'] = Variable<String>(subjectId);
    }
    map['title'] = Variable<String>(title);
    {
      map['kind'] = Variable<String>(
        $NotebooksTable.$converterkind.toSql(kind),
      );
    }
    if (!nullToAbsent || pdfFileId != null) {
      map['pdf_file_id'] = Variable<String>(pdfFileId);
    }
    {
      map['page_ids'] = Variable<String>(
        $NotebooksTable.$converterpageIds.toSql(pageIds),
      );
    }
    {
      map['created_at'] = Variable<int>(
        $NotebooksTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $NotebooksTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || lastPageId != null) {
      map['last_page_id'] = Variable<String>(lastPageId);
    }
    map['last_zoom'] = Variable<double>(lastZoom);
    return map;
  }

  NotebooksCompanion toCompanion(bool nullToAbsent) {
    return NotebooksCompanion(
      id: Value(id),
      subjectId: subjectId == null && nullToAbsent
          ? const Value.absent()
          : Value(subjectId),
      title: Value(title),
      kind: Value(kind),
      pdfFileId: pdfFileId == null && nullToAbsent
          ? const Value.absent()
          : Value(pdfFileId),
      pageIds: Value(pageIds),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastPageId: lastPageId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPageId),
      lastZoom: Value(lastZoom),
    );
  }

  factory Notebook.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Notebook(
      id: serializer.fromJson<String>(json['id']),
      subjectId: serializer.fromJson<String?>(json['subjectId']),
      title: serializer.fromJson<String>(json['title']),
      kind: $NotebooksTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      pdfFileId: serializer.fromJson<String?>(json['pdfFileId']),
      pageIds: serializer.fromJson<List<String>>(json['pageIds']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastPageId: serializer.fromJson<String?>(json['lastPageId']),
      lastZoom: serializer.fromJson<double>(json['lastZoom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subjectId': serializer.toJson<String?>(subjectId),
      'title': serializer.toJson<String>(title),
      'kind': serializer.toJson<String>(
        $NotebooksTable.$converterkind.toJson(kind),
      ),
      'pdfFileId': serializer.toJson<String?>(pdfFileId),
      'pageIds': serializer.toJson<List<String>>(pageIds),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastPageId': serializer.toJson<String?>(lastPageId),
      'lastZoom': serializer.toJson<double>(lastZoom),
    };
  }

  Notebook copyWith({
    String? id,
    Value<String?> subjectId = const Value.absent(),
    String? title,
    NotebookKind? kind,
    Value<String?> pdfFileId = const Value.absent(),
    List<String>? pageIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> lastPageId = const Value.absent(),
    double? lastZoom,
  }) => Notebook(
    id: id ?? this.id,
    subjectId: subjectId.present ? subjectId.value : this.subjectId,
    title: title ?? this.title,
    kind: kind ?? this.kind,
    pdfFileId: pdfFileId.present ? pdfFileId.value : this.pdfFileId,
    pageIds: pageIds ?? this.pageIds,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastPageId: lastPageId.present ? lastPageId.value : this.lastPageId,
    lastZoom: lastZoom ?? this.lastZoom,
  );
  Notebook copyWithCompanion(NotebooksCompanion data) {
    return Notebook(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      title: data.title.present ? data.title.value : this.title,
      kind: data.kind.present ? data.kind.value : this.kind,
      pdfFileId: data.pdfFileId.present ? data.pdfFileId.value : this.pdfFileId,
      pageIds: data.pageIds.present ? data.pageIds.value : this.pageIds,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastPageId: data.lastPageId.present
          ? data.lastPageId.value
          : this.lastPageId,
      lastZoom: data.lastZoom.present ? data.lastZoom.value : this.lastZoom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Notebook(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('title: $title, ')
          ..write('kind: $kind, ')
          ..write('pdfFileId: $pdfFileId, ')
          ..write('pageIds: $pageIds, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastPageId: $lastPageId, ')
          ..write('lastZoom: $lastZoom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    subjectId,
    title,
    kind,
    pdfFileId,
    pageIds,
    createdAt,
    updatedAt,
    lastPageId,
    lastZoom,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Notebook &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.title == this.title &&
          other.kind == this.kind &&
          other.pdfFileId == this.pdfFileId &&
          other.pageIds == this.pageIds &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastPageId == this.lastPageId &&
          other.lastZoom == this.lastZoom);
}

class NotebooksCompanion extends UpdateCompanion<Notebook> {
  final Value<String> id;
  final Value<String?> subjectId;
  final Value<String> title;
  final Value<NotebookKind> kind;
  final Value<String?> pdfFileId;
  final Value<List<String>> pageIds;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> lastPageId;
  final Value<double> lastZoom;
  final Value<int> rowid;
  const NotebooksCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.title = const Value.absent(),
    this.kind = const Value.absent(),
    this.pdfFileId = const Value.absent(),
    this.pageIds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastPageId = const Value.absent(),
    this.lastZoom = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotebooksCompanion.insert({
    required String id,
    this.subjectId = const Value.absent(),
    required String title,
    required NotebookKind kind,
    this.pdfFileId = const Value.absent(),
    required List<String> pageIds,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.lastPageId = const Value.absent(),
    this.lastZoom = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       kind = Value(kind),
       pageIds = Value(pageIds),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Notebook> custom({
    Expression<String>? id,
    Expression<String>? subjectId,
    Expression<String>? title,
    Expression<String>? kind,
    Expression<String>? pdfFileId,
    Expression<String>? pageIds,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? lastPageId,
    Expression<double>? lastZoom,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (title != null) 'title': title,
      if (kind != null) 'kind': kind,
      if (pdfFileId != null) 'pdf_file_id': pdfFileId,
      if (pageIds != null) 'page_ids': pageIds,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastPageId != null) 'last_page_id': lastPageId,
      if (lastZoom != null) 'last_zoom': lastZoom,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotebooksCompanion copyWith({
    Value<String>? id,
    Value<String?>? subjectId,
    Value<String>? title,
    Value<NotebookKind>? kind,
    Value<String?>? pdfFileId,
    Value<List<String>>? pageIds,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? lastPageId,
    Value<double>? lastZoom,
    Value<int>? rowid,
  }) {
    return NotebooksCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      kind: kind ?? this.kind,
      pdfFileId: pdfFileId ?? this.pdfFileId,
      pageIds: pageIds ?? this.pageIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastPageId: lastPageId ?? this.lastPageId,
      lastZoom: lastZoom ?? this.lastZoom,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $NotebooksTable.$converterkind.toSql(kind.value),
      );
    }
    if (pdfFileId.present) {
      map['pdf_file_id'] = Variable<String>(pdfFileId.value);
    }
    if (pageIds.present) {
      map['page_ids'] = Variable<String>(
        $NotebooksTable.$converterpageIds.toSql(pageIds.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $NotebooksTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $NotebooksTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (lastPageId.present) {
      map['last_page_id'] = Variable<String>(lastPageId.value);
    }
    if (lastZoom.present) {
      map['last_zoom'] = Variable<double>(lastZoom.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotebooksCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('title: $title, ')
          ..write('kind: $kind, ')
          ..write('pdfFileId: $pdfFileId, ')
          ..write('pageIds: $pageIds, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastPageId: $lastPageId, ')
          ..write('lastZoom: $lastZoom, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PagesTable extends Pages with TableInfo<$PagesTable, NotebookPage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notebookIdMeta = const VerificationMeta(
    'notebookId',
  );
  @override
  late final GeneratedColumn<String> notebookId = GeneratedColumn<String>(
    'notebook_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES notebooks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<double> width = GeneratedColumn<double>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<double> height = GeneratedColumn<double>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PageBackground, String>
  background = GeneratedColumn<String>(
    'background',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<PageBackground>($PagesTable.$converterbackground);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    notebookId,
    width,
    height,
    background,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pages';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotebookPage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('notebook_id')) {
      context.handle(
        _notebookIdMeta,
        notebookId.isAcceptableOrUnknown(data['notebook_id']!, _notebookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_notebookIdMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotebookPage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotebookPage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      notebookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notebook_id'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}width'],
      )!,
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height'],
      )!,
      background: $PagesTable.$converterbackground.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}background'],
        )!,
      ),
    );
  }

  @override
  $PagesTable createAlias(String alias) {
    return $PagesTable(attachedDatabase, alias);
  }

  static TypeConverter<PageBackground, String> $converterbackground =
      const PageBackgroundConverter();
}

class NotebookPage extends DataClass implements Insertable<NotebookPage> {
  final String id;
  final String notebookId;
  final double width;
  final double height;
  final PageBackground background;
  const NotebookPage({
    required this.id,
    required this.notebookId,
    required this.width,
    required this.height,
    required this.background,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['notebook_id'] = Variable<String>(notebookId);
    map['width'] = Variable<double>(width);
    map['height'] = Variable<double>(height);
    {
      map['background'] = Variable<String>(
        $PagesTable.$converterbackground.toSql(background),
      );
    }
    return map;
  }

  PagesCompanion toCompanion(bool nullToAbsent) {
    return PagesCompanion(
      id: Value(id),
      notebookId: Value(notebookId),
      width: Value(width),
      height: Value(height),
      background: Value(background),
    );
  }

  factory NotebookPage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotebookPage(
      id: serializer.fromJson<String>(json['id']),
      notebookId: serializer.fromJson<String>(json['notebookId']),
      width: serializer.fromJson<double>(json['width']),
      height: serializer.fromJson<double>(json['height']),
      background: serializer.fromJson<PageBackground>(json['background']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'notebookId': serializer.toJson<String>(notebookId),
      'width': serializer.toJson<double>(width),
      'height': serializer.toJson<double>(height),
      'background': serializer.toJson<PageBackground>(background),
    };
  }

  NotebookPage copyWith({
    String? id,
    String? notebookId,
    double? width,
    double? height,
    PageBackground? background,
  }) => NotebookPage(
    id: id ?? this.id,
    notebookId: notebookId ?? this.notebookId,
    width: width ?? this.width,
    height: height ?? this.height,
    background: background ?? this.background,
  );
  NotebookPage copyWithCompanion(PagesCompanion data) {
    return NotebookPage(
      id: data.id.present ? data.id.value : this.id,
      notebookId: data.notebookId.present
          ? data.notebookId.value
          : this.notebookId,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      background: data.background.present
          ? data.background.value
          : this.background,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotebookPage(')
          ..write('id: $id, ')
          ..write('notebookId: $notebookId, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('background: $background')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, notebookId, width, height, background);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotebookPage &&
          other.id == this.id &&
          other.notebookId == this.notebookId &&
          other.width == this.width &&
          other.height == this.height &&
          other.background == this.background);
}

class PagesCompanion extends UpdateCompanion<NotebookPage> {
  final Value<String> id;
  final Value<String> notebookId;
  final Value<double> width;
  final Value<double> height;
  final Value<PageBackground> background;
  final Value<int> rowid;
  const PagesCompanion({
    this.id = const Value.absent(),
    this.notebookId = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.background = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PagesCompanion.insert({
    required String id,
    required String notebookId,
    required double width,
    required double height,
    required PageBackground background,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       notebookId = Value(notebookId),
       width = Value(width),
       height = Value(height),
       background = Value(background);
  static Insertable<NotebookPage> custom({
    Expression<String>? id,
    Expression<String>? notebookId,
    Expression<double>? width,
    Expression<double>? height,
    Expression<String>? background,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (notebookId != null) 'notebook_id': notebookId,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (background != null) 'background': background,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PagesCompanion copyWith({
    Value<String>? id,
    Value<String>? notebookId,
    Value<double>? width,
    Value<double>? height,
    Value<PageBackground>? background,
    Value<int>? rowid,
  }) {
    return PagesCompanion(
      id: id ?? this.id,
      notebookId: notebookId ?? this.notebookId,
      width: width ?? this.width,
      height: height ?? this.height,
      background: background ?? this.background,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (notebookId.present) {
      map['notebook_id'] = Variable<String>(notebookId.value);
    }
    if (width.present) {
      map['width'] = Variable<double>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<double>(height.value);
    }
    if (background.present) {
      map['background'] = Variable<String>(
        $PagesTable.$converterbackground.toSql(background.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PagesCompanion(')
          ..write('id: $id, ')
          ..write('notebookId: $notebookId, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('background: $background, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StrokesTable extends Strokes with TableInfo<$StrokesTable, Stroke> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StrokesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageIdMeta = const VerificationMeta('pageId');
  @override
  late final GeneratedColumn<String> pageId = GeneratedColumn<String>(
    'page_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pages (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<StrokeTool, String> tool =
      GeneratedColumn<String>(
        'tool',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<StrokeTool>($StrokesTable.$convertertool);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<double> size = GeneratedColumn<double>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Float32List, Uint8List> points =
      GeneratedColumn<Uint8List>(
        'points',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<Float32List>($StrokesTable.$converterpoints);
  static const VerificationMeta _minXMeta = const VerificationMeta('minX');
  @override
  late final GeneratedColumn<double> minX = GeneratedColumn<double>(
    'min_x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minYMeta = const VerificationMeta('minY');
  @override
  late final GeneratedColumn<double> minY = GeneratedColumn<double>(
    'min_y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxXMeta = const VerificationMeta('maxX');
  @override
  late final GeneratedColumn<double> maxX = GeneratedColumn<double>(
    'max_x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxYMeta = const VerificationMeta('maxY');
  @override
  late final GeneratedColumn<double> maxY = GeneratedColumn<double>(
    'max_y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($StrokesTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pageId,
    tool,
    color,
    size,
    points,
    minX,
    minY,
    maxX,
    maxY,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'strokes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Stroke> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('page_id')) {
      context.handle(
        _pageIdMeta,
        pageId.isAcceptableOrUnknown(data['page_id']!, _pageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pageIdMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('min_x')) {
      context.handle(
        _minXMeta,
        minX.isAcceptableOrUnknown(data['min_x']!, _minXMeta),
      );
    } else if (isInserting) {
      context.missing(_minXMeta);
    }
    if (data.containsKey('min_y')) {
      context.handle(
        _minYMeta,
        minY.isAcceptableOrUnknown(data['min_y']!, _minYMeta),
      );
    } else if (isInserting) {
      context.missing(_minYMeta);
    }
    if (data.containsKey('max_x')) {
      context.handle(
        _maxXMeta,
        maxX.isAcceptableOrUnknown(data['max_x']!, _maxXMeta),
      );
    } else if (isInserting) {
      context.missing(_maxXMeta);
    }
    if (data.containsKey('max_y')) {
      context.handle(
        _maxYMeta,
        maxY.isAcceptableOrUnknown(data['max_y']!, _maxYMeta),
      );
    } else if (isInserting) {
      context.missing(_maxYMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Stroke map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Stroke(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}page_id'],
      )!,
      tool: $StrokesTable.$convertertool.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tool'],
        )!,
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}size'],
      )!,
      points: $StrokesTable.$converterpoints.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}points'],
        )!,
      ),
      minX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_x'],
      )!,
      minY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_y'],
      )!,
      maxX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_x'],
      )!,
      maxY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_y'],
      )!,
      createdAt: $StrokesTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  $StrokesTable createAlias(String alias) {
    return $StrokesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<StrokeTool, String, String> $convertertool =
      const EnumNameConverter<StrokeTool>(StrokeTool.values);
  static TypeConverter<Float32List, Uint8List> $converterpoints =
      const Float32ListConverter();
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const MillisDateTimeConverter();
}

class Stroke extends DataClass implements Insertable<Stroke> {
  final String id;
  final String pageId;
  final StrokeTool tool;

  /// ARGB color value.
  final int color;
  final double size;

  /// x, y, pressure repeated.
  final Float32List points;
  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  /// Also the draw order: undoing an erase must restore the original value.
  final DateTime createdAt;
  const Stroke({
    required this.id,
    required this.pageId,
    required this.tool,
    required this.color,
    required this.size,
    required this.points,
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['page_id'] = Variable<String>(pageId);
    {
      map['tool'] = Variable<String>($StrokesTable.$convertertool.toSql(tool));
    }
    map['color'] = Variable<int>(color);
    map['size'] = Variable<double>(size);
    {
      map['points'] = Variable<Uint8List>(
        $StrokesTable.$converterpoints.toSql(points),
      );
    }
    map['min_x'] = Variable<double>(minX);
    map['min_y'] = Variable<double>(minY);
    map['max_x'] = Variable<double>(maxX);
    map['max_y'] = Variable<double>(maxY);
    {
      map['created_at'] = Variable<int>(
        $StrokesTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  StrokesCompanion toCompanion(bool nullToAbsent) {
    return StrokesCompanion(
      id: Value(id),
      pageId: Value(pageId),
      tool: Value(tool),
      color: Value(color),
      size: Value(size),
      points: Value(points),
      minX: Value(minX),
      minY: Value(minY),
      maxX: Value(maxX),
      maxY: Value(maxY),
      createdAt: Value(createdAt),
    );
  }

  factory Stroke.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Stroke(
      id: serializer.fromJson<String>(json['id']),
      pageId: serializer.fromJson<String>(json['pageId']),
      tool: $StrokesTable.$convertertool.fromJson(
        serializer.fromJson<String>(json['tool']),
      ),
      color: serializer.fromJson<int>(json['color']),
      size: serializer.fromJson<double>(json['size']),
      points: serializer.fromJson<Float32List>(json['points']),
      minX: serializer.fromJson<double>(json['minX']),
      minY: serializer.fromJson<double>(json['minY']),
      maxX: serializer.fromJson<double>(json['maxX']),
      maxY: serializer.fromJson<double>(json['maxY']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pageId': serializer.toJson<String>(pageId),
      'tool': serializer.toJson<String>(
        $StrokesTable.$convertertool.toJson(tool),
      ),
      'color': serializer.toJson<int>(color),
      'size': serializer.toJson<double>(size),
      'points': serializer.toJson<Float32List>(points),
      'minX': serializer.toJson<double>(minX),
      'minY': serializer.toJson<double>(minY),
      'maxX': serializer.toJson<double>(maxX),
      'maxY': serializer.toJson<double>(maxY),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Stroke copyWith({
    String? id,
    String? pageId,
    StrokeTool? tool,
    int? color,
    double? size,
    Float32List? points,
    double? minX,
    double? minY,
    double? maxX,
    double? maxY,
    DateTime? createdAt,
  }) => Stroke(
    id: id ?? this.id,
    pageId: pageId ?? this.pageId,
    tool: tool ?? this.tool,
    color: color ?? this.color,
    size: size ?? this.size,
    points: points ?? this.points,
    minX: minX ?? this.minX,
    minY: minY ?? this.minY,
    maxX: maxX ?? this.maxX,
    maxY: maxY ?? this.maxY,
    createdAt: createdAt ?? this.createdAt,
  );
  Stroke copyWithCompanion(StrokesCompanion data) {
    return Stroke(
      id: data.id.present ? data.id.value : this.id,
      pageId: data.pageId.present ? data.pageId.value : this.pageId,
      tool: data.tool.present ? data.tool.value : this.tool,
      color: data.color.present ? data.color.value : this.color,
      size: data.size.present ? data.size.value : this.size,
      points: data.points.present ? data.points.value : this.points,
      minX: data.minX.present ? data.minX.value : this.minX,
      minY: data.minY.present ? data.minY.value : this.minY,
      maxX: data.maxX.present ? data.maxX.value : this.maxX,
      maxY: data.maxY.present ? data.maxY.value : this.maxY,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Stroke(')
          ..write('id: $id, ')
          ..write('pageId: $pageId, ')
          ..write('tool: $tool, ')
          ..write('color: $color, ')
          ..write('size: $size, ')
          ..write('points: $points, ')
          ..write('minX: $minX, ')
          ..write('minY: $minY, ')
          ..write('maxX: $maxX, ')
          ..write('maxY: $maxY, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pageId,
    tool,
    color,
    size,
    points,
    minX,
    minY,
    maxX,
    maxY,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Stroke &&
          other.id == this.id &&
          other.pageId == this.pageId &&
          other.tool == this.tool &&
          other.color == this.color &&
          other.size == this.size &&
          other.points == this.points &&
          other.minX == this.minX &&
          other.minY == this.minY &&
          other.maxX == this.maxX &&
          other.maxY == this.maxY &&
          other.createdAt == this.createdAt);
}

class StrokesCompanion extends UpdateCompanion<Stroke> {
  final Value<String> id;
  final Value<String> pageId;
  final Value<StrokeTool> tool;
  final Value<int> color;
  final Value<double> size;
  final Value<Float32List> points;
  final Value<double> minX;
  final Value<double> minY;
  final Value<double> maxX;
  final Value<double> maxY;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const StrokesCompanion({
    this.id = const Value.absent(),
    this.pageId = const Value.absent(),
    this.tool = const Value.absent(),
    this.color = const Value.absent(),
    this.size = const Value.absent(),
    this.points = const Value.absent(),
    this.minX = const Value.absent(),
    this.minY = const Value.absent(),
    this.maxX = const Value.absent(),
    this.maxY = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StrokesCompanion.insert({
    required String id,
    required String pageId,
    required StrokeTool tool,
    required int color,
    required double size,
    required Float32List points,
    required double minX,
    required double minY,
    required double maxX,
    required double maxY,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       pageId = Value(pageId),
       tool = Value(tool),
       color = Value(color),
       size = Value(size),
       points = Value(points),
       minX = Value(minX),
       minY = Value(minY),
       maxX = Value(maxX),
       maxY = Value(maxY),
       createdAt = Value(createdAt);
  static Insertable<Stroke> custom({
    Expression<String>? id,
    Expression<String>? pageId,
    Expression<String>? tool,
    Expression<int>? color,
    Expression<double>? size,
    Expression<Uint8List>? points,
    Expression<double>? minX,
    Expression<double>? minY,
    Expression<double>? maxX,
    Expression<double>? maxY,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pageId != null) 'page_id': pageId,
      if (tool != null) 'tool': tool,
      if (color != null) 'color': color,
      if (size != null) 'size': size,
      if (points != null) 'points': points,
      if (minX != null) 'min_x': minX,
      if (minY != null) 'min_y': minY,
      if (maxX != null) 'max_x': maxX,
      if (maxY != null) 'max_y': maxY,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StrokesCompanion copyWith({
    Value<String>? id,
    Value<String>? pageId,
    Value<StrokeTool>? tool,
    Value<int>? color,
    Value<double>? size,
    Value<Float32List>? points,
    Value<double>? minX,
    Value<double>? minY,
    Value<double>? maxX,
    Value<double>? maxY,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return StrokesCompanion(
      id: id ?? this.id,
      pageId: pageId ?? this.pageId,
      tool: tool ?? this.tool,
      color: color ?? this.color,
      size: size ?? this.size,
      points: points ?? this.points,
      minX: minX ?? this.minX,
      minY: minY ?? this.minY,
      maxX: maxX ?? this.maxX,
      maxY: maxY ?? this.maxY,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pageId.present) {
      map['page_id'] = Variable<String>(pageId.value);
    }
    if (tool.present) {
      map['tool'] = Variable<String>(
        $StrokesTable.$convertertool.toSql(tool.value),
      );
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (size.present) {
      map['size'] = Variable<double>(size.value);
    }
    if (points.present) {
      map['points'] = Variable<Uint8List>(
        $StrokesTable.$converterpoints.toSql(points.value),
      );
    }
    if (minX.present) {
      map['min_x'] = Variable<double>(minX.value);
    }
    if (minY.present) {
      map['min_y'] = Variable<double>(minY.value);
    }
    if (maxX.present) {
      map['max_x'] = Variable<double>(maxX.value);
    }
    if (maxY.present) {
      map['max_y'] = Variable<double>(maxY.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $StrokesTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StrokesCompanion(')
          ..write('id: $id, ')
          ..write('pageId: $pageId, ')
          ..write('tool: $tool, ')
          ..write('color: $color, ')
          ..write('size: $size, ')
          ..write('points: $points, ')
          ..write('minX: $minX, ')
          ..write('minY: $minY, ')
          ..write('maxX: $maxX, ')
          ..write('maxY: $maxY, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TapesTable extends Tapes with TableInfo<$TapesTable, Tape> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TapesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageIdMeta = const VerificationMeta('pageId');
  @override
  late final GeneratedColumn<String> pageId = GeneratedColumn<String>(
    'page_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pages (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Float32List, Uint8List> points =
      GeneratedColumn<Uint8List>(
        'points',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<Float32List>($TapesTable.$converterpoints);
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<double> width = GeneratedColumn<double>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _styleMeta = const VerificationMeta('style');
  @override
  late final GeneratedColumn<String> style = GeneratedColumn<String>(
    'style',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('solid'),
  );
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  @override
  late final GeneratedColumn<bool> hidden = GeneratedColumn<bool>(
    'hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _minXMeta = const VerificationMeta('minX');
  @override
  late final GeneratedColumn<double> minX = GeneratedColumn<double>(
    'min_x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minYMeta = const VerificationMeta('minY');
  @override
  late final GeneratedColumn<double> minY = GeneratedColumn<double>(
    'min_y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxXMeta = const VerificationMeta('maxX');
  @override
  late final GeneratedColumn<double> maxX = GeneratedColumn<double>(
    'max_x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxYMeta = const VerificationMeta('maxY');
  @override
  late final GeneratedColumn<double> maxY = GeneratedColumn<double>(
    'max_y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<StudyResult?, String>
  studyLastResult = GeneratedColumn<String>(
    'study_last_result',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<StudyResult?>($TapesTable.$converterstudyLastResultn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> studyDueAt =
      GeneratedColumn<int>(
        'study_due_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($TapesTable.$converterstudyDueAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($TapesTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pageId,
    points,
    width,
    style,
    hidden,
    minX,
    minY,
    maxX,
    maxY,
    studyLastResult,
    studyDueAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tapes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tape> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('page_id')) {
      context.handle(
        _pageIdMeta,
        pageId.isAcceptableOrUnknown(data['page_id']!, _pageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pageIdMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('style')) {
      context.handle(
        _styleMeta,
        style.isAcceptableOrUnknown(data['style']!, _styleMeta),
      );
    }
    if (data.containsKey('hidden')) {
      context.handle(
        _hiddenMeta,
        hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta),
      );
    }
    if (data.containsKey('min_x')) {
      context.handle(
        _minXMeta,
        minX.isAcceptableOrUnknown(data['min_x']!, _minXMeta),
      );
    } else if (isInserting) {
      context.missing(_minXMeta);
    }
    if (data.containsKey('min_y')) {
      context.handle(
        _minYMeta,
        minY.isAcceptableOrUnknown(data['min_y']!, _minYMeta),
      );
    } else if (isInserting) {
      context.missing(_minYMeta);
    }
    if (data.containsKey('max_x')) {
      context.handle(
        _maxXMeta,
        maxX.isAcceptableOrUnknown(data['max_x']!, _maxXMeta),
      );
    } else if (isInserting) {
      context.missing(_maxXMeta);
    }
    if (data.containsKey('max_y')) {
      context.handle(
        _maxYMeta,
        maxY.isAcceptableOrUnknown(data['max_y']!, _maxYMeta),
      );
    } else if (isInserting) {
      context.missing(_maxYMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tape map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tape(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}page_id'],
      )!,
      points: $TapesTable.$converterpoints.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}points'],
        )!,
      ),
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}width'],
      )!,
      style: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}style'],
      )!,
      hidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hidden'],
      )!,
      minX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_x'],
      )!,
      minY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_y'],
      )!,
      maxX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_x'],
      )!,
      maxY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_y'],
      )!,
      studyLastResult: $TapesTable.$converterstudyLastResultn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}study_last_result'],
        ),
      ),
      studyDueAt: $TapesTable.$converterstudyDueAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}study_due_at'],
        ),
      ),
      createdAt: $TapesTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  $TapesTable createAlias(String alias) {
    return $TapesTable(attachedDatabase, alias);
  }

  static TypeConverter<Float32List, Uint8List> $converterpoints =
      const Float32ListConverter();
  static JsonTypeConverter2<StudyResult, String, String>
  $converterstudyLastResult = const EnumNameConverter<StudyResult>(
    StudyResult.values,
  );
  static JsonTypeConverter2<StudyResult?, String?, String?>
  $converterstudyLastResultn = JsonTypeConverter2.asNullable(
    $converterstudyLastResult,
  );
  static TypeConverter<DateTime, int> $converterstudyDueAt =
      const MillisDateTimeConverter();
  static TypeConverter<DateTime?, int?> $converterstudyDueAtn =
      NullAwareTypeConverter.wrap($converterstudyDueAt);
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const MillisDateTimeConverter();
}

class Tape extends DataClass implements Insertable<Tape> {
  final String id;
  final String pageId;

  /// x, y, pressure repeated (centerline of the band).
  final Float32List points;
  final double width;
  final String style;
  final bool hidden;
  final double minX;
  final double minY;
  final double maxX;
  final double maxY;
  final StudyResult? studyLastResult;
  final DateTime? studyDueAt;
  final DateTime createdAt;
  const Tape({
    required this.id,
    required this.pageId,
    required this.points,
    required this.width,
    required this.style,
    required this.hidden,
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
    this.studyLastResult,
    this.studyDueAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['page_id'] = Variable<String>(pageId);
    {
      map['points'] = Variable<Uint8List>(
        $TapesTable.$converterpoints.toSql(points),
      );
    }
    map['width'] = Variable<double>(width);
    map['style'] = Variable<String>(style);
    map['hidden'] = Variable<bool>(hidden);
    map['min_x'] = Variable<double>(minX);
    map['min_y'] = Variable<double>(minY);
    map['max_x'] = Variable<double>(maxX);
    map['max_y'] = Variable<double>(maxY);
    if (!nullToAbsent || studyLastResult != null) {
      map['study_last_result'] = Variable<String>(
        $TapesTable.$converterstudyLastResultn.toSql(studyLastResult),
      );
    }
    if (!nullToAbsent || studyDueAt != null) {
      map['study_due_at'] = Variable<int>(
        $TapesTable.$converterstudyDueAtn.toSql(studyDueAt),
      );
    }
    {
      map['created_at'] = Variable<int>(
        $TapesTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  TapesCompanion toCompanion(bool nullToAbsent) {
    return TapesCompanion(
      id: Value(id),
      pageId: Value(pageId),
      points: Value(points),
      width: Value(width),
      style: Value(style),
      hidden: Value(hidden),
      minX: Value(minX),
      minY: Value(minY),
      maxX: Value(maxX),
      maxY: Value(maxY),
      studyLastResult: studyLastResult == null && nullToAbsent
          ? const Value.absent()
          : Value(studyLastResult),
      studyDueAt: studyDueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(studyDueAt),
      createdAt: Value(createdAt),
    );
  }

  factory Tape.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tape(
      id: serializer.fromJson<String>(json['id']),
      pageId: serializer.fromJson<String>(json['pageId']),
      points: serializer.fromJson<Float32List>(json['points']),
      width: serializer.fromJson<double>(json['width']),
      style: serializer.fromJson<String>(json['style']),
      hidden: serializer.fromJson<bool>(json['hidden']),
      minX: serializer.fromJson<double>(json['minX']),
      minY: serializer.fromJson<double>(json['minY']),
      maxX: serializer.fromJson<double>(json['maxX']),
      maxY: serializer.fromJson<double>(json['maxY']),
      studyLastResult: $TapesTable.$converterstudyLastResultn.fromJson(
        serializer.fromJson<String?>(json['studyLastResult']),
      ),
      studyDueAt: serializer.fromJson<DateTime?>(json['studyDueAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pageId': serializer.toJson<String>(pageId),
      'points': serializer.toJson<Float32List>(points),
      'width': serializer.toJson<double>(width),
      'style': serializer.toJson<String>(style),
      'hidden': serializer.toJson<bool>(hidden),
      'minX': serializer.toJson<double>(minX),
      'minY': serializer.toJson<double>(minY),
      'maxX': serializer.toJson<double>(maxX),
      'maxY': serializer.toJson<double>(maxY),
      'studyLastResult': serializer.toJson<String?>(
        $TapesTable.$converterstudyLastResultn.toJson(studyLastResult),
      ),
      'studyDueAt': serializer.toJson<DateTime?>(studyDueAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Tape copyWith({
    String? id,
    String? pageId,
    Float32List? points,
    double? width,
    String? style,
    bool? hidden,
    double? minX,
    double? minY,
    double? maxX,
    double? maxY,
    Value<StudyResult?> studyLastResult = const Value.absent(),
    Value<DateTime?> studyDueAt = const Value.absent(),
    DateTime? createdAt,
  }) => Tape(
    id: id ?? this.id,
    pageId: pageId ?? this.pageId,
    points: points ?? this.points,
    width: width ?? this.width,
    style: style ?? this.style,
    hidden: hidden ?? this.hidden,
    minX: minX ?? this.minX,
    minY: minY ?? this.minY,
    maxX: maxX ?? this.maxX,
    maxY: maxY ?? this.maxY,
    studyLastResult: studyLastResult.present
        ? studyLastResult.value
        : this.studyLastResult,
    studyDueAt: studyDueAt.present ? studyDueAt.value : this.studyDueAt,
    createdAt: createdAt ?? this.createdAt,
  );
  Tape copyWithCompanion(TapesCompanion data) {
    return Tape(
      id: data.id.present ? data.id.value : this.id,
      pageId: data.pageId.present ? data.pageId.value : this.pageId,
      points: data.points.present ? data.points.value : this.points,
      width: data.width.present ? data.width.value : this.width,
      style: data.style.present ? data.style.value : this.style,
      hidden: data.hidden.present ? data.hidden.value : this.hidden,
      minX: data.minX.present ? data.minX.value : this.minX,
      minY: data.minY.present ? data.minY.value : this.minY,
      maxX: data.maxX.present ? data.maxX.value : this.maxX,
      maxY: data.maxY.present ? data.maxY.value : this.maxY,
      studyLastResult: data.studyLastResult.present
          ? data.studyLastResult.value
          : this.studyLastResult,
      studyDueAt: data.studyDueAt.present
          ? data.studyDueAt.value
          : this.studyDueAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tape(')
          ..write('id: $id, ')
          ..write('pageId: $pageId, ')
          ..write('points: $points, ')
          ..write('width: $width, ')
          ..write('style: $style, ')
          ..write('hidden: $hidden, ')
          ..write('minX: $minX, ')
          ..write('minY: $minY, ')
          ..write('maxX: $maxX, ')
          ..write('maxY: $maxY, ')
          ..write('studyLastResult: $studyLastResult, ')
          ..write('studyDueAt: $studyDueAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pageId,
    points,
    width,
    style,
    hidden,
    minX,
    minY,
    maxX,
    maxY,
    studyLastResult,
    studyDueAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tape &&
          other.id == this.id &&
          other.pageId == this.pageId &&
          other.points == this.points &&
          other.width == this.width &&
          other.style == this.style &&
          other.hidden == this.hidden &&
          other.minX == this.minX &&
          other.minY == this.minY &&
          other.maxX == this.maxX &&
          other.maxY == this.maxY &&
          other.studyLastResult == this.studyLastResult &&
          other.studyDueAt == this.studyDueAt &&
          other.createdAt == this.createdAt);
}

class TapesCompanion extends UpdateCompanion<Tape> {
  final Value<String> id;
  final Value<String> pageId;
  final Value<Float32List> points;
  final Value<double> width;
  final Value<String> style;
  final Value<bool> hidden;
  final Value<double> minX;
  final Value<double> minY;
  final Value<double> maxX;
  final Value<double> maxY;
  final Value<StudyResult?> studyLastResult;
  final Value<DateTime?> studyDueAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TapesCompanion({
    this.id = const Value.absent(),
    this.pageId = const Value.absent(),
    this.points = const Value.absent(),
    this.width = const Value.absent(),
    this.style = const Value.absent(),
    this.hidden = const Value.absent(),
    this.minX = const Value.absent(),
    this.minY = const Value.absent(),
    this.maxX = const Value.absent(),
    this.maxY = const Value.absent(),
    this.studyLastResult = const Value.absent(),
    this.studyDueAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TapesCompanion.insert({
    required String id,
    required String pageId,
    required Float32List points,
    required double width,
    this.style = const Value.absent(),
    this.hidden = const Value.absent(),
    required double minX,
    required double minY,
    required double maxX,
    required double maxY,
    this.studyLastResult = const Value.absent(),
    this.studyDueAt = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       pageId = Value(pageId),
       points = Value(points),
       width = Value(width),
       minX = Value(minX),
       minY = Value(minY),
       maxX = Value(maxX),
       maxY = Value(maxY),
       createdAt = Value(createdAt);
  static Insertable<Tape> custom({
    Expression<String>? id,
    Expression<String>? pageId,
    Expression<Uint8List>? points,
    Expression<double>? width,
    Expression<String>? style,
    Expression<bool>? hidden,
    Expression<double>? minX,
    Expression<double>? minY,
    Expression<double>? maxX,
    Expression<double>? maxY,
    Expression<String>? studyLastResult,
    Expression<int>? studyDueAt,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pageId != null) 'page_id': pageId,
      if (points != null) 'points': points,
      if (width != null) 'width': width,
      if (style != null) 'style': style,
      if (hidden != null) 'hidden': hidden,
      if (minX != null) 'min_x': minX,
      if (minY != null) 'min_y': minY,
      if (maxX != null) 'max_x': maxX,
      if (maxY != null) 'max_y': maxY,
      if (studyLastResult != null) 'study_last_result': studyLastResult,
      if (studyDueAt != null) 'study_due_at': studyDueAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TapesCompanion copyWith({
    Value<String>? id,
    Value<String>? pageId,
    Value<Float32List>? points,
    Value<double>? width,
    Value<String>? style,
    Value<bool>? hidden,
    Value<double>? minX,
    Value<double>? minY,
    Value<double>? maxX,
    Value<double>? maxY,
    Value<StudyResult?>? studyLastResult,
    Value<DateTime?>? studyDueAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TapesCompanion(
      id: id ?? this.id,
      pageId: pageId ?? this.pageId,
      points: points ?? this.points,
      width: width ?? this.width,
      style: style ?? this.style,
      hidden: hidden ?? this.hidden,
      minX: minX ?? this.minX,
      minY: minY ?? this.minY,
      maxX: maxX ?? this.maxX,
      maxY: maxY ?? this.maxY,
      studyLastResult: studyLastResult ?? this.studyLastResult,
      studyDueAt: studyDueAt ?? this.studyDueAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pageId.present) {
      map['page_id'] = Variable<String>(pageId.value);
    }
    if (points.present) {
      map['points'] = Variable<Uint8List>(
        $TapesTable.$converterpoints.toSql(points.value),
      );
    }
    if (width.present) {
      map['width'] = Variable<double>(width.value);
    }
    if (style.present) {
      map['style'] = Variable<String>(style.value);
    }
    if (hidden.present) {
      map['hidden'] = Variable<bool>(hidden.value);
    }
    if (minX.present) {
      map['min_x'] = Variable<double>(minX.value);
    }
    if (minY.present) {
      map['min_y'] = Variable<double>(minY.value);
    }
    if (maxX.present) {
      map['max_x'] = Variable<double>(maxX.value);
    }
    if (maxY.present) {
      map['max_y'] = Variable<double>(maxY.value);
    }
    if (studyLastResult.present) {
      map['study_last_result'] = Variable<String>(
        $TapesTable.$converterstudyLastResultn.toSql(studyLastResult.value),
      );
    }
    if (studyDueAt.present) {
      map['study_due_at'] = Variable<int>(
        $TapesTable.$converterstudyDueAtn.toSql(studyDueAt.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $TapesTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TapesCompanion(')
          ..write('id: $id, ')
          ..write('pageId: $pageId, ')
          ..write('points: $points, ')
          ..write('width: $width, ')
          ..write('style: $style, ')
          ..write('hidden: $hidden, ')
          ..write('minX: $minX, ')
          ..write('minY: $minY, ')
          ..write('maxX: $maxX, ')
          ..write('maxY: $maxY, ')
          ..write('studyLastResult: $studyLastResult, ')
          ..write('studyDueAt: $studyDueAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$MarginDatabase extends GeneratedDatabase {
  _$MarginDatabase(QueryExecutor e) : super(e);
  $MarginDatabaseManager get managers => $MarginDatabaseManager(this);
  late final $SubjectsTable subjects = $SubjectsTable(this);
  late final $PdfFilesTable pdfFiles = $PdfFilesTable(this);
  late final $NotebooksTable notebooks = $NotebooksTable(this);
  late final $PagesTable pages = $PagesTable(this);
  late final $StrokesTable strokes = $StrokesTable(this);
  late final $TapesTable tapes = $TapesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final Index pagesNotebookId = Index(
    'pages_notebook_id',
    'CREATE INDEX pages_notebook_id ON pages (notebook_id)',
  );
  late final Index strokesPageId = Index(
    'strokes_page_id',
    'CREATE INDEX strokes_page_id ON strokes (page_id)',
  );
  late final Index tapesPageId = Index(
    'tapes_page_id',
    'CREATE INDEX tapes_page_id ON tapes (page_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    subjects,
    pdfFiles,
    notebooks,
    pages,
    strokes,
    tapes,
    settings,
    pagesNotebookId,
    strokesPageId,
    tapesPageId,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'subjects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('notebooks', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'notebooks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pages', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pages',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('strokes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pages',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tapes', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SubjectsTableCreateCompanionBuilder = SubjectsCompanion Function({
  required String id,
  required String name,
  required int color,
  required int sortOrder,
  Value<int> rowid,
});
typedef $$SubjectsTableUpdateCompanionBuilder = SubjectsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> color,
  Value<int> sortOrder,
  Value<int> rowid,
});

final class $$SubjectsTableReferences
    extends BaseReferences<_$MarginDatabase, $SubjectsTable, Subject> {
  $$SubjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$NotebooksTable, List<Notebook>>
  _notebooksRefsTable(_$MarginDatabase db) => MultiTypedResultKey.fromTable(
    db.notebooks,
    aliasName: 'subjects__id__notebooks__subject_id',
  );

  $$NotebooksTableProcessedTableManager get notebooksRefs {
    final manager = $$NotebooksTableTableManager(
      $_db,
      $_db.notebooks,
    ).filter((f) => f.subjectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_notebooksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SubjectsTableFilterComposer
    extends Composer<_$MarginDatabase, $SubjectsTable> {
  $$SubjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> notebooksRefs(
    Expression<bool> Function($$NotebooksTableFilterComposer f) f,
  ) {
    final $$NotebooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notebooks,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotebooksTableFilterComposer(
            $db: $db,
            $table: $db.notebooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubjectsTableOrderingComposer
    extends Composer<_$MarginDatabase, $SubjectsTable> {
  $$SubjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubjectsTableAnnotationComposer
    extends Composer<_$MarginDatabase, $SubjectsTable> {
  $$SubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> notebooksRefs<T extends Object>(
    Expression<T> Function($$NotebooksTableAnnotationComposer a) f,
  ) {
    final $$NotebooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notebooks,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotebooksTableAnnotationComposer(
            $db: $db,
            $table: $db.notebooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubjectsTableTableManager
    extends
        RootTableManager<
          _$MarginDatabase,
          $SubjectsTable,
          Subject,
          $$SubjectsTableFilterComposer,
          $$SubjectsTableOrderingComposer,
          $$SubjectsTableAnnotationComposer,
          $$SubjectsTableCreateCompanionBuilder,
          $$SubjectsTableUpdateCompanionBuilder,
          (Subject, $$SubjectsTableReferences),
          Subject,
          PrefetchHooks Function({bool notebooksRefs})
        > {
  $$SubjectsTableTableManager(_$MarginDatabase db, $SubjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubjectsCompanion(
                id: id,
                name: name,
                color: color,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int color,
                required int sortOrder,
                Value<int> rowid = const Value.absent(),
              }) => SubjectsCompanion.insert(
                id: id,
                name: name,
                color: color,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SubjectsTable, Subject>(table),
                  $$SubjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({notebooksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (notebooksRefs) db.notebooks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (notebooksRefs)
                    await $_getPrefetchedDataByColumns<
                      Subject,
                      $SubjectsTable,
                      Notebook,
                      $NotebooksTable
                    >(
                      currentTable: table,
                      referencedTable: $$SubjectsTableReferences
                          ._notebooksRefsTable(db),
                      managerFromTypedResult: (p0) => $$SubjectsTableReferences(
                        db,
                        table,
                        p0,
                      ).notebooksRefs,
                      currentColumn: 'id',
                      referencedColumn: 'subject_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SubjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$MarginDatabase,
      $SubjectsTable,
      Subject,
      $$SubjectsTableFilterComposer,
      $$SubjectsTableOrderingComposer,
      $$SubjectsTableAnnotationComposer,
      $$SubjectsTableCreateCompanionBuilder,
      $$SubjectsTableUpdateCompanionBuilder,
      (Subject, $$SubjectsTableReferences),
      Subject,
      PrefetchHooks Function({bool notebooksRefs})
    >;
typedef $$PdfFilesTableCreateCompanionBuilder = PdfFilesCompanion Function({
  required String id,
  required String path,
  required int pageCount,
  required String sha256,
  Value<int> rowid,
});
typedef $$PdfFilesTableUpdateCompanionBuilder = PdfFilesCompanion Function({
  Value<String> id,
  Value<String> path,
  Value<int> pageCount,
  Value<String> sha256,
  Value<int> rowid,
});

final class $$PdfFilesTableReferences
    extends BaseReferences<_$MarginDatabase, $PdfFilesTable, PdfFile> {
  $$PdfFilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$NotebooksTable, List<Notebook>>
  _notebooksRefsTable(_$MarginDatabase db) => MultiTypedResultKey.fromTable(
    db.notebooks,
    aliasName: 'pdf_files__id__notebooks__pdf_file_id',
  );

  $$NotebooksTableProcessedTableManager get notebooksRefs {
    final manager = $$NotebooksTableTableManager(
      $_db,
      $_db.notebooks,
    ).filter((f) => f.pdfFileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_notebooksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PdfFilesTableFilterComposer
    extends Composer<_$MarginDatabase, $PdfFilesTable> {
  $$PdfFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> notebooksRefs(
    Expression<bool> Function($$NotebooksTableFilterComposer f) f,
  ) {
    final $$NotebooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notebooks,
      getReferencedColumn: (t) => t.pdfFileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotebooksTableFilterComposer(
            $db: $db,
            $table: $db.notebooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PdfFilesTableOrderingComposer
    extends Composer<_$MarginDatabase, $PdfFilesTable> {
  $$PdfFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PdfFilesTableAnnotationComposer
    extends Composer<_$MarginDatabase, $PdfFilesTable> {
  $$PdfFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  Expression<T> notebooksRefs<T extends Object>(
    Expression<T> Function($$NotebooksTableAnnotationComposer a) f,
  ) {
    final $$NotebooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notebooks,
      getReferencedColumn: (t) => t.pdfFileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotebooksTableAnnotationComposer(
            $db: $db,
            $table: $db.notebooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PdfFilesTableTableManager
    extends
        RootTableManager<
          _$MarginDatabase,
          $PdfFilesTable,
          PdfFile,
          $$PdfFilesTableFilterComposer,
          $$PdfFilesTableOrderingComposer,
          $$PdfFilesTableAnnotationComposer,
          $$PdfFilesTableCreateCompanionBuilder,
          $$PdfFilesTableUpdateCompanionBuilder,
          (PdfFile, $$PdfFilesTableReferences),
          PdfFile,
          PrefetchHooks Function({bool notebooksRefs})
        > {
  $$PdfFilesTableTableManager(_$MarginDatabase db, $PdfFilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PdfFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PdfFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PdfFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<int> pageCount = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PdfFilesCompanion(
                id: id,
                path: path,
                pageCount: pageCount,
                sha256: sha256,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String path,
                required int pageCount,
                required String sha256,
                Value<int> rowid = const Value.absent(),
              }) => PdfFilesCompanion.insert(
                id: id,
                path: path,
                pageCount: pageCount,
                sha256: sha256,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PdfFilesTable, PdfFile>(table),
                  $$PdfFilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({notebooksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (notebooksRefs) db.notebooks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (notebooksRefs)
                    await $_getPrefetchedDataByColumns<
                      PdfFile,
                      $PdfFilesTable,
                      Notebook,
                      $NotebooksTable
                    >(
                      currentTable: table,
                      referencedTable: $$PdfFilesTableReferences
                          ._notebooksRefsTable(db),
                      managerFromTypedResult: (p0) => $$PdfFilesTableReferences(
                        db,
                        table,
                        p0,
                      ).notebooksRefs,
                      currentColumn: 'id',
                      referencedColumn: 'pdf_file_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PdfFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$MarginDatabase,
      $PdfFilesTable,
      PdfFile,
      $$PdfFilesTableFilterComposer,
      $$PdfFilesTableOrderingComposer,
      $$PdfFilesTableAnnotationComposer,
      $$PdfFilesTableCreateCompanionBuilder,
      $$PdfFilesTableUpdateCompanionBuilder,
      (PdfFile, $$PdfFilesTableReferences),
      PdfFile,
      PrefetchHooks Function({bool notebooksRefs})
    >;
typedef $$NotebooksTableCreateCompanionBuilder = NotebooksCompanion Function({
  required String id,
  Value<String?> subjectId,
  required String title,
  required NotebookKind kind,
  Value<String?> pdfFileId,
  required List<String> pageIds,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String?> lastPageId,
  Value<double> lastZoom,
  Value<int> rowid,
});
typedef $$NotebooksTableUpdateCompanionBuilder = NotebooksCompanion Function({
  Value<String> id,
  Value<String?> subjectId,
  Value<String> title,
  Value<NotebookKind> kind,
  Value<String?> pdfFileId,
  Value<List<String>> pageIds,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String?> lastPageId,
  Value<double> lastZoom,
  Value<int> rowid,
});

final class $$NotebooksTableReferences
    extends BaseReferences<_$MarginDatabase, $NotebooksTable, Notebook> {
  $$NotebooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SubjectsTable _subjectIdTable(_$MarginDatabase db) =>
      db.subjects.createAlias('notebooks__subject_id__subjects__id');

  $$SubjectsTableProcessedTableManager? get subjectId {
    final $_column = $_itemColumn<String>('subject_id');
    if ($_column == null) return null;
    final manager = $$SubjectsTableTableManager(
      $_db,
      $_db.subjects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subjectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PdfFilesTable _pdfFileIdTable(_$MarginDatabase db) =>
      db.pdfFiles.createAlias('notebooks__pdf_file_id__pdf_files__id');

  $$PdfFilesTableProcessedTableManager? get pdfFileId {
    final $_column = $_itemColumn<String>('pdf_file_id');
    if ($_column == null) return null;
    final manager = $$PdfFilesTableTableManager(
      $_db,
      $_db.pdfFiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pdfFileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PagesTable, List<NotebookPage>> _pagesRefsTable(
    _$MarginDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.pages,
    aliasName: 'notebooks__id__pages__notebook_id',
  );

  $$PagesTableProcessedTableManager get pagesRefs {
    final manager = $$PagesTableTableManager(
      $_db,
      $_db.pages,
    ).filter((f) => f.notebookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_pagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NotebooksTableFilterComposer
    extends Composer<_$MarginDatabase, $NotebooksTable> {
  $$NotebooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<NotebookKind, NotebookKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get pageIds => $composableBuilder(
    column: $table.pageIds,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get lastPageId => $composableBuilder(
    column: $table.lastPageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lastZoom => $composableBuilder(
    column: $table.lastZoom,
    builder: (column) => ColumnFilters(column),
  );

  $$SubjectsTableFilterComposer get subjectId {
    final $$SubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableFilterComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PdfFilesTableFilterComposer get pdfFileId {
    final $$PdfFilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pdfFileId,
      referencedTable: $db.pdfFiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PdfFilesTableFilterComposer(
            $db: $db,
            $table: $db.pdfFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> pagesRefs(
    Expression<bool> Function($$PagesTableFilterComposer f) f,
  ) {
    final $$PagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pages,
      getReferencedColumn: (t) => t.notebookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagesTableFilterComposer(
            $db: $db,
            $table: $db.pages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotebooksTableOrderingComposer
    extends Composer<_$MarginDatabase, $NotebooksTable> {
  $$NotebooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pageIds => $composableBuilder(
    column: $table.pageIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastPageId => $composableBuilder(
    column: $table.lastPageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lastZoom => $composableBuilder(
    column: $table.lastZoom,
    builder: (column) => ColumnOrderings(column),
  );

  $$SubjectsTableOrderingComposer get subjectId {
    final $$SubjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableOrderingComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PdfFilesTableOrderingComposer get pdfFileId {
    final $$PdfFilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pdfFileId,
      referencedTable: $db.pdfFiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PdfFilesTableOrderingComposer(
            $db: $db,
            $table: $db.pdfFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotebooksTableAnnotationComposer
    extends Composer<_$MarginDatabase, $NotebooksTable> {
  $$NotebooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumnWithTypeConverter<NotebookKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get pageIds =>
      $composableBuilder(column: $table.pageIds, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get lastPageId => $composableBuilder(
    column: $table.lastPageId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lastZoom =>
      $composableBuilder(column: $table.lastZoom, builder: (column) => column);

  $$SubjectsTableAnnotationComposer get subjectId {
    final $$SubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PdfFilesTableAnnotationComposer get pdfFileId {
    final $$PdfFilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pdfFileId,
      referencedTable: $db.pdfFiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PdfFilesTableAnnotationComposer(
            $db: $db,
            $table: $db.pdfFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> pagesRefs<T extends Object>(
    Expression<T> Function($$PagesTableAnnotationComposer a) f,
  ) {
    final $$PagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pages,
      getReferencedColumn: (t) => t.notebookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagesTableAnnotationComposer(
            $db: $db,
            $table: $db.pages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotebooksTableTableManager
    extends
        RootTableManager<
          _$MarginDatabase,
          $NotebooksTable,
          Notebook,
          $$NotebooksTableFilterComposer,
          $$NotebooksTableOrderingComposer,
          $$NotebooksTableAnnotationComposer,
          $$NotebooksTableCreateCompanionBuilder,
          $$NotebooksTableUpdateCompanionBuilder,
          (Notebook, $$NotebooksTableReferences),
          Notebook,
          PrefetchHooks Function({
            bool subjectId,
            bool pdfFileId,
            bool pagesRefs,
          })
        > {
  $$NotebooksTableTableManager(_$MarginDatabase db, $NotebooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotebooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotebooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotebooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> subjectId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<NotebookKind> kind = const Value.absent(),
                Value<String?> pdfFileId = const Value.absent(),
                Value<List<String>> pageIds = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> lastPageId = const Value.absent(),
                Value<double> lastZoom = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotebooksCompanion(
                id: id,
                subjectId: subjectId,
                title: title,
                kind: kind,
                pdfFileId: pdfFileId,
                pageIds: pageIds,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastPageId: lastPageId,
                lastZoom: lastZoom,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> subjectId = const Value.absent(),
                required String title,
                required NotebookKind kind,
                Value<String?> pdfFileId = const Value.absent(),
                required List<String> pageIds,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String?> lastPageId = const Value.absent(),
                Value<double> lastZoom = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotebooksCompanion.insert(
                id: id,
                subjectId: subjectId,
                title: title,
                kind: kind,
                pdfFileId: pdfFileId,
                pageIds: pageIds,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastPageId: lastPageId,
                lastZoom: lastZoom,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NotebooksTable, Notebook>(table),
                  $$NotebooksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({subjectId = false, pdfFileId = false, pagesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (pagesRefs) db.pages],
                  addJoins:
                      <
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
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (subjectId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.subjectId,
                            referencedTable: $$NotebooksTableReferences
                                ._subjectIdTable(db),
                            referencedColumn: $$NotebooksTableReferences
                                ._subjectIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (pdfFileId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.pdfFileId,
                            referencedTable: $$NotebooksTableReferences
                                ._pdfFileIdTable(db),
                            referencedColumn: $$NotebooksTableReferences
                                ._pdfFileIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (pagesRefs)
                        await $_getPrefetchedDataByColumns<
                          Notebook,
                          $NotebooksTable,
                          NotebookPage,
                          $PagesTable
                        >(
                          currentTable: table,
                          referencedTable: $$NotebooksTableReferences
                              ._pagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NotebooksTableReferences(
                                db,
                                table,
                                p0,
                              ).pagesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'notebook_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$NotebooksTableProcessedTableManager =
    ProcessedTableManager<
      _$MarginDatabase,
      $NotebooksTable,
      Notebook,
      $$NotebooksTableFilterComposer,
      $$NotebooksTableOrderingComposer,
      $$NotebooksTableAnnotationComposer,
      $$NotebooksTableCreateCompanionBuilder,
      $$NotebooksTableUpdateCompanionBuilder,
      (Notebook, $$NotebooksTableReferences),
      Notebook,
      PrefetchHooks Function({bool subjectId, bool pdfFileId, bool pagesRefs})
    >;
typedef $$PagesTableCreateCompanionBuilder = PagesCompanion Function({
  required String id,
  required String notebookId,
  required double width,
  required double height,
  required PageBackground background,
  Value<int> rowid,
});
typedef $$PagesTableUpdateCompanionBuilder = PagesCompanion Function({
  Value<String> id,
  Value<String> notebookId,
  Value<double> width,
  Value<double> height,
  Value<PageBackground> background,
  Value<int> rowid,
});

final class $$PagesTableReferences
    extends BaseReferences<_$MarginDatabase, $PagesTable, NotebookPage> {
  $$PagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $NotebooksTable _notebookIdTable(_$MarginDatabase db) =>
      db.notebooks.createAlias('pages__notebook_id__notebooks__id');

  $$NotebooksTableProcessedTableManager get notebookId {
    final $_column = $_itemColumn<String>('notebook_id')!;

    final manager = $$NotebooksTableTableManager(
      $_db,
      $_db.notebooks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_notebookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$StrokesTable, List<Stroke>> _strokesRefsTable(
    _$MarginDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.strokes,
    aliasName: 'pages__id__strokes__page_id',
  );

  $$StrokesTableProcessedTableManager get strokesRefs {
    final manager = $$StrokesTableTableManager(
      $_db,
      $_db.strokes,
    ).filter((f) => f.pageId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_strokesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TapesTable, List<Tape>> _tapesRefsTable(
    _$MarginDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tapes,
    aliasName: 'pages__id__tapes__page_id',
  );

  $$TapesTableProcessedTableManager get tapesRefs {
    final manager = $$TapesTableTableManager(
      $_db,
      $_db.tapes,
    ).filter((f) => f.pageId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tapesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PagesTableFilterComposer
    extends Composer<_$MarginDatabase, $PagesTable> {
  $$PagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PageBackground, PageBackground, String>
  get background => $composableBuilder(
    column: $table.background,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$NotebooksTableFilterComposer get notebookId {
    final $$NotebooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.notebookId,
      referencedTable: $db.notebooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotebooksTableFilterComposer(
            $db: $db,
            $table: $db.notebooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> strokesRefs(
    Expression<bool> Function($$StrokesTableFilterComposer f) f,
  ) {
    final $$StrokesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.strokes,
      getReferencedColumn: (t) => t.pageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrokesTableFilterComposer(
            $db: $db,
            $table: $db.strokes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tapesRefs(
    Expression<bool> Function($$TapesTableFilterComposer f) f,
  ) {
    final $$TapesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tapes,
      getReferencedColumn: (t) => t.pageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TapesTableFilterComposer(
            $db: $db,
            $table: $db.tapes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PagesTableOrderingComposer
    extends Composer<_$MarginDatabase, $PagesTable> {
  $$PagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get background => $composableBuilder(
    column: $table.background,
    builder: (column) => ColumnOrderings(column),
  );

  $$NotebooksTableOrderingComposer get notebookId {
    final $$NotebooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.notebookId,
      referencedTable: $db.notebooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotebooksTableOrderingComposer(
            $db: $db,
            $table: $db.notebooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PagesTableAnnotationComposer
    extends Composer<_$MarginDatabase, $PagesTable> {
  $$PagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<double> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PageBackground, String> get background =>
      $composableBuilder(
        column: $table.background,
        builder: (column) => column,
      );

  $$NotebooksTableAnnotationComposer get notebookId {
    final $$NotebooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.notebookId,
      referencedTable: $db.notebooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotebooksTableAnnotationComposer(
            $db: $db,
            $table: $db.notebooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> strokesRefs<T extends Object>(
    Expression<T> Function($$StrokesTableAnnotationComposer a) f,
  ) {
    final $$StrokesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.strokes,
      getReferencedColumn: (t) => t.pageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrokesTableAnnotationComposer(
            $db: $db,
            $table: $db.strokes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tapesRefs<T extends Object>(
    Expression<T> Function($$TapesTableAnnotationComposer a) f,
  ) {
    final $$TapesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tapes,
      getReferencedColumn: (t) => t.pageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TapesTableAnnotationComposer(
            $db: $db,
            $table: $db.tapes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PagesTableTableManager
    extends
        RootTableManager<
          _$MarginDatabase,
          $PagesTable,
          NotebookPage,
          $$PagesTableFilterComposer,
          $$PagesTableOrderingComposer,
          $$PagesTableAnnotationComposer,
          $$PagesTableCreateCompanionBuilder,
          $$PagesTableUpdateCompanionBuilder,
          (NotebookPage, $$PagesTableReferences),
          NotebookPage,
          PrefetchHooks Function({
            bool notebookId,
            bool strokesRefs,
            bool tapesRefs,
          })
        > {
  $$PagesTableTableManager(_$MarginDatabase db, $PagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> notebookId = const Value.absent(),
                Value<double> width = const Value.absent(),
                Value<double> height = const Value.absent(),
                Value<PageBackground> background = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PagesCompanion(
                id: id,
                notebookId: notebookId,
                width: width,
                height: height,
                background: background,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String notebookId,
                required double width,
                required double height,
                required PageBackground background,
                Value<int> rowid = const Value.absent(),
              }) => PagesCompanion.insert(
                id: id,
                notebookId: notebookId,
                width: width,
                height: height,
                background: background,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PagesTable, NotebookPage>(table),
                  $$PagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({notebookId = false, strokesRefs = false, tapesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (strokesRefs) db.strokes,
                    if (tapesRefs) db.tapes,
                  ],
                  addJoins:
                      <
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
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (notebookId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.notebookId,
                            referencedTable: $$PagesTableReferences
                                ._notebookIdTable(db),
                            referencedColumn: $$PagesTableReferences
                                ._notebookIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (strokesRefs)
                        await $_getPrefetchedDataByColumns<
                          NotebookPage,
                          $PagesTable,
                          Stroke,
                          $StrokesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PagesTableReferences
                              ._strokesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PagesTableReferences(db, table, p0).strokesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'page_id',
                          typedResults: items,
                        ),
                      if (tapesRefs)
                        await $_getPrefetchedDataByColumns<
                          NotebookPage,
                          $PagesTable,
                          Tape,
                          $TapesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PagesTableReferences
                              ._tapesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PagesTableReferences(db, table, p0).tapesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'page_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PagesTableProcessedTableManager =
    ProcessedTableManager<
      _$MarginDatabase,
      $PagesTable,
      NotebookPage,
      $$PagesTableFilterComposer,
      $$PagesTableOrderingComposer,
      $$PagesTableAnnotationComposer,
      $$PagesTableCreateCompanionBuilder,
      $$PagesTableUpdateCompanionBuilder,
      (NotebookPage, $$PagesTableReferences),
      NotebookPage,
      PrefetchHooks Function({
        bool notebookId,
        bool strokesRefs,
        bool tapesRefs,
      })
    >;
typedef $$StrokesTableCreateCompanionBuilder = StrokesCompanion Function({
  required String id,
  required String pageId,
  required StrokeTool tool,
  required int color,
  required double size,
  required Float32List points,
  required double minX,
  required double minY,
  required double maxX,
  required double maxY,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$StrokesTableUpdateCompanionBuilder = StrokesCompanion Function({
  Value<String> id,
  Value<String> pageId,
  Value<StrokeTool> tool,
  Value<int> color,
  Value<double> size,
  Value<Float32List> points,
  Value<double> minX,
  Value<double> minY,
  Value<double> maxX,
  Value<double> maxY,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$StrokesTableReferences
    extends BaseReferences<_$MarginDatabase, $StrokesTable, Stroke> {
  $$StrokesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PagesTable _pageIdTable(_$MarginDatabase db) =>
      db.pages.createAlias('strokes__page_id__pages__id');

  $$PagesTableProcessedTableManager get pageId {
    final $_column = $_itemColumn<String>('page_id')!;

    final manager = $$PagesTableTableManager(
      $_db,
      $_db.pages,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StrokesTableFilterComposer
    extends Composer<_$MarginDatabase, $StrokesTable> {
  $$StrokesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<StrokeTool, StrokeTool, String> get tool =>
      $composableBuilder(
        column: $table.tool,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Float32List, Float32List, Uint8List>
  get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get minX => $composableBuilder(
    column: $table.minX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minY => $composableBuilder(
    column: $table.minY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxX => $composableBuilder(
    column: $table.maxX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxY => $composableBuilder(
    column: $table.maxY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$PagesTableFilterComposer get pageId {
    final $$PagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pageId,
      referencedTable: $db.pages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagesTableFilterComposer(
            $db: $db,
            $table: $db.pages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StrokesTableOrderingComposer
    extends Composer<_$MarginDatabase, $StrokesTable> {
  $$StrokesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tool => $composableBuilder(
    column: $table.tool,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minX => $composableBuilder(
    column: $table.minX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minY => $composableBuilder(
    column: $table.minY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxX => $composableBuilder(
    column: $table.maxX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxY => $composableBuilder(
    column: $table.maxY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PagesTableOrderingComposer get pageId {
    final $$PagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pageId,
      referencedTable: $db.pages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagesTableOrderingComposer(
            $db: $db,
            $table: $db.pages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StrokesTableAnnotationComposer
    extends Composer<_$MarginDatabase, $StrokesTable> {
  $$StrokesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<StrokeTool, String> get tool =>
      $composableBuilder(column: $table.tool, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<double> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Float32List, Uint8List> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);

  GeneratedColumn<double> get minX =>
      $composableBuilder(column: $table.minX, builder: (column) => column);

  GeneratedColumn<double> get minY =>
      $composableBuilder(column: $table.minY, builder: (column) => column);

  GeneratedColumn<double> get maxX =>
      $composableBuilder(column: $table.maxX, builder: (column) => column);

  GeneratedColumn<double> get maxY =>
      $composableBuilder(column: $table.maxY, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PagesTableAnnotationComposer get pageId {
    final $$PagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pageId,
      referencedTable: $db.pages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagesTableAnnotationComposer(
            $db: $db,
            $table: $db.pages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StrokesTableTableManager
    extends
        RootTableManager<
          _$MarginDatabase,
          $StrokesTable,
          Stroke,
          $$StrokesTableFilterComposer,
          $$StrokesTableOrderingComposer,
          $$StrokesTableAnnotationComposer,
          $$StrokesTableCreateCompanionBuilder,
          $$StrokesTableUpdateCompanionBuilder,
          (Stroke, $$StrokesTableReferences),
          Stroke,
          PrefetchHooks Function({bool pageId})
        > {
  $$StrokesTableTableManager(_$MarginDatabase db, $StrokesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StrokesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StrokesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StrokesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> pageId = const Value.absent(),
                Value<StrokeTool> tool = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<double> size = const Value.absent(),
                Value<Float32List> points = const Value.absent(),
                Value<double> minX = const Value.absent(),
                Value<double> minY = const Value.absent(),
                Value<double> maxX = const Value.absent(),
                Value<double> maxY = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StrokesCompanion(
                id: id,
                pageId: pageId,
                tool: tool,
                color: color,
                size: size,
                points: points,
                minX: minX,
                minY: minY,
                maxX: maxX,
                maxY: maxY,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String pageId,
                required StrokeTool tool,
                required int color,
                required double size,
                required Float32List points,
                required double minX,
                required double minY,
                required double maxX,
                required double maxY,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => StrokesCompanion.insert(
                id: id,
                pageId: pageId,
                tool: tool,
                color: color,
                size: size,
                points: points,
                minX: minX,
                minY: minY,
                maxX: maxX,
                maxY: maxY,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StrokesTable, Stroke>(table),
                  $$StrokesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pageId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pageId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.pageId,
                        referencedTable: $$StrokesTableReferences._pageIdTable(
                          db,
                        ),
                        referencedColumn: $$StrokesTableReferences
                            ._pageIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$StrokesTableProcessedTableManager =
    ProcessedTableManager<
      _$MarginDatabase,
      $StrokesTable,
      Stroke,
      $$StrokesTableFilterComposer,
      $$StrokesTableOrderingComposer,
      $$StrokesTableAnnotationComposer,
      $$StrokesTableCreateCompanionBuilder,
      $$StrokesTableUpdateCompanionBuilder,
      (Stroke, $$StrokesTableReferences),
      Stroke,
      PrefetchHooks Function({bool pageId})
    >;
typedef $$TapesTableCreateCompanionBuilder = TapesCompanion Function({
  required String id,
  required String pageId,
  required Float32List points,
  required double width,
  Value<String> style,
  Value<bool> hidden,
  required double minX,
  required double minY,
  required double maxX,
  required double maxY,
  Value<StudyResult?> studyLastResult,
  Value<DateTime?> studyDueAt,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$TapesTableUpdateCompanionBuilder = TapesCompanion Function({
  Value<String> id,
  Value<String> pageId,
  Value<Float32List> points,
  Value<double> width,
  Value<String> style,
  Value<bool> hidden,
  Value<double> minX,
  Value<double> minY,
  Value<double> maxX,
  Value<double> maxY,
  Value<StudyResult?> studyLastResult,
  Value<DateTime?> studyDueAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$TapesTableReferences
    extends BaseReferences<_$MarginDatabase, $TapesTable, Tape> {
  $$TapesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PagesTable _pageIdTable(_$MarginDatabase db) =>
      db.pages.createAlias('tapes__page_id__pages__id');

  $$PagesTableProcessedTableManager get pageId {
    final $_column = $_itemColumn<String>('page_id')!;

    final manager = $$PagesTableTableManager(
      $_db,
      $_db.pages,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TapesTableFilterComposer
    extends Composer<_$MarginDatabase, $TapesTable> {
  $$TapesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Float32List, Float32List, Uint8List>
  get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get style => $composableBuilder(
    column: $table.style,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minX => $composableBuilder(
    column: $table.minX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minY => $composableBuilder(
    column: $table.minY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxX => $composableBuilder(
    column: $table.maxX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxY => $composableBuilder(
    column: $table.maxY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<StudyResult?, StudyResult, String>
  get studyLastResult => $composableBuilder(
    column: $table.studyLastResult,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get studyDueAt =>
      $composableBuilder(
        column: $table.studyDueAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$PagesTableFilterComposer get pageId {
    final $$PagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pageId,
      referencedTable: $db.pages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagesTableFilterComposer(
            $db: $db,
            $table: $db.pages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TapesTableOrderingComposer
    extends Composer<_$MarginDatabase, $TapesTable> {
  $$TapesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get style => $composableBuilder(
    column: $table.style,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minX => $composableBuilder(
    column: $table.minX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minY => $composableBuilder(
    column: $table.minY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxX => $composableBuilder(
    column: $table.maxX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxY => $composableBuilder(
    column: $table.maxY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studyLastResult => $composableBuilder(
    column: $table.studyLastResult,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get studyDueAt => $composableBuilder(
    column: $table.studyDueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PagesTableOrderingComposer get pageId {
    final $$PagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pageId,
      referencedTable: $db.pages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagesTableOrderingComposer(
            $db: $db,
            $table: $db.pages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TapesTableAnnotationComposer
    extends Composer<_$MarginDatabase, $TapesTable> {
  $$TapesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Float32List, Uint8List> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);

  GeneratedColumn<double> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<String> get style =>
      $composableBuilder(column: $table.style, builder: (column) => column);

  GeneratedColumn<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => column);

  GeneratedColumn<double> get minX =>
      $composableBuilder(column: $table.minX, builder: (column) => column);

  GeneratedColumn<double> get minY =>
      $composableBuilder(column: $table.minY, builder: (column) => column);

  GeneratedColumn<double> get maxX =>
      $composableBuilder(column: $table.maxX, builder: (column) => column);

  GeneratedColumn<double> get maxY =>
      $composableBuilder(column: $table.maxY, builder: (column) => column);

  GeneratedColumnWithTypeConverter<StudyResult?, String> get studyLastResult =>
      $composableBuilder(
        column: $table.studyLastResult,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, int> get studyDueAt =>
      $composableBuilder(
        column: $table.studyDueAt,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PagesTableAnnotationComposer get pageId {
    final $$PagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pageId,
      referencedTable: $db.pages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagesTableAnnotationComposer(
            $db: $db,
            $table: $db.pages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TapesTableTableManager
    extends
        RootTableManager<
          _$MarginDatabase,
          $TapesTable,
          Tape,
          $$TapesTableFilterComposer,
          $$TapesTableOrderingComposer,
          $$TapesTableAnnotationComposer,
          $$TapesTableCreateCompanionBuilder,
          $$TapesTableUpdateCompanionBuilder,
          (Tape, $$TapesTableReferences),
          Tape,
          PrefetchHooks Function({bool pageId})
        > {
  $$TapesTableTableManager(_$MarginDatabase db, $TapesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TapesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TapesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TapesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> pageId = const Value.absent(),
                Value<Float32List> points = const Value.absent(),
                Value<double> width = const Value.absent(),
                Value<String> style = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<double> minX = const Value.absent(),
                Value<double> minY = const Value.absent(),
                Value<double> maxX = const Value.absent(),
                Value<double> maxY = const Value.absent(),
                Value<StudyResult?> studyLastResult = const Value.absent(),
                Value<DateTime?> studyDueAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TapesCompanion(
                id: id,
                pageId: pageId,
                points: points,
                width: width,
                style: style,
                hidden: hidden,
                minX: minX,
                minY: minY,
                maxX: maxX,
                maxY: maxY,
                studyLastResult: studyLastResult,
                studyDueAt: studyDueAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String pageId,
                required Float32List points,
                required double width,
                Value<String> style = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                required double minX,
                required double minY,
                required double maxX,
                required double maxY,
                Value<StudyResult?> studyLastResult = const Value.absent(),
                Value<DateTime?> studyDueAt = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TapesCompanion.insert(
                id: id,
                pageId: pageId,
                points: points,
                width: width,
                style: style,
                hidden: hidden,
                minX: minX,
                minY: minY,
                maxX: maxX,
                maxY: maxY,
                studyLastResult: studyLastResult,
                studyDueAt: studyDueAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TapesTable, Tape>(table),
                  $$TapesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pageId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pageId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.pageId,
                        referencedTable: $$TapesTableReferences._pageIdTable(
                          db,
                        ),
                        referencedColumn: $$TapesTableReferences
                            ._pageIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TapesTableProcessedTableManager =
    ProcessedTableManager<
      _$MarginDatabase,
      $TapesTable,
      Tape,
      $$TapesTableFilterComposer,
      $$TapesTableOrderingComposer,
      $$TapesTableAnnotationComposer,
      $$TapesTableCreateCompanionBuilder,
      $$TapesTableUpdateCompanionBuilder,
      (Tape, $$TapesTableReferences),
      Tape,
      PrefetchHooks Function({bool pageId})
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$MarginDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$MarginDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$MarginDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$MarginDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$MarginDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$MarginDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$MarginDatabase, $SettingsTable, Setting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$MarginDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$MarginDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $MarginDatabaseManager {
  final _$MarginDatabase _db;
  $MarginDatabaseManager(this._db);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db, _db.subjects);
  $$PdfFilesTableTableManager get pdfFiles =>
      $$PdfFilesTableTableManager(_db, _db.pdfFiles);
  $$NotebooksTableTableManager get notebooks =>
      $$NotebooksTableTableManager(_db, _db.notebooks);
  $$PagesTableTableManager get pages =>
      $$PagesTableTableManager(_db, _db.pages);
  $$StrokesTableTableManager get strokes =>
      $$StrokesTableTableManager(_db, _db.strokes);
  $$TapesTableTableManager get tapes =>
      $$TapesTableTableManager(_db, _db.tapes);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
