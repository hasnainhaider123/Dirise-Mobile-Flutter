import 'dart:convert';
import 'dart:developer';
import 'package:dirise/controller/profile_controller.dart';
import 'package:dirise/repository/repository.dart';
import 'package:get/get.dart';
import '../model/author_modal.dart';
import '../model/featured_store_model.dart';
import '../model/home_modal.dart';
import '../model/popular_product_modal.dart';
import '../model/shipping_model.dart';
import '../model/showCase_product_model.dart';
import '../model/trending_products_modal.dart';
import '../model/vendor_models/vendor_category_model.dart';
import '../utils/api_constant.dart';
import 'cart_controller.dart';
import 'location_controller.dart';

class TrendingProductsController extends GetxController {
  String defaultAddressId = '';
  Rx<HomeModal> homeModal = HomeModal().obs;
  final cartController = Get.put(CartController());
  Rx<PopularProductsModal> popularProdModal = PopularProductsModal().obs;
  Rx<GetShowCaseProductModel> getShowModal = GetShowCaseProductModel().obs;
  Rx<AuthorModal> authorModal = AuthorModal().obs;
  final Repositories repositories = Repositories();
  Rx<TendingModel> trendingModel = TendingModel().obs;
  Rx<ShippingModel> shippingModel = ShippingModel().obs;
  final locationController = Get.put(LocationController());
  ModelVendorCategory vendorCategory = ModelVendorCategory();
  RxInt updateCate = 0.obs;
  Rx<GetFeaturedStoreModel> getFeaturedModel = GetFeaturedStoreModel().obs;
  final profileController = Get.put(ProfileController());
  Future trendingData() async {
    Map<String, dynamic> map = {};

    map["country_id"]= profileController.model.user!= null && cartController.countryId.isEmpty ? profileController.model.user!.country_id : cartController.countryId.toString();
    // map["country_id"]= cartController.countryId.toString();
      map["zip_code"]= locationController.zipcode.value.toString();
      map["state"]= locationController.state.toString();
      map["is_def_address"]= defaultAddressId.toString();
      log('Tranding Api ${map}');
    await repositories.postApi(url: ApiUrls.trendingProductsUrl, mapData:map,showResponse: true).then((value) {
      trendingModel.value = TendingModel.fromJson(jsonDecode(value));
    });
  }
  Future shippingHome({productId}) async {

    await repositories.postApi(url: '${ApiUrls.productShipping}product_id=$productId',showResponse: true).then((value) {
      shippingModel.value = ShippingModel.fromJson(jsonDecode(value));
    });
  }

  Future homeData() async {
    await repositories.postApi(url: ApiUrls.homeUrl, mapData: {}).then((value) {
      homeModal.value = HomeModal.fromJson(jsonDecode(value));
    });
  }
  Future featuredStores() async {
    await repositories.getApi(url: ApiUrls.featuredStore).then((value) {
      getFeaturedModel.value = GetFeaturedStoreModel.fromJson(jsonDecode(value));
    });
  }

  Future popularProductsData() async {
    Map<String, dynamic> map = {};

    map["country_id"]= profileController.model.user!= null && cartController.countryId.isEmpty ? profileController.model.user!.country_id : cartController.countryId.toString();
    // map["country_id"]= cartController.countryId.isNotEmpty ? cartController.countryId.toString() : '117';
    map["zip_code"]= locationController.zipcode.value.toString();
    map["state"]= locationController.state.toString();
    map["is_def_address"]= defaultAddressId.toString();
    log('this is calll........${map.toString()}');
    await repositories.postApi(url: ApiUrls.popularProductUrl, mapData: map).then((value) {
      popularProdModal.value = PopularProductsModal.fromJson(jsonDecode(value));
    });
  }
  Future showCaseProductsData() async {

    await repositories.getApi(url: ApiUrls.showCaseProductUrl,).then((value) {
      getShowModal.value = GetShowCaseProductModel.fromJson(jsonDecode(value));
    });
  }

  Future authorData() async {
    await repositories.getApi(url: ApiUrls.authorUrl).then((value) {
      authorModal.value = AuthorModal.fromJson(jsonDecode(value));
    });
  }

  getVendorCategories() {
    repositories.getApi(url: ApiUrls.vendorCategoryListUrl).then((value) {
      vendorCategory = ModelVendorCategory.fromJson(jsonDecode(value));
      updateCate.value = DateTime.now().millisecondsSinceEpoch;
    });
  }
  getVendorCategoriesHome() {
    repositories.getApi(url: ApiUrls.homeCategoryListUrl).then((value) {
      vendorCategory = ModelVendorCategory.fromJson(jsonDecode(value));
      updateCate.value = DateTime.now().millisecondsSinceEpoch;
    });
  }

  Future getAll() async {
    homeData();
    getVendorCategories();
    getVendorCategoriesHome();
    trendingData();
    popularProductsData();
    showCaseProductsData();
    authorData();
    featuredStores();
  }
}
