import 'dart:ui';

import 'package:flutter/widgets.dart';

/// {@template custom_rect_tween}
/// Linear RectTween with a [Curves.easeOut] curve.
///
/// Less dramatic that the regular [RectTween] used in [Hero] animations.
/// {@endtemplate}
class CustomRectTween extends RectTween {
  /// {@macro custom_rect_tween}
  CustomRectTween({
    required Rect begin,
    required Rect end,
  }) : super(begin: begin, end: end);

  @override
  Rect lerp(double t) {
    final elasticCurveValue = Curves.easeOut.transform(t);
 

    return Rect.fromLTRB(
      lerpDouble(begin?.left.toDouble(), end?.left.toDouble(), elasticCurveValue)!.toDouble(),
      lerpDouble(begin?.top.toDouble(), end?.top.toDouble(), elasticCurveValue)!.toDouble(),
      lerpDouble(begin?.right.toDouble(), end?.right.toDouble(), elasticCurveValue)!.toDouble(),
      lerpDouble(begin?.bottom.toDouble(), end?.bottom.toDouble(), elasticCurveValue)!.toDouble(),
    );
  }
}
