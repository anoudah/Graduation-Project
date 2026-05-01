import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; 
import '../../core/theme.dart';
import '../../data/datasources/ai_remote_source.dart';

/// A data model representing a single message in the chat interface.
class ChatMessage {
  final String text;       // The content of the message
  final bool isUser;       // True if sent by the user, false if sent by Wasel AI
  
  ChatMessage({required this.text, required this.isUser});
}

/// The main chat interface where users interact with the Wasel AI.
/// It supports streaming text, markdown formatting, and dynamic RTL/LTR language support.
class ChatScreen extends StatefulWidget {
  final String? eventId; // Optional: Used if the chat is opened from a specific event page

  const ChatScreen({super.key, this.eventId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // --- UI CONTROLLERS ---
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // --- BACKEND SERVICES ---
  final AiRemoteSource _aiSource = AiRemoteSource();
  
  // --- STATE VARIABLES ---
  late final String _sessionId;     // The unique "Short-Term Memory" ID for this specific chat
  bool _isLoading = false;          // Prevents the user from spamming the send button
  bool _isTyping = false;           // Controls the visibility of the bouncing dot animation
  
  // Initialize the chat with a welcome message
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello! I am your Wasel cultural guide. How can I help you explore Riyadh today?", 
      isUser: false
    )
  ];

  @override
  void initState() {
    super.initState();
    // Generates a unique session ID the moment the screen opens.
    // This tells the backend to treat this as a brand new, empty conversation.
    _sessionId = "session_${DateTime.now().millisecondsSinceEpoch}";
  }

  /// Handles sending the user's message to the FastAPI backend and listening to the streaming response.
  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    _controller.clear();

    setState(() {
      // 1. Instantly display the user's message in the UI
      _messages.insert(0, ChatMessage(text: text, isUser: true));
      
      // 2. Lock the input and show the bouncing "typing..." animation
      _isLoading = true;
      _isTyping = true; 
    });

    try {
      // Used to track the very first word the AI sends back
      bool isFirstChunk = true;
      
      // 3. Open a stream connection to the FastAPI /chat endpoint
      await for (var chunk in _aiSource.getChatStream(
        text, 
        eventId: widget.eventId,
        sessionId: _sessionId,
      )) {
        setState(() {
          // If this is the very first piece of text received from the AI:
          if (isFirstChunk) {
            _isTyping = false; // Hide the bouncing dots
            _messages.insert(0, ChatMessage(text: chunk, isUser: false)); // Create the AI's chat bubble
            isFirstChunk = false;
          } else {
            // For all following text chunks, append them to the existing AI bubble (creates the "typing" effect)
            final currentAiMessage = _messages.first.text;
            _messages[0] = ChatMessage(text: currentAiMessage + chunk, isUser: false);
          }
        });
      }
    } catch (e) {
      // Failsafe in case the backend crashes or the user loses internet
      setState(() {
        _isTyping = false;
        _messages.insert(0, ChatMessage(text: "Sorry, I lost connection to the server.", isUser: false));
      });
    } finally {
      // Unlock the text input box when the AI is completely finished
      setState(() {
        _isLoading = false;
        _isTyping = false; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Ask Wasel AI', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Builds the list from the bottom up, pushing older messages to the top
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              // If the AI is typing, artificially add 1 to the list length to make room for the animation
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                
                // If the AI is currently typing, render the animation bubble at the very bottom (index 0)
                if (_isTyping && index == 0) {
                  return _buildTypingIndicator();
                }
                
                // Shift the normal messages up by 1 to account for the typing indicator
                final message = _messages[_isTyping ? index - 1 : index];
                return _buildChatBubble(message);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  // =========================================================================
  // UI WIDGETS
  // =========================================================================

  /// Builds the bouncing dots animation indicating the AI is processing.
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildBotAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04), // Soft, modern shadow
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            // The actual animation widget from the flutter_spinkit package
            child: const SpinKitThreeBounce(
              color: AppColors.primary,
              size: 20.0,
            ),
          ),
        ],
      ),
    );
  }

  /// Icon representing the Wasel AI
  Widget _buildBotAvatar() {
    return const CircleAvatar(
      radius: 16,
      backgroundColor: AppColors.primary,
      child: Icon(Icons.support_agent, color: Colors.white, size: 20),
    );
  }

  /// Icon representing the user
  Widget _buildUserAvatar() {
    return const CircleAvatar(
      radius: 16,
      backgroundColor: AppColors.textMain, 
      child: Icon(Icons.person, color: Colors.white, size: 20),
    );
  }

  /// Builds a single chat message bubble (both for the User and the AI).
  Widget _buildChatBubble(ChatMessage message) {
    // Regular Expression: Detects if any character in the text is Arabic
    // This is crucial for properly formatting punctuation and English words inside Arabic sentences
    final bool isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(message.text);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        // Aligns user messages to the right, AI messages to the left
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end, // Aligns avatars to the bottom of the bubble
        children: [
          
          // Render bot avatar if it's an AI message
          if (!message.isUser) ...[
            _buildBotAvatar(),
            const SizedBox(width: 8),
          ],
          
          // Flexible widget ensures the bubble wraps tightly around short text, 
          // but doesn't exceed the max width for long paragraphs
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: message.isUser ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  // Creates a "speech tail" pointing to the correct avatar
                  bottomLeft: Radius.circular(message.isUser ? 24 : 0),
                  bottomRight: Radius.circular(message.isUser ? 0 : 24),
                ),
                boxShadow: [
                  if (!message.isUser)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                ],
              ),
              
              // Forces the text to render Right-to-Left if Arabic characters are detected
              child: Directionality(
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                
                // Parses bold text (**bold**) and bullet points returned by the AI
                child: MarkdownBody(
                  data: message.text,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      fontFamily: 'Poppins',
                      color: message.isUser ? Colors.white : AppColors.textMain,
                      fontSize: 15,
                      height: 1.6, 
                    ),
                    strong: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      color: message.isUser ? Colors.white : AppColors.primary, 
                    ),
                    listBullet: TextStyle(
                      color: message.isUser ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Render user avatar if it's a user message
          if (message.isUser) ...[
            const SizedBox(width: 8),
            _buildUserAvatar(),
          ],
        ],
      ),
    );
  }

  /// Builds the text input field and send button at the bottom of the screen.
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: const TextStyle(color: AppColors.textHint, fontFamily: 'Poppins'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              // Disable the send button if the AI is currently thinking
              onPressed: _isLoading ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}