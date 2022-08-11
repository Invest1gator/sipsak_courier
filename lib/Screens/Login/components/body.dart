// ignore_for_file: prefer_const_constructors, duplicate_ignore

import 'package:courier_app/Screens/courier_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';
import '../../../components/already_have_account_check.dart';
import '../../../components/rounded_button.dart';
import '../../../components/rounded_input_field.dart';
import '../../../components/rounded_password_field.dart';
import '../../../constant.dart';
import '../../../Location/CourierMap.dart';
import 'background.dart';

class Body extends StatelessWidget {
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
