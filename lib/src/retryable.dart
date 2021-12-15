import 'package:cancelable/cancelable.dart';

/// Able
/// [i] current retry times
/// [error] latest error
typedef Able = Future<void> Function(int i, dynamic error);

/// retry operation
/// [computation] computation operation
/// [cancelable] cancelable context
/// [cancel] cancel function
/// [able] able to retry
Future<T> retry<T>(Future<T> Function() computation, {Cancelable? cancelable, Future<void> Function()? cancel, Able? able}) async {
  bool cancelled = false;
  final disposable = cancelable?.whenCancel(() {
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
      await disposable?.dispose();
      return t;
    } catch (e) {
      if (able == null || cancelled == true) {
        await disposable?.dispose();
        rethrow;
      }
      try {
        await able(++i, e);
        if (cancelled == true) {
          rethrow;
        }
      } catch (e) {
        await disposable?.dispose();
        rethrow;
      }
    }
  }
}
