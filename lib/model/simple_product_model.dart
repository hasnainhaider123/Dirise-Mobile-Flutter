// ignore_for_file: public_member_api_docs, sort_constructors_first
class SimpleProductModel {
  bool? status;
  dynamic message;
  SimpleProduct? simpleProduct;

  SimpleProductModel({this.status, this.message, this.simpleProduct});

  SimpleProductModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    simpleProduct = json['simple_product'] != null
        ? new SimpleProduct.fromJson(json['simple_product'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = status;
    data['message'] = message;
    if (simpleProduct != null) {
      data['simple_product'] = simpleProduct!.toJson();
    }
    return data;
  }
}

class SimpleProduct {
  dynamic id;
  dynamic vendorId;
  dynamic addressId;
  List<CatId>? catId;
  dynamic pname;
  dynamic productType;
  dynamic itemType;
  dynamic featuredImage;
  dynamic featureImageApp;
  dynamic featureImageWeb;
  List<String>? galleryImage;
  dynamic serialNumber;
  dynamic productNumber;
  dynamic productCode;
  dynamic promotionCode;
  dynamic inStock;
  dynamic pPrice;
  dynamic returnPolicyDesc;
  dynamic shortDescription;
  dynamic longDescription;
  dynamic isComplete;
  dynamic virtualProductFile;
  dynamic views;
  dynamic rating;
  bool? inWishlist;
  bool? alreadyReview;
  Storemeta? storemeta;
  dynamic lowestDeliveryPrice;
  dynamic shippingDate;
  dynamic discountPrice;
  dynamic discountOff;
  dynamic shippingPolicy;
  dynamic packageDetail;

  VendorInformation? vendorInformation;
  SimpleProduct(
      {this.id,
        this.vendorId,
        this.addressId,
        this.catId,
        this.pname,
        this.productType,
        this.itemType,
        this.featuredImage,
        this.featureImageApp,
        this.featureImageWeb,
        this.galleryImage,
        this.serialNumber,
        this.productNumber,
        this.productCode,
        this.promotionCode,
        this.inStock,
        this.pPrice,
        this.returnPolicyDesc,
        this.shortDescription,
        this.longDescription,
        this.isComplete,
        this.virtualProductFile,
        this.views,
        this.rating,
        this.alreadyReview,
        this.inWishlist,
        this.storemeta,
        this.lowestDeliveryPrice,
        this.shippingDate,
        this.discountPrice,
        this.discountOff,
        this.shippingPolicy,
        this.vendorInformation,
        this.packageDetail,
  
      });

  SimpleProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    vendorId = json['vendor_id'];
    addressId = json['address_id'];
    if (json['cat_id'] != null) {
      catId = <CatId>[];
      json['cat_id'].forEach((v) {
        catId!.add(new CatId.fromJson(v));
      });
    }
    pname = json['pname'];
    

    productType = json['product_type'];
    itemType = json['item_type'];
    featuredImage = json['featured_image'];
    featureImageApp = json['feature_image_app'];
    featureImageWeb = json['feature_image_web'];
    galleryImage = json['gallery_image'].cast<String>();
    serialNumber = json['serial_number'];
    productNumber = json['product_number'];
    productCode = json['product_code'];
    inWishlist = json['in_wishlist'];
    promotionCode = json['promotion_code'];
    inStock = json['in_stock'];
    pPrice = json['p_price'];
    returnPolicyDesc = json['return_policy_desc'];
    shortDescription = json['short_description'];
    longDescription = json['long_description'];
    isComplete = json['is_complete'];
    virtualProductFile = json['virtual_product_file'];
    views = json['views'];
    rating = json['rating'];
    alreadyReview = json['already_review'];
    vendorInformation = json['vendor_information'] != null
        ? new VendorInformation.fromJson(json['vendor_information'])
        : null;
    storemeta = json['storemeta'] != null
        ? new Storemeta.fromJson(json['storemeta'])
        : null;
    lowestDeliveryPrice = json['lowestDeliveryPrice'];
    shippingDate = json['shipping_date'];
    discountPrice = json['discount_price'];
    discountOff = json['discount_off'];
    shippingPolicy = json['shipping_policy'];
    packageDetail=json['package_detail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['vendor_id'] = vendorId;
    data['address_id'] = addressId;
    if (catId != null) {
      data['cat_id'] = catId!.map((v) => v.toJson()).toList();
    }
    if (vendorInformation != null) {
      data['vendor_information'] = vendorInformation!.toJson();
    }
    data['pname'] = pname;
    data['product_type'] = productType;
    data['item_type'] = itemType;
    data['featured_image'] = featuredImage;
    data['feature_image_app'] = featureImageApp;
    data['feature_image_web'] = featureImageWeb;
    data['gallery_image'] = galleryImage;
    data['serial_number'] = serialNumber;
    data['product_number'] = productNumber;
    data['product_code'] = productCode;
    data['promotion_code'] = promotionCode;
    data['in_stock'] = inStock;
    data['in_wishlist'] = inWishlist;
    data['p_price'] = pPrice;
    data['return_policy_desc'] = returnPolicyDesc;
    data['short_description'] = shortDescription;
    data['long_description'] = longDescription;
    data['is_complete'] = isComplete;
    data['virtual_product_file'] = virtualProductFile;
    data['views'] = views;
    data['rating'] = rating;
    data['already_review'] = alreadyReview;
    if (storemeta != null) {
      data['storemeta'] = storemeta!.toJson();
    }
    data['lowestDeliveryPrice'] = lowestDeliveryPrice;
    data['shipping_date'] = shippingDate;
    data['discount_price'] = discountPrice;
    data['discount_off'] = discountOff;
    data['shipping_policy'] = shippingPolicy;
    data['package_detail']=packageDetail;
    return data;
  }

