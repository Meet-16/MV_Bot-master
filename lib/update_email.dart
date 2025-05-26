import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateEmailPage extends StatefulWidget {
  const UpdateEmailPage({Key? key}) : super(key: key);

  @override
  State<UpdateEmailPage> createState() => _UpdateEmailPageState();
}

class _UpdateEmailPageState extends State<UpdateEmailPage> {
  final TextEditingController _emailController = TextEditingController();

  Future<void> _updateEmail() async {
    String newEmail = _emailController.text.trim();

    if (newEmail.isEmpty || !newEmail.contains('@')) {
      Fluttertoast.showToast(
        msg: "Please enter a valid email address!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    await saveEmail(newEmail); // ✅ Save the email using SharedPreferences

    Fluttertoast.showToast(
      msg: "Email updated successfully!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          sessionTitle: newEmail,
          sessionIndex: 0, // Replace with actual index if needed
        ),
      ),
    );
  }

  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Enter new email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateEmail,
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
