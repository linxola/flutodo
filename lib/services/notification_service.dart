import 'package:flutodo/ui/task_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../controllers/tasks_controller.dart';
import '../models/task.dart';

class NotificationService {
  FlutterLocalNotificationsPlugin
  flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin(); //

  initializeNotification() async {
    _configureLocalTimezone();
    final DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(
      iOS: initializationSettingsIOS,
      android:initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  }

  displayNotification({required String title, required String body}) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'your channel id', 'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'app_icon');
    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: title,
    );
  }

  scheduledNotification(int id, Task task) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      task.title,
      task.note,
      _notificationTime(task.remind, task.repeat, task.date, task.startTime),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your channel id', 'your channel name',
          channelDescription: 'your channel description')),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: _repeatRate(task.repeat),
      payload: "${task.id}"
    );
  }

  DateTimeComponents _repeatRate(String? repeat) {
    DateTimeComponents repeatRate = DateTimeComponents.dateAndTime;
    switch (repeat) {
      case 'Daily':
        return repeatRate = DateTimeComponents.time;
      case 'Weekly':
      return repeatRate = DateTimeComponents.dayOfWeekAndTime;
      case 'Monthly':
        return repeatRate = DateTimeComponents.dayOfMonthAndTime;
    }
    return repeatRate;
  }

  tz.TZDateTime _notificationTime(int? remind, String? repeat, String? date, String? time) {
    // final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    int day  = int.parse(date!.split(".")[0]);
    int month  = int.parse(date.split(".")[1]);
    int year = int.parse(date.split(".")[2]);
    int hour = int.parse(time!.split(":")[0]);
    int minutes = int.parse(time.split(":")[1]) - remind!;

    // if (scheduledDate.isBefore(now)) {
    //   switch (repeat) {
    //     case 'Daily':
    //       return scheduledDate = scheduledDate.add(const Duration(days: 1));
    //     case 'Weekly':
    //       return scheduledDate = scheduledDate.add(const Duration(days: 7));
    //     case 'Monthly':
    //       return scheduledDate = tz.TZDateTime(tz.local, year, month+1, day, hour, minutes);
    //     case 'Yearly':
    //       return scheduledDate = tz.TZDateTime(tz.local, year+1, month, day, hour, minutes);
    //   }
    // }
    return tz.TZDateTime(tz.local, year, month, day, hour, minutes);
  }

  cancel(id) async => await flutterLocalNotificationsPlugin.cancel(id);

  Future<void> _configureLocalTimezone() async {
    tz.initializeTimeZones();
    final String timezone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone));
  }

  requestIOSPermissions() async {
    flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
  }

  Future onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      print('notification payload: $payload');
    } else {
      print("No payload");
    }

    await Get.to(()=>TaskPage(taskId: payload));
    TasksController().getTask(int.parse(payload.toString()));
  }

  Future onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    // showDialog(
    //   //context: context,
    //   builder: (BuildContext context) => CupertinoAlertDialog(
    //     title: Text(title),
    //     content: Text(body),
    //     actions: [
    //       CupertinoDialogAction(
    //         isDefaultAction: true,
    //         child: Text('Ok'),
    //         onPressed: () async {
    //           Navigator.of(context, rootNavigator: true).pop();
    //           await Navigator.push(
    //             context,
    //             MaterialPageRoute(
    //               builder: (context) => SecondScreen(payload),
    //             ),
    //           );
    //         },
    //       )
    //     ],
    //   ),
    // );
    Get.dialog(const Text("Welcome to flutter!"));
  }
}