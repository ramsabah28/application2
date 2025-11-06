import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isFromAdmin;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.isFromAdmin,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isFromAdmin: data['isFromAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isFromAdmin': isFromAdmin,
    };
  }
}

class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the current user
  static User? get currentUser => _auth.currentUser;

  /// Get current user's role from Firestore
  static Future<String?> getCurrentUserRole() async {
    if (currentUser == null) return null;
    
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return userData['roll']; // Using 'roll' as shown in the Firestore image
      }
    } catch (e) {
      print('Error getting user role: $e');
    }
    return null;
  }

  /// Check if current user is admin
  static Future<bool> isCurrentUserAdmin() async {
    String? role = await getCurrentUserRole();
    return role == 'admin';
  }

  /// Generate chat room ID between user and admin
  static String getChatRoomId(String userId) {
    // For user-admin chats, use a consistent format
    return 'chat_${userId}_admin';
  }

  /// Send a message in the chat
  static Future<void> sendMessage({
    required String content,
    String? recipientUserId,
  }) async {
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    if (content.trim().isEmpty) {
      throw Exception('Message content cannot be empty');
    }

    try {
      String? userRole = await getCurrentUserRole();
      if (userRole == null) {
        throw Exception('Unable to determine user role');
      }

      bool isFromAdmin = userRole == 'admin';
      String chatRoomId;

      if (isFromAdmin && recipientUserId != null) {
        // Admin sending to specific user
        chatRoomId = getChatRoomId(recipientUserId);
      } else if (!isFromAdmin) {
        // Regular user sending to admin (only allowed option for users)
        chatRoomId = getChatRoomId(currentUser!.uid);
      } else {
        throw Exception('Invalid chat configuration');
      }

      // Get sender name from users collection
      DocumentSnapshot senderDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      
      String senderName = 'User';
      if (senderDoc.exists) {
        Map<String, dynamic> senderData = senderDoc.data() as Map<String, dynamic>;
        senderName = senderData['name'] ?? senderData['username'] ?? 'User';
        if (isFromAdmin) {
          senderName = 'Admin ($senderName)';
        }
      }

      final message = Message(
        id: '',
        senderId: currentUser!.uid,
        senderName: senderName,
        content: content.trim(),
        timestamp: DateTime.now(),
        isFromAdmin: isFromAdmin,
      );

      await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .add(message.toFirestore());

      // Update chat room metadata
      List<String> participants = [currentUser!.uid];
      if (isFromAdmin && recipientUserId != null) {
        participants.add(recipientUserId);
      } else {
        // Find admin user ID for participants
        QuerySnapshot adminQuery = await _firestore
            .collection('users')
            .where('roll', isEqualTo: 'admin')
            .limit(1)
            .get();
        
        if (adminQuery.docs.isNotEmpty) {
          participants.add(adminQuery.docs.first.id);
        }
      }

      await _firestore.collection('chats').doc(chatRoomId).set({
        'participants': participants,
        'lastMessage': content.trim(),
        'lastMessageTime': Timestamp.fromDate(DateTime.now()),
        'lastMessageSender': currentUser!.uid,
        'lastMessageSenderName': senderName,
      }, SetOptions(merge: true));

    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Get messages stream for current user's chat
  static Stream<List<Message>> getMessagesStream({String? chatWithUserId}) async* {
    if (currentUser == null) {
      yield [];
      return;
    }

    try {
      String? userRole = await getCurrentUserRole();
      if (userRole == null) {
        yield [];
        return;
      }

      String chatRoomId;
      if (userRole == 'admin' && chatWithUserId != null) {
        // Admin viewing chat with specific user
        chatRoomId = getChatRoomId(chatWithUserId);
      } else if (userRole == 'user') {
        // Regular user viewing their chat with admin
        chatRoomId = getChatRoomId(currentUser!.uid);
      } else {
        yield [];
        return;
      }

      yield* _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
      });
    } catch (e) {
      print('Error in getMessagesStream: $e');
      yield [];
    }
  }

  /// Get all user chats (for admin only)
  static Stream<List<Map<String, dynamic>>> getAllUserChatsStream() async* {
    if (currentUser == null) {
      yield [];
      return;
    }

    try {
      bool isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) {
        yield [];
        return;
      }

      yield* _firestore
          .collection('chats')
          .where('participants', arrayContains: currentUser!.uid)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
        List<Map<String, dynamic>> chats = [];
        
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          List<dynamic> participants = data['participants'] ?? [];
          
          // Find the other participant (non-admin user)
          String? otherUserId;
          for (String participantId in participants.cast<String>()) {
            if (participantId != currentUser!.uid) {
              otherUserId = participantId;
              break;
            }
          }

          if (otherUserId != null) {
            // Get user info
            try {
              DocumentSnapshot userDoc = await _firestore
                  .collection('users')
                  .doc(otherUserId)
                  .get();
              
              String userName = 'Unknown User';
              if (userDoc.exists) {
                Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
                userName = userData['name'] ?? userData['username'] ?? 'Unknown User';
              }

              chats.add({
                'chatRoomId': doc.id,
                'otherUserId': otherUserId,
                'otherUserName': userName,
                'participants': participants,
                'lastMessage': data['lastMessage'] ?? '',
                'lastMessageTime': data['lastMessageTime'] ?? Timestamp.now(),
                'lastMessageSender': data['lastMessageSender'] ?? '',
                'lastMessageSenderName': data['lastMessageSenderName'] ?? '',
              });
            } catch (e) {
              print('Error getting user info for $otherUserId: $e');
            }
          }
        }
        
        return chats;
      });
    } catch (e) {
      print('Error in getAllUserChatsStream: $e');
      yield [];
    }
  }

  /// Mark messages as read
  static Future<void> markMessagesAsRead({String? chatWithUserId}) async {
    if (currentUser == null) return;

    try {
      String? userRole = await getCurrentUserRole();
      if (userRole == null) return;

      String chatRoomId;
      if (userRole == 'admin' && chatWithUserId != null) {
        chatRoomId = getChatRoomId(chatWithUserId);
      } else {
        chatRoomId = getChatRoomId(currentUser!.uid);
      }

      await _firestore.collection('chats').doc(chatRoomId).update({
        'lastReadBy_${currentUser!.uid}': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Failed to mark messages as read: $e');
    }
  }

  /// Get user info by ID
  static Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return {
          'id': userId,
          'name': userData['name'] ?? 'Unknown',
          'username': userData['username'] ?? '',
          'email': userData['email'] ?? '',
          'role': userData['roll'] ?? 'user', // Using 'roll' from Firestore
        };
      }
    } catch (e) {
      print('Failed to get user info: $e');
    }
    return null;
  }

  /// Check if user can access chat (both users and admins can access)
  static Future<bool> canAccessChat() async {
    if (currentUser == null) return false;
    
    String? role = await getCurrentUserRole();
    return role == 'user' || role == 'admin';
  }

  /// Check if user can view other users' chats (admin only)
  static Future<bool> canViewAllChats() async {
    return await isCurrentUserAdmin();
  }
}
