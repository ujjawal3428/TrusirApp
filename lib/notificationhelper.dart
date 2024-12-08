import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'package:trusir/main.dart';

Future<void> showDownloadNotification(String filename, String filePath) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'download_channel',
    'Downloads',
    channelDescription: 'Notifications for download status',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: true,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    'Download Successful',
    filename,
    platformChannelSpecifics,
    payload: filePath, // Pass the file path as payload
  );
}

void handleNotificationTap(String filePath) {
  OpenFile.open(filePath); // Open the file when notification is tapped
}
