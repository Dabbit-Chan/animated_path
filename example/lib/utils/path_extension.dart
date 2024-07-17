import 'dart:ui';

extension PathExtension on Path {
  void moveToPoint(Offset offset) {
    moveTo(offset.dx, offset.dy);
  }

  void lineToPoint(Offset offset) {
    lineTo(offset.dx, offset.dy);
  }
}