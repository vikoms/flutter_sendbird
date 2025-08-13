import 'package:flutter/material.dart';
import 'package:flutter_sendbird_sandbox/main.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';

class ChannelListScreen extends StatefulWidget {
  const ChannelListScreen({super.key});

  @override
  State<ChannelListScreen> createState() => _ChannelListScreenState();
}

class _ChannelListScreenState extends State<ChannelListScreen> {
  var groupChannelListQuery = GroupChannelListQuery();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Channel List Screen')),
      body: SafeArea(
        child: SBUGroupChannelListScreen(
          query: groupChannelListQuery,
          customHeader: (context, theme, strings, collection) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Group ${groupChannelListQuery.channelNameContainsFilter}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by channel name',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 12,
                      ),
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        groupChannelListQuery = GroupChannelListQuery()
                          ..includeEmpty = true
                          ..order =
                              GroupChannelListQueryOrder.channelNameAlphabetical
                          ..searchQuery = value
                          ..channelNameContainsFilter = value;

                        print(groupChannelListQuery.channelNameContainsFilter);
                      });
                    },
                  ),
                ],
              ),
            );
          },
          onCreateButtonClicked: () {
            moveToGroupChannelCreateScreen(context);
          },
          onListItemClicked: (channel) {
            moveToGroupChannelScreen(context, channel.channelUrl);
          },
          customListItem:
              (context, theme, strings, collection, index, channel) {
                // Last message time formatting
                final lastMessage = channel.lastMessage;
                final updatedAt = lastMessage != null
                    ? DateTime.fromMillisecondsSinceEpoch(lastMessage.createdAt)
                    : DateTime.fromMillisecondsSinceEpoch(
                        channel.createdAt ?? 0,
                      );

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

                // Last message preview
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

                // Unread count badge
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
                                  return Icon(Icons.group, size: 24);
                                },
                              ),
                            )
                          : Icon(Icons.group, size: 24),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            channel.name.isNotEmpty
                                ? channel.name
                                : 'Group ${channel.members.length} members',
                            style: TextStyle(
                              fontWeight: unreadCount > 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          timeString,
                          style: TextStyle(fontSize: 12, color: Colors.black54),
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
                              fontWeight: unreadCount > 0
                                  ? FontWeight.w500
                                  : FontWeight.normal,
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
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      moveToGroupChannelScreen(context, channel.channelUrl);
                    },
                  ),
                );
              },
        ),
      ),
    );
  }
}
