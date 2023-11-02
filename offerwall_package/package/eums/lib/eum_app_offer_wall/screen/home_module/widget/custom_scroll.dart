import 'dart:io';

import 'package:flutter/material.dart';

typedef BuildChildrenSliverCustomScrollView = List<Widget> Function(
    BuildContext context, ValueNotifier<bool> showAppBar, ScrollController scrollController);

class WidgetCustomScroll extends StatefulWidget {
  const WidgetCustomScroll({Key? key, required this.buildChildren, required this.onRefresh, required this.scrollController, this.physics})
      : super(key: key);
  final BuildChildrenSliverCustomScrollView buildChildren;
  final Function() onRefresh;
  final ScrollController scrollController;
  final ScrollPhysics? physics;

  @override
  State<WidgetCustomScroll> createState() => _WidgetCustomScrollState();
}

class _WidgetCustomScrollState extends State<WidgetCustomScroll> {
  ValueNotifier<bool> showAppBar = ValueNotifier(false);
  @override
  void initState() {
    super.initState();
  }

  _listener() {
    if (widget.scrollController.offset + kToolbarHeight >= 300) {
      showAppBar.value = true;
    } else {
      showAppBar.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // widget.scrollController.removeListener(_listener);
    widget.scrollController.addListener(_listener);
    return RefreshIndicator(
      // color: ColorName.primaryColorStart,
      onRefresh: () async {
        widget.onRefresh.call();
      },
      child: CustomScrollView(
        controller: widget.scrollController,
        physics: widget.physics,
        cacheExtent: 0.0,
        slivers: widget.buildChildren.call(context, showAppBar, widget.scrollController),
      ),
    );
  }
}

// ignore: must_be_immutable
class CustomSliverAppBar extends StatelessWidget {
  CustomSliverAppBar({Key? key, this.headerAppBar, this.header, this.expandedHeight, this.showAppBar, this.toolbarHeight}) : super(key: key);
  final Widget? headerAppBar;
  final Widget? header;
  final double? expandedHeight;
  final ValueNotifier<bool>? showAppBar;
  double? toolbarHeight;

  @override
  Widget build(BuildContext context) {
    if (toolbarHeight == null) {
      if (Platform.isIOS) {
        toolbarHeight = 0;
      } else {
        toolbarHeight = kToolbarHeight;
      }
    }

    if (showAppBar != null) {
      return ValueListenableBuilder<bool>(
        valueListenable: showAppBar!,
        builder: (context, value, child) {
          return SliverAppBar(
            pinned: value,
            toolbarHeight: toolbarHeight!,
            expandedHeight: expandedHeight,
            backgroundColor: Colors.white,
            shadowColor: Colors.transparent,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              // collapseMode: CollapseMode.none,
              titlePadding: const EdgeInsetsDirectional.only(
                start: 0.0,
                bottom: 5.0,
              ),
              expandedTitleScale: 1.0,
              background: header,
              title: value == true ? headerAppBar : null,
            ),
          );
        },
      );
    }
    return SliverAppBar(
      pinned: true,
      toolbarHeight: toolbarHeight!,
      expandedHeight: expandedHeight,
      backgroundColor: Colors.white,
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        // collapseMode: CollapseMode.none,
        titlePadding: const EdgeInsetsDirectional.only(
          start: 0.0,
          bottom: 5.0,
        ),
        expandedTitleScale: 1.0,
        background: header,
        title: headerAppBar,
      ),
    );
  }
}

class CustomSliverList extends StatelessWidget {
  const CustomSliverList({Key? key, required this.children}) : super(key: key);
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SliverList(delegate: SliverChildListDelegate(children));
  }
}
