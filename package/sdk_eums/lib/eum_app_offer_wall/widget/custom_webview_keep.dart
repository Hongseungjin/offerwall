import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sdk_eums/common/routing.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/hex_color.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/custom_circular.dart';
import 'package:sdk_eums/gen/assets.gen.dart';

import '../screen/report_module/report_page.dart';

class CustomWebViewKeep extends StatefulWidget {
  final dynamic urlLink;
  final dynamic uriImage;
  final Widget? bookmark;
  final Function()? mission;
  const CustomWebViewKeep(
      {Key? key, this.urlLink, this.bookmark, this.mission, this.uriImage})
      : super(key: key);

  @override
  State<CustomWebViewKeep> createState() => _CustomWebViewKeepState();
}

class _CustomWebViewKeepState extends State<CustomWebViewKeep>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  ScrollController _scrollController = ScrollController();

  Timer? _timer;
  int _startTime = 15;
  Timer? timer5s;
  bool showButton = false;
  bool isRunning = true;
  late LinearTimerController timerController = LinearTimerController(this);

  void startTimeDown() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timerController.start();
      if (_startTime == 0) {
        _timer?.cancel();
      } else {
        setState(() {
          _startTime--;
        });
        if (_startTime == 0) {
          setState(() {
            showButton = true;
            _timer?.cancel();
          });
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimeDown();
    start5s();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    timer5s?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  start5s() {
    timer5s?.cancel();
    timer5s = Timer.periodic(const Duration(seconds: 5), (_) {
      _timer?.cancel();
      isRunning = false;
      timerController.stop();
      setState(() {});
    });
  }

  _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse ||
        _scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
      if (!isRunning) {
        isRunning = true;
        startTimeDown();
        // controller?.forward(from: _startTime.toDouble());
      }
      start5s();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
            color: AppColor.black,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Routing().navigate(context, ReportPage());
            },
            child: Icon(
              Icons.report,
              color: Colors.amber,
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          NotificationListener(
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  CachedNetworkImage(
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                      imageUrl: widget.urlLink,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) {
                        return Image.asset(Assets.logo.path,
                            package: "sdk_eums", height: 16);
                      }),
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 70,
                  )
                ],
              ),
            ),
          ),
          Positioned(
              bottom: 0,
              child: Container(
                padding: EdgeInsets.only(
                    top: 5, bottom: MediaQuery.of(context).padding.bottom + 20),
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    widget.bookmark ?? SizedBox(),
                    GestureDetector(
                      onTap: !showButton ? null : widget.mission,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: !showButton
                                ? HexColor('#cccccc')
                                : AppColor.red),
                        child: Text(
                          '포인트 적립하기',
                          style: AppStyle.medium.copyWith(
                              color:
                                  !showButton ? AppColor.grey : AppColor.white),
                        ),
                      ),
                    ),
                    Stack(
                      children: [
                        SizedBox(
                          height: 40,
                          width: 40,
                          child: LinearTimer(
                            color: AppColor.yellow,
                            backgroundColor:
                                HexColor('#888888').withOpacity(0.3),
                            controller: timerController,
                            duration: Duration(seconds: _startTime),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          left: 0,
                          top: 10,
                          child: Image.asset(
                            Assets.coingif.path,
                            package: "sdk_eums",
                            height: 25,
                          ),
                        )
                      ],
                    ),
                    // Container(
                    //     padding: const EdgeInsets.all(10),
                    //     decoration: BoxDecoration(
                    //         color: AppColor.grey.withOpacity(0.5),
                    //         shape: BoxShape.circle),
                    //     child: Text(
                    //       _startTime.toString(),
                    //       style: AppStyle.medium.copyWith(fontSize: 16),
                    //     ))
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
