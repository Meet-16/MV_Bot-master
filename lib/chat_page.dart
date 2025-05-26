import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

import 'sidebar_menu.dart';
import 'profile_menu.dart';
import 'dialogflow_service.dart';
import 'chat_session_provider.dart';

class ChatPage extends StatefulWidget {
  final String sessionTitle;
  final int sessionIndex;

  const ChatPage({super.key, required this.sessionTitle, required this.sessionIndex});

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

    user = FirebaseAuth.instance.currentUser;

    FirebaseAuth.instance.authStateChanges().listen((User? updatedUser) {
      if (mounted && updatedUser != user) {
        setState(() {
          user = updatedUser;
        });
      }
    });
  }

  Future<String> _getSessionFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/chat_messages_${widget.sessionIndex}.json';
  }

  Future<void> _loadMessages() async {
    try {
      final filePath = await _getSessionFilePath();
      final file = File(filePath);
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
      final filePath = await _getSessionFilePath();
      final file = File(filePath);
      await file.writeAsString(json.encode(messages));
    } catch (e) {
      print("Error saving messages: $e");
    }
  }

  Future<void> deleteChatHistory() async {
    try {
      final filePath = await _getSessionFilePath();
      final file = File(filePath);
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
    if (message.trim().isEmpty) return;

    final userMessage = {"message": message.trim(), "isUser": true};

    setState(() {
      messages.add(userMessage);
    });
    _textController.clear();
    _saveMessages();
    _archiveMessage(userMessage);

    dialogflowService.sendMessage(message).then((response) {
      final botResponse = {"message": response, "isUser": false};

      setState(() {
        messages.add(botResponse);
      });
      _saveMessages();
      _archiveMessage(botResponse);
    }).catchError((e) {
      print("Dialogflow error: $e");
    });
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

      final archivedMessage = {
        "session": widget.sessionTitle,
        "timestamp": DateTime.now().toIso8601String(),
        ...message,
      };

      archiveMessages.add(archivedMessage);
      await archiveFile.writeAsString(json.encode(archiveMessages));
    } catch (e) {
      print("Error archiving message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sessionTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
                  ],
                ),
              );
              if (confirm == true) {
                await deleteChatHistory();
              }
            },
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileMenu())),
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
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isUser = message["isUser"];
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
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
                        hintStyle: TextStyle(color: theme.hintColor),
                        filled: true,
                        fillColor: theme.brightness == Brightness.dark
                            ? theme.cardColor
                            : Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      ),
                      style: TextStyle(color: theme.textTheme.bodyLarge!.color),
                      onSubmitted: sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send, color: theme.colorScheme.secondary),
                    onPressed: () => sendMessage(_textController.text),
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
