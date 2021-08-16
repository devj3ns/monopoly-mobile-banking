import 'dart:async';

import 'failures.dart';

extension StreamExtensions<T> on Stream<T> {
  Stream<T> onErrorResumeWith(
    T Function(Object error, StackTrace stackTrace) valueOnError,
  ) {
    return transform(
      StreamTransformer<T, T>.fromHandlers(
        handleError: (Object error, StackTrace stackTrace, EventSink<T> sink) {
          sink.add(valueOnError(error, stackTrace));
        },
      ),
    );
  }

  Stream<T> handleFailure([void Function(AppFailure failure)? onFailure]) {
    return handleError(
      (Object error) {
        if (error is AppFailure) {
          onFailure?.call(error);
        }
      },
    );
  }
}
