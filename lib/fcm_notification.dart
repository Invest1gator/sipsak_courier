import 'dart:convert';

import 'package:http/http.dart' as http;

class FCMNotificaiton {
  Future<bool> callOnFcmApiSendPushNotifications({
    required String title,
    required String body,
    required String device_token,
  }) async {
    const postUrl = 'https://fcm.googleapis.com/fcm/send';
    final data = {
      "to":
          "c46_qIMHQRubXj4_jKPPuG:APA91bEyTTvaNYhFjMCC4mT3AwZe91rqvAm5ujgiWSp6sdwRe-PBiPk4Wff93kgxdkVf3IkNJ8QOQ-0o6U-lu3_81PYTj04yqvF88VehOnHZKIGjLgs0qxsQdft0gmVkZ_NcmiQs5RnL",
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
}
