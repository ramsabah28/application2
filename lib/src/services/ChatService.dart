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

class ChattService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // TODO: Set admin user ID here - replace with actual admin user ID
  static const String adminUserId = 'ADMIN_USER_ID_PLACEHOLDER';

  /// Get the current user
  static User? get currentUser => _auth.currentUser;

  /// Check if current user is admin
  static bool get isCurrentUserAdmin => currentUser?.uid == adminUserId;

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
      String chatRoomId;
      bool isFromAdmin = isCurrentUserAdmin;

      if (isFromAdmin && recipientUserId != null) {
        // Admin sending to specific user
        chatRoomId = getChatRoomId(recipientUserId);
      } else {
        // User sending to admin
        chatRoomId = getChatRoomId(currentUser!.uid);
      }

      final message = Message(
        id: '',
        senderId: currentUser!.uid,
        senderName: currentUser!.displayName ?? currentUser!.email ?? 'User',
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
      await _firestore.collection('chats').doc(chatRoomId).set({
        'participants': [currentUser!.uid, isFromAdmin ? recipientUserId : adminUserId],
        'lastMessage': content.trim(),
        'lastMessageTime': Timestamp.fromDate(DateTime.now()),
        'lastMessageSender': currentUser!.uid,
      }, SetOptions(merge: true));

    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Get messages stream for current user's chat with admin
  static Stream<List<Message>> getMessagesStream({String? chatWithUserId}) {
    if (currentUser == null) {
      return Stream.value([]);
    }

    String chatRoomId;
    if (isCurrentUserAdmin && chatWithUserId != null) {
      // Admin viewing chat with specific user
      chatRoomId = getChatRoomId(chatWithUserId);
    } else {
      // User viewing chat with admin
      chatRoomId = getChatRoomId(currentUser!.uid);
    }

    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
    });
  }

  /// Get all user chats (for admin to see all conversations)
  static Stream<List<Map<String, dynamic>>> getAllUserChatsStream() {
    if (!isCurrentUserAdmin) {
      return Stream.value([]);
    }

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: adminUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return {
          'chatRoomId': doc.id,
          'participants': data['participants'] ?? [],
          'lastMessage': data['lastMessage'] ?? '',
          'lastMessageTime': data['lastMessageTime'] ?? Timestamp.now(),
          'lastMessageSender': data['lastMessageSender'] ?? '',
        };
      }).toList();
    });
  }

  /// Mark messages as read (for future implementation)
  static Future<void> markMessagesAsRead({String? chatWithUserId}) async {
    if (currentUser == null) return;

    try {
      String chatRoomId;
      if (isCurrentUserAdmin && chatWithUserId != null) {
        chatRoomId = getChatRoomId(chatWithUserId);
      } else {
        chatRoomId = getChatRoomId(currentUser!.uid);
      }

      // Update read status in chat room metadata
      await _firestore.collection('chats').doc(chatRoomId).update({
        'lastReadBy_${currentUser!.uid}': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Failed to mark messages as read: $e');
    }
  }

  /// Get user info by ID (for admin to display user names)
  static Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    try {
      // This would typically fetch from a users collection
      // For now, we'll return basic info
      return {
        'id': userId,
        'name': 'User', // TODO: Fetch actual user name from users collection
        'email': '', // TODO: Fetch actual email from users collection
      };
    } catch (e) {
      print('Failed to get user info: $e');
      return null;
    }
  }
}
