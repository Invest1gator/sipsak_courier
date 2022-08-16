// ignore_for_file: prefer_const_constructors, duplicate_ignore

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:courier_app/Screens/CourierPage/courier_page.dart';
import 'package:courier_app/fcm_notification.dart';
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

class Body extends StatelessWidget {
  FCMNotificaiton fcm = new FCMNotificaiton();

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
              press: () async {
                String device_token = "";

                CollectionReference _collectionRef =
                    FirebaseFirestore.instance.collection("CurrentUser");
                // Get docs from collection reference
                QuerySnapshot querySnapshot = await _collectionRef.get();
                // Get data from docs and convert map to List
                final data = querySnapshot.docs;

                for (var i = 0; i < data.length; i++) {
                  device_token = data[i]['device_token'];
                }

                fcm.callOnFcmApiSendPushNotifications(
                    title: 'Siparişiniz Gelmek Üzere!',
                    body: 'Kuryemiz çok yakında kapınızda olacak!',
                    device_token: device_token);

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
