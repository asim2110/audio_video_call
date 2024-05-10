import 'package:audio_video_call/controller/call_controller.dart';
import 'package:audio_video_call/screens/audio_call.dart';
import 'package:audio_video_call/static_data.dart';
import 'package:audio_video_call/theme.dart';
import 'package:get/get.dart';
import 'package:audio_video_call/model/user_model.dart';
import 'package:audio_video_call/screens/call%20_screen.dart';
import 'package:audio_video_call/screens/chat_screen.dart';
import 'package:audio_video_call/signaling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Signaling signaling = Signaling();
  UserModel loggedInUser = UserModel();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    Get.put(CallController());

    WidgetsBinding.instance!.addObserver(this);

    FirebaseFirestore.instance
        .collection("users")
        .doc(StaticData.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {
        getUser();
        setStatus(true);
      });
    });
  }

  void setStatus(bool status) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(StaticData.uid)
        .update({
      "status": status,
    });
  }

  @override
  void dispose() {
    CallController.to.dispozeRtcRenders();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus(true);
    } else {
      // offline
      setStatus(false);
    }
  }

  Future<List<UserModel>> getUser() async {
    List<UserModel> allUsers = [];
    var list = await FirebaseFirestore.instance
        .collection("users")
        .where('status', isEqualTo: true)
        .get();
    for (var u in list.docs) {
      allUsers.add(UserModel.fromMap(u.data()));
    }
    return allUsers;
  }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(StaticData.uid)
              .snapshots(),
          builder: (context, profileSnapshot) {
            return SizedBox(
              height: height,
              width: width,
              child: Stack(
                children: [
                  SizedBox(
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
                            padding: EdgeInsets.only(
                                right: width * 0.02, left: width * 0.02),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                    'Welcome ${loggedInUser.firstName} ${loggedInUser.secondName}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500)),
                                Expanded(
                                    child: SizedBox(
                                  width: width,
                                )),
                                InkWell(
                                    onTap: () {
                                      logout(context);
                                    },
                                    child: const Icon(
                                      Icons.logout,
                                      color: Colors.white,
                                    )),
                                SizedBox(
                                  width: width * 0.02,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: _firestore
                                .collection('users')
                                .where('uid', isNotEqualTo: StaticData.uid)
                                .snapshots(),
                            builder: (context, newsnapshot) {
                              return newsnapshot.data != null
                                  ? SizedBox(
                                      height: height,
                                      width: width,
                                      child: ListView.builder(
                                          itemCount:
                                              newsnapshot.data!.docs.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                  top: height * 0.02,
                                                  left: width * 0.03,
                                                  right: width * 0.03),
                                              child: InkWell(
                                                onTap: () {
                                                  String id = chatRoomId(
                                                      '${loggedInUser.uid}',
                                                      '${newsnapshot.data!.docs[index].get('uid')}');

                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ChatScreen(
                                                          chatroomId: id,
                                                          userModel:
                                                              UserModel.fromMap(
                                                                  newsnapshot
                                                                      .data!
                                                                      .docs[
                                                                          index]
                                                                      .data()),
                                                          profileModel:
                                                              loggedInUser,
                                                          username:
                                                              '${loggedInUser.firstName}${loggedInUser.secondName}',
                                                        ),
                                                      ));
                                                },
                                                child: Container(
                                                  height: height * 0.1,
                                                  width: width,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          Mytheme.primaryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: width *
                                                                    0.02,
                                                                right: width *
                                                                    0.02),
                                                        child: SizedBox(
                                                          height: height * 0.06,
                                                          width: width,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                '${newsnapshot.data!.docs[index].get('firstName')} ${newsnapshot.data!.docs[index].get('secondName')}',
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                              const Icon(
                                                                  Icons.chat,
                                                                  color: Colors
                                                                      .white)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: width *
                                                                    0.02,
                                                                right: width *
                                                                    0.02),
                                                        child: Text(
                                                          newsnapshot
                                                                      .data!
                                                                      .docs[
                                                                          index]
                                                                      .get(
                                                                          'status') ==
                                                                  true
                                                              ? 'Online'
                                                              : 'Offline',
                                                          style: TextStyle(
                                                              color: newsnapshot
                                                                          .data!
                                                                          .docs[
                                                                              index]
                                                                          .get(
                                                                              'status') ==
                                                                      true
                                                                  ? Colors.black
                                                                  : Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                    )
                                  : const Center(
                                      child: CircularProgressIndicator());
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  profileSnapshot.data != null
                      ? profileSnapshot.data!.get('callStatus') == true
                          ? Align(
                              alignment: Alignment.center,
                              child: Card(
                                elevation: 8,
                                color: Mytheme.primaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                child: Container(
                                  height: height * 0.4,
                                  width: width * 0.8,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                          color: Colors.white, width: 4)),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: height * 0.07,
                                        width: width,
                                        child: Center(
                                          child: Text(
                                            '${profileSnapshot.data!.get('roomId')}',
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
                                            color: Colors.white,
                                            shape: BoxShape.circle),
                                        child: Icon(
                                          Icons.call,
                                          size: width * 0.07,
                                          color: Mytheme.primaryColor,
                                        ),
                                      ),
                                      Expanded(
                                        child: SizedBox(
                                          height: height,
                                          width: width,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              InkWell(
                                                onTap: () async {
                                                  signaling.hangUp(
                                                      CallController
                                                          .to.localRenderer);
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .doc(profileSnapshot.data!
                                                          .get('uid'))
                                                      .update({
                                                    "callStatus": false,
                                                    "roomId": ''
                                                  });
                                                },
                                                child: Container(
                                                  height: height * 0.06,
                                                  width: width * 0.12,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Colors.white,
                                                          shape:
                                                              BoxShape.circle),
                                                  child: Icon(
                                                    Icons.call_end,
                                                    size: width * 0.05,
                                                    color: Mytheme.primaryColor,
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () async {
                                                  if (profileSnapshot.data!.get(
                                                          'audiocallStatus') ==
                                                      true) {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              AudioCall(
                                                            roomId:
                                                                profileSnapshot
                                                                    .data!
                                                                    .get(
                                                                        'roomId'),
                                                            callstatus: true,
                                                            profileModel:
                                                                loggedInUser,
                                                            userModel:
                                                                loggedInUser,
                                                          ),
                                                        ));
                                                  } else {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              CallScreen(
                                                            roomId:
                                                                profileSnapshot
                                                                    .data!
                                                                    .get(
                                                                        'roomId'),
                                                            callstatus: true,
                                                            profileModel:
                                                                loggedInUser,
                                                            userModel:
                                                                loggedInUser,
                                                          ),
                                                        ));
                                                  }

                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .doc(profileSnapshot.data!
                                                          .get('uid'))
                                                      .update({
                                                    "callStatus": false,
                                                    "roomId": ''
                                                  });
                                                },
                                                child: Container(
                                                  height: height * 0.06,
                                                  width: width * 0.12,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Colors.white,
                                                          shape:
                                                              BoxShape.circle),
                                                  child: Icon(
                                                    Icons.call,
                                                    size: width * 0.07,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox()
                      : const SizedBox()
                ],
              ),
            );
          }),
    );
  }

  // the logout function
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.getKeys();
    preferences.clear();
    setStatus(false);
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()));
  }
}
