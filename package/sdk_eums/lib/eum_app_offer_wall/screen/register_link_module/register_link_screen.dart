import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sdk_eums/common/routing.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/hex_color.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/loading_dialog.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/app_alert.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/custom_inappweb.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/select_image_picker_dialog.dart';
import 'package:sdk_eums/gen/assets.gen.dart';

import '../../../common/constants.dart';
import '../../../common/events/events.dart';
import '../../../common/rx_bus.dart';
import '../../utils/appColor.dart';
import '../../utils/appStyle.dart';
import '../../widget/custom_dialog.dart';
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
  File? fileImage;
  FToast fToast = FToast();

  String urlImage = '';
  String htmlWeb = '';

  @override
  void initState() {
    fToast.init(context);
    getHtml();
    // TODO: implement initState
    super.initState();
    _getPreferredLanguages();
  }

  getHtml() async {
    dynamic data = await Dio()
        .get(
      widget.data['api'],
    )
        .then((value) {
      htmlWeb = value.data;
    });
    return data;
  }

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
      LoadingDialog.instance.show();
      return;
    }
    if (state.registerLinkStatus == RegisterLinkStatus.failure) {
      LoadingDialog.instance.hide();
      AppAlert.showError(
        context,
        fToast,
        'Invalid image',
      );
      return;
    }
    if (state.registerLinkStatus == RegisterLinkStatus.success) {
      RxBus.post(UpdateUser());
      LoadingDialog.instance.hide();
      DialogUtils.showDialogMissingPoint(context, data: widget.data['reward'],
          voidCallback: () {
        Navigator.pop(context);
      });
    }
  }

  List? _languages = [];

  Future<void> _getPreferredLanguages() async {
    try {
      final languages = await Devicelocale.preferredLanguages;
      print((languages != null)
          ? languages
          : "unable to get preferred languages");
      setState(() => _languages = languages);
      print("_languages$_languages");
    } on PlatformException {
      print("Error obtaining preferred languages");
    }
  }

  _buildContent(BuildContext context) {
    return Scaffold(
      key: globalKey,
      backgroundColor: AppColor.white,
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios_outlined,
              color: AppColor.dark, size: 25),
        ),
        centerTitle: true,
        elevation: 1,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Image.asset(Assets.chat.path,
                package: "sdk_eums", height: 24, width: 24),
          )
        ],
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
                        '구독시 포인트 적립',
                        style: AppStyle.regular
                            .copyWith(color: AppColor.black, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "+ ${Constants.formatMoney(widget.data['reward'] ?? 0, suffix: 'P')}",
                        style: AppStyle.bold
                            .copyWith(color: HexColor('#f4a43b'), fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 5,
              height: 0,
              color: HexColor('#e5e5e5'),
            ),
            Divider(
              height: 1,
              thickness: 7,
              color: HexColor('#f4f4f4'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text('구독 참여 절차', style: AppStyle.bold),
            ),
            Row(
              children: [
                const SizedBox(width: 16),
                Wrap(
                  direction: Axis.horizontal,
                  children: List.generate(
                      listResLink.length,
                      (index) => Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width / 4 - 40,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: HexColor('#eeeeee')),
                                      child: Image.asset(
                                          listResLink[index]['link'],
                                          package: "sdk_eums",
                                          width: 44,
                                          height: 44),
                                    ),
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
                                const Padding(
                                  padding: EdgeInsets.only(
                                    top: 20,
                                  ),
                                  child: Icon(Icons.arrow_forward_ios_rounded,
                                      size: 16),
                                ),
                                const SizedBox(width: 10),
                              }
                            ],
                          )),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Divider(
              thickness: 5,
              height: 0,
              color: HexColor('#e5e5e5'),
            ),
            Divider(
              height: 1,
              thickness: 7,
              color: HexColor('#f4f4f4'),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildTilte('STEP 1   ', '아래의 버튼을 눌러 구독해주세요'),
                InkWell(
                  onTap: () {
                    Routing().navigate(
                        context,
                        CustomInappWebView(
                          urlLink: widget.data['api'],
                          onClose: () {},
                        ));
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: HexColor('#fdd000'),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      '구독하러 가기',
                      textAlign: TextAlign.center,
                      style: AppStyle.bold
                          .copyWith(color: AppColor.black, fontSize: 16),
                    ),
                  ),
                ),
                Divider(),
                // Image.asset(
                //   Assets.lineBreak.path,
                //   package: "sdk_eums",
                // ),
                const SizedBox(height: 16),
                _buildTilte('STEP 2   ', '인천e몰 유튜브 구독 후 캡쳐하기'),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '인천e음 유튜브 페이지에서 구독된 화면을 캡쳐해주세요.',
                    style: AppStyle.medium
                        .copyWith(color: AppColor.black, fontSize: 14),
                  ),
                ),
                // const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '※ 아래의 예시와 같이 언론사 페이지에서 구독 상태가 보이도록 캡쳐해 주세요',
                    style: AppStyle.medium
                        .copyWith(color: HexColor('#ff0019'), fontSize: 12),
                  ),
                ),
                const SizedBox(height: 12),

                Image.asset(
                  Assets.resLinkBanner.path,
                  package: "sdk_eums",
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 12),
                Divider(),
                // Image.asset(
                //   Assets.lineBreak.path,
                //   package: "sdk_eums",
                // ),
                const SizedBox(height: 16),
                _buildTilte('STEP 3   ', '스크린 샷 업로드 하기'),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '이미지가 업로드 완료 된 후, 지급받기 버튼을 눌러주세요. ',
                    style: AppStyle.medium
                        .copyWith(color: AppColor.black, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 24),
                InkWell(
                  onTap: () {
                    _addImages();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColor.color70),
                        borderRadius: BorderRadius.circular(12)),
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(Assets.camera.path,
                              package: "sdk_eums", height: 24, width: 24),
                          const SizedBox(width: 10),
                          SizedBox(
                              child: Text(
                                  files.isNotEmpty ? urlImage : '이미지 업로드 하기',
                                  style: AppStyle.medium
                                      .copyWith(color: AppColor.black),
                                  overflow: TextOverflow.clip)),
                        ],
                      ),
                    ),
                  ),
                ),
                // InkWell(
                //   onTap: () {},
                //   child: Container(
                //     margin: const EdgeInsets.symmetric(vertical: 16),
                //     padding: const EdgeInsets.symmetric(vertical: 16),
                //     width: MediaQuery.of(context).size.width,
                //     decoration: BoxDecoration(
                //         color: AppColor.blue1,
                //         borderRadius: BorderRadius.circular(4)),
                //     child: Text(
                //       '이미지 업로드하기',
                //       textAlign: TextAlign.center,
                //       style: AppStyle.bold
                //           .copyWith(color: AppColor.white, fontSize: 16),
                //     ),
                //   ),
                // ),
              ],
            ),
            // const Divider(thickness: 10),
            InkWell(
              onTap: () {
                String lang = '';
                if (_languages?[0] == 'ko-KR') {
                  lang = 'kor';
                } else {
                  lang = 'eng';
                }
                if (urlImage != '') {
                  print("htmlWeb${htmlWeb}");
                  globalKey.currentContext?.read<RegisterLinkBloc>().add(
                      MissionOfferWallRegisterLink(
                          files: fileImage,
                          xId: widget.data['idx'],
                          lang: lang,
                          html: htmlWeb));
                }
              },
              child: Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                padding: const EdgeInsets.symmetric(vertical: 16),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: AppColor.yellow,
                    borderRadius: BorderRadius.circular(10)),
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
        print(urlImage);
        fileImage = File(pickedFile.path);
        print("File(pickedFile.path)${File(pickedFile.path)}");
        files.add(File(pickedFile.path));
        setState(() {});
      }
    } catch (e) {}
  }

  _buildTilte(String? step, String? title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step ?? '',
            style: AppStyle.bold
                .copyWith(color: HexColor('#f4a43b'), fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            title ?? '',
            style: AppStyle.bold.copyWith(color: AppColor.black, fontSize: 16),
          )
        ],
      ),
    );
    // RichText(
    //     text: TextSpan(
    //         text: step ?? '',
    //         style: AppStyle.bold.copyWith(color: AppColor.red, fontSize: 16),
    //         children: [
    //       TextSpan(
    //         text: title ?? '',
    //         style: AppStyle.bold.copyWith(color: AppColor.black, fontSize: 16),
    //       )
    //     ]));
  }

  void printWrapped(String text) {
    final pattern = RegExp('.{3,800}');
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }
}

List listResLink = [
  {"name": '구독하기', "link": Assets.icon_sub.path},
  {"name": '구독 화면 캡쳐', "link": Assets.icon_check.path},
  {"name": '스크린샷 업로드', "link": Assets.icon_upload.path},
  {"name": '리워드 지금', "link": Assets.icon_reward.path}
];
