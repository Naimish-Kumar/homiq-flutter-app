import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:homiq/exports/main_export.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _msgController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text': 'Hello! I am your Homiq AI design assistant. How can I help you transform your space today?',
      'time': 'Just now',
    },
  ];

  final List<String> _suggestions = [
    'What colors match a teal sofa?',
    'Small bedroom layout ideas',
    'Modern vs Scandinavian',
    'Low budget kitchen refresh',
  ];

  void _sendMessage() {
    if (_msgController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'isUser': true,
        'text': _msgController.text,
        'time': 'Now',
      });
      _msgController.clear();
    });

    // Mock AI Response
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({
          'isUser': false,
          'text': 'That is an excellent question! I would recommend focusing on neutral tones with warm accents to create a balanced look. Let me know if you want to see some style inspirations!',
          'time': 'Just now',
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: CustomAppBar(
        title: CustomText('DESIGN ASSISTANT', 
          fontWeight: FontWeight.w900, 
          letterSpacing: 2,
          fontSize: 14,
          color: context.color.textColorDark,
        ),
        showBackButton: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              reverse: true,
              physics: const BouncingScrollPhysics(),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages.reversed.toList()[index];
                return _buildChatBubble(msg);
              },
            ),
          ),
          _buildBottomInput(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> msg) {
    final isUser = msg['isUser'] as bool;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
              decoration: BoxDecoration(
                gradient: isUser 
                  ? LinearGradient(
                      colors: [context.color.tertiaryColor, context.color.tertiaryColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
                color: isUser ? null : context.color.secondaryColor.withOpacity(0.5),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: Radius.circular(isUser ? 24 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 24),
                ),
                border: isUser ? null : Border.all(color: Colors.white.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CustomText(
                msg['text'] as String,
                color: Colors.white.withOpacity(0.95),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            CustomText(
              msg['time'] as String,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: context.color.textLightColor.withOpacity(0.5),
              letterSpacing: 0.5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInput() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 20),
          decoration: BoxDecoration(
            color: context.color.secondaryColor.withOpacity(0.8),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Suggestions List
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() => _msgController.text = _suggestions[index]);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: context.color.tertiaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: context.color.tertiaryColor.withOpacity(0.2)),
                        ),
                        alignment: Alignment.center,
                        child: CustomText(
                          _suggestions[index],
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.color.tertiaryColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Input Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: TextField(
                        controller: _msgController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Describe your vision...',
                          hintStyle: TextStyle(color: context.color.textLightColor.withOpacity(0.5)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: context.color.tertiaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: context.color.tertiaryColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
