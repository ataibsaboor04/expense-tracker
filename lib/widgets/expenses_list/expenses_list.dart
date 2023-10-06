import 'package:flutter/material.dart';

import 'package:expense_tracker/widgets/expenses_list/expense_item.dart';
import 'package:expense_tracker/models/expense.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList({
    super.key,
    required this.expenses,
    required this.onRemoveExpense,
  });

  final List<Expense> expenses;
  final void Function(Expense expense) onRemoveExpense;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) => Dismissible(
        key: ValueKey(expenses[index]),
        onDismissed: (direction) {
          onRemoveExpense(expenses[index]);
        },
        background: Container(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.centerRight,
          margin: Theme.of(context).cardTheme.margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.error.withOpacity(0.2),
          ),
          child: const Icon(
            Icons.delete_rounded,
            size: 26,
          ),
        ),
        child: ExpenseItem(expenses[index]),
      ),
    );
  }
}
