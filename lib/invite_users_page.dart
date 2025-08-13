import 'package:flutter/material.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';

class InviteUsersPage extends StatelessWidget {
  final int messageCollectionNo;
  const InviteUsersPage({super.key, required this.messageCollectionNo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SBUGroupChannelInviteScreen(
          messageCollectionNo: messageCollectionNo,
        ),
      ),
    );
  }
}
