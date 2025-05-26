import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateNamePage extends StatefulWidget {
  const UpdateNamePage({Key? key}) : super(key: key);

  @override
  State<UpdateNamePage> createState() => _UpdateNamePageState();
}

class _UpdateNamePageState extends State<UpdateNamePage> {
  final TextEditingController _nameController = TextEditingController();

  Future<void> _updateName() async {
    String newName = _nameController.text.trim();

    if (newName.isEmpty) {
      Fluttertoast.showToast(
        msg: "Name cannot be empty!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    await saveName(newName); // ✅ Save the name using SharedPreferences

    Fluttertoast.showToast(
      msg: "Name changed successfully!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          sessionTitle: newName,
          sessionIndex: 0, // Replace with actual index if needed
        ),
      ),
    );
  }

  Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Name'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Enter new name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateName, // ✅ Now async-safe and functional
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
