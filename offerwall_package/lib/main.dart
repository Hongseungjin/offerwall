// // import 'package:device_preview/device_preview.dart';
// import 'package:eums/common/routing.dart';
// import 'package:eums/eum_app_offer_wall/utils/appColor.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:eums/common/const/values.dart';
// import 'package:eums/common/local_store/local_store_service.dart';
// import 'package:eums/eum_app_offer_wall/bloc/authentication_bloc/authentication_bloc.dart';
// import 'package:eums/eums_library.dart';
// import 'package:intl/intl.dart';

// void main() async {
//   // SdkEums.instant.init(onRun: () async {
//   //   await Firebase.initializeApp();

//   //   NotificationHandler.instant.initializeFcmNotification();

//   //   runApp(MaterialApp(
//   //     debugShowCheckedModeBanner: false,
//   //     // home: MyHomePage(),
//   //     home: DevicePreview(
//   //       // child: ,
//   //       enabled: false,
//   //       // tools: [
//   //       //   ...DevicePreview.defaultTools,
//   //       //   // const CustomPlugin(),
//   //       // ],
//   //       builder: (context) => const MyHomePage(),
//   //     ),
//   //   ));
//   // });
//   await Eums.instant.initMaterial(home: const MyHomePage());

//   // runApp(const MaterialApp(
//   //   debugShowCheckedModeBanner: false,
//   //   home: MyHomePage(),
//   // ));
// }

// @pragma("vm:entry-point")
// void overlayMain() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
//   //   statusBarColor: Colors.black,
//   // ));

//   await LocalStoreService.instant.init();

//   runApp(
//     const MyAppOverlay(),
//   );
// }

// class MyAppOverlay extends StatefulWidget {
//   const MyAppOverlay({super.key});

//   @override
//   State<MyAppOverlay> createState() => _MyAppOverlayState();
// }

// class _MyAppOverlayState extends State<MyAppOverlay> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       key: globalKeyMainOverlay,
//       debugShowCheckedModeBanner: false,
//       home: const TrueCallOverlay(),
//       // routes: {
//       //   '/': (context) => const TrueCallOverlay(),
//       // },
//       builder: (context, child) {
//         return Overlay(
//           initialEntries: [
//             OverlayEntry(builder: (context) => child ?? const SizedBox()),
//           ],
//         );
//       },
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
//   // LocalStore localStore = LocalStoreService();
//   double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;
//   double deviceHeight(BuildContext context) => MediaQuery.of(context).size.height;
//   @override
//   void initState() {
//     // checkOpenApp('initState');

//     super.initState();

//     WidgetsBinding.instance.addObserver(this);
//   }

//   setDeviceWidth() {
//     LocalStoreService.instant.setDeviceWidth(deviceWidth(context));
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//     LocalStoreService.instant.setDataShare(dataShare: null);
//   }

//   @override
//   Widget build(BuildContext context) {
//     setDeviceWidth();
//     return MultiBlocProvider(
//         providers: [
//           BlocProvider<AuthenticationBloc>(
//             create: (context) => AuthenticationBloc()..add(CheckSaveAccountLogged()),
//           ),
//         ],
//         child: MultiBlocListener(
//           listeners: [
//             BlocListener<AuthenticationBloc, AuthenticationState>(
//               listenWhen: (previous, current) => previous.logoutStatus != current.logoutStatus,
//               listener: (context, state) {
//                 if (state.logoutStatus == LogoutStatus.loading) {
//                   return;
//                 }

//                 if (state.logoutStatus == LogoutStatus.finish) {
//                   return;
//                 }
//               },
//             ),
//           ],
//           child: GestureDetector(
//             onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
//             child: const AppMainScreen(),
//             // child: GetMaterialApp(
//             //   key: Get.key,
//             //   debugShowCheckedModeBanner: false,
//             //   home: AppMainScreen(),
//             // ),
//           ),
//         ));
//   }
// }

