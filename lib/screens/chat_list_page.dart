import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart'; // ✅ Import Service
import 'chat_room_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  // ✅ เรียกใช้ ChatService
  final ChatService _chatService = ChatService();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text('Messages', style: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold)),),
        body: StreamBuilder<QuerySnapshot>(
        stream: _chatService.getChatRooms(), 
        builder: (context, snapshot) {
          
        if (snapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  const Text("No matches yet. Go swipe!", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          var allMatches = snapshot.data!.docs;

          // -------------------------------------------------------------
          // 🧠 LOGIC แยกประเภท
          // -------------------------------------------------------------
        var newMatchesList = allMatches.where((doc) {
        var data = doc.data() as Map<String, dynamic>;
            return (data['lastMessage'] ?? "") == "New Match! Say Hi 👋";
          }).toList();

        var recentMatchesList = allMatches.where((doc) {
        var data = doc.data() as Map<String, dynamic>;
            return (data['lastMessage'] ?? "") != "New Match! Say Hi 👋";
          }).toList();

          return Column(
            children: [
              // --- 1. New Matches (แถวบน) ---
              if (newMatchesList.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Text("New Matches", style: TextStyle(color: Colors.red[400], fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10)),
                        child: Text("${newMatchesList.length}", style: TextStyle(color: Colors.red[400], fontSize: 10)),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: newMatchesList.length,
                    itemBuilder: (context, index) {
                      var matchDoc = newMatchesList[index];
                      var matchData = matchDoc.data() as Map<String, dynamic>;
                        List<dynamic> users = matchData['users'];
                        String otherUserId = users.firstWhere((id) => id != currentUserId, orElse: () => "");
                      return FutureBuilder<Map<String, dynamic>?>(
                        future: _chatService.getUserProfile(otherUserId),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) return const SizedBox(width: 70); 
                            var otherUser = userSnapshot.data!;
                          
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoomPage(
                                chatId: matchDoc.id,
                                friendName: otherUser['name'] ?? "Unknown",
                                friendImage: otherUser['photoUrl'] ?? "",
                              )));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.red.withValues(alpha: 0.5), width: 2),
                                        ),
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundImage: NetworkImage(otherUser['photoUrl'] ?? "https://via.placeholder.com/150"),
                                        ),
                                      ),
                                      if (otherUser['isOnline'] == true)
                                        Positioned(
                                          right: 2, bottom: 2,
                                          child: Container(
                                            width: 14, height: 14,
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 2),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(otherUser['name'] ?? "", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                ],
                              ),
                            ),
                          );
                        }
                      );
                    },
                  ),
                ),
              ],

              // --- 2. Recent (แถวล่าง) ---
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Align(alignment: Alignment.centerLeft, child: Text("Recent", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
              ),
              
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: recentMatchesList.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, indent: 80),
                  itemBuilder: (context, index) {
                    var matchDoc = recentMatchesList[index];
                    var matchData = matchDoc.data() as Map<String, dynamic>;
                    List<dynamic> users = matchData['users'];
                    String otherUserId = users.firstWhere((id) => id != currentUserId, orElse: () => "");

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: _chatService.getUserProfile(otherUserId),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) return const SizedBox.shrink();
                         var otherUser = userSnapshot.data!;

                        return InkWell(
                          onTap: () {
                             Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoomPage(
                                chatId: matchDoc.id,
                                friendName: otherUser['name'] ?? "Unknown",
                                friendImage: otherUser['photoUrl'] ?? "",
                              )));
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: Row(
                              children: [
                                CircleAvatar(radius: 28, backgroundImage: NetworkImage(otherUser['photoUrl'] ?? "https://via.placeholder.com/150")),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(otherUser['name'] ?? "", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                      Text(matchData['lastMessage'] ?? "", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600])),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}