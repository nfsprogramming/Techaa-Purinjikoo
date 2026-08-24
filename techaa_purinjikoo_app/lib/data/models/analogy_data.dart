class AnalogyVisualNode {
  final String icon;
  final String label;

  const AnalogyVisualNode({required this.icon, required this.label});

  factory AnalogyVisualNode.fromJson(Map<String, dynamic> json) {
    return AnalogyVisualNode(
      icon: json['icon'] ?? '💡',
      label: json['label'] ?? '',
    );
  }
}

class AnalogyData {
  final String title;
  final String description;
  final List<AnalogyVisualNode> visualNodes;
  final String userRole;
  final String userLabel;
  final String connectorRole;
  final String connectorLabel;
  final String targetRole;
  final String targetLabel;
  final String takeaway;

  const AnalogyData({
    this.title = 'Real-world Analogy',
    this.description = '',
    this.visualNodes = const [],
    this.userRole = 'Client / User',
    this.userLabel = 'Request',
    this.connectorRole = 'Bridge / API',
    this.connectorLabel = 'Process',
    this.targetRole = 'Server / Target',
    this.targetLabel = 'Response',
    this.takeaway = '',
  });

  factory AnalogyData.fromJson(Map<String, dynamic> json) {
    final visualList = (json['visual'] as List<dynamic>?)
            ?.map((v) => AnalogyVisualNode.fromJson(v as Map<String, dynamic>))
            .toList() ??
        const [];

    final desc = json['description'] ?? '';
    final node1 = visualList.isNotEmpty ? visualList[0] : const AnalogyVisualNode(icon: '💻', label: 'User');
    final node2 = visualList.length > 1 ? visualList[1] : const AnalogyVisualNode(icon: '⚡', label: 'Connector');
    final node3 = visualList.length > 2 ? visualList[2] : const AnalogyVisualNode(icon: '🌍', label: 'Server');

    return AnalogyData(
      title: json['title'] ?? 'Real-world Analogy',
      description: desc,
      visualNodes: visualList,
      userRole: node1.icon,
      userLabel: node1.label,
      connectorRole: node2.icon,
      connectorLabel: node2.label,
      targetRole: node3.icon,
      targetLabel: node3.label,
      takeaway: json['takeaway'] ?? desc,
    );
  }
}
