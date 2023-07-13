

// void mainApp() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//       options: const FirebaseOptions(
//           apiKey: 'AIzaSyBkj46lMsOL6WABO5FzeTXTlppVognezoM',
//           appId: '1:739452302790:android:9fe699ead424427640aec7',
//           messagingSenderId: '739452302790',
//           projectId: 'e-ums-24291'));
//   SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);
//   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
//     statusBarColor: Colors.transparent,
//   ));
//   // EasyLoadingCustom.initConfigLoading();
//   runApp(MyHomePage());
// }

// overlay entry point
// @pragma("vm:entry-point")
// void overlayMain() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//       options: const FirebaseOptions(
//           apiKey: 'AIzaSyBkj46lMsOL6WABO5FzeTXTlppVognezoM',
//           appId: '1:739452302790:android:9fe699ead424427640aec7',
//           messagingSenderId: '739452302790',
//           projectId: 'e-ums-24291'));
//   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
//     statusBarColor: Colors.transparent,
//   ));
//   runApp(MaterialApp(
//       builder: EasyLoading.init(builder: (context, child) {
//         return child ?? const SizedBox.shrink();
//       }),
//       debugShowCheckedModeBanner: false,
//       home: TrueCallerOverlay()));
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
//   Timer? _timer;
//   int _start = 10;

//   @override
//   void initState() {
//     _registerEventBus();
//     checkPermission();

//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//   }

//   checkPermission() async {
//     final bool status = await FlutterOverlayWindow.isPermissionGranted();

//     if (!status) {
//       await FlutterOverlayWindow.requestPermission();
//     } else {}
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//   }

//   Future<void> _registerEventBus() async {
//     // RxBus.register<TestBus>().listen((event) {});

//     // RxBus.register<ShowDataAdver>(tag: Constants.showDataAdver)
//     //     .listen((event) {});
//   }

//   void _unregisterEventBus() {
//     RxBus.destroy();
//   }

//   @override
//   void dispose() {
//     _unregisterEventBus();
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: GestureDetector(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child: Icon(Icons.architecture),
//         ),
//       ),
//       body: MultiRepositoryProvider(
//         providers: [
//           RepositoryProvider<LocalStore>(
//               create: (context) => LocalStoreService()),
//           RepositoryProvider<EumsOfferWallService>(
//               create: (context) => EumsOfferWallServiceApi()),
//         ],
//         child: MultiBlocProvider(
//             providers: [
//               BlocProvider<AuthenticationBloc>(
//                 create: (context) =>
//                     AuthenticationBloc()..add(CheckSaveAccountLogged()),
//               ),
//               BlocProvider<PushNotificationServiceBloc>(
//                 create: (context) => PushNotificationServiceBloc(),
//               ),
//               // BlocProvider<SettingBloc>(
//               //     create: (context) => SettingBloc()..add(InfoUser())),
//             ],
//             child: MultiBlocListener(
//               listeners: [
//                 BlocListener<AuthenticationBloc, AuthenticationState>(
//                   listenWhen: (previous, current) =>
//                       previous.logoutStatus != current.logoutStatus,
//                   listener: (context, state) {
//                     if (state.logoutStatus == LogoutStatus.loading) {
//                       EasyLoading.show();
//                       return;
//                     }

//                     if (state.logoutStatus == LogoutStatus.finish) {
//                       EasyLoading.dismiss();
//                       return;
//                     }
//                   },
//                 ),
//               ],
//               child: GestureDetector(
//                 onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
//                 child: MaterialApp(
//                   debugShowCheckedModeBanner: false,
//                   home: AccumulateMoneyScreen(),
//                   builder: EasyLoading.init(builder: (context, child) {
//                     return child ?? const SizedBox.shrink();
//                   }),
//                 ),
//               ),
//             )),
//       ),
//     );
//   }
// }
