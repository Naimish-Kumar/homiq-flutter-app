import 'package:homiq/utils/api.dart';

class ChatMessage {
  ChatMessage({
    this.id = '',
    this.senderId = '',
    this.receiverId = '',
    this.propertyId = '',
    this.message = '',
    this.file = '',
    this.chatMessageType = 'text',
    this.date = '',
    this.timeAgo = '',
    this.isSentByMe = false,
    this.isSentNow = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json[Api.id]?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      receiverId: json['receiver_id']?.toString() ?? '',
      propertyId: json['property_id']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      file: json['file']?.toString() ?? '',
      chatMessageType: json['chat_message_type']?.toString() ?? 'text',
      date: json['created_at']?.toString() ?? '',
      timeAgo: json['time_ago']?.toString() ?? '',
    );
  }

  String id;
  String senderId;
  String receiverId;
  String propertyId;
  String? message;
  String? file;
  String chatMessageType;
  String date;
  String timeAgo;
  bool isSentByMe;
  bool isSentNow;

  void setIsSentByMe({required bool value}) {
    isSentByMe = value;
  }
}
