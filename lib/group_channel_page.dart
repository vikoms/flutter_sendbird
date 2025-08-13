import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';

import 'group_channel_info_page.dart';

class GroupChannelPage extends StatelessWidget {
  final String channelUrl;
  const GroupChannelPage({super.key, required this.channelUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SBUGroupChannelScreen(
          channelUrl: channelUrl,
          onInfoButtonClicked: (messageCollectionNo) {
            Get.to(() => GroupChannelInfoPage(
                  channelUrl: channelUrl,
                  messageCollectionNo: messageCollectionNo,
                ));
          },
          onListItemClicked: (channel, message) async {
            try {
              if (message is UserMessage && message.ogMetaData != null) {
                final url = message.ogMetaData?.url;
                if (url != null) {
                  print('Opening URL: $url');
                }
              } else if (message is FileMessage && message.secureUrl.isNotEmpty) {
                if (message.type != null) {
                  if (message.type!.startsWith('image')) {
                    print('Opening image: ${message.secureUrl}');
                  } else if (message.type!.startsWith('video')) {
                    print('Opening video: ${message.secureUrl}');
                  }
                }
              } else if (message is AdminMessage) {
                print('Admin message: ${message.message}');
              } else {
                print('Unknown message type: $message');
              }
            } catch (e) {
              debugPrint(e.toString());
            }
          },
          on1On1ChannelCreated: (p0) {
            print('1-on-1 channel created: $p0');
          },
          onChannelDeleted: (p0) {
            print('Channel deleted: $p0');
          },
          onMessageCollectionReady: (messageCollectionNo) {},
        ),
      ),
    );
  }
}
