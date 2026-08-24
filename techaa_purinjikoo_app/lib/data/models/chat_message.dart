enum SenderType { friend, you }

class ChatMessage {
  final String id;
  final SenderType sender;
  final String speakerName;
  final String text;
  final String avatarEmoji;

  const ChatMessage({
    required this.id,
    required this.sender,
    this.speakerName = '',
    required this.text,
    this.avatarEmoji = '👨‍💻',
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, [int index = 0]) {
    final isEven = index % 2 == 0;
    return ChatMessage(
      id: json['id'] ?? 'msg_$index',
      sender: isEven ? SenderType.friend : SenderType.you,
      speakerName: json['speaker'] ?? (isEven ? 'Friend' : 'You'),
      text: json['message'] ?? json['text'] ?? '',
      avatarEmoji: json['avatar'] ?? (isEven ? '🧑‍💻' : '👨‍💻'),
    );
  }
}
