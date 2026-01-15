import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart'; // ✅ เรียกใช้ Service

class ChatRoomPage extends StatefulWidget {
  final String chatId;
  final String friendName;
  final String friendImage;

  const ChatRoomPage({
    super.key, 
    required this.chatId,
    required this.friendName,
    required this.friendImage,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

  class _ChatRoomPageState extends State<ChatRoomPage> {
    final TextEditingController _messageController = TextEditingController();
    final ChatService _chatService = ChatService(); // ✅ Instance
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    void _sendMessage() {
      if (_messageController.text.trim().isEmpty) return;
      
      // เรียกใช้ Service
      _chatService.sendMessage(widget.chatId, _messageController.text.trim());
      _messageController.clear();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.friendImage),
                radius: 18,
              ),
              const SizedBox(width: 10),
              Text(widget.friendName, style: const TextStyle(color: Colors.black, fontSize: 18)),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _chatService.getMessages(widget.chatId), // ✅ เรียกผ่าน Service
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  
                  var messages = snapshot.data!.docs;

                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    itemBuilder: (context, index) {
                      var msgData = messages[index].data() as Map<String, dynamic>;
                      bool isMe = msgData['senderId'] == currentUserId;

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFF1DB954) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            msgData['text'] ?? "",
                            style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 16),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            
            // ช่องพิมพ์
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5)]),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(hintText: "Type a message...", border: InputBorder.none),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFF1DB954)),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }