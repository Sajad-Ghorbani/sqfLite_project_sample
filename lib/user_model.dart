class User {
  int? id;
  String? name;
  int? age;

  User({this.id, this.name, this.age});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    age = json['age'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    data['age'] = age;
    return data;
  }
}
