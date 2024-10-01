import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:timezone/timezone.dart' as tz; // Import timezone package

class PeriodController extends GetxController {
  var selectedDate = Rx<DateTime?>(null);
  var nextPeriodDate = DateTime.now().obs; // Use observable for next period date
  var editAvailable = true.obs;
  var confirmedDates = <DateTime>[].obs;
  Timer? editTimer;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void onInit() {
    super.onInit();
    _initializeNotification();
    _loadData(); // Load data from SharedPreferences
  }

  void _initializeNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Load saved data from SharedPreferences
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? dateStrings = prefs.getStringList('confirmed_dates');
    if (dateStrings != null) {
      confirmedDates.value = dateStrings
          .map((dateString) => DateTime.parse(dateString))
          .toList();
    }
    // Load next period date if available
    String? nextDateString = prefs.getString('next_period_date');
    if (nextDateString != null) {
      nextPeriodDate.value = DateTime.parse(nextDateString);
    }
  }

  // Save confirmed dates and next period date
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> dateStrings =
    confirmedDates.map((date) => date.toIso8601String()).toList();
    await prefs.setStringList('confirmed_dates', dateStrings);
    await prefs.setString('next_period_date', nextPeriodDate.value.toIso8601String()); // Save next period date
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    nextPeriodDate.value = date.add(Duration(days: 30));
    _startEditTimer();
  }

  void confirmDate() {
    if (selectedDate.value != null) {
      confirmedDates.add(selectedDate.value!);
      nextPeriodDate.value = selectedDate.value!.add(Duration(days: 30));
      editAvailable.value = false;
      _schedulePeriodAlert(nextPeriodDate.value);
      _saveData(); // Save data after confirming
    }
  }

  void _startEditTimer() {
    editAvailable.value = true;
    editTimer?.cancel();
    editTimer = Timer(Duration(days: 3), () {
      editAvailable.value = false;
    });
  }

  void _schedulePeriodAlert(DateTime nextPeriod) async {
    DateTime alertDate = nextPeriod.subtract(Duration(days: 3));
    String alertBody = "Your period is coming in 3 days!";
    _showNotification(alertDate, alertBody);
  }

  Future<void> _showNotification(DateTime scheduledDate, String body) async {
    var androidDetails = const AndroidNotificationDetails(
      'period_channel',
      'Period Tracker Notifications',

      importance: Importance.max,
      priority: Priority.high,
    );

    var platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Period Reminder',
      body,
      _convertToTZDateTime(scheduledDate),
      platformDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    final tz.TZDateTime tzDate = tz.TZDateTime.from(dateTime, tz.local);
    return tzDate;
  }

  @override
  void onClose() {
    editTimer?.cancel();
    super.onClose();
  }

  // Clear history and save updated data
  void clearHistory() {
    confirmedDates.clear();
    nextPeriodDate.value = DateTime.now(); // Reset next period date if needed
    _saveData(); // Save changes after clearing
  }
}
