import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';

import '../routes/app_routes.dart';

class HomeController extends GetxController {
  final userIdController = TextEditingController(
    text: "sendbird_desk_agent_id_6991b122-6fb9-4415-83da-0c3331b7c9ac",
  );
  final userNameController = TextEditingController(text: "VIKO");
  final accessTokenController = TextEditingController(
    text: "9da79284f51b09f4382efb3837420b968a76efab",
  );

  Future<void> login() async {
    final userId = userIdController.text;
    final userName = userNameController.text;
    final accessToken = accessTokenController.text;

    if (userId.isNotEmpty && userName.isNotEmpty) {
      try {
        await SendbirdUIKit.connect(
          userId,
          accessToken: accessToken,
          nickname: userName,
        );
        Get.offNamed(Routes.channels);
      } catch (e) {
        Get.snackbar('Login failed', e.toString());
      }
    } else {
      Get.snackbar('Validation', 'User ID and User Name are required');
    }
  }
}
