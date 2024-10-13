class ModelCategoryHome {
  bool? status;
  dynamic message;
  List<Data>? data;

  ModelCategoryHome({this.status, this.message, this.data});

  ModelCategoryHome.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
 dynamic id;
  dynamic name;
  dynamic arabName;
  dynamic status;
  dynamic description;
  dynamic profileImage;
  dynamic bannerProfile;

  Data(
      {this.id,
        this.name,
        this.arabName,
        this.status,
        this.description,
        this.profileImage,
        this.bannerProfile});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    arabName = json['arab_name'];
    status = json['status'];
    description = json['description'];
    profileImage = json['profile_image'];
    bannerProfile = json['banner_profile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['arab_name'] = this.arabName;
    data['status'] = this.status;
    data['description'] = this.description;
    data['profile_image'] = this.profileImage;
    data['banner_profile'] = this.bannerProfile;
    return data;
  }
}
