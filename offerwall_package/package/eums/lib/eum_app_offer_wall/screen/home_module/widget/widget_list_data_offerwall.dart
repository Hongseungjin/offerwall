import 'package:cached_network_image/cached_network_image.dart';
import 'package:eums/common/constants.dart';
import 'package:eums/common/routing.dart';
import 'package:eums/eum_app_offer_wall/screen/detail_offwall_module/detail_offwall_screen.dart';
import 'package:eums/eum_app_offer_wall/screen/home_module/bloc/home_bloc.dart';
import 'package:eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:eums/eum_app_offer_wall/utils/hex_color.dart';
import 'package:eums/eum_app_offer_wall/utils/widget_loading_animated.dart';
import 'package:eums/eum_app_offer_wall/widget/custom_animation_click.dart';
import 'package:eums/eum_app_offer_wall/widget/setting_fontsize.dart';
import 'package:eums/eums_library.dart';
import 'package:eums/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ListViewHome extends StatefulWidget {
  const ListViewHome({
    Key? key,
    required this.tab,
    required this.scrollController,
    required this.stateClients,
    required this.blocs,
    this.onFilter,
    this.filter,
    required this.category,
  }) : super(key: key);

  final int tab;
  // final Function? fetchData;
  // final Function? fetchDataLoadMore;
  final Function? onFilter;
  final ScrollController scrollController;
  final List<HomeListDataOfferWallState?> stateClients;
  final List<HomeBloc> blocs;
  final String? filter;
  final String category;

  @override
  State<ListViewHome> createState() => _ListViewHomeState();
}

class _ListViewHomeState extends State<ListViewHome> {
  RefreshController refreshController = RefreshController(initialRefresh: false);

  // ScrollController? controller;

  String allMedia = '최신순';
  final controllerGet = Get.put(SettingFontSize());

  final double _endReachedThreshold = 400;

  @override
  void initState() {
    widget.scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent(context);
  }

