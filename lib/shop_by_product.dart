import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dirise/controller/single_product_controller.dart';
import 'package:dirise/model/CarsSubCateGoryModel.dart';
import 'package:dirise/model/filter_by_price_model.dart'
    as filter_by_price_model;
import 'package:dirise/repository/repository.dart';
import 'package:dirise/screens/auth_screens/login_screen.dart';
import 'package:dirise/screens/categories/single_category_with_stores/single_categorie.dart';
import 'package:dirise/screens/categories/single_category_with_stores/single_store_screen.dart';
import 'package:dirise/screens/check_out/direct_check_out.dart';
import 'package:dirise/screens/my_account_screens/contact_us_screen.dart';
import 'package:dirise/screens/product_details/product_widget.dart';
import 'package:dirise/screens/search_products.dart';
import 'package:dirise/screens/service_single_ui.dart';
import 'package:dirise/single_products/advirtising_single.dart';
import 'package:dirise/single_products/bookable_single.dart';
import 'package:dirise/single_products/give_away_single.dart';
import 'package:dirise/single_products/simple_product.dart';
import 'package:dirise/single_products/variable_single.dart';
import 'package:dirise/single_products/vritual_product_single.dart';
import 'package:dirise/utils/api_constant.dart';
import 'package:dirise/utils/helper.dart';
import 'package:dirise/utils/shimmer_extension.dart';
import 'package:dirise/utils/styles.dart';
import 'package:dirise/widgets/cart_widget.dart';
import 'package:dirise/widgets/like_button.dart';
import 'package:dirise/widgets/loading_animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Services/review_publish_service.dart';
import '../../addNewProduct/addProductScreen.dart';
import '../../addNewProduct/addProductStartScreen.dart';
import '../../addNewProduct/myItemIsScreen.dart';
import '../../addNewProduct/reviewPublishScreen.dart';
import '../../controller/profile_controller.dart';
import '../../controller/vendor_controllers/add_product_controller.dart';
import '../../controller/vendor_controllers/products_controller.dart';
import '../../jobOffers/JobReviewandPublishScreen.dart';
import '../../singleproductScreen/ReviewandPublishScreen.dart';
import '../../virtualProduct/ReviewandPublishScreen.dart';
import '../../widgets/common_colour.dart';
import '../../widgets/dimension_screen.dart';
import 'controller/cart_controller.dart';
import 'controller/location_controller.dart';
import 'controller/wish_list_controller.dart';
import 'language/app_strings.dart';
import 'model/add_current_address.dart';
import 'model/common_modal.dart';
import 'model/model_category_list.dart';
import 'model/model_category_stores.dart';
import 'model/order_models/model_direct_order_details.dart';
import 'model/product_model/model_product_element.dart';
import 'model/shop_by_Product_model.dart';
import 'model/vendor_models/vendor_category_model.dart';

class ShopProductScreen extends StatefulWidget {
  static String route = "/ApproveProductScreen";

  const ShopProductScreen({super.key, required this.vendorCategories});
  final VendorCategoriesData vendorCategories;
  @override
  State<ShopProductScreen> createState() => _ShopProductScreenState();
}

class _ShopProductScreenState extends State<ShopProductScreen> {
  VendorCategoriesData get mainCategory => widget.vendorCategories;
  void launchURLl(String url) async {
    if (await canLaunch(url)) {
      try {
        await launch(url);
      } catch (e) {
        print('Error launching URL: $url');
        print('Exception: $e');
      }
    } else {
      print('Could not launch $url');
    }
  }

