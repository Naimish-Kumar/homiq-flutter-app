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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: CustomText(
          'AI ASSISTANT',
          fontWeight: FontWeight.w900,
          color: context.color.textColorDark,
          fontSize: 14,
          letterSpacing: 4,
        ),
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
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75),
              decoration: BoxDecoration(
                color: isUser
                    ? context.color.tertiaryColor
                    : context.color.brightness == Brightness.light
                        ? Colors.black.withValues(alpha: 0.05)
                        : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: Radius.circular(isUser ? 24 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUser
                        ? context.color.tertiaryColor.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CustomText(
                msg['text'] as String,
                color: isUser
                    ? Colors.white
                    : context.color.textColorDark.withValues(alpha: 0.9),
                fontSize: 14,
             
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: CustomText(
                (msg['time'] as String).toUpperCase(),
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: context.color.textLightColor.withValues(alpha: 0.4),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Suggestions List
          SizedBox(
            height: 40,
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
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: context.color.brightness == Brightness.light
                          ? Colors.black.withValues(alpha: 0.04)
                          : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: context.color.borderColor.withValues(alpha: 0.5),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: CustomText(
                      _suggestions[index],
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: context.color.textColorDark,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // Input Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: context.color.brightness == Brightness.light
                        ? Colors.black.withValues(alpha: 0.04)
                        : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: context.color.borderColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: TextField(
                    controller: _msgController,
                    style: TextStyle(
                        color: context.color.textColorDark, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Describe your vision...',
                      hintStyle: TextStyle(
                        color:
                            context.color.textLightColor.withValues(alpha: 0.4),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: context.color.tertiaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            context.color.tertiaryColor.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.send_rounded,
                        color: Colors.white, size: 24),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
