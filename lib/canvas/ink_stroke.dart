import 'dart:typed_data';
import 'dart:ui';

import '../db/tables.dart';
import 'stroke_geometry.dart';

/// A finished stroke in memory: what the ink layer draws and commands move
/// between the page and the database.
class InkStroke {
  InkStroke({
    required this.id,
    required this.tool,
    required this.color,
    required this.size,
    required this.points,
    required this.bounds,
    required this.createdAt,
  });

  final String id;
  final StrokeTool tool;

  /// ARGB color value.
  final int color;
  final double size;

  /// Settled points (x, y, pressure), in page coordinates.
  final Float32List points;
  final Rect bounds;

  /// Also the draw order.
  final DateTime createdAt;

  Path? _path;

  /// Outline in page coordinates, built once and reused.
  Path get path =>
      _path ??= strokePath(points, size, complete: true, streamline: 0);
}
