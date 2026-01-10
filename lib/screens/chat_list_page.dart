import 'package:flutter/material.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  // --- Mock Data ที่ละเอียดขึ้น ---
  // แยกเป็น 2 ส่วน: คนที่เพิ่ง Match (ด้านบน) และ คนที่คุยค้างไว้ (ด้านล่าง)
  final List<Map<String, dynamic>> newMatches = [
    {"name": "Fah", "image": "assets/mock/girl4.jpg", "isOnline": true},
    {"name": "Ploy", "image": "assets/mock/girl5.jpg", "isOnline": false},
  ];

  final List<Map<String, dynamic>> chatList = [
    {
      "name": "Alice",
      "image": "assets/mock/girl1.jpg",
      "message": "วันนี้ว่างไหม? ไปกินข้าวกัน",
      "time": "10:30 AM",
      "unread": 2, // จำนวนข้อความที่ยังไม่อ่าน
      "isOnline": true
    },
    {
      "name": "Beem",
      "image": "assets/mock/girl2.jpg",
      "message": "ส่งงานวิชา Cloud ยังอ่า?",
      "time": "Yesterday",
      "unread": 0,
      "isOnline": false
    },
    {
      "name": "Mint",
      "image": "assets/mock/girl3.jpg",
      "message": "ไว้เจอกันนะ 👋",
      "time": "Sun",
      "unread": 0,
      "isOnline": true
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // พื้นหลังขาวสะอาดตาแบบแอปแชท Pro
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text(
          'Messages', // แก้จาก Massage
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search, color: Colors.black),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // ------------------------------------------
          // 1. New Matches Section (แนวนอน)
          // ------------------------------------------
          if (newMatches.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Text(
                    "New Matches",
                    style: TextStyle(
                      color: Colors.red[400], // สีแดงสื่อถึงความรัก/แมตช์ใหม่
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text("${newMatches.length}", style: TextStyle(color: Colors.red[400], fontSize: 10)),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: newMatches.length,
                itemBuilder: (context, index) {
                  final match = newMatches[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3), // ขอบสี
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.red.withOpacity(0.5), width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(match['image']), // หรือ AssetImage
                              ),
                            ),
                            if (match['isOnline'])
                              Positioned(
                                right: 2,
                                bottom: 2,
                                child: Container(
                                  width: 14,
                                  height: 14,
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
                        Text(
                          match['name'],
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],

          // ------------------------------------------
          // 2. Chat List Section (แนวตั้ง)
          // ------------------------------------------
           const Padding(
             padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
             child: Align(
               alignment: Alignment.centerLeft,
               child: Text("Recent", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
             ),
           ),
           
           Expanded(
             child: ListView.separated(
               padding: const EdgeInsets.only(bottom: 20),
               itemCount: chatList.length,
               separatorBuilder: (context, index) => const Divider(height: 1, indent: 80),
               itemBuilder: (context, index) {
                 final chat = chatList[index];
                 final bool hasUnread = chat['unread'] > 0;
                 
                 return InkWell(
                   onTap: () {
                     Navigator.pushNamed(context, '/chatroom');
                   },
                   child: Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                     child: Row(
                       children: [
                         // --- Avatar ---
                         Stack(
                           children: [
                             CircleAvatar(
                               radius: 28,
                               backgroundImage: NetworkImage(chat['image']), // หรือ AssetImage
                             ),
                             if (chat['isOnline'])
                               Positioned(
                                 right: 0,
                                 bottom: 0,
                                 child: Container(
                                   width: 16,
                                   height: 16,
                                   decoration: BoxDecoration(
                                     color: const Color(0xFF32CD32), // เขียว KUpid
                                     shape: BoxShape.circle,
                                     border: Border.all(color: Colors.white, width: 2.5),
                                   ),
                                 ),
                               ),
                           ],
                         ),
                         
                         const SizedBox(width: 16),
                         
                         // --- Message Info ---
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 children: [
                                   Text(
                                     chat['name'],
                                     style: TextStyle(
                                       fontSize: 16,
                                       fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w600,
                                       color: Colors.black87,
                                     ),
                                   ),
                                   Text(
                                     chat['time'],
                                     style: TextStyle(
                                       fontSize: 12,
                                       color: hasUnread ? const Color(0xFF32CD32) : Colors.grey,
                                       fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                                     ),
                                   ),
                                 ],
                               ),
                               const SizedBox(height: 4),
                               Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 children: [
                                   Expanded(
                                     child: Text(
                                       chat['message'],
                                       maxLines: 1,
                                       overflow: TextOverflow.ellipsis,
                                       style: TextStyle(
                                         color: hasUnread ? Colors.black87 : Colors.grey[600],
                                         fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                                         fontSize: 14,
                                       ),
                                     ),
                                   ),
                                   if (hasUnread)
                                     Container(
                                       margin: const EdgeInsets.only(left: 8),
                                       padding: const EdgeInsets.all(6),
                                       decoration: const BoxDecoration(
                                         color: Color(0xFF32CD32),
                                         shape: BoxShape.circle,
                                       ),
                                       child: Text(
                                         "${chat['unread']}",
                                         style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                       ),
                                     ),
                                 ],
                               ),
                             ],
                           ),
                         ),
                       ],
                     ),
                   ),
                 );
               },
             ),
           ),
        ],
      ),    );
  }}