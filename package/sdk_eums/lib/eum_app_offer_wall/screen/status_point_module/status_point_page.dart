import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/hex_color.dart';
import 'package:sdk_eums/gen/assets.gen.dart';

import '../../../common/constants.dart';

enum Units { MILLISECOND, SECOND, MINUTE, HOUR, DAY, WEEK, MONTH, YEAR }

class StatusPointPage extends StatefulWidget {
  const StatusPointPage({Key? key}) : super(key: key);

  @override
  State<StatusPointPage> createState() => _StatusPointPageState();
}

class _StatusPointPageState extends State<StatusPointPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;

  DateTime firstMonth = DateTime.now();

  @override
  void initState() {
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title:
            Text('포인트 현황', style: AppStyle.bold.copyWith(color: Colors.black)),
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.arrow_back, size: 24, color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          TabBar(
            onTap: (value) {
              int index = value;
              setState(() {
                _tabController.index = index;
              });
            },
            labelPadding: const EdgeInsets.only(bottom: 10, top: 10),
            controller: _tabController,
            indicatorColor: HexColor('#f4a43b'),
            unselectedLabelColor: HexColor('#707070'),
            labelColor: HexColor('#f4a43b'),
            labelStyle: AppStyle.bold.copyWith(color: HexColor('#707070')),
            tabs: const [
              Text(
                '포인트 적립 내역',
              ),
              Text(' 포인트 전환'),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '현재 보유 포인트',
                      style:
                          AppStyle.medium.copyWith(color: HexColor('707070')),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: HexColor('#fcc900')),
                          child: Text('P',
                              style: AppStyle.bold.copyWith(fontSize: 18)),
                        ),
                        Text(
                          Constants.formatMoney(12398120, suffix: '원'),
                          style: AppStyle.bold.copyWith(fontSize: 20),
                        ),
                      ],
                    )
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: HexColor('#fcc900')),
                  child:
                      Text('소멸예정', style: AppStyle.bold.copyWith(fontSize: 12)),
                ),
              ],
            ),
          ),
          Divider(thickness: 7, color: HexColor('#f4f4f4')),
          _buildWidgetDate(),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _tabController.index == 0
                    ? HexColor('#f4f4f4')
                    : HexColor('#fdde4c')),
            child: Column(
              children: [
                Text(
                  '현재까지 캐시로 전환된 포인트',
                  style: AppStyle.regular,
                ),
                Text(Constants.formatMoney(18912, suffix: 'P'),
                    style: AppStyle.bold),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24))),
              child: TabBarView(controller: _tabController, children: [
                ListViewPointPage(
                  tab: _tabController.index,
                ),
                ListViewPointPage(
                  tab: _tabController.index,
                )
              ]),
            ),
          ),
        ],
      ),
    );
  }

  _buildWidgetDate() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
              onTap: () {
                setState(() {
                  firstMonth = DateTime.parse(
                      Jiffy.parseFromDateTime(firstMonth)
                          .startOf(Unit.month)
                          .subtract(months: 1)
                          .format(pattern: 'yyyy-MM-dd'));
                });
              },
              child: const Icon(
                Icons.arrow_back_ios_new,
              )),
          Text(
            Constants.formatTimePoint(firstMonth.toString()),
            style: AppStyle.bold.copyWith(fontSize: 16),
          ),
          GestureDetector(
              onTap: () {
                setState(() {
                  firstMonth = DateTime.parse(
                      Jiffy.parseFromDateTime(firstMonth)
                          .startOf(Unit.month)
                          .add(months: 1)
                          .format(pattern: 'yyyy-MM-dd'));
                });
              },
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
              )),
        ],
      ),
    );
  }
}

class ListViewPointPage extends StatefulWidget {
  const ListViewPointPage({Key? key, this.tab}) : super(key: key);

  final int? tab;

  @override
  State<ListViewPointPage> createState() => _ListViewPointPageState();
}

class _ListViewPointPageState extends State<ListViewPointPage> {
  @override
  Widget build(BuildContext context) {
    return _buildContent(context);
  }

  _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Wrap(
          runSpacing: 20,
          children: List.generate(10, (index) => _buildItem()),
        ),
      ),
    );
  }

  _buildItem() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: HexColor('#888888').withOpacity(0.3)),
          child: Image.asset(Assets.icon_point.path,
              package: "sdk_eums", height: 25),
        ),
        const SizedBox(width: 5),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '서프라이즈 짱 - 술자리에서 내가 짱이...',
                style: AppStyle.medium.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 5),
              Text(
                '찾아가는 광고 ${Constants.formatTimeDayPoint('2023-08-24 16:10:10')}',
                style: AppStyle.regular
                    .copyWith(fontSize: 12, color: HexColor('#707070')),
              )

              ///  오퍼월 광고
            ],
          ),
        ),
        Text(
          Constants.formatMoney(18912, suffix: 'P'),
          style: AppStyle.bold.copyWith(fontSize: 14),
        ),
      ],
    );
  }
}
