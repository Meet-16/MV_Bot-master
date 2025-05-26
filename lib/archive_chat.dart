import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ArchiveChatPage extends StatefulWidget {
  const ArchiveChatPage({super.key});

  @override
  State<ArchiveChatPage> createState() => _ArchiveChatPageState();
}

class _ArchiveChatPageState extends State<ArchiveChatPage> {
  List<Map<String, dynamic>> archivedSessions = [];

  @override
  void initState() {
    super.initState();
    _loadArchivedChats();
  }

  Future<void> _loadArchivedChats() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/chat_archive.json');

      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonData = jsonDecode(content);

        setState(() {
          archivedSessions = jsonData.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      print("Error loading archived chats: $e");
    }
  }

  Future<void> _clearArchive() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/chat_archive.json');

      if (await file.exists()) {
        await file.delete();
      }

      setState(() {
        archivedSessions.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Archive cleared.")),
        );
      }
    } catch (e) {
      print("Error clearing archive: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to clear archive.")),
        );
      }
    }
  }

  void _confirmClearArchive() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Clear All Archives?"),
        content: const Text("This will permanently delete all archived chats."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Clear", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _clearArchive();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Archived Sessions"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: "Clear Archive",
            onPressed: _confirmClearArchive,
          ),
        ],
      ),
      body: archivedSessions.isEmpty
          ? const Center(child: Text("No archived sessions found."))
          : ListView.builder(
        itemCount: archivedSessions.length,
        itemBuilder: (context, index) {
          final session = archivedSessions[index];
          final sessionName = session["session"] ?? "Unknown";
          final timestamp = session["timestamp"] ?? "No timestamp";
          final messages = session["messages"] ?? [];

          return ExpansionTile(
            leading: const Icon(Icons.archive),
            title: Text(sessionName),
            subtitle: Text("Archived at: $timestamp"),
            children: messages.map<Widget>((msg) {
              return ListTile(
                leading: Icon(msg['isUser'] == true ? Icons.person : Icons.smart_toy),
                title: Text(msg["message"]),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
