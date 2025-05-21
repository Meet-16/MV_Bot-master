import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart'; // Import ThemeProvider

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the current theme
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor, // ✅ Use Theme Background
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.primaryColor, // ✅ Dynamic Header Color
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.menu, size: 30, color: Colors.white),
                const SizedBox(height: 10),
                const Text(
                  "MV Chatbot",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Text("Your AI Assistant", style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          _menuItem(Icons.search, "Search Chats", context, () {}),
          _menuItem(Icons.add, "New Chat", context, () {}),
          _menuItem(Icons.history, "History", context, () {}),
          const Divider(),
          ExpansionTile(
            leading: Icon(Icons.help_outline, color: theme.iconTheme.color), // ✅ Dynamic Icon Color
            title: Text("Help", style: TextStyle(color: theme.textTheme.bodyLarge!.color)), // ✅ Dynamic Text Color
            children: [
              _menuItem(Icons.update, "Updates", context, () {}),
              _menuItem(Icons.bug_report, "Report Issue or Bug", context, () {}),
              _menuItem(Icons.question_answer, "FAQ", context, () {}),
              _menuItem(Icons.info_outline, "About MV", context, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String text, BuildContext context, VoidCallback onTap) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.iconTheme.color), // ✅ Dynamic Icon Color
      title: Text(text, style: TextStyle(color: theme.textTheme.bodyLarge!.color)), // ✅ Dynamic Text Color
      onTap: onTap,
    );
  }
}
