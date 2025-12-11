import 'package:flutter/material.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 186, 214, 177),
      body: ListView.builder(
        itemCount: 10, // mock 10 แชท
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color.fromARGB(255, 28, 140, 49),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text("User $index"),
            subtitle: const Text("Tap to chat..."),
            trailing: const Icon(Icons.chevron_right),

            // ❗ context ถูกต้อง เพราะอยู่ใน builder
            onTap: () {
              Navigator.pushNamed(context, '/chat-room');
            },
          );
        },
      ),
    );
  }
}
