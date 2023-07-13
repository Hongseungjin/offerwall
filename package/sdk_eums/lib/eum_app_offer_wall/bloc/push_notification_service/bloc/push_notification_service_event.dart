// part of 'push_notification_service_bloc.dart';

// @immutable
// abstract class PushNotificationServiceEvent extends Equatable {
//   const PushNotificationServiceEvent();
// }


// class UnSubNotification extends PushNotificationServiceEvent {
//   const UnSubNotification();

//   @override
//   List<Object?> get props => [
//   ];
// }

// class PushNotificationSetup extends PushNotificationServiceEvent {
//   const PushNotificationSetup();

//   @override
//   List<Object?> get props => [
//       ];
// }

// class PushNotificationRegisterToken extends PushNotificationServiceEvent {
//   const PushNotificationRegisterToken({
//     required this.token,
//   });

//   final String token;

//   @override
//   List<Object?> get props => [
//         token,
//       ];
// }

// class PushNotificationHandleRemoteMessage extends PushNotificationServiceEvent {
//   const PushNotificationHandleRemoteMessage({
//     required this.message,
//     required this.isForeground,
//   });

//   final RemoteMessage? message;

//   final bool isForeground;

//   @override
//   List<Object?> get props => [
//         message,
//         isForeground,
//       ];
// }
// class RemoveToken extends PushNotificationServiceEvent {
//   RemoveToken({this.token});
//   final dynamic token;
//   @override
//   List<Object?> get props => [token];
// }