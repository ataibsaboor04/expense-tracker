import 'dart:convert';
import 'dart:io';
import 'package:expense_tracker/models/expense.dart';

Future<void> main() async {
  final server = await HttpServer.bind(
    InternetAddress.anyIPv4,
    8080,
  );

  print('Server started on port ${server.port}');

  final file = File('expenses.json');
  if (file.existsSync()) {
    final encodedExpenses = file.readAsStringSync();

    final List<dynamic> expenseList = json.decode(encodedExpenses);

    final List<Expense> expenses =
        expenseList.map((e) => Expense.fromJson(e)).toList();

    await for (final request in server) {
      if (request.method == 'POST') {
        try {
          final body = await utf8.decodeStream(request);
          final expenseData = jsonDecode(body);
          final expense = Expense.fromJson(
            {
              'id': expenseData['id'],
              'title': expenseData['title'],
              'amount': expenseData['amount'],
              'date': expenseData['date'],
              'category': expenseData['category'],
            },
          );

          expenses.add(expense);

          final file = File('expenses.json');
          final encodedExpenses =
              json.encode(expenses.map((e) => e.toJson()).toList());
          file.writeAsStringSync(encodedExpenses);

          request.response
            ..statusCode = HttpStatus.ok
            ..write('Expense saved successfully.');
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.badRequest
            ..write('Error: ${e.toString()}');
        }
      } else if (request.method == 'GET') {
        request.response
          ..statusCode = HttpStatus.ok
          ..write(json.encode(expenses.map((e) => e.toJson()).toList()));
      } else if (request.method == 'DELETE') {
        final uriSegments = request.uri.pathSegments;

        if (uriSegments.length == 2 && uriSegments[0] == 'expenses') {
          final expenseId = uriSegments[1];

          expenses.removeWhere((expense) => expense.id == expenseId);

          final file = File('expenses.json');
          final encodedExpenses =
              json.encode(expenses.map((e) => e.toJson()).toList());
          file.writeAsStringSync(encodedExpenses);
          print('Expense with ID $expenseId deleted successfully.');
          request.response
            ..statusCode = HttpStatus.ok
            ..write('Expense with ID $expenseId deleted successfully.');
        }
      } else {
        request.response
          ..statusCode = HttpStatus.methodNotAllowed
          ..write('Only POST, DELETE and GET requests are allowed.');
      }

      await request.response.close();
    }
  }
}
