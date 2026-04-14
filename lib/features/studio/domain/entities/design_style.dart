class DesignStyle {
  final String id;
  final String name;
  final String imagePath;

  DesignStyle({required this.id, required this.name, required this.imagePath});

  factory DesignStyle.fromJson(Map<String, dynamic> json) {
    return DesignStyle(
      id: json['id'].toString(),
      name: json['name'].toString(),
      imagePath: json['thumbnail_url']?.toString() ?? '',
    );
  }

  String get imageUrl {
    if (imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    // Styles are currently hosted directly under the images directory
    return 'https://homiq.acrocoder.com/$imagePath';
  }
}
