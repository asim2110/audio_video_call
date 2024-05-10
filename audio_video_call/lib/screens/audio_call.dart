import 'dart:convert';

import 'package:audio_video_call/controller/call_controller.dart';
import 'package:audio_video_call/signaling.dart';
import 'package:audio_video_call/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:audio_video_call/model/user_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AudioCall extends StatefulWidget {
  final String roomId;
  final bool callstatus;
  final UserModel profileModel;
  final UserModel userModel;
  AudioCall({
    required this.roomId,
    required this.callstatus,
    required this.userModel,
    required this.profileModel,
  });

  @override
  State<AudioCall> createState() => _AudioCallState();
}

class _AudioCallState extends State<AudioCall> {
  Signaling signaling = Signaling();
  http.Response? response;

  MediaStream? loacalStream;
  bool ismute = false;
  String? roomId;

  @override
  void initState() {
    super.initState();

    roomId = widget.roomId;
    CallController.to.initilizeRTcREneders();

    signaling.onAddRemoteStream = ((stream) {
      CallController.to.remoteRenderer.srcObject = stream;
      setState(() {});
    });
    Future.delayed(const Duration(seconds: 1), () {
      startCAll(widget.callstatus);
    });
  }

  startCAll(bool value) async {
    await signaling.openAudioUserMedia(
        CallController.to.localRenderer, CallController.to.remoteRenderer);

    if (value == false) {
      creatCallRoom();
    } else {
      await signaling.joinRoom(
        widget.roomId,
        CallController.to.remoteRenderer,
      );
      setState(() {});
    }
  }

  sendNotifcation(String roomId) async {
    var body = {
      "registration_ids": [widget.userModel.token],
      "notification": {
        "body": 'Incomming Audio Call',
        "title":
            '${widget.profileModel.firstName} ${widget.profileModel.secondName}',
        "android_channel_id": "pushnotificationapp",
        "sound": true,
      },
      "data": {"source": "audio", 'roomId': roomId}
    };
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'authorization':
          'key=AAAAAfhc2J0:APA91bFVJOhoyhOnSXRQ5j6mRS8mpJBk3hkbcFNC6o4gLBFmFOLG8uT6rdLf8PlEOupELZ9rZ_fX-QAHIsanJtoT5JccMQve7jrd34y3_vup-hbvlEJYyWGw5YIyhpquwUorbcG1RnaR'
    };
    response = await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: headers, body: jsonEncode(body));
    if (response!.statusCode == 200) {}
  }

  creatCallRoom() async {
    roomId = await signaling.createRoom(CallController.to.remoteRenderer);
    setCallStatus(true, roomId!.trim(), widget.userModel.uid!, true);
    sendNotifcation(roomId!);
    setState(() {});
  }

  void setCallStatus(
      bool status, String roomid, String uid, bool calltype) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update(
        {"callStatus": status, "roomId": roomid, "audiocallStatus": calltype});
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SizedBox(
        height: height,
        width: width,
        child: Stack(
          children: [
            Container(
              height: height,
              width: width,
              color: Mytheme.primaryColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: height * 0.07,
                    width: width,
                    child: Center(
                      child: Text(
                        'Audio Call',
                        style: TextStyle(
                            fontSize: width * 0.05,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  Container(
                    height: height * 0.1,
                    width: width,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Icon(
                      Icons.call,
                      size: width * 0.07,
                      color: Mytheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: SizedBox(
                height: height * 0.1,
                width: width,
                child: Row(
                  children: [
                    SizedBox(
                      width: width * 0.02,
                    ),
                    SizedBox(
                      width: width * 0.02,
                    ),
                    GetBuilder<CallController>(builder: (calobj) {
                      return InkWell(
                        onTap: () {
                          signaling.muteMic();
                        },
                        child: calobj.ismute
                            ? Container(
                                height: height * 0.05,
                                width: width * 0.1,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white),
                                child: Center(
                                    child: Icon(
                                  Icons.speaker_phone_sharp,
                                  color: Mytheme.primaryColor,
                                )),
                              )
                            : Container(
                                height: height * 0.05,
                                width: width * 0.1,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white),
                                child: Center(
                                    child: Icon(
                                  Icons.voice_over_off_sharp,
                                  color: Mytheme.primaryColor,
                                )),
                              ),
                      );
                    }),
                    SizedBox(
                      width: width * 0.02,
                    ),
                    InkWell(
                      onTap: () {
                        signaling.hangUp(CallController.to.localRenderer);
                        setCallStatus(false, '', widget.userModel.uid!, false);
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: height * 0.05,
                        width: width * 0.1,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        child: Center(
                            child: Icon(
                          Icons.call_end,
                          color: Mytheme.primaryColor,
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
