import 'dart:async';

Stream<T> withFirstEventTimeout<T>(
  Stream<T> source, {
  Duration timeout = const Duration(seconds: 20),
  required String message,
}) {
  return Stream<T>.multi((controller) {
    var receivedFirstEvent = false;
    final timer = Timer(timeout, () {
      if (!receivedFirstEvent) {
        controller.addError(TimeoutException(message, timeout));
      }
    });
    final subscription = source.listen(
      (event) {
        if (!receivedFirstEvent) {
          receivedFirstEvent = true;
          timer.cancel();
        }
        controller.add(event);
      },
      onError: (Object error, StackTrace stackTrace) {
        controller.addError(error, stackTrace);
      },
      onDone: () {
        timer.cancel();
        controller.close();
      },
    );

    controller.onCancel = () async {
      timer.cancel();
      await subscription.cancel();
    };
  }, isBroadcast: true);
}