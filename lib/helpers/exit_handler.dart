import 'package:flutter/widgets.dart';

class ExitHandler with WidgetsBindingObserver {
  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // Clear history, cookies, etc.
    }
  }
}
