

class Event {
  final String id;
  final String title;
  final String sbtitle;
  final String address;
  final SpecialGuest specialGuest;
  final Tags tags;
  final String description;
  String slug;

  Event({
    required this.id,
    required this.title,
    required this.sbtitle,
    required this.address,
    required this.specialGuest,
    required this.tags,
    required this.description,
    required this.slug,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'],
      title: json['title'],
      sbtitle: json['sbtitle'],
      address: json['address'],
      specialGuest: SpecialGuest.fromJson(json['special_guest']),
      tags: Tags.fromJson(json['tags']),
      description: json['description'],
      slug: json.containsKey('slug') ? json['slug'] : 'none',
    );
  }
}

class SpecialGuest {
  final String name;

  SpecialGuest({required this.name});

  factory SpecialGuest.fromJson(Map<String, dynamic> json) {
    return SpecialGuest(
      name: json['name'],
    );
  }
}

class Tags {
  final String name;

  Tags({required this.name});

  factory Tags.fromJson(Map<String, dynamic> json) {
    return Tags(
      name: json['name'],
    );
  }
}

