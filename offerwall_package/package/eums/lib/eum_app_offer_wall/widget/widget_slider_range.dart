import 'package:another_xlider/another_xlider.dart';
import 'package:another_xlider/enums/tooltip_direction_enum.dart';
import 'package:another_xlider/models/handler.dart';
import 'package:another_xlider/models/tooltip/tooltip.dart';
import 'package:another_xlider/models/trackbar.dart';
import 'package:eums/eum_app_offer_wall/widget/widget_animation_click.dart';
import 'package:eums/gen/assets.gen.dart';
import 'package:eums/gen/style_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'dart:math' as math;

class WidgetSliderRange extends StatefulWidget {
  const WidgetSliderRange({
    super.key,
    required this.onChange,
    required this.valueDefault,
    required this.maxValue,
    required this.minValue,
  });
  final Function(double value) onChange;
  final double valueDefault;
  final double maxValue;
  final double minValue;

  @override
  State<WidgetSliderRange> createState() => _WidgetSliderRangeState();
}

class _WidgetSliderRangeState extends State<WidgetSliderRange> {
  late double valueDefault;

  // GlobalKey globalKey = GlobalKey();
  // Size? _size;

  @override
  void initState() {
    super.initState();
    valueDefault = widget.valueDefault;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // _getWidgetInfo();
    });
  }

  // void _getWidgetInfo() {
  //   final RenderBox renderBox = globalKey.currentContext?.findRenderObject() as RenderBox;

  //   _size = renderBox.size; // or _widgetKey.currentContext?.size
  //   debugPrint('Size: ${_size?.width}, ${_size?.height}');
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildButton(
          icon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Assets.icons.remove.svg(width: 24, height: 24),
          ),
          onTap: () {
            if (valueDefault > widget.minValue) {
              valueDefault -= 1;
              HapticFeedback.heavyImpact();
              widget.onChange.call(valueDefault);
              setState(() {});
            }
          },
        ),
        Expanded(
          // key: globalKey,
          // child: SfSlider(
          //   min: widget.minValue,
          //   max: widget.maxValue,
          //   value: valueDefault,
          //   interval: 1,
          //   activeColor: const Color(0xfffdd000),
          //   inactiveColor: Colors.grey.shade300,
          //   stepSize: 1,
          //   showTicks: true,
          //   onChanged: (dynamic value) {
          //     if (valueDefault != value) {
          //       HapticFeedback.heavyImpact();
          //     }
          //     valueDefault = value;
          //     widget.onChange.call(valueDefault);
          //     setState(() {});
          //   },
          // ),
          child: Stack(children: [
            FlutterSlider(
              values: [valueDefault],
              max: widget.maxValue,
              min: widget.minValue,
              handlerHeight: 20,
              handlerWidth: 20,
              trackBar: FlutterSliderTrackBar(
                inactiveTrackBarHeight: 10,
                activeTrackBarHeight: 10,
                inactiveTrackBar: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.grey.shade300,
                ),
                activeTrackBar: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                        begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xfffdd000), Color(0xfffdd000)])),
              ),

              // hatchMark: _size != null
              //     ? FlutterSliderHatchMark(
              //         density: 1, // means 50 lines, from 0 to 100 percent
              //         labels: [
              //           FlutterSliderHatchMarkLabel(
              //               percent: 2,
              //               label: Container(
              //                 width: 5,
              //                 height: 5,
              //                 decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.white),
              //               )),
              //           FlutterSliderHatchMarkLabel(
              //               percent: (_size!.width / 14),
              //               label: Container(
              //                 width: 5,
              //                 height: 5,
              //                 decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.white),
              //               )),
              //           FlutterSliderHatchMarkLabel(
              //               percent: (_size!.width / 14) * 2,
              //               label: Container(
              //                 width: 5,
              //                 height: 5,
              //                 decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.white),
              //               )),
              //           FlutterSliderHatchMarkLabel(
              //               percent: (_size!.width / 14) * 3,
              //               label: Container(
              //                 width: 5,
              //                 height: 5,
              //                 decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.white),
              //               )),
              //           FlutterSliderHatchMarkLabel(
              //               percent: (_size!.width / 14) * 4 - 1,
              //               label: Container(
              //                 width: 5,
              //                 height: 5,
              //                 decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.white),
              //               )),
              //         ],
              //       )
              //     : null,
              handler: FlutterSliderHandler(
                  foregroundDecoration: const BoxDecoration(color: Colors.transparent),
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: toolTripRadius()),
              tooltip: FlutterSliderTooltip(
                disabled: true,
                custom: (value) {
                  int textShow = (value as double).toInt();
                  return CustomPaint(
                    painter: CustomIconToolTripPaint(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
                      child: Text(
                        " $textShow ",
                        style: StyleFont.bold(14).copyWith(),
                      ),
                    ),
                  );
                },
                alwaysShowTooltip: true,
                direction: FlutterSliderTooltipDirection.top,
              ),
              onDragging: (handlerIndex, lowerValue, upperValue) {
                if (valueDefault != lowerValue) {
                  HapticFeedback.heavyImpact();
                }
                valueDefault = lowerValue;
                widget.onChange.call(valueDefault);

                setState(() {});
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                    widget.maxValue.toInt() + 1,
                    (index) => Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100), color: valueDefault != index ? Colors.white : Colors.transparent),
                        )),
              ),
            )
          ]),
        ),
        _buildButton(
          icon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Assets.icons.add.svg(width: 24),
          ),
          onTap: () {
            if (valueDefault < widget.maxValue) {
              valueDefault += 1;
              HapticFeedback.heavyImpact();
              widget.onChange.call(valueDefault);
              setState(() {});
            }
          },
        ),
      ],
    );
  }

  Widget _buildButton({required Widget icon, required Function() onTap}) {
    return WidgetAnimationClick(onTap: onTap, child: icon);
  }

  Widget toolTripRadius() {
    return Container(
      // margin: const EdgeInsets.all(5),
      height: 20,
      width: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
    );
  }
}

class CustomIconToolTripPaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width / 2 + 5, size.height);
    path.lineTo(size.width / 2, size.height + 6);
    path.lineTo(size.width / 2 - 5, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
