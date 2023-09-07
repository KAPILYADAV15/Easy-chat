

import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_chat/models/chat_user.dart';
import 'package:easy_chat/screens/view_profile_screen.dart';
import 'package:easy_chat/utils/my_date_util.dart';
import 'package:easy_chat/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {

  final ChatUser user;



  const ChatScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  // for storing all the messages
  List<Message> _list = [];

  // for handling text messages
  final _textController = TextEditingController();

  bool _showEmoji = false, _isUploading = false;

  @override

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),

            backgroundColor: Color.fromARGB(255, 234, 248, 255),


            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                      stream: Apis.getAllMessages(widget.user),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                        // if data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const SizedBox();

                        // if some or all data is loaded then show it
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;

                            _list =
                                data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

                            if (_list.isNotEmpty) {
                              return ListView.builder(
                                  itemCount: _list.length,
                                  reverse: true,
                                  physics: BouncingScrollPhysics(),
                                  padding:
                                  EdgeInsets.only(top: screenSize.height * 0.01),
                                  itemBuilder: (context, index) {
                                    return MessageCard(message: _list[index],);
                                  });
                            } else {
                              return Center(
                                  child: Text(
                                    "Say Hi!! 👋 ",
                                    style: TextStyle(fontSize: 20),
                                  ));
                            }
                        }
                      }),
                ),


                if (_isUploading)
                  const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                          padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          child: CircularProgressIndicator(strokeWidth: 2))),


                _chatInput(),


                if (_showEmoji)
                  SizedBox(
                    height: screenSize.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        bgColor: const Color.fromARGB(255, 234, 248, 255),
                        columns: 8,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar(){
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfileScreen(user: widget.user)));
      },
      child: StreamBuilder(
          stream: Apis.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

            return Row(
              children: [
                //back button
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon:
                    const Icon(Icons.arrow_back, color: Colors.black54)),

                //user profile picture
                ClipRRect(
                  borderRadius: BorderRadius.circular(screenSize.height * .03),
                  child: CachedNetworkImage(
                    width: screenSize.height * .05,
                    height: screenSize.height * .05,
                    imageUrl:
                    list.isNotEmpty ? list[0].image : widget.user.image,
                    errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(CupertinoIcons.person)),
                  ),
                ),

                //for adding some space
                const SizedBox(width: 10),

                //user name & last seen time
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //user name
                    Text(list.isNotEmpty ? list[0].name : widget.user.name,
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500)),

                    //for adding some space
                    const SizedBox(height: 2),

                    //last seen time of user
                    Text(
                        list.isNotEmpty
                            ? list[0].isOnline
                            ? 'Online'
                            : myDateUtil.getLastActiveTime(
                            context: context,
                            lastActive: list[0].lastActive)
                            : myDateUtil.getLastActiveTime(
                            context: context,
                            lastActive: widget.user.lastActive),
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54)),
                  ],
                )
              ],
            );
          }),
    );
  }

  Widget _chatInput(){
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenSize. width * 0.025, vertical: screenSize.height*0.01),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                      onPressed: (){
                        setState(() {
                          FocusScope.of(context).unfocus();
                          _showEmoji = !_showEmoji;
                        });
                      },
                      icon: Icon(Icons.emoji_emotions, color: Colors.blueAccent, size: 25,)),

                  Expanded(
                      child: TextField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onTap: () {
                          if (_showEmoji) setState(() => _showEmoji = !_showEmoji);
                        },
                        decoration: InputDecoration(
                          hintText: "Type Something",
                          hintStyle: TextStyle(color: Colors.blueAccent),
                          border: InputBorder.none
                        ),
                      )),

                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Picking multiple images
                        final List<XFile> images =
                        await picker.pickMultiImage(imageQuality: 70);

                        // uploading & sending image one by one
                        for (var i in images) {
                          log('Image Path: ${i.path}');
                          setState(() => _isUploading = true);
                          await Apis.sendChatImage(widget.user, File(i.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: Icon(Icons.image, color: Colors.blueAccent, size: 26,)),

                  IconButton(
                      onPressed: ()async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() => _isUploading = true);

                          await Apis.sendChatImage(
                              widget.user, File(image.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: Icon(Icons.camera_alt_outlined, color: Colors.blueAccent, size: 26,)),

                  SizedBox(width: screenSize.width *.02,)
                ],
              ),
            ),
          ),

          MaterialButton(onPressed: (){
            if(_textController.text.isNotEmpty){
              Apis.sendMessage(widget.user, _textController.text, Type.text);
              _textController.text = '';
            }
          },
            minWidth: 0,
            padding: EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 5),
            shape: CircleBorder(),
            color: Colors.green,
          child: Icon(Icons.send, color: Colors.white, size: 28,),)
        ],
      ),
    );
  }
}
