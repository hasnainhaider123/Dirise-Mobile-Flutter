class PerDaySlotModel {
  bool? status;
  String? message;
  List<DataList>? dataList;

  PerDaySlotModel({this.status, this.message, this.dataList});

  PerDaySlotModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      dataList = <DataList>[];
      json['data'].forEach((v) {
        dataList!.add(new DataList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.dataList != null) {
      data['data'] = this.dataList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DataList {
  dynamic    id;
  dynamic   productId;
  dynamic   weekDay;
  dynamic  productAvailabilityId;
  dynamic  vendorId;
  dynamic timeSloat;
  dynamic timeSloatEnd;
  dynamic  isBooked;

  DataList(
      {this.id,
        this.productId,
        this.weekDay,
        this.productAvailabilityId,
        this.vendorId,
        this.timeSloat,
        this.timeSloatEnd,
        this.isBooked});

  DataList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    weekDay = json['week_day'];
    productAvailabilityId = json['product_availability_id'];
    vendorId = json['vendor_id'];
    timeSloat = json['time_sloat'];
    timeSloatEnd = json['time_sloat_end'];
    isBooked = json['is_booked'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['product_id'] = this.productId;
    data['week_day'] = this.weekDay;
    data['product_availability_id'] = this.productAvailabilityId;
    data['vendor_id'] = this.vendorId;
    data['time_sloat'] = this.timeSloat;
    data['time_sloat_end'] = this.timeSloatEnd;
    data['is_booked'] = this.isBooked;
    return data;
  }
}
