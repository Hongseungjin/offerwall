import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/local_store/local_store.dart';
import '../../../common/local_store/local_store_service.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc()
      : _localStore = LocalStoreService(),
        super(const AuthenticationState()) {
    on<AuthenticationEvent>(mapEventToState);
    _localStore.hasAuthenticated().then((hasAuthenticated) {
      add(AuthenticationStatusChanged(hasAuthenticated
          ? AuthenticationStatus.authenticated
          : AuthenticationStatus.unauthenticated));
    });
  }

  final LocalStore _localStore;
  bool onLoggingOut = false;

  FutureOr<void> mapEventToState(AuthenticationEvent event, emit) async {
    if (event is AuthenticationStatusChanged) {
      await _mapAuthenticationStatusChangedToState(event, emit);
    } else if (event is AuthenticationLogout) {
      await _mapAuthenticationLogoutToState(event, emit);
    } else if (event is CheckSaveAccountLogged) {
      await _mapCheckSaveAccountLoggedToState(event, emit);
    }
  }

  _mapAuthenticationStatusChangedToState(
      AuthenticationStatusChanged event, emit) async {
    switch (event.status) {
      case AuthenticationStatus.unauthenticated:
        await _localStore.removeCredentials();
        emit(state.copyWith(status: AuthenticationStatus.unauthenticated));
        return;
      case AuthenticationStatus.authenticated:
        emit(state.copyWith(status: AuthenticationStatus.authenticated));
        return;
      default:
        emit(state.copyWith(status: AuthenticationStatus.unknown));
        return;
    }
  }

  _mapCheckSaveAccountLoggedToState(CheckSaveAccountLogged event, emit) async {
    await Future.delayed(const Duration(milliseconds: 200));
    bool isSave = await _localStore.getSaveOrNotCredentials();
    
    if (!isSave) {
      add(AuthenticationStatusChanged(AuthenticationStatus.unauthenticated));
    }
  }

  _mapAuthenticationLogoutToState(AuthenticationLogout event, emit) async {
   
    if (onLoggingOut) {
      return;
    }
    onLoggingOut = true;
    emit(state.copyWith(logoutStatus: LogoutStatus.loading));
    try {
      String accessToken = await _localStore.getAccessToken();
      if (accessToken.isNotEmpty) {
        // await _accountRepos.logout();
      }
      emit(state.copyWith(logoutStatus: LogoutStatus.finish));
    } catch (e) {
      emit(state.copyWith(logoutStatus: LogoutStatus.finish));
    } finally {
      add(AuthenticationStatusChanged(AuthenticationStatus.unauthenticated));
      onLoggingOut = false;
    }
  }
}
