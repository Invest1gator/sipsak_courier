// ignore_for_file: prefer_const_constructors, duplicate_ignore

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:courier_app/Screens/CourierPage/courier_page.dart';
import 'package:courier_app/fcm_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import '../../../components/already_have_account_check.dart';
import '../../../components/rounded_button.dart';
import '../../../components/rounded_input_field.dart';
import '../../../components/rounded_password_field.dart';
import '../../../constant.dart';
import '../../../Location/CourierMap.dart';
import 'background.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

bool loading = false;
bool hasError = false;
bool hasPassError = false;
bool hasUsernameError = false;

String _username = '';
String _password = '';
String _error = "";
String _usernameError = "";
String _passError = "";

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Background(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: size.height * 0.03,
            ),
            SizedBox(
              height: size.height * 0.38,
              width: size.width * 1,
              child: Lottie.network(
                  "https://assets10.lottiefiles.com/packages/lf20_3ls8a1y5.json"),
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            // ignore: prefer_const_constructors
            RoundedInputField(
              hintText: "Kullanıcı Adınız",
              onChanged: (val) {
                setState(() {
                  _username = val;
                });

                if (!isUsernameValid(val)) {
                  setState(() {
                    hasUsernameError = true;
                    _usernameError =
                        'Lütfen geçerli bir kullanıcı adı giriniz.';
                  });
                } else {
                  setState(() {
                    hasUsernameError = false;
                    _usernameError = '';
                  });
                }
              },
              icon: Icons.person,
            ),
            hasUsernameError
                ? Text(
                    _usernameError,
                    style: TextStyle(color: Colors.red, fontSize: 15),
                  )
                : Text(""),
            RoundedPasswordField(
              onChanged: (val) {
                setState(() {
                  _password = val;
                });

                if (!isPasswordValid(val)) {
                  setState(() {
                    hasPassError = true;
                    _passError =
                        'Şifreniz en az 6 karakter uzunluğunda olmalı.';
                  });
                } else {
                  setState(() {
                    hasPassError = false;
                    _passError = '';
                  });
                }
              },
            ),
            hasPassError
                ? Text(
                    _passError,
                    style: TextStyle(color: Colors.red, fontSize: 15),
                  )
                : Text(""),
            !loading
                ? RoundedButton(
                    text: "GİRİŞ YAP",
                    color: kPrimaryColor,
                    textColor: kTextColorWhite,
                    press: () async {
                      setState(() => loading = true);

                      bool isLogSuccess = false;

                      hasError = false;

                      CollectionReference _collectionRef =
                          FirebaseFirestore.instance.collection("Courier");

                      String username = "";
                      String pass = "";

                      // Get docs from collection reference
                      QuerySnapshot querySnapshot = await _collectionRef.get();
                      final data = querySnapshot.docs;

                      for (var i = 0; i < data.length; i++) {
                        if (data[i]['username'] == _username.trim() &&
                            data[i]['password'] == _password) {
                          isLogSuccess = true;
                          break;
                        }
                      }

                      if (isLogSuccess) {
                        snackBar("Giriş Başarılı!");

                        // Get Courier Token
                        String? token =
                            await FirebaseMessaging.instance.getToken();

                        await FirebaseFirestore.instance
                            .collection('CurrentCourier')
                            .doc("CurrentCourierDoc")
                            .set(
                          {
                            "device_token": token,
                          },
                        );

                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.leftToRight,
                            child: CourierPage(),
                          ),
                        );
                      } else {
                        snackBar("Giriş  Başarısız!");
                        setState(() {
                          hasError = true;
                          _error = "Giriş yapılamadı: Kimlik bilgileri yanlış!";
                          loading = false;
                        });
                      }
                    },
                  )
                : CircularProgressIndicator(),
            hasError
                ? Text(
                    _error,
                    style: TextStyle(color: Colors.red, fontSize: 15),
                  )
                : Text(""),
            SizedBox(
              height: size.height * 0.03,
            ),
          ],
        ),
      ),
    );
  }

  snackBar(String? message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
        duration: const Duration(seconds: 2),
        backgroundColor: kPrimaryColor,
      ),
    );
  }
}

bool isUsernameValid(String password) => password.length >= 6;

bool isPasswordValid(String password) => password.length >= 6;
