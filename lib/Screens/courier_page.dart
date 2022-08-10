import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import '../Location/CourierBuildMap.dart';
import '../constant.dart';

class CourierPage extends StatefulWidget {
  const CourierPage({Key? key}) : super(key: key);

  @override
  State<CourierPage> createState() => _CourierPageState();
}

class _CourierPageState extends State<CourierPage> {
  bool isSwitched = false;
  String courierState = "Kurye Meşgul";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Şipşak Kurye Sayfası",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 218, 196, 4)),
                  ),
                  Icon(
                    Icons.person,
                    size: 34,
                    color: Color.fromARGB(255, 218, 196, 4),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 5,
              thickness: 2,
            ),
            const Divider(
              height: 10,
              thickness: 2,
            ),
            const SizedBox(
              height: 8,
            ),
            const CourierCard(
              title: "Product Type",
              content: "Hamburger",
              imagePath: "",
            ),
            const CourierCard(
              title: "Product Content",
              content: "1 Hamburger",
              imagePath: "",
            ),
            const CourierCard(
              title: "Payment Method",
              content: "Credit Card",
              imagePath: "",
            ),
            Container(
              color: Colors.amber[200],
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 1,
                  ),
                  const Icon(
                    Icons.motorcycle,
                    size: 40,
                  ),
                  Text(
                    courierState,
                    style: const TextStyle(fontSize: 20),
                  ),
                  Switch(
                    value: isSwitched,
                    onChanged: (value) {
                      setState(() {
                        if (!isSwitched) {
                          courierState = "Kurye Çalışıyor";
                        } else {
                          courierState = "Kurye Dinleniyor";
                        }
                        isSwitched = value;
                      });
                    },
                    activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,
                    inactiveTrackColor: Colors.redAccent,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: size.height * 0.38,
              width: size.width * 1,
              child: Lottie.network(
                  "https://assets10.lottiefiles.com/packages/lf20_3ls8a1y5.json"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        highlightElevation: 50,
        elevation: 12,
        backgroundColor: Colors.blue.withOpacity(0.8),
        child: Icon(
          Icons.gps_fixed,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeftWithFade,
              duration: Duration(milliseconds: 200),
              child: CourierBuildMap(),
            ),
          );
        },
      ),
    );
  }
}

class CourierCard extends StatelessWidget {
  final String? title;
  final String? content;
  final String? imagePath;

  const CourierCard({
    Key? key,
    this.title,
    this.content,
    this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Container(
        height: size.height * 0.13,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: KprimaryColor,
            border: Border.all(
              width: 2,
              color: const Color.fromARGB(255, 11, 12, 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 3),
              )
            ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              radius: 40,
            ),
            const SizedBox(
              width: 40,
            ),
            SizedBox(
              width: size.width * 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        title!,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        content!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
