
enum MessageType { success, error, info, warning }
enum PersonalizedVisitType { home, office, other, firstTime }

class ArticleModel {
  final int? id;
  final String? title;
  final String? image;
  final String? description;
  final String? date;
  ArticleModel({this.id, this.title, this.image, this.description, this.date});
  factory ArticleModel.fromJson(Map<String, dynamic> json) => ArticleModel.fromMap(json);
  factory ArticleModel.fromMap(Map<String, dynamic> map) => ArticleModel(id: int.tryParse(map['id']?.toString() ?? ''));
  Map<String, dynamic> toMap() => {'id': id};
}

class FaqsModel {
  final int? id;
  final String? question;
  final String? answer;
  FaqsModel({this.id, this.question, this.answer});
  factory FaqsModel.fromJson(Map<String, dynamic> json) => FaqsModel.fromMap(json);
  factory FaqsModel.fromMap(Map<String, dynamic> map) => FaqsModel(id: int.tryParse(map['id']?.toString() ?? ''));
}

class NotificationData {
  final int? id;
  final String? title;
  final String? message;
  final String? type;
  final String? createdAt;
  final String? image;
  NotificationData({this.id, this.title, this.message, this.type, this.createdAt, this.image});
  factory NotificationData.fromJson(Map<String, dynamic> json) => NotificationData.fromMap(json);
  factory NotificationData.fromMap(Map<String, dynamic> map) {
    return NotificationData(
      id: map['id'] as int?,
      title: map['title']?.toString(),
      message: map['message']?.toString(),
      image: map['image']?.toString(),
      createdAt: map['created_at']?.toString(),
    );
  }
}

class PropertyModel {
  final int? id;
  final String? title;
  final String? price;
  final String? image;
  final Map<String, dynamic>? allPropData;
  final bool? promoted;
  final String? addedBy;
  final String? propertyType;
  final String? slugId;
  final String? titleImage;
  final dynamic category;
  final bool? isFavourite;
  final dynamic requestStatus;
  final dynamic rejectReason;
  final String? translatedTitle;
  final String? city;
  final String? rentduration;
  
  PropertyModel({
    this.id, this.title, this.price, this.image,
    this.allPropData, this.promoted, this.addedBy, this.propertyType,
    this.slugId, this.titleImage, this.category, this.isFavourite,
    this.requestStatus, this.rejectReason, this.translatedTitle,
    this.city, this.rentduration,
  });
  factory PropertyModel.fromJson(Map<String, dynamic> json) => PropertyModel.fromMap(json);
  factory PropertyModel.fromMap(Map<String, dynamic> map) => PropertyModel(id: int.tryParse(map['id']?.toString() ?? ''));
  Map<String, dynamic> toMap() => {'id': id};
}

class Company {
  final String? name;
  final String? companyTel1;
  final String? companyTel2;
  final String? companyEmail;
  Company({this.name, this.companyTel1, this.companyTel2, this.companyEmail});
  factory Company.fromJson(Map<String, dynamic> json) => Company(name: json['name']?.toString());
}

class StatusButton {
  final String lable;
  final dynamic color;
  final dynamic textColor;
  StatusButton({required this.lable, this.color, this.textColor});
}

class AdvertisementProperty {
  final int? id;
  final String? image;
  AdvertisementProperty({this.id, this.image});
  factory AdvertisementProperty.fromJson(Map<String, dynamic> json) => AdvertisementProperty(id: json['id']);
}

class ProjectModel {
  final int? id;
  final String? title;
  final String? image;
  final bool? promoted;
  final dynamic addedBy;
  final String? type;

  ProjectModel({this.id, this.title, this.image, this.promoted, this.addedBy, this.type});
  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(id: json['id']);
}
