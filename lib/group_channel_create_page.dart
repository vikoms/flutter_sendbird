import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';

import 'group_channel_page.dart';

class GroupChannelCreatePage extends StatelessWidget {
  const GroupChannelCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SBUGroupChannelCreateScreen(
          onChannelCreated: (channel) {
            Get.to(() => GroupChannelPage(channelUrl: channel.channelUrl));
          },
        ),
      ),
    );
  }
}
