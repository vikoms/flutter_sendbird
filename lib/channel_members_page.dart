import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';

import 'invite_users_page.dart';

class ChannelMembersPage extends StatelessWidget {
  final String channelUrl;
  final int messageCollectionNo;
  const ChannelMembersPage({
    super.key,
    required this.channelUrl,
    required this.messageCollectionNo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SBUGroupChannelMembersScreen(
          messageCollectionNo: messageCollectionNo,
          onInviteButtonClicked: (channel) {
            Get.to(() => InviteUsersPage(messageCollectionNo: messageCollectionNo));
          },
        ),
      ),
    );
  }
}
