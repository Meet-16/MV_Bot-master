import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'archive_chat.dart';
import 'chat_session_provider.dart';
import 'chat_page.dart';
import 'archive_chat.dart';

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessionProvider = Provider.of<ChatSessionProvider>(context);

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: theme.primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.menu, size: 30, color: Colors.white),
                SizedBox(height: 10),
                Text("MV Chatbot",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                Text("Your AI Assistant", style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          // ✅ New Chat button
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text("New Chat"),
            onTap: () {
              final newSessionName = "Chat ${sessionProvider.sessions.length + 1}";
              sessionProvider.addSession(newSessionName);
              final newIndex = sessionProvider.sessions.length - 1;
              sessionProvider.setCurrentIndex(newIndex);
              Navigator.pop(context);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    sessionTitle: newSessionName,
                    sessionIndex: newIndex,
                  ),
                ),
              );
            },
          ),

          // ✅ Archive button
          ListTile(
            leading: const Icon(Icons.archive),
            title: const Text("View Archive"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ArchiveChatPage()),
              );
            },
          ),

          // Chat sessions
          if (sessionProvider.sessions.isNotEmpty)
            ExpansionTile(
              leading: const Icon(Icons.list),
              title: const Text("Chat Sessions"),
              children: sessionProvider.sessions.asMap().entries.map((entry) {
                final index = entry.key;
                final title = entry.value;
                return ListTile(
                  title: Text(title),
                  onTap: () {
                    sessionProvider.setCurrentIndex(index);
                    Navigator.pop(context);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          sessionTitle: title,
                          sessionIndex: index,
                        ),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit Button
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        tooltip: 'Rename session',
                        onPressed: () => _renameDialog(context, index, sessionProvider),
                      ),

                      // Archive Button
                      IconButton(
                        icon: const Icon(Icons.archive, size: 18, color: Colors.deepPurple),
                        tooltip: 'Archive chat',
                        onPressed: () async {
                          await _archiveSession(context, index);
                        },
                      ),

                      // Delete Button
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18),
                        tooltip: 'Delete session',
                        onPressed: () => _confirmDeleteDialog(context, index, sessionProvider),
                      ),
                    ],
                  ),

                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _renameDialog(BuildContext context, int index, ChatSessionProvider provider) {
    final controller = TextEditingController(text: provider.sessions[index]);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Rename Chat"),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              provider.renameSession(index, controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteDialog(BuildContext context, int index, ChatSessionProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Session?"),
        content: const Text("This will permanently delete the chat history for this session."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await provider.deleteSession(index);
    }
  }
}

Future<void> _archiveSession(BuildContext context, int index) async {
  try {
    final directory = await getApplicationDocumentsDirectory();

    final sessionFile = File('${directory.path}/chat_messages_$index.json');
    final archiveFile = File('${directory.path}/chat_archive.json');

    if (!await sessionFile.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No chat history found to archive.")),
      );
      return;
    }

    // Read current session messages
    final sessionMessages = json.decode(await sessionFile.readAsString());

    // Load existing archive data (if any)
    List<dynamic> archiveMessages = [];
    if (await archiveFile.exists()) {
      archiveMessages = json.decode(await archiveFile.readAsString());
    }

    // Add session messages to archive with session metadata
    final sessionTitle = Provider.of<ChatSessionProvider>(context, listen: false).sessions[index];
    final timestamp = DateTime.now().toIso8601String();

    for (var message in sessionMessages) {
      archiveMessages.add({
        "session": sessionTitle,
        "timestamp": timestamp,
        ...message,
      });
    }

    // Save updated archive
    await archiveFile.writeAsString(json.encode(archiveMessages));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Chat successfully archived.")),
    );
  } catch (e) {
    print("Error archiving chat: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to archive chat.")),
    );
  }
}
