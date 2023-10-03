import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sdk_eums/common/constants.dart';
import 'package:sdk_eums/common/routing.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/hex_color.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/loading_dialog.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/widget_expansion_title.dart';
import 'package:sdk_eums/gen/assets.gen.dart';

import '../../utils/appStyle.dart';
import '../../utils/app_string.dart';
import '../request_module/request_screen.dart';
import 'bloc/asked_question_bloc.dart';

class AskedQuestionScreen extends StatefulWidget {
  const AskedQuestionScreen({Key? key}) : super(key: key);

  @override
  State<AskedQuestionScreen> createState() => _AskedQuestionScreenState();
}

class _AskedQuestionScreenState extends State<AskedQuestionScreen> {
  final GlobalKey<State<StatefulWidget>> globalKey =
      GlobalKey<State<StatefulWidget>>();
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  String keySearch = '';
  bool checkSearch = false;
  TextEditingController searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AskedQuestionBloc>(
      create: (context) => AskedQuestionBloc()
        ..add(AskedQuestion(limit: Constants.LIMIT_DATA, search: keySearch)),
      child: BlocListener<AskedQuestionBloc, AskedQuestionState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: _listenFetchData,
        child: BlocBuilder<AskedQuestionBloc, AskedQuestionState>(
          builder: (context, state) {
            return _buildContent(context, state.dataAskedQuestion);
          },
        ),
      ),
    );
  }

  void _listenFetchData(BuildContext context, AskedQuestionState state) {
    if (state.status == AskedQuestionStatus.loading) {
      LoadingDialog.instance.show();
      return;
    }
    if (state.status == AskedQuestionStatus.failure) {
      LoadingDialog.instance.hide();
      return;
    }
    if (state.status == AskedQuestionStatus.success) {
      LoadingDialog.instance.hide();
    }
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(seconds: 0));
    refreshController.refreshCompleted();
    setState(() {});
    _fetchData();
  }

  _fetchData() async {
    globalKey.currentContext
        ?.read<AskedQuestionBloc>()
        .add(AskedQuestion(limit: Constants.LIMIT_DATA, search: keySearch));
  }

  void _onLoading() async {
    await Future.delayed(const Duration(seconds: 0));
    refreshController.loadComplete();
    List<dynamic>? dataAsked = globalKey.currentContext
        ?.read<AskedQuestionBloc>()
        .state
        .dataAskedQuestion;
    if (dataAsked != null) {
      globalKey.currentContext?.read<AskedQuestionBloc>().add(
          LoadMoreAskedQuestion(
              offset: dataAsked.length,
              limit: Constants.LIMIT_DATA,
              search: keySearch));
    }
  }

  Scaffold _buildContent(BuildContext context, dynamic dataAskedQuestion) {
    return Scaffold(
      key: globalKey,
      backgroundColor: AppColor.white,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        elevation: 1,
        centerTitle: true,
        title: Text(AppString.askedQuestion,
            style: AppStyle.bold.copyWith(fontSize: 16, color: AppColor.black)),
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.arrow_back_ios_outlined,
              color: AppColor.dark, size: 25),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 65,
            bottom: 100,
            child: SmartRefresher(
              controller: refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              header: CustomHeader(
                builder: (BuildContext context, RefreshStatus? mode) {
                  return const Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.transparent)));
                },
              ),
              footer: CustomFooter(
                builder: (BuildContext context, LoadStatus? mode) {
                  return mode == LoadStatus.loading
                      ? Center(
                          child: Column(
                          children: const [
                            Text(' '),
                            CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.black)),
                          ],
                        ))
                      : Container();
                },
              ),
              enablePullDown: true,
              enablePullUp: true,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: dataAskedQuestion != null
                      ? Wrap(
                          children:
                              List.generate(dataAskedQuestion.length, (index) {
                            dynamic data = dataAskedQuestion[index];

                            return _buildItem(index: index, data: data);
                          }),
                        )
                      : SizedBox(),
                ),
              ),
            ),
          ),
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(color: AppColor.white),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: searchCtrl,
                      onChanged: (value) {
                        setState(() {
                          keySearch = value;
                          checkSearch = true;
                        });
                        _fetchData();
                      },
                      decoration: InputDecoration(
                          suffixIcon: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 17),
                            child: checkSearch
                                ? InkWell(
                                    onTap: () {
                                      setState(() {
                                        searchCtrl.clear();
                                        keySearch = '';
                                        checkSearch = false;
                                      });
                                      _fetchData();
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.black,
                                    ))
                                : Image.asset(Assets.searchOrange.path,
                                    color: Colors.black,
                                    package: "sdk_eums",
                                    height: 15),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            borderSide: BorderSide(
                                color: HexColor('#e5e5e5'), width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            borderSide: BorderSide(
                                color: HexColor('#e5e5e5'), width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          hintText: '질문 키워드를 입력해 주세요',
                          border: InputBorder.none,
                          hintStyle: AppStyle.bold.copyWith(
                              color: AppColor.color70.withOpacity(0.7))),
                    ),
                    Divider(),
                  ],
                ),
              )),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(color: AppColor.white),
              child: Column(
                children: [
                  Text(
                    '더 궁금한 점은 1:1문의하기를 통해 해결해 보세요.',
                    style: AppStyle.bold
                        .copyWith(fontSize: 14, color: HexColor('#666666')),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      Routing().navigate(context, RequestScreen());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColor.yellow),
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        '1:1 문의하기',
                        textAlign: TextAlign.center,
                        style: AppStyle.bold
                            .copyWith(color: AppColor.black, fontSize: 14),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildItem({int? index, dynamic data}) {
    return WidgetExpansionTitle(
      initiallyExpanded: data['isExpanded'],
      onExpansionChanged: (expanded) {
        setState(() {
          data['isExpanded'] = expanded;
        });
      },
      header: (BuildContext text, dynamic Function(bool?) onExpand) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Row(
                children: [
                  _buildTitle(
                    title: '${data['title']}',
                  ),
                  Spacer(),
                  SizedBox(
                    width: 30,
                    height: 50,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                          begin: 0.0,
                          end: data['isExpanded'] == true ? 1.0 : 0.0),
                      duration: const Duration(milliseconds: 200),
                      builder: (context, value, child) => Center(
                        child: Transform.rotate(
                          angle: -value * pi,
                          child: const Icon(Icons.expand_more,
                              color: AppColor.grey5D),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          decoration: BoxDecoration(
              color: AppColor.colorF4, borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: HtmlWidget(
            data['content'],
            customStylesBuilder: (e) {
              if (e.classes.contains('ql-align-center')) {
                return {'text-align': 'center'};
              }

              return null;
            },
          ),
        ),
        const SizedBox(height: 8),
        const Divider()
      ],
    );
  }

  Widget _buildTitle({String? title}) {
    String start1 = 'Q';
    int startIndex1 = title!.indexOf(start1);
    String iframeTag1 = title.substring(startIndex1 + 2);
    title = iframeTag1.replaceAll(iframeTag1, iframeTag1);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: HexColor('#fdd000')),
          child: Text(
            start1,
            style: AppStyle.bold,
          ),
        ),
        // Image.asset(Assets.question.path, package: "sdk_eums", height: 32),
        SizedBox(
            width: MediaQuery.of(context).size.width - 100,
            child: Text(
              title,
              maxLines: 2,
              style: AppStyle.bold.copyWith(color: AppColor.black),
            ))
      ],
    );
  }
}
