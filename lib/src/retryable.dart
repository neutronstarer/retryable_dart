import 'dart:async';

import 'package:cancelable/cancelable.dart';

/// [Able] Able means able to retry.
/// [i] Current retry times.
/// [error] Latest error.
typedef Able = FutureOr<void> Function(int i, dynamic error);

/// [retry] Retry operation.
/// [computation] Computation operation.
/// [cancelable] Cancelable context.
/// [cancel] Cancel function called when [cancelable].cancel().
/// [able] Able to retry
Future<T> retry<T>(FutureOr<T> Function() computation, {Cancelable? cancelable, Exception? Function()? cancel, Able? able}) async {
  bool cancelled = false;
  Exception? cancellError;
  final disposable = cancelable?.whenCancel(() {
    if (cancelled == true) {
      return;
    }
    cancelled = true;
    if (cancel == null) {
      return;
    }
    cancellError = cancel();
  });
  int i = 0;
  while (true) {
    try {
      var t = await computation();
      disposable?.dispose();
      if (cancelled && cancellError != null) {
        throw cancellError!;
      }
      return t;
    } catch (e) {
      try {
        if (cancelled == true) {
          rethrow;
        }
        if (able == null) {
          rethrow;
        }
        await able(++i, e);
        if (cancelled == true) {
          rethrow;
        }
      } catch (e) {
        disposable?.dispose();
        rethrow;
      }
    }
  }
}
