import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:wasel/data/datasources/ai_remote_source.dart';
import 'package:wasel/core/theme.dart';


class WaselChatPage extends StatefulWidget {
  final String? eventId;
  final String? eventName;

  const WaselChatPage({super.key, this.eventId, this.eventName});

  @override
  State<WaselChatPage> createState() => _WaselChatPageState();
}

class _WaselChatPageState extends State<WaselChatPage> {
  final AiRemoteSource _aiSource = AiRemoteSource();
  
  // 1. Define the Users using your AppColors
  final ChatUser _currentUser = ChatUser(
    id: '1',
    firstName: 'User',
  );

  final ChatUser _waselBot = ChatUser(
    id: '2',
    firstName: 'Wasel Guide',
  );

  final List<ChatMessage> _messages = <ChatMessage>[];

  @override
  void initState() {
    super.initState();
    // Initializing with a themed welcome message
    _messages.add(
      ChatMessage(
        text: widget.eventName != null 
          ? "Welcome to ${widget.eventName}! I'm your Wasel guide. Ask me anything about this place."
          : "Welcome to Wasel! How can I help you explore Riyadh's culture today?",
        user: _waselBot,
        createdAt: DateTime.now(),
      ),
    );
  }

  void _onSend(ChatMessage message) {
    setState(() => _messages.insert(0, message));

    ChatMessage botResponse = ChatMessage(
      text: "",
      user: _waselBot,
      createdAt: DateTime.now(),
    );
    setState(() => _messages.insert(0, botResponse));

    String fullText = "";
    _aiSource.getChatStream(message.text, eventId: widget.eventId).listen(
      (chunk) {
        fullText += chunk;
        setState(() {
          _messages[0] = ChatMessage(
            text: fullText,
            user: _waselBot,
            createdAt: botResponse.createdAt,
          );
        });
      },
      onError: (error) {
        setState(() => _messages[0].text = "Connection lost. Please try again.");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Using your scaffold background
      appBar: AppBar(
        title: Text(
          widget.eventName ?? "Wasel Guide",
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 20), // Using your section title style
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primary,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: DashChat(
        currentUser: _currentUser,
        onSend: _onSend,
        messages: _messages,
        // --- CUSTOM THEMED INPUT BOX ---
        inputOptions: InputOptions(
          sendOnEnter: true,
          inputTextStyle: const TextStyle(color: AppColors.textMain, fontFamily: 'Poppins'),
          inputDecoration: InputDecoration(
            hintText: "Ask about Riyadh...",
            hintStyle: const TextStyle(color: AppColors.textHint),
            fillColor: AppColors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        // --- CUSTOM THEMED MESSAGE BUBBLES ---
        messageOptions: MessageOptions(
          showOtherUsersAvatar: false,
          showTime: true,
          // Bot Bubble Styling
          containerColor: AppColors.primaryLight, // Using your Light Purple
          textColor: AppColors.textMain,
          // User Bubble Styling
          currentUserContainerColor: AppColors.primary, // Using your Deep Purple
          currentUserTextColor: AppColors.white,
          borderRadius: 18.0,
          messageTextBuilder: (message, previousMessage, nextMessage) {
             return Text(
               message.text,
               style: const TextStyle(
                 fontFamily: 'Poppins', 
                 fontSize: 15,
                 height: 1.4,
               ),
             );
          },
        ),
      ),
    );
  }
}