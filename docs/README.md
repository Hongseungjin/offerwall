# Flutter OfferWall Module

This is a module for Android and iOS that can be used together, created based on the flutter framework

Prepared based on the following documents:

- [documentation android](https://docs.flutter.dev/add-to-app/android/project-setup?tab=with-android-studio).

- [documentation ios](https://docs.flutter.dev/add-to-app/ios/project-setup).

## Getting Started Version

WARNING: Please check if the version on your device is suitable, it may be equal or higher

### Flutter

- Flutter version 3.13.8 on channel stable
- Dart version 3.1.4
- DevTools version 2.25.0

### Android

- Android studio version: (Android SDK version 34.0.0)
- Java version OpenJDK Runtime Environment (build 11.0.15+0-b2043.56-8887301)

![Alt text](./images/version-android-studio.png)

### IOS

- Develop for iOS and macOS (Xcode 15.0)
- CocoaPods version 1.13.0

![Alt text](./images/version-xcode.png)

## Getting Started Import Module

- Project folder structure:

```
offerwall
├── docs
├── offerwall_module
│     ├── AndroidExample
│     ├── flutter_offerwall_module (Folder build sdk)
│     └── IOSExampleV2
└── offerwall_package (Folder source code module)

```

### ANDROID

### Create project android kotlin

![Alt text](./images/create-project-android.gif)

### Build sdk aar

- Open the terminal folder :  

```
offerwall
├── docs
├── offerwall_module
│     ├── AndroidExample
│     ├── flutter_offerwall_module (Folder build sdk)
│     └── IOSExampleV2
└── offerwall_package (Folder source code module)

```

- Example path folder build sdk: 

```
cd <your path>/offerwal/offerwall_module/flutter_offerwall_module
```

- Command build sdk:

```
flutter build aar --output=< your path >/< My Application >/app/libs
```

![Alt text](./images/result-build-aar.png)

