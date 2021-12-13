library retryable;

import 'package:cancelable/cancelable.dart';

Future<T> retry<T>(Future<T> Function() computation, {Cancelable? cancelable, Future<void> Function()? cancel, Future<void> Function(int i, dynamic error)? able}) async {
  bool cancelled = false;
  final sub = cancelable?.whenCancel(() {
    if (cancelled == true) {
      return;
    }
    cancelled = true;
    if (cancel == null) {
      return;
    }
    cancel();
  });
  int i = 0;
  while (true) {
    try {
      var t = await computation();
      await sub?.cancel();
      return t;
    } catch (e) {
      if (able == null || cancelled == true) {
        await sub?.cancel();
        rethrow;
      }
      try {
        await able(++i, e);
        if (cancelled == true) {
          rethrow;
        }
      } catch (e) {
        await sub?.cancel();
        rethrow;
      }
    }
  }
}
