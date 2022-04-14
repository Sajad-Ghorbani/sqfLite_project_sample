import 'package:flutter/material.dart';
import 'package:sqflite_test/database.dart';
import 'package:sqflite_test/user_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  return runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // reference to our single class that manages the database
  final dbHelper = DatabaseHelper.instance;

  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  List<User> users = [];
  int updatingId = -1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _query();
  }

  // homepage layout
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('sqflite'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Insert name',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(
                labelText: 'Insert age',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              child: const Text(
                'insert',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: _insert,
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              child: const Text(
                'update',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: _updateUser,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(
                    label: Text('id'),
                  ),
                  DataColumn(
                    label: Text('name'),
                  ),
                  DataColumn(
                    label: Text('age'),
                  ),
                  DataColumn(
                    label: Text('actions'),
                  ),
                ],
                rows: users.map(
                  (User user) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            user.id.toString(),
                          ),
                        ),
                        DataCell(
                          Text(user.name!),
                        ),
                        DataCell(
                          Text(
                            user.age.toString(),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  _update(user);
                                },
                                icon: const Icon(
                                  Icons.edit,
                                ),
                                color: Colors.blue,
                              ),
                              IconButton(
                                onPressed: () {
                                  _delete(user.id!);
                                },
                                icon: const Icon(
                                  Icons.delete,
                                ),
                                color: Colors.redAccent,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Button onPressed methods
  void _insert() async {
    if (nameController.text.isEmpty && ageController.text.isEmpty) {
      //pass
    } //
    else {
      String name = nameController.text;
      int age = int.parse(ageController.text);

      User user = User();
      user.name = name;
      user.age = age;
      // row to insert
      final id = await dbHelper.insert(user.toJson());
      print('inserted row id: $id');
      await _query();
      setState(() {
        reset();
      });
    }
  }

  Future _query() async {
    users = [];
    final allRows = await dbHelper.queryAllRows();
    for (var item in allRows) {
      users.add(User.fromJson(item));
    }
  }

  void _update(User user) {
    updatingId = user.id!;
    nameController.text = user.name!;
    ageController.text = user.age.toString();
  }

  void _updateUser() async {
    if (updatingId != -1) {
      String name = nameController.text;
      int age = int.parse(ageController.text);

      User user = User();
      user.id = updatingId;
      user.name = name;
      user.age = age;
      // row to update
      final rowsAffected = await dbHelper.update(user.toJson());
      print('updated $rowsAffected row(s)');
      await _query();
      setState(() {
        reset();
      });
    } //
    else {
      //pass
    }
  }

  void _delete(int id) async {
    // Assuming that the number of rows is the id for the last row.
    final rowsDeleted = await dbHelper.delete(id);
    print('deleted $rowsDeleted row(s): row $id');
    await _query();
    setState(() {});
  }

  void reset() {
    nameController.clear();
    ageController.clear();
    updatingId = -1;
  }
}
