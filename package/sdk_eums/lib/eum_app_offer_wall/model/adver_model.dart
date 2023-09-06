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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['idx'] = this.idx;
    data['category'] = this.category;
    data['title'] = this.title;
    data['suju'] = this.suju;
    data['description'] = this.description;
    data['thumbnail'] = this.thumbnail;
    data['api'] = this.api;
    data['precaution'] = this.precaution;
    data['type'] = this.type;
    data['price'] = this.price;
    data['reward'] = this.reward;
    data['regist_date'] = this.registDate;
    return data;
  }
}
