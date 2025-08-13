import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Base widget that exposes an injected [GetxController] to its subclasses.
///
/// All screens in the app extend this class so they can access their
/// respective controllers through GetX's dependency injection while keeping
/// the widget tree stateless.
abstract class BaseView<T extends GetxController> extends GetView<T> {
  const BaseView({super.key});

  /// Called when building the widget tree. The [controller] is provided by
  /// GetX via dependency injection.
  Widget buildView(BuildContext context, T controller);

  @override
  Widget build(BuildContext context) => buildView(context, controller);
}
