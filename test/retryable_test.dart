import 'dart:async';
import 'dart:math';

import 'package:cancelable/cancelable.dart';
import 'package:retryable/retryable.dart';
import 'package:test/test.dart';

void main() {
  test('retryable', () async {
    final cancelable = Cancelable();
    int i = -1;
    const int exceptionI = 0;
    const int expectI = 9;
    final timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        i = Random().nextInt(10);
      },
    );
    try {
      final r = await retry<int>(
        () async {
          print(i);
          if (i == exceptionI) {
            throw Exception('exit');
          }
          if (i != expectI) {
            throw Exception('retryable');
          }
          return i;
        },
        cancelable: cancelable,
        cancel: () async {
          timer.cancel();
        },
        able: (i, e) async {
          if (e is! Exception || e.toString().contains('retryable') == false) {
            throw e;
          }
          await Future.delayed(const Duration(seconds: 1));
        },
      );
      print(r);
    } catch (e) {
      print(e);
    }
  });
}
