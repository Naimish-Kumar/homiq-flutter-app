class LayoutModel {
  final int id;
  final String name;
  final String floorPlanUrl;
  final String? result3dUrl;
  final String status;
  final DateTime createdAt;

  LayoutModel({
    required this.id,
    required this.name,
    required this.floorPlanUrl,
    this.result3dUrl,
    required this.status,
    required this.createdAt,
  });

  factory LayoutModel.fromJson(Map<String, dynamic> json) {
    return LayoutModel(
      id: json['id'],
      name: json['name'],
      floorPlanUrl: json['floor_plan_url'],
      result3dUrl: json['result_3d_url'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isProcessing => status == 'processing';
  bool get isFailed => status == 'failed';
}
