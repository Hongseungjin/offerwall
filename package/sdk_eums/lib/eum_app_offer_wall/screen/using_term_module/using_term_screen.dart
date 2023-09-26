import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appStyle.dart';

import 'bloc/using_term_bloc.dart';

class UsingTermScreen extends StatefulWidget {
  const UsingTermScreen({Key? key}) : super(key: key);

  @override
  State<UsingTermScreen> createState() => _UsingTermScreenState();
}

class _UsingTermScreenState extends State<UsingTermScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<UsingTermnBloc>(
      create: (context) => UsingTermnBloc()..add(UsingTerm()),
      child: BlocListener<UsingTermnBloc, UsingTermState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: _listenFetchData,
        child: BlocBuilder<UsingTermnBloc, UsingTermState>(
          builder: (context, state) {
            return _buildContent(context, state.dataUsingTerm);
          },
        ),
      ),
    );
  }

  void _listenFetchData(BuildContext context, UsingTermState state) {
    if (state.status == UsingTermStatus.loading) {
      // EasyLoading.show();
      return;
    }
    if (state.status == UsingTermStatus.failure) {
      // EasyLoading.dismiss();
      // AppAlert.showError(
      //     fToast,
      //     state.error != null
      //         ? state.error!.message != null
      //             ? state.error!.message!
      //             : 'Error!'
      //         : 'Error!');
      return;
    }
    if (state.status == UsingTermStatus.success) {
      // EasyLoading.dismiss();
    }
  }

  Scaffold _buildContent(BuildContext context, dynamic dataUsingTerm) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        leading: InkWell(
          onTap: () {
            Navigator.maybePop(context);
          },
          child:
              const Icon(Icons.arrow_back_ios_outlined, color: AppColor.black),
        ),
        centerTitle: true,
        title: Text(
          '서비스 이용약관',
          style: AppStyle.bold.copyWith(color: AppColor.black),
        ),
      ),
      body: dataUsingTerm != null
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: HtmlWidget(
                  dataUsingTerm[0]['content'],
                  customStylesBuilder: (e) {
                    if (e.classes.contains('ql-align-center')) {
                      return {'text-align': 'center'};
                    }

                    return null;
                  },
                ),
              ),
            )
          : const SizedBox(),
    );
  }
}
