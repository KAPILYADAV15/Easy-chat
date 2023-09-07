import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_chat/api/apis.dart';
import 'package:easy_chat/main.dart';
import 'package:easy_chat/utils/my_date_util.dart';
import 'package:flutter/material.dart';

import '../models/message.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  const MessageCard({Key? key, required this.message}) : super(key: key);

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return Apis.user.uid == widget.message.fromId
        ? _greenMessaage()
        : _blueMessaage();
  }

  // another user message
  Widget _blueMessaage() {
    if (widget.message.read.isEmpty) {
      Apis.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? screenSize.width * .03
                : screenSize.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: screenSize.width * .04, vertical: screenSize.height * .01),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 221, 245, 255),
                border: Border.all(color: Colors.lightBlue),
                //making borders curved
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: widget.message.type == Type.text
                ?
            //show text
            Text(
              widget.message.msg,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            )
                :
            //show image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: widget.message.msg,
                placeholder: (context, url) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) =>
                const Icon(Icons.image, size: 70),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: screenSize.width * 0.04),
          child: Text(
            myDateUtil.getFormattedTime(context, widget.message.sent),
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        )
      ],
    );
  }

  // our message
  Widget _greenMessaage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: screenSize.width * 0.04,
            ),

            if (widget.message.read.isNotEmpty)
              Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
                size: 20,
              ),

            SizedBox(
              width: 2,
            ),

            // sent time
            Text(
              myDateUtil.getFormattedTime(context, widget.message.sent),
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? screenSize.width * .03
                : screenSize.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: screenSize.width * .04, vertical: screenSize.height * .01),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 218, 255, 176),
                border: Border.all(color: Colors.lightGreen),
                //making borders curved
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            child: widget.message.type == Type.text
                ?
            //show text
            Text(
              widget.message.msg,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            )
                :
            //show image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: widget.message.msg,
                placeholder: (context, url) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) =>
                const Icon(Icons.image, size: 70),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
