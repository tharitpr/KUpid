import 'package:flutter/material.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  // Mock data เพื่อน
  final List<Map<String, String>> mockFriends = const [
    {
      "name": "Alice, 20",
      "faculty": "Faculty of Engineering",
      "image": "assets/mock/girl1.jpg"
    },
    {
      "name": "Beem, 21",
      "faculty": "Faculty of Science",
      "image": "assets/mock/girl2.jpg"
    },
    {
      "name": "Mint, 22",
      "faculty": "Faculty of Architecture",
      "image": "assets/mock/girl3.jpg"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Massage'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255), 
        automaticallyImplyLeading: false, 
      ),
      
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE5F2E4),
              Color(0xFFE5F2E4),
              Color(0xFFF2F1E4),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: ListView.builder(
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          itemCount: mockFriends.length,
          itemBuilder: (context, index) {
            final friend = mockFriends[index];
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(friend['image']!),
              ),
              title: Text(friend['name']!),
              subtitle: Text(friend['faculty']!),
              trailing: IconButton(
                icon: const Icon(Icons.chat),
                onPressed: () {
                  // TODO: นำทางไปยัง Chat Room กับเพื่อนคนนี้
                  Navigator.pushNamed(context, '/chatroom');
                },
              ),
            ),
          );
        },
      ),
      )
    );
  }
}
