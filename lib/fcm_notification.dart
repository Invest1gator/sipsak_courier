import 'dart:convert';

import 'package:http/http.dart' as http;

class FCMNotificaiton {
  Future<bool> callOnFcmApiSendPushNotifications({
    required String title,
    required String body,
    required String device_token,
    required String from,
  }) async {
    const postUrl = 'https://fcm.googleapis.com/fcm/send';
    final data = {
      "to": device_token,
      "notification": {
        "title": title,
        "body": body,
      },
      "data": {
        "type": from == "Restaurant"
            ? 'Restaurant'
            : from == "Market"
                ? 'Market'
                : from == "Finish"
                    ? 'Finish'
                    : '',
        "id": '28',
        "click_action": 'FLUTTER_NOTIFICATION_CLICK',
      }
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=AAAA83fQ5ws:APA91bFTKvfHiHcfPYe-MNnO5bjLJFgptWOL88NiTJ7VdjDdsC868mLNWVqI4Txvbqj6ylOd6Bxa_yI9NR8FqI-QM8kPYYfEI-v0vk7L7tKvFExQsTc9DgpKSPYrq-vz8x--LfdS3Gmk'
      // 'key=YOUR_SERVER_KEY'
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
}
