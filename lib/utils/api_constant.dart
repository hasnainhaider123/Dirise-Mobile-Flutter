import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/login_model.dart';
import '../widgets/common_colour.dart';

class ApiUrls {
   static const String baseUrl = 'https://admin.diriseapp.com/api/';
  //static const String baseUrl = 'https://diriseapp.com/api/';
  // static const String baseUrl = 'https://dirise.virtualdemo.tech/api/';
  // static const String baseUrl = 'https://dirise.webdemozone.com/api/';
  // static const String baseUrl = 'https://backend.diriseapp.com/api/';
  // static const String baseUrl = 'https://beta-dirise.eoxyslive.com/api/';
  static const String signInUrl = "${baseUrl}register";
  static const String vendorShippingPolicy = "${baseUrl}vendor-shipping-policy";
  static const String vendorPickUpPolicy = "${baseUrl}vendor-pickup-policy";
  static const String getShippingPolicy = "${baseUrl}shipping-policy";
  static const String sampleCsvFile = "${baseUrl}sample-csv-file";
  static const String getPickUpPolicy = "${baseUrl}pickup-policy";
  static const String newRegisterUrl = "${baseUrl}register";
  static const String socialMediaUrl = "${baseUrl}social-media";
  static const String singleVirtualProductUrl =
      "${baseUrl}single-virtual-product";
  static const String getSocialMediaUrl = "${baseUrl}social-media";
  static const String loginUrl = "${baseUrl}login";
  static const String resendOtpUrl = "${baseUrl}resend-otp";
  static const String vendorVerification = "${baseUrl}vendor-verification";
  static const String verifyOtpEmail = "${baseUrl}verify-otp-email";
  static const String forgotPasswordUrl = "${baseUrl}forget-password";
  static const String changePasswordUrl = "${baseUrl}change-password";
  static const String trendingProductsUrl = "${baseUrl}trending-product";
  static const String homeUrl = "${baseUrl}home";
  static const String categoryUrl = "${baseUrl}category";
  static const String popularProductUrl = "${baseUrl}popular-product";
  static const String authorUrl = "${baseUrl}authers-list";
  static const String addToCartUrl = "${baseUrl}add-cart";
  static const String buyNowDetailsUrl = "${baseUrl}buy-now-checkout-details";
  static const String cartListUrl = "${baseUrl}cart-list";
  static const String deleteCartUrl = "${baseUrl}delete-cart";
  static const String applyCouponUrl = "${baseUrl}apply-coupon";
  static const String updateProfile = "${baseUrl}edit-account";
  static const String userProfile = "${baseUrl}my-account";
  static const String addressListUrl = "${baseUrl}address";
  static const String defaultAddressUrl = "${baseUrl}my-default-address";
  static const String editAddressUrl = "${baseUrl}edit-address";
  static const String giveawayProductAddress = "${baseUrl}add-vendor-product";
  static const String addMultipleProduct = "${baseUrl}add-multiple-product";
  static const String placeOrderUrl = "${baseUrl}add-order";
  static const String myOrdersListUrl = "${baseUrl}orders";
  static const String customerDashboardUrl = "${baseUrl}customer-dashboard";
  static const String orderDetailsUrl = "${baseUrl}order-details";
  static const String addToWishListUrl = "${baseUrl}add-to-wishlist";
  static const String removeFromWishListUrl = "${baseUrl}delete-from-wishlist";
  static const String wishListUrl = "${baseUrl}wishlist";
  static const String storesUrl = "${baseUrl}stores";
  static const String vendorCategoryListUrl = "${baseUrl}vendor-category-list";
  static const String homeCategoryListUrl = "${baseUrl}homepage-category-list";
  static const String jobCategoryListUrl = "${baseUrl}job-category-list";
  static const String jobSubCategoryListUrl =
      "${baseUrl}job-subcategory-list?category_id=";
  static const String productCategory = "${baseUrl}product-category";
  static const String vendorRegistrationUrl = "${baseUrl}vendor-signup";
  static const String verifyVendorOTPEmailUrl = "${baseUrl}verify-otp-email";
  static const String vendorResendOTPUrl = "${baseUrl}vendor-resend-otp";
  static const String deleteAddressUrl = "${baseUrl}delete-address";
  static const String getVendorDetailUrl = "${baseUrl}my-vendor-details";
  static const String productRemark =
      "${baseUrl}product-remark-list?product_id=";
  static const String productAddRemark = "${baseUrl}add-product-remark";
  static const String addVendorProductUrl = "${baseUrl}add-vendor-product";
  static const String productCategoryListUrl =
      "${baseUrl}prodect-category-list";
  static const String taxDataUrl = "${baseUrl}tax";
  static const String myProductsListUrl = "${baseUrl}my-product-list";
  static const String myApproved = "${baseUrl}my-approved-product-list";
  static const String getProductDetailsUrl = "${baseUrl}edit-product/";
  static const String aboutUsUrl = "${baseUrl}page-data";
  static const String deleteUser = "${baseUrl}delete-user";
  static const String contactUsUrl = "${baseUrl}get-in-touch";
  static const String editVendorDetailsUrl = "${baseUrl}edit-vendor-details";
  static const String updateProductStatusUrl =
      "${baseUrl}update-product-status";
  static const String vendorDashBoardUrl = "${baseUrl}vendor-dashboard";
  static const String getCategoryStoresUrl = "${baseUrl}get-vendor-details?";
  static const String shopByProductUrl = "${baseUrl}shop-by-product?";
  static const String vendorProductListUrl = "${baseUrl}vendor-product-list?";
  static const String singleProductUrl = "${baseUrl}product";
  static const String singleGiveAwayUrl = "${baseUrl}single-giveaway-product";
  static const String simpleProductUrl = "${baseUrl}simple-product";
  static const String bookableProductUrl = "${baseUrl}single-bookable-product";
  static const String advertisingUrl = "${baseUrl}single-advertising-product";
  static const String varientsUrl = "${baseUrl}variable-product";
  static const String getEventsUrl = "${baseUrl}get-events";
  static const String addEventUrl = "${baseUrl}event";
  static const String deleteEventUrl = "${baseUrl}delete-event";
  static const String storeTimingUrl = "${baseUrl}store-timing";
  static const String productWeekly =
      "${baseUrl}product-weekly-timing?product_id=";
  static const String storeAvailabilityUrl = "${baseUrl}store-availability";
  static const String productAvailabilityUrl =
      "${baseUrl}product-weekly-availability";
  static const String virtualAssetsPDFUrl = "${baseUrl}my-e-book?type=PDF";
  static const String virtualAssetsVoiceUrl = "${baseUrl}my-e-book?type=voice";
  static const String accountDetailsUrl = "${baseUrl}account-details";
  static const String bankListUrl = "${baseUrl}banks-list";
  static const String addAccountDetailsUrl = "${baseUrl}add-account-details";
  static const String getVendorInfoUrl =
      "${baseUrl}get-vendor-information?user_id=";
  static const String searchProductUrl = "${baseUrl}search-product";
  static const String vendorPlanUrl = "${baseUrl}vendor-plan";
  static const String createPaymentUrl = "${baseUrl}create-payment";
  static const String getAttributeUrl = "${baseUrl}get-attributes";
  static const String quantityUpdateUrl = "${baseUrl}qty-update";
  static const String paymentMethodsUrl = "${baseUrl}payment-methods";
  static const String allCountriesUrl = "${baseUrl}all-countries";
  static const String allStatesUrl = "${baseUrl}all-states";
  static const String allCityUrl = "${baseUrl}all-cities";
  static const String withdrawalListUrl = "${baseUrl}withdrawal-list";
  static const String withdrawalRequestUrl = "${baseUrl}withdraw-request";
  static const String deleteProductUrl = "${baseUrl}delete-product";
  static const String deleteReturnPolicy = "${baseUrl}remove-return-policy";
  static const String deleteShippingPolicy = "${baseUrl}remove-shipping-policy";
  static const String deletePickupPolicy = "${baseUrl}remove-pickup-policy";
  static const String returnPolicyUrl = "${baseUrl}return-policy";
  static const String singleReturnPolicyUrl =
      "${baseUrl}single-return-policy?id=";
  static const String singleShippingPolicyUrl =
      "${baseUrl}single-shipping-policy?id=";
  static const String stateList = "${baseUrl}all-states";
  static const String citiesList = "${baseUrl}all-cities";
  static const String productCategoriesListUrl = "${baseUrl}categries";
  static const String showCaseProductUrl = "${baseUrl}get-showcase-product";
  static const String categoryListUrl =
      "${baseUrl}categories-list?category_id=";
  static const String categoryFilterUrl = "${baseUrl}category-filter";
  static const String faqListUrl = "${baseUrl}faq-list";
  static const String getPublishUrl = "${baseUrl}all-news";
  static const String deleteNewsUrl = "${baseUrl}delete-news";
  static const String getNewsTrendsUrl = "${baseUrl}news-trends";
  static const String createPostUrl = "${baseUrl}create-news";
  static const String addRemoveLike = "${baseUrl}add-remove-like";
  static const String socialLoginUrl = "${baseUrl}social";
  static const String filterByPriceUrl = "${baseUrl}filter-by-price";
  static const String addReviewUrl = "${baseUrl}review";
  static const String getReviewUrl = "${baseUrl}review-list?product_id=";
  static const String getPerDaySlot = "${baseUrl}per-day-slots?product_id=";
  static const String getContactUsUrl = "${baseUrl}contact-us";
  static const String starVendorUrl = "${baseUrl}star-vendors";
  static const String createShipment = "${baseUrl}create-shipment";
  static const String changeOrderStatus = "${baseUrl}change-order-status";
  static const String defaultAddressStatus = "${baseUrl}default-address";
  static const String myDefaultAddressStatus = "${baseUrl}my-default-address";
  static const String vendorEarning = "${baseUrl}vendor-earning";
  static const String vendorEarningNew = "${baseUrl}get-vendor-earnings";
  static const String addCurrentAddress = "${baseUrl}add-current-address";
  static const String insertErrorLog = "${baseUrl}insert-error-log";
  static const String productCreateSlots = "${baseUrl}product-create-slots";
  static const String addProductSponsor = "${baseUrl}add-product-sponsor";
  static const String sponsorList = "${baseUrl}sponsor-list";
  static const String featuredStore = "${baseUrl}get-featured-store";
  static const String getJobList = "${baseUrl}job-product-list";
  static const String getJobHiringList = "${baseUrl}job-hiring-list";
  static const String singleJobList =
      "${baseUrl}single-job-product?product_id=";
  static const String releatedProduct = "${baseUrl}related-product";
  static const String returnRequest = "${baseUrl}add-order-return-request";
  static const String subCategory = "${baseUrl}sub-category";
  static const String searchOrderList = "${baseUrl}vendor-order";
  static const String productShipping = "${baseUrl}product-shipping?";
}

showToast(message, {ToastGravity? gravity, bool? center}) {
  Fluttertoast.cancel();
  Fluttertoast.showToast(
      msg: message.toString(),
      toastLength: Toast.LENGTH_LONG,
      gravity:
          center == true ? ToastGravity.CENTER : gravity ?? ToastGravity.BOTTOM,
      timeInSecForIosWeb: 4,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 15);
}

showToastCenter(message, {ToastGravity? gravity, bool? center}) {
  Fluttertoast.cancel();
  Fluttertoast.showToast(
      msg: message.toString().capitalize!,
      toastLength: Toast.LENGTH_LONG,
      gravity:
          center == true ? ToastGravity.CENTER : gravity ?? ToastGravity.CENTER,
      timeInSecForIosWeb: 4,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 15);
}

hideToast() {
  Fluttertoast.cancel();
}

Future getUserToken() async {
  SharedPreferences sharedPreference = await SharedPreferences.getInstance();
  LoginModal model =
      LoginModal.fromJson(jsonDecode(sharedPreference.getString("userData")!));
  return model.token.toString();
}
