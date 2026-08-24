class Certificate {
  final String id;
  final String userId;
  final String userName;
  final String courseId;
  final String courseTitle;
  final DateTime issueDate;
  final String certificateCode;
  final String verificationUrl;

  const Certificate({
    required this.id,
    required this.userId,
    required this.userName,
    required this.courseId,
    required this.courseTitle,
    required this.issueDate,
    required this.certificateCode,
    this.verificationUrl = 'https://techaapurinjikoo.dev/verify',
  });

  String get formattedDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[issueDate.month - 1]} ${issueDate.year}';
  }

  String get shareMessage => '🎓 I successfully mastered $courseTitle with Techaa Purinjikoo! Verify: $verificationUrl/$certificateCode';
}
