import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppTabs {
  static final index = ValueNotifier<int>(0);
  static final shopFeatures = ValueNotifier<bool>(false);

  static void goToday() => index.value = 0;
  static void goWorkspace() => index.value = 1;
  static void goCockpit() => index.value = 2;
  static void goSettings() => index.value = 3;
  static void goHome() => goToday();
  static void goGarden() => goWorkspace();
  static void goInventory() => goCockpit();
  static void goJournal() => goSettings();
  static void goMore() => goSettings();
  static void goShop({bool features = false}) {
    shopFeatures.value = features;
    rootNavigatorKey.currentState?.pushNamed('/shop');
  }
}

BuildContext? get rootContext => rootNavigatorKey.currentContext;

Future<T?> showAppModal<T>(Widget sheet) {
  final ctx = rootContext;
  if (ctx == null) return Future.value(null);
  return showModalBottomSheet<T>(
    context: ctx,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => sheet,
  );
}
