import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BaseView<T extends GetxController> extends StatelessWidget {
  final T controller;
  final Widget Function(BuildContext context, T controller) builder;
  const BaseView({super.key, required this.controller, required this.builder});

  @override
  Widget build(BuildContext context) {
    Get.put<T>(controller);
    return builder(context, controller);
  }
}