// class AppMainScreen extends StatefulWidget {
//   const AppMainScreen({Key? key}) : super(key: key);

//   @override
//   State<AppMainScreen> createState() => _AppMainScreenState();
// }

// class _AppMainScreenState extends State<AppMainScreen> {
//   // LocalStore? localStore;

//   TextEditingController textEditingController1 = TextEditingController();
//   TextEditingController textEditingController2 = TextEditingController();
//   TextEditingController textEditingController4 = TextEditingController();
//   String dateTime = "2000-01-01";

//   @override
//   void initState() {
//     // localStore = LocalStoreService();
//     super.initState();

//     textEditingController1.text = LocalStoreService.instant.preferences.getString("memId") ?? "abee997";
//     textEditingController2.text = LocalStoreService.instant.preferences.getString("memGen") ?? "w";
//     textEditingController4.text = LocalStoreService.instant.preferences.getString("memRegion") ?? "인천_서";
//     dateTime = LocalStoreService.instant.preferences.getString("memBirth") ?? dateTime;
//   }

//   @override
//   Widget build(BuildContext context) {
//     // return FutureBuilder<Widget>(
//     //   future: EumsAppOfferWallService.instance.openSdkTest(context, memId: "abee997", memGen: "w", memBirth: "2000-01-01", memRegion: "인천_서"),
//     //   builder: (context, snapshot) => snapshot.data ?? const SizedBox(),
//     // );
//     return Scaffold(
//       // key: globalKeyMain,
//       appBar: AppBar(),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("memId:", style: TextStyle(fontWeight: FontWeight.w700)),
//             TextField(
//               controller: textEditingController1,
//             ),
//             const SizedBox(
//               height: 16,
//             ),
//             const Text("memGen:", style: TextStyle(fontWeight: FontWeight.w700)),
//             TextField(
//               controller: textEditingController2,
//             ),
//             const SizedBox(
//               height: 16,
//             ),
//             GestureDetector(
//               onTap: () async {
//                 final picked = await showDatePicker(
//                   context: context,
//                   initialDate: DateTime.parse(dateTime),
//                   firstDate: DateTime(2000),
//                   lastDate: DateTime(2025),
//                 );
//                 if (picked != null) {
//                   dateTime = DateFormat('yyyy-MM-dd').format(picked);
//                   setState(() {});
//                 }
//               },
//               child: Column(
//                 children: [
//                   const Text("memBirth:", style: TextStyle(fontWeight: FontWeight.w700)),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   Text(
//                     dateTime,
//                     style: const TextStyle(color: Colors.blue),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(
//               height: 16,
//             ),
//             const Text("memRegion:", style: TextStyle(fontWeight: FontWeight.w700)),
//             TextField(
//               controller: textEditingController4,
//             ),
//             const SizedBox(
//               height: 16,
//             ),
//             InkWell(
//               onTap: () async {
//                 LocalStoreService.instant.preferences.setString("memId", textEditingController1.text);
//                 LocalStoreService.instant.preferences.setString("memGen", textEditingController2.text);
//                 LocalStoreService.instant.preferences.setString("memBirth", dateTime);
//                 LocalStoreService.instant.preferences.setString("memRegion", textEditingController4.text);
//                 await LocalStoreService.instant.setDataShare(dataShare: null);
//                 // ignore: use_build_context_synchronously
//                 final child = await EumsAppOfferWallService.instance.openSdkTest(context,
//                     memId: textEditingController1.text,
//                     memGen: textEditingController2.text,
//                     memBirth: dateTime,
//                     memRegion: textEditingController4.text);
//                 Routings().navigate(context, child);
//               },
//               child: Container(color: AppColor.blue1, padding: const EdgeInsets.all(20), child: const Text('go to sdk')),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // class MyHomePage extends StatefulWidget {
// //   const MyHomePage({super.key});

// //   @override
// //   State<MyHomePage> createState() => _MyHomePageState();
// // }

