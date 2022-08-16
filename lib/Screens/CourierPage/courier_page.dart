import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:courier_app/Screens/CourierPage/product_product.dart';
import 'package:courier_app/local_notificaiton_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import '../../Location/CourierBuildMap.dart';
import '../../constant.dart';

bool isSwitched = false;
String courierState = "Kurye Meşgul";
String userId = "";
String restaurantAddress = "";
String restaurantName = "";
List<ProductProduct> productBasketList = [];
String userAddress = "";

class CourierPage extends StatefulWidget {
  const CourierPage({Key? key}) : super(key: key);

  @override
  State<CourierPage> createState() => _CourierPageState();
}

class _CourierPageState extends State<CourierPage> {
  late final LocalNotificationService service;

  Future<void> addDeviceTokenToDetailedUser() async {
    String? token = await FirebaseMessaging.instance.getToken();

    await FirebaseFirestore.instance
        .collection('CurrentCourier')
        .doc("CurrentCourierDoc")
        .set(
      {
        "device_token": token,
      },
    );
  }

  Future<void> getCurrentUserId() async {
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection("CurrentUser");
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await _collectionRef.get();
    // Get data from docs and convert map to List
    final data = querySnapshot.docs;

    for (var i = 0; i < data.length; i++) {
      userId = data[i]['user_id'];
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      service = LocalNotificationService();
      await service.intialize();
      await addDeviceTokenToDetailedUser();
      await getCurrentUserId();
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // Not firing
      print("Sipariş Hazır!");
      await service.showNotification(
          id: 0,
          title: 'Teslimat Hazır!',
          body: 'Teslimat için hedef konuma gidiniz!');
      print('Kuryeden Mesaj geldi!');
    });

    /*FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
      await service.showNotification(
          id: 0,
          title: 'Teslimat Hazır!',
          body: 'Teslimat için hedef konuma gidiniz!');
    });*/

    super.initState();
    setState(() {
      print("abc");
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SizedBox(
              height: 450,
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection(userId + ".CurrentRestaurantBasket")
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      //return const Text('Something went wrong!');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      //return const Text("Loading");
                    }

                    final data = snapshot.requireData;

                    if (data.size > 0) {
                      restaurantName = data.docs.first['restaurant_name'];
                      restaurantAddress = data.docs.first['restaurant_address'];

                      return Column(
                        children: [
                          Container(
                            height: 80,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: kOrderPageButtonColor,
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              ),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Text(
                                  restaurantName,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            child: ListView.builder(
                                itemCount: data.size,
                                itemBuilder: ((context, index) {
                                  return Row(children: [
                                    CourierCard(
                                      title: data.docs[index]['name'],
                                      content: data.docs[index]['text'],
                                      price: data.docs[index]['price'],
                                      quantity: data.docs[index]['quantitiy'],
                                    ),
                                  ]);
                                })),
                          ),
                          Text(
                            "Restorant Adresi: " + restaurantAddress,
                            style: const TextStyle(
                              fontSize: 20,
                              color: kOrderPageTextColor,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Sipariş Adresi: " + restaurantAddress,
                            style: const TextStyle(
                              fontSize: 20,
                              color: kOrderPageTextColor,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Text(
                          "Sipariş yok! Lütfen bekleme konumuna gidiniz!");
                    }
                  }),
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
        child: const Icon(
          Icons.gps_fixed,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeftWithFade,
              duration: const Duration(milliseconds: 200),
              child: const CourierBuildMap(),
            ),
          );
        },
      ),
    );
  }
}

class CourierCard extends StatelessWidget {
  final String? title;
  final double? price;
  final String? content;
  final String? imagePath;
  final int? quantity;

  const CourierCard({
    Key? key,
    this.title,
    this.content,
    this.imagePath,
    this.price,
    this.quantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Container(
        height: size.height * 0.13,
        width: size.width * 0.9,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: kOrderPageButtonColor,
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 20,
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              quantity.toString() +
                                  " adet " +
                                  title! +
                                  "( " +
                                  content! +
                                  " )",
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          Text(
                            "Fiyat: ₺" + price!.toStringAsFixed(2),
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
