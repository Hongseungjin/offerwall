import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';

class GradientCircularProgressIndicator extends StatelessWidget {
  const GradientCircularProgressIndicator({
    Key? key,
    required this.radius,
    required this.gradientColorsStart,
    required this.gradientColorsEnd,
    this.strokeWidth = 10.0,
    this.endPoint,
  }) : super(key: key);
  final double radius;
  final Color gradientColorsStart;
  final Color gradientColorsEnd;
  final double strokeWidth;
  final double? endPoint;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.fromRadius(radius),
      painter: GradientCircularProgressPainter(
        gradientColors: [
          gradientColorsEnd,
          gradientColorsStart,
        ],
        strokeWidth: strokeWidth,
        endPoint: endPoint,
      ),
    );
  }
}

class WidgetLoadingAnimated extends StatefulWidget {
  const WidgetLoadingAnimated({
    Key? key,
    this.strokeWidth,
    this.radius,
    this.begin,
    this.end,
    this.gradientColorsStart,
    this.gradientColorsEnd,
    this.endPoint,
    this.size,
  }) : super(key: key);
  final Size? size;
  final double? strokeWidth;
  final double? radius;
  final double? begin;
  final double? end;
  final Color? gradientColorsStart;
  final Color? gradientColorsEnd;
  final double? endPoint;

  @override
  State<WidgetLoadingAnimated> createState() => _WidgetLoadingAnimatedState();
}

class _WidgetLoadingAnimatedState extends State<WidgetLoadingAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(
        begin: widget.begin ?? 0.0,
        end: widget.end ?? 1.0,
      ).animate(_controller),
      child: SizedBox(
        width: widget.size?.width,
        height: widget.size?.height,
        child: GradientCircularProgressIndicator(
          radius: widget.radius ?? 20,
          strokeWidth: widget.strokeWidth ?? 5,
          gradientColorsEnd: widget.gradientColorsEnd ?? AppColor.black,
          gradientColorsStart: widget.gradientColorsStart ?? AppColor.black,
          endPoint: widget.endPoint,
        ),
      ),
    );
  }
}

class GradientCircularProgressPainter extends CustomPainter {
  GradientCircularProgressPainter({
    required this.gradientColors,
    required this.strokeWidth,
    this.endPoint,
  });
  final List<Color> gradientColors;
  final double strokeWidth;
  final double? endPoint;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.height / 2;
    size = Size.fromRadius(radius);
    final offset = strokeWidth / 2;
    final scapToDegree = offset / radius;
    final startAngle = _degreeToRad(270) + scapToDegree;
    final sweepAngle = _degreeToRad(endPoint ?? 360) - (2 * scapToDegree);
    final rect =
        Rect.fromCircle(center: Offset(radius, radius), radius: radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    paint.shader = SweepGradient(
            colors: gradientColors,
            tileMode: TileMode.repeated,
            startAngle: _degreeToRad(270),
            endAngle: _degreeToRad(270 + 360.0))
        .createShader(
            Rect.fromCircle(center: Offset(radius, radius), radius: 0));

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  double _degreeToRad(double degree) => degree * pi / 180;

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
