import 'package:audio_video_call/notifcation_servce/notifcation_service.dart';
import 'package:audio_video_call/screens/home_screen.dart';
import 'package:audio_video_call/screens/login_screen.dart';
import 'package:audio_video_call/static_data.dart';
import 'package:audio_video_call/theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        if (message != null) {
          print(message);
        }
      },
    );
    // 2. This method only call when App in forground it mean app must be opened
    FirebaseMessaging.onMessage.listen(
      (message) {
        print(message.data);
        if (message.notification != null) {
          LocalNotificationService.createAndDisplayCallNotification(message);
        }
      },
    );
    // 3. This method only call when App in background and not terminated(not closed)
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        print('app open on click');
        print(message.notification!.body);
        print(message.notification!.title);
        print(message.data);
        if (message.notification != null) {}
      },
    );

    geValuesSF();
  }

  geValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    late String? userid = prefs.getString('UserId');
    late String? userToken = prefs.getString('UserToken');

    if (userid == null) {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushAndRemoveUntil(
            (context),
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false);
      });
    } else {
      StaticData.token = userToken!;
      StaticData.uid = userid;
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushAndRemoveUntil(
            (context),
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Mytheme.primaryColor,
        child: const Center(
          child: Image(
              height: 100,
              color: Colors.white,
              image: AssetImage('assets/logo.png')),
        ),
      ),
    );
  }
}
