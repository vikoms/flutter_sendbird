import 'package:get/get.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

class ChannelListController extends GetxController {
  GroupChannelListQuery groupChannelListQuery = GroupChannelListQuery();

  void search(String value) {
    groupChannelListQuery = GroupChannelListQuery()
      ..includeEmpty = true
      ..order = GroupChannelListQueryOrder.channelNameAlphabetical
      ..searchQuery = value
      ..channelNameContainsFilter = value;
    update();
  }
}
