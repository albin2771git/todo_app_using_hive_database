import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hive/hive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //-------crreating list------------//
  List<Map<String, dynamic>> items = [];

  final shopping_box = Hive.box('shopping_box');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshdata();
  }

  //-----------fetch all the data from the database ---------------//
  void refreshdata() {
    final data = shopping_box.keys.map((key) {
      final value = shopping_box.get(key);
      return {"key": key, "name": value["name"], "quantity": value["quantity"]};
    }).toList();

    setState(() {
      items = data.reversed.toList();
    });
  }

  //---------function to add new item-------//
  Future<void> createItem(Map<String, dynamic> newItem) async {
    await shopping_box.add(newItem);
    refreshdata();
  }

  // Retrieve a single item from the database by using its key
  // Our app won't use this function but I put it here for your reference

  Map<String, dynamic> readItem(int key) {
    final item = shopping_box.get(key);
    return item;
  }

//---------------update an item---------------//
  Future<void> updateItem(int itemKey, Map<String, dynamic> item) async {
    await shopping_box.put(itemKey, item);
    refreshdata();
  }
  //------------------delete an item---------------//

  Future<void> deleteItem(int itemKey) async {
    await shopping_box.delete(itemKey);
    refreshdata();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("item deleted")));
  }

  //----------------controllers--------------//
  final TextEditingController name_controllers = TextEditingController();
  final TextEditingController quantity_controllers = TextEditingController();

//
  void Show_form(BuildContext ctx, int? itemKey) async {
    // itemKey == null -> create new item
    // itemKey != null -> update an existing item
    if (itemKey != null) {
      final existingItem =
          items.firstWhere((element) => element['key'] == itemKey);
      name_controllers.text = existingItem['name'];
      quantity_controllers.text = existingItem['quantity'];
    }
    showModalBottomSheet(
        context: ctx,
        elevation: 5,
        isScrollControlled: true,
        builder: (context) => Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  top: 15,
                  left: 15,
                  right: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: name_controllers,
                    decoration: InputDecoration(hintText: "name"),
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: quantity_controllers,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: "Quantity"),
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (itemKey == null) {
                          createItem({
                            "name": name_controllers.text,
                            "quantity": quantity_controllers.text,
                          });
                        }
                        if (itemKey != null) {
                          updateItem(itemKey, {
                            'name': name_controllers.text.trim(),
                            "quantity": quantity_controllers.text.trim(),
                          });
                        }
                        //-----------clear the text field---------
                        name_controllers.text = "";
                        quantity_controllers.text = "";
                        Navigator.of(context).pop();
                      },
                      child: Text(itemKey == null ? 'create new' : 'update')),
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        "HIVE DB",
        style: TextStyle(fontSize: 21),
      )),
      body: items.isEmpty
          ? Center(
              child: Text("no data found"),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: ((context, index) {
                final currentItem = items[index];
                return Card(
                  color: Colors.blue,
                  margin: EdgeInsets.all(10),
                  elevation: 3,
                  child: ListTile(
                    title: Text(currentItem['name']),
                    subtitle: Text(
                      currentItem['quantity'].toString(),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () =>
                                Show_form(context, currentItem['key']),
                            icon: Icon(Icons.edit)),
                        IconButton(
                            onPressed: () => deleteItem(currentItem['key']),
                            icon: Icon(Icons.delete))
                      ],
                    ),
                  ),
                );
              }),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Show_form(context, null),
        child: Icon(Icons.add),
      ),
    );
  }
}