// // class _MyHomePageState extends State<MyHomePage> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return const Placeholder();
// //   }
// // }







// import 'package:device_preview/device_preview.dart';
import 'package:eums/common/method_native/host_handle.dart';
import 'package:eums/eum_app_offer_wall/eums_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eums/common/const/values.dart';
import 'package:eums/common/local_store/local_store_service.dart';
import 'package:eums/eum_app_offer_wall/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:eums/eums_library.dart';

void main() async {
  await Eums.instant.initMaterial(home: const MyHomePage());
}

@pragma("vm:entry-point")
void overlayMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStoreService.instant.init();

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
  Widget build(BuildContext context) {
    return MaterialApp(
      key: globalKeyMainOverlay,
      debugShowCheckedModeBanner: false,
      home: const TrueCallOverlay(),
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
  }

  setDeviceWidth() {
    LocalStoreService.instant.setDeviceWidth(deviceWidth(context));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    LocalStoreService.instant.setDataShare(dataShare: null);
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
  // late LocalStore localStore;

  ValueNotifier<bool> showMain = ValueNotifier(false);

  @override
  void initState() {
    // localStore = LocalStoreService();

    super.initState();
    print("=>>>>>>>>>>> AppMainScreen");

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      print("Token->>>>: xxxxx");

      final token = LocalStoreService.instant.getAccessToken();
      print("Token->>>>: $token");
      if (token.isNotEmpty == true) {
        await FlutterBackgroundService().configure(
            iosConfiguration: IosConfiguration(),
            androidConfiguration: AndroidConfiguration(
                onStart: onStart,
                autoStart: false,
                isForegroundMode: true,
                initialNotificationTitle: "인천e음",
                initialNotificationContent: "eum 캐시 혜택 서비스가 실행중입니다"));

        showMain.value = true;
      } else {
        FlutterOfferWallApi.setup(FlutterOfferWallApiHandler((dataOfferWall) async {
          print("aaaaaa ${dataOfferWall.encode()}");
          await LocalStoreService.instant.preferences.setString(LocalStoreService.instant.firebaseKey, dataOfferWall.firebaseKey ?? '');
          dynamic data = await EumsOfferWallService.instance.authConnect(
              memBirth: dataOfferWall.memBirth, memGen: dataOfferWall.memGen, memRegion: dataOfferWall.memRegion, memId: dataOfferWall.memId);
          await LocalStoreService.instant.setAccessToken(data['token']);
          await FlutterBackgroundService().configure(
              iosConfiguration: IosConfiguration(),
              androidConfiguration: AndroidConfiguration(
                  onStart: onStart,
                  autoStart: false,
                  isForegroundMode: true,
                  initialNotificationTitle: "인천e음",
                  initialNotificationContent: "eum 캐시 혜택 서비스가 실행중입니다"));

          showMain.value = true;
        }));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("=>>>>>>>>>>> AppMainScreen - build");

    return ValueListenableBuilder<bool>(
      valueListenable: showMain,
      builder: (context, value, child) {
        if (value == true) {
          return FutureBuilder<Widget>(
            future: EumsAppOfferWallService.instance.openSdk(context),
            builder: (context, snapshot) => snapshot.data ?? const SizedBox(),
          );
        }
        return const SizedBox();
      },
    );

    // return Scaffold(
    //   key: globalKeyMain,
    //   appBar: AppBar(),
    //   body: Column(
    //     children: [
    //       InkWell(
    //         onTap: () async {
    //           await localStore?.setDataShare(dataShare: null);
    //           // ignore: use_build_context_synchronously
    //           EumsAppOfferWallService.instance.openSdk(context, memId: "abee997", memGen: "w", memBirth: "2000-01-01", memRegion: "인천_서");
    //         },
    //         child: Container(color: AppColor.blue1, padding: const EdgeInsets.all(20), child: const Text('go to sdk')),
    //       ),
    //     ],
    //   ),
    // );
  }
}




