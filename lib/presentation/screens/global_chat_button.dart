import 'package:flutter/material.dart';
import 'chat_screen.dart'; 

/// A global manager class that controls the visibility of the floating chat button.
/// It uses Flutter's [Overlay] system, which allows widgets to float "above" 
/// all other screens and navigation routes in the app.
class GlobalChatButton {
  // Stores the active overlay so we can remove it later
  static OverlayEntry? _overlayEntry;
  // Prevents us from accidentally drawing multiple buttons on top of each other
  static bool _isVisible = false;

  /// Injects the floating button onto the screen.
  /// Usually called once when the app finishes booting (e.g., on the Home Screen).
  static void show(BuildContext context) {
    if (_isVisible) return;
    _isVisible = true;

    // Create the overlay entry containing our draggable widget
    _overlayEntry = OverlayEntry(
      builder: (context) => _DraggableChatWidget(
        onClose: () => hide(), // Passes the hide function to the 'X' button
      ),
    );

    // Insert it into the app's topmost visual layer
    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Removes the button from the screen and cleans up the memory.
  static void hide() {
    if (!_isVisible) return;
    _isVisible = false;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

// ============================================================================
// THE DRAGGABLE UI WIDGET
// ============================================================================

/// The actual visual button that the user sees and drags.
/// It is Stateful because it needs to constantly update its X and Y coordinates.
class _DraggableChatWidget extends StatefulWidget {
  final VoidCallback onClose;
  const _DraggableChatWidget({required this.onClose});

  @override
  State<_DraggableChatWidget> createState() => _DraggableChatWidgetState();
}

class _DraggableChatWidgetState extends State<_DraggableChatWidget> {
  // Tracks the exact X (dx) and Y (dy) coordinates of the button on the screen
  Offset position = const Offset(0, 0);
  bool isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // We calculate the starting position here because MediaQuery requires context.
    // We only want to set this once, putting the button in the bottom right corner.
    if (!isInitialized) {
      final size = MediaQuery.of(context).size;
      position = Offset(size.width - 80, size.height - 150);
      isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // We need the screen size to prevent the user from dragging the button off-screen
    final size = MediaQuery.of(context).size;

    return Positioned(
      left: position.dx,
      top: position.dy,
      // Material widget is strictly required inside an Overlay so that touch ripples
      // and tap gestures register correctly.
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          // Triggered every frame while the user is dragging their finger
          onPanUpdate: (details) {
            setState(() {
              // Add the finger's movement delta to our current position
              position += details.delta;
              
              // .clamp() acts as a mathematical boundary wall.
              // It forces the X/Y coordinates to stay within the screen's width and height.
              position = Offset(
                position.dx.clamp(0.0, size.width - 70), // 70 ensures the right edge doesn't clip
                position.dy.clamp(0.0, size.height - 100), // 100 protects against the bottom nav bar
              );
            });
          },
          child: Stack(
            clipBehavior: Clip.none, // Allows the 'X' button to hang outside the main circle
            children: [
              
              // 1. The Main Chat Button
              FloatingActionButton(
                heroTag: "global_chat_fab",
                backgroundColor: Theme.of(context).primaryColor, 
                elevation: 6,
                onPressed: () async {
                  // A UX optimization: Hide the floating button while the user is 
                  // actively inside the Chat Screen so it doesn't block the messages.
                  GlobalChatButton.hide();
                  
                  // Open the chat screen and wait for the user to pop (close) it
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChatScreen()),
                  );
                  
                  // The user left the chat screen! Bring the floating button back.
                  if (context.mounted) {
                    GlobalChatButton.show(context);
                  }
                },
                child: const Icon(Icons.support_agent, color: Colors.white, size: 28),
              ),
              
              // 2. The Close ('X') Button
              Positioned(
                right: -4,
                top: -4,
                child: GestureDetector(
                  onTap: widget.onClose, // Triggers GlobalChatButton.hide()
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                      ]
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.close, size: 12, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}