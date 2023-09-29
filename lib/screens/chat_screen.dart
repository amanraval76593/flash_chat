// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, avoid_print, use_build_context_synchronously, await_only_futures, duplicate_ignore, unused_local_variable, camel_case_types, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
late final User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final messageTextController = TextEditingController();
  late String message;
  late String email;
  late AsyncSnapshot<DocumentSnapshot> snapshot;
  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    // ignore: await_only_futures
    try {
      final user = await _auth.currentUser;
      loggedInUser = user!;
      if (user != null) {
        email = user.email!;
      }
    } catch (e) {
      print(e);
    }
  }

  // void getMessage() async {
  //   final QuerySnapshot<Map<String, dynamic>> messagesSnapshot =
  //       await _firestore.collection('message').get();
  //   final List<QueryDocumentSnapshot<Map<String, dynamic>>> messages =
  //       messagesSnapshot.docs;

  //   for (var message in messages) {
  //     print(message.data());
  //   }
  // }

  void messagestream() async {
    _firestore
        .collection('message')
        .snapshots()
        .listen((QuerySnapshot snapshots) {
      for (DocumentSnapshot message in snapshots.docs) {
        print(message.data());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () async {
                await _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            messageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: Colors.black),
                      controller: messageTextController,
                      onChanged: (value) {
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection('message').add({
                        'text': message,
                        'sender': email,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class messageStream extends StatelessWidget {
  const messageStream({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _firestore.collection('message').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ));
          }
          final messages = snapshot.data!.docs.reversed;
          List<messageBubbble> messageWidgets = [];

          for (var message in messages) {
            Map<String, dynamic> data = message.data();
            var messageText = data['text'];
            var messageSender = data['sender'];
            final messageWidget = messageBubbble(
              text: messageText,
              sender: messageSender,
              isMe: loggedInUser.email == messageSender,
            );
            messageWidgets.add(messageWidget);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              children: messageWidgets,
            ),
          );
        });
  }
}

class messageBubbble extends StatelessWidget {
  const messageBubbble(
      {required this.text, required this.sender, required this.isMe});
  final String text;
  final String sender;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Material(
            elevation: 5,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                text,
                style: TextStyle(
                    fontSize: 20, color: isMe ? Colors.white : Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
