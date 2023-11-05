import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:eums/gen/assets.gen.dart';

class RewardGuideScreen extends StatefulWidget {
  const RewardGuideScreen({Key? key}) : super(key: key);

  @override
  State<RewardGuideScreen> createState() => _RewardGuideScreenState();
}

class _RewardGuideScreenState extends State<RewardGuideScreen> {
  final _currentPageNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CarouselSlider(
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
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 16,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.close),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            right: 0,
            left: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imageList.map(
                (image) {
                  int index = imageList.indexOf(image);
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPageNotifier.value == index ? const Color.fromRGBO(0, 0, 0, 0.9) : const Color.fromRGBO(0, 0, 0, 0.4)),
                  );
                },
              ).toList(), // this was the part the I had to add
            ),
          ),
        ],
      ),
    );
  }
}

List imageList = [Assets.icons.rewardGuide.path, Assets.icons.rewardGuideMome.path];
