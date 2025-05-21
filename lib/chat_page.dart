import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'sidebar_menu.dart';
import 'profile_menu.dart';
import 'theme_provider.dart';
import 'dialogflow_service.dart';
import 'archive_chat.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  User? user;
  final TextEditingController _textController = TextEditingController();
  final DialogflowService dialogflowService = DialogflowService();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    dialogflowService.init();
    _loadMessages();
    FirebaseAuth.instance.authStateChanges().listen((User? updatedUser) {
      setState(() {
        user = updatedUser;
      });
    });
    user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _loadMessages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/chat_messages.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() {
          messages = List<Map<String, dynamic>>.from(json.decode(content));
        });
      }
    } catch (e) {
      print("Error loading messages: $e");
    }
  }

  Future<void> _saveMessages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/chat_messages.json');
      await file.writeAsString(json.encode(messages));
    } catch (e) {
      print("Error saving messages: $e");
    }
  }

  Future<void> deleteChatHistory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/chat_messages.json');
      if (await file.exists()) {
        await file.delete();
        setState(() {
          messages.clear();
        });
        print("Chat history deleted.");
      }
    } catch (e) {
      print("Error deleting chat history: $e");
    }
  }

  void sendMessage(String message) {
    if (message.isNotEmpty) {
      final userMessage = {"message": message, "isUser": true};

      setState(() {
        messages.add(userMessage);
      });
      _textController.clear();
      _saveMessages();
      _archiveMessage(userMessage); // Archive user's message

      try {
        dialogflowService.sendMessage(message).then((response) {
          final botResponse = {"message": response, "isUser": false};

          setState(() {
            messages.add(botResponse);
          });
          _saveMessages();
          _archiveMessage(botResponse); // Archive bot's response
        });
      } catch (e) {
        print("Error: $e");
      }
    }
  }

  Future<void> _archiveMessage(Map<String, dynamic> message) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final archiveFile = File('${directory.path}/chat_archive.json');

      List<Map<String, dynamic>> archiveMessages = [];

      if (await archiveFile.exists()) {
        final content = await archiveFile.readAsString();
        archiveMessages = List<Map<String, dynamic>>.from(json.decode(content));
      }

      archiveMessages.add(message);

      await archiveFile.writeAsString(json.encode(archiveMessages));
    } catch (e) {
      print("Error archiving message: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MV Chatbot", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Delete chat history',
            onPressed: () async {
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
                await deleteChatHistory();
              }
            },
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileMenu()),
              );
            },
            child: CircleAvatar(
              backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null ? const Icon(Icons.person, color: Colors.white) : null,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: const SidebarMenu(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isUser = message["isUser"];
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(14),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blueAccent : Colors.grey[300],
                        gradient: isUser
                            ? const LinearGradient(colors: [Colors.blueAccent, Colors.lightBlue])
                            : null,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        message["message"],
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: "Ask MV Chatbot",
                        hintStyle: TextStyle(color: Theme.of(context).hintColor),
                        filled: true,
                        fillColor: Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).cardColor
                            : Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                      ),
                      style:
                      TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send,
                        color: Theme.of(context).colorScheme.secondary),
                    onPressed: () {
                      sendMessage(_textController.text);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
