import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class WidgetShimmerItemLoading extends StatelessWidget {
  const WidgetShimmerItemLoading({Key? key, required this.child, this.enabled = true}) : super(key: key);
  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (enabled == false) return child;
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade400,
        highlightColor: Colors.grey.shade100,
        child: child);
  }
}
