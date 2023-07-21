import 'package:flutter/material.dart';

class Routing {
  navigate<T>(BuildContext context, Widget screen,
      {bool replace = false,
      String? routeName,
      bool isAnimated = false,
      bool rootNavigator = false}) {
    if (!!replace) {
      return Navigator.pushReplacement(
          context,
          isAnimated
              ? _createRoute(screen)
              : MaterialPageRoute<T>(
                  settings: RouteSettings(name: routeName),
                  builder: (BuildContext context) {
                    return screen;
                  }));
    }

    return Navigator.of(context, rootNavigator: rootNavigator).push(isAnimated
        ? _createRoute(screen)
        : MaterialPageRoute<T>(
            settings: RouteSettings(name: routeName),
            builder: (BuildContext context) {
              return screen;
            }));
  }

  Route _createRoute(Widget screen) {
    return PageRouteBuilder(
        pageBuilder: (BuildContext context, Animation animation,
            Animation secondaryAnimation) {
          return screen;
        },
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: const Offset(0.0, 0.0),
            ).animate(animation),
            child: child,
          );
        });
  }

  navigateOpacity<T>(BuildContext context, Widget screen,
      {bool replace = false, String? routeName}) {
    if (!!replace) {
      return Navigator.pushReplacement(
          context,
          PageRouteBuilder(
              pageBuilder: (BuildContext context, Animation animation,
                  Animation secondaryAnimation) {
                return screen;
              },
              transitionDuration: const Duration(milliseconds: 800),
              // reverseTransitionDuration: Duration(seconds: 500),
              transitionsBuilder: (
                BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child,
              ) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              }));
    }
    return Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: (BuildContext context, Animation animation,
                Animation secondaryAnimation) {
              return screen;
            },
            transitionDuration: const Duration(milliseconds: 800),
            // reverseTransitionDuration: Duration(seconds: 500),
            transitionsBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            }));
  }

  void popToRoot(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
