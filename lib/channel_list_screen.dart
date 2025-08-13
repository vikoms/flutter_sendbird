import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';

import 'base_view.dart';
import 'controllers/channel_list_controller.dart';
import 'group_channel_create_page.dart';
import 'group_channel_page.dart';

class ChannelListScreen extends BaseView<ChannelListController> {
  const ChannelListScreen({super.key});

  @override
  Widget buildView(BuildContext context, ChannelListController controller) {
    return Scaffold(
      appBar: AppBar(title: const Text('Channel List Screen')),
      body: SafeArea(
        child: GetBuilder<ChannelListController>(
          builder: (_) {
            return SBUGroupChannelListScreen(
              query: controller.groupChannelListQuery,
              customHeader: (context, theme, strings, collection) {
                return ChannelListHeader(
                  title:
                      'Group ${controller.groupChannelListQuery.channelNameContainsFilter}',
                  onSearch: controller.search,
                );
              },
              onCreateButtonClicked: () {
                Get.to(() => const GroupChannelCreatePage());
              },
              onListItemClicked: (channel) {
                Get.to(() => GroupChannelPage(channelUrl: channel.channelUrl));
              },
              customListItem:
                  (context, theme, strings, collection, index, channel) {
                return ChannelListItem(channel: channel);
              },
            );
          },
        ),
      ),
    );
  }
}

class ChannelListHeader extends StatelessWidget {
  final String title;
  final void Function(String) onSearch;
  const ChannelListHeader({super.key, required this.title, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by channel name',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 12,
              ),
            ),
            onSubmitted: onSearch,
          ),
        ],
      ),
    );
  }
}

class ChannelListItem extends StatelessWidget {
  final GroupChannel channel;
  const ChannelListItem({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    final lastMessage = channel.lastMessage;
    final updatedAt = lastMessage != null
        ? DateTime.fromMillisecondsSinceEpoch(lastMessage.createdAt)
        : DateTime.fromMillisecondsSinceEpoch(channel.createdAt ?? 0);

    final now = DateTime.now();
    final difference = now.difference(updatedAt);

    String timeString;
    if (difference.inDays > 0) {
      timeString = '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      timeString = '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      timeString = '${difference.inMinutes}m ago';
    } else {
      timeString = 'Just now';
    }

    String messagePreview = 'No messages yet';
    if (lastMessage != null) {
      if (lastMessage is UserMessage) {
        messagePreview = lastMessage.message;
      } else if (lastMessage is FileMessage) {
        messagePreview = '📎 File: ${lastMessage.name}';
      } else if (lastMessage is AdminMessage) {
        messagePreview = '🔔 ${lastMessage.message}';
      }
    }

    final unreadCount = channel.unreadMessageCount;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.amber,
          foregroundColor: Colors.white,
          child: channel.coverUrl.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    channel.coverUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.group, size: 24);
                    },
                  ),
                )
              : const Icon(Icons.group, size: 24),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                channel.name.isNotEmpty
                    ? channel.name
                    : 'Group ${channel.members.length} members',
                style: TextStyle(
                  fontWeight:
                      unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              timeString,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                messagePreview,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight:
                      unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () {
          Get.to(() => GroupChannelPage(channelUrl: channel.channelUrl));
        },
      ),
    );
  }
}

