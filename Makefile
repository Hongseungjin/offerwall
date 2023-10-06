init: clean pub-get

clean:
	 fvm flutter clean

pub-get:
	fvm flutter pub get

init-icon:
	fvm flutter pub run flutter_launcher_icons:main

gen:
	fvm flutter pub run build_runner build

gen-conflict:
	fvm flutter pub get && fvm flutter pub run build_runner build --delete-conflicting-outputs

clear-cocoa-pod:
	rm -rf ~/Library/Caches/CocoaPods
	rm -rf ~/Library/Developer/Xcode/DerivedData/*
	cd ios && rm -rf Pods
	cd ios && pod deintegrate
	cd ios && pod setup
	cd ios && pod install

pod-install:
	cd ios && rm -rf Pods && rm -rf build && rm -rf Podfile.lock && pod install && cd ..

run:
	fvm flutter run -d 'R5CT90QNQBM'
	#'00008101-00097DEE1A38001E'
	#--no-sound-null-safety
	#emulator-5554
	#
	#ce071717818b84fd0b
	

run-web:
	fvm flutter run -d chrome --no-sound-null-safety

build: build-android-apk build-android-bundle finder

apk:
	fvm flutter build apk

aab:
	fvm flutter build appbundle --release --no-sound-null-safety --no-tree-shake-icons

sha:
	cd android && ./gradlew signingReport

release-web:
	fvm flutter build web

build-android-bundle:
	fvm flutter build appbundle --no-sound-null-safety