import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_chat/main.dart';
import 'package:easy_chat/models/chat_user.dart';
import 'package:easy_chat/models/message.dart';
import 'package:easy_chat/utils/my_date_util.dart';
import 'package:easy_chat/widgets/dialogs/profile_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../api/apis.dart';
import '../screens/chatScreen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({Key? key, required this.user}) : super(key: key);

  @override
  State<ChatUserCard> createState() => _ChatUserState();
}

class _ChatUserState extends State<ChatUserCard> {
  //last message (if null -> no message)
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.04, vertical: 4),
      // color: Colors.blue.shade50,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(user: widget.user)));
          },
          child: StreamBuilder(
              stream: Apis.getLastMessage(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;

                final list =
                    data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

                if (list.isNotEmpty) {
                  _message = list[0];
                }

                return ListTile(
                  leading: InkWell(
                    onTap: (){
                      showDialog(context: context, builder: (_) => ProfileDialog(user: widget.user) );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(screenSize.height * .3),
                      child: CachedNetworkImage(
                        width: screenSize.height * .055,
                        height: screenSize.height * .055,
                        imageUrl: widget.user.image,
                        errorWidget: (context, url, error) => CircleAvatar(
                          child: Icon(CupertinoIcons.person),
                        ),
                      ),
                    ),
                  ),
                  //leading: CircleAvatar(child: Icon(CupertinoIcons.person),),
                  title: Text(widget.user.name),
                  subtitle: Text(_message != null
                      ? _message!.type == Type.image
                      ? 'image'
                      : _message!.msg
                      : widget.user.about,
                      maxLines: 1),
                  trailing: _message == null
                      ? null
                      : _message!.read.isEmpty &&
                              _message!.fromId != Apis.user.uid
                          ? Container(
                              width: 17,
                              height: 17,
                              decoration: BoxDecoration(
                                  color: Colors.greenAccent.shade400,
                                  borderRadius: BorderRadius.circular(10))
                              //
                              //
                              )
                          : Text(
                              myDateUtil.getLastMessageTime(
                                  context: context, time: _message!.sent),
                              style: TextStyle(color: Colors.black54),
                            ),
                );
              })),
    );
  }
}
