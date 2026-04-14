class Category {
  final String? id;
  final String? name;
  final String? image;

  Category({this.id, this.name, this.image});

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id']?.toString(),
      name: map['category_name']?.toString() ?? map['name']?.toString(),
      image: map['image']?.toString(),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) => Category.fromMap(json);

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'image': image,
      };
}

class Categorys {
  final List<Category>? data;

  Categorys({this.data});

  factory Categorys.fromMap(Map<String, dynamic> map) {
    return Categorys(
      data: (map['data'] as List?)
          ?.map((e) => Category.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'data': data?.map((e) => e.toMap()).toList(),
      };
}
