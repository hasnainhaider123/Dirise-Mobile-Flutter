// ignore_for_file: public_member_api_docs, sort_constructors_first
class ModelCommonResponse {
  dynamic status;
  dynamic message;
  dynamic addressId;
  dynamic otp;
  dynamic uRL;

  ModelCommonResponse({this.status, this.message, this.otp,this.uRL});

  ModelCommonResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    addressId = json['address_id'];
    otp = json['otp'];
    uRL = json['URL'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['address_id'] = addressId;
    data['otp'] = otp;
    data['URL'] = uRL;
    return data;
  }

  @override
  String toString() {
    return 'ModelCommonResponse(status: $status, message: $message, addressId: $addressId, otp: $otp, uRL: $uRL)';
  }
}
