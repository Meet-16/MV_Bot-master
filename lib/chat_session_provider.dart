import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class ChatSessionProvider extends ChangeNotifier {
  List<String> sessions = [];
  int currentIndex = 0;

  void addSession(String title) {
    sessions.add(title);
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }

  void renameSession(int index, String newTitle) {
    sessions[index] = newTitle;
    notifyListeners();
  }

  Future<void> deleteSession(int index) async {
    try {
      // Delete the chat_messages_<index>.json file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/chat_messages_$index.json';
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Remove session-related messages from chat_archive.json
      final archiveFile = File('${directory.path}/chat_archive.json');
      if (await archiveFile.exists()) {
        final content = await archiveFile.readAsString();
        List<dynamic> archiveMessages = json.decode(content);

        // Filter out messages related to this session
        archiveMessages = archiveMessages
            .where((msg) => msg["session"] != sessions[index])
            .toList();

        await archiveFile.writeAsString(json.encode(archiveMessages));
      }

      // Remove the session from the list
      sessions.removeAt(index);

      // Reset currentIndex if necessary
      if (currentIndex >= sessions.length) {
        currentIndex = sessions.isEmpty ? 0 : sessions.length - 1;
      }

      notifyListeners();
    } catch (e) {
      print("Error deleting session: $e");
    }
  }
}