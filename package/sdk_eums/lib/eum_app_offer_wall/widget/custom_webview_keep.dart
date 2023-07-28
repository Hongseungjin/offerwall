import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:sdk_eums/gen/assets.gen.dart';

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

class _CustomWebViewKeepState extends State<CustomWebViewKeep> {
  ScrollController _scrollController = ScrollController();

  Timer? _timer;
  int _startTime = 15;
  Timer? timer5s;
  bool showButton = false;
  bool isRunning = true;

  void startTimeDown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
          // CachedNetworkImage(
          //     width: MediaQuery.of(context).size.width - 64,
          //     fit: BoxFit.cover,
          //     imageUrl: widget.uriImage,
          //     placeholder: (context, url) =>
          //         const Center(child: CircularProgressIndicator()),
          //     errorWidget: (context, url, error) {
          //       return Image.asset(Assets.logo.path,
          //           package: "sdk_eums", height: 16);
          //     }),
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
                                ? AppColor.grey.withOpacity(0.5)
                                : AppColor.red),
                        child: Text(
                          '포인트 적립하기',
                          style: AppStyle.medium.copyWith(
                              color:
                                  !showButton ? AppColor.grey : AppColor.white),
                        ),
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: AppColor.grey.withOpacity(0.5),
                            shape: BoxShape.circle),
                        child: Text(
                          _startTime.toString(),
                          style: AppStyle.medium.copyWith(fontSize: 16),
                        ))
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
