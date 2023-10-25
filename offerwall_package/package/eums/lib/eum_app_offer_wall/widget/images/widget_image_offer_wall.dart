import 'package:cached_network_image/cached_network_image.dart';
import 'package:eums/gen/assets.gen.dart';
import 'package:flutter/material.dart';

class WidgetImageOfferWall extends StatefulWidget {
  const WidgetImageOfferWall({super.key, required this.urlLink, required this.onDone, required this.scrollController});
  final String urlLink;
  final Function() onDone;
  final ScrollController scrollController;

  @override
  State<WidgetImageOfferWall> createState() => _WidgetImageOfferWallState();
}

class _WidgetImageOfferWallState extends State<WidgetImageOfferWall> {
  final events = [];
  bool canScroll = true;

  @override
  Widget build(BuildContext context) {
    final imageCache = InteractiveViewer(
      minScale: 0.1,
      maxScale: 2.6,
      child: CachedNetworkImage(
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
          imageUrl: widget.urlLink,
          placeholder: (context, url) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(
                    child: CircularProgressIndicator(
                  color: Color(0xfffcc900),
                )),
              ),
          imageBuilder: (context, imageProvider) {
            widget.onDone.call();
            return Image(image: imageProvider);
          },
          errorWidget: (context, url, error) {
            return Image.asset(Assets.logo.path, package: "eums", height: 100);
          }),
    );

    return SingleChildScrollView(
      controller: widget.scrollController,
      scrollDirection: Axis.vertical,
      physics: canScroll ? const ScrollPhysics() : const NeverScrollableScrollPhysics(),
      child: Listener(
          onPointerDown: (event) {
            events.add(event.pointer);
            print("new event ${event.pointer}");
          },
          onPointerUp: (event) {
            events.clear();
            print("events cleared");
            setState(() {
              canScroll = true;
            });
          },
          onPointerMove: (event) {
            if (events.length == 2) {
              setState(() {
                canScroll = false;
              });
            }
          },
          child: imageCache),
    );
  }
}
