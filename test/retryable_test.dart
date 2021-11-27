import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:retryable/retryable.dart';
import 'package:cancelable/cancelable.dart';

void main() {
  test('adds one to input values', () async {
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
      final res = await retry<int>(
        () async {
          debugPrint('$i');
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
      expect(res, expectI);
    } catch (e) {
      debugPrint(e.toString());
    }
  });
}
