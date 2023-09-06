import 'package:flutter/material.dart';
import 'package:sdk_eums/common/routing.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/asked_question_module/asked_question_screen.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/request_module/request_screen.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/hex_color.dart';
import 'package:sdk_eums/gen/assets.gen.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(),
      body: Column(
        children: [_buildItem()],
      ),
    );
  }

  _buildItem() {
    List<String> dataAreaName =
        (listItemMy.map((item) => item['area'].toString())).toSet().toList();
    return Wrap(
      children: List.generate(
          dataAreaName.length,
          (index) => _buildAreaItem(
              data: listItemMy
                  .where((element) => element['area'] == dataAreaName[index])
                  .toList())),
    );
  }

  _buildAreaItem({dynamic data}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: HexColor('#f4f4f4')),
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
            child: Text(
              data[0]['area'],
              style: AppStyle.bold,
            )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            direction: Axis.horizontal,
            children: List.generate(
                data.length,
                (index) => GestureDetector(
                      onTap: () {
                        switch (data[index]['id']) {
                          case 1:
                            print("asdlkajsd");
                            break;
                          case 2:
                            print("asdlkajsd");
                            break;
                          case 3:
                            print("asdlkajsd");
                            break;
                          case 4:
                            print("asdlkajsd");
                            break;
                          case 5:
                            print("11");
                            break;
                          case 6:
                            Routing().navigate(context, RequestScreen());
                            break;
                          case 7:
                            Routing().navigate(context, AskedQuestionScreen());
                            break;
                          case 8:
                            print("asdlkajsd");
                            break;
                          case 9:
                            print("asdlkajsd");
                            break;
                          case 10:
                            print("asdlkajsd");
                            break;
                          case 11:
                            print("asdlkajsd");
                            break;
                          case 12:
                            print("asdlkajsd");
                            break;
                          default:
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                            border: Border.all(color: HexColor('#e5e5e5')),
                            borderRadius: BorderRadius.circular(5)),
                        width: (MediaQuery.of(context).size.width - 45) / 2,
                        child: Row(
                          children: [
                            Text(
                              data[index]['subArea'],
                              style: AppStyle.medium,
                            ),
                            const Spacer(),
                            Image.asset(
                              data[index]['urlImage'],
                              package: "sdk_eums",
                              height: 24,
                            )
                          ],
                        ),
                      ),
                    )),
          ),
        )
      ],
    );
  }
}

List listItemMy = [
  {
    "id": 1,
    "area": "포인트/광고 관련",
    "subArea": "포인트 적립 내역",
    "urlImage": Assets.history_point.path
  },
  {
    "id": 2,
    "area": "포인트/광고 관련",
    "subArea": "포인트 전환",
    "urlImage": Assets.point_conversion.path
  },
  {
    "id": 3,
    "area": "포인트/광고 관련",
    "subArea": "광고 보관함",
    "urlImage": Assets.adarchive.path
  },
  {
    "id": 4,
    "area": "포인트/광고 관련",
    "subArea": "광고 스크랩",
    "urlImage": Assets.adscrap.path
  },
  {"id": 5, "area": "기타", "subArea": "공지사항", "urlImage": Assets.notifi.path},
  {
    "id": 6,
    "area": "기타",
    "subArea": "1:1 문의",
    "urlImage": Assets.inquiry1.path
  },
  {
    "id": 7,
    "area": "기타",
    "subArea": "자주 묻는 질문",
    "urlImage": Assets.frequentlyAQ.path
  },
  {
    "id": 8,
    "area": "서비스 이용 관련",
    "subArea": "제휴 및 광고 문의",
    "urlImage": Assets.frequentluasq.path
  },
  {
    "id": 9,
    "area": "서비스 이용 관련",
    "subArea": "서비스 이용 안내",
    "urlImage": Assets.service_info.path
  },
  {
    "id": 10,
    "area": "서비스 이용 관련",
    "subArea": "이용약관",
    "urlImage": Assets.termofuser.path
  },
  {
    "id": 12,
    "area": "서비스 이용 관련",
    "subArea": "설정",
    "urlImage": Assets.setting.path
  }
];
