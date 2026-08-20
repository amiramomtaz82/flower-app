import 'dart:async';

import 'package:injectable/injectable.dart';

import 'ui_action.dart';

@lazySingleton
class UiActionDispatcher {
  final _controller = StreamController<UiAction>.broadcast();

  Stream<UiAction> get stream => _controller.stream;

  void dispatch(UiAction action) => _controller.add(action);

  @disposeMethod
  void dispose() => _controller.close();
}
