import 'package:flutter/material.dart';
import '../screens/ai_chat_screen.dart';

class FloatingAIButton extends StatelessWidget {
  FloatingAIButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: Colors.deepPurple,
      elevation: 8,
      icon: const Icon(Icons.smart_toy, color: Colors.white),
      label: const Text("AI", style: TextStyle(color: Colors.white)),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AIChatScreen()),
        );
      },
    );
  }
}
