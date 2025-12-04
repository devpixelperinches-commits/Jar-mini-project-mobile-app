import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class NavigationService {
  static BuildContext? get context => rootNavigatorKey.currentContext;

  static go(String route) {
    final ctx = context;
    if (ctx != null) {
      GoRouter.of(ctx).go(route);
    }
  }

  static push(String route) {
    final ctx = context;
    if (ctx != null) {
      GoRouter.of(ctx).push(route);
    }
  }

  static clearAndGo(String route) {
    final ctx = context;
    if (ctx != null) {
      GoRouter.of(ctx).go(route); // go() automatically clears stack
    }
  }

  static showMessage(String message) {
    final ctx = rootNavigatorKey.currentContext;
    if (ctx != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white, // keep text readable
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.red, // 🔴 RED ERROR COLOR
          behavior: SnackBarBehavior.floating, // looks nicer
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