  @override
  String toString() {
    return 'SimpleProduct(id: $id, vendorId: $vendorId, addressId: $addressId, catId: ${catId.toString()}, pname: $pname, productType: $productType, itemType: $itemType, featuredImage: $featuredImage, featureImageApp: $featureImageApp, featureImageWeb: $featureImageWeb, galleryImage: $galleryImage, serialNumber: $serialNumber, productNumber: $productNumber, productCode: $productCode, promotionCode: $promotionCode, inStock: $inStock, pPrice: $pPrice, returnPolicyDesc: $returnPolicyDesc, shortDescription: $shortDescription, longDescription: $longDescription, isComplete: $isComplete, virtualProductFile: $virtualProductFile, views: $views, rating: $rating, inWishlist: $inWishlist, alreadyReview: $alreadyReview, storemeta: $storemeta, lowestDeliveryPrice: $lowestDeliveryPrice, shippingDate: $shippingDate, discountPrice: $discountPrice, discountOff: $discountOff, shippingPolicy: $shippingPolicy ,packageDetail $packageDetail';
  }
}
class VendorInformation {
  dynamic storeId;
  dynamic storeName;
  dynamic storeEmail;
  dynamic storePhone;
  dynamic storeLogo;
  dynamic storeImage;
  dynamic storeLogoApp;
  dynamic storeLogoWeb;
  dynamic bannerProfile;
  dynamic bannerProfileApp;
  dynamic bannerProfileWeb;

  VendorInformation(
      {this.storeId,
        this.storeName,
        this.storeEmail,
        this.storePhone,
        this.storeLogo,
        this.storeImage,
        this.storeLogoApp,
        this.storeLogoWeb,
        this.bannerProfile,
        this.bannerProfileApp,
        this.bannerProfileWeb});

  VendorInformation.fromJson(Map<String, dynamic> json) {
    storeId = json['store_id'];
    storeName = json['store_name'];
    storeEmail = json['store_email'];
    storePhone = json['store_phone'];
    storeLogo = json['store_logo'];
    storeImage = json['store_image'];
    storeLogoApp = json['store_logo_app'];
    storeLogoWeb = json['store_logo_web'];
    bannerProfile = json['banner_profile'];
    bannerProfileApp = json['banner_profile_app'];
    bannerProfileWeb = json['banner_profile_web'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['store_id'] = storeId;
    data['store_name'] = storeName;
    data['store_email'] = storeEmail;
    data['store_phone'] = storePhone;
    data['store_logo'] = storeLogo;
    data['store_image'] = storeImage;
    data['store_logo_app'] = storeLogoApp;
    data['store_logo_web'] = storeLogoWeb;
    data['banner_profile'] = bannerProfile;
    data['banner_profile_app'] = bannerProfileApp;
    data['banner_profile_web'] = bannerProfileWeb;
    return data;
  }
}
class CatId {
  dynamic id;
  dynamic title;

  CatId({this.id, this.title});

  CatId.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['title'] = title;
    return data;
  }

  @override
  String toString() => 'CatId(id: $id, title: $title)';
}

class Storemeta {
  dynamic firstName;
  dynamic lastName;
  dynamic storeId;
  dynamic storeName;
  dynamic storeLocation;
  dynamic profileImg;
  dynamic document2;
  dynamic bannerProfile;
  dynamic commercialLicense;
  dynamic storeCategory;
  dynamic verifyBatch;

  Storemeta(
      {this.firstName,
        this.lastName,
        this.storeId,
        this.storeName,
        this.verifyBatch,
        this.document2,
        this.storeLocation,
        this.profileImg,
        this.bannerProfile,
        this.commercialLicense,
        this.storeCategory});

  Storemeta.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    storeId = json['store_id'];
    storeName = json['store_name'];
    document2 = json['document_2'];
    storeLocation = json['store_location'];
    profileImg = json['profile_img'];
    bannerProfile = json['banner_profile'];
    commercialLicense = json['commercial_license'];
    storeCategory = json['store_category'];
    verifyBatch = json['verify_batch'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['store_id'] = storeId;
    data['store_name'] = storeName;
    data['document_2'] = document2;
    data['store_location'] = storeLocation;
    data['profile_img'] = profileImg;
    data['banner_profile'] = bannerProfile;
    data['commercial_license'] = commercialLicense;
    data['store_category'] = storeCategory;
    data['verify_batch'] = verifyBatch;
    return data;
  }
}
