class ShippingModel {
  dynamic status;
  dynamic message;
  ProductShipping? productShipping;

  ShippingModel({this.status, this.message, this.productShipping});

  ShippingModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    productShipping = json['product_shipping'] != null
        ? new ProductShipping.fromJson(json['product_shipping'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.productShipping != null) {
      data['product_shipping'] = this.productShipping!.toJson();
    }
    return data;
  }
}

class ProductShipping {
  dynamic shippingDate;
  dynamic lowestDeliveryPrice;

  ProductShipping({this.shippingDate, this.lowestDeliveryPrice});

  ProductShipping.fromJson(Map<String, dynamic> json) {
    shippingDate = json['shipping_date'];
    lowestDeliveryPrice = json['lowestDeliveryPrice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['shipping_date'] = this.shippingDate;
    data['lowestDeliveryPrice'] = this.lowestDeliveryPrice;
    return data;
  }
}
