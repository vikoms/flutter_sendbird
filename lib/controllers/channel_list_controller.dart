import 'package:get/get.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

enum ChannelFilter { all, read, unread }

class ChannelListController extends GetxController {
  GroupChannelListQuery groupChannelListQuery = GroupChannelListQuery();

  // Add filter state
  ChannelFilter _selectedFilter = ChannelFilter.all;
  ChannelFilter get selectedFilter => _selectedFilter;

  void search(String value) {
    groupChannelListQuery = GroupChannelListQuery()
      ..includeEmpty = true
      ..order = GroupChannelListQueryOrder.channelNameAlphabetical
      ..searchQuery = value
      ..channelNameContainsFilter = value;
    update();
  }

  void setFilter(ChannelFilter filter) {
    _selectedFilter = filter;
    // Refresh query to trigger list update
    groupChannelListQuery = GroupChannelListQuery()
      ..includeEmpty = true
      ..order = GroupChannelListQueryOrder.channelNameAlphabetical;
    update();
  }

  bool shouldShowChannel(GroupChannel channel) {
    final unreadCount = channel.unreadMessageCount;

    switch (_selectedFilter) {
      case ChannelFilter.read:
        return unreadCount == 0;
      case ChannelFilter.unread:
        return unreadCount > 0;
      case ChannelFilter.all:
      default:
        return true;
    }
  }
}
