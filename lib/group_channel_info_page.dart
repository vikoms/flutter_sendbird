import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';

import 'channel_members_page.dart';

class GroupChannelInfoPage extends StatelessWidget {
  final String channelUrl;
  final int messageCollectionNo;
  const GroupChannelInfoPage({
    super.key,
    required this.channelUrl,
    required this.messageCollectionNo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SBUGroupChannelInformationScreen(
          messageCollectionNo: messageCollectionNo,
          onMembersButtonClicked: (p0) {
            Get.to(() => ChannelMembersPage(
                  channelUrl: channelUrl,
                  messageCollectionNo: messageCollectionNo,
                ));
          },
          onModerationsButtonClicked: (p0) {
            print('Moderations button clicked: $p0');
          },
          onChannelLeft: (p0) {
            print('Channel left: $p0');
          },
        ),
      ),
    );
  }
}
