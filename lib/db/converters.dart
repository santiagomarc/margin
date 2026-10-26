import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart';

import 'page_background.dart';

/// Stores point arrays (x, y, pressure repeated) as raw little-endian bytes.
///
/// Android devices are little-endian, so this is a straight memory copy.
class Float32ListConverter extends TypeConverter<Float32List, Uint8List> {
  const Float32ListConverter();

  @override
  Float32List fromSql(Uint8List fromDb) {
    // Copy first: the blob's offset is not guaranteed to be 4-byte aligned.
    return Uint8List.fromList(fromDb).buffer.asFloat32List();
  }

  @override
  Uint8List toSql(Float32List value) {
    return value.buffer.asUint8List(value.offsetInBytes, value.lengthInBytes);
  }
}

/// Stores a notebook's ordered page ids as a JSON array.
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    return (jsonDecode(fromDb) as List<dynamic>).cast<String>();
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

/// Stores timestamps as milliseconds since epoch (UTC).
///
/// Strokes are drawn in `createdAt` order, so second precision is not enough.
class MillisDateTimeConverter extends TypeConverter<DateTime, int> {
  const MillisDateTimeConverter();

  @override
  DateTime fromSql(int fromDb) {
    return DateTime.fromMillisecondsSinceEpoch(fromDb, isUtc: true);
  }

  @override
  int toSql(DateTime value) => value.millisecondsSinceEpoch;
}

class PageBackgroundConverter extends TypeConverter<PageBackground, String> {
  const PageBackgroundConverter();

  @override
  PageBackground fromSql(String fromDb) {
    return PageBackground.fromJson(jsonDecode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(PageBackground value) => jsonEncode(value.toJson());
}
