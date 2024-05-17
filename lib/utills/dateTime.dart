import 'package:flutter/material.dart';

class ConvertTime {
  DateTime convertDateMonthYearToDateTime(String dateString) {
    List<String> dateParts = dateString.split('/');
    if (dateParts.length != 3) {
      throw const FormatException(
          'Invalid date format. Expected format: dd/MM/yyyy');
    }

    int day = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int year = int.parse(dateParts[2]);

    DateTime dateTime = DateTime(year, month, day);

    return dateTime;
  }

  String convertDateTimeToDateMonthYear(DateTime dateTime) {
    // Extract day, month, and year from DateTime object
    int day = dateTime.day;
    int month = dateTime.month;
    int year = dateTime.year;

    // Format date as string
    String formattedDate = '$day/${month.toString().padLeft(2, '0')}/$year';

    return formattedDate;
  }

  String convertFromIso8601String(iso8601String) {
    DateTime dateTime = DateTime.parse(iso8601String);

    // Format DateTime as "date/month/year"
    String formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';

    return formattedDate;
  }

  String convertTimeOfDayToAmPm(TimeOfDay timeOfDay) {
    // Extract hour and minute from TimeOfDay object
    int hour = timeOfDay.hour;
    int minute = timeOfDay.minute;

    // Determine AM/PM
    String period = hour < 12 ? 'AM' : 'PM';

    // Convert hour to 12-hour format
    hour = hour % 12;
    hour = hour == 0 ? 12 : hour;

    // Format time as string
    String formattedTime = '$hour:${minute.toString().padLeft(2, '0')} $period';

    return formattedTime;
  }
}
