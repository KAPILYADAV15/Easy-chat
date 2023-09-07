

import 'dart:developer';

import 'package:easy_chat/api/apis.dart';
import 'package:easy_chat/main.dart';
import 'package:easy_chat/models/chat_user.dart';
import 'package:easy_chat/screens/profileScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];

  final List<ChatUser> _searchedList = [];

  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    Apis.getSelfInfo();

    //for updating user active status according to lifecycle events
    //resume -- active or online
    //pause  -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (Apis.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          Apis.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          Apis.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        // if search is on && back button is pressed then close search
        // or else simple close current screen on back button click

        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
            appBar: AppBar(
              title: _isSearching
                  ? TextField(
                      decoration: InputDecoration(
                        hintText: "Name or Email",
                        border: InputBorder.none,
                      ),
                      autofocus: true,
                      style: TextStyle(fontSize: 17, letterSpacing: 0.5),
                      onChanged: (value) {
                        _searchedList.clear();
                        for (var i in _list) {
                          if ((i.name
                                  .toLowerCase()
                                  .contains(value.toLowerCase())) ||
                              (i.email
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))) {
                            _searchedList.add(i);
                          }
                          setState(() {
                            _searchedList;
                          });
                        }
                      },
                    )
                  : Text("Easy chat"),
              leading: IconButton(
                icon: Icon(Icons.home_outlined),
                onPressed: () {},
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                      });
                    },
                    icon: _isSearching
                        ? Icon(CupertinoIcons.clear_circled_solid)
                        : Icon(Icons.search)),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ProfileScreen(user: Apis.myself)));
                    },
                    icon: Icon(Icons.more_vert))
              ],
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton(
                onPressed: () async {},
                child: const Icon(Icons.add_comment_rounded),
              ),
            ),
            body: StreamBuilder(
                stream: Apis.getAllUsers(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    // if data is loading
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(child: CircularProgressIndicator());

                    // if some or all data is loaded then show it
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data?.docs;
                      _list = data
                              ?.map((e) => ChatUser.fromJson(e.data()))
                              .toList() ??
                          [];

                      if (_list.isNotEmpty) {
                        return ListView.builder(
                            itemCount: _isSearching
                                ? _searchedList.length
                                : _list.length,
                            physics: BouncingScrollPhysics(),
                            padding:
                                EdgeInsets.only(top: screenSize.height * 0.01),
                            itemBuilder: (context, index) {
                              return ChatUserCard(
                                  user: _isSearching
                                      ? _searchedList[index]
                                      : _list[index]);
                              //Text('Name : ${list[index]}');
                            });
                      } else {
                        return Center(
                            child: Text(
                          "no connections found!!",
                          style: TextStyle(fontSize: 20),
                        ));
                      }
                  }
                })),
      ),
    );
  }


}
