// // ignore_for_file: unrelated_type_equality_checks

// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// // import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:eums/common/local_store/local_store.dart';
// import 'package:eums/common/local_store/local_store_service.dart';
// import 'package:eums/common/routing.dart';
// import 'package:eums/common/rx_bus.dart';
// import 'package:eums/eum_app_offer_wall/utils/loading_dialog.dart';
// import 'package:eums/eum_app_offer_wall/widget/app_alert.dart';
// import 'package:eums/eum_app_offer_wall/widget/custom_webview2.dart';
// import 'package:eums/gen/assets.gen.dart';

// import '../../../common/events/rx_events.dart';
// import '../../utils/appColor.dart';
// import '../../widget/custom_dialog.dart';
// import 'bloc/watch_adver_bloc.dart';

// class WatchAdverScreen extends StatefulWidget {
//   const WatchAdverScreen({Key? key, this.data, this.backOverlay}) : super(key: key);

//   final dynamic data;
//   final Function()? backOverlay;

//   @override
//   State<WatchAdverScreen> createState() => _WatchAdverScreenState();
// }

// class _WatchAdverScreenState extends State<WatchAdverScreen> {
//   final GlobalKey<State<StatefulWidget>> globalKey = GlobalKey<State<StatefulWidget>>();
//   FToast fToast = FToast();
//   LocalStore? localStorel;

//   final _key = UniqueKey();

//   @override
//   void initState() {
//     print("asdkalsdk${widget.data}");
//     localStorel = LocalStoreService();
//     fToast.init(context);
//     super.initState();
//   }

//   @override
//   void dispose() async {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider<WatchAdverBloc>(
//       create: (context) => WatchAdverBloc(),
//       // ..add(WatchAdver(id: 'abeetest')),
//       child: MultiBlocListener(listeners: [
//         BlocListener<WatchAdverBloc, WatchAdverState>(listener: _listenFetchDataEarnPoint),
//         BlocListener<WatchAdverBloc, WatchAdverState>(
//             listenWhen: (previous, current) => previous.saveKeepAdverboxStatus != current.saveKeepAdverboxStatus, listener: _listenSave),
//         BlocListener<WatchAdverBloc, WatchAdverState>(
//             listenWhen: (previous, current) => previous.deleteScrapStatus != current.deleteScrapStatus, listener: _listenDelete)
//       ], child: _buidlContent(context)),
//     );
//   }

//   void _listenFetchDataEarnPoint(BuildContext context, WatchAdverState state) async {
//     if (state.earnMoneyStatus == EarnMoneyStatus.loading) {
//       LoadingDialog.instance.show();
//       return;
//     }
//     if (state.earnMoneyStatus == EarnMoneyStatus.failure) {
//       LoadingDialog.instance.hide();
//       return;
//     }
//     if (state.earnMoneyStatus == EarnMoneyStatus.success) {
//       LoadingDialog.instance.hide();
//       if (Platform.isIOS) {
//         RxBus.post(UpdateUser());
//         Navigator.of(context).pop();
//       }
//       if (Platform.isAndroid) {
//         // FlutterBackgroundService().invoke("closeOverlay");
//         RxBus.post(UpdateUser());
//         // await Restart.restartApp();
//       }
//     }
//   }

//   void _listenDelete(BuildContext context, WatchAdverState state) {
//     if (state.deleteScrapStatus == DeleteScrapStatus.loading) {
//       LoadingDialog.instance.show();
//       return;
//     }
//     if (state.deleteScrapStatus == DeleteScrapStatus.failure) {
//       LoadingDialog.instance.hide();
//       return;
//     }
//     if (state.deleteScrapStatus == DeleteScrapStatus.success) {
//       LoadingDialog.instance.hide();
//       AppAlert.showSuccess(
//         context,
//         fToast,
//         'Delete success!',
//       );
//     }
//   }

//   void _listenSave(BuildContext context, WatchAdverState state) {
//     if (state.saveKeepAdverboxStatus == SaveKeepAdverboxStatus.loading) {
//       LoadingDialog.instance.show();
//       return;
//     }
//     if (state.saveKeepAdverboxStatus == SaveKeepAdverboxStatus.failure) {
//       LoadingDialog.instance.hide();
//       return;
//     }
//     if (state.saveKeepAdverboxStatus == SaveKeepAdverboxStatus.success) {
//       LoadingDialog.instance.hide();
//       AppAlert.showSuccess(
//         context,
//         fToast,
//         'Save success!',
//       );
//     }
//   }

//   bool checkSave = false;
//   double deviceWidth = 0;

//   _buidlContent(BuildContext context) {
//     try {
//       return WillPopScope(
//         onWillPop: () async {
//           // RxBus.post(
//           //   BackToTab(tab: widget.tab),
//           // );
//           return false;
//         },
//         child: Scaffold(
//           key: globalKey,
//           body: CustomWebView2(
//             showImage: true,
//             showMission: true,
//             paddingTop: 0,
//             deviceWidth: deviceWidth,
//             bookmark: InkWell(
//               onTap: () {
//                 setState(() {
//                   checkSave = !checkSave;
//                 });
//                 if (checkSave) {
//                   globalKey.currentContext?.read<WatchAdverBloc>().add(SaveAdver(advertise_idx: jsonDecode(widget.data)['idx']));
//                 } else {
//                   print('widget.data ${widget.data}');
//                   globalKey.currentContext?.read<WatchAdverBloc>().add(DeleteScrap(id: jsonDecode(widget.data)['idx']));
//                 }
//               },
//               child: Image.asset(checkSave ? Assets.bookmarkWhite.path : Assets.bookmark.path, package: "eums", height: 27, color: AppColor.black),
//             ),
//             onSave: () {
//               print(checkSave);
//             },
//             mission: () async {
//               localStorel!.setDataShare(dataShare: null);
//               DialogUtils.showDialogRewardPoint(context, data: jsonDecode(widget.data), voidCallback: () async {
//                 print("vao day");

//                 globalKey.currentContext
//                     ?.read<WatchAdverBloc>()
//                     .add(EarnPoin(advertise_idx: jsonDecode(widget.data)['idx'], pointType: jsonDecode(widget.data)['typePoint']));
//               });
//             },
//             urlLink: jsonDecode(widget.data)['url_link'],
//             onClose: () {
//               Routings().popToRoot(context);
//             },
//           ),
//         ),
//       );
//     } catch (ex) {
//       print("exxxxx$ex");
//       return InkWell(
//         // behavior: HitTestBehavior.translucent,
//         onTap: () {
//           Routings().popToRoot(context);
//           checkBack();
//           // FlutterOverlayWindow.closeOverlay();
//           // FlutterOverlayWindow.closeOverlay();
//         },
//         child: const Scaffold(
//           body: Text(
//             "ERROR",
//             style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.red),
//           ),
//         ),
//       );
//     }
//   }

//   checkBack() {
//     // Routing().popToRoot(context);

//     Future.delayed(const Duration(milliseconds: 450), () async {
//       // FlutterBackgroundService().invoke("closeOverlay");

//       // await FlutterOverlayWindow.closeOverlay();
//       // await FlutterOverlayWindow.closeOverlay();
//       // print("vafo day khong em");
//       // // FlutterOverlayWindow.closeOverlay();
//     });
//   }
// }
