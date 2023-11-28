// import 'package:device_preview/device_preview.dart';

import 'package:eums/common/routing.dart';
import 'package:eums/eum_app_offer_wall/notification_handler.dart';
import 'package:eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:eums/eum_app_offer_wall/widget/widget_animation_click_v2.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eums/common/const/values.dart';
import 'package:eums/common/local_store/local_store_service.dart';
import 'package:eums/eum_app_offer_wall/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:eums/eums_library.dart';
import 'package:intl/intl.dart';
import 'package:offerwall/widget_dialog_check_version.dart';

void main() async {
  await Eums.instant.initMaterial(
    home: const MyHomePage(),
    onRun: () async {
      // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    },
  );
}

@pragma("vm:entry-point")
void overlayMain() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
  //   statusBarColor: Colors.black,
  // ));

  await LocalStoreService.instant.init();
  // await NotificationHandler.instant.initializeFcmNotification();

  runApp(
    const MyAppOverlay(),
  );
}

class MyAppOverlay extends StatefulWidget {
  const MyAppOverlay({super.key});

  @override
  State<MyAppOverlay> createState() => _MyAppOverlayState();
}

class _MyAppOverlayState extends State<MyAppOverlay> {
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const TrueCallOverlay(),
      navigatorKey: globalKeyMainOverlay,
      // routes: {
      //   '/': (context) => const TrueCallOverlay(),
      // },
      builder: (context, child) {
        return Overlay(
          initialEntries: [
            OverlayEntry(builder: (context) => child ?? const SizedBox()),
          ],
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  // LocalStore localStore = LocalStoreService();
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;
  double deviceHeight(BuildContext context) => MediaQuery.of(context).size.height;
  @override
  void initState() {
    // checkOpenApp('initState');

    super.initState();

    WidgetsBinding.instance.addObserver(this);

    LocalStoreService.instant.preferences.setBool("isDebug", true);
  }

  setDeviceWidth() {
    LocalStoreService.instant.setDeviceWidth(deviceWidth(context));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    // LocalStoreService.instant.setDataShare(dataShare: null);
  }

  @override
  Widget build(BuildContext context) {
    setDeviceWidth();
    return MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc()..add(CheckSaveAccountLogged()),
          ),
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<AuthenticationBloc, AuthenticationState>(
              listenWhen: (previous, current) => previous.logoutStatus != current.logoutStatus,
              listener: (context, state) {
                if (state.logoutStatus == LogoutStatus.loading) {
                  return;
                }

                if (state.logoutStatus == LogoutStatus.finish) {
                  return;
                }
              },
            ),
          ],
          child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: const AppMainScreen(),
            // child: GetMaterialApp(
            //   key: Get.key,
            //   debugShowCheckedModeBanner: false,
            //   home: AppMainScreen(),
            // ),
          ),
        ));
  }
}

class AppMainScreen extends StatefulWidget {
  const AppMainScreen({Key? key}) : super(key: key);

  @override
  State<AppMainScreen> createState() => _AppMainScreenState();
}

class _AppMainScreenState extends State<AppMainScreen> {
  // LocalStore? localStore;

  TextEditingController textEditingController1 = TextEditingController();
  TextEditingController textEditingController2 = TextEditingController();
  TextEditingController textEditingController4 = TextEditingController();
  String dateTime = "2000-01-01";

  bool isShowCheckVersion = false;

  @override
  void initState() {
    // localStore = LocalStoreService();
    super.initState();

    if (kDebugMode) {
      textEditingController1.text = LocalStoreService.instant.preferences.getString("memId") ?? "abee997";
      textEditingController2.text = LocalStoreService.instant.preferences.getString("memGen") ?? "w";
      textEditingController4.text = LocalStoreService.instant.preferences.getString("memRegion") ?? "인천_서";
      dateTime = LocalStoreService.instant.preferences.getString("memBirth") ?? dateTime;
    } else {
      textEditingController1.text = LocalStoreService.instant.preferences.getString("memId") ?? "";
      textEditingController2.text = LocalStoreService.instant.preferences.getString("memGen") ?? "";
      textEditingController4.text = LocalStoreService.instant.preferences.getString("memRegion") ?? "";
      dateTime = LocalStoreService.instant.preferences.getString("memBirth") ?? dateTime;
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(minutes: 1),
      ));
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String versionCurrent = packageInfo.version;

