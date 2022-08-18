import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:courier_app/Screens/CourierPage/product_product.dart';
import 'package:courier_app/local_notificaiton_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '../../Location/CourierBuildMap.dart';
import '../../constant.dart';
import '../../fcm_notification.dart';

bool isSwitched = false;
String courierState = "Kurye Meşgul";
String userId = "";
String restaurantAddress = "";
String restaurantName = "";
String marketName = "Sekom Market";
List<ProductProduct> productBasketList = [];
String userAddress = "";
bool isRestaurant = true;
bool isArrivedBase = false;
bool isArrivedUser = false;

class CourierPage extends StatefulWidget {
  const CourierPage({Key? key}) : super(key: key);

  @override
  State<CourierPage> createState() => _CourierPageState();
}

class _CourierPageState extends State<CourierPage> {
  late final LocalNotificationService service;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      service = LocalNotificationService();
      service.intialize();

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        // Not firing
        print("Sipariş Hazır!");
        await service.showNotification(
            id: 0,
            title: 'Teslimat Hazır!',
            body: 'Teslimat için hedef konuma gidiniz!');
        print('Kuryeden Mesaj geldi!');
        if (message.data['type'].toString() == "Restaurant") {
          setState(() {
            isRestaurant = true;
          });
        } else {
          setState(() {
            isRestaurant = false;
          });
        }
      });

      FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
        await service.showNotification(
            id: 0,
            title: 'Teslimat Hazır!',
            body: 'Teslimat için hedef konuma gidiniz!');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    FCMNotificaiton fcm = new FCMNotificaiton();
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SizedBox(
              height: 470,
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("CurrentUser")
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      //return const Text('Something went wrong!');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      //return const Text("Loading");
                    }

                    final firstData = snapshot.requireData;

                    userId = firstData.docs.first['user_id'];

                    if (firstData.size > 0) {
                      return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("DetailedUser")
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              //return Text('Something went wrong!');
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              //return Text("Loading");
                            }

                            final secondData = snapshot.requireData;

                            for (var i = 0; i < secondData.size; i++) {
                              if (secondData.docs[i].id == userId) {
                                userAddress = secondData.docs[i]['address'];
                                break;
                              }
                            }

                            Provider.of<AddressesProvider>(context,
                                    listen: false)
                                .setOrderAddress(userAddress);

                            return isRestaurant
                                ? StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection(
                                            userId + ".CurrentRestaurantBasket")
                                        .snapshots(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasError) {
                                        return Column(
                                          children: const [
                                            SizedBox(
                                              height: 100,
                                            ),
                                            Text(
                                                "Sipariş yok! Lütfen bekleme konumuna gidiniz!"),
                                          ],
                                        );
                                      }
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        //return Container();
                                      }

                                      final data = snapshot.requireData.docs;

                                      if (data.isNotEmpty) {
                                        productBasketList.clear();

                                        for (var i = 0; i < data.length; i++) {
                                          productBasketList.add(ProductProduct(
                                            price: data[i]['price'],
                                            name: data[i]['name'],
                                            text: data[i]['text'],
                                            quantitiy: data[i]['quantitiy'],
                                            restaurantName: data[i]
                                                ['restaurant_name'],
                                            restaurantAddress: data[i]
                                                ['restaurant_address'],
                                          ));
                                          restaurantName =
                                              data[i]['restaurant_name'];
                                          restaurantAddress =
                                              data[i]['restaurant_address'];
                                        }

                                        Provider.of<AddressesProvider>(context,
                                                listen: false)
                                            .setRestaurantAddress(
                                                restaurantAddress);

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
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(15),
                                                  bottomRight:
                                                      Radius.circular(15),
                                                ),
                                              ),
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 20),
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
                                                  itemCount:
                                                      productBasketList.length,
                                                  itemBuilder:
                                                      ((context, index) {
                                                    return Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        CourierCard(
                                                          title:
                                                              productBasketList[
                                                                      index]
                                                                  .name,
                                                          content:
                                                              productBasketList[
                                                                      index]
                                                                  .text,
                                                          price:
                                                              productBasketList[
                                                                      index]
                                                                  .price,
                                                          quantity:
                                                              productBasketList[
                                                                      index]
                                                                  .quantitiy,
                                                        ),
                                                      ],
                                                    );
                                                  })),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 20,
                                              ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 4,
                                                        child: Text(
                                                          "Restorant Adresi: " +
                                                              Provider.of<AddressesProvider>(
                                                                      context)
                                                                  .restaurantAddress,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                kOrderPageTextColor,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      GestureDetector(
                                                        onTap: () async {
                                                          setState(() {
                                                            isArrivedBase =
                                                                true;
                                                          });

                                                          Provider.of<CourierStateProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .setGoingRestaurant();
                                                          // User Basket delete
                                                          // Send notification to User and local
                                                          String device_token =
                                                              "";

                                                          CollectionReference
                                                              _collectionRef =
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      "CurrentUser");
                                                          // Get docs from collection reference
                                                          QuerySnapshot
                                                              querySnapshot =
                                                              await _collectionRef
                                                                  .get();
                                                          // Get data from docs and convert map to List
                                                          final data =
                                                              querySnapshot
                                                                  .docs;

                                                          for (var i = 0;
                                                              i < data.length;
                                                              i++) {
                                                            device_token = data[
                                                                    i][
                                                                'device_token'];
                                                          }

                                                          fcm.callOnFcmApiSendPushNotifications(
                                                              title:
                                                                  'Siparişiniz Gelmek Üzere!',
                                                              body:
                                                                  'Kuryemiz çok yakında kapınızda olacak!',
                                                              device_token:
                                                                  device_token);
                                                        },
                                                        child: Expanded(
                                                          flex: 1,
                                                          child: Container(
                                                            height: 50,
                                                            width: 50,
                                                            child: const Icon(
                                                              Icons.check,
                                                              size: 28,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: isArrivedBase
                                                                  ? kOrderPageButtonColor
                                                                  : Colors.grey,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .black,
                                                                  width: 2),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    width: 20,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: Text(
                                                          "Sipariş Adresi: " +
                                                              Provider.of<AddressesProvider>(
                                                                      context)
                                                                  .orderAddress,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                kOrderPageTextColor,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      isArrivedBase
                                                          ? GestureDetector(
                                                              onTap: () async {
                                                                setState(() {
                                                                  isArrivedUser =
                                                                      true;
                                                                });

                                                                Provider.of<CourierStateProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .setGoingUser();
                                                                // User Basket delete
                                                                // Send notification to User and local
                                                                String
                                                                    device_token =
                                                                    "";

                                                                CollectionReference
                                                                    _collectionRef =
                                                                    FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            "CurrentUser");
                                                                // Get docs from collection reference
                                                                QuerySnapshot
                                                                    querySnapshot =
                                                                    await _collectionRef
                                                                        .get();
                                                                // Get data from docs and convert map to List
                                                                final data =
                                                                    querySnapshot
                                                                        .docs;

                                                                for (var i = 0;
                                                                    i < data.length;
                                                                    i++) {
                                                                  device_token =
                                                                      data[i][
                                                                          'device_token'];
                                                                }

                                                                fcm.callOnFcmApiSendPushNotifications(
                                                                    title:
                                                                        'Siparişiniz Gelmek Üzere!',
                                                                    body:
                                                                        'Kuryemiz çok yakında kapınızda olacak!',
                                                                    device_token:
                                                                        device_token);
                                                              },
                                                              child: Expanded(
                                                                flex: 1,
                                                                child:
                                                                    Container(
                                                                  height: 50,
                                                                  width: 50,
                                                                  child:
                                                                      const Icon(
                                                                    Icons.check,
                                                                    size: 28,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: isArrivedUser
                                                                        ? kOrderPageButtonColor
                                                                        : Colors
                                                                            .grey,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            100),
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .black,
                                                                        width:
                                                                            2),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : Container(),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                          ],
                                        );
                                      } else {
                                        return Column(
                                          children: const [
                                            SizedBox(
                                              height: 100,
                                            ),
                                            Text(
                                                "Sipariş yok! Lütfen bekleme konumuna gidiniz!"),
                                          ],
                                        );
                                      }
                                    })
                                : StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection(
                                            userId + ".CurrentMarketBasket")
                                        .snapshots(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasError) {
                                        //return Text('Something went wrong!');
                                      }
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        //return Text("Loading");
                                      }

                                      final data = snapshot.requireData.docs;

                                      if (data.isNotEmpty) {
                                        productBasketList.clear();

                                        for (var i = 0; i < data.length; i++) {
                                          productBasketList.add(ProductProduct(
                                            price: data[i]['price'],
                                            name: data[i]['name'],
                                            text: data[i]['text'],
                                            quantitiy: data[i]['quantitiy'],
                                            restaurantName: "",
                                            restaurantAddress: "",
                                          ));
                                        }

                                        Provider.of<AddressesProvider>(context,
                                                listen: false)
                                            .setRestaurantAddress(
                                                restaurantAddress);

                                        return Column(
                                          children: [
                                            Container(
                                              height: 100,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: kOrderPageButtonColor,
                                                border: Border.all(
                                                  color: Colors.black,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(15),
                                                  bottomRight:
                                                      Radius.circular(15),
                                                ),
                                              ),
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 20),
                                                  child: Text(
                                                    marketName,
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
                                                  itemCount:
                                                      productBasketList.length,
                                                  itemBuilder:
                                                      ((context, index) {
                                                    return Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        CourierCard(
                                                          title:
                                                              productBasketList[
                                                                      index]
                                                                  .name,
                                                          content:
                                                              productBasketList[
                                                                      index]
                                                                  .text,
                                                          price:
                                                              productBasketList[
                                                                      index]
                                                                  .price,
                                                          quantity:
                                                              productBasketList[
                                                                      index]
                                                                  .quantitiy,
                                                        ),
                                                      ],
                                                    );
                                                  })),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 20,
                                              ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Market Adresi: Sekomların Evi",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              kOrderPageTextColor,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      GestureDetector(
                                                        onTap: () async {
                                                          setState(() {
                                                            isArrivedBase =
                                                                true;
                                                          });

                                                          Provider.of<CourierStateProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .setGoingRestaurant();

                                                          // User Basket delete
                                                          // Send notification to User and local
                                                          String device_token =
                                                              "";

                                                          CollectionReference
                                                              _collectionRef =
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      "CurrentUser");
                                                          // Get docs from collection reference
                                                          QuerySnapshot
                                                              querySnapshot =
                                                              await _collectionRef
                                                                  .get();
                                                          // Get data from docs and convert map to List
                                                          final data =
                                                              querySnapshot
                                                                  .docs;

                                                          for (var i = 0;
                                                              i < data.length;
                                                              i++) {
                                                            device_token = data[
                                                                    i][
                                                                'device_token'];
                                                          }

                                                          fcm.callOnFcmApiSendPushNotifications(
                                                              title:
                                                                  'Siparişiniz Gelmek Üzere!',
                                                              body:
                                                                  'Kuryemiz çok yakında kapınızda olacak!',
                                                              device_token:
                                                                  device_token);
                                                        },
                                                        child: Container(
                                                          height: 50,
                                                          width: 50,
                                                          child: const Icon(
                                                            Icons.check,
                                                            size: 28,
                                                            color: Colors.white,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: isArrivedBase
                                                                ? kOrderPageButtonColor
                                                                : Colors.grey,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 30,
                                                  ),
                                                  isArrivedBase
                                                      ? Row(
                                                          children: [
                                                            Text(
                                                              "Sipariş Adresi: " +
                                                                  Provider.of<AddressesProvider>(
                                                                          context)
                                                                      .orderAddress,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                                color:
                                                                    kOrderPageTextColor,
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () async {
                                                                setState(() {
                                                                  isArrivedUser =
                                                                      true;
                                                                });

                                                                Provider.of<CourierStateProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .setGoingUser();
                                                                // User Basket delete
                                                                // Send notification to User and local
                                                                String
                                                                    device_token =
                                                                    "";

                                                                CollectionReference
                                                                    _collectionRef =
                                                                    FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            "CurrentUser");
                                                                // Get docs from collection reference
                                                                QuerySnapshot
                                                                    querySnapshot =
                                                                    await _collectionRef
                                                                        .get();
                                                                // Get data from docs and convert map to List
                                                                final data =
                                                                    querySnapshot
                                                                        .docs;

                                                                for (var i = 0;
                                                                    i < data.length;
                                                                    i++) {
                                                                  device_token =
                                                                      data[i][
                                                                          'device_token'];
                                                                }

                                                                fcm.callOnFcmApiSendPushNotifications(
                                                                    title:
                                                                        'Siparişiniz Gelmek Üzere!',
                                                                    body:
                                                                        'Kuryemiz çok yakında kapınızda olacak!',
                                                                    device_token:
                                                                        device_token);
                                                              },
                                                              child: Container(
                                                                height: 50,
                                                                width: 50,
                                                                child:
                                                                    const Icon(
                                                                  Icons.check,
                                                                  size: 28,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: isArrivedUser
                                                                      ? kOrderPageButtonColor
                                                                      : Colors
                                                                          .grey,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              100),
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .black,
                                                                      width: 2),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : Container(),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                          ],
                                        );
                                      } else {
                                        return Column(
                                          children: const [
                                            SizedBox(
                                              height: 100,
                                            ),
                                            Text(
                                                "Sipariş yok! Lütfen bekleme konumuna gidiniz!"),
                                          ],
                                        );
                                      }
                                    });
                          });
                    } else {
                      return Column(
                        children: const [
                          SizedBox(
                            height: 100,
                          ),
                          Text("Sipariş yok! Lütfen bekleme konumuna gidiniz!"),
                        ],
                      );
                    }
                  }),
            ),
            isArrivedBase
                ? isArrivedUser
                    ? GestureDetector(
                        onTap: () {
                          //

                          Provider.of<CourierStateProvider>(context,
                                  listen: false)
                              .setGoingOptimumPlace();
                        },
                        child: Container(
                          height: 60,
                          width: 200,
                          decoration: BoxDecoration(
                            color: kOrderPageButtonColor,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: const Center(
                            child: Text(
                              "Teslimatı Tamamla",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    : Container()
                : Container(),
            const SizedBox(
              height: 15,
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
                          Provider.of<CourierStateProvider>(context,
                                  listen: false)
                              .setIdle();
                        } else {
                          courierState = "Kurye Dinleniyor";
                          Provider.of<CourierStateProvider>(context,
                                  listen: false)
                              .setIdle();
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
            const SizedBox(
              height: 20,
            ),
            const Text("Sipariş teslim edildi!"),
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
              child: CourierBuildMap(
                  secondEndLocation:
                      Provider.of<AddressesProvider>(context, listen: false)
                          .orderAddress,
                  firstEndLocation:
                      Provider.of<AddressesProvider>(context, listen: false)
                          .restaurantAddress,
                  courrierState:
                      Provider.of<CourierStateProvider>(context, listen: false)
                          .courierState),
            ),
          );
        },
      ),
    );
  }
}

class CourierStateProvider with ChangeNotifier {
  int courierState = -1;

  void setIdle() {
    courierState = -1;
    notifyListeners();
  }

  void setGoingRestaurant() {
    courierState = 0;
    notifyListeners();
  }

  void setGoingUser() {
    courierState = 1;
    notifyListeners();
  }

  void setGoingOptimumPlace() {
    courierState = 2;
    notifyListeners();
  }
}

class AddressesProvider with ChangeNotifier {
  String orderAddress = "";
  String restaurantAddress = "";

  void setOrderAddress(String order_address) {
    orderAddress = order_address;
    notifyListeners();
  }

  void setRestaurantAddress(String res_address) {
    restaurantAddress = res_address;
    notifyListeners();
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
        width: size.width * 0.80,
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
                                  " ( " +
                                  content! +
                                  " )",
                              style: const TextStyle(
                                fontSize: 16,
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
                              fontSize: 16,
                              color: Colors.white,
                            ),
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
