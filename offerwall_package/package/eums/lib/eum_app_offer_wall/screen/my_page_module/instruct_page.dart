import 'dart:async';

import 'package:eums/eum_app_offer_wall/widget/widget_animation_click.dart';
import 'package:eums/gen/assets.gen.dart';
import 'package:flutter/material.dart';

class InstructPage extends StatefulWidget {
  const InstructPage({super.key});

  @override
  State<InstructPage> createState() => _InstructPageState();
}

class _InstructPageState extends State<InstructPage> {
  late List<Widget> listInstruct1;
  late List<Widget> listInstruct2;
  late List<Widget> listInstruct3;
  late List<Widget> listInstruct4;

  PageController controller = PageController(initialPage: 0);

  ValueNotifier<int> index = ValueNotifier(0);

  @override
  void initState() {
    listInstruct1 = [
      Assets.images.instructs.instruct11.image(fit: BoxFit.contain),
      Assets.images.instructs.instruct12.image(fit: BoxFit.contain),
    ];
    listInstruct2 = [
      Assets.images.instructs.instruct21.image(fit: BoxFit.contain),
      Assets.images.instructs.instruct22.image(fit: BoxFit.contain),
    ];
    listInstruct3 = [
      Assets.images.instructs.instruct31.image(fit: BoxFit.contain),
      Assets.images.instructs.instruct32.image(fit: BoxFit.contain),
    ];
    listInstruct4 = [
      Assets.images.instructs.instruct41.image(fit: BoxFit.contain),
      Assets.images.instructs.instruct42.image(fit: BoxFit.contain),
    ];
    controller.addListener(() {
      index.value = controller.page!.toInt();
    });

    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (index.value >= 3) {
        controller.jumpToPage(0);
      } else {
        controller.animateToPage(index.value + 1, duration: const Duration(seconds: 1), curve: Curves.easeIn);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          Column(
            children: [
              const SizedBox(
                height: 16,
              ),
              Expanded(
                child: PageView(
                  controller: controller,
                  children: [
                    ViewInstruct(
                      listWidget: listInstruct1,
                    ),
                    ViewInstruct(
                      listWidget: listInstruct2,
                    ),
                    ViewInstruct(
                      listWidget: listInstruct3,
                    ),
                    ViewInstruct(
                      listWidget: listInstruct4,
                    ),
                  ],
                ),
              ),
              ValueListenableBuilder<int>(
                valueListenable: index,
                builder: (context, value, child) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          4,
                          (index) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                width: value == index ? 25 : 10,
                                height: 10,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.orange),
                              )),
                    ),
                  );
                },
              )
            ],
          ),
          Positioned(
              top: 16,
              right: 16,
              child: WidgetAnimationClick(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.close),
                ),
              ))
        ],
      )),
    );
  }
}

class ViewInstruct extends StatelessWidget {
  const ViewInstruct({super.key, required this.listWidget});
  final List<Widget> listWidget;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(flex: 1, child: listWidget.first),
        Expanded(flex: 3, child: listWidget.last),
      ],
    );
  }
}
