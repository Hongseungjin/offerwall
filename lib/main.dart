// import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sdk_eums/common/const/values.dart';
import 'package:sdk_eums/common/local_store/local_store.dart';
import 'package:sdk_eums/common/local_store/local_store_service.dart';
import 'package:sdk_eums/eum_app_offer_wall/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:sdk_eums/eum_app_offer_wall/notification_handler.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/sdk_eums_library.dart';

void main() {
  SdkEums.instant.init(onRun: () async {
    await Firebase.initializeApp();

    NotificationHandler().initializeFcmNotification();

    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
      // home: DevicePreview(
      //   enabled: true,
      //   // tools: [
      //   //   ...DevicePreview.defaultTools,
      //   //   // const CustomPlugin(),
      //   // ],
      //   builder: (context) => const MyHomePage(),
      // ),
    ));
  });
}

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    statusBarColor: Colors.transparent,
  ));

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TrueCallOverlay(),
    ),
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  LocalStore localStore = LocalStoreService();
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;
  double deviceHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  @override
  void initState() {
    // checkOpenApp('initState');

    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  setDeviceWidth() {
    localStore.setDeviceWidth(deviceWidth(context));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    localStore.setDataShare(dataShare: null);
  }

  @override
  Widget build(BuildContext context) {
    setDeviceWidth();
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<LocalStore>(
            create: (context) => LocalStoreService()),
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
            child: GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              child: const MaterialApp(
                debugShowCheckedModeBanner: false,
                home: AppMainScreen(),
              ),
            ),
          )),
    );
  }
}

class AppMainScreen extends StatefulWidget {
  const AppMainScreen({Key? key}) : super(key: key);

  @override
  State<AppMainScreen> createState() => _AppMainScreenState();
}

class _AppMainScreenState extends State<AppMainScreen> {
  LocalStore? localStore;

  @override
  void initState() {
    localStore = LocalStoreService();
    super.initState();
    getSizeDevice();
  }

  getSizeDevice() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKeyMain,
      appBar: AppBar(),
      body: Column(
        children: [
          InkWell(
            onTap: () async {
              await localStore?.setDataShare(dataShare: null);
              EumsAppOfferWallService.instance.openSdk(context,
                  memId: "abee997",
                  memGen: "w",
                  memBirth: "2000-01-01",
                  memRegion: "인천_서");
            },
            child: Container(
                color: AppColor.blue1,
                padding: EdgeInsets.all(20),
                child: const Text('go to sdk')),
          ),
          InkWell(
            onTap: () async {},
            child: Container(
                color: AppColor.blue1,
                padding: EdgeInsets.all(20),
                child: const Text('go to sdk')),
          )
        ],
      ),
    );
  }
}
