import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:expense_tracker/models/expense.dart';

class NewExpense extends StatefulWidget {
  const NewExpense({super.key, required this.onAddExpense});

  final void Function(Expense expense) onAddExpense;

  @override
  State<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  Category _selectedCategory = Category.leisure;

  void _presentDatePicker() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _showDialog() {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Invalid input'),
          content: const Text(
              'Please make sure a valid title, amount, date and category was entered.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Okay'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Invalid input'),
          content: const Text(
              'Please make sure a valid title, amount, date and category was entered.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Okay'),
            ),
          ],
        ),
      );
    }
  }

  void _submitExpenseData() {
    final enteredAmount = double.tryParse(_amountController.text);
    if (_titleController.text.trim().isEmpty ||
        enteredAmount == null ||
        enteredAmount <= 0 ||
        _selectedDate == null) {
      _showDialog();

      return;
    }
    widget.onAddExpense(
      Expense(
        title: _titleController.text,
        amount: enteredAmount,
        date: _selectedDate!,
        category: _selectedCategory,
      ),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    FocusNode node1 = FocusNode();
    FocusNode node2 = FocusNode();
    FocusNode node3 = FocusNode();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SizedBox(
            height: double.infinity,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + keyboardSpace),
                child: Column(
                  children: [
                    if (width >= 600)
                      Column(
                        children: [
                          const Text('Add an expense',
                              style: TextStyle(fontSize: 20)),
                          const SizedBox(
                            height: 16,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TitleInput(
                                  node1: node1,
                                  node2: node2,
                                  titleController: _titleController,
                                ),
                              ),
                              const SizedBox(
                                width: 24,
                              ),
                              Expanded(
                                child: AmountInput(
                                  node2: node2,
                                  node3: node3,
                                  amountController: _amountController,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          const Text('Add an expense',
                              style: TextStyle(fontSize: 20)),
                          TitleInput(
                            node1: node1,
                            node2: node2,
                            titleController: _titleController,
                          ),
                        ],
                      ),
                    if (width >= 600)
                      Row(
                        children: [
                          DropdownButton(
                            focusNode: node3,
                            value: _selectedCategory,
                            items: Category.values
                                .map(
                                  (category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(
                                      category.name[0].toUpperCase() +
                                          category.name.substring(1),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              setState(() {
                                _selectedCategory = value;
                              });
                            },
                          ),
                          const SizedBox(
                            width: 24,
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  _selectedDate == null
                                      ? 'No date selected'
                                      : formatter.format(_selectedDate!),
                                ),
                                IconButton(
                                    onPressed: _presentDatePicker,
                                    icon: const Icon(Icons.calendar_month))
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: AmountInput(
                              node2: node2,
                              node3: node3,
                              amountController: _amountController,
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  _selectedDate == null
                                      ? 'No date selected'
                                      : formatter.format(_selectedDate!),
                                ),
                                IconButton(
                                    onPressed: _presentDatePicker,
                                    icon: const Icon(Icons.calendar_month))
                              ],
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(
                      height: 16,
                    ),
                    if (width >= 600)
                      Row(
                        children: [
                          const Spacer(),
                          ElevatedButton(
                            onPressed: _submitExpenseData,
                            child: const Text('Save'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          DropdownButton(
                            focusNode: node3,
                            value: _selectedCategory,
                            items: Category.values
                                .map(
                                  (category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(
                                      category.name[0].toUpperCase() +
                                          category.name.substring(1),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              // setState(() {
                              _selectedCategory = value;
                              // });
                            },
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: _submitExpenseData,
                            child: const Text('Save'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AmountInput extends StatelessWidget {
  const AmountInput({
    super.key,
    required this.node2,
    required this.node3,
    required TextEditingController amountController,
  }) : _amountController = amountController;

  final FocusNode node2;
  final FocusNode node3;
  final TextEditingController _amountController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: node2,
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(node3);
      },
      controller: _amountController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        prefixText: 'Rs. ',
        label: Text('Amount'),
      ),
    );
  }
}

class TitleInput extends StatelessWidget {
  const TitleInput({
    super.key,
    required this.node1,
    required this.node2,
    required TextEditingController titleController,
  }) : _titleController = titleController;

  final FocusNode node1;
  final FocusNode node2;
  final TextEditingController _titleController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: node1,
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(node2);
      },
      controller: _titleController,
      maxLength: 50,
      decoration: const InputDecoration(
        label: Text('Title'),
      ),
    );
  }
}
