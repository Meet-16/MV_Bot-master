import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

class ArchiveChatPage extends StatefulWidget {
  const ArchiveChatPage({super.key});

  @override
  State<ArchiveChatPage> createState() => _ArchiveChatPageState();
}

class _ArchiveChatPageState extends State<ArchiveChatPage> {
  List<String> archivedMessages = [];

  @override
  void initState() {
    super.initState();
    loadArchivedMessages();
  }

  Future<void> loadArchivedMessages() async {
    final directory = await getApplicationDocumentsDirectory();
    final archiveFile = File('${directory.path}/chat_archive.json');

    if (await archiveFile.exists()) {
      final contents = await archiveFile.readAsString();
      setState(() {
        archivedMessages = List<String>.from(jsonDecode(contents));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Archived Chats"),
      ),
      body: archivedMessages.isEmpty
          ? const Center(child: Text("No archived chats found."))
          : ListView.builder(
        itemCount: archivedMessages.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(archivedMessages[index]),
          );
        },
      ),
    );
  }
}
