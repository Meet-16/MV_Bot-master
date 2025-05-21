import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'chat_page.dart';
import 'theme_provider.dart';
import 'home_page.dart';
import 'main.dart';
import 'archive_chat.dart';

class ProfileMenu extends StatefulWidget {
  @override
  _ProfileMenuState createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<ProfileMenu> {
  Future<void> _clearLocalChat(BuildContext context) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Clear Chat?"),
        content: const Text("Are you sure you want to delete all chat history?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/chat_messages.json');
        final archiveFile = File('${directory.path}/chat_archive.json');

        if (await file.exists()) {
          final chatData = await file.readAsString();
          await archiveFile.writeAsString(chatData); // Save to archive
          await file.delete(); // Then delete the main chat

          Fluttertoast.showToast(
            msg: "Chat history deleted and archived!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else {
          Fluttertoast.showToast(
            msg: "No chat history found to delete.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } catch (e) {
        print("Error deleting chat history: $e");
        Fluttertoast.showToast(
          msg: "Error deleting chat history. Please try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Profile Settings", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: Theme.of(context).iconTheme,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Account Settings", context),
              _menuItem(Icons.person, "Account Settings", context, () {}),
              _menuItem(Icons.edit, "Update Name", context, () {}),
              _menuItem(Icons.email, "Update Email", context, () {}),
              const SizedBox(height: 10),
              const Divider(),
              _sectionTitle("Settings", context),
              _menuItem(Icons.brightness_6, "Choose Theme (System/Dark/Light)", context, () {
                _showThemeDialog(context);
              }),
              _menuItem(Icons.language, "Language", context, () {
                Fluttertoast.showToast(
                  msg: "We currently support only English.",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.blueGrey,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              }),
              _menuItem(Icons.archive, "Archive all chats", context, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ArchiveChatPage()),
                );
              }),
              // _menuItem(Icons.delete_forever, "Delete chat history", context, () => _clearLocalChat(context), color: Colors.orange),
              _menuItem(Icons.logout, "Logout on this device", context, _logout),
              const SizedBox(height: 10),
              const Divider(),
              _sectionTitle("Security", context),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Log out of all devices",
                    style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyLarge!.color),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text("Log out all", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              _menuItem(Icons.exit_to_app, "Log out", context, _logout, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  void _logout() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.logout();

    Fluttertoast.showToast(
      msg: "See you soon!!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LandingPage()),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text("Choose Theme", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _themeOption(context, "Light Mode", ThemeMode.light),
                  _themeOption(context, "Dark Mode", ThemeMode.dark),
                  _themeOption(context, "System Default", ThemeMode.system),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _themeOption(BuildContext context, String text, ThemeMode mode) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return ListTile(
      title: Text(text, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color)),
      leading: Radio<ThemeMode>(
        value: mode,
        groupValue: themeProvider.themeMode,
        onChanged: (ThemeMode? value) {
          themeProvider.toggleTheme(mode);
          Navigator.pop(context);
        },
      ),
      onTap: () {
        themeProvider.toggleTheme(mode);
        Navigator.pop(context);
      },
    );
  }

  Widget _sectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge!.color),
    );
  }

  Widget _menuItem(IconData icon, String text, BuildContext context, VoidCallback onTap, {Color color = Colors.black}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).iconTheme.color),
      title: Text(text, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color)),
      onTap: onTap,
    );
  }
}
