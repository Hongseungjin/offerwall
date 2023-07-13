import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sdk_eums/common/routing.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/select_image_picker_dialog.dart';
import 'package:sdk_eums/gen/assets.gen.dart';

import '../../../common/constants.dart';
import '../../../common/events/events.dart';
import '../../../common/rx_bus.dart';
import '../../utils/appColor.dart';
import '../../utils/appStyle.dart';
import '../../widget/custom_dialog.dart';
import '../../widget/custom_webview.dart';
import 'bloc/register_link_bloc.dart';

class RegisterLinkScreen extends StatefulWidget {
  dynamic data;
  RegisterLinkScreen({Key? key, this.data}) : super(key: key);

  @override
  State<RegisterLinkScreen> createState() => _RegisterLinkScreenState();
}

class _RegisterLinkScreenState extends State<RegisterLinkScreen> {
  final GlobalKey<State<StatefulWidget>> globalKey =
      GlobalKey<State<StatefulWidget>>();
  List<File> files = [];
  String urlImage = '';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegisterLinkBloc>(
      create: (context) => RegisterLinkBloc(),
      child: MultiBlocListener(listeners: [
        BlocListener<RegisterLinkBloc, RegisterLinkState>(
          listenWhen: (previous, current) =>
              previous.registerLinkStatus != current.registerLinkStatus,
          listener: _listenFetchData,
        ),
      ], child: _buildContent(context)),
    );
  }

  void _listenFetchData(BuildContext context, RegisterLinkState state) {
    if (state.registerLinkStatus == RegisterLinkStatus.loading) {
      // EasyLoading.show();
      return;
    }
    if (state.registerLinkStatus == RegisterLinkStatus.failure) {
      // EasyLoading.dismiss();
      return;
    }
    if (state.registerLinkStatus == RegisterLinkStatus.success) {
      RxBus.post(UpdateUser());
      // EasyLoading.dismiss();
      DialogUtils.showDialogMissingPoint(context, data: widget.data['reward']);
    }
  }

  _buildContent(BuildContext context) {
    return Scaffold(
      key: globalKey,
      backgroundColor: AppColor.white,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.arrow_back_ios_outlined,
              color: AppColor.dark, size: 25),
        ),
        centerTitle: true,
        elevation: 1,
        backgroundColor: AppColor.white,
        title: Text(
          '캐시적립',
          style: AppStyle.bold.copyWith(color: AppColor.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: AppColor.color70.withOpacity(0.2),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColor.black)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                          imageUrl:
                              Constants.baseUrlImage + widget.data['thumbnail'],
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) {
                            return Assets.logo.image();
                          }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2 - 20,
                        child: Text(
                          widget.data['title'],
                          overflow: TextOverflow.ellipsis,
                          style: AppStyle.bold
                              .copyWith(color: AppColor.black, fontSize: 16),
                        ),
                      ),
                      Text(
                        '도달시 캐시 적립',
                        style: AppStyle.regular
                            .copyWith(color: AppColor.black, fontSize: 14),
                      )
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "+ ${widget.data['reward']}",
                        style: AppStyle.bold
                            .copyWith(color: AppColor.orange4, fontSize: 20),
                      ),
                      Text(
                        "+캐시",
                        style: AppStyle.medium
                            .copyWith(color: AppColor.black, fontSize: 14),
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(width: 16),
                Wrap(
                  direction: Axis.horizontal,
                  children: List.generate(
                      listResLink.length,
                      (index) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width / 4 - 40,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(listResLink[index]['link'],
                                        package: "sdk_eums",
                                        width: 44,
                                        height: 44),
                                    const SizedBox(height: 16),
                                    Text(
                                      '${listResLink[index]['name']}',
                                      textAlign: TextAlign.center,
                                      style: AppStyle.bold.copyWith(
                                          color: AppColor.black, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              if (listResLink[index]['name'] != '리워드 지금') ...{
                                Image.asset(
                                  Assets.arrow.path,
                                  package: "sdk_eums",
                                  height: 16,
                                ),
                                const SizedBox(width: 16),
                              }
                            ],
                          )),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(thickness: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildTilte('STEP 1   ', '아래의 버튼을 눌러 구독해주세요'),
                  GestureDetector(
                    onTap: () {
                      Routing().navigate(
                          context,
                          CustomWebView(
                            urlLink: widget.data['api'],
                            title: '',
                          ));
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: AppColor.blue1,
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        '구독하러 가기',
                        textAlign: TextAlign.center,
                        style: AppStyle.bold
                            .copyWith(color: AppColor.white, fontSize: 16),
                      ),
                    ),
                  ),
                  Image.asset(
                    Assets.lineBreak.path,
                    package: "sdk_eums",
                  ),
                  const SizedBox(height: 16),
                  _buildTilte('STEP 2   ', '언론사 페이지 캡쳐하기'),
                  const SizedBox(height: 4),
                  Text(
                    '국민일보 페이지에서 구독된 화면을 캡쳐해 주세요.',
                    style: AppStyle.medium
                        .copyWith(color: AppColor.black, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '※ 아래의 예시와 같이 언론사 페이지에서 구독 상태가 보이도록 캡쳐해 주세요',
                    style: AppStyle.medium
                        .copyWith(color: AppColor.orange4, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Image.asset(
                    Assets.resLinkBanner.path,
                    package: "sdk_eums",
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(height: 12),
                  Image.asset(
                    Assets.lineBreak.path,
                    package: "sdk_eums",
                  ),
                  const SizedBox(height: 16),
                  _buildTilte('STEP 3   ', '스크린 샷 업로드 하기'),
                  const SizedBox(height: 4),
                  Text(
                    '이미지가 업로드 완료 된 후, 지급받기 버튼을 눌러주세요. ',
                    style: AppStyle.medium
                        .copyWith(color: AppColor.black, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                          border: Border.all(color: AppColor.color70),
                          borderRadius: BorderRadius.circular(12)),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Image.asset(Assets.upImage.path,
                              package: "sdk_eums", height: 24, width: 24),
                          const SizedBox(width: 10),
                          SizedBox(
                              width: MediaQuery.of(context).size.width / 2 + 50,
                              child: Text(
                                  files.isNotEmpty ? urlImage : '이미지 업로드',
                                  style: AppStyle.medium
                                      .copyWith(color: AppColor.black),
                                  overflow: TextOverflow.clip)),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _addImages();
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: AppColor.blue1,
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        '구독하러 가기',
                        textAlign: TextAlign.center,
                        style: AppStyle.bold
                            .copyWith(color: AppColor.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 10),
            GestureDetector(
              onTap: () {
                if (urlImage != '') {
                  globalKey.currentContext?.read<RegisterLinkBloc>().add(
                      MissionOfferWallRegisterLink(
                          files: files, xId: widget.data['idx']));
                }
              },
              child: Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                padding: const EdgeInsets.symmetric(vertical: 16),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: AppColor.yellow,
                    borderRadius: BorderRadius.circular(4)),
                child: Text(
                  '참여하고 캐시 받기',
                  textAlign: TextAlign.center,
                  style: AppStyle.bold
                      .copyWith(color: AppColor.black, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _addImages() async {
    SelectImgPickerDialog.show(context, chooseImgTap: () {
      _onPickPhoto(ImageSource.gallery);
    }, openCameraTap: () {
      _onPickPhoto(ImageSource.camera);
    });
  }

  void _onPickPhoto(ImageSource source) async {
    try {
      PickedFile? pickedFile = await ImagePicker().getImage(
        source: source,
      );
      if (pickedFile != null) {
        String start = '/';
        int startIndex = pickedFile.path.lastIndexOf(start);
        urlImage = pickedFile.path.substring(startIndex + 1);
        files.add(File(pickedFile.path));
        setState(() {});
      }
    } catch (e) {
      
    }
  }

  _buildTilte(String? step, String? title) {
    return RichText(
        text: TextSpan(
            text: step ?? '',
            style: AppStyle.bold.copyWith(color: AppColor.red, fontSize: 16),
            children: [
          TextSpan(
            text: title ?? '',
            style: AppStyle.bold.copyWith(color: AppColor.black, fontSize: 16),
          )
        ]));
  }
}

List listResLink = [
  {"name": '구독 하기', "link": Assets.reward.path},
  {"name": '구독 화면 캡쳐', "link": Assets.checkin.path},
  {"name": '스크린샷 업로드', "link": Assets.uploadImage.path},
  {"name": '리워드 지금', "link": Assets.receivePoint.path}
];
