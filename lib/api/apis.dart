import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_chat/models/chat_user.dart';
import 'package:easy_chat/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Apis {
  // authentication variable
  static FirebaseAuth auth = FirebaseAuth.instance;

  // reference for fireStore database
  static FirebaseFirestore ref = FirebaseFirestore.instance;

  // reference for firebase Storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // to return current user
  static User get user => auth.currentUser!;

  // to check current user
  static Future<bool> userExists() async {
    return (await ref.collection('users').doc(user.uid).get()).exists;
  }

  // variable to store signed in user information
  static late ChatUser myself;

  // to get current user data
  static Future<void> getSelfInfo() async {
    await ref.collection("users").doc(user.uid).get().then((user) async {
      if (user.exists) {
        myself = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();

        Apis.updateActiveStatus(true);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: user.uid,
        image: user.photoURL.toString(),
        about: 'Hey! i am using Easy chat',
        email: user.email.toString(),
        isOnline: false,
        lastActive: time,
        name: user.displayName.toString(),
        createdAt: time,
        pushToken: ' ');
    return (await ref.collection('users').doc(user.uid).set(chatUser.toJson()));
  }

  // for accessing firebase messaging (Push Notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        myself.pushToken = t;
        log('Push Token: $t');
      }
    });
  }


    // get all users except me
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return ref
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // update user profile
  static Future<void> updateUser() async {
    await ref
        .collection('users')
        .doc(user.uid)
        .update({'name': myself.name, 'about': myself.about});
  }

  static Future<void> updateProfilePicture(File file) async {
    // getting file image extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final refStorage = storage.ref().child('profile_pictures/${user.uid}.$ext');

    //uploading image
    await refStorage
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {});

    // uploading image in firestore database
    myself.image = await refStorage.getDownloadURL();
    await ref.collection('users').doc(user.uid).update({'image': myself.image});
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return ref
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    ref.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': myself.pushToken,
    });
  }


  /// ********************* Message related APIS *****************

  // chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc)

  // useful for getting conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // get all messages from a specific conversation from fireStore Database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return ref
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // for sending messages
  static Future<void> sendMessage(ChatUser chatUser, String msg, Type type) async {
    // message sending time also used as id
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // message to send
    final Message message = Message(
        msg: msg,
        toId: chatUser.id,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);

    final msgRef =
        ref.collection('chats/${getConversationID(chatUser.id)}/messages/');
    await msgRef.doc(time).set(message.toJson());
  }

  // getting the read status
  static Future<void> updateMessageReadStatus(Message message) async {
    ref
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // get only last message from specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return ref
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }


  // send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }
}
