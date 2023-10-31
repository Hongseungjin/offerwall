import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:eums/eum_app_offer_wall/lifecycale_event_handle.dart';
import 'package:eums/eums_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:eums/common/events/rx_events.dart';
import 'package:eums/common/local_store/local_store_service.dart';
import 'package:eums/common/rx_bus.dart';
import 'package:eums/eum_app_offer_wall/notification_handler.dart';
import 'package:eums/eum_app_offer_wall/screen/accumulate_money_module/accumulate_money_screen.dart';
import 'package:eums/eum_app_offer_wall/screen/asked_question_module/asked_question_screen.dart';
import 'package:eums/eum_app_offer_wall/screen/home_module/home_page.dart';
import 'package:eums/eum_app_offer_wall/screen/link_addvertising_module/link_addvertising_screen.dart';
import 'package:eums/eum_app_offer_wall/screen/request_module/request_screen.dart';
import 'package:eums/eum_app_offer_wall/screen/reward_guide_module/reward_guide_screen.dart';
import 'package:eums/eum_app_offer_wall/screen/using_term_module/using_term_screen.dart';
import 'package:eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:eums/eum_app_offer_wall/widget/setting_fontsize.dart';
import 'package:eums/gen/assets.gen.dart';
import 'package:permission_handler/permission_handler.dart';

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

  _permissionNotification() async {
    try {
      PermissionStatus? statusNotification = await Permission.notification.request();
      if (statusNotification == PermissionStatus.denied) {
        await AppSettings.openAppSettings(type: AppSettingsType.notification);
        // _permissionNotification();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // return Future.error('Location services are disabled.');
      await Geolocator.openLocationSettings();
      return _determinePosition();
      // return Future.error('Location services are disabled.');
    } else {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // return Future.error('Location permissions are denied');
          return _determinePosition();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return _determinePosition();
        // return Future.error('Location permissions are permanently denied, we cannot request permissions.');
      }
      return await Geolocator.getCurrentPosition();
    }
  }

  SettingFontSize controllerGet = Get.put(SettingFontSize());
  // LocalStore localStore = LocalStoreService();

  @override
  void initState() {
    _registerEventBus();
    _determinePosition().then((value) {
      _permissionNotification();
    });
    SettingFontSize().initSetingFontSize(controllerGet);

    NotificationHandler.instant.didReceiveLocalNotificationStream.stream.listen((ReceivedNotification receivedNotification) async {});

    NotificationHandler.instant.selectNotificationStream.stream.listen((String? payload) async {});
    print("======= MyHomeScreen init1 ======");
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Firebase.initializeApp();
      await LocalStoreService.instant.init();
      if (Platform.isAndroid) {
        settingBattery();
      }
      String? token = await NotificationHandler.instant.getToken();
      if (token != null) {
        await LocalStoreService.instant.setDeviceToken(token);
        // await EumsOfferWallServiceApi().createTokenNotifi(token: token);
      }
      print("TOKEN======> $token");
      FirebaseMessaging.instance.subscribeToTopic('eums');
    });
    WidgetsBinding.instance.addObserver(LifecycleEventHandler(resumeCallBack: () async {
      // _permissionNotification();
    }));
  }


  getBatteryOptimization() async {
    await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
    bool? isBatteryOptimizationDisabled = await DisableBatteryOptimization.isBatteryOptimizationDisabled;
    return isBatteryOptimizationDisabled;
  }

  settingBattery() async {
    if (Platform.isAndroid) {
      bool? isBatteryOptimizationDisabled = await getBatteryOptimization();
      if (isBatteryOptimizationDisabled == null || !isBatteryOptimizationDisabled) {
        timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
          bool? isBatteryOptimizationDisabled = await getBatteryOptimization();
          if (isBatteryOptimizationDisabled != null && !!isBatteryOptimizationDisabled) {
            timer.cancel();
          }
          // _checkPermissionLocationBackground();
        });
      } else {
        // _checkPermissionLocationBackground();
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
        // RepositoryProvider<LocalStore>(create: (context) => LocalStoreService()),
        RepositoryProvider<EumsOfferWallService>(create: (context) => EumsOfferWallServiceApi()),
      ],
      child: MultiBlocProvider(
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
          child: Scaffold(
            body: Stack(
              children: [
                const MyHomePagePage2(),
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
                                      package: "eums", color: AppColor.grey.withOpacity(0.5), width: 30, height: 15)),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColor.white,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3), // changes position of shadow
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
                                                  Routings().navigate(context, const RequestScreen());
                                                  break;
                                                case 1:
                                                  Routings().navigate(context, const AskedQuestionScreen());
                                                  break;
                                                case 2:
                                                  Routings().navigate(context, const LinkAddvertisingScreen());
                                                  break;
                                                case 3:
                                                  Routings().navigate(context, const RewardGuideScreen());
                                                  break;
                                                case 4:
                                                  Routings().navigate(context, const UsingTermScreen());
                                                  break;
                                                default:
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              width: MediaQuery.of(context).size.width,
                                              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColor.colorC9))),
                                              child: Text(
                                                action[index],
                                                style: AppStyle.medium.copyWith(fontSize: 18),
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

class _MyHomePagePage2State extends State<MyHomePagePage2> with WidgetsBindingObserver {
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
        // RepositoryProvider<LocalStore>(create: (context) => LocalStoreService()),
        RepositoryProvider<EumsOfferWallService>(create: (context) => EumsOfferWallServiceApi()),
      ],
      child: MultiBlocProvider(
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
            child: const HomePage(),
          )),
    );
  }
}
