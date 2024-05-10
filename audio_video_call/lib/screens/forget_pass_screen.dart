import 'package:audio_video_call/screens/login_screen.dart';
import 'package:audio_video_call/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgetPassScreen extends StatefulWidget {
  const ForgetPassScreen({Key? key}) : super(key: key);

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
  var height, width;
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SizedBox(
            height: height,
            width: width,
            child: Form(
              key: _formKey,
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
                      child: const Center(
                        child: Text('Recover Password',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.1,
                  ),
                  SizedBox(
                    height: height * 0.2,
                    width: width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'FORGET PASSWORD',
                          style: TextStyle(
                              color: Mytheme.primaryColor,
                              fontSize: width * 0.05,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Enter your Email and we will send you a recover password Link',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: width * 0.04,
                              fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.05, right: width * 0.05),
                    child: TextFormField(
                        autofocus: false,
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return ("Please Enter Your Email");
                          }
                          // reg expression for email validation
                          if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                              .hasMatch(value)) {
                            return ("Please Enter a valid email");
                          }
                          return null;
                        },
                        onSaved: (value) {
                          emailController.text = value!;
                        },
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.mail,
                            color: Mytheme.primaryColor,
                          ),
                          contentPadding:
                              const EdgeInsets.fromLTRB(20, 15, 20, 15),
                          hintText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        )),
                  ),
                  SizedBox(
                    height: height * 0.1,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.05, right: width * 0.05),
                    child: Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(10),
                      color: Mytheme.primaryColor,
                      child: MaterialButton(
                          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                          minWidth: MediaQuery.of(context).size.width,
                          onPressed: () {
                            forget(emailController.text);
                          },
                          child: const Text(
                            "Send",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                    ),
                  )
                ],
              ),
            )));
  }

  forget(String email) async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.sendPasswordResetEmail(
          email: email,
        );

        Fluttertoast.showToast(msg: "Link Send Successful");
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      } catch (e) {
        print(e);
      }
    }
  }
}
