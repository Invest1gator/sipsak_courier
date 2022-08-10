// ignore_for_file: prefer_const_constructors, duplicate_ignore

import 'dart:convert';

import 'package:courier_app/Screens/courier_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';
import '../../../components/already_have_account_check.dart';
import '../../../components/rounded_button.dart';
import '../../../components/rounded_input_field.dart';
import '../../../components/rounded_password_field.dart';
import '../../../constant.dart';
import 'background.dart';
import 'package:http/http.dart' as http;

class Body extends StatelessWidget {
  Future<bool> callOnFcmApiSendPushNotifications(
      {required String title, required String body}) async {
    const postUrl = 'https://fcm.googleapis.com/fcm/send';
    final data = {
      "to":
          "fN9JkU1n_UUfR9oWAY4eEl:APA91bFXIrNMvuyhOlknMZ4uqwzXwS-rtFoKC8Y96YX-Ybwv4PLXE1x2LILYqqAiqHG7LNrSVbh2Inb37SUFUo2U9zLJergRx_OpU5K9kzvwvnr6B166YR_yw5DfleAKSNY4cMgkRv3t",
      "notification": {
        "title": title,
        "body": body,
      },
      "data": {
        "type": '0rder',
        "id": '28',
        "click_action": 'FLUTTER_NOTIFICATION_CLICK',
      }
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=AAAA83fQ5ws:APA91bFTKvfHiHcfPYe-MNnO5bjLJFgptWOL88NiTJ7VdjDdsC868mLNWVqI4Txvbqj6ylOd6Bxa_yI9NR8FqI-QM8kPYYfEI-v0vk7L7tKvFExQsTc9DgpKSPYrq-vz8x--LfdS3Gmk' // 'key=YOUR_SERVER_KEY'
    };

    final response = await http.post(Uri.parse(postUrl),
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      // on success do sth
      print('test ok push CFM');
      return true;
    } else {
      print(' CFM error');
      // on failure do sth
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Background(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: size.height * 0.03,
            ),
            SvgPicture.asset(
              "assets/icons/login.svg",
              height: size.height * 0.35,
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            // ignore: prefer_const_constructors
            RoundedInputField(
              hintText: "Kullanıcı Adınız",
              onChanged: (value) {},
              icon: Icons.person,
            ),
            RoundedPasswordField(
              onChanged: (value) {},
            ),
            RoundedButton(
              text: "GİRİŞ YAP",
              color: kPrimaryColor,
              textColor: kTextColorWhite,
              press: () {
                callOnFcmApiSendPushNotifications(
                    body:
                        'Sipariş geldi lütfen sipariş kutusunu kontrol ediniz!',
                    title: 'Sipariş Geldi!');
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.leftToRight,
                    child: CourierPage(),
                  ),
                );
              },
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
          ],
        ),
      ),
    );
  }
}
