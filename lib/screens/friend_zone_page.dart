import 'package:flutter/material.dart';

class FriendZonePage extends StatelessWidget {
  const FriendZonePage({super.key});

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
        title: const Text('Friend Zone'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255), // เขียวเข้ม KUpid
      ),
      body: ListView.builder(
        itemCount: mockFriends.length,
        itemBuilder: (context, index) {
          final friend = mockFriends[index];
          return Card(
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0C2F1C),
        unselectedItemColor: Colors.grey,
        currentIndex: 1, // เลือกไอคอน Friends
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/swipe');
              break;
            case 1:
              break; // อยู่หน้าปัจจุบัน
            case 2:
              Navigator.pushReplacementNamed(context, '/chats');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Love',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