  Widget _buildDropDown(BuildContext context) {
    dynamic medias = DATA_MEDIA.map((item) => item['name']).toList();
    List<DropdownMenuItem<String>> items = medias.map<DropdownMenuItem<String>>((String? value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(
          value ?? "",
          textAlign: TextAlign.center,
          style: AppStyle.bold.copyWith(color: AppColor.black, fontSize: controllerGet.fontSizeObx.value),
        ),
      );
    }).toList();

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        dropdownColor: AppColor.white,
        value: allMedia,
        style: AppStyle.bold.copyWith(color: AppColor.black, fontSize: 14),
        hint: Text(
          allMedia,
          style: AppStyle.bold.copyWith(color: AppColor.black, fontSize: 14),
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColor.black,
          size: 24,
        ),
        items: items,
        onChanged: (value) {
          setState(() {
            allMedia = value!;
          });

          widget.onFilter?.call(value);
        },
      ),
    );
  }

  _buildContent(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) => current is HomeListDataOfferWallState,
      bloc: widget.blocs[widget.tab],
      builder: (context, state) {
        if (state is HomeListDataOfferWallState) {
          widget.stateClients[widget.tab] = state;
        }

        if (widget.tab == 0) {
          return SliverList(
            delegate: SliverChildListDelegate([
              _buildItemTitle(context),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    ...List.generate(
                        (widget.stateClients[widget.tab]?.listData ?? []).length,
                        (index) => WidgetAnimationClick(
                            onTap: () {
                              Routings().navigate(
                                  context,
                                  DetailOffWallScreen(
                                    title: widget.stateClients[widget.tab]?.listData![index]['title'],
                                    xId: widget.stateClients[widget.tab]?.listData![index]['idx'],
                                    type: widget.stateClients[widget.tab]?.listData![index]['type'],
                                  ));
                            },
                            child: _buildItemRow(data: widget.stateClients[widget.tab]?.listData![index]))),
                    if (widget.stateClients[widget.tab]?.loading == true && widget.stateClients[widget.tab]?.lastItem == false)
                      const WidgetLoadingAnimated()
                  ],
                ),
              )
            ]),
          );
        }
        return SliverList(
          delegate: SliverChildListDelegate([
            _buildItemTitle(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: buildBodyWrap(
                  context: context,
                  countRow: 2,
                  data: widget.stateClients[widget.tab]?.listData ?? [],
                  buildItem: (index) {
                    return WidgetAnimationClick(
                        onTap: () {
                          Routings().navigate(
                              context,
                              DetailOffWallScreen(
                                title: widget.stateClients[widget.tab]?.listData![index]['title'],
                                xId: widget.stateClients[widget.tab]?.listData![index]['idx'],
                                type: widget.stateClients[widget.tab]?.listData![index]['type'],
                              ));
                        },
                        child: _buildItemColum(data: widget.stateClients[widget.tab]?.listData![index]));
                  },
                ),
              ),
            )
          ]),
        );
      },
    );
  }

  Container _buildItemTitle(BuildContext context) {
    return Container(
      color: AppColor.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            '전체 ${widget.stateClients[widget.tab]?.listData != null ? widget.stateClients[widget.tab]?.listData!.length : 0} 개',
            style: AppStyle.regular.copyWith(fontSize: controllerGet.fontSizeObx.value),
          ),
          const Spacer(),
          SizedBox(
            height: 35,
            width: 100,
            child: Center(child: _buildDropDown(context)),
          ),
        ],
      ),
    );
  }

  _buildItemColum({dynamic data}) {
    return Container(
      color: Colors.white,
      width: (MediaQuery.of(context).size.width - 48) / 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
                width: MediaQuery.of(context).size.width,
                height: 200,
                fit: BoxFit.cover,
                imageUrl: '${Constants.baseUrlImage}${data['thumbnail']}',
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) {
                  return Image.asset(Assets.logo.path, package: "eums", width: 30, height: 30);
                }),
          ),
          const SizedBox(height: 4),
          Text(
            data['title'] ?? "",
            maxLines: 2,
            style: AppStyle.regular.copyWith(fontSize: controllerGet.fontSizeObx.value, color: Colors.black),
          ),
          const SizedBox(height: 4),
          Text(
            Constants.formatMoney(data['reward'], suffix: '원'),
            style: AppStyle.regular
                .copyWith(decoration: TextDecoration.lineThrough, fontSize: controllerGet.fontSizeObx.value, color: HexColor('#888888')),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text('60% ', style: AppStyle.bold.copyWith(color: HexColor('#ff7169'), fontSize: 2 + controllerGet.fontSizeObx.value)),
              Text(Constants.formatMoney(data['reward'], suffix: '원'),
                  style: AppStyle.bold.copyWith(color: HexColor('#000000'), fontSize: 2 + controllerGet.fontSizeObx.value))
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: HexColor('#fdd000'), borderRadius: BorderRadius.circular(5)),
            child: Text(
              '+${Constants.formatMoney(data['reward'], suffix: '')}',
              style: AppStyle.bold.copyWith(color: Colors.black, fontSize: controllerGet.fontSizeObx.value),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  _buildItemRow({Map<String, dynamic>? data}) {
    String title = '';
    switch (data?['type']) {
      case 'install':
        title = '설치하면${Constants.formatMoney(data?['reward'], suffix: '')}적립';
        break;
      case 'visit':
        title = '방문하면${Constants.formatMoney(data?['reward'], suffix: '')}적립';
        break;
      case 'join':
        title = '가입하면${Constants.formatMoney(data?['reward'], suffix: '')}적립';
        break;
      case 'shopping':
        title = '구매하면${Constants.formatMoney(data?['reward'], suffix: '')}적립';
        break;
      case 'subscribe':
        title = '구독/좋아요/팔로우 하면 ${Constants.formatMoney(data?['reward'], suffix: '')}적립 ';
        break;
      default:
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.3)), borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              child: CachedNetworkImage(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width / 2,
                  // height: 200,
                  fit: BoxFit.cover,
                  imageUrl: '${Constants.baseUrlImage}${data?['thumbnail']}',
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) {
                    return Image.asset(Assets.logo.path, package: "eums", width: 30, height: 30);
                  }),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                data?['title'] ?? "",
                // maxLines: 2,
                style: AppStyle.bold.copyWith(color: Colors.black, fontSize: 2 + controllerGet.fontSizeObx.value),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: (MediaQuery.of(context).size.width) / 1.8 - 10,
                    child: Text(
                      title,
                      style: AppStyle.regular.copyWith(color: HexColor('#666666'), fontSize: controllerGet.fontSizeObx.value),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: HexColor('#fdd000')),
                    child: Text(
                      '포인트받기',
                      style: AppStyle.regular.copyWith(fontSize: controllerGet.fontSizeObx.value),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onScroll() async {
    if (!widget.scrollController.hasClients ||
        widget.stateClients[widget.tab]?.lastItem == true ||
        widget.stateClients[widget.tab]?.loading == true) {
      return;
    }
    final thresholdReached = widget.scrollController.position.extentAfter < _endReachedThreshold;
    if (thresholdReached) {
      widget.stateClients[widget.tab]?.loading = true;
      await _onLoading();
    }
  }

  _onLoading() {
    widget.blocs[widget.tab]
        .add(HomeListDataOfferWallEvent(filter: widget.filter, category: widget.category, stateClient: widget.stateClients[widget.tab]));
  }

  List<Widget> buildBodyWrap<T>(
      {required BuildContext context,
      required int countRow,
      int index = 0,
      required List<T>? data,
      List<Widget>? listChild,
      double vertical = 10,
      double horizontal = 10,
      required Function(int index) buildItem}) {
    listChild ??= [];
    List<Widget> listChildRow = [];

    if (data != null) {
      for (int i = index; i < index + countRow; i++) {
        if (i < data.length) {
          listChildRow.add(
            Expanded(child: buildItem.call(i)),
          );
          if (i < (index + countRow - 1)) {
            listChildRow.add(SizedBox(
              width: horizontal,
            ));
          }
        } else {
          // listChildRow.add(SizedBox(
          //   width: horizontal * (countRow - 1),
          // ));
          listChildRow.add(const Expanded(child: SizedBox()));
        }
      }
    }

    listChild.add(Padding(
      padding: EdgeInsets.symmetric(vertical: vertical / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: listChildRow,
      ),
    ));

    if ((index + countRow) < (data?.length ?? 0)) {
      buildBodyWrap(index: index + countRow, data: data, listChild: listChild, buildItem: buildItem, context: context, countRow: countRow);
    } else {
      if (widget.stateClients[widget.tab]?.lastItem == false) {
        listChild.add(const WidgetLoadingAnimated());
      } else {
        listChild.add(const SizedBox());
      }
    }

    return listChild;
  }
}