      // remoteConfig.onConfigUpdated.listen((event) async {
      //   await remoteConfig.activate();
      //   final newVersion = remoteConfig.getString("version");

      //   debugPrint("check version ($isShowCheckVersion): $newVersion / $versionCurrent ");
      //   if (_checkNumberVersion(currentVersion: versionCurrent, newVersion: newVersion) == false && isShowCheckVersion == false) {
      //     isShowCheckVersion = true;
      //     // ignore: use_build_context_synchronously
      //     await WidgetDialogCheckVersion.show(context);
      //   }

      //   // Use the new config values here.
      // });
      await remoteConfig.fetchAndActivate();
      final newVersion = remoteConfig.getString("version");

      if (newVersion.isNotEmpty == true) {
        debugPrint("check version : $newVersion / $versionCurrent ");
        if (_checkNumberVersion(currentVersion: versionCurrent, newVersion: newVersion) == false && isShowCheckVersion == false) {
          isShowCheckVersion = true;
          // ignore: use_build_context_synchronously
          await WidgetDialogCheckVersion.show(
            context,
          );
        }
      }
    });
  }

  _checkNumberVersion({required String newVersion, required String currentVersion}) {
    List<int> versionCurrent = currentVersion.split(".").map((e) => int.parse(e.toString())).toList();
    List<int> versionNew = newVersion.split(".").map((e) => int.parse(e.toString())).toList();

    if (versionCurrent[0] > versionNew[0]) {
      return true;
    } else {
      if (versionCurrent[1] > versionNew[1]) {
        return true;
      } else {
        if (versionCurrent[2] > versionNew[2]) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  void dispose() {
    isShowCheckVersion = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return FutureBuilder<Widget>(
    //   future: EumsAppOfferWallService.instance.openSdkTest(context, memId: "abee997", memGen: "w", memBirth: "2000-01-01", memRegion: "인천_서"),
    //   builder: (context, snapshot) => snapshot.data ?? const SizedBox(),
    // );
    return Scaffold(
      // key: globalKeyMain,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("memId:", style: TextStyle(fontWeight: FontWeight.w700)),
            TextField(
              controller: textEditingController1,
            ),
            const SizedBox(
              height: 16,
            ),
            const Text("memGen:", style: TextStyle(fontWeight: FontWeight.w700)),
            TextField(
              controller: textEditingController2,
            ),
            const SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.parse(dateTime),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2025),
                );
                if (picked != null) {
                  dateTime = DateFormat('yyyy-MM-dd').format(picked);
                  setState(() {});
                }
              },
              child: Column(
                children: [
                  const Text("memBirth:", style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    dateTime,
                    style: const TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            const Text("memRegion:", style: TextStyle(fontWeight: FontWeight.w700)),
            TextField(
              controller: textEditingController4,
            ),
            const SizedBox(
              height: 16,
            ),
            WidgetAnimationClickV2(
              color: AppColor.blue1,
              padding: const EdgeInsets.all(20),
              onTap: () async {
                if (textEditingController1.text.isEmpty == true ||
                    textEditingController2.text.isEmpty == true ||
                    textEditingController4.text.isEmpty == true) {
                  return;
                }
                LocalStoreService.instant.preferences.setString("memId", textEditingController1.text);
                LocalStoreService.instant.preferences.setString("memGen", textEditingController2.text);
                LocalStoreService.instant.preferences.setString("memBirth", dateTime);
                LocalStoreService.instant.preferences.setString("memRegion", textEditingController4.text);
                // await LocalStoreService.instant.setDataShare(dataShare: null);
                // ignore: use_build_context_synchronously
                final child = await EumsAppOfferWallService.instance.openSdkTest(context,
                    memId: textEditingController1.text,
                    memGen: textEditingController2.text,
                    memBirth: dateTime,
                    memRegion: textEditingController4.text);
                Routings().navigate(context, child);
              },
              child: const Text('go to sdk'),
            ),
          ],
        ),
      ),
    );
  }
}
