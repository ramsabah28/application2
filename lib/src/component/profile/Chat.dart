import 'package:flutter/material.dart';
import '../../services/ChatService.dart';
import 'ChatList.dart';

class Chat extends StatefulWidget {
  final String? chatWithUserId; // For admin to chat with specific user
  
  const Chat({
    Key? key,
    this.chatWithUserId,
  }) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _error;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    print('Chat widget initialized with chatWithUserId: ${widget.chatWithUserId}');
    _checkUserRole();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ChatService.markMessagesAsRead(chatWithUserId: widget.chatWithUserId);
    });
  }

  Future<void> _checkUserRole() async {
    try {
      bool isAdmin = await ChatService.isCurrentUserAdmin();
      print('User role check: isAdmin = $isAdmin'); // Debug print
      setState(() {
        _isAdmin = isAdmin;
      });
    } catch (e) {
      print('Error checking user role: $e');
      setState(() {
        _isAdmin = false; // Default to non-admin on error
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ChatService.sendMessage(
        content: _messageController.text,
        recipientUserId: widget.chatWithUserId,
      );
      
      _messageController.clear();
      
      // Scroll to bottom after sending message
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom();
      });
      
    } catch (e) {
      String errorMessage = 'Failed to send message';
      String errorString = e.toString().toLowerCase();
      
      if (errorString.contains('user role')) {
        errorMessage = 'Unable to verify user permissions. Please try again.';
      } else if (errorString.contains('network')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (errorString.contains('permission')) {
        errorMessage = 'You don\'t have permission to send messages.';
      } else if (errorString.contains('authentication')) {
        errorMessage = 'Please log in to send messages.';
      }
      
      setState(() {
        _error = errorMessage;
      });
      
      // Clear error after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _error = null;
          });
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildMessageBubble(Message message) {
    final bool isCurrentUser = message.senderId == ChatService.currentUser?.uid;
    final bool isFromAdmin = message.isFromAdmin;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isCurrentUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: isFromAdmin ? Colors.red[100] : Colors.blue[100],
              child: Icon(
                isFromAdmin ? Icons.admin_panel_settings : Icons.person,
                size: 16,
                color: isFromAdmin ? Colors.red[700] : Colors.blue[700],
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isCurrentUser 
                    ? Colors.blue[600] 
                    : (isFromAdmin ? Colors.red[50] : Colors.grey[200]),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isCurrentUser ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: isCurrentUser ? const Radius.circular(4) : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isCurrentUser 
                    ? CrossAxisAlignment.end 
                    : CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        isFromAdmin ? 'Admin' : message.senderName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isFromAdmin ? Colors.red[700] : Colors.grey[600],
                        ),
                      ),
                    ),
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                    textAlign: isCurrentUser ? TextAlign.right : TextAlign.left,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: isCurrentUser 
                          ? Colors.white70 
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[100],
              child: Icon(
                Icons.person,
                size: 16,
                color: Colors.blue[700],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inDays > 0) {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 6,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: _isAdmin 
                    ? 'Type your response...' 
                    : 'Type your message to admin...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              enabled: !_isLoading,
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _isLoading ? null : _sendMessage,
            mini: true,
            backgroundColor: Colors.blue[600],
            child: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  List<Widget>? _buildAppBarActions() {
    print('Building AppBar actions, _isAdmin: $_isAdmin'); // Debug print
    
    // Only show ChatList button for admin users
    if (!_isAdmin) {
      print('User is not admin, hiding ChatList button');
      return null; // No actions for regular users
    }

    print('User is admin, showing ChatList button');
    return [
      IconButton(
        icon: Icon(
          Icons.list,
          color: Colors.blue[700],
        ),
        tooltip: 'View All User Chats',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatList(),
            ),
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, //TODO: use the chat_bg.png in the assets directory as background insted of the white color
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: _isAdmin 
                  ? Colors.blue[100] 
                  : Colors.red[100],
              child: Icon(
                _isAdmin 
                    ? Icons.person 
                    : Icons.admin_panel_settings,
                color: _isAdmin 
                    ? Colors.blue[700] 
                    : Colors.red[700],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isAdmin 
                        ? 'Chat with User' 
                        : 'Chat with Admin',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black),
        actions: _buildAppBarActions(),
      ),
      body: Column(
        children: [
          if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.red[100],
              child: Text(
                _error!,
                style: TextStyle(color: Colors.red[700]),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: ChatService.getMessagesStream(
                chatWithUserId: widget.chatWithUserId,
              ),
              builder: (context, snapshot) {
                print('StreamBuilder: connectionState = ${snapshot.connectionState}, hasError = ${snapshot.hasError}, data length = ${snapshot.data?.length ?? 'null'}');
                
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading messages',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isAdmin 
                              ? 'No messages yet' 
                              : 'Start a conversation with admin',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isAdmin 
                              ? 'Wait for the user to send a message' 
                              : 'Send a message to get support',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Auto-scroll to bottom when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(messages[index]);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }
}
