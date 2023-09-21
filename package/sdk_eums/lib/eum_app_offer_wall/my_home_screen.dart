import 'dart:async';
import 'dart:io';

import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:sdk_eums/common/events/rx_events.dart';
import 'package:sdk_eums/common/local_store/local_store_service.dart';
import 'package:sdk_eums/common/rx_bus.dart';
import 'package:sdk_eums/eum_app_offer_wall/notification_handler.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/accumulate_money_module/accumulate_money_screen.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/asked_question_module/asked_question_screen.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/home_module/home_page.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/link_addvertising_module/link_addvertising_screen.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/request_module/request_screen.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/reward_guide_module/reward_guide_screen.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/using_term_module/using_term_screen.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:sdk_eums/gen/assets.gen.dart';

import '../common/local_store/local_store.dart';
import '../common/routing.dart';
import 'bloc/authentication_bloc/authentication_bloc.dart';
import 'screen/my_page_module/my_page.dart';

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({Key? key}) : super(key: key);

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  bool showAction = false;
  Timer? timer;
  dynamic dataUser;

  Future<void> _registerEventBus() async {
    RxBus.register<ShowAction>().listen((event) {
      if (showAction) {
        setState(() {
          showAction = false;
        });
      }
    });
  }

  void _unregisterEventBus() {
    RxBus.destroy();
  }

  // Future<void> initPlatformState() async {
  //   // Configure BackgroundFetch.
  //   int status = await BackgroundFetch.configure(
  //       BackgroundFetchConfig(
  //           minimumFetchInterval: 1,
  //           stopOnTerminate: false,
  //           enableHeadless: true,
  //           requiresBatteryNotLow: false,
  //           requiresCharging: false,
  //           requiresStorageNotLow: false,
  //           requiresDeviceIdle: false,
  //           requiredNetworkType: NetworkType.NONE), (String taskId) async {
  //     print("[BackgroundFetch] Event received $taskId");
  //     setState(() {});

  //     BackgroundFetch.finish(taskId);
  //   }, (String taskId) async {
  //     print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
  //     BackgroundFetch.finish(taskId);
  //   });
  //   if (status == BackgroundFetch.STATUS_AVAILABLE) {
  //     startTimeDown();
  //     print('[BackgroundFetch] configure success: $status');
  //   }

  //   setState(() {});

  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;
  // }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    _registerEventBus();
    _determinePosition();
    super.initState();
    if (Platform.isAndroid) {
      settingBattery();
    }

    NotificationHandler()
        .didReceiveLocalNotificationStream
        .stream
        .listen((ReceivedNotification receivedNotification) async {});

    NotificationHandler()
        .selectNotificationStream
        .stream
        .listen((String? payload) async {});
  }

  getBatteryOptimization() async {
    await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
    bool? isBatteryOptimizationDisabled =
        await DisableBatteryOptimization.isBatteryOptimizationDisabled;
    return isBatteryOptimizationDisabled;
  }

  settingBattery() async {
    if (Platform.isAndroid) {
      bool? isBatteryOptimizationDisabled = await getBatteryOptimization();
      if (isBatteryOptimizationDisabled == null ||
          !isBatteryOptimizationDisabled) {
        timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
          bool? isBatteryOptimizationDisabled = await getBatteryOptimization();
          if (isBatteryOptimizationDisabled != null &&
              !!isBatteryOptimizationDisabled) {
            timer.cancel();
          }
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant MyHomeScreen oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _unregisterEventBus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<LocalStore>(
            create: (context) => LocalStoreService()),
        RepositoryProvider<EumsOfferWallService>(
            create: (context) => EumsOfferWallServiceApi()),
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
          // BlocProvider<SettingBloc>(
          //     create: (context) => SettingBloc()..add(InfoUser())),
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<AuthenticationBloc, AuthenticationState>(
              listenWhen: (previous, current) =>
                  previous.logoutStatus != current.logoutStatus,
              listener: (context, state) {
                if (state.logoutStatus == LogoutStatus.loading) {
                  // EasyLoading.show();
                  return;
                }

                if (state.logoutStatus == LogoutStatus.finish) {
                  // EasyLoading.dismiss();
                  return;
                }
              },
            ),
          ],
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: AppColor.white,
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColor.black,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Image.asset(
                    Assets.logo_eums.path,
                    package: "sdk_eums",
                  ),
                ),
                SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 14),
                  child: Text('리워드',
                      style: AppStyle.bold
                          .copyWith(color: AppColor.black, fontSize: 18)),
                ),
                SizedBox(width: 90),
                InkWell(
                  onTap: () {
                    Routing().navigate(context, MyPage());
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Image.asset(Assets.my_page.path,
                        package: "sdk_eums", height: 24),
                  ),
                ),
                const SizedBox(
                  width: 25,
                )
              ],
            ),
            body: Stack(
              children: [
                MyHomePagePage2(),
                !showAction
                    ? const SizedBox()
                    : Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Image.asset(Assets.polygon.path,
                                      package: "sdk_eums",
                                      color: AppColor.grey.withOpacity(0.5),
                                      width: 30,
                                      height: 15)),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColor.white,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Wrap(
                                  children: List.generate(
                                      action.length,
                                      (index) => GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                showAction = false;
                                              });
                                              switch (index) {
                                                case 0:
                                                  Routing().navigate(
                                                      context, RequestScreen());
                                                  break;
                                                case 1:
                                                  Routing().navigate(context,
                                                      AskedQuestionScreen());
                                                  break;
                                                case 2:
                                                  Routing().navigate(context,
                                                      LinkAddvertisingScreen());
                                                  break;
                                                case 3:
                                                  Routing().navigate(context,
                                                      RewardGuideScreen());
                                                  break;
                                                case 4:
                                                  Routing().navigate(context,
                                                      UsingTermScreen());
                                                  break;
                                                default:
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              decoration: const BoxDecoration(
                                                  border: Border(
                                                      bottom: BorderSide(
                                                          color: AppColor
                                                              .colorC9))),
                                              child: Text(
                                                action[index],
                                                style: AppStyle.medium
                                                    .copyWith(fontSize: 18),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          )),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home: ,

    // );
  }
}

class MyHomePagePage2 extends StatefulWidget {
  const MyHomePagePage2({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePagePage2> createState() => _MyHomePagePage2State();
}

class _MyHomePagePage2State extends State<MyHomePagePage2>
    with WidgetsBindingObserver {
  Timer? _timer;
  int _start = 10;

  @override
  void initState() {
    _registerEventBus();
    if (Platform.isAndroid) {
      // checkPermission();
    }
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _registerEventBus() async {}

  void _unregisterEventBus() {}

  @override
  void dispose() {
    _unregisterEventBus();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<LocalStore>(
            create: (context) => LocalStoreService()),
        RepositoryProvider<EumsOfferWallService>(
            create: (context) => EumsOfferWallServiceApi()),
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
            // BlocProvider<SettingBloc>(
            //     create: (context) => SettingBloc()..add(InfoUser())),
          ],
          child: MultiBlocListener(
            listeners: [
              BlocListener<AuthenticationBloc, AuthenticationState>(
                listenWhen: (previous, current) =>
                    previous.logoutStatus != current.logoutStatus,
                listener: (context, state) {
                  if (state.logoutStatus == LogoutStatus.loading) {
                    // EasyLoading.show();
                    return;
                  }

                  if (state.logoutStatus == LogoutStatus.finish) {
                    // EasyLoading.dismiss();
                    return;
                  }
                },
              ),
            ],
            child: const HomePage(),
          )),
    );
  }
}
