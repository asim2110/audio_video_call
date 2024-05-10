import 'dart:convert';

import 'package:audio_video_call/controller/call_controller.dart';
import 'package:audio_video_call/model/user_model.dart';
import 'package:audio_video_call/signaling.dart';
import 'package:audio_video_call/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CallScreen extends StatefulWidget {
  final String roomId;
  final bool callstatus;
  final UserModel profileModel;
  final UserModel userModel;
  CallScreen({
    required this.roomId,
    required this.callstatus,
    required this.userModel,
    required this.profileModel,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  Signaling signaling = Signaling();
  bool ismute = false;
  http.Response? response;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  MediaStream? loacalStream;

  String? roomId;

  @override
  void initState() {
    super.initState();

    roomId = widget.roomId;
    CallController.to.initilizeRTcREneders();
    // _localRenderer.initialize();
    // _remoteRenderer.initialize();
    // CallController.to.initilizeRTcREneders();

    signaling.onAddRemoteStream = ((stream) {
      CallController.to.remoteRenderer.srcObject = stream;
      setState(() {});
    });
    Future.delayed(Duration(seconds: 1), () {
      startCAll(widget.callstatus);
    });
  }

  startCAll(bool value) async {
    await signaling.openUserMedia(
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
        "body": 'Incomming Video Call',
        "title":
            '${widget.profileModel.firstName} ${widget.profileModel.secondName}',
        "android_channel_id": "pushnotificationapp",
        "sound": true,
      },
      "data": {"source": "video", 'roomId': roomId}
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

  creatCallRoom() async {
    roomId = await signaling.createRoom(CallController.to.remoteRenderer);
    setCallStatus(true, roomId!.trim(), widget.userModel.uid!);
    sendNotifcation(roomId!);
    setState(() {});
    print('this is my room id=$roomId');
  }

  void setCallStatus(bool status, String roomid, String uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({"callStatus": status, "roomId": roomid});
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
            SizedBox(
              height: height,
              width: width,
              child: RTCVideoView(
                CallController.to.remoteRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding:
                    EdgeInsets.only(top: height * 0.05, left: width * 0.05),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Container(
                    height: height * 0.15,
                    width: width * 0.3,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    child: RTCVideoView(
                      CallController.to.localRenderer,
                      mirror: true,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  ),
                ),
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
                        signaling.switchCamera();
                      },
                      child: Container(
                        height: height * 0.05,
                        width: width * 0.1,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        child: Center(
                            child: Icon(
                          Icons.switch_camera,
                          color: Mytheme.primaryColor,
                        )),
                      ),
                    ),
                    SizedBox(
                      width: width * 0.02,
                    ),
                    InkWell(
                      onTap: () {
                        signaling.hangUp(CallController.to.localRenderer);
                        setCallStatus(
                          false,
                          '',
                          widget.userModel.uid!,
                        );

                        Navigator.pop(context);
                      },
                      child: Container(
                        height: height * 0.05,
                        width: width * 0.1,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Mytheme.primaryColor),
                        child: const Center(
                            child: Icon(
                          Icons.call_end,
                          color: Colors.white,
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
