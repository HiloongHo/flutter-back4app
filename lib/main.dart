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
    debugShowCheckedModeBanner: false,
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
    if (todoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("请输入信息！"),
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
        title: const Text('Todo'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    autocorrect: true,
                    textCapitalization: TextCapitalization.sentences,
                    controller: todoController,
                    decoration: const InputDecoration(
                        labelText: "输入新的计划",
                        labelStyle: TextStyle(color: Colors.blueAccent)),
                  ),
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueAccent,
                    ),
                    onPressed: addTodo,
                    child: const Text("添加"))
              ],
            ),
          ),
          Expanded(
              child: FutureBuilder<List<ParseObject>>(
            future: getTodo(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return const Center(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(),
                    ),
                  );
                default:
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (snapshot.hasData) {
                    return const Center(
                      child: Text("什么也没有哦。"),
                    );
                  } else {
                    return ListView.builder(
                        padding: const EdgeInsets.only(top: 10.0),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          //*************************************
                          //Get Parse Object Values
                          final varTodo = snapshot.data![index];
                          final varTitle = varTodo.get<String>('title') ?? "";
                          final varDone = varTodo.get<bool>('done')!;
                          //*************************************

                          return ListTile(
                            title: Text(varTitle), // 注意这里去掉了const，因为Text的参数现在可能不是常量
                            leading:  CircleAvatar(
                              backgroundColor: varDone
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              foregroundColor: Colors.white,
                              child: Icon(
                                varDone ? Icons.check : Icons.error,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                    value: varDone,
                                    onChanged: (value) async {
                                      await updateTodo(
                                          varTodo.objectId!, value!);
                                      setState(() {});
                                    }),
                                IconButton(
                                  onPressed: () async {
                                    await deleteTodo(varTodo.objectId!);
                                    setState(() {
                                      const snackBar = SnackBar(
                                        content: Text("Todo deleted!"),
                                        duration: Duration(seconds: 2),
                                      );
                                      ScaffoldMessenger.of(context)
                                        ..removeCurrentSnackBar()
                                        ..showSnackBar(snackBar);
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                  }
              }
            },
          ))
        ],
      ),
    );
  }
}

Future<void> saveTodo(String title) async {
  final todo = ParseObject('Todo')
    ..set('title', title)
    ..set('done', false);
  await todo.save();
}

Future<List<ParseObject>> getTodo() async {
  QueryBuilder<ParseObject> queryTodo =
      QueryBuilder<ParseObject>(ParseObject('Todo'));
  final ParseResponse apiResponse = await queryTodo.query();

  if (apiResponse.success && apiResponse.results != null) {
    return apiResponse.results as List<ParseObject>;
  } else {
    return [];
  }
}

Future<void> updateTodo(String id, bool done) async {
  var todo = ParseObject('Todo')
    ..objectId = id
    ..set('done', done);
  await todo.save();
}

Future<void> deleteTodo(String id) async {
  var todo = ParseObject('Todo')..objectId = id;
  await todo.delete();
}
