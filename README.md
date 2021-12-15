# Retryable, make operation retryable.

## Usage

```dart
void main(){
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
          print('$i');
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
      print('$res');
    } catch (e) {
      print(e.toString());
    }
}
```