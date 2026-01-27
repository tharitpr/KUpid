import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart';

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
  final ChatService _chatService = ChatService();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final ScrollController _scrollController = ScrollController();

  // สีธีมแอป
  final Color _primaryColor = const Color(0xFF006400); 
  final Color _myBubbleColor = const Color(0xFFE8F5E9); 
  final Color _friendBubbleColor = Colors.white; 

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    _chatService.sendMessage(widget.chatId, _messageController.text.trim());
    _messageController.clear();
  }

  // --- 📅 1. Helper Functions สำหรับวันที่ ---
  
  // เช็คว่าเป็นวันเดียวกันหรือไม่
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  // แปลงวันที่เป็นคำพูด (Today, Yesterday, dd/MM/yyyy)
  String _getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return "Today";
    } else if (dateToCheck == yesterday) {
      return "Yesterday";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7), 
      
      // ----------------------------------------------------
      // APP BAR
      // ----------------------------------------------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.friendImage),
                  radius: 20,
                  backgroundColor: Colors.grey[200],
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent[400], 
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.friendName,
                  style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Active now",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam_outlined, color: Colors.black54), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call_outlined, color: Colors.black54), onPressed: () {}),
        ],
      ),

      // ----------------------------------------------------
      // BODY
      // ----------------------------------------------------
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Error loading messages"));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, 
                  itemCount: messages.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemBuilder: (context, index) {
                    var msgData = messages[index].data() as Map<String, dynamic>;
                    bool isMe = msgData['senderId'] == currentUserId;
                    
                    Timestamp? ts = msgData['timestamp'];
                    DateTime messageDate = ts?.toDate() ?? DateTime.now();
                    String time = ts != null 
                        ? "${messageDate.hour.toString().padLeft(2, '0')}:${messageDate.minute.toString().padLeft(2, '0')}" 
                        : "";

                    // --- 📅 2. Logic คำนวณ Header วันที่ ---
                    // เนื่องจาก ListView เป็น reverse (ล่างขึ้นบน)
                    // เราต้องเช็คข้อความ "ถัดไป" (index + 1) ซึ่งจริงๆ คือข้อความที่ "เก่ากว่า"
                    bool showDateHeader = false;
                    if (index + 1 < messages.length) {
                      var olderMsgData = messages[index + 1].data() as Map<String, dynamic>;
                      Timestamp? olderTs = olderMsgData['timestamp'];
                      if (olderTs != null) {
                        DateTime olderDate = olderTs.toDate();
                        // ถ้าวันไม่เหมือนกัน ให้โชว์ Header
                        if (!_isSameDay(messageDate, olderDate)) {
                          showDateHeader = true;
                        }
                      }
                    } else {
                      // ถ้าเป็นข้อความสุดท้าย (บนสุดของจอ / เก่าสุด) ให้โชว์วันที่เสมอ
                      showDateHeader = true;
                    }

                    return Column(
                      children: [
                        // เพราะ Reverse: Header ต้องอยู่ "ล่างสุดของ Column" เพื่อให้ไปโผล่ "ข้างบน Bubble" ในหน้าจอจริง
                        if (showDateHeader) _buildDateHeader(messageDate),
                        _buildMessageBubble(msgData['text'] ?? "", isMe, time),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // ----------------------------------------------------
          // INPUT AREA
          // ----------------------------------------------------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.grey, size: 28),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: "Type a message...",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _primaryColor, 
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 📅 3. Widget สร้าง Date Header สวยๆ ---
  Widget _buildDateHeader(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[300], // พื้นหลังสีเทาอ่อน
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getFormattedDate(date),
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String message, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isMe ? _myBubbleColor : _friendBubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
                bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.black87, fontSize: 16, height: 1.4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 8),
            child: Text(time, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ),
        ],
      ),
    );
  }
}