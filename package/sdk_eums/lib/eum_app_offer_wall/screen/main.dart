import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:sdk_eums/eum_app_offer_wall/bloc/push_notification_service/push_notification_service.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/accumulate_money_module/accumulate_money_screen.dart';
import 'package:sdk_eums/sdk_eums_library.dart';

import '../../common/local_store/local_store.dart';
import '../../common/local_store/local_store_service.dart';
import '../bloc/authentication_bloc/authentication_bloc.dart';

// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) {
//   try {
//     service.on('showOverlay').listen((event) async {
//       bool isActive = await FlutterOverlayWindow.isActive();
//       if (isActive == true) {
//         await FlutterOverlayWindow.closeOverlay();
//         await Future.delayed(const Duration(milliseconds: 200));
//       }

//       if (event?['data'] != null && event?['data']['isWebView'] != null) {
//         print('showWebView');
//         await FlutterOverlayWindow.showOverlay();
//         await FlutterOverlayWindow.shareData(event?['data']);
//       } else {
//         print('showOverlay123123123');
//         try {
//           await FlutterOverlayWindow.showOverlay(
//               enableDrag: true,
//               height: 300,
//               width: 300,
//               alignment: OverlayAlignment.center);
//           await FlutterOverlayWindow.shareData(event?['data']);
//           print("vao day khong");
//         } catch (e) {
//           print("errrrrr$e");
//         }
//       }
//       print('showOverlay123$isActive');
//     });

//     service.on('setAppTokenBg').listen((event) {
//       print('setAppTokenBg $event');
//       LocalStoreService().setAccessToken(event?['token']);
//     });
//   } catch (e) {
//     print(e);
//   }
// }

void mainSdk() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyhomePage(),
  ));
}

class MyhomePage extends StatefulWidget {
  const MyhomePage({Key? key}) : super(key: key);

  @override
  State<MyhomePage> createState() => _MyhomePageState();
}

class _MyhomePageState extends State<MyhomePage> {
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;

  @override
  void initState() {
    // TODO: implement initState
    checkPermission();
    super.initState();
  }

  checkPermission() async {
    final bool status = await FlutterOverlayWindow.isPermissionGranted();
    if (!status) {
      await FlutterOverlayWindow.requestPermission();
    } else {}
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<LocalStore>(
              create: (context) => LocalStoreService()),
          RepositoryProvider<EumsOfferWallService>(
              create: (context) => EumsOfferWallServiceApi())
        ],
        child: MultiBlocProvider(
            providers: [
              BlocProvider<AuthenticationBloc>(
                create: (context) =>
                    AuthenticationBloc()..add(CheckSaveAccountLogged()),
              ),
              // BlocProvider<PushNotificationServiceBloc>(
              //   create: (context) => PushNotificationServiceBloc(),
              // ),
            ],
            child: MultiBlocListener(
              listeners: [
                BlocListener<AuthenticationBloc, AuthenticationState>(
                  listenWhen: (previous, current) =>
                      previous.logoutStatus != current.logoutStatus,
                  listener: (context, state) {
                    if (state.logoutStatus == LogoutStatus.loading) {
                      return;
                    }
                    if (state.logoutStatus == LogoutStatus.finish) {
                      // EasyLoading.dismiss();
                      return;
                    }
                  },
                ),
              ],
              child: GestureDetector(
                onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                child: WillPopScope(
                  onWillPop: () async {
                    return true;
                  },
                  child: MaterialApp(
                    debugShowCheckedModeBanner: false,
                    home: Scaffold(
                      appBar: AppBar(),
                      body: AccumulateMoneyScreen(),
                    ),
                    builder: EasyLoading.init(builder: (context, child) {
                      return child ?? const SizedBox.shrink();
                    }),
                  ),
                ),
              ),
            )));
  }
}
