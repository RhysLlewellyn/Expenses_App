import 'package:expenses/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  final List<Expense> _allExpenses = [];

/*

S E T U P

*/

// initialize db
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

/*

G E T T E R S

*/

  List<Expense> get allExpense => _allExpenses;

/*

O P E R A T I O N S

*/

  // Clear the entire database
  Future<void> clearDatabase() async {
    await isar.writeTxn((isar) async {
      await isar.deleteAll<Expense>();
    } as Future Function());

    // Clear the local list
    _allExpenses.clear();

    // Notify listeners to update the UI
    notifyListeners();
  }

// Create - add new expense
  Future<void> createExpense(Expense newExpense) async {
    // add to db
    await isar.writeTxn(() => isar.expenses.put(newExpense));
    // re-read db
    await readExpenses();
  }

// Read - expenses from db
  Future<void> readExpenses() async {
    // fetch all existing expenses from db
    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();

    // give to local expense list
    _allExpenses.clear();
    _allExpenses.addAll(fetchedExpenses);
    // update UI
    notifyListeners();
  }

// Update - edit an expense in db
  Future<void> updateExpense(int id, Expense updatedExpense) async {
    // make sure new expense has the same id as existing one
    updatedExpense.id = id;
    // update in db
    await isar.writeTxn(() => isar.expenses.put(updatedExpense));

    // re-read db
    await readExpenses();
  }

// Delete - an expense from db
  Future<void> deleteExpense(int id) async {
    // delete from db
    await isar.writeTxn(() => isar.expenses.delete(id));
    // re-read db
    await readExpenses();
  }
/*

H E L P E R S

*/

// calculate total expenses for each month
/*

year - month

{
  2024-0: £250, jan
  2024-1: £200, feb
  2024-2: £175, mar
  ...
  2024-11: £240, dec
  2025-0: £300, jan
}

*/

  Future<Map<String, double>> calculateMonthlyTotals() async {
    // ensure the expenses are read from the db
    await readExpenses();

    // create a map to keep track of total expenses per month
    Map<String, double> monthlyTotals = {};

    // iterate over all expenses
    for (var expense in _allExpenses) {
      //extract year & month from the date of the expense
      String yearMonth = '${expense.date.year}-${expense.date.month}';

      // if the year-month is not yet in the map, initialize to 0
      if (!monthlyTotals.containsKey(yearMonth)) {
        monthlyTotals[yearMonth] = 0;
      }

      // add the expense amount to the total for the month
      monthlyTotals[yearMonth] =
          (monthlyTotals[yearMonth] ?? 0) + expense.amount;
    }

    return monthlyTotals;
  }

//calculate current month total
  Future<double> calculateCurrentMonthTotal() async {
    // ensure expenses are read from db first
    await readExpenses();

    // get current month, year
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    // filter the expenses to include only those for this month this year
    List<Expense> currentMonthExpenses = _allExpenses.where((expense) {
      return expense.date.month == currentMonth &&
          expense.date.year == currentYear;
    }).toList();
    // calculate total amount for the current month
    double total =
        currentMonthExpenses.fold(0, (sum, expense) => sum + expense.amount);
    return total;
  }

// get start month
  int getStartMonth() {
    if (_allExpenses.isEmpty) {
      return DateTime.now()
          .month; // default to current month if no expenses are recorded
    }

    //sort expenses by date to find the earliest
    _allExpenses.sort(
      (a, b) => a.date.compareTo(b.date),
    );

    return _allExpenses.first.date.month;
  }

// get start year
  int getStartYear() {
    if (_allExpenses.isEmpty) {
      return DateTime.now()
          .year; // default to current year if no expenses are recorded
    }

    //sort expenses by date to find the earliest
    _allExpenses.sort(
      (a, b) => a.date.compareTo(b.date),
    );

    return _allExpenses.first.date.year;
  }
}
