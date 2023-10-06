import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker/models/expense.dart';

import 'package:http/http.dart' as http;

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  List<Expense> _registeredExpenses = [];
  // [
  //   Expense(
  //     title: 'Flutter Course',
  //     amount: 19.99,
  //     date: DateTime.now(),
  //     category: Category.work,
  //   ),
  //   Expense(
  //     title: 'Beach Party',
  //     amount: 15.69,
  //     date: DateTime.now(),
  //     category: Category.leisure,
  //   ),
  // ];

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (context) => NewExpense(onAddExpense: _addExpense),
    );
  }

  void _addExpense(Expense expense) {
    setState(() {
      _registeredExpenses.add(expense);
      saveExpense(expense);
    });
  }

  void _removeExpense(Expense expense) {
    final expenseIndex = _registeredExpenses.indexOf(expense);
    var _undoPressed = false;

    setState(() {
      _registeredExpenses.remove(expense);
    });

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          setState(() {
            _undoPressed = true;
            _registeredExpenses.insert(expenseIndex, expense);
          });
        },
      ),
      content: const Text(
        'Expense deleted.',
      ),
    ));

    Future.delayed(const Duration(seconds: 3), () {
      // Delete the expense only if "_undoPressed" is false
      if (!_undoPressed) {
        deleteExpense(expense.id);
      }
      // Reset the flag
      _undoPressed = false;
    });
  }

  Future<void> saveExpense(Expense expense) async {
    const serverUrl =
        'http://localhost:8080'; // Update with your server's IP and port

    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(expense.toJson()),
      );

      if (response.statusCode == 200) {
        print('Expense saved successfully.');
      } else {
        print('Failed to save expense: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<List<Expense>> fetchExpenses() async {
    const serverUrl =
        'http://localhost:8080'; // Update with your server's IP and port

    try {
      final response = await http.get(Uri.parse(serverUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Expense> expenses =
            data.map((e) => Expense.fromJson(e)).toList();
        return expenses;
      } else {
        print('Failed to fetch expenses: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    const serverUrl =
        'http://localhost:8080'; // Update with your server's IP and port
    final response = await http.delete(
      Uri.parse('$serverUrl/expenses/$expenseId'),
    );

    if (response.statusCode == 200) {
      print('Expense deleted successfully.');
    } else if (response.statusCode == 404) {
      print('Expense not found.');
    } else {
      print('Failed to delete expense.');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final expenses = await fetchExpenses();
    setState(() {
      _registeredExpenses = expenses;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    Widget mainContent = const Center(
      child: Text('You currently have no expenses. Start adding some!'),
    );

    if (_registeredExpenses.isNotEmpty) {
      mainContent = ExpensesList(
        expenses: _registeredExpenses,
        onRemoveExpense: _removeExpense,
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: Container(
          padding: const EdgeInsets.all(11.0),
          child: Image.asset(
            'assets/images/expense_tracker.png',
            height: 35,
            width: 35,
          ),
        ),
        title: const Text('Expense Tracker App'),
        actions: [
          IconButton(
            onPressed: _openAddExpenseOverlay,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: width < 600
          ? Column(
              children: [
                Chart(expenses: _registeredExpenses),
                Expanded(
                  child: mainContent,
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Chart(expenses: _registeredExpenses),
                ),
                Expanded(
                  child: mainContent,
                ),
              ],
            ),
    );
  }
}
