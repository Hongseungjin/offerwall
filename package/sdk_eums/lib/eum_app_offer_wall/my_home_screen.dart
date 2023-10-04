import 'dart:async';
import 'dart:io';

import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/instance_manager.dart';
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
import 'package:sdk_eums/eum_app_offer_wall/widget/setting_fontsize.dart';
import 'package:sdk_eums/gen/assets.gen.dart';

import '../common/local_store/local_store.dart';
import '../common/routing.dart';
import 'bloc/authentication_bloc/authentication_bloc.dart';

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

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  SettingFontSize controllerGet = Get.put(SettingFontSize());

  @override
  void initState() {
    _registerEventBus();
    _determinePosition();
    SettingFontSize().initSetingFontSize(controllerGet);
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
                  return;
                }
              },
            ),
          ],
          child: Scaffold(
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
                                      (index) => InkWell(
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
  @override
  void initState() {
    if (Platform.isAndroid) {
      // checkPermission();
    }
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
