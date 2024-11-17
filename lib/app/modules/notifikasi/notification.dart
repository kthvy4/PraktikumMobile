import 'package:demo_mobile/app/modules/notifikasi/notification_handler.dart' as custom_notification; // Menggunakan alias
import 'package:demo_mobile/app/modules/notifikasi/notification_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final NotificationService notificationService = Get.put(NotificationService());

    return Scaffold(
      appBar: AppBar(title: Text('Notifikasi')),
      body: StreamBuilder<List<custom_notification.Notification>>(
        stream: notificationService.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada notifikasi'));
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(notifications[index].title),
                subtitle: Text(notifications[index].body),
              );
            },
          );
        },
      ),
    );
  }
}
