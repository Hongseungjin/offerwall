import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:eums/eum_app_offer_wall/utils/hex_color.dart';
import 'package:eums/eum_app_offer_wall/widget/custom_animation_click.dart';
import 'package:eums/gen/assets.gen.dart';

class InstructAppScreen extends StatefulWidget {
  const InstructAppScreen({Key? key}) : super(key: key);

  @override
  State<InstructAppScreen> createState() => _InstructAppScreenState();
}

class _InstructAppScreenState extends State<InstructAppScreen> {
  final _currentPageNotifier = ValueNotifier<int>(0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: HexColor('#f4f4f4'),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).padding.top,
            ),
            Row(
              children: [
                const Spacer(),
                WidgetAnimationClick(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.close_rounded),
                    ))
              ],
            ),
            Expanded(
              child: CarouselSlider(
                options: CarouselOptions(
                  autoPlay: true,
                  height: MediaQuery.of(context).size.height,
                  aspectRatio: 1.4,
                  scrollDirection: Axis.horizontal,
                  enlargeCenterPage: true,
                  viewportFraction: 1,
                  onPageChanged: (int index, CarouselPageChangedReason c) {
                    setState(() {});
                    _currentPageNotifier.value = index;
                  },
                ),
                items: imageList.map((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          i,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                          package: "eums",
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List imageList = [Assets.icons.banner1.path, Assets.icons.banner2.path, Assets.icons.banner3.path, Assets.icons.banner4.path];
