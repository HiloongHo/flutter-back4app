import 'package:flutter/material.dart';
import 'dart:async';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

void main() async {
  // Initialize Parse app
  WidgetsFlutterBinding.ensureInitialized();
  const keyApplicationId = 'TEiKfTpSpk8QNLmtqsVBnQ1v5nSzw8ov8uGWuuyw';
  const keyClientKey = '33mbOibO1cG6lwNshmMjFxfHvjwljsBiQM3orUl2';
  const keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, autoSendSessionId: true);

  // Test connection
  // var firstObject = ParseObject('FirstClass')
  //   ..set(
  //       'message', 'Hey ! First message from Flutter. Parse is now connected');
  // await firstObject.save();

  runApp(const MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final todoController = TextEditingController();

  void addTodo() async {
    if (todoController.text
        .trim()
        .isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("空标题"),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    await saveTodo(todoController.text);
    setState(() {
      todoController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
          children: <Widget>[
      Container(
      padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
      child: Row(
        children: <Widget>[
      Expanded(child: TextField(
        autocorrect: true,
        textCapitalization: TextCapitalization.sentences,
        controller: todoController,
        decoration: const InputDecoration(
            labelText: "New todo",
            labelStyle: TextStyle(color: Colors.blueAccent)),
      ),
    ))
    ],
    ),
    )
    ],
    ),
    );
  }
}

Future<void> saveTodo(String title) async {
  await Future.delayed(const Duration(seconds: 1), () {});
}
