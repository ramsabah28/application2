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
  static Future<String> getCurrentUserRole() async {
    if (currentUser == null) {
      print('No current user found, defaulting to user role');
      return 'user'; // Default to user role when no authentication
    }
    
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String? role = userData['roll']; // Using 'roll' as shown in the Firestore image
        
        // Default to 'user' if role is null or empty
        if (role == null || role.isEmpty) {
          print('User ${currentUser!.uid} has no role defined, defaulting to user');
          role = 'user';
        }
        
        print('User ${currentUser!.uid} has role: $role');
        return role;
      } else {
        print('User document does not exist for ${currentUser!.uid}, defaulting to user role');
        return 'user'; // Default to user role when document doesn't exist
      }
    } catch (e) {
      print('Error getting user role: $e, defaulting to user role');
      return 'user'; // Default to user role on error
    }
  }

  /// Check if current user is admin
  static Future<bool> isCurrentUserAdmin() async {
    String role = await getCurrentUserRole(); // Now returns non-nullable String
    bool isAdmin = role == 'admin';
    print('isCurrentUserAdmin result: $isAdmin (role: $role)');
    return isAdmin;
  }

  /// Generate chat room ID between user and admin
  static String getChatRoomId(String userId) {
    // For user-admin chats, use a consistent format
    String chatRoomId = 'chat_${userId}_admin';
    print('getChatRoomId: userId = $userId, chatRoomId = $chatRoomId');
    return chatRoomId;
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
      String userRole = await getCurrentUserRole();
      print('sendMessage: userRole = $userRole');

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

      // Update chat room metadata with user information
      List<String> participants = [currentUser!.uid];
      Map<String, dynamic> chatMetadata = {
        'lastMessage': content.trim(),
        'lastMessageTime': Timestamp.fromDate(DateTime.now()),
        'lastMessageSender': currentUser!.uid,
        'lastMessageSenderName': senderName,
      };

      if (isFromAdmin && recipientUserId != null) {
        participants.add(recipientUserId);
        
        // Get recipient user information
        try {
          DocumentSnapshot recipientDoc = await _firestore
              .collection('users')
              .doc(recipientUserId)
              .get();
          
          if (recipientDoc.exists) {
            Map<String, dynamic> recipientData = recipientDoc.data() as Map<String, dynamic>;
            chatMetadata['recipientUserId'] = recipientUserId;
            chatMetadata['recipientName'] = recipientData['name'] ?? '';
            chatMetadata['recipientSurname'] = recipientData['nachname'] ?? '';
            chatMetadata['recipientUsername'] = recipientData['username'] ?? '';
            chatMetadata['recipientEmail'] = recipientData['email'] ?? '';
          }
        } catch (e) {
          print('Error getting recipient info: $e');
        }
        
      } else {
        // Find admin user ID for participants and get admin info
        QuerySnapshot adminQuery = await _firestore
            .collection('users')
            .where('roll', isEqualTo: 'admin')
            .limit(1)
            .get();
        
        if (adminQuery.docs.isNotEmpty) {
          String adminId = adminQuery.docs.first.id;
          participants.add(adminId);
          
          // Get admin user information
          Map<String, dynamic> adminData = adminQuery.docs.first.data() as Map<String, dynamic>;
          chatMetadata['adminUserId'] = adminId;
          chatMetadata['adminName'] = adminData['name'] ?? '';
          chatMetadata['adminSurname'] = adminData['nachname'] ?? '';
          chatMetadata['adminUsername'] = adminData['username'] ?? '';
          chatMetadata['adminEmail'] = adminData['email'] ?? '';
        }
        
        // Get current user (sender) information for user-to-admin chats
        try {
          DocumentSnapshot senderDoc = await _firestore
              .collection('users')
              .doc(currentUser!.uid)
              .get();
          
          if (senderDoc.exists) {
            Map<String, dynamic> senderData = senderDoc.data() as Map<String, dynamic>;
            chatMetadata['senderUserId'] = currentUser!.uid;
            chatMetadata['senderName'] = senderData['name'] ?? '';
            chatMetadata['senderSurname'] = senderData['nachname'] ?? '';
            chatMetadata['senderUsername'] = senderData['username'] ?? '';
            chatMetadata['senderEmail'] = senderData['email'] ?? '';
          }
        } catch (e) {
          print('Error getting sender info: $e');
        }
      }

      // Add participants list to metadata
      chatMetadata['participants'] = participants;

      await _firestore.collection('chats').doc(chatRoomId).set(chatMetadata, SetOptions(merge: true));

    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Get messages stream for current user's chat
  static Stream<List<Message>> getMessagesStream({String? chatWithUserId}) async* {
    if (currentUser == null) {
      print('getMessagesStream: No current user');
      yield [];
      return;
    }

    try {
      String userRole = await getCurrentUserRole();
      print('getMessagesStream: userRole = $userRole, chatWithUserId = $chatWithUserId');

      String chatRoomId;
      if (userRole == 'admin' && chatWithUserId != null) {
        // Admin viewing chat with specific user
        chatRoomId = getChatRoomId(chatWithUserId);
        print('getMessagesStream: Admin viewing chat with user $chatWithUserId, chatRoomId = $chatRoomId');
      } else if (userRole == 'user') {
        // Regular user viewing their chat with admin
        chatRoomId = getChatRoomId(currentUser!.uid);
        print('getMessagesStream: User viewing chat with admin, chatRoomId = $chatRoomId');
      } else {
        print('getMessagesStream: Invalid role/user combination');
        yield [];
        return;
      }

      print('getMessagesStream: Listening to messages in chatRoomId = $chatRoomId');
      
      // First check if the chat room exists
      DocumentSnapshot chatRoomDoc = await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .get();
      
      if (chatRoomDoc.exists) {
        print('getMessagesStream: Chat room exists');
      } else {
        print('getMessagesStream: Chat room does NOT exist!');
      }
      
      yield* _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snapshot) {
        print('getMessagesStream: Received ${snapshot.docs.length} messages for chatRoomId = $chatRoomId');
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
          .snapshots()
          .asyncMap((snapshot) async {
        List<Map<String, dynamic>> chats = [];
        
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          List<dynamic> participants = data['participants'] ?? [];
          print('getAllUserChatsStream: Processing chat ${doc.id}, participants: $participants');
          
          // Find the other participant (non-admin user)
          String? otherUserId;
          for (String participantId in participants.cast<String>()) {
            if (participantId != currentUser!.uid) {
              otherUserId = participantId;
              break;
            }
          }
          print('getAllUserChatsStream: Found otherUserId = $otherUserId');

          if (otherUserId != null) {
            // Try to get user info from chat metadata first, then from users collection
            String userName = 'Unknown User';
            String userSurname = '';
            String userEmail = '';
            String username = '';

            // Check if user info is already stored in chat metadata
            if (data['senderUserId'] == otherUserId) {
              userName = data['senderName'] ?? 'Unknown User';
              userSurname = data['senderSurname'] ?? '';
              username = data['senderUsername'] ?? '';
              userEmail = data['senderEmail'] ?? '';
            } else if (data['recipientUserId'] == otherUserId) {
              userName = data['recipientName'] ?? 'Unknown User';
              userSurname = data['recipientSurname'] ?? '';
              username = data['recipientUsername'] ?? '';
              userEmail = data['recipientEmail'] ?? '';
            }

            // If no stored info, fetch from users collection
            if (userName == 'Unknown User') {
              try {
                DocumentSnapshot userDoc = await _firestore
                    .collection('users')
                    .doc(otherUserId)
                    .get();
                
                if (userDoc.exists) {
                  Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
                  userName = userData['name'] ?? 'Unknown User';
                  userSurname = userData['nachname'] ?? '';
                  username = userData['username'] ?? '';
                  userEmail = userData['email'] ?? '';
                }
              } catch (e) {
                print('Error getting user info for $otherUserId: $e');
              }
            }

            // Create display name with surname if available
            String displayName = userName;
            if (userSurname.isNotEmpty) {
              displayName = '$userName $userSurname';
            }

            chats.add({
              'chatRoomId': doc.id,
              'otherUserId': otherUserId,
              'otherUserName': displayName,
              'otherUserFirstName': userName,
              'otherUserSurname': userSurname,
              'otherUserUsername': username,
              'otherUserEmail': userEmail,
              'participants': participants,
              'lastMessage': data['lastMessage'] ?? '',
              'lastMessageTime': data['lastMessageTime'] ?? Timestamp.now(),
              'lastMessageSender': data['lastMessageSender'] ?? '',
              'lastMessageSenderName': data['lastMessageSenderName'] ?? '',
            });
          }
        }
        
        // Sort chats by lastMessageTime in Dart instead of Firestore
        chats.sort((a, b) {
          Timestamp timeA = a['lastMessageTime'] ?? Timestamp.now();
          Timestamp timeB = b['lastMessageTime'] ?? Timestamp.now();
          return timeB.compareTo(timeA); // Descending order (newest first)
        });
        
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
      String userRole = await getCurrentUserRole();

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
        String firstName = userData['name'] ?? 'Unknown';
        String surname = userData['nachname'] ?? '';
        String displayName = firstName;
        if (surname.isNotEmpty) {
          displayName = '$firstName $surname';
        }
        
        return {
          'id': userId,
          'name': firstName,
          'surname': surname,
          'displayName': displayName,
          'username': userData['username'] ?? '',
          'email': userData['email'] ?? '',
          'role': userData['roll'] ?? 'user', // Using 'roll' from Firestore
          'phone': userData['phone'] ?? '',
          'city': userData['city'] ?? '',
          'street': userData['street'] ?? '',
          'zip': userData['zip'] ?? '',
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

  /// Delete entire conversation between admin and user (admin only)
  static Future<bool> deleteConversation(String userId) async {
    try {
      // Only admins can delete conversations
      if (!await isCurrentUserAdmin()) {
        print('Error: Only admins can delete conversations');
        return false;
      }

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('Error: No authenticated user');
        return false;
      }

      // Create a batch to delete all messages in the conversation
      WriteBatch batch = _firestore.batch();

      // Get all messages between admin and this user
      QuerySnapshot messagesQuery = await _firestore
          .collection('messages')
          .where('participants', arrayContains: currentUser.uid)
          .get();

      int deletedCount = 0;
      
      for (QueryDocumentSnapshot doc in messagesQuery.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> participants = data['participants'] ?? [];
        
        // Check if this message is part of the conversation with the specified user
        if (participants.contains(userId)) {
          batch.delete(doc.reference);
          deletedCount++;
        }
      }

      // Commit the batch deletion
      await batch.commit();
      
      print('Successfully deleted $deletedCount messages from conversation with user $userId');
      return true;
    } catch (e) {
      print('Error deleting conversation: $e');
      return false;
    }
  }
}
