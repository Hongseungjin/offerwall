// import 'package:flutter/material.dart';
// import 'package:sdk_eums/common/routing.dart';
// import 'package:sdk_eums/sdk_eums_library.dart';

// class TestOverlayScreen extends StatefulWidget {
//   const TestOverlayScreen({Key? key}) : super(key: key);

//   @override
//   State<TestOverlayScreen> createState() => _TestOverlayScreenState();
// }

// class _TestOverlayScreenState extends State<TestOverlayScreen> {
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     checkBack();
//   }

//   checkBack() {
//     Routing().popToRoot(context);
  
//     Future.delayed(const Duration(milliseconds: 150), () {
//       FlutterOverlayWindow.closeOverlay();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: Column(
//         children: [
//           InkWell(
//             behavior: HitTestBehavior.translucent,
//             onTap: () async {
//               checkBack();
//             },
//             child: const Scaffold(
//               body: Text(
//                 "ERROR",
//                 style: TextStyle(
//                     fontSize: 30,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.red),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