  Position? _currentPosition;
  String? _address = "";
  final cartController = Get.put(CartController());
  final wishListController = Get.put(WishListController());
  GoogleMapController? mapController;
  Size size = Size.zero;
  final Repositories repositories = Repositories();
  RxInt productQuantity = 1.obs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    size = MediaQuery.of(context).size;
  }

  final locationController = Get.put(LocationController());

  addCurrentAddress() {
    Map<String, dynamic> map = {};
    map['zip_code'] = locationController.zipcode.value.toString();
    print('current location${map.toString()}');
    FocusManager.instance.primaryFocus!.unfocus();
    repositories
        .postApi(url: ApiUrls.addCurrentAddress, context: context, mapData: map)
        .then((value) {
      AddCorrentAddressModel response =
          AddCorrentAddressModel.fromJson(jsonDecode(value));
      cartController.countryId = response.data!.countryId.toString();
      // showToast(response.message.toString());
      // getAllAsync();
      // homeController.trendingData();
      // homeController.popularProductsData();
    });
  }

  Future<void> getAddressFromLatLng(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks != null && placemarks.isNotEmpty) {
      Placemark placemark = placemarks[0];

      setState(() {
        locationController.zipcode.value = placemark.postalCode ?? '';
        locationController.street = placemark.street ?? '';
        locationController.city.value = placemark.locality ?? '';
        locationController.state = placemark.administrativeArea ?? '';
        locationController.countryName = placemark.country ?? '';
        locationController.town = placemark.subAdministrativeArea ?? '';
        // showToast(locationController.countryName.toString());
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('street', placemark.street ?? '');
      await prefs.setString('city', placemark.locality ?? '');
      await prefs.setString('state', placemark.administrativeArea ?? '');
      await prefs.setString('country', placemark.country ?? '');
      await prefs.setString('zipcode', placemark.postalCode ?? '');
      await prefs.setString('town', placemark.subAdministrativeArea ?? '');
    }

    // errorApi();
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _address =
            '${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e.toString());
    });
  }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services'
                  .tr)));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location permissions are denied'.tr)));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.'
                  .tr)));
      return false;
    }
    return true;
  }

  // addToWishList() {
  //   repositories
  //       .postApi(
  //       url: ApiUrls.addToWishListUrl,
  //       mapData: {
  //         "product_id": item.id.toString(),
  //       },
  //       context: context)
  //       .then((value) {
  //     // widget.onLiked(true);
  //     ModelCommonResponse response = ModelCommonResponse.fromJson(jsonDecode(value));
  //     showToast(response.message);
  //     if (response.status == true) {
  //       wishListController.getYourWishList();
  //       wishListController.favoriteItems.add(item.id.toString());
  //       wishListController.updateFav;
  //     }
  //   });
  // }
  bool hasShownDialog = false;

  // removeFromWishList() {
  //   repositories
  //       .postApi(
  //       url: ApiUrls.removeFromWishListUrl,
  //       mapData: {
  //         "product_id": item.id.toString(),
  //       },
  //       context: context)
  //       .then((value) {
  //     // widget.onLiked(false);
  //     ModelCommonResponse response = ModelCommonResponse.fromJson(jsonDecode(value));
  //     showToast(response.message);
  //     if (response.status == true) {
  //       wishListController.getYourWishList();
  //       wishListController.favoriteItems.removeWhere((element) => element == item.id.toString());
  //       wishListController.updateFav;
  //     }
  //   });
  // }
  Future<void> _getCurrentPosition() async {
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      getAddressFromLatLng(_currentPosition!);
      mapController!.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(
                  _currentPosition!.latitude, _currentPosition!.longitude),
              zoom: 15)));
      // _onAddMarkerButtonPressed(LatLng(_currentPosition!.latitude, _currentPosition!.longitude), "current location");
      setState(() {});
      // homeController.trendingData();
      // homeController.popularProductsData();
      // location = _currentAddress!;
    }).catchError((e) {
      debugPrint(e.toString());
    });
  }

  ScrollController scrollController = ScrollController();
  final productController = Get.put(ProductsController());
  RxBool paginationLoading1 = false.obs;
  RxBool isDataLoading = false.obs;
  int paginationPage = 1;
  int paginationPage1 = 1;
  Rx<ShopByProductModel> modelCategoryStores =
      ShopByProductModel(product: Product(data: [])).obs;
  List<ModelCategoryStores>? modelCategoryStores1;
  Future getProductList(
      {required int page, String? search, bool? resetAll}) async {
    String url = ApiUrls.shopByProductUrl;
    if (resetAll == true) {
      isDataLoading.value = false;
      allLoaded1 = false;
      paginationLoading1.value = false;
      paginationPage1 = 1;
      modelCategoryStores.value.product!.data = null;
      page = 1;
    }
    if (allLoaded1) return;
    if (paginationLoading1.value) return;
    paginationLoading1.value = true;
    profileController.userLoggedIn
        ? await repositories
            .getApi(
                url:
                    "$url&pagination=5&page=$paginationPage1&category_id=$categoryID&key=fedexRate&country_id=${profileController.model.user != null && cartController.countryId.isEmpty ? profileController.model.user!.country_id : cartController.countryId.toString()}&zip_code=${locationController.zipcode.value.toString()}")
            .then((value) {
            paginationLoading1.value = false;
            isDataLoading.value = true;
            modelCategoryStores.value.product!.data ??= [];
            final response = ShopByProductModel.fromJson(jsonDecode(value));
            print('mapmapmap${response.toJson()}');
            if (response.product!.data != null &&
                response.product!.data!.isNotEmpty) {
              modelCategoryStores.value.product!.data!
                  .addAll(response.product!.data!);
              modelCategoryStores.value.categoryName =
                  response.categoryName.toString();
              print('fdfdf${modelCategoryStores.value.categoryName}');
              page++;
              paginationPage1++;
              print('pagination++++${paginationPage1.toString()}');
              setState(() {});
            } else {
              allLoaded = true;
            }
            setState(() {});
          })
        : await repositories
            .getApi(
                url:
                    "$url&device_id=${deviceId.toString()}&pagination=5&page=$paginationPage1&category_id=$categoryID&key=fedexRate&country_id=${profileController.model.user != null && cartController.countryId.isEmpty ? profileController.model.user!.country_id : cartController.countryId.toString()}&zip_code=${locationController.zipcode.value.toString()}")
            .then((value) {
            paginationLoading1.value = false;
            isDataLoading.value = true;
            modelCategoryStores.value.product!.data ??= [];
            final response = ShopByProductModel.fromJson(jsonDecode(value));
            print('mapmapmap${response.toJson()}');
            if (response.product!.data != null &&
                response.product!.data!.isNotEmpty) {
              modelCategoryStores.value.product!.data!
                  .addAll(response.product!.data!);
              modelCategoryStores.value.categoryName =
                  response.categoryName.toString();
              print('fdfdf${modelCategoryStores.value.categoryName}');
              page++;
              paginationPage1++;
              print('pagination++++${paginationPage1.toString()}');
              setState(() {});
            } else {
              allLoaded1 = true;
            }
            setState(() {});
          });
  }
  // Future getProductList() async {
  //   String url = ApiUrls.shopByProductUrl;
  //   // List<String> params = [];
  //   // if(textEditingController.text.trim().isNotEmpty){
  //   //   params.add("search=${textEditingController.text.trim()}");
  //   // }
  //   // params.add("page=$page");
  //   // if (selectedValue1 != null && selectedValue1.toString().isNotEmpty) {
  //   //   params.add("filter_type=${selectedValue1 == "All"?"":selectedValue1.toString()}");
  //   // }
  //   profileController.userLoggedIn ?
  //   await repositories.getApi(url: "${url}page=1&pagination=50000&category_id=$categoryID&key=fedexRate&country_id=${profileController.model.user != null && cartController.countryId.isEmpty ? profileController.model.user!.country_id : cartController.countryId.toString()}&zip_code=${locationController.zipcode.value.toString()}").then((value) {
  //         print("id:::::::::"+categoryID);
  //     // apiLoaded = true;
  //     modelCategoryStores.value = ShopByProductModel.fromJson(jsonDecode(value));
  //     // updateUI;
  //   }) :
  //   await repositories.getApi(url: "$url&device_id=${deviceId.toString()}&page=1&pagination=50000&category_id=$categoryID&key=fedexRate&country_id=${profileController.model.user != null && cartController.countryId.isEmpty ? profileController.model.user!.country_id : cartController.countryId.toString()}&zip_code=${locationController.zipcode.value.toString()}").then((value) {
  //         print("id:::::::::"+categoryID);
  //     // apiLoaded = true;
  //     modelCategoryStores.value = ShopByProductModel.fromJson(jsonDecode(value));
  //     // updateUI;
  //   });
  // }

  bool allLoaded = false;
  bool allLoaded1 = false;
  bool paginationLoading = false;
  var categoryID = Get.arguments;

  final controller = Get.put(AddProductController(), permanent: true);

  Timer? timer;

  // String? selectedValue;
  //
  // final List<String> dropdownItems = [
  //   'Giveaway',
  //   'Product',
  //   'Job',
  //   'Service',
  //   'Virtual',
  // ];

  RxString id = "".obs;
  addToCartProduct() {
    // if (!validateSlots()) return;
    Map<String, dynamic> map = {};
    map["product_id"] = id.toString();
    map["quantity"] =
        map["quantity"] = int.tryParse(productQuantity.value.toString());
    map["key"] = 'fedexRate';
    map["country_id"] =
        profileController.model.user != null && cartController.countryId.isEmpty
            ? profileController.model.user!.country_id
            : cartController.countryId.toString();

    // if (isBookingProduct) {
    //   map["start_date"] = selectedDate.text.trim();
    //   map["time_sloat"] = selectedSlot.split("--").first;
    //   map["sloat_end_time"] = selectedSlot.split("--").last;
    // }
    // if (isVariantType) {
    //   map["variation"] = selectedVariant!.id.toString();
    // }
    repositories
        .postApi(url: ApiUrls.addToCartUrl, mapData: map, context: context)
        .then((value) {
      ModelCommonResponse response =
          ModelCommonResponse.fromJson(jsonDecode(value));
      showToast(response.message.toString());
      if (response.status == true) {
        // Get.back();
        cartController.getCart();
      }
    });
  }

  addToWishList() {
    repositories
        .postApi(
            url: ApiUrls.addToWishListUrl,
            mapData: {
              "product_id": id.toString(),
            },
            context: context)
        .then((value) {
      // modelSingleProduct.value.singleGiveawayProduct!.inWishlist == true;
      ModelCommonResponse response =
          ModelCommonResponse.fromJson(jsonDecode(value));
      showToast(response.message);
      if (response.status == true) {
        wishListController.getYourWishList();
        wishListController.favoriteItems.add(id.toString());
        wishListController.updateFav;
      }
    });
  }

  removeFromWishList() {
    repositories
        .postApi(
            url: ApiUrls.removeFromWishListUrl,
            mapData: {
              "product_id": id.toString(),
            },
            context: context)
        .then((value) {
      // modelSingleProduct.value.singleGiveawayProduct!.inWishlist == true;
      ModelCommonResponse response =
          ModelCommonResponse.fromJson(jsonDecode(value));
      showToast(response.message);
      if (response.status == true) {
        wishListController.getYourWishList();
        wishListController.favoriteItems
            .removeWhere((element) => element == id.toString());
        wishListController.updateFav;
      }
    });
  }

  directBuyProduct() {
    // if (!validateSlots()) return;
    Map<String, dynamic> map = {};

    // cartController.isVariantType = isVariantType;
    // if (isVariantType) {
    //   cartController.selectedVariant = selectedVariant!.id.toString();
    // }
    map["product_id"] = id.toString();
    map["quantity"] =
        map["quantity"] = int.tryParse(productQuantity.value.toString());
    map["key"] = 'fedexRate';
    map["country_id"] = profileController.model.user != null
        ? profileController.model.user!.country_id
        : '117';
    map["zip_code"] = cartController.zipCode.toString();
    // if (isBookingProduct) {
    //   map["start_date"] = selectedDate.text.trim();
    //   map["time_sloat"] = selectedSlot.split("--").first;
    //   map["sloat_end_time"] = selectedSlot.split("--").last;
    // }
    // if (isVariantType) {
    //   map["variation"] = selectedVariant!.id.toString();
    // }
    repositories
        .postApi(url: ApiUrls.buyNowDetailsUrl, mapData: map, context: context)
        .then((value) {
      // log("Value>>>>>>>$value");
      print('singleee');
      cartController.directOrderResponse.value =
          ModelDirectOrderResponse.fromJson(jsonDecode(value));

      showToast(cartController.directOrderResponse.value.message.toString());
      if (cartController.directOrderResponse.value.status == true) {
        cartController.directOrderResponse.value.prodcutData!.inStock =
            productQuantity.value;
        if (kDebugMode) {
          print(cartController.directOrderResponse.value.prodcutData!.inStock);
        }
        Get.toNamed(DirectCheckOutScreen.route);
      }
    });
  }

  debounceSearch() {
    if (timer != null) timer!.cancel();
    timer = Timer(const Duration(milliseconds: 500), () {
      productController.getProductList1(context: context);
    });
  }

  ModelSingleCategoryList? modelCategoryList;
  bool isSelect = false;
  Future getCategoryFilter() async {
    // if (modelCategoryList != null) return;
    await repositories
        .getApi(url: ApiUrls.categoryListUrl + categoryID, showResponse: true)
        .then((value) {
      modelCategoryList = ModelSingleCategoryList.fromJson(jsonDecode(value));
      setState(() {});
    });
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      // homeController.page.value = homeController.page.value + 1;
      getProductList(page: paginationPage1);
      print("callghgfhgfhk/g;flhklgfhkgfh");
    } else {
      print("Don't callhg'h;lgfkhg;flhgfhgfhg");
    }
  }

  @override
  void initState() {
    super.initState();
    getCategoryFilter();
    getCategoryStores(page: 1);
    getProductList(page: paginationPage1);
    scrollController.addListener((_scrollListener));
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      scrollController.addListener(() {});
    });
    // getProductList(page: null);
    // SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    //
    // });
  }

  RxInt refreshInt = 0.obs;
  Future getCategoryStores(
      {required int page, String? search, bool? resetAll}) async {
    if (resetAll == true) {
      allLoaded = false;
      paginationLoading = false;
      paginationPage = 1;
      modelCategoryStores1 = null;
      page = 1;
      setState(() {});
    }
    if (allLoaded) return;
    if (paginationLoading) return;

    String url = "";
    if (search != null) {
      url = "category_id=$categoryID&pagination=4&page=$page&search=$search";
    } else {
      url = "category_id=$categoryID&pagination=4&page=$page";
    }
    paginationLoading = true;
    refreshInt.value = DateTime.now().millisecondsSinceEpoch;
    if (modelCategoryList == null) {
      await repositories
          .getApi(
              url: "${ApiUrls.getCategoryStoresUrl}$url", showResponse: true)
          .then((value) {
        modelCategoryStores1 ??= [];
        paginationLoading = false;
        refreshInt.value = DateTime.now().millisecondsSinceEpoch;
        final response = ModelCategoryStores.fromJson(jsonDecode(value));
        if (response.user!.data!.isNotEmpty &&
            !modelCategoryStores1!
                .map((e) => e.user!.currentPage.toString())
                .toList()
                .contains(response.user!.currentPage.toString())) {
          modelCategoryStores1!.add(response);
          paginationPage++;
        } else {
          allLoaded = true;
        }
        setState(() {});
      });
      return;
    }

    if (modelCategoryList!.selectedVendorSubCategory != null ||
        modelCategoryList!.data!
            .map((e) => e.selectedCategory != null)
            .toList()
            .contains(true)) {
      String kk = modelCategoryList!.data!
          .where((element) => element.selectedCategory != null)
          .map((e) => e.selectedCategory!.id.toString())
          .toList()
          .join(",");
      await repositories.postApi(
          url: ApiUrls.categoryFilterUrl,
          showResponse: true,
          mapData: {
            'category_id': categoryID,
            if (kk.isNotEmpty) 'child_id': kk,
            if (modelCategoryList!.selectedVendorSubCategory != null)
              'sub_category_id':
                  modelCategoryList!.selectedVendorSubCategory!.id.toString(),
            'pagination': '4',
            'page': page.toString()
          }).then((value) {
        modelCategoryStores1 ??= [];
        paginationLoading = false;
        refreshInt.value = DateTime.now().millisecondsSinceEpoch;
        final response = ModelCategoryStores.fromJson(jsonDecode(value));
        if (response.user!.data!.isNotEmpty &&
            !modelCategoryStores1!
                .map((e) => e.user!.currentPage.toString())
                .toList()
                .contains(response.user!.currentPage.toString())) {
          modelCategoryStores1!.add(response);
          paginationPage++;
        } else {
          allLoaded = true;
        }
        setState(() {});
      });
    } else {
      await repositories
          .getApi(
              url: "${ApiUrls.getCategoryStoresUrl}$url", showResponse: true)
          .then((value) {
        modelCategoryStores1 ??= [];
        paginationLoading = false;
        refreshInt.value = DateTime.now().millisecondsSinceEpoch;
        final response = ModelCategoryStores.fromJson(jsonDecode(value));
        if (response.user!.data!.isNotEmpty &&
            !modelCategoryStores1!
                .map((e) => e.user!.currentPage.toString())
                .toList()
                .contains(response.user!.currentPage.toString())) {
          modelCategoryStores1!.add(response);
          paginationPage++;
        } else {
          allLoaded = true;
        }
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    if (timer != null) {
      timer!.cancel();
    }
  }

  String? selectedValue1;

  final List<String> dropdownItems = [
    'Shop by product',
    'Shop by vendor',
  ];
  final List<String> dropdownItemsArabic = [
    'تسوق حسب المنتج',
    'تسوق حسب البائع',
  ];
  final ScrollController _scrollController = ScrollController();
  // final bottomController = Get.put(BottomNavBarController());

  List<Widget> vendorPartner() {
    return [
      // GestureDetector(
      //   onTap: () {
      //     if (profileController.model.user == null) {
      //       showVendorDialog();
      //       return;
      //     }
      //     if (profileController.model.user!.isVendor != true) {
      //       Get.to(() => const VendorPlansScreen());
      //       return;
      //     }
      //     if (profileController.model.user!.isVendor == true) {
      //       Get.to(() => const VendorDashBoardScreen());
      //       return;
      //     }
      //     _isValue.value = !_isValue.value;
      //     setState(() {});
      //   },
      //   child:SvgPicture.asset("assets/svgs/heart.svg"),
      // ),

      // _isValue.value == true
      //     ? Obx(() {
      //   if (profileController.refreshInt.value > 0) {}
      //`
      //   return profileController.model.user != null
      //       ? Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children:
      //         ? List.generate(
      //         vendor.length,
      //             (index) => Row(
      //           children: [
      //             const SizedBox(
      //               width: 30,
      //             ),
      //             // Expanded(
      //             //   child: TextButton(
      //             //     onPressed: () {
      //             //       Get.toNamed(vendorRoutes[index]);
      //             //     },
      //             //     style: TextButton.styleFrom(
      //             //         visualDensity: const VisualDensity(vertical: -3, horizontal: -3),
      //             //         padding: EdgeInsets.zero.copyWith(left: 16)),
      //             //     child: Row(
      //             //       children: [
      //             //         Expanded(
      //             //           child: Text(
      //             //             vendor[index],
      //             //             style: GoogleFonts.poppins(
      //             //                 fontSize: 16,
      //             //                 fontWeight: FontWeight.w400,
      //             //                 color: Colors.grey.shade500),
      //             //           ),
      //             //         ),
      //             //         const Icon(
      //             //           Icons.arrow_forward_ios_rounded,
      //             //           size: 14,
      //             //         )
      //             //       ],
      //             //     ),
      //             //   ),
      //             // ),
      //           ],
      //         ))
      //         : [],
      //   )
      //       : const SizedBox();
      // })
      //     : const SizedBox(),
    ];
  }

  List<CarsSubCateGoryModel> model = <CarsSubCateGoryModel>[];
  String subCategory = '';

  Rx<CarsSubCateGoryModel> carsSubCateGoryModel = CarsSubCateGoryModel().obs;

  Future getSubCategory() async {
    Map<String, dynamic> map = {};
    map['category_id'] = subCategory.toString();
    repositories
        .postApi(url: ApiUrls.subCategory, mapData: map, showResponse: true)
        .then((value) {
      var responseJson = jsonDecode(value);
      if (responseJson['data']['sub_categories'].isNotEmpty) {
        carsSubCateGoryModel.value =
            CarsSubCateGoryModel.fromJson(responseJson);
        model.add(carsSubCateGoryModel.value);
      }
      if (responseJson['data']['sub_categories'].isEmpty) {
        showToastCenter('No category found');
      }
      setState(() {});
    });
  }

  final controlle = Get.put(SingleCategoryController());
  Rx<filter_by_price_model.ModelFilterByPrice> filterModl =
      filter_by_price_model.ModelFilterByPrice().obs;
  VendorStoreData gg = VendorStoreData();
  VendorStoreData get storeInfo => gg;

  // Rx<ModelFilterByPrice> filterModl = ModelFilterByPrice().obs;
  filterProduct({productId}) {
    repositories.postApi(
      url: ApiUrls.filterByPriceUrl,
      context: context,
      mapData: {
        "min_price": controlle.currentRangeValues.start.toInt(),
        "max_price": controlle.currentRangeValues.end.toInt(),
        "vendor_id": productId,
      },
    ).then((value) {
      print('object${value.toString()}');
      filterModl.value =
          filter_by_price_model.ModelFilterByPrice.fromJson(jsonDecode(value));
      if (filterModl.value.status == true) {
        showToast(filterModl.value.message);
        print(filterModl.value.product.toString());
      }
    });
  }

  List<ModelCategoryStores>? modelCategoryStore;
  List<Widget> list1(int i) {
    return [
      if (modelCategoryStore![i].promotionData != null &&
          modelCategoryStore![i].promotionData!.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16).copyWith(top: 5),
            child: GestureDetector(
              onTap: () {
                final kk = modelCategoryStore![i].promotionData![min(
                    i % 3, modelCategoryStore![i].promotionData!.length - 1)];
                if (kk.promotionType == "product") {
                  bottomSheet(
                      productDetails: ProductElement(
                        id: kk.productStoreId.toString(),
                      ),
                      context: context);
                  return;
                }
                if (kk.promotionType == "store") {
                  Get.to(() => SingleStoreScreen(
                        storeDetails:
                            VendorStoreData(id: kk.productStoreId.toString()),
                      ));
                  return;
                }
              },
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                      key: ValueKey(i * DateTime.now().millisecond),
                      height: context.getSize.height * .25,
                      width: double.maxFinite,
                      child: CachedNetworkImage(
                        imageUrl: modelCategoryStore![i]
                            .promotionData![min(
                                i % 3,
                                modelCategoryStore![i].promotionData!.length -
                                    1)]
                            .banner
                            .toString(),
                        fit: BoxFit.contain,
                        width: context.getSize.width,
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                        ),
                      )).animate().fade(duration: 300.ms)),
            ),
          ),
        ),
      // const SliverToBoxAdapter(
      //   child: SizedBox(
      //     height: 20,
      //   ),
      // ),
    ];
  }

  String publish = '';
  final addProductController = Get.put(AddProductController());
  final profileController = Get.put(ProfileController());
  final scaffoldKey1 = GlobalKey<ScaffoldState>();
  final RxBool search = false.obs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: kToolbarHeight + 20,
          backgroundColor: const Color(0xFFF2F2F2),
          surfaceTintColor: const Color(0xFFF2F2F2),
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    scaffoldKey1.currentState!.openDrawer();
                  },
                  child: Image.asset(
                    'assets/images/menu_new.png',
                    width: 35,
                    height: 35,
                    // color: Colors.white,
                  ),
                ),
                const SizedBox(
                  width: 13,
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      search.value = !search.value;
                    });
                  },
                  child: SvgPicture.asset(
                    'assets/svgs/search_icon_new.svg',
                    width: 35,
                    height: 35,
                    // color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          leadingWidth: 100,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                      // width: double.maxFinite,
                      height: context.getSize.width * .1,
                      child: Hero(
                        tag: mainCategory.bannerProfile.toString(),
                        child: Material(
                          color: Colors.transparent,
                          surfaceTintColor: Colors.transparent,
                          child: CachedNetworkImage(
                              imageUrl: mainCategory.bannerProfile.toString(),
                              errorWidget: (_, __, ___) =>
                                  Image.asset('assets/images/new_logo.png')),
                        ),
                      ))),
              SizedBox(
                width: 130,
                child: Text(
                  profileController.selectedLAnguage.value == 'English'
                      ? mainCategory.name.toString()
                      : mainCategory.arabName.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 2,
                ),
              ),
              3.spaceY
            ],
          ),
          centerTitle: true,
          actions: [
            ...vendorPartner(),
            const CartBagCard(),
          ],
          bottom: PreferredSize(
            preferredSize: search.value == true
                ? const Size.fromHeight(50.0)
                : const Size.fromHeight(0.0),
            child: search.value == true
                ? Hero(
                    tag: "search_tag",
                    child: Material(
                      color: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: TextField(
                          maxLines: 1,
                          style: GoogleFonts.poppins(fontSize: 16),
                          textInputAction: TextInputAction.search,
                          onSubmitted: (vb) {
                            Get.to(() => SearchProductsScreen(
                                  searchText: vb,
                                ));
                          },
                          decoration: InputDecoration(
                              filled: true,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Image.asset(
                                  'assets/icons/search.png',
                                  height: 5,
                                ),
                              ),
                              border: InputBorder.none,
                              enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  borderSide:
                                      BorderSide(color: AppTheme.buttonColor)),
                              disabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  borderSide:
                                      BorderSide(color: AppTheme.buttonColor)),
                              focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  borderSide:
                                      BorderSide(color: AppTheme.buttonColor)),
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(15),
                              hintText: AppStrings.searchFieldText.tr,
                              hintStyle: GoogleFonts.poppins(
                                  color: AppTheme.buttonColor,
                                  fontWeight: FontWeight.w400)),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        body: CustomScrollView(
            shrinkWrap: true,
            controller: scrollController,
            slivers: [
              // if (modelCategoryStore != null)
              //   for (var i = 0; i < modelCategoryStore!.length; i++) ...list1(i)
              // else
              //   const SliverToBoxAdapter(
              //     child: LoadingAnimation(),
              //   ),
              // New Filter
              SliverAppBar(
                primary: false,
                pinned: true,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                leading: const SizedBox.shrink(),
                titleSpacing: 0,
                leadingWidth: 16,
                title: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: modelCategoryList != null
                      ? Row(
                          children: [
                            if (modelCategoryList!
                                .vendorSubCategory!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: StatefulBuilder(builder: (c, newState) {
                                  return PopupMenuButton(
                                    position: PopupMenuPosition.under,
                                    child: Container(
                                      height: 36,
                                      constraints: BoxConstraints(
                                          maxWidth:
                                              context.getSize.width * .75),
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 0, 10, 0),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color(0xff014E70)),
                                          color: const Color(0xffEBF1F4),
                                          borderRadius:
                                              BorderRadius.circular(22)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8, right: 8),
                                              child: Text(
                                                modelCategoryList!
                                                            .selectedVendorSubCategory !=
                                                        null
                                                    ? modelCategoryList!
                                                        .selectedVendorSubCategory!
                                                        .name
                                                        .toString()
                                                    : "Type",
                                                style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: const Color(
                                                        0xff014E70)),
                                              ),
                                            ),
                                          ),
                                          const Icon(
                                              Icons
                                                  .keyboard_arrow_down_outlined,
                                              color: Color(0xff014E70))
                                        ],
                                      ),
                                    ),
                                    itemBuilder: (c) {
                                      return modelCategoryList!
                                          .vendorSubCategory!
                                          .map((ee) => PopupMenuItem(
                                                child: Text(ee.name.toString()),
                                                onTap: () {
                                                  modelCategoryList!
                                                      .selectedVendorSubCategory = ee;
                                                  getCategoryStores(
                                                      page: 1, resetAll: true);
                                                  isSelect = true;
                                                  newState(() {});
                                                },
                                              ))
                                          .toList();
                                    },
                                  );
                                }),
                              ),
                            Row(
                              children: modelCategoryList!.data!
                                  .map((e) => Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: StatefulBuilder(
                                            builder: (c, newState) {
                                          return PopupMenuButton(
                                            position: PopupMenuPosition.under,
                                            child: Container(
                                              height: 36,
                                              constraints: BoxConstraints(
                                                maxWidth:
                                                    context.getSize.width * .75,
                                              ),
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      5, 0, 5, 0),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: const Color(
                                                          0xff014E70)),
                                                  // color: const Color(0xffEBF1F4),
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          22)),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Flexible(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8,
                                                              right: 8),
                                                      child: Text(
                                                        e.selectedCategory !=
                                                                null
                                                            ? e.selectedCategory!
                                                                .title
                                                                .toString()
                                                            : e.title
                                                                .toString(),
                                                        style: GoogleFonts.poppins(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: const Color(
                                                                0xff014E70)),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Image.asset(
                                                        'assets/images/Arrow down.png',
                                                        color:
                                                            Color(0xff014E70)),
                                                  ),
                                                  // const Icon(Icons.keyboard_arrow_down_outlined, color: Color(0xff014E70))
                                                ],
                                              ),
                                            ),
                                            itemBuilder: (c) {
                                              return e.childCategory!
                                                  .map((ee) => PopupMenuItem(
                                                        child: Text(ee.title
                                                            .toString()),
                                                        onTap: () {
                                                          e.selectedCategory =
                                                              ee;
                                                          getCategoryStores(
                                                              page: 1,
                                                              resetAll: true);
                                                          getSubCategory();
                                                          isSelect = true;
                                                          newState(() {});
                                                        },
                                                      ))
                                                  .toList();
                                            },
                                          );
                                        }),
                                      ))
                                  .toList(),
                            ),
                          ],
                        )
                      : const SizedBox(),
                ),
              ),
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: carsSubCateGoryModel.value.data != null
                      ? Row(
                          children: [
                            if (carsSubCateGoryModel
                                .value.data!.subCategories!.isNotEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 10, left: 16),
                                child: StatefulBuilder(builder: (c, newState) {
                                  return SizedBox(
                                    height: 40,
                                    child: ListView.builder(
                                        itemCount: model.length,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (c, i) {
                                          return ListView.builder(
                                            itemCount: 1,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, index) {
                                              //  final subCategorys = carsSubCateGoryModel.value.data!.subCategories![index];
                                              return PopupMenuButton(
                                                position:
                                                    PopupMenuPosition.under,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10),
                                                  child: Container(
                                                    height: 36,
                                                    constraints: BoxConstraints(
                                                        maxWidth: context
                                                                .getSize.width *
                                                            .75),
                                                    padding: const EdgeInsets
                                                        .fromLTRB(10, 0, 10, 0),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: const Color(
                                                              0xff014E70)),
                                                      color: const Color(
                                                          0xffEBF1F4),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              22),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Flexible(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 8,
                                                                    right: 10),
                                                            child: Text(
                                                              model[i]
                                                                  .data!
                                                                  .title
                                                                  .toString(),
                                                              //     carsSubCateGoryModel.value.data!.subCategories![index].title.toString(),
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: const Color(
                                                                    0xff014E70),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const Icon(
                                                            Icons
                                                                .keyboard_arrow_down_outlined,
                                                            color: Color(
                                                                0xff014E70)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                itemBuilder: (c) {
                                                  return model[i]
                                                      .data!
                                                      .subCategories!
                                                      .map((ee) =>
                                                          PopupMenuItem(
                                                            child: Text(ee.title
                                                                .toString()),
                                                            onTap: () {
                                                              subCategory = ee
                                                                  .id
                                                                  .toString();
                                                              getSubCategory();
                                                              newState(() {});
                                                            },
                                                          ))
                                                      .toList();
                                                },
                                              );
                                            },
                                          );
                                        }),
                                  );
                                }),
                              ),
                            // Row(
                            //   children: subCategoryModel.value.data!
                            //       .map((e) => Padding(
                            //             padding:
                            //                 const EdgeInsets.only(right: 10),
                            //             child: StatefulBuilder(
                            //                 builder: (c, newState) {
                            //               return PopupMenuButton(
                            //                 position: PopupMenuPosition.under,
                            //                 child: Container(
                            //                   height: 36,
                            //                   constraints: BoxConstraints(
                            //                       maxWidth:
                            //                           context.getSize.width *
                            //                               .75),
                            //                   padding:
                            //                       const EdgeInsets.fromLTRB(
                            //                           10, 0, 10, 0),
                            //                   decoration: BoxDecoration(
                            //                       border: Border.all(
                            //                           color: const Color(
                            //                               0xff014E70)),
                            //                       color:
                            //                           const Color(0xffEBF1F4),
                            //                       borderRadius:
                            //                           BorderRadius.circular(
                            //                               22)),
                            //                   child: Row(
                            //                     mainAxisSize: MainAxisSize.min,
                            //                     children: [
                            //                       // Flexible(
                            //                       //   child: Padding(
                            //                       //     padding: const EdgeInsets.only(left: 8, right: 10),
                            //                       //     child: Text(
                            //                       //       e.selectedCategory != null
                            //                       //           ? e.selectedCategory!.title.toString()
                            //                       //           : e.title.toString(),
                            //                       //       style: GoogleFonts.poppins(
                            //                       //           fontSize: 14,
                            //                       //           fontWeight: FontWeight.w500,
                            //                       //           color: const Color(0xff014E70)),
                            //                       //     ),
                            //                       //   ),
                            //                       // ),
                            //                       const Icon(
                            //                           Icons
                            //                               .keyboard_arrow_down_outlined,
                            //                           color: Color(0xff014E70))
                            //                     ],
                            //                   ),
                            //                 ),
                            //                 itemBuilder: (c) {
                            //                   return e.childCategory!
                            //                       .map((ee) => PopupMenuItem(
                            //                             child: Text(ee.title
                            //                                 .toString()),
                            //                             onTap: () {
                            //                               e.selectedCategory =
                            //                                   ee;
                            //                               getCategoryStores(
                            //                                   page: 1,
                            //                                   resetAll: true);
                            //                               getSubCategory();
                            //                               isSelect = true;
                            //                               newState(() {});
                            //                             },
                            //                           ))
                            //                       .toList();
                            //                 },
                            //               );
                            //             }),
                            //           ))
                            //       .toList(),
                            // ),
                          ],
                        )
                      : const SizedBox(),
                ),
              ),
              isSelect == true
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child: modelCategoryList != null
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          if (isSelect == true)
                                            GestureDetector(
                                              onTap: () {
                                                modelCategoryList = null;
                                                model.clear();
                                                getCategoryFilter();
                                                getCategoryStores(
                                                    page: 1, resetAll: true);
                                                isSelect = false;
                                                setState(() {});
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 16),
                                                child: Container(
                                                  height: 36,
                                                  width: 120,
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          10, 0, 10, 0),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: const Color(
                                                              0xff014E70)),
                                                      color: const Color(
                                                          0xffEBF1F4),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              22)),
                                                  child: Center(
                                                    child: Text(
                                                      "Clear",
                                                      style: GoogleFonts.poppins(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: const Color(
                                                              0xff014E70)),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      )
                                    : const SizedBox()),
                            10.spaceX,
                          ],
                        ),
                      ),
                    )
                  : const SliverToBoxAdapter(child: SizedBox.shrink()),

              // Old
              // SliverToBoxAdapter(
              //   child:    Align(
              //     alignment: Alignment.centerRight,
              //     child: Padding(
              //       padding: const EdgeInsets.only(right: 8.0,top: 10),
              //       child: Container(
              //         width: 200,
              //         height: 40,
              //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              //         decoration: BoxDecoration(
              //           color: const Color(0xffEBF1F4),
              //           border: Border.all(color: const Color(0xff014E70)),
              //           borderRadius: BorderRadius.circular(50),
              //         ),
              //         child: DropdownButton<String>(
              //           isExpanded: true,
              //           hint: Text(
              //             'Shop by product'.tr,
              //             style: TextStyle(color: Color(0xff014E70)),),
              //           value:selectedValue1,
              //
              //           onChanged: (String? newValue) {
              //             setState(() {
              //               selectedValue1 = newValue;
              //               if (selectedValue1 == "Shop by Vendor" || selectedValue1 == 'تسوق حسب البائع') {
              //                 Get.to(
              //                       () => SingleCategories(vendorCategories: widget.vendorCategories), // arguments: widget.vendorCategories.id.toString(),
              //                 );
              //               }
              //               // selectedValue1 == "Shop by Vendor"?Get.back():Get.back();
              //               print("value"+selectedValue1.toString());
              //
              //               // getProductList1(context: context);
              //             });
              //           },
              //           items:  profileController.selectedLAnguage.value == 'English' ?  dropdownItems.map<DropdownMenuItem<String>>((String value) {
              //             return DropdownMenuItem<String>(
              //               value: value,
              //               child: Text(value),
              //             );
              //           }).toList() :
              //           dropdownItemsArabic.map<DropdownMenuItem<String>>((String value) {
              //             return DropdownMenuItem<String>(
              //               value: value,
              //               child: Text(value),
              //             );
              //           }).toList(),
              //           underline: const SizedBox(),
              //           icon: Icon(
              //             Icons.keyboard_arrow_down_outlined,
              //             color: Color(0xff014E70),
              //           ),// Removes the default underline
              //         ),
              //       ),
              //     ),
              //   ),),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                      right: 8.0, left: 8.0, top: 10, bottom: 20),
                  child: Container(
                    width: 200,
                    height: 40,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.buttonColor,
                      border: Border.all(color: Color(0xff014E70)),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: PopupMenuButton<String>(
                      position: PopupMenuPosition.under,
                      onSelected: (String newValue) {
                        setState(() {
                          selectedValue1 = newValue;
                          if (selectedValue1 == "Shop by vendor" ||
                              selectedValue1 == 'تسوق حسب البائع') {
                            Get.to(() => SingleCategories(
                                vendorCategories: widget.vendorCategories));
                          }
                          print("value: $selectedValue1");
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        return profileController.selectedLAnguage.value ==
                                'English'
                            ? dropdownItems.map((String value) {
                                return PopupMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList()
                            : dropdownItemsArabic.map((String value) {
                                return PopupMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedValue1 ?? 'Shop by product'.tr,
                            style: TextStyle(color: Colors.white),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(7.0),
                            child: Image.asset('assets/images/Arrow down.png'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              //Apply Price Filter
              const SliverToBoxAdapter(
                child: SizedBox(height: 10),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        'FILTER BY PRICE'.tr,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 17),
                      ),
                    ),
                    RangeSlider(
                      values: controlle.currentRangeValues,
                      max: 20000,
                      divisions: 19999,
                      labels: RangeLabels(
                        controlle.currentRangeValues.start.round().toString(),
                        controlle.currentRangeValues.end.round().toString(),
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          controlle.currentRangeValues = values;
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Price : '.tr),
                          Text(
                            'KWD :'.tr,
                            style: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              ' ${controlle.currentRangeValues.start.toInt()} - ${controlle.currentRangeValues.end.toInt()}',
                              style: GoogleFonts.poppins(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          15.spaceX,
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                filterProduct(
                                    productId: storeInfo.id.toString());
                                controlle.isFilter.value = true;
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.buttonColor,
                                surfaceTintColor: AppTheme.buttonColor,
                              ),
                              child: FittedBox(
                                child: Text(
                                  "Filter".tr,
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          10.spaceX,
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  controlle.isFilter.value = false;
                                  controlle.currentRangeValues =
                                      const RangeValues(0, 0);
                                  print('valee${controlle.isFilter.value}');
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.buttonColor,
                                surfaceTintColor: AppTheme.buttonColor,
                              ),
                              child: FittedBox(
                                child: Text(
                                  "Clear".tr,
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              modelCategoryList != null
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 10, 0, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (isSelect == true)
                              GestureDetector(
                                onTap: () {
                                  modelCategoryList = null;
                                  getCategoryFilter();
                                  // getCategoryStores(page: 1, resetAll: true);
                                  isSelect = false;
                                  setState(() {});
                                },
                                child: Container(
                                  height: 36,
                                  width: 120,
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0xff014E70)),
                                      color: const Color(0xffEBF1F4),
                                      borderRadius: BorderRadius.circular(22)),
                                  child: Center(
                                    child: Text(
                                      "Clear",
                                      style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xff014E70)),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                  : const SliverToBoxAdapter(
                      child: SizedBox(),
                    ),
              if (modelCategoryStores1 != null)
                for (var i = 0; i < modelCategoryStores1!.length; i++)
                  ...list(i)
              else
                const SliverToBoxAdapter(
                  child: SizedBox(),
                ),
              SliverToBoxAdapter(
                child: Obx(() {
                  var itemsize= modelCategoryStores.value.product!.data!;
                  return modelCategoryStores.value.product!.data != null &&
                          modelCategoryStores.value.product!.data!.isNotEmpty
                      ? SizedBox(
                          // width:  MediaQuery.of(context).size.width ,
                          // height: MediaQuery.of(context).size.height,
                          child: GridView.builder(
                          // controller: scrollController,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1, // 2 images per row
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: .71,
                          ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          // itemExtent: 10.1,
                          itemCount: paginationLoading1.value
                              ? modelCategoryStores.value.product!.data!.length
                              : modelCategoryStores.value.product!.data!.length,
                          itemBuilder: (BuildContext context, int index) {

                            var item =
                                modelCategoryStores.value.product!.data![index];
                                
                            if (index ==
                                modelCategoryStores
                                        .value.product!.data!.length -
                                    1) {
                              if (paginationLoading1.value == true) {
                                return const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: Center(
                                        child: CircularProgressIndicator()));
                              } else {
                                return InkWell(
                                  onTap: () {
                                    print('item type is ${item.itemType}');
                                    if (item.itemType == 'giveaway') {
                                      Get.to(() => const GiveAwayProduct(),
                                          arguments: item.id.toString());
                                    } else if (item.productType == 'variants' &&
                                        item.itemType == 'product') {
                                      Get.to(
                                          () => const VarientsProductScreen(),
                                          arguments: item.id.toString());
                                    } else if (item.productType == 'booking' &&
                                        item.itemType == 'product') {
                                      Get.to(
                                          () => const BookableProductScreen(),
                                          arguments: item.id.toString());
                                    } else if (item.productType ==
                                            'virtual_product' &&
                                        item.itemType == 'virtual_product') {
                                      Get.to(() => VritualProductScreen(),
                                          arguments: item.id.toString());
                                    } else if (item.itemType == 'product' &&
                                        item.showcaseProduct != true) {
                                      Get.to(() => const SimpleProductScreen(),
                                          arguments: item.id.toString());
                                    } else if (item.itemType == 'service') {
                                      Get.to(() => const ServiceProductScreen(),
                                          arguments: item.id.toString());
                                    } else if (item.itemType == 'product' &&
                                        item.showcaseProduct == true) {
                                      Get.to(
                                          () =>
                                              const AdvirtismentProductScreen(),
                                          arguments: item.id.toString());
                                    }
                                    // if (item.itemType == 'giveaway') {
                                    //   Get.to(() => const GiveAwayProduct(),
                                    //       arguments: item.id.toString());
                                    // }
                                    // else if (item.productType == 'variants' &&
                                    //     item.itemType == 'product') {
                                    //   Get.to(() => const VarientsProductScreen(),
                                    //       arguments: item.id.toString());
                                    // }
                                    // else if (item.productType == 'booking' &&
                                    //     item.itemType == 'product') {
                                    //   Get.to(() => const BookableProductScreen(),
                                    //       arguments: item.id.toString());
                                    // }
                                    // else if (item.itemType == 'product') {
                                    //   Get.to(() => const SimpleProductScreen(),
                                    //       arguments: item.id.toString());
                                    // }
                                  },
                                  child:
                                      item.itemType != 'giveaway' &&
                                              item.isShowcase != true &&
                                              item.showcaseProduct != true
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Container(
                                                
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        blurStyle:
                                                            BlurStyle.outer,
                                                        offset: Offset(1, 1),
                                                        color: Colors.black12,
                                                        blurRadius: 3,
                                                      )
                                                    ]),
                                                constraints: BoxConstraints(
                                                  // maxHeight: 100,
                                                  minWidth: 0,
                                                  maxWidth: size.width * .8,
                                                ),
                                                // color: Colors.red,
                                                margin: const EdgeInsets.only(
                                                    right: 9),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        item.discountOff !=
                                                                '0.00'
                                                            ? Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(4),
                                                                decoration: BoxDecoration(
                                                                    color: const Color(
                                                                        0xFFFF6868),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                      " SALE"
                                                                          .tr,
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          color:
                                                                              const Color(0xFFFFDF33)),
                                                                    ),
                                                                    Text(
                                                                      " ${item.discountOff}${'%'}  ",
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            : const SizedBox
                                                                .shrink(),
                                                        Obx(() {
                                                          if (wishListController
                                                                  .refreshFav
                                                                  .value >
                                                              0) {}
                                                          return LikeButtonCat(
                                                            onPressed: () {
                                                              if (wishListController
                                                                  .favoriteItems
                                                                  .contains(item
                                                                      .id
                                                                      .toString())) {
                                                                removeFromWishList();
                                                              } else {
                                                                addToWishList();
                                                              }
                                                            },
                                                            isLiked: wishListController
                                                                .favoriteItems
                                                                .contains(item
                                                                    .id
                                                                    .toString()),
                                                          );
                                                        }),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    SizedBox(
                                                      height: 200,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Expanded(
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Center(
                                                                child: CachedNetworkImage(
                                                                    imageUrl: item
                                                                        .featuredImage
                                                                        .toString(),
                                                                    height: 200,
                                                                    fit: BoxFit
                                                                        .contain,
                                                                    errorWidget: (_,
                                                                            __,
                                                                            ___) =>
                                                                        Image.asset(
                                                                            'assets/images/new_logo.png')),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    const SizedBox(
                                                      height: 3,
                                                    ),
                                                    Text(
                                                      item.pName.toString(),
                                                      maxLines: 2,
                                                      style: GoogleFonts.poppins(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: const Color(
                                                              0xFF19313C)),
                                                    ),
                                                    const SizedBox(
                                                      height: 3,
                                                    ),

                                                    item.itemType != 'giveaway'
                                                        ? Row(
                                                            children: [
                                                              item.discountOff !=
                                                                      '0.00'
                                                                  ? profileController
                                                                              .selectedLAnguage
                                                                              .value ==
                                                                          "English"
                                                                      ? Expanded(
                                                                          child:
                                                                              Text.rich(
                                                                            TextSpan(
                                                                              text: '${item.pPrice.toString().split('.')[0]}.',
                                                                              style: const TextStyle(
                                                                                fontSize: 24,
                                                                                fontWeight: FontWeight.w600,
                                                                                color: Color(0xFF19313B),
                                                                                decorationColor: Colors.red,
                                                                                decorationThickness: 2,
                                                                                decoration: TextDecoration.lineThrough,
                                                                              ),
                                                                              children: [
                                                                                WidgetSpan(
                                                                                  alignment: PlaceholderAlignment.middle,
                                                                                  child: Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    children: [
                                                                                      const Text(
                                                                                        'KWD',
                                                                                        style: TextStyle(
                                                                                          fontSize: 8,
                                                                                          fontWeight: FontWeight.w500,
                                                                                          color: Color(0xFF19313B),
                                                                                        ),
                                                                                      ),
                                                                                      InkWell(
                                                                                        onTap: () {
                                                                                          print("date:::::::::::" + item.shippingDate);
                                                                                        },
                                                                                        child: Text(
                                                                                          '${item.pPrice.toString().split('.')[1]}',
                                                                                          style: const TextStyle(
                                                                                            fontSize: 8,
                                                                                            fontWeight: FontWeight.w600,
                                                                                            color: Color(0xFF19313B),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          // Text(
                                                                          //   'KWD ${item.pPrice.toString()}',
                                                                          //   style: GoogleFonts.poppins(
                                                                          //       decorationColor: Colors.red,
                                                                          //       decorationThickness: 2,
                                                                          //       decoration: TextDecoration.lineThrough,
                                                                          //       color: const Color(0xff19313B),
                                                                          //       fontSize: 16,
                                                                          //       fontWeight: FontWeight.w600),
                                                                          // ),
                                                                        )
                                                                      : Expanded(
                                                                          child:
                                                                              Text.rich(
                                                                            TextSpan(
                                                                              children: [
                                                                                WidgetSpan(
                                                                                  alignment: PlaceholderAlignment.bottom,
                                                                                  child: Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    children: [
                                                                                      const Text(
                                                                                        'KWD',
                                                                                        style: TextStyle(
                                                                                          fontSize: 8,
                                                                                          fontWeight: FontWeight.w500,
                                                                                          color: Color(0xFF19313B),
                                                                                        ),
                                                                                      ),
                                                                                      InkWell(
                                                                                        onTap: () {
                                                                                          print("date:::::::::::" + item.shippingDate);
                                                                                        },
                                                                                        child: Text(
                                                                                          '${item.pPrice.toString().split('.')[1]}',
                                                                                          style: const TextStyle(
                                                                                            fontSize: 8,
                                                                                            fontWeight: FontWeight.w600,
                                                                                            color: Color(0xFF19313B),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                TextSpan(
                                                                                  text: '.${item.pPrice.toString().split('.')[0]}',
                                                                                  style: const TextStyle(
                                                                                    fontSize: 24,
                                                                                    fontWeight: FontWeight.w600,
                                                                                    color: Color(0xFF19313B),
                                                                                    decorationColor: Colors.red,
                                                                                    decorationThickness: 2,
                                                                                    decoration: TextDecoration.lineThrough,
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          // Text(
                                                                          //   'KWD ${item.pPrice.toString()}',
                                                                          //   style: GoogleFonts.poppins(
                                                                          //       decorationColor: Colors.red,
                                                                          //       decorationThickness: 2,
                                                                          //       decoration: TextDecoration.lineThrough,
                                                                          //       color: const Color(0xff19313B),
                                                                          //       fontSize: 16,
                                                                          //       fontWeight: FontWeight.w600),
                                                                          // ),
                                                                        )
                                                                  : const SizedBox
                                                                      .shrink(),
                                                              const SizedBox(
                                                                width: 7,
                                                              ),
                                                              profileController
                                                                          .selectedLAnguage
                                                                          .value ==
                                                                      "English"
                                                                  ? Expanded(
                                                                      child: Text
                                                                          .rich(
                                                                        TextSpan(
                                                                          text:
                                                                              '${item.discountPrice.toString().split('.')[0]}.',
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                24,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color:
                                                                                Color(0xFF19313B),
                                                                          ),
                                                                          children: [
                                                                            WidgetSpan(
                                                                              alignment: PlaceholderAlignment.middle,
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                children: [
                                                                                  const Text(
                                                                                    'KWD',
                                                                                    style: TextStyle(
                                                                                      fontSize: 8,
                                                                                      fontWeight: FontWeight.w500,
                                                                                      color: Color(0xFF19313B),
                                                                                    ),
                                                                                  ),
                                                                                  InkWell(
                                                                                    onTap: () {
                                                                                      print("date:::::::::::" + item.shippingDate);
                                                                                    },
                                                                                    child: Text(
                                                                                      '${item.discountPrice.toString().split('.')[1]}',
                                                                                      style: const TextStyle(
                                                                                        fontSize: 8,
                                                                                        fontWeight: FontWeight.w600,
                                                                                        color: Color(0xFF19313B),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : Expanded(
                                                                      child: Text
                                                                          .rich(
                                                                        TextSpan(
                                                                          children: [
                                                                            WidgetSpan(
                                                                              alignment: PlaceholderAlignment.bottom,
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                children: [
                                                                                  const Text(
                                                                                    'KWD',
                                                                                    style: TextStyle(
                                                                                      fontSize: 8,
                                                                                      fontWeight: FontWeight.w500,
                                                                                      color: Color(0xFF19313B),
                                                                                    ),
                                                                                  ),
                                                                                  InkWell(
                                                                                    onTap: () {
                                                                                      print("date:::::::::::" + item.shippingDate);
                                                                                    },
                                                                                    child: Text(
                                                                                      '${item.discountPrice.toString().split('.')[1]}',
                                                                                      style: const TextStyle(
                                                                                        fontSize: 8,
                                                                                        fontWeight: FontWeight.w600,
                                                                                        color: Color(0xFF19313B),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            TextSpan(
                                                                              text: '.${item.discountPrice.toString().split('.')[0]}',
                                                                              style: const TextStyle(
                                                                                fontSize: 24,
                                                                                fontWeight: FontWeight.w600,
                                                                                color: Color(0xFF19313B),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                            ],
                                                          )
                                                        : const SizedBox
                                                            .shrink(),

                                                    // const SizedBox(
                                                    //   height: 8,
                                                    // ),

                                                    item.inStock == "-1"
                                                        ? const SizedBox
                                                            .shrink()
                                                        : Text(
                                                            '${'QTY'}: ${item.inStock} ${'piece'}',
                                                            style: normalStyle,
                                                          ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              item.rating != 0
                                                                  ? RatingBar
                                                                      .builder(
                                                                      initialRating: double.parse(item
                                                                          .rating
                                                                          .toString()),
                                                                      minRating:
                                                                          1,
                                                                      direction:
                                                                          Axis.horizontal,
                                                                      updateOnDrag:
                                                                          true,
                                                                      tapOnlyMode:
                                                                          false,
                                                                      ignoreGestures:
                                                                          true,
                                                                      allowHalfRating:
                                                                          true,
                                                                      itemSize:
                                                                          20,
                                                                      itemCount:
                                                                          5,
                                                                      itemBuilder:
                                                                          (context, _) =>
                                                                              const Icon(
                                                                        Icons
                                                                            .star,
                                                                        size: 8,
                                                                        color: Colors
                                                                            .amber,
                                                                      ),
                                                                      onRatingUpdate:
                                                                          (rating) {
                                                                        print(
                                                                            rating);
                                                                      },
                                                                    )
                                                                  : Text(
                                                                      "No Review"
                                                                          .tr),
                                                              // ,Text(
                                                              //   '${item.inStock.toString()} ${'pieces'.tr}',
                                                              //   style: GoogleFonts.poppins(color: Colors.grey.shade700, fontSize: 15,fontWeight: FontWeight.w500),
                                                              // ),
                                                              // const SizedBox(
                                                              //   height: 5,
                                                              // ),
                                                              if (Platform
                                                                  .isAndroid)
                                                                item.shippingDate !=
                                                                        "No Internation Shipping Available"
                                                                    ? Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            'shipping',
                                                                            style: GoogleFonts.poppins(
                                                                                color: const Color(0xff858484),
                                                                                fontSize: 13,
                                                                                fontWeight: FontWeight.w500),
                                                                          ),
                                                                          if (item.lowestDeliveryPrice !=
                                                                              null)
                                                                            Text(
                                                                              'KWD${item.lowestDeliveryPrice.toString()}',
                                                                              style: GoogleFonts.poppins(color: const Color(0xff858484), fontSize: 13, fontWeight: FontWeight.w500),
                                                                            ),
                                                                          if (item.shippingDate !=
                                                                              null)
                                                                            Text(
                                                                              item.shippingDate.toString(),
                                                                              maxLines: 2,
                                                                              style: GoogleFonts.poppins(color: const Color(0xff858484), fontSize: 13, fontWeight: FontWeight.w500),
                                                                            ),
                                                                        ],
                                                                      )
                                                                    : GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          Get.to(() =>
                                                                              const ContactUsScreen());
                                                                        },
                                                                        child:
                                                                            RichText(
                                                                          text: TextSpan(
                                                                              text: 'international shipping not available',
                                                                              style: GoogleFonts.poppins(color: const Color(0xff858484), fontSize: 13, fontWeight: FontWeight.w500),
                                                                              children: [
                                                                                TextSpan(text: ' contact us', style: GoogleFonts.poppins(decoration: TextDecoration.underline, color: AppTheme.buttonColor, fontSize: 13, fontWeight: FontWeight.w500)),
                                                                                TextSpan(text: ' for the soloution', style: GoogleFonts.poppins(color: const Color(0xff858484), fontSize: 13, fontWeight: FontWeight.w500)),
                                                                              ]),
                                                                        ),
                                                                      ),
                                                              // Text("vendor doesn't ship internationally, contact us for the soloution",  style: GoogleFonts.poppins(
                                                              //     color: const Color(0xff858484),
                                                              //     fontSize: 13,
                                                              //     fontWeight: FontWeight.w500),),
                                                              if (Platform
                                                                  .isIOS)
                                                                item.shippingDate !=
                                                                        "No Internation Shipping Available"
                                                                    ? Text.rich(
                                                                        TextSpan(
                                                                          text:
                                                                              'Shipping: ',
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color:
                                                                                Color(0xFF19313B),
                                                                          ),
                                                                          children: [
                                                                            if (item.lowestDeliveryPrice !=
                                                                                null)
                                                                              WidgetSpan(
                                                                                alignment: PlaceholderAlignment.middle,
                                                                                child: Text(
                                                                                  item.lowestDeliveryPrice.toString(),
                                                                                  style: GoogleFonts.poppins(
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    color: Colors.black,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            WidgetSpan(
                                                                              alignment: PlaceholderAlignment.middle,
                                                                              child: Text(
                                                                                ' KWD ',
                                                                                style: GoogleFonts.poppins(
                                                                                  fontSize: 14,
                                                                                  fontWeight: FontWeight.w500,
                                                                                  color: Colors.black,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            const WidgetSpan(
                                                                              alignment: PlaceholderAlignment.middle,
                                                                              child: Text(
                                                                                ' & Estimated arrival by ',
                                                                                style: TextStyle(
                                                                                  fontSize: 9,
                                                                                  fontWeight: FontWeight.w500,
                                                                                  color: Color(0xFF19313B),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            WidgetSpan(
                                                                              alignment: PlaceholderAlignment.middle,
                                                                              child: Text(
                                                                                item.shippingDate ?? '',
                                                                                maxLines: 2,
                                                                                style: GoogleFonts.poppins(
                                                                                  fontSize: 14,
                                                                                  fontWeight: FontWeight.w500,
                                                                                  color: Colors.black,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      )
                                                                    : GestureDetector(
                                                                        onTap:
                                                                            () async {
                                                                          SharedPreferences
                                                                              preferences =
                                                                              await SharedPreferences.getInstance();
                                                                          hasShownDialog =
                                                                              preferences.getBool('hasShownDialog') ?? false;
                                                                          // Get.to(() => const ContactUsScreen());
                                                                          await preferences.setBool(
                                                                              'hasShownDialog',
                                                                              true);
                                                                          _getCurrentPosition();
                                                                          addCurrentAddress();
                                                                        },
                                                                        child:
                                                                            RichText(
                                                                          text: TextSpan(
                                                                              text: 'international shipping not available',
                                                                              style: GoogleFonts.poppins(color: const Color(0xff858484), fontSize: 13, fontWeight: FontWeight.w500),
                                                                              children: [
                                                                                TextSpan(text: ' allow location', style: GoogleFonts.poppins(decoration: TextDecoration.underline, color: AppTheme.buttonColor, fontSize: 13, fontWeight: FontWeight.w500)),
                                                                                TextSpan(text: ' for the soloution', style: GoogleFonts.poppins(color: const Color(0xff858484), fontSize: 13, fontWeight: FontWeight.w500)),
                                                                              ]),
                                                                        ),
                                                                      ),
                                                            ],
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            children: [
                                                              item.itemType !=
                                                                      'giveaway'
                                                                  ? Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            if (productQuantity.value >
                                                                                1) {
                                                                              productQuantity.value--;
                                                                            }
                                                                          },
                                                                          child: Center(
                                                                              child: Text(
                                                                            "-",
                                                                            style: GoogleFonts.poppins(
                                                                                fontSize: 40,
                                                                                fontWeight: FontWeight.w300,
                                                                                color: const Color(0xFF014E70)),
                                                                          )),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              size.width * .02,
                                                                        ),
                                                                        Obx(() {
                                                                          return Text(
                                                                            productQuantity.value.toString(),
                                                                            style: GoogleFonts.poppins(
                                                                                fontSize: 26,
                                                                                fontWeight: FontWeight.w500,
                                                                                color: const Color(0xFF014E70)),
                                                                          );
                                                                        }),
                                                                        SizedBox(
                                                                          width:
                                                                              size.width * .02,
                                                                        ),
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            if (item.inStock ==
                                                                                0) {
                                                                              showToast("Out Of Stock".tr);
                                                                            } else {
                                                                              productQuantity.value++;
                                                                            }
                                                                          },
                                                                          child: Center(
                                                                              child: Text(
                                                                            "+",
                                                                            style: GoogleFonts.poppins(
                                                                                fontSize: 30,
                                                                                fontWeight: FontWeight.w300,
                                                                                color: const Color(0xFF014E70)),
                                                                          )),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : const SizedBox(),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              id.value = item.id
                                                                  .toString();
                                                              if (item.productType ==
                                                                  'variants') {
                                                                bottomSheet(
                                                                    productDetails:
                                                                        item,
                                                                    context:
                                                                        context);
                                                              } else {
                                                                cartController
                                                                        .productElementId =
                                                                    item.id
                                                                        .toString();
                                                                cartController
                                                                        .productQuantity =
                                                                    productQuantity
                                                                        .value
                                                                        .toString();
                                                                directBuyProduct();
                                                              }
                                                            },
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  Colors.red,
                                                              surfaceTintColor:
                                                                  Colors.red,
                                                              minimumSize: const Size(
                                                                  double
                                                                      .infinity,
                                                                  40), // Use double.infinity for full width
                                                            ),
                                                            child: FittedBox(
                                                              child: Text(
                                                                "  Buy Now  "
                                                                    .tr,
                                                                style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 8),
                                                        // Optional: Adds space between the buttons
                                                        Expanded(
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              id.value = item.id
                                                                  .toString();
                                                              if (item.productType ==
                                                                  'variants') {
                                                                bottomSheet(
                                                                    productDetails:
                                                                        item,
                                                                    context:
                                                                        context);
                                                              } else {
                                                                addToCartProduct();
                                                              }
                                                            },
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  AppTheme
                                                                      .buttonColor,
                                                              surfaceTintColor:
                                                                  AppTheme
                                                                      .buttonColor,
                                                              minimumSize: const Size(
                                                                  double
                                                                      .infinity,
                                                                  40), // Use double.infinity for full width
                                                            ),
                                                            child: FittedBox(
                                                              child: Text(
                                                                "Add to Cart"
                                                                    .tr,
                                                                style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          : item.isShowcase != true &&
                                                  item.showcaseProduct != true
                                              ? Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: Container(
                                                  
                                                    // margin: widget.isSingle == false ? EdgeInsets.zero :const EdgeInsets.only(right: 9),
                                                    // padding: widget.isSingle == false ? EdgeInsets.zero :const EdgeInsets.all(8),
                                                    decoration:
                                                        const BoxDecoration(
                                                            color: Colors.white,
                                                            boxShadow: [
                                                          BoxShadow(
                                                            blurStyle:
                                                                BlurStyle.outer,
                                                            offset:
                                                                Offset(1, 1),
                                                            color:
                                                                Colors.black12,
                                                            blurRadius: 3,
                                                          )
                                                        ]),
                                                    child: Stack(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),

                                                          constraints:
                                                              BoxConstraints(
                                                            // maxHeight: 100,
                                                            minWidth: 0,
                                                            maxWidth:
                                                                size.width * .9,
                                                          ),
                                                          // color: Colors.red,
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 9),
                                                          // constraints: BoxConstraints(
                                                          //   // maxHeight: 100,
                                                          //   minWidth: 0,
                                                          //   maxWidth: size.width,
                                                          // ),
                                                          // color: Colors.red,
                                                          // margin: const EdgeInsets.only(right: 9,left: 10),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const SizedBox(
                                                                height: 40,
                                                              ),
                                                              Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child: CachedNetworkImage(
                                                                        imageUrl: item
                                                                            .featuredImage
                                                                            .toString(),
                                                                        height:
                                                                            200,
                                                                        fit: BoxFit
                                                                            .contain,
                                                                        errorWidget: (_,
                                                                                __,
                                                                                ___) =>
                                                                            Image.asset('assets/images/new_logo.png')),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 20,
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        const SizedBox(
                                                                          height:
                                                                              15,
                                                                        ),
                                                                        Obx(() {
                                                                          if (wishListController.refreshFav.value >
                                                                              0) {}

                                                                          return LikeButtonCat(
                                                                            onPressed:
                                                                                () {
                                                                              if (wishListController.favoriteItems.contains(item.id.toString())) {
                                                                                removeFromWishList();
                                                                              } else {
                                                                                addToWishList();
                                                                              }
                                                                            },
                                                                            isLiked:
                                                                                wishListController.favoriteItems.contains(item.id.toString()),
                                                                          );
                                                                        }),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Text(
                                                                          item.pName
                                                                              .toString(),
                                                                          maxLines:
                                                                              2,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w400,
                                                                              color: const Color(0xFF19313C)),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Text(
                                                                          item.shortDescription ??
                                                                              '',
                                                                          maxLines:
                                                                              5,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w400,
                                                                              color: const Color(0xFF19313C)),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              30.spaceY,
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        id.value = item
                                                                            .id
                                                                            .toString();
                                                                        cartController.productElementId = item
                                                                            .id
                                                                            .toString();
                                                                        id.value = item
                                                                            .id
                                                                            .toString();
                                                                        cartController.productQuantity = productQuantity
                                                                            .value
                                                                            .toString();
                                                                        directBuyProduct();
                                                                      },
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        backgroundColor:
                                                                            const Color(0xFFFFDF33),
                                                                        surfaceTintColor:
                                                                            const Color(0xFFFFDF33),
                                                                      ),
                                                                      child:
                                                                          FittedBox(
                                                                        child:
                                                                            Text(
                                                                          "Get it"
                                                                              .tr,
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w500,
                                                                              color: Colors.black),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  15.spaceX,
                                                                  Expanded(
                                                                    child:
                                                                        ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        id.value = item
                                                                            .id
                                                                            .toString();
                                                                        addToCartProduct();
                                                                      },
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        backgroundColor:
                                                                            AppTheme.buttonColor,
                                                                        surfaceTintColor:
                                                                            AppTheme.buttonColor,
                                                                      ),
                                                                      child:
                                                                          FittedBox(
                                                                        child:
                                                                            Text(
                                                                          "Add to Cart"
                                                                              .tr,
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w500,
                                                                              color: Colors.white),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  item.itemType !=
                                                                          'giveaway'
                                                                      ? Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: [
                                                                            GestureDetector(
                                                                              onTap: () {
                                                                                if (productQuantity.value > 1) {
                                                                                  productQuantity.value--;
                                                                                }
                                                                              },
                                                                              child: Center(
                                                                                  child: Text(
                                                                                "-",
                                                                                style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.w300, color: const Color(0xFF014E70)),
                                                                              )),
                                                                            ),
                                                                            SizedBox(
                                                                              width: size.width * .02,
                                                                            ),
                                                                            Obx(() {
                                                                              return Text(
                                                                                productQuantity.value.toString(),
                                                                                style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w500, color: const Color(0xFF014E70)),
                                                                              );
                                                                            }),
                                                                            SizedBox(
                                                                              width: size.width * .02,
                                                                            ),
                                                                            GestureDetector(
                                                                              onTap: () {
                                                                                if (item.inStock == 0) {
                                                                                  showToast("Out Of Stock".tr);
                                                                                } else {
                                                                                  productQuantity.value++;
                                                                                }
                                                                              },
                                                                              child: Center(
                                                                                  child: Text(
                                                                                "+",
                                                                                style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w300, color: const Color(0xFF014E70)),
                                                                              )),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      : const SizedBox(),
                                                                ],
                                                              ),
                                                              15.spaceY,
                                                              if (Platform
                                                                  .isAndroid)
                                                                item.shippingDate !=
                                                                        "No Internation Shipping Available"
                                                                    ? Expanded(
                                                                        child: Text
                                                                            .rich(
                                                                          TextSpan(
                                                                            text:
                                                                                'Shipping: ',
                                                                            style:
                                                                                const TextStyle(
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.w600,
                                                                              color: Color(0xFF19313B),
                                                                            ),
                                                                            children: [
                                                                              if (item.lowestDeliveryPrice != null)
                                                                                WidgetSpan(
                                                                                  alignment: PlaceholderAlignment.middle,
                                                                                  child: Text(
                                                                                    item.lowestDeliveryPrice.toString(),
                                                                                    style: GoogleFonts.poppins(
                                                                                      fontSize: 14,
                                                                                      fontWeight: FontWeight.w500,
                                                                                      color: Colors.black,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              WidgetSpan(
                                                                                alignment: PlaceholderAlignment.middle,
                                                                                child: Text(
                                                                                  ' KWD ',
                                                                                  style: GoogleFonts.poppins(
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    color: Colors.black,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              const WidgetSpan(
                                                                                alignment: PlaceholderAlignment.middle,
                                                                                child: Text(
                                                                                  ' & Estimated arrival by ',
                                                                                  style: TextStyle(
                                                                                    fontSize: 9,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    color: Color(0xFF19313B),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              WidgetSpan(
                                                                                alignment: PlaceholderAlignment.middle,
                                                                                child: Text(
                                                                                  item.shippingDate ?? '',
                                                                                  style: GoogleFonts.poppins(
                                                                                    fontSize: 14,
                                                                                    letterSpacing: 0.5,
                                                                                    height: 2,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    color: Colors.black,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          Get.to(() =>
                                                                              const ContactUsScreen());
                                                                        },
                                                                        child:
                                                                            RichText(
                                                                          text: TextSpan(
                                                                              text: 'international shipping not available',
                                                                              style: GoogleFonts.poppins(color: const Color(0xff858484), fontSize: 13, fontWeight: FontWeight.w500),
                                                                              children: [
                                                                                TextSpan(text: ' contact us', style: GoogleFonts.poppins(decoration: TextDecoration.underline, color: AppTheme.buttonColor, fontSize: 13, fontWeight: FontWeight.w500)),
                                                                                TextSpan(text: ' for the soloution', style: GoogleFonts.poppins(color: const Color(0xff858484), fontSize: 13, fontWeight: FontWeight.w500)),
                                                                              ]),
                                                                        ),
                                                                      ),
                                                              if (Platform
                                                                  .isIOS)
                                                                item.shippingDate !=
                                                                        "No Internation Shipping Available"
                                                                    ? Expanded(
                                                                        child: Text
                                                                            .rich(
                                                                          TextSpan(
                                                                            text:
                                                                                'Shipping: ',
                                                                            style:
                                                                                const TextStyle(
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.w600,
                                                                              color: Color(0xFF19313B),
                                                                            ),
                                                                            children: [
                                                                              if (item.lowestDeliveryPrice != null)
                                                                                WidgetSpan(
                                                                                  alignment: PlaceholderAlignment.middle,
                                                                                  child: Text(
                                                                                    item.lowestDeliveryPrice.toString(),
                                                                                    style: GoogleFonts.poppins(
                                                                                      fontSize: 14,
                                                                                      fontWeight: FontWeight.w500,
                                                                                      color: Colors.black,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              WidgetSpan(
                                                                                alignment: PlaceholderAlignment.middle,
                                                                                child: Text(
                                                                                  ' KWD ',
                                                                                  style: GoogleFonts.poppins(
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    color: Colors.black,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              const WidgetSpan(
                                                                                alignment: PlaceholderAlignment.middle,
                                                                                child: Text(
                                                                                  ' & Estimated arrival by ',
                                                                                  style: TextStyle(
                                                                                    fontSize: 9,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    color: Color(0xFF19313B),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              WidgetSpan(
                                                                                alignment: PlaceholderAlignment.middle,
                                                                                child: Text(
                                                                                  item.shippingDate ?? '',
                                                                                  style: GoogleFonts.poppins(
                                                                                    fontSize: 14,
                                                                                    letterSpacing: 0.5,
                                                                                    height: 2,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    color: Colors.black,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          // Get.to(() => const ContactUsScreen());
                                                                          // Navigator.of(context).pop();
                                                                          _getCurrentPosition();
                                                                          addCurrentAddress();
                                                                        },
                                                                        child:
                                                                            RichText(
                                                                          text: TextSpan(
                                                                              text: 'international shipping not available',
                                                                              style: GoogleFonts.poppins(color: const Color(0xff858484), fontSize: 13, fontWeight: FontWeight.w500),
                                                                              children: [
                                                                                TextSpan(text: ' allow location', style: GoogleFonts.poppins(decoration: TextDecoration.underline, color: AppTheme.buttonColor, fontSize: 13, fontWeight: FontWeight.w500)),
                                                                                TextSpan(text: ' for the soloution', style: GoogleFonts.poppins(color: const Color(0xff858484), fontSize: 13, fontWeight: FontWeight.w500)),
                                                                              ]),
                                                                        ),
                                                                      ),
                                                            ],
                                                          ),
                                                        ),
                                                        Positioned(
                                                          right: 1,
                                                          top: 0,
                                                          child: Container(
                                                            width: 100,
                                                            decoration:
                                                                const BoxDecoration(
                                                                    boxShadow: [
                                                                  BoxShadow(
                                                                    // blurStyle: BlurStyle.outer,
                                                                    offset:
                                                                        Offset(
                                                                            2,
                                                                            3),
                                                                    color: Colors
                                                                        .black26,
                                                                    blurRadius:
                                                                        3,
                                                                  )
                                                                ],
                                                                    color: Color(
                                                                        0xFFFFDF33)),
                                                            child: Center(
                                                              child: Text(
                                                                "Free".tr,
                                                                style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: const Color(
                                                                        0xFF0C0D0C)),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: Stack(
                                                    children: [
                                                      Container(
                                                        height: 350,
                                                        width: Get.width,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            boxShadow: const [
                                                              BoxShadow(
                                                                blurStyle:
                                                                    BlurStyle
                                                                        .outer,
                                                                offset: Offset(
                                                                    1, 1),
                                                                color: Colors
                                                                    .black12,
                                                                blurRadius: 3,
                                                              )
                                                            ]),
                                                        // constraints: BoxConstraints(
                                                        //   // maxHeight: 100,
                                                        //   minWidth: 0,
                                                        //   maxWidth: size.width,
                                                        // ),
                                                        // color: Colors.red,
                                                        // margin: const EdgeInsets.only(right: 9,left: 10),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Expanded(
                                                                  flex: 1,
                                                                  child: CachedNetworkImage(
                                                                      imageUrl: item
                                                                          .featuredImage
                                                                          .toString(),
                                                                      height:
                                                                          200,
                                                                      fit: BoxFit
                                                                          .contain,
                                                                      errorWidget: (_,
                                                                              __,
                                                                              ___) =>
                                                                          Image.asset(
                                                                              'assets/images/new_logo.png')),
                                                                ),
                                                                const SizedBox(
                                                                  width: 20,
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    children: [
                                                                      const SizedBox(
                                                                        height:
                                                                            15,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Image.asset(
                                                                              'assets/svgs/flagk.png'),
                                                                          const SizedBox(
                                                                            width:
                                                                                5,
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Text(
                                                                              "Kuwait City",
                                                                              maxLines: 2,
                                                                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF19313C)),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                5,
                                                                          ),
                                                                          Obx(() {
                                                                            if (wishListController.refreshFav.value >
                                                                                0) {}
                                                                            return LikeButtonCat(
                                                                              onPressed: () {
                                                                                if (wishListController.favoriteItems.contains(item.id.toString())) {
                                                                                  repositories
                                                                                      .postApi(
                                                                                          url: ApiUrls.removeFromWishListUrl,
                                                                                          mapData: {
                                                                                            "product_id": item.id.toString(),
                                                                                          },
                                                                                          context: context)
                                                                                      .then((value) {
                                                                                    ModelCommonResponse response = ModelCommonResponse.fromJson(jsonDecode(value));
                                                                                    // log('api response is${response.toJson()}');
                                                                                    showToast(response.message);
                                                                                    wishListController.getYourWishList();
                                                                                    wishListController.favoriteItems.remove(item.id.toString());
                                                                                    wishListController.updateFav;
                                                                                    setState(() {});
                                                                                  });
                                                                                } else {
                                                                                  repositories
                                                                                      .postApi(
                                                                                          url: ApiUrls.addToWishListUrl,
                                                                                          mapData: {
                                                                                            "product_id": item.id.toString(),
                                                                                          },
                                                                                          context: context)
                                                                                      .then((value) {
                                                                                    ModelCommonResponse response = ModelCommonResponse.fromJson(jsonDecode(value));
                                                                                    showToast(response.message);
                                                                                    if (response.status == true) {
                                                                                      wishListController.getYourWishList();
                                                                                      wishListController.favoriteItems.add(item.id.toString());
                                                                                      wishListController.updateFav;
                                                                                    }
                                                                                  });
                                                                                }
                                                                              },
                                                                              isLiked: wishListController.favoriteItems.contains(item.id.toString()),
                                                                            );
                                                                          }),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            25,
                                                                      ),
                                                                      Text(
                                                                        item.pName
                                                                            .toString(),
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            color: const Color(0xFF19313C)),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            25,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                Text(
                                                                              "yokun",
                                                                              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w400, color: const Color(0xFF19313C)),
                                                                              maxLines: 1,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                6,
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Text(
                                                                              "gmc",
                                                                              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w400, color: const Color(0xFF19313C)),
                                                                              maxLines: 1,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                6,
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Text(
                                                                              "used",
                                                                              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w400, color: const Color(0xFF19313C)),
                                                                              maxLines: 1,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                6,
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Text(
                                                                              "2024",
                                                                              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w400, color: const Color(0xFF19313C)),
                                                                              maxLines: 1,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            35,
                                                                      ),
                                                                      Text.rich(
                                                                        TextSpan(
                                                                          text:
                                                                              '${item.discountPrice.toString().split('.')[0]}.',
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                32,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color:
                                                                                Color(0xFF19313B),
                                                                          ),
                                                                          children: [
                                                                            WidgetSpan(
                                                                              alignment: PlaceholderAlignment.middle,
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                children: [
                                                                                  const Text(
                                                                                    'KWD',
                                                                                    style: TextStyle(
                                                                                      fontSize: 8,
                                                                                      fontWeight: FontWeight.w500,
                                                                                      color: Color(0xFF19313B),
                                                                                    ),
                                                                                  ),
                                                                                  InkWell(
                                                                                    onTap: () {
                                                                                      // print("date:::::::::::" + item.shippingDate);
                                                                                    },
                                                                                    child: Text(
                                                                                      '${item.discountPrice.toString().split('.')[1]}',
                                                                                      style: const TextStyle(
                                                                                        fontSize: 8,
                                                                                        fontWeight: FontWeight.w600,
                                                                                        color: Color(0xFF19313B),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            25.spaceY,
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    item.shortDescription
                                                                        .toString(),
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            11,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color: const Color(
                                                                            0xFF19313C)),
                                                                    maxLines: 3,
                                                                  ),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    // launchURLl('tel:${ item.vendorDetails!.phoneNumber.toString()}');
                                                                  },
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                    'assets/svgs/phonee.svg',
                                                                    width: 25,
                                                                    height: 25,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 10,
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    // launchURLl('mailto:${ item.vendorDetails!.email.toString()}');
                                                                  },
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                    'assets/svgs/chat-dots.svg',
                                                                    width: 25,
                                                                    height: 25,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),

                                                            // SizedBox(height: 10,),
                                                            // Align(
                                                            //   alignment: Alignment.center,
                                                            //   child: Center(
                                                            //     child: CachedNetworkImage(
                                                            //         imageUrl: item.featuredImage.toString(),
                                                            //         height: 150,
                                                            //         fit: BoxFit.fill,
                                                            //         errorWidget: (_, __, ___) => Image.asset('assets/images/new_logo.png')
                                                            //     ),
                                                            //   ),
                                                            // ),
                                                            // const SizedBox(
                                                            //   height: 10,
                                                            // ),
                                                            //
                                                            // const SizedBox(
                                                            //   height: 3,
                                                            // ),
                                                            // Text(
                                                            //   item.pname.toString(),
                                                            //   maxLines: 2,
                                                            //   style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500,color: Color(0xFF19313C)),
                                                            // ),
                                                            // const SizedBox(
                                                            //   height: 3,
                                                            // ),
                                                            // Text(
                                                            //   item.shortDescription.toString(),
                                                            //   maxLines: 2,
                                                            //   style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500,color: Color(0xFF19313C)),
                                                            // ),
                                                            // const SizedBox(
                                                            //   height: 3,
                                                            // ),
                                                          ],
                                                        ),
                                                      ),
                                                      Positioned(
                                                        right: 0,
                                                        top: 0,
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              boxShadow: [
                                                                const BoxShadow(
                                                                  // blurStyle: BlurStyle.outer,
                                                                  offset:
                                                                      Offset(
                                                                          2, 3),
                                                                  color: Colors
                                                                      .black26,
                                                                  blurRadius: 3,
                                                                )
                                                              ],
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .only(
                                                                      topRight:
                                                                          Radius.circular(
                                                                              8)),
                                                              color: const Color(
                                                                      0xFF27D6FF)
                                                                  .withOpacity(
                                                                      0.6)),
                                                          child: Text(
                                                            " Showcase ".tr,
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Colors
                                                                        .white),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                );
                              }
                            } else if (modelCategoryStores
                                    .value.product!.data !=
                                null) {
                              return InkWell(
                                onTap: () {
                                  print(item.id);
                                  print(item.id);
                                  if (item.itemType == 'giveaway') {
                                    Get.to(() => const GiveAwayProduct(),
                                        arguments: item.id.toString());
                                  } else if (item.productType == 'variants' &&
                                      item.itemType == 'product') {
                                    Get.to(() => const VarientsProductScreen(),
                                        arguments: item.id.toString());
                                  } else if (item.productType == 'booking' &&
                                      item.itemType == 'product') {
                                    Get.to(() => const BookableProductScreen(),
                                        arguments: item.id.toString());
                                  } else if (item.productType ==
                                          'virtual_product' &&
                                      item.itemType == 'virtual_product') {
                                    Get.to(() => VritualProductScreen(),
                                        arguments: item.id.toString());
                                  } else if (item.itemType == 'product' &&
                                      item.showcaseProduct != true) {
                                    Get.to(() => const SimpleProductScreen(),
                                        arguments: item.id.toString());
                                  } else if (item.itemType == 'service') {
                                    Get.to(() => const ServiceProductScreen(),
                                        arguments: item.id.toString());
                                  } else if (item.itemType == 'product' &&
                                      item.showcaseProduct == true) {
                                    Get.to(
                                        () => const AdvirtismentProductScreen(),
                                        arguments: item.id.toString());
                                  }
                                },
                                child:
                                    item.itemType != 'giveaway' &&
                                            item.isShowcase != true &&
                                            item.showcaseProduct != true
                                        ? Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      blurStyle:
                                                          BlurStyle.outer,
                                                      offset: Offset(1, 1),
                                                      color: Colors.black12,
                                                      blurRadius: 3,
                                                    )
                                                  ]),
                                              constraints: BoxConstraints(
                                                // maxHeight: 100,
                                                minWidth: 0,
                                                maxWidth: size.width * .8,
                                              ),
                                              // color: Colors.red,
                                              margin: const EdgeInsets.only(
                                                  right: 9),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      item.discountOff != '0.00'
                                                          ? Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4),
                                                              decoration: BoxDecoration(
                                                                  color: const Color(
                                                                      0xFFFF6868),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10)),
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                    " SALE".tr,
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w700,
                                                                        color: const Color(
                                                                            0xFFFFDF33)),
                                                                  ),
                                                                  Text(
                                                                    " ${item.discountOff}${'%'}  ",
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w700,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          : const SizedBox
                                                              .shrink(),
                                                      Obx(() {
                                                        if (wishListController
                                                                .refreshFav
                                                                .value >
                                                            0) {}
                                                        return LikeButtonCat(
                                                          onPressed: () {
                                                            if (wishListController
                                                                .favoriteItems
                                                                .contains(item
                                                                    .id
                                                                    .toString())) {
                                                              removeFromWishList();
                                                            } else {
                                                              if (profileController
                                                                  .userLoggedIn) {
                                                                addToWishList();
                                                                setState(() {});
                                                              } else {
                                                                Get.to(
                                                                    const LoginScreen());
                                                              }
                                                            }
                                                          },
                                                          isLiked:
                                                              wishListController
                                                                  .favoriteItems
                                                                  .contains(item
                                                                      .id
                                                                      .toString()),
                                                        );
                                                      }),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  SizedBox(
                                                    height: 200,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Expanded(
                                                          child: Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Center(
                                                              child: CachedNetworkImage(
                                                                  imageUrl: item
                                                                      .featuredImage
                                                                      .toString(),
                                                                  height: 200,
                                                                  fit: BoxFit
                                                                      .contain,
                                                                  errorWidget: (_,
                                                                          __,
                                                                          ___) =>
                                                                      Image.asset(
                                                                          'assets/images/new_logo.png')),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    item.pName.toString(),
                                                    maxLines: 2,
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: const Color(
                                                            0xFF19313C)),
                                                  ),
                                                  const SizedBox(
                                                    height: 3,
                                                  ),
                                                  Text(
                                                    item.shortDescription !=
                                                            null
                                                        ? item.shortDescription ??
                                                            ''
                                                        : item.longDescription ??
                                                            '',
                                                    maxLines: 2,
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: const Color(
                                                            0xFF19313C)),
                                                  ),
                                                  const SizedBox(
                                                    height: 3,
                                                  ),

                                                  item.itemType != 'giveaway'
                                                      ? Row(
                                                          children: [
                                                            item.discountOff !=
                                                                    '0.00'
                                                                ? profileController
                                                                            .selectedLAnguage
                                                                            .value ==
                                                                        "English"
                                                                    ? Flexible(
                                                                        child: Text
                                                                            .rich(
                                                                          TextSpan(
                                                                            text:
                                                                                '${item.pPrice.toString().split('.')[0]}.',
                                                                            style:
                                                                                const TextStyle(
                                                                              fontSize: 24,
                                                                              fontWeight: FontWeight.w600,
                                                                              color: Color(0xFF19313B),
                                                                              decorationColor: Colors.red,
                                                                              decorationThickness: 2,
                                                                              decoration: TextDecoration.lineThrough,
                                                                            ),
                                                                            children: [
                                                                              WidgetSpan(
                                                                                alignment: PlaceholderAlignment.middle,
                                                                                child: Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: [
                                                                                    const Text(
                                                                                      'KWD',
                                                                                      style: TextStyle(
                                                                                        fontSize: 8,
                                                                                        fontWeight: FontWeight.w500,
                                                                                        color: Color(0xFF19313B),
                                                                                      ),
                                                                                    ),
                                                                                    InkWell(
                                                                                      onTap: () {
                                                                                        print("date:::::::::::" + item.shippingDate);
                                                                                      },
                                                                                      child: Text(
                                                                                        '${item.pPrice.toString().split('.')[1]}',
                                                                                        style: const TextStyle(
                                                                                          fontSize: 8,
                                                                                          fontWeight: FontWeight.w600,
                                                                                          color: Color(0xFF19313B),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        // Text(
                                                                        //   'KWD ${item.pPrice.toString()}',
                                                                        //   style: GoogleFonts.poppins(
                                                                        //       decorationColor: Colors.red,
                                                                        //       decorationThickness: 2,
                                                                        //       decoration: TextDecoration.lineThrough,
                                                                        //       color: const Color(0xff19313B),
                                                                        //       fontSize: 16,
                                                                        //       fontWeight: FontWeight.w600),
                                                                        // ),
                                                                      )
                                                                    : Flexible(
                                                                        child: Text
                                                                            .rich(
                                                                          TextSpan(
                                                                            children: [
                                                                              WidgetSpan(
                                                                                alignment: PlaceholderAlignment.bottom,
                                                                                child: Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: [
                                                                                    const Text(
                                                                                      'KWD',
                                                                                      style: TextStyle(
                                                                                        fontSize: 8,
                                                                                        fontWeight: FontWeight.w500,
                                                                                        color: Color(0xFF19313B),
                                                                                      ),
                                                                                    ),
                                                                                    InkWell(
                                                                                      onTap: () {
                                                                                        print("date:::::::::::" + item.shippingDate);
                                                                                      },
                                                                                      child: Text(
                                                                                        '${item.pPrice.toString().split('.')[1]}',
                                                                                        style: const TextStyle(
                                                                                          fontSize: 8,
                                                                                          fontWeight: FontWeight.w600,
                                                                                          color: Color(0xFF19313B),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              TextSpan(
                                                                                text: '.${item.pPrice.toString().split('.')[0]}',
                                                                                style: const TextStyle(
                                                                                  fontSize: 24,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  color: Color(0xFF19313B),
                                                                                  decorationColor: Colors.red,
                                                                                  decorationThickness: 2,
                                                                                  decoration: TextDecoration.lineThrough,
                                                                                ),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        // Text(
                                                                        //   'KWD ${item.pPrice.toString()}',
                                                                        //   style: GoogleFonts.poppins(
                                                                        //       decorationColor: Colors.red,
                                                                        //       decorationThickness: 2,
                                                                        //       decoration: TextDecoration.lineThrough,
                                                                        //       color: const Color(0xff19313B),
                                                                        //       fontSize: 16,
                                                                        //       fontWeight: FontWeight.w600),
                                                                        // ),
                                                                      )
                                                                : const SizedBox
                                                                    .shrink(),
                                                            const SizedBox(
                                                              width: 7,
                                                            ),
                                                            profileController
                                                                        .selectedLAnguage
                                                                        .value ==
                                                                    "English"
                                                                ? Expanded(
                                                                    child: Text
                                                                        .rich(
                                                                      TextSpan(
                                                                        text:
                                                                            '${item.discountPrice.toString().split('.')[0]}.',
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              24,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          color:
                                                                              Color(0xFF19313B),
                                                                        ),
                                                                        children: [
                                                                          WidgetSpan(
                                                                            alignment:
                                                                                PlaceholderAlignment.middle,
                                                                            child:
                                                                                Column(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                const Text(
                                                                                  'KWD',
                                                                                  style: TextStyle(
                                                                                    fontSize: 8,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    color: Color(0xFF19313B),
                                                                                  ),
                                                                                ),
                                                                                InkWell(
                                                                                  onTap: () {
                                                                                    print("date:::::::::::" + item.shippingDate);
                                                                                  },
                                                                                  child: Text(
                                                                                    '${item.discountPrice.toString().split('.')[1]}',
                                                                                    style: const TextStyle(
                                                                                      fontSize: 8,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      color: Color(0xFF19313B),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Expanded(
                                                                    child: Text
                                                                        .rich(
                                                                      TextSpan(
                                                                        children: [
                                                                          WidgetSpan(
                                                                            alignment:
                                                                                PlaceholderAlignment.bottom,
                                                                            child:
                                                                                Column(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                const Text(
                                                                                  'KWD',
                                                                                  style: TextStyle(
                                                                                    fontSize: 8,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    color: Color(0xFF19313B),
                                                                                  ),
                                                                                ),
                                                                                InkWell(
                                                                                  onTap: () {
                                                                                    print("date:::::::::::" + item.shippingDate);
                                                                                  },
                                                                                  child: Text(
                                                                                    '${item.discountPrice.toString().split('.')[1]}',
                                                                                    style: const TextStyle(
                                                                                      fontSize: 8,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      color: Color(0xFF19313B),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          TextSpan(
                                                                            text:
                                                                                '.${item.discountPrice.toString().split('.')[0]}',
                                                                            style:
                                                                                const TextStyle(
                                                                              fontSize: 24,
                                                                              fontWeight: FontWeight.w600,
                                                                              color: Color(0xFF19313B),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                          ],
                                                        )
                                                      : const SizedBox.shrink(),

                                                  // const SizedBox(
                                                  //   height: 8,
                                                  // ),

                                                  item.inStock == "-1"
                                                      ? const SizedBox.shrink()
                                                      : Text(
                                                          '${'QTY'}: ${item.inStock} ${'piece'}',
                                                          style: normalStyle,
                                                        ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            item.rating != 0
                                                                ? RatingBar
                                                                    .builder(
                                                                    initialRating:
                                                                        double.parse(item
                                                                            .rating
                                                                            .toString()),
                                                                    minRating:
                                                                        1,
                                                                    direction: Axis
                                                                        .horizontal,
                                                                    updateOnDrag:
                                                                        true,
                                                                    tapOnlyMode:
                                                                        false,
                                                                    ignoreGestures:
                                                                        true,
                                                                    allowHalfRating:
                                                                        true,
                                                                    itemSize:
                                                                        20,
                                                                    itemCount:
                                                                        5,
                                                                    itemBuilder:
                                                                        (context,
                                                                                _) =>
                                                                            const Icon(
                                                                      Icons
                                                                          .star,
                                                                      size: 8,
                                                                      color: Colors
                                                                          .amber,
                                                                    ),
                                                                    onRatingUpdate:
                                                                        (rating) {
                                                                      print(
                                                                          rating);
                                                                    },
                                                                  )
                                                                : Text(
                                                                    "No Review"
                                                                        .tr),
                                                            // ,Text(
                                                            //   '${item.inStock.toString()} ${'pieces'.tr}',
                                                            //   style: GoogleFonts.poppins(color: Colors.grey.shade700, fontSize: 15,fontWeight: FontWeight.w500),
                                                            // ),
                                                            // const SizedBox(
                                                            //   height: 5,
                                                            // ),
                                                            if (Platform
                                                                .isAndroid)
                                                              item.itemType !=
                                                                          'service' &&
                                                                      item.itemType !=
                                                                          'virtual_product'
                                                                  ? item.shippingDate !=
                                                                          "No Internation Shipping Available"
                                                                      ? Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              'shipping',
                                                                              style: GoogleFonts.poppins(color: const Color(0xff858484), fontSize: 13, fontWeight: FontWeight.w500),
                                                                            ),
                                                                            if (item.lowestDeliveryPrice !=
                                                                                null)
                                                                              Text(
                                                                                'KWD${item.lowestDeliveryPrice.toString()}',
                                                                                style: GoogleFonts.poppins(color: const Color(0xff858484), fontSize: 13, fontWeight: FontWeight.w500),
                                                                              ),
                                                                            if (item.shippingDate !=
                                                                                null)
                                                                              Text(
                                                                                item.shippingDate.toString(),
                                                                                maxLines: 2,
                                                                                style: GoogleFonts.poppins(color: const Color(0xff858484), fontSize: 13, fontWeight: FontWeight.w500),
                                                                              ),
                                                                          ],
                                                                        )
                                                                      : GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            Get.to(() =>
                                                                                const ContactUsScreen());
                                                                          },
                                                                          child:
                                                                              RichText(
                                                                            text:
                                                                                TextSpan(text: 'international shipping not available', style: GoogleFonts.poppins(color: const Color(0xff858484), fontSize: 13, fontWeight: FontWeight.w500), children: [
                                                                              TextSpan(text: ' contact us', style: GoogleFonts.poppins(decoration: TextDecoration.underline, color: AppTheme.buttonColor, fontSize: 13, fontWeight: FontWeight.w500)),
                                                                              TextSpan(text: ' for the soloution', style: GoogleFonts.poppins(color: const Color(0xff858484), fontSize: 13, fontWeight: FontWeight.w500)),
                                                                            ]),
                                                                          ),
                                                                        )
                                                                  : const SizedBox
                                                                      .shrink(),
                                                            // Text("vendor doesn't ship internationally, contact us for the soloution",  style: GoogleFonts.poppins(
                                                            //     color: const Color(0xff858484),
                                                            //     fontSize: 13,
                                                            //     fontWeight: FontWeight.w500),),
                                                            if (Platform.isIOS)
                                                              item.itemType !=
                                                                          'service' &&
                                                                      item.itemType !=
                                                                          'virtual_product'
                                                                  ? item.shippingDate !=
                                                                          "No Internation Shipping Available"
                                                                      ? Text
                                                                          .rich(
                                                                          TextSpan(
                                                                            text:
                                                                                'Shipping: ',
                                                                            style:
                                                                                const TextStyle(
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.w600,
                                                                              color: Color(0xFF19313B),
                                                                            ),
                                                                            children: [
                                                                              if (item.lowestDeliveryPrice != null)
                                                                                WidgetSpan(
                                                                                  alignment: PlaceholderAlignment.middle,
                                                                                  child: Text(
                                                                                    item.lowestDeliveryPrice.toString(),
                                                                                    style: GoogleFonts.poppins(
                                                                                      fontSize: 14,
                                                                                      fontWeight: FontWeight.w500,
                                                                                      color: Colors.black,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              WidgetSpan(
                                                                                alignment: PlaceholderAlignment.middle,
                                                                                child: Text(
                                                                                  ' KWD ',
                                                                                  style: GoogleFonts.poppins(
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    color: Colors.black,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              const WidgetSpan(
                                                                                alignment: PlaceholderAlignment.middle,
                                                                                child: Text(
                                                                                  ' & Estimated arrival by ',
                                                                                  style: TextStyle(
                                                                                    fontSize: 9,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    color: Color(0xFF19313B),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              WidgetSpan(
                                                                                alignment: PlaceholderAlignment.middle,
                                                                                child: Text(
                                                                                  item.shippingDate ?? '',
                                                                                  style: GoogleFonts.poppins(
                                                                                    fontSize: 14,
                                                                                    letterSpacing: 0.5,
                                                                                    height: 2,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    color: Colors.black,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        )
                                                                      : GestureDetector(
                                                                          onTap:
                                                                              () async {
                                                                            SharedPreferences
                                                                                preferences =
                                                                                await SharedPreferences.getInstance();
                                                                            hasShownDialog =
                                                                                preferences.getBool('hasShownDialog') ?? false;
                                                                            // Get.to(() => const ContactUsScreen());
                                                                            await preferences.setBool('hasShownDialog',
                                                                                true);
                                                                            _getCurrentPosition();
                                                                            addCurrentAddress();
                                                                          },
                                                                          child:
                                                                              RichText(
                                                                            text:
                                                                                TextSpan(text: 'international shipping not available', style: GoogleFonts.poppins(color: const Color(0xff858484), fontSize: 13, fontWeight: FontWeight.w500), children: [
                                                                              TextSpan(text: ' allow location', style: GoogleFonts.poppins(decoration: TextDecoration.underline, color: AppTheme.buttonColor, fontSize: 13, fontWeight: FontWeight.w500)),
                                                                              TextSpan(text: ' for the soloution', style: GoogleFonts.poppins(color: const Color(0xff858484), fontSize: 13, fontWeight: FontWeight.w500)),
                                                                            ]),
                                                                          ),
                                                                        )
                                                                  : const SizedBox
                                                                      .shrink(),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          children: [
                                                            item.itemType !=
                                                                    'giveaway'
                                                                ? Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          if (productQuantity.value >
                                                                              1) {
                                                                            productQuantity.value--;
                                                                          }
                                                                        },
                                                                        child: Center(
                                                                            child: Text(
                                                                          "-",
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 40,
                                                                              fontWeight: FontWeight.w300,
                                                                              color: const Color(0xFF014E70)),
                                                                        )),
                                                                      ),
                                                                      SizedBox(
                                                                        width: size.width *
                                                                            .02,
                                                                      ),
                                                                      Obx(() {
                                                                        return Text(
                                                                          productQuantity
                                                                              .value
                                                                              .toString(),
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 26,
                                                                              fontWeight: FontWeight.w500,
                                                                              color: const Color(0xFF014E70)),
                                                                        );
                                                                      }),
                                                                      SizedBox(
                                                                        width: size.width *
                                                                            .02,
                                                                      ),
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          int inStock =
                                                                              int.tryParse(item.inStock) ?? 0;
                                                                          if (inStock ==
                                                                              -1) {
                                                                            setState(() {
                                                                              productQuantity.value++;
                                                                            });
                                                                          } else if (inStock ==
                                                                              0) {
                                                                            showToastCenter('Product out of stock'.tr);
                                                                          } else if (productQuantity.value >=
                                                                              inStock) {
                                                                            showToastCenter('Product out of stock'.tr);
                                                                          } else {
                                                                            setState(() {
                                                                              productQuantity.value++;
                                                                            });
                                                                          }
                                                                        },
                                                                        child: Center(
                                                                            child: Text(
                                                                          "+",
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 30,
                                                                              fontWeight: FontWeight.w300,
                                                                              color: const Color(0xFF014E70)),
                                                                        )),
                                                                      ),
                                                                    ],
                                                                  )
                                                                : const SizedBox(),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Spacer(),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 20),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              id.value = item.id
                                                                  .toString();
                                                              if (item.productType ==
                                                                  'variants') {
                                                                bottomSheet(
                                                                    productDetails:
                                                                        item,
                                                                    context:
                                                                        context);
                                                              } else {
                                                                cartController
                                                                        .productElementId =
                                                                    item.id
                                                                        .toString();
                                                                cartController
                                                                        .productQuantity =
                                                                    productQuantity
                                                                        .value
                                                                        .toString();
                                                                directBuyProduct();
                                                              }
                                                            },
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  Colors.red,
                                                              surfaceTintColor:
                                                                  Colors.red,
                                                              minimumSize: const Size(
                                                                  double
                                                                      .infinity,
                                                                  40), // Use double.infinity for full width
                                                            ),
                                                            child: FittedBox(
                                                              child: Text(
                                                                "  Buy Now  "
                                                                    .tr,
                                                                style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 8),
                                                        // Optional: Adds space between the buttons
                                                        Expanded(
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              id.value = item.id
                                                                  .toString();
                                                              if (item.productType ==
                                                                  'variants') {
                                                                bottomSheet(
                                                                    productDetails:
                                                                        item,
                                                                    context:
                                                                        context);
                                                              } else {
                                                                addToCartProduct();
                                                              }
                                                            },
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  AppTheme
                                                                      .buttonColor,
                                                              surfaceTintColor:
                                                                  AppTheme
                                                                      .buttonColor,
                                                              minimumSize: const Size(
                                                                  double
                                                                      .infinity,
                                                                  40), // Use double.infinity for full width
                                                            ),
                                                            child: FittedBox(
                                                              child: Text(
                                                                "Add to Cart"
                                                                    .tr,
                                                                style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        : item.isShowcase != true &&
                                                item.showcaseProduct != true
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Container(
                                                  // margin: widget.isSingle == false ? EdgeInsets.zero :const EdgeInsets.only(right: 9),
                                                  // padding: widget.isSingle == false ? EdgeInsets.zero :const EdgeInsets.all(8),
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Colors.white,
                                                          boxShadow: [
                                                        BoxShadow(
                                                          blurStyle:
                                                              BlurStyle.outer,
                                                          offset: Offset(1, 1),
                                                          color: Colors.black12,
                                                          blurRadius: 3,
                                                        )
                                                      ]),
                                                  child: Stack(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),

                                                        constraints:
                                                            BoxConstraints(
                                                          // maxHeight: 100,
                                                          minWidth: 0,
                                                          maxWidth:
                                                              size.width * .9,
                                                        ),
                                                        // color: Colors.red,
                                                        margin: const EdgeInsets
                                                            .only(right: 9),
                                                        // constraints: BoxConstraints(
                                                        //   // maxHeight: 100,
                                                        //   minWidth: 0,
                                                        //   maxWidth: size.width,
                                                        // ),
                                                        // color: Colors.red,
                                                        // margin: const EdgeInsets.only(right: 9,left: 10),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const SizedBox(
                                                              height: 40,
                                                            ),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                  flex: 2,
                                                                  child: CachedNetworkImage(
                                                                      imageUrl: item
                                                                          .featuredImage
                                                                          .toString(),
                                                                      height:
                                                                          200,
                                                                      fit: BoxFit
                                                                          .contain,
                                                                      errorWidget: (_,
                                                                              __,
                                                                              ___) =>
                                                                          Image.asset(
                                                                              'assets/images/new_logo.png')),
                                                                ),
                                                                const SizedBox(
                                                                  width: 20,
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      const SizedBox(
                                                                        height:
                                                                            15,
                                                                      ),
                                                                      Obx(() {
                                                                        if (wishListController.refreshFav.value >
                                                                            0) {}

                                                                        return LikeButtonCat(
                                                                          onPressed:
                                                                              () {
                                                                            if (wishListController.favoriteItems.contains(item.id.toString())) {
                                                                              removeFromWishList();
                                                                            } else {
                                                                              addToWishList();
                                                                            }
                                                                          },
                                                                          isLiked: wishListController
                                                                              .favoriteItems
                                                                              .contains(item.id.toString()),
                                                                        );
                                                                      }),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Text(
                                                                        item.pName
                                                                            .toString(),
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            color: const Color(0xFF19313C)),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Text(
                                                                        item.shortDescription ??
                                                                            '',
                                                                        maxLines:
                                                                            5,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            color: const Color(0xFF19313C)),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            30.spaceY,
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      id.value = item
                                                                          .id
                                                                          .toString();
                                                                      cartController
                                                                              .productElementId =
                                                                          item.id
                                                                              .toString();
                                                                      cartController
                                                                              .productQuantity =
                                                                          productQuantity
                                                                              .value
                                                                              .toString();
                                                                      directBuyProduct();
                                                                    },
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      backgroundColor:
                                                                          const Color(
                                                                              0xFFFFDF33),
                                                                      surfaceTintColor:
                                                                          const Color(
                                                                              0xFFFFDF33),
                                                                    ),
                                                                    child:
                                                                        FittedBox(
                                                                      child:
                                                                          Text(
                                                                        "Get it"
                                                                            .tr,
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            color: Colors.black),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                15.spaceX,
                                                                Expanded(
                                                                  child:
                                                                      ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      id.value = item
                                                                          .id
                                                                          .toString();
                                                                      addToCartProduct();
                                                                    },
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      backgroundColor:
                                                                          AppTheme
                                                                              .buttonColor,
                                                                      surfaceTintColor:
                                                                          AppTheme
                                                                              .buttonColor,
                                                                    ),
                                                                    child:
                                                                        FittedBox(
                                                                      child:
                                                                          Text(
                                                                        "Add to Cart"
                                                                            .tr,
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            color: Colors.white),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                item.itemType !=
                                                                        'giveaway'
                                                                    ? Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              if (productQuantity.value > 1) {
                                                                                productQuantity.value--;
                                                                              }
                                                                            },
                                                                            child: Center(
                                                                                child: Text(
                                                                              "-",
                                                                              style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.w300, color: const Color(0xFF014E70)),
                                                                            )),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                size.width * .02,
                                                                          ),
                                                                          Obx(() {
                                                                            return Text(
                                                                              productQuantity.value.toString(),
                                                                              style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w500, color: const Color(0xFF014E70)),
                                                                            );
                                                                          }),
                                                                          SizedBox(
                                                                            width:
                                                                                size.width * .02,
                                                                          ),
                                                                          GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              int inStock = int.tryParse(item.inStock) ?? 0;
                                                                              if (inStock == -1) {
                                                                                setState(() {
                                                                                  productQuantity.value++;
                                                                                });
                                                                              } else if (inStock == 0) {
                                                                                showToastCenter('Product out of stock'.tr);
                                                                              } else if (productQuantity.value >= inStock) {
                                                                                showToastCenter('Product out of stock'.tr);
                                                                              } else {
                                                                                setState(() {
                                                                                  productQuantity.value++;
                                                                                });
                                                                              }
                                                                              // if (item.inStock == 0) {
                                                                              //   showToast(
                                                                              //       "Out Of Stock".tr);
                                                                              // } else {
                                                                              //   productQuantity.value++;
                                                                              // }
                                                                            },
                                                                            child: Center(
                                                                                child: Text(
                                                                              "+",
                                                                              style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w300, color: const Color(0xFF014E70)),
                                                                            )),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : const SizedBox(),
                                                              ],
                                                            ),
                                                            15.spaceY,
                                                            if (Platform
                                                                .isAndroid)
                                                              item.shippingDate !=
                                                                      "No Internation Shipping Available"
                                                                  ? Expanded(
                                                                      child: Text
                                                                          .rich(
                                                                        TextSpan(
                                                                          text:
                                                                              'Shipping: ',
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color:
                                                                                Color(0xFF19313B),
                                                                          ),
                                                                          children: [
                                                                            if (item.lowestDeliveryPrice !=
                                                                                null)
                                                                              WidgetSpan(
                                                                                alignment: PlaceholderAlignment.middle,
                                                                                child: Text(
                                                                                  item.lowestDeliveryPrice.toString(),
                                                                                  style: GoogleFonts.poppins(
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    color: Colors.black,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            WidgetSpan(
                                                                              alignment: PlaceholderAlignment.middle,
                                                                              child: Text(
                                                                                ' KWD ',
                                                                                style: GoogleFonts.poppins(
                                                                                  fontSize: 14,
                                                                                  fontWeight: FontWeight.w500,
                                                                                  color: Colors.black,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            const WidgetSpan(
                                                                              alignment: PlaceholderAlignment.middle,
                                                                              child: Text(
                                                                                ' & Estimated arrival by ',
                                                                                style: TextStyle(
                                                                                  fontSize: 9,
                                                                                  fontWeight: FontWeight.w500,
                                                                                  color: Color(0xFF19313B),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            WidgetSpan(
                                                                              alignment: PlaceholderAlignment.middle,
                                                                              child: Text(
                                                                                item.shippingDate ?? '',
                                                                                style: GoogleFonts.poppins(
                                                                                  fontSize: 14,
                                                                                  letterSpacing: 0.5,
                                                                                  height: 2,
                                                                                  fontWeight: FontWeight.w500,
                                                                                  color: Colors.black,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        Get.to(() =>
                                                                            const ContactUsScreen());
                                                                      },
                                                                      child:
                                                                          RichText(
                                                                        text: TextSpan(
                                                                            text:
                                                                                'international shipping not available',
                                                                            style: GoogleFonts.poppins(
                                                                                color: const Color(0xff858484),
                                                                                fontSize: 13,
                                                                                fontWeight: FontWeight.w500),
                                                                            children: [
                                                                              TextSpan(text: ' contact us', style: GoogleFonts.poppins(decoration: TextDecoration.underline, color: AppTheme.buttonColor, fontSize: 13, fontWeight: FontWeight.w500)),
                                                                              TextSpan(text: ' for the soloution', style: GoogleFonts.poppins(color: const Color(0xff858484), fontSize: 13, fontWeight: FontWeight.w500)),
                                                                            ]),
                                                                      ),
                                                                    ),
                                                            if (Platform.isIOS)
                                                              item.shippingDate !=
                                                                      "No Internation Shipping Available"
                                                                  ? Expanded(
                                                                      child: Text
                                                                          .rich(
                                                                        TextSpan(
                                                                          text:
                                                                              'Shipping: ',
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color:
                                                                                Color(0xFF19313B),
                                                                          ),
                                                                          children: [
                                                                            if (item.lowestDeliveryPrice !=
                                                                                null)
                                                                              WidgetSpan(
                                                                                alignment: PlaceholderAlignment.middle,
                                                                                child: Text(
                                                                                  item.lowestDeliveryPrice.toString(),
                                                                                  style: GoogleFonts.poppins(
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    color: Colors.black,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            WidgetSpan(
                                                                              alignment: PlaceholderAlignment.middle,
                                                                              child: Text(
                                                                                ' KWD ',
                                                                                style: GoogleFonts.poppins(
                                                                                  fontSize: 14,
                                                                                  fontWeight: FontWeight.w500,
                                                                                  color: Colors.black,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            const WidgetSpan(
                                                                              alignment: PlaceholderAlignment.middle,
                                                                              child: Text(
                                                                                ' & Estimated arrival by ',
                                                                                style: TextStyle(
                                                                                  fontSize: 9,
                                                                                  fontWeight: FontWeight.w500,
                                                                                  color: Color(0xFF19313B),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            WidgetSpan(
                                                                              alignment: PlaceholderAlignment.middle,
                                                                              child: Text(
                                                                                item.shippingDate ?? '',
                                                                                style: GoogleFonts.poppins(
                                                                                  fontSize: 14,
                                                                                  letterSpacing: 0.5,
                                                                                  height: 2,
                                                                                  fontWeight: FontWeight.w500,
                                                                                  color: Colors.black,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        // Get.to(() => const ContactUsScreen());
                                                                        // Navigator.of(context).pop();
                                                                        _getCurrentPosition();
                                                                        addCurrentAddress();
                                                                      },
                                                                      child:
                                                                          RichText(
                                                                        text: TextSpan(
                                                                            text:
                                                                                'international shipping not available',
                                                                            style: GoogleFonts.poppins(
                                                                                color: const Color(0xff858484),
                                                                                fontSize: 13,
                                                                                fontWeight: FontWeight.w500),
                                                                            children: [
                                                                              TextSpan(text: ' allow location', style: GoogleFonts.poppins(decoration: TextDecoration.underline, color: AppTheme.buttonColor, fontSize: 13, fontWeight: FontWeight.w500)),
                                                                              TextSpan(text: ' for the soloution', style: GoogleFonts.poppins(color: const Color(0xff858484), fontSize: 13, fontWeight: FontWeight.w500)),
                                                                            ]),
                                                                      ),
                                                                    ),
                                                          ],
                                                        ),
                                                      ),
                                                      Positioned(
                                                        right: 1,
                                                        top: 0,
                                                        child: Container(
                                                          width: 100,
                                                          decoration:
                                                              const BoxDecoration(
                                                                  boxShadow: [
                                                                BoxShadow(
                                                                  // blurStyle: BlurStyle.outer,
                                                                  offset:
                                                                      Offset(
                                                                          2, 3),
                                                                  color: Colors
                                                                      .black26,
                                                                  blurRadius: 3,
                                                                )
                                                              ],
                                                                  color: Color(
                                                                      0xFFFFDF33)),
                                                          child: Center(
                                                            child: Text(
                                                              "Free".tr,
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: const Color(
                                                                      0xFF0C0D0C)),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      height: 350,
                                                      width: Get.width,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          boxShadow: const [
                                                            BoxShadow(
                                                              blurStyle:
                                                                  BlurStyle
                                                                      .outer,
                                                              offset:
                                                                  Offset(1, 1),
                                                              color: Colors
                                                                  .black12,
                                                              blurRadius: 3,
                                                            )
                                                          ]),
                                                      // constraints: BoxConstraints(
                                                      //   // maxHeight: 100,
                                                      //   minWidth: 0,
                                                      //   maxWidth: size.width,
                                                      // ),
                                                      // color: Colors.red,
                                                      // margin: const EdgeInsets.only(right: 9,left: 10),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Expanded(
                                                                flex: 1,
                                                                child: CachedNetworkImage(
                                                                    imageUrl: item
                                                                        .featuredImage
                                                                        .toString(),
                                                                    height: 200,
                                                                    fit: BoxFit
                                                                        .contain,
                                                                    errorWidget: (_,
                                                                            __,
                                                                            ___) =>
                                                                        Image.asset(
                                                                            'assets/images/new_logo.png')),
                                                              ),
                                                              const SizedBox(
                                                                width: 20,
                                                              ),
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    const SizedBox(
                                                                      height:
                                                                          15,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        // Image.asset(
                                                                        //     'assets/svgs/flagk.png'),
                                                                        // const SizedBox(width: 5,),
                                                                        Expanded(
                                                                          child:
                                                                              Text(
                                                                            "Kuwait City",
                                                                            maxLines:
                                                                                2,
                                                                            style: GoogleFonts.poppins(
                                                                                fontSize: 14,
                                                                                fontWeight: FontWeight.w400,
                                                                                color: const Color(0xFF19313C)),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        Obx(() {
                                                                          if (wishListController.refreshFav.value >
                                                                              0) {}
                                                                          return LikeButtonCat(
                                                                            onPressed:
                                                                                () {
                                                                              if (wishListController.favoriteItems.contains(item.id.toString())) {
                                                                                repositories
                                                                                    .postApi(
                                                                                        url: ApiUrls.removeFromWishListUrl,
                                                                                        mapData: {
                                                                                          "product_id": item.id.toString(),
                                                                                        },
                                                                                        context: context)
                                                                                    .then((value) {
                                                                                  ModelCommonResponse response = ModelCommonResponse.fromJson(jsonDecode(value));
                                                                                  // log('api response is${response.toJson()}');
                                                                                  showToast(response.message);
                                                                                  wishListController.getYourWishList();
                                                                                  wishListController.favoriteItems.remove(item.id.toString());
                                                                                  wishListController.updateFav;
                                                                                  setState(() {});
                                                                                });
                                                                              } else {
                                                                                repositories
                                                                                    .postApi(
                                                                                        url: ApiUrls.addToWishListUrl,
                                                                                        mapData: {
                                                                                          "product_id": item.id.toString(),
                                                                                        },
                                                                                        context: context)
                                                                                    .then((value) {
                                                                                  ModelCommonResponse response = ModelCommonResponse.fromJson(jsonDecode(value));
                                                                                  showToast(response.message);
                                                                                  if (response.status == true) {
                                                                                    wishListController.getYourWishList();
                                                                                    wishListController.favoriteItems.add(item.id.toString());
                                                                                    wishListController.updateFav;
                                                                                  }
                                                                                });
                                                                              }
                                                                            },
                                                                            isLiked:
                                                                                wishListController.favoriteItems.contains(item.id.toString()),
                                                                          );
                                                                        }),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          25,
                                                                    ),
                                                                    Text(
                                                                      item.pName
                                                                          .toString(),
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color:
                                                                              const Color(0xFF19313C)),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          25,
                                                                    ),
                                                                    Text(modelCategoryStores
                                                                        .value
                                                                        .categoryName
                                                                        .toString()),
                                                                    // Row(
                                                                    //   children: [
                                                                    //     Expanded(
                                                                    //       child: Text("yokun",
                                                                    //         style: GoogleFonts
                                                                    //             .poppins(
                                                                    //             fontSize: 10,
                                                                    //             fontWeight: FontWeight
                                                                    //                 .w400,
                                                                    //             color: const Color(
                                                                    //                 0xFF19313C)),
                                                                    //         maxLines: 1,
                                                                    //       ),
                                                                    //     ),
                                                                    //     const SizedBox(width: 6,),
                                                                    //     Expanded(
                                                                    //       child: Text("gmc",
                                                                    //         style: GoogleFonts
                                                                    //             .poppins(
                                                                    //             fontSize: 10,
                                                                    //             fontWeight: FontWeight
                                                                    //                 .w400,
                                                                    //             color: const Color(
                                                                    //                 0xFF19313C)),
                                                                    //         maxLines: 1,
                                                                    //       ),
                                                                    //     ),
                                                                    //     const SizedBox(width: 6,),
                                                                    //     Expanded(
                                                                    //       child: Text("used",
                                                                    //         style: GoogleFonts
                                                                    //             .poppins(
                                                                    //             fontSize: 10,
                                                                    //             fontWeight: FontWeight
                                                                    //                 .w400,
                                                                    //             color: const Color(
                                                                    //                 0xFF19313C)),
                                                                    //         maxLines: 1,
                                                                    //       ),
                                                                    //     ),
                                                                    //     const SizedBox(width: 6,),
                                                                    //     Expanded(
                                                                    //       child: Text("2024",
                                                                    //         style: GoogleFonts
                                                                    //             .poppins(
                                                                    //             fontSize: 10,
                                                                    //             fontWeight: FontWeight
                                                                    //                 .w400,
                                                                    //             color: const Color(
                                                                    //                 0xFF19313C)),
                                                                    //         maxLines: 1,
                                                                    //       ),
                                                                    //     ),
                                                                    //   ],
                                                                    // ),
                                                                    const SizedBox(
                                                                      height:
                                                                          35,
                                                                    ),
                                                                    Text.rich(
                                                                      TextSpan(
                                                                        text:
                                                                            '${item.discountPrice.toString().split('.')[0]}.',
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              32,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          color:
                                                                              Color(0xFF19313B),
                                                                        ),
                                                                        children: [
                                                                          WidgetSpan(
                                                                            alignment:
                                                                                PlaceholderAlignment.middle,
                                                                            child:
                                                                                Column(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                const Text(
                                                                                  'KWD',
                                                                                  style: TextStyle(
                                                                                    fontSize: 8,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    color: Color(0xFF19313B),
                                                                                  ),
                                                                                ),
                                                                                InkWell(
                                                                                  onTap: () {
                                                                                    // print("date:::::::::::" + item.shippingDate);
                                                                                  },
                                                                                  child: Text(
                                                                                    '${item.discountPrice.toString().split('.')[1]}',
                                                                                    style: const TextStyle(
                                                                                      fontSize: 8,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      color: Color(0xFF19313B),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          25.spaceY,
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  item.shortDescription
                                                                      .toString(),
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: const Color(
                                                                          0xFF19313C)),
                                                                  maxLines: 3,
                                                                ),
                                                              ),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  // launchURLl('tel:${ item.vendorDetails!.phoneNumber.toString()}');
                                                                },
                                                                child:
                                                                    SvgPicture
                                                                        .asset(
                                                                  'assets/svgs/phonee.svg',
                                                                  width: 25,
                                                                  height: 25,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  // launchURLl('mailto:${ item.vendorDetails!.email.toString()}');
                                                                },
                                                                child:
                                                                    SvgPicture
                                                                        .asset(
                                                                  'assets/svgs/chat-dots.svg',
                                                                  width: 25,
                                                                  height: 25,
                                                                ),
                                                              ),
                                                            ],
                                                          ),

                                                          // SizedBox(height: 10,),
                                                          // Align(
                                                          //   alignment: Alignment.center,
                                                          //   child: Center(
                                                          //     child: CachedNetworkImage(
                                                          //         imageUrl: item.featuredImage.toString(),
                                                          //         height: 150,
                                                          //         fit: BoxFit.fill,
                                                          //         errorWidget: (_, __, ___) => Image.asset('assets/images/new_logo.png')
                                                          //     ),
                                                          //   ),
                                                          // ),
                                                          // const SizedBox(
                                                          //   height: 10,
                                                          // ),
                                                          //
                                                          // const SizedBox(
                                                          //   height: 3,
                                                          // ),
                                                          // Text(
                                                          //   item.pname.toString(),
                                                          //   maxLines: 2,
                                                          //   style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500,color: Color(0xFF19313C)),
                                                          // ),
                                                          // const SizedBox(
                                                          //   height: 3,
                                                          // ),
                                                          // Text(
                                                          //   item.shortDescription.toString(),
                                                          //   maxLines: 2,
                                                          //   style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500,color: Color(0xFF19313C)),
                                                          // ),
                                                          // const SizedBox(
                                                          //   height: 3,
                                                          // ),
                                                        ],
                                                      ),
                                                    ),
                                                    profileController
                                                                .selectedLAnguage
                                                                .value ==
                                                            "English"
                                                        ? Positioned(
                                                            right: 0,
                                                            top: 0,
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  boxShadow: [
                                                                    const BoxShadow(
                                                                      // blurStyle: BlurStyle.outer,
                                                                      offset:
                                                                          Offset(
                                                                              2,
                                                                              3),
                                                                      color: Colors
                                                                          .black26,
                                                                      blurRadius:
                                                                          3,
                                                                    )
                                                                  ],
                                                                  borderRadius: const BorderRadius
                                                                      .only(
                                                                      topRight:
                                                                          Radius.circular(
                                                                              8)),
                                                                  color: const Color(
                                                                          0xFF27D6FF)
                                                                      .withOpacity(
                                                                          0.6)),
                                                              child: Text(
                                                                " Showcase ".tr,
                                                                style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          )
                                                        : Positioned(
                                                            left: 0,
                                                            top: 0,
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  boxShadow: [
                                                                    const BoxShadow(
                                                                      // blurStyle: BlurStyle.outer,
                                                                      offset:
                                                                          Offset(
                                                                              2,
                                                                              3),
                                                                      color: Colors
                                                                          .black26,
                                                                      blurRadius:
                                                                          3,
                                                                    )
                                                                  ],
                                                                  borderRadius: const BorderRadius
                                                                      .only(
                                                                      topRight:
                                                                          Radius.circular(
                                                                              8)),
                                                                  color: const Color(
                                                                          0xFF27D6FF)
                                                                      .withOpacity(
                                                                          0.6)),
                                                              child: Text(
                                                                " Showcase ".tr,
                                                                style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          )
                                                  ],
                                                ),
                                              ),
                              );
                            } else {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 38.0),
                                child: Center(
                                  child: Text(
                                    "Product not found".tr,
                                    style: GoogleFonts.poppins(),
                                  ),
                                ),
                              );
                            }
                          },
                        ))
                      : SizedBox(
                          height: 100,
                          width: 100,
                          child: Center(
                            child: Text("Product not found".tr),
                          ),
                        );
                }),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 20,
                ),
              ),
            ]));
  }

  List<Widget> list(int i) {
    return [
      if (modelCategoryStores1![i].promotionData != null &&
          modelCategoryStores1![i].promotionData!.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16).copyWith(top: 10),
            child: GestureDetector(
              onTap: () {
                final kk = modelCategoryStores1![i].promotionData![min(
                    i % 3, modelCategoryStores1![i].promotionData!.length - 1)];
                if (kk.promotionType == "product") {
                  bottomSheet(
                      productDetails: ProductElement(
                        id: kk.productStoreId.toString(),
                      ),
                      context: context);
                  return;
                }
                if (kk.promotionType == "store") {
                  Get.to(() => SingleStoreScreen(
                        storeDetails:
                            VendorStoreData(id: kk.productStoreId.toString()),
                      ));
                  return;
                }
              },
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                      key: ValueKey(i * DateTime.now().millisecond),
                      height: context.getSize.width * .4,
                      width: double.maxFinite,
                      child: CachedNetworkImage(
                        imageUrl: modelCategoryStores1![i]
                            .promotionData![min(
                                i % 3,
                                modelCategoryStores1![i].promotionData!.length -
                                    1)]
                            .banner
                            .toString(),
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                        ),
                      )).animate().fade(duration: 300.ms)),
            ),
          ),
        ),
      // SliverList.builder(
      //     itemCount: modelCategoryStores1![i].user!.data!.length,
      //     itemBuilder: (context, index) {
      //       final store = modelCategoryStores1![i].user!.data![index];
      //       return Padding(
      //         padding: const EdgeInsets.symmetric(horizontal: 16),
      //         child: InkWell(
      //             onTap: () {
      //               Get.to(
      //                       () => SingleStoreScreen(
      //                     storeDetails: store,
      //                   ),
      //                   arguments: mainCategory.name.toString().tr);
      //             },
      //             child: Container(
      //                 margin: const EdgeInsets.only(
      //                   bottom: 10,
      //                 ),
      //                 decoration: BoxDecoration(
      //                     border: Border.all(color: const Color(0xffDCDCDC)), borderRadius: BorderRadius.circular(10)),
      //                 child: Padding(
      //                   padding: const EdgeInsets.fromLTRB(8, 10, 15, 8),
      //                   child: Row(
      //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                     crossAxisAlignment: CrossAxisAlignment.start,
      //                     children: [
      //                       SizedBox(
      //                         height: 85,
      //                         width: 100,
      //                         child: Hero(
      //                           tag: store.storeLogo.toString(),
      //                           child: Material(
      //                             color: Colors.transparent,
      //                             surfaceTintColor: Colors.transparent,
      //                             child: CachedNetworkImage(
      //                                 imageUrl: store.storeLogoApp.toString(),
      //                                 fit: BoxFit.cover,
      //                                 errorWidget: (_, __, ___) => Image.asset('assets/images/new_logo.png')),
      //                           ),
      //                         ),
      //                       ),
      //                       const SizedBox(
      //                         width: 12,
      //                       ),
      //                       Expanded(
      //                         child: Column(
      //                           crossAxisAlignment: CrossAxisAlignment.start,
      //                           mainAxisAlignment: MainAxisAlignment.start,
      //                           children: [
      //                             Text(
      //                               store.storeName.toString(),
      //                               style: GoogleFonts.poppins(
      //                                   color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
      //                             ),
      //                             Padding(
      //                               padding: const EdgeInsets.only(top: 5, bottom: 5),
      //                               child: Text(
      //                                 store.description.toString(),
      //                                 maxLines: 1,
      //                                 style: GoogleFonts.poppins(
      //                                     color: Colors.grey.withOpacity(.7),
      //                                     fontSize: 12,
      //                                     fontWeight: FontWeight.w500),
      //                               ),
      //                             ),
      //                             Text(
      //                               // ("${modelCategoryStores![i].product.toString()} ${AppStrings.items.tr}"),
      //                               AppStrings.items.tr,
      //                               style: GoogleFonts.poppins(
      //                                   color: const Color(0xff014E70), fontSize: 16, fontWeight: FontWeight.w600),
      //                             )
      //                           ],
      //                         ),
      //                       )
      //                     ],
      //                   ),
      //                 ))),
      //       );
      //     }),
      // if (modelCategoryStores1![i].product!.isNotEmpty)
      //   SliverToBoxAdapter(
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         Padding(
      //           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      //           child: Text(
      //             AppStrings.relatedProduct.tr,
      //             style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
      //           ),
      //         ),
      //         const SizedBox(
      //           height: 10,
      //         ),
      //         Container(
      //           height: 440,
      //           margin: const EdgeInsets.only(top: 20),
      //           child: ListView.builder(
      //               itemCount: modelCategoryStores1![i].product!.length,
      //               scrollDirection: Axis.horizontal,
      //               shrinkWrap: true,
      //               padding: const EdgeInsets.symmetric(horizontal: 16),
      //               itemBuilder: (BuildContext context, int index) {
      //                 final item = modelCategoryStores1![i].product![index];
      //                 return ProductUI(
      //                   isSingle: false,
      //                   productElement: item,
      //                   onLiked: (value) {
      //                     modelCategoryStores1![i].product![index].inWishlist = value;
      //                   },
      //                 );
      //               }),
      //         ),
      //       ],
      //     ),
      //   ),
      const SliverToBoxAdapter(
        child: SizedBox(
          height: 20,
        ),
      ),
    ];
  }
}
