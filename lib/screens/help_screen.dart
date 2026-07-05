import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Help & Support"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(leading: Icon(Icons.help_outline), title: Text("FAQ")),
          ListTile(
            leading: Icon(Icons.email_outlined),
            title: Text("Contact Us"),
          ),
          ListTile(
            leading: Icon(Icons.feedback_outlined),
            title: Text("Feedback"),
          ),
          ListTile(
            leading: Icon(Icons.smart_toy_outlined),
            title: Text("Chat with DARSAN AI"),
          ),
        ],
      ),
    );
  }
}
