import 'dart:convert';

import 'package:audio_video_call/controller/call_controller.dart';
import 'package:audio_video_call/model/user_model.dart';
import 'package:audio_video_call/screens/audio_call.dart';
import 'package:audio_video_call/screens/call%20_screen.dart';
import 'package:audio_video_call/static_data.dart';
import 'package:audio_video_call/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String chatroomId;
  final String username;
  final UserModel profileModel;
  final UserModel userModel;
  ChatScreen(
      {required this.chatroomId,
      required this.userModel,
      required this.profileModel,
      required this.username});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  http.Response? response;
  TextEditingController msgController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    print(widget.userModel.toMap());

    // _firestore
    //     .collection('chatroom')
    //     .doc(widget.chatroomId)
    //     .collection('chats')
    //     .orderBy("time", descending: false)
    //     .snapshots();

    super.initState();
  }

  sendNotifcation(String msg) async {
    var body = {
      "registration_ids": [widget.userModel.token],
      "notification": {
        "body": msg,
        "title":
            '${widget.profileModel.firstName} ${widget.profileModel.secondName}',
        "android_channel_id": "pushnotificationapp",
        "sound": true,
      },
      "data": {
        "source": "chat",
      }
    };
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'authorization':
          'key=AAAAAfhc2J0:APA91bFVJOhoyhOnSXRQ5j6mRS8mpJBk3hkbcFNC6o4gLBFmFOLG8uT6rdLf8PlEOupELZ9rZ_fX-QAHIsanJtoT5JccMQve7jrd34y3_vup-hbvlEJYyWGw5YIyhpquwUorbcG1RnaR'
    };
    response = await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: headers, body: jsonEncode(body));
    if (response!.statusCode == 200) {
      print(response!.body);
    }
  }

  void onsendMessage() async {
    if (msgController.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendBy": widget.username,
        "message": msgController.text,
        "time": FieldValue.serverTimestamp()
      };
      await _firestore
          .collection('chatroom')
          .doc(widget.chatroomId)
          .collection('chats')
          .add(messages);
      sendNotifcation(msgController.text);
      msgController.clear();
    } else {
      print("Enter Some Text");
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: height,
          width: width,
          child: Column(
            children: [
              Container(
                color: Mytheme.primaryColor,
                height: height * 0.04,
              ),
              Container(
                height: height * 0.08,
                width: width,
                decoration: BoxDecoration(
                    color: Mytheme.primaryColor,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10))),
                child: Padding(
                  padding:
                      EdgeInsets.only(right: width * 0.02, left: width * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: height * 0.05,
                        width: width * 0.12,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        child: Icon(
                          Icons.person,
                          color: Mytheme.primaryColor,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${widget.userModel.firstName} ${widget.userModel.secondName}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500)),
                          Text(
                            widget.userModel.status == true
                                ? 'Online'
                                : 'Offline',
                            style: TextStyle(
                              color: widget.userModel.status == true
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                          child: SizedBox(
                        width: width,
                      )),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AudioCall(
                                  roomId: '',
                                  callstatus: false,
                                  profileModel: widget.profileModel,
                                  userModel: widget.userModel,
                                ),
                              ));
                        },
                        child: Icon(
                          Icons.call,
                          size: width * 0.07,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: width * 0.02,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CallScreen(
                                  roomId: '',
                                  callstatus: false,
                                  profileModel: widget.profileModel,
                                  userModel: widget.userModel,
                                ),
                              ));
                        },
                        child: Icon(
                          Icons.video_call,
                          size: width * 0.07,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: width * 0.02,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('chatroom')
                        .doc(widget.chatroomId)
                        .collection('chats')
                        .orderBy("time", descending: false)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.data != null) {
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> map =
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;
                            return messages(MediaQuery.of(context).size, map);
                          },
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
              ),
              Divider(
                color: Mytheme.primaryColor,
              ),
              SizedBox(
                height: height * 0.07,
                width: width,
                child: Padding(
                  padding:
                      EdgeInsets.only(left: width * 0.03, right: width * 0.01),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: EdgeInsets.only(left: width * 0.02),
                            child: Center(
                              child: TextField(
                                controller: msgController,
                                decoration: const InputDecoration(
                                    border: InputBorder.none),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width * 0.01,
                      ),
                      InkWell(
                          onTap: () {
                            onsendMessage();
                          },
                          child: Container(
                            height: height,
                            width: width * 0.14,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Mytheme.primaryColor),
                            child: const Center(
                              child: Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.01,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget messages(Size size, Map<String, dynamic> map) {
    return Container(
      width: size.width,
      alignment: map['sendBy'] == widget.username
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: map['sendBy'] == widget.username
              ? Mytheme.primaryColor
              : Colors.red[100],
        ),
        child: Text(
          map['message'],
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: map['sendBy'] == widget.username
                  ? Colors.white
                  : Colors.black),
        ),
      ),
    );
  }
}
