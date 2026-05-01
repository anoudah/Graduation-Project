import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme.dart';
import '../../data/datasources/ai_remote_source.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatScreen extends StatefulWidget {
  final String? eventId;

  const ChatScreen({super.key, this.eventId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiRemoteSource _aiSource = AiRemoteSource();

  // 1. Declare the session ID variable
  late final String _sessionId;
  late String _welcomeMessage;

  final List<ChatMessage> _messages = [];

  bool _isLoading = false;

  // 2. Initialize it the exact moment the chat screen opens
  @override
  void initState() {
    super.initState();
    // This creates a completely unique ID every single time the user opens the chat
    _sessionId = "session_${DateTime.now().millisecondsSinceEpoch}";
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _welcomeMessage = AppLocalizations.of(context).helloWaselGuide;
    if (_messages.isEmpty) {
      _messages.add(ChatMessage(text: _welcomeMessage, isUser: false));
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    _controller.clear();

    setState(() {
      _messages.insert(0, ChatMessage(text: text, isUser: true));
      _messages.insert(0, ChatMessage(text: "", isUser: false));
      _isLoading = true;
    });

    try {
      // 3. Pass the unique sessionId to the backend!
      await for (var chunk in _aiSource.getChatStream(
        text,
        eventId: widget.eventId,
        sessionId: _sessionId, // Added here!
      )) {
        setState(() {
          final currentAiMessage = _messages.first.text;
          _messages[0] = ChatMessage(
            text: currentAiMessage + chunk,
            isUser: false,
          );
        });
      }
    } catch (e) {
      setState(() {
        _messages[0] = ChatMessage(
          text: AppLocalizations.of(context).lostConnection,
          isUser: false,
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: Text(AppLocalizations.of(context).askWaselAI),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildChatBubble(message);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

Widget _buildChatBubble(ChatMessage message) {
    final bool isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(message.text);

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: Radius.circular(message.isUser ? 24 : 0), // Sharp corner on the speaker's side
            bottomRight: Radius.circular(message.isUser ? 0 : 24),
          ),
          boxShadow: [
            if (!message.isUser)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04), // Soft, matte shadow
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
          ],
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        // Directionality fixes the Arabic punctuation alignment we solved earlier!
        child: Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
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
                color: message.isUser ? Colors.white : AppColors.primary, // Makes bot's bold text pop in brand colors
              ),
              listBullet: TextStyle(
                color: message.isUser ? Colors.white : AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: AppColors.white,
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
                hintText: AppLocalizations.of(context).typeYourMessage,
                hintStyle: const TextStyle(color: AppColors.textHint),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: IconButton(
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send, color: AppColors.white),
              onPressed: _isLoading ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
