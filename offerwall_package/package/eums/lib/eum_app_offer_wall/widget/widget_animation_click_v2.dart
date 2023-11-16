import 'dart:async';

import 'package:flutter/material.dart';

class WidgetAnimationClickV2 extends StatefulWidget {
  const WidgetAnimationClickV2({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
    this.borderRadius,
    this.radius,
    this.border,
  });
  final Widget child;
  final Function()? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final BorderRadius? borderRadius;
  final double? radius;
  final BoxBorder? border;

  @override
  State<WidgetAnimationClickV2> createState() => _WidgetAnimationClickV2State();
}

class _WidgetAnimationClickV2State extends State<WidgetAnimationClickV2> with SingleTickerProviderStateMixin {
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(100),
      child: Material(
        color: Colors.white,
        child: InkWell(
          splashColor: Colors.grey.withOpacity(.7),
          borderRadius: widget.borderRadius ?? BorderRadius.circular(100),
          onTap: () {
            timer?.cancel();
            timer = Timer(const Duration(milliseconds: 600), () {
              widget.onTap?.call();
            });
          },
          child: Ink(
              padding: widget.padding,
              decoration: widget.border != null || widget.color != null
                  ? BoxDecoration(
                      borderRadius: widget.borderRadius,
                      color: widget.color,
                      border: widget.border,
                    )
                  : null,
              child: widget.child),
        ),
      ),
    );
  }
}
