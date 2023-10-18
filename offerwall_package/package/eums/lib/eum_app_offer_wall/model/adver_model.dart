class AdverModel {
  int? idx;
  String? category;
  String? title;
  String? suju;
  String? description;
  String? thumbnail;
  String? api;
  String? precaution;
  String? type;
  int? price;
  int? reward;
  String? registDate;

  AdverModel(
      {this.idx,
      this.category,
      this.title,
      this.suju,
      this.description,
      this.thumbnail,
      this.api,
      this.precaution,
      this.type,
      this.price,
      this.reward,
      this.registDate});

  AdverModel.fromJson(Map<String, dynamic> json) {
    idx = json['idx'];
    category = json['category'];
    title = json['title'];
    suju = json['suju'];
    description = json['description'];
    thumbnail = json['thumbnail'];
    api = json['api'];
    precaution = json['precaution'];
    type = json['type'];
    price = json['price'];
    reward = json['reward'];
    registDate = json['regist_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['idx'] = idx;
    data['category'] = category;
    data['title'] = title;
    data['suju'] = suju;
    data['description'] = description;
    data['thumbnail'] = thumbnail;
    data['api'] = api;
    data['precaution'] = precaution;
    data['type'] = type;
    data['price'] = price;
    data['reward'] = reward;
    data['regist_date'] = registDate;
    return data;
  }
}
