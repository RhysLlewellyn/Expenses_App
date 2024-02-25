/*

these are helpful functions used across the app

*/

import 'package:intl/intl.dart';

//convert string to a double
double convertStringToDouble(String string) {
  double? amount = double.tryParse(string);
  return amount ?? 0;
}

//format double amount into pounds and pennies
String formatAmount(double amount) {
  final format =
      NumberFormat.currency(locale: "en_Uk", symbol: "£", decimalDigits: 2);
  return format.format(amount);
}

// or operator
// ||

// calculate the number of months since the start month
int calculateMonthCount(int startYear, startMonth, currentYear, currentMonth) {
  int monthCount =
      (currentYear - startYear) * 12 + currentMonth - startMonth + 1;
  return monthCount;
}

// get current month name
String getCurrentMonthName() {
  DateTime now = DateTime.now();
  List<String> months = [
    "JAN",
    "FEB",
    "MAR",
    "APR",
    "MAY",
    "JUN",
    "JUL",
    "AUG",
    "SEP",
    "OCT",
    "NOV",
    "DEC",
  ];
  return months[now.month - 1];
}
