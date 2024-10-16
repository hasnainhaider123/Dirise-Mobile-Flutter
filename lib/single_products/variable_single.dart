import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dirise/single_products/simple_product.dart';
import 'package:dirise/single_products/vritual_product_single.dart';
import 'package:dirise/utils/helper.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../controller/cart_controller.dart';
import '../controller/home_controller.dart';
import '../controller/location_controller.dart';
import '../controller/profile_controller.dart';
import '../controller/wish_list_controller.dart';
import '../model/add_review_model.dart';
import '../model/common_modal.dart';

import '../model/get_review_model.dart';
import '../model/giveaway_single_model.dart';
import '../model/model_category_stores.dart';
import '../model/model_single_product.dart';
import '../model/order_models/model_direct_order_details.dart';
import '../model/releated_product_model.dart';
import '../model/simple_product_model.dart';
import '../model/variable_product_nodel.dart';
import '../repository/repository.dart';
import '../screens/categories/single_category_with_stores/single_store_screen.dart';
import '../screens/check_out/direct_check_out.dart';
import '../screens/my_account_screens/contact_us_screen.dart';
import '../screens/product_details/fullScreenImageViewer.dart';
import '../screens/service_single_ui.dart';
import '../utils/api_constant.dart';
import '../utils/styles.dart';
import '../widgets/cart_widget.dart';
import '../widgets/common_colour.dart';
import '../widgets/like_button.dart';
import '../widgets/loading_animation.dart';
import 'bookable_single.dart';
import 'give_away_single.dart';

class VarientsProductScreen extends StatefulWidget {
  const VarientsProductScreen({super.key});
  @override
  State<VarientsProductScreen> createState() => _VarientsProductScreenState();
}

class _VarientsProductScreenState extends State<VarientsProductScreen> {
  final Repositories repositories = Repositories();

  // SingleGiveawayProduct productElement = SingleGiveawayProduct();
  TextEditingController reviewController = TextEditingController();
  final profileController = Get.put(ProfileController());

  // ProductElement get productDetails => productElement;
  Rx<VariableProductModel> modelSingleProduct = VariableProductModel().obs;
  ModelAddReview modelAddReview = ModelAddReview();
  final locationController = Get.put(LocationController());

  String id = Get.arguments;
  String releatedId = "";
  String productID = "";

  Map<String, dynamic> get getMap {
    Map<String, dynamic> map = {};
    map["product_id"] = id.toString();
    map["quantity"] =
        map["quantity"] = int.tryParse(productQuantity.value.toString());
    map["key"] = 'fedexRate';
    map["country_id"] = profileController.model.user!.country_id;

    return map;
  }

  RxStatus statusSingle = RxStatus.empty();
  String formattedDate = "";
  String dateTimeString = "";
  String imageSelect = '';
  final homeController = Get.put(TrendingProductsController());
  double ratingRills = 0.0;
  int ratingRill = 20;
  getProductDetails({BuildContext? context}) {
    // statusSingle = RxStatus.loading();
    Map<String, dynamic> map = {};
    map['product_id'] = id.toString();
    map['key'] = 'fedexRate';
    map["is_def_address"] = homeController.defaultAddressId.toString();
    repositories.postApi(url: ApiUrls.varientsUrl, mapData: map).then((value) {
      log('modelSingleProduct.value1 ${modelSingleProduct.value.toJson()}');
      modelSingleProduct.value =
          VariableProductModel.fromJson(jsonDecode(value));
      log('modelSingleProduct.value ${modelSingleProduct.value.toJson()}');
      if (modelSingleProduct.value.variantProduct != null) {
        log("modelSingleProduct.product!.toJson().....${modelSingleProduct.value.variantProduct!.toJson()}");
        ratingRills = ratingRill *
            double.parse(
                modelSingleProduct.value.variantProduct!.rating.toString());
        imagesList.addAll(
            modelSingleProduct.value.variantProduct!.galleryImage ?? []);
        imagesList = imagesList.toSet().toList();
        if (modelSingleProduct.value.variantProduct!.catId != null &&
            modelSingleProduct.value.variantProduct!.catId!.isNotEmpty) {
          releatedId = modelSingleProduct.value.variantProduct!.catId!.last.id
              .toString();
          productID = modelSingleProduct.value.variantProduct!.id.toString();
        }
//         dateTimeString = modelSingleProduct.value.variantProduct!.shippingDate.toString();
//
// // Parse the string into a DateTime object
//         DateTime dateTime = DateTime.parse(dateTimeString);
//
// // Format the DateTime object to display only the date part
//         formattedDate = "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";

        print("releatedId" + releatedId);
        similarProduct();
        // statusSingle = RxStatus.success();
      } else {
        // statusSingle = RxStatus.empty();
        print('elese call');
      }
      setState(() {});
    });
  }

  //
  addToCartProduct() {
    // if (!validateSlots()) return;
    Map<String, dynamic> map = {};
    map["product_id"] = id.toString();
    map["quantity"] = map["quantity"] = int.tryParse(_counter.toString());
    map["key"] = 'fedexRate';
    map["variation"] = selectedVariant!.id.toString();
    map["country_id"] =
        profileController.model.user != null && cartController.countryId.isEmpty
            ? profileController.model.user!.country_id
            : cartController.countryId.toString();

    repositories
        .postApi(url: ApiUrls.addToCartUrl, mapData: map, context: context)
        .then((value) {
      ModelCommonResponse response =
          ModelCommonResponse.fromJson(jsonDecode(value));
      showToast(response.message.toString());
      if (response.status == true) {
        Get.back();
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
      modelSingleProduct.value.variantProduct!.inWishlist == true;
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
      modelSingleProduct.value.variantProduct!.inWishlist == true;
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
    Map<String, dynamic> map = {};

    map["product_id"] = id.toString();
    map["quantity"] = map["quantity"] = int.tryParse(_counter.toString());
    map["key"] = 'fedexRate';
    map["country_id"] = profileController.model.user != null
        ? profileController.model.user!.country_id
        : '117';
    map["zip_code"] = cartController.zipCode.toString();
    map["variation"] = selectedVariant!.id.toString();
    repositories
        .postApi(url: ApiUrls.buyNowDetailsUrl, mapData: map, context: context)
        .then((value) {
      log("Value>>>>>>>$value");
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

  Rx<ReleatedProductModel> modelRelated = ReleatedProductModel().obs;
  RxBool isDataLoading = false.obs;
  similarProduct() {
    Map<String, dynamic> map = {};
    map["cat_id"] = releatedId.toString();
    map["product_id"] = productID.toString();
    repositories
        .postApi(
      url: ApiUrls.releatedProduct,
      mapData: map,
    )
        .then((value) {
      log("Value>>>>>>>$value");
      print('singleee');
      isDataLoading.value = true;
      modelRelated.value = ReleatedProductModel.fromJson(jsonDecode(value));

      if (modelRelated.value.status == true) {}
    });
  }

  List<String> imagesList = [];
  RxInt currentIndex = 0.obs;
  Variants? selectedVariant;

  @override
  void initState() {
    super.initState();
    getProductDetails();
    log('ggsgsax${id}');
  }

  RxInt productQuantity = 1.obs;
  final cartController = Get.put(CartController());
  CarouselControllerImpl carouselController = CarouselControllerImpl();

  final wishListController = Get.put(WishListController());

  RxBool alreadyReview = false.obs;
  int _counter = 1;

  void incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Size size = Size.zero;
  String pricess = '';
  String descriptionn = '';
  String longDescription = '';
  void decrementCounter() {
    setState(() {
      if (_counter > 1) {
        _counter--;
      }
    });
  }

  final ScrollController _scrollController = ScrollController();

  // Function to scroll to the top
  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 300), // Animation duration
      curve: Curves.easeInOut, // Animation curve
    );
  }

  @override
  void dispose() {
    // Dispose the ScrollController when the widget is disposed
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leadingWidth: 120,
        leading: Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  profileController.selectedLAnguage.value != 'English'
                      ? Image.asset(
                          'assets/images/forward_icon.png',
                          height: 19,
                          width: 19,
                        )
                      : Image.asset(
                          'assets/images/back_icon_new.png',
                          height: 19,
                          width: 19,
                        ),
                ],
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            InkWell(
              onTap: () {},
              child: SvgPicture.asset(
                'assets/svgs/search_icon_new.svg',
                width: 38,
                height: 38,
                // color: Colors.white,
              ),
              // child : Image.asset('assets/images/search_icon_new.png')
            ),
          ],
        ),
        actions: [
          // ...vendorPartner(),
          const CartBagCard(),
          // const Icon(
          //   Icons.more_vert,
          //   color: Color(0xFF014E70),
          // ),
          const SizedBox(
            width: 10,
          )
        ],
        titleSpacing: 0,
      ),
      body: Obx(() {
        return modelSingleProduct.value.variantProduct != null
            ? SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (modelSingleProduct
                                    .value.variantProduct!.discountOff !=
                                '0.00')
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                    color: const Color(0xFFFF6868),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  children: [
                                    Text(
                                      " SALE".tr,
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFFFFDF33)),
                                    ),
                                    Text(
                                      " ${modelSingleProduct.value.variantProduct!.discountOff}${'%'}  ",
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            const Spacer(),

                            Obx(() {
                              if (wishListController.refreshFav.value > 0) {}
                              return LikeButtonCat(
                                onPressed: () {
                                  if (wishListController.favoriteItems
                                      .contains(id.toString())) {
                                    removeFromWishList();
                                  } else {
                                    addToWishList();
                                  }
                                },
                                isLiked: wishListController.favoriteItems
                                    .contains(id.toString()),
                              );
                            }),
                            // Icon(Icons.favorite_border, color: Colors.red,),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        if (imageSelect == '')
                          CarouselSlider(
                            options: CarouselOptions(
                                height: 300,
                                viewportFraction: 1,
                                onPageChanged: (daf, sda) {
                                  currentIndex.value = daf;
                                }),
                            carouselController: carouselController,
                            items: imagesList.map((i) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FullScreenImageViewer(
                                            images: imagesList,
                                            initialIndex: imagesList.indexOf(i),
                                          ),
                                        ),
                                      );
                                    },
                                    child: CachedNetworkImage(
                                        imageUrl: i,
                                        height: 180,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, __, ___) =>
                                            Image.asset(
                                                'assets/images/new_logo.png')),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        if (imageSelect == '')
                          const SizedBox(
                            height: 6,
                          ),
                        if (imageSelect == '')
                          Align(
                            alignment: Alignment.center,
                            child: Obx(() {
                              return AnimatedSmoothIndicator(
                                activeIndex: currentIndex.value,
                                count: imagesList.length,
                                effect: WormEffect(
                                    dotWidth: 10,
                                    dotColor: Colors.grey.shade200,
                                    dotHeight: 10,
                                    activeDotColor: AppTheme.buttonColor),
                              );
                            }),
                          ),
                        if (imageSelect == '')
                          const SizedBox(
                            height: 30,
                          ),
                        // Center(child: Image.asset("assets/svgs/single.png")),
                        if (imageSelect == '')
                          Obx(() => Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 18),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.white,
                                  boxShadow: [
                                    const BoxShadow(
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                        color: Colors.grey)
                                  ],
                                ),
                                child: Text(
                                  "${currentIndex.value + 1}/${imagesList.length}",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                    color: const Color(0xFF014E70),
                                  ),
                                ),
                              )),
                        if (imageSelect != '')
                          Center(
                            child: CachedNetworkImage(
                                imageUrl: imageSelect.toString(),
                                height: 180,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) =>
                                    Image.asset('assets/images/new_logo.png')),
                          ),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                        //   decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(30),
                        //       // border: Border.all(color: Colors.white),
                        //       color: Colors.white,
                        //       boxShadow: [const BoxShadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.grey)]),
                        //   child: Text(
                        //     "1/10",
                        //     style: GoogleFonts.poppins(
                        //         fontWeight: FontWeight.w500, fontSize: 10, color: const Color(0xFF014E70)),
                        //   ),
                        // ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          modelSingleProduct.value.variantProduct!.pname
                              .toString()
                              .capitalize!,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: const Color(0xFF19313C)),
                        ),
                        if (descriptionn != '')
                          Text(
                            descriptionn.toString(),
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: const Color(0xFF19313C)),
                          ),
                        if (descriptionn == '')
                          Text(
                            modelSingleProduct
                                .value.variantProduct!.shortDescription
                                .toString()
                                .capitalize!,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: const Color(0xFF19313C)),
                          ),

                        const SizedBox(
                          height: 6,
                        ),

                        Row(
                          children: [
                            if (modelSingleProduct
                                    .value.variantProduct!.discountOff !=
                                '0.00')
                              Expanded(
                                child: Text(
                                  'KWD ${modelSingleProduct.value.variantProduct!.pPrice.toString()}',
                                  style: GoogleFonts.poppins(
                                      decorationColor: Colors.red,
                                      decorationThickness: 2,
                                      decoration: TextDecoration.lineThrough,
                                      color: const Color(0xff19313B),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            const SizedBox(width: 7),
                            if (pricess != '')
                              Text(
                                'KWD ${pricess.toString()}',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF19313B)),
                              ),
                            if (pricess == '')
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text:
                                        '${modelSingleProduct.value.variantProduct!.discountPrice.toString().split('.')[0]}.',
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF19313B)),
                                    children: [
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'KWD',
                                              style: TextStyle(
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF19313B)),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                print("date:::::::::::" +
                                                    modelSingleProduct
                                                        .value
                                                        .variantProduct!
                                                        .shippingDate
                                                        .toString());
                                              },
                                              child: Text(
                                                '${modelSingleProduct.value.variantProduct!.discountPrice.toString().split('.')[1]}',
                                                style: const TextStyle(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF19313B)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        modelSingleProduct.value.variantProduct!.rating == '0'
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  modelSingleProduct
                                              .value.variantProduct!.rating !=
                                          '0'
                                      ? RatingBar.builder(
                                          initialRating: double.parse(
                                              modelSingleProduct
                                                  .value.variantProduct!.rating
                                                  .toString()),
                                          minRating: 1,
                                          direction: Axis.horizontal,
                                          updateOnDrag: true,
                                          tapOnlyMode: false,
                                          ignoreGestures: true,
                                          allowHalfRating: true,
                                          itemSize: 20,
                                          itemCount: 5,
                                          itemBuilder: (context, _) =>
                                              const Icon(
                                            Icons.star,
                                            size: 8,
                                            color: Colors.amber,
                                          ),
                                          onRatingUpdate: (rating) {
                                            print(rating);
                                          },
                                        )
                                      : const SizedBox.shrink(),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  // Image.asset("assets/svgs/rils.png"),
                                  modelSingleProduct
                                              .value.variantProduct!.rating !=
                                          '0'
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'RILS'.tr,
                                              style: TextStyle(
                                                  color: AppTheme.buttonColor,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(ratingRills.toString())
                                          ],
                                        )
                                      : const SizedBox.shrink()
                                ],
                              )
                            : Text('No reviews'.tr),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          height: 28,
                          child: ListView.builder(
                            itemCount: modelSingleProduct
                                .value.variantProduct!.catId!.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 7, horizontal: 37),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF014E70)
                                          .withOpacity(.07),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      modelSingleProduct.value.variantProduct!
                                          .catId![index].title
                                          .toString(),
                                      style: GoogleFonts.poppins(
                                          color: const Color(0xFF014E70),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  )
                                ],
                              );
                            },
                          ),
                        ),

                        Text(
                          'Variants'.tr,
                          style: normalStyle,
                        ),
                        if (modelSingleProduct.value.variantProduct != null)
                          DropdownButtonFormField(
                            value: selectedVariant,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                enabled: true,
                                enabledBorder: InputBorder.none,
                                fillColor: Colors.grey.shade100,
                                filled: true,
                                hintText: "Select Variant".tr,
                                hintStyle: normalStyle),
                            validator: (value) {
                              if (selectedVariant == null) {
                                return "Please select variation".tr;
                              }
                              return null;
                            },
                            items: modelSingleProduct
                                .value.variantProduct!.variants!
                                .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Row(
                                      children: [
                                        Flexible(
                                            child: Image.network(
                                          e.image.toString(),
                                          width: 50,
                                        )),
                                        5.spaceX,
                                        Expanded(
                                            child: Text(
                                                e.comb.toString().capitalize!)),
                                        Expanded(child: Text("kwd ${e.price}")),
                                        Expanded(
                                            child: Text(
                                                "${"Stock".tr} ${e.variantStock}")),
                                        const SizedBox(
                                          width: 4,
                                        )
                                      ],
                                    )))
                                .toList(),
                            onChanged: (newValue) {
                              if (newValue == null) return;
                              selectedVariant = newValue;
                              pricess = newValue.price.toString();
                              descriptionn =
                                  newValue.variantShortDescription.toString();
                              imageSelect = newValue.image.toString();
                              longDescription =
                                  newValue.variantLongDescription.toString();
                              carouselController.animateToPage(
                                  imagesList.indexWhere((element) =>
                                      element.toString() ==
                                      selectedVariant!.image.toString()));

                              setState(() {});
                            },
                          ),

                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Description".tr,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: const Color(0xFF014E70)),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        if (modelSingleProduct
                                    .value.variantProduct!.longDescription !=
                                '' &&
                            modelSingleProduct
                                    .value.variantProduct!.longDescription !=
                                null &&
                            longDescription == '')
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.circle,
                                color: Colors.grey,
                                size: 10,
                              ),
                              const SizedBox(
                                width: 7,
                              ),
                              Expanded(
                                child: Text(
                                  modelSingleProduct.value.variantProduct!
                                          .longDescription ??
                                      '',
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        if (longDescription != '')
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.circle,
                                color: Colors.grey,
                                size: 10,
                              ),
                              const SizedBox(
                                width: 7,
                              ),
                              Expanded(
                                child: Text(
                                  longDescription.toString(),
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              color: Colors.grey,
                              size: 10,
                            ),
                            const SizedBox(
                              width: 7,
                            ),
                            Text(
                              'Shipping Type : '.tr,
                              style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                            Expanded(
                              child: Text(
                                modelSingleProduct
                                    .value.variantProduct!.shippingDate
                                    .toString(),
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFf014E70),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Text(
                              'Quantity : '.tr,
                              style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(
                                Icons.remove,
                                color: Color(0xFF014E70),
                              ),
                              onPressed: decrementCounter,
                            ),
                            Text(
                              '$_counter',
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFF014E70),
                                  fontSize: 26,
                                  fontWeight: FontWeight.w500),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add,
                                color: Color(0xFF014E70),
                              ),
                              // onPressed: incrementCounter,
                              onPressed: () {
                                int inStock = int.tryParse(modelSingleProduct
                                        .value.variantProduct!.inStock) ??
                                    0;
                                if (inStock == 0) {
                                  showToastCenter('Product out of stock'.tr);
                                } else if (_counter >= inStock) {
                                  showToastCenter('Product out of stock'.tr);
                                } else {
                                  setState(() {
                                    _counter++;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),

                        const SizedBox(
                          height: 20,
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Expanded(
                        //       child: InkWell(
                        //         onTap: () {
                        //           if(selectedVariant != null) {
                        //             cartController.productElementId =  id.toString();
                        //             cartController.productQuantity = productQuantity.value.toString();
                        //             directBuyProduct();
                        //           }else{
                        //             showToastCenter('Please select variation'.tr);
                        //           }
                        //         },
                        //         child: Container(
                        //           padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                        //           decoration: BoxDecoration(
                        //             border: Border.all(color: Colors.red),
                        //             borderRadius: BorderRadius.circular(20),
                        //           ),
                        //           child: Center(
                        //             child: Text(
                        //               "Buy Now".tr,
                        //               style:
                        //                   GoogleFonts.poppins(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //     SizedBox(width: 10,),
                        //     Expanded(
                        //       child: InkWell(
                        //         onTap: () {
                        //           if(selectedVariant != null) {
                        //             addToCartProduct();
                        //           }else{
                        //             showToastCenter('Please select variation'.tr);
                        //           }
                        //         },
                        //         child: Container(
                        //           padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                        //           decoration: BoxDecoration(
                        //             color: const Color(0xFF014E70),
                        //             border: Border.all(
                        //               color: const Color(0xFF014E70),
                        //             ),
                        //             borderRadius: BorderRadius.circular(20),
                        //           ),
                        //           child: Text(
                        //             "ADD TO CART".tr,
                        //             style: GoogleFonts.poppins(
                        //                 color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        Row(
                          children: [
                            Expanded(
                              child: profileController.selectedLAnguage.value ==
                                      "English"
                                  ? ElevatedButton(
                                      onPressed: () {
                                        cartController.productElementId =
                                            id.toString();
                                        cartController.productQuantity =
                                            productQuantity.value.toString();
                                        directBuyProduct();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        surfaceTintColor: Colors.red,
                                        minimumSize: const Size(double.infinity,
                                            40), // Use double.infinity for full width
                                      ),
                                      child: FittedBox(
                                        child: Text(
                                          "  Buy Now  ".tr,
                                          style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white),
                                        ),
                                      ),
                                    )
                                  : SizedBox(
                                      width: 130,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          cartController.productElementId =
                                              id.toString();
                                          cartController.productQuantity =
                                              productQuantity.value.toString();
                                          directBuyProduct();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          surfaceTintColor: Colors.red,
                                        ),
                                        child: FittedBox(
                                          child: Text(
                                            "  Buy Now  ".tr,
                                            style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                            SizedBox(
                                width:
                                    8), // Optional: Adds space between the buttons
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  addToCartProduct();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.buttonColor,
                                  surfaceTintColor: AppTheme.buttonColor,
                                  minimumSize: const Size(double.infinity,
                                      40), // Use double.infinity for full width
                                ),
                                child: FittedBox(
                                  child: Text(
                                    "Add to Cart".tr,
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
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Specifications'.tr,
                          style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          height: 16,
                        ),

                        Row(
                          children: [
                            Text(
                              'SKU :'.tr,
                              style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            const Icon(
                              Icons.circle,
                              color: Colors.grey,
                              size: 6,
                            ),
                            const SizedBox(
                              width: 7,
                            ),
                            Text(
                              modelSingleProduct
                                  .value.variantProduct!.serialNumber
                                  .toString(),
                              style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Divider(
                          color: Colors.grey.withOpacity(.5),
                          thickness: 1,
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        Text(
                          'Delivery'.tr,
                          style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Row(
                          children: [
                            Text(
                              'Your Location :'.tr,
                              style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            const Icon(
                              Icons.circle,
                              color: Color(0xFF014E70),
                              size: 6,
                            ),
                            const SizedBox(
                              width: 7,
                            ),
                            Expanded(
                              child: Text(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                locationController.city.toString(),
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF014E70),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              'Standard Delivery :'.tr,
                              style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            const Icon(
                              Icons.circle,
                              color: Color(0xFF014E70),
                              size: 6,
                            ),
                            const SizedBox(
                              width: 7,
                            ),
                            Expanded(
                              child: Text(
                                //  formattedDate.toString(),
                                modelSingleProduct
                                    .value.variantProduct!.shippingDate
                                    .toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF014E70),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery Charges :'.tr,
                              style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            const Icon(
                              Icons.circle,
                              color: Color(0xFF014E70),
                              size: 6,
                            ),
                            const SizedBox(
                              width: 7,
                            ),
                            Expanded(
                              child: Text(
                                modelSingleProduct.value.variantProduct!
                                            .lowestDeliveryPrice ==
                                        ""
                                    ? "0"
                                    : modelSingleProduct.value.variantProduct!
                                        .lowestDeliveryPrice
                                        .toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF014E70),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Divider(
                          color: Colors.grey.withOpacity(.5),
                          thickness: 1,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Seller information'.tr,
                          style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                modelSingleProduct
                                    .value.variantProduct!.storemeta!.storeName
                                    .toString(),
                                style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            if (modelSingleProduct.value.variantProduct!
                                    .storemeta!.verifyBatch ==
                                true)
                              Image.asset(
                                "assets/svgs/verified.png",
                                width: 100,
                              )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),

                        Row(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Seller id :'.tr,
                              style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              child: Text(
                                modelSingleProduct
                                    .value.variantProduct!.storemeta!.storeId
                                    .toString(),
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF014E70),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            // Image.asset("assets/svgs/pak.png"),

                            Text(
                              modelSingleProduct.value.variantProduct!
                                  .storemeta!.storeLocation
                                  .toString(),
                              style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            Text(
                              modelSingleProduct.value.variantProduct!
                                  .storemeta!.storeCategory
                                  .toString(),
                              style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 13,
                        ),

                        const SizedBox(
                          height: 10,
                        ),
                        // Divider(
                        //   color: Colors.grey.withOpacity(.5),
                        //   thickness: 1,
                        // ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Seller documents'.tr,
                          style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        modelSingleProduct.value.variantProduct!.storemeta!
                                    .commercialLicense !=
                                ""
                            ? Center(
                                child: CachedNetworkImage(
                                  imageUrl: modelSingleProduct
                                      .value
                                      .variantProduct!
                                      .storemeta!
                                      .commercialLicense
                                      .toString(),
                                  height: 180,
                                  fit: BoxFit.cover,
                                  // errorWidget: (_, __, ___) => Image.asset('assets/images/new_logo.png')
                                ),
                              )
                            : Center(
                                child: Text(
                                  'No documents were uploaded by vendor '.tr,
                                  style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                        // Center(child: Image.asset("assets/svgs/licence.png")),

                        const SizedBox(
                          height: 25,
                        ),
                        Text(
                          'Seller translated documents'.tr,
                          style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        modelSingleProduct.value.variantProduct!.storemeta!
                                    .document2 !=
                                ""
                            ? Center(
                                child: CachedNetworkImage(
                                  imageUrl: modelSingleProduct.value
                                      .variantProduct!.storemeta!.document2
                                      .toString(),
                                  height: 180,
                                  fit: BoxFit.cover,
                                  // errorWidget: (_, __, ___) => Image.asset('assets/images/new_logo.png')
                                ),
                              )
                            : Center(
                                child: Text(
                                  'No documents were uploaded by vendor '.tr,
                                  style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => SingleStoreScreen(
                                storeDetails: VendorStoreData(
                                    id: modelSingleProduct.value.variantProduct!
                                        .vendorInformation!.storeId)));
                          },
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 130,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFF014E70),
                                      width: 1.5),
                                  borderRadius: BorderRadius.circular(30)),
                              child: Center(
                                child: Text(
                                  "Seller profile".tr,
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xFF014E70),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // const SizedBox(
                        //   height: 20,
                        // ),
                        // GestureDetector(
                        //   onTap: (){
                        //     Get.to(
                        //             () => SingleStoreScreen(storeDetails:  VendorStoreData(id:
                        //         modelSingleProduct.value.variantProduct!.vendorInformation!.storeId
                        //         ))
                        //     );
                        //   },
                        //   child: Align(
                        //     alignment: Alignment.centerRight,
                        //     child: Container(
                        //       width: 130,
                        //       padding: const EdgeInsets.all(10),
                        //       decoration: BoxDecoration(
                        //           border: Border.all(color: const Color(0xFF014E70), width: 1.5),
                        //           borderRadius: BorderRadius.circular(30)),
                        //       child: Center(
                        //         child: Text(
                        //           "Take Below",
                        //           style: GoogleFonts.poppins(
                        //               color: const Color(0xFF014E70), fontSize: 14, fontWeight: FontWeight.w500),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),

                        const SizedBox(
                          height: 10,
                        ),
                        Divider(
                          color: Colors.grey.withOpacity(.5),
                          thickness: 1,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        modelRelated.value.relatedProduct != null
                            ? Text(
                                'Similar products'.tr,
                                style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600),
                              )
                            : const SizedBox(),

                        Obx(() {
                          if (isDataLoading.value == false) {
                            return const Center(
                              child: LoadingAnimation(),
                            );
                          }
                          if (modelRelated.value.relatedProduct == null) {
                            return Center(
                              child: Text(
                                'No Similar products'.tr,
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }
                          return modelRelated.value.relatedProduct != null
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: modelRelated
                                      .value.relatedProduct!.product!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    var item = modelRelated
                                        .value.relatedProduct!.product![index];
                                    return GestureDetector(
                                      onTap: () {
                                        log('dasdadadad ${item.itemType}');
                                        if (item.itemType == 'giveaway') {
                                          Get.to(() => const GiveAwayProduct(),
                                              arguments: item.id.toString());
                                        } else if (item.productType ==
                                                'variants' &&
                                            item.itemType == 'product') {
                                          imagesList.clear();
                                          id = item.id.toString();
                                          getProductDetails(context: context);
                                          _scrollToTop();
                                          Get.to(
                                              () =>
                                                  const VarientsProductScreen(),
                                              arguments: item.id.toString());
                                        } else if (item.productType ==
                                                'booking' &&
                                            item.itemType == 'product') {
                                          Get.to(
                                              () =>
                                                  const BookableProductScreen(),
                                              arguments: item.id.toString());
                                        } else if (item.productType ==
                                                'virtual_product' &&
                                            item.itemType ==
                                                'virtual_product') {
                                          Get.to(() => VritualProductScreen(),
                                              arguments: item.id.toString());
                                        } else if (item.itemType == 'product') {
                                          Get.to(
                                              () => const SimpleProductScreen(),
                                              arguments: item.id.toString());
                                        } else if (item.itemType == 'service') {
                                          Get.to(
                                              () =>
                                                  const ServiceProductScreen(),
                                              arguments: item.id.toString());
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: const BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  blurStyle: BlurStyle.outer,
                                                  offset: Offset(1, 1),
                                                  color: Colors.black12,
                                                  blurRadius: 3,
                                                )
                                              ]),
                                          constraints: BoxConstraints(
                                            minWidth: 0,
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .8,
                                          ),
                                          margin:
                                              const EdgeInsets.only(right: 9),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  if (item.discountOff !=
                                                      '0.00')
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
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
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: const Color(
                                                                    0xFFFFDF33)),
                                                          ),
                                                          Text(
                                                            " ${item.discountOff}${'%'}  ",
                                                            style: GoogleFonts
                                                                .poppins(
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
                                                    ),
                                                  Obx(() {
                                                    if (wishListController
                                                            .refreshFav.value >
                                                        0) {}
                                                    return LikeButtonCat(
                                                      onPressed: () {
                                                        if (wishListController
                                                            .favoriteItems
                                                            .contains(item.id
                                                                .toString())) {
                                                          removeFromWishList();
                                                        } else {
                                                          addToWishList();
                                                        }
                                                      },
                                                      isLiked:
                                                          wishListController
                                                              .favoriteItems
                                                              .contains(item.id
                                                                  .toString()),
                                                    );
                                                  }),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Center(
                                                      child: CachedNetworkImage(
                                                        imageUrl: item
                                                            .featuredImage
                                                            .toString(),
                                                        height: 200,
                                                        fit: BoxFit.contain,
                                                        errorWidget: (_, __,
                                                                ___) =>
                                                            Image.asset(
                                                                'assets/images/new_logo.png'),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                item.pname.toString(),
                                                maxLines: 2,
                                                style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: const Color(
                                                        0xFF19313C)),
                                              ),
                                              const SizedBox(height: 3),
                                              if (item.itemType != 'giveaway')
                                                Row(
                                                  children: [
                                                    if (item.discountOff !=
                                                        '0.00')
                                                      Expanded(
                                                        child: Text(
                                                          'KWD ${item.pPrice.toString()}',
                                                          style: GoogleFonts.poppins(
                                                              decorationColor:
                                                                  Colors.red,
                                                              decorationThickness:
                                                                  2,
                                                              decoration:
                                                                  TextDecoration
                                                                      .lineThrough,
                                                              color: const Color(
                                                                  0xff19313B),
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      ),
                                                    const SizedBox(width: 7),
                                                    Expanded(
                                                      child: Text.rich(
                                                        TextSpan(
                                                          text:
                                                              '${item.discountPrice.toString().split('.')[0]}.',
                                                          style: const TextStyle(
                                                              fontSize: 24,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Color(
                                                                  0xFF19313B)),
                                                          children: [
                                                            WidgetSpan(
                                                              alignment:
                                                                  PlaceholderAlignment
                                                                      .middle,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  const Text(
                                                                    'KWD',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            8,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Color(
                                                                            0xFF19313B)),
                                                                  ),
                                                                  InkWell(
                                                                    onTap: () {
                                                                      print("date:::::::::::" +
                                                                          item.shippingDate
                                                                              .toString());
                                                                    },
                                                                    child: Text(
                                                                      '${item.discountPrice.toString().split('.')[1]}',
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              8,
                                                                          fontWeight: FontWeight
                                                                              .w600,
                                                                          color:
                                                                              Color(0xFF19313B)),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              const SizedBox(height: 8),
                                              if (item.inStock != "-1")
                                                Text(
                                                  '${'QTY'.tr}: ${item.inStock} ${'piece'.tr}',
                                                  style: normalStyle,
                                                ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(item.shortDescription),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
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
                                                        RatingBar.builder(
                                                          initialRating:
                                                              double.parse(item
                                                                  .rating
                                                                  .toString()),
                                                          minRating: 1,
                                                          direction:
                                                              Axis.horizontal,
                                                          updateOnDrag: true,
                                                          tapOnlyMode: false,
                                                          ignoreGestures: true,
                                                          allowHalfRating: true,
                                                          itemSize: 20,
                                                          itemCount: 5,
                                                          itemBuilder:
                                                              (context, _) =>
                                                                  const Icon(
                                                            Icons.star,
                                                            size: 8,
                                                            color: Colors.amber,
                                                          ),
                                                          onRatingUpdate:
                                                              (rating) {
                                                            print(rating);
                                                          },
                                                        ),
                                                        const SizedBox(
                                                            height: 7),
                                                        if (item.shippingDate !=
                                                            "No International Shipping Available")
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'shipping'.tr,
                                                                style: GoogleFonts.poppins(
                                                                    color: const Color(
                                                                        0xff858484),
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                              if (item.lowestDeliveryPrice !=
                                                                  null)
                                                                Text(
                                                                  'KWD${item.lowestDeliveryPrice.toString()}',
                                                                  style: GoogleFonts.poppins(
                                                                      color: const Color(
                                                                          0xff858484),
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              if (item.shippingDate !=
                                                                  null)
                                                                Text(
                                                                  item.shippingDate
                                                                      .toString(),
                                                                  maxLines: 2,
                                                                  style: GoogleFonts.poppins(
                                                                      color: const Color(
                                                                          0xff858484),
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                            ],
                                                          )
                                                        else
                                                          GestureDetector(
                                                            onTap: () {
                                                              Get.to(() =>
                                                                  const ContactUsScreen());
                                                            },
                                                            child: RichText(
                                                              text: TextSpan(
                                                                  text:
                                                                      'international shipping not available'
                                                                          .tr,
                                                                  style: GoogleFonts.poppins(
                                                                      color: const Color(
                                                                          0xff858484),
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                  children: [
                                                                    TextSpan(
                                                                        text: ' contact us'
                                                                            .tr,
                                                                        style: GoogleFonts.poppins(
                                                                            decoration: TextDecoration
                                                                                .underline,
                                                                            color: AppTheme
                                                                                .buttonColor,
                                                                            fontSize:
                                                                                13,
                                                                            fontWeight:
                                                                                FontWeight.w500)),
                                                                    TextSpan(
                                                                        text: ' for the solution'
                                                                            .tr,
                                                                        style: GoogleFonts.poppins(
                                                                            color: const Color(
                                                                                0xff858484),
                                                                            fontSize:
                                                                                13,
                                                                            fontWeight:
                                                                                FontWeight.w500)),
                                                                  ]),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      children: [
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            cartController
                                                                    .productElementId =
                                                                id.toString();
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
                                                                Colors.red,
                                                            surfaceTintColor:
                                                                Colors.red,
                                                          ),
                                                          child: FittedBox(
                                                            child: Text(
                                                              "  Buy Now  ".tr,
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () {
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
                                                          child: FittedBox(
                                                            child: Text(
                                                              "Add to Cart".tr,
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: Text(
                                    'No Similar products'.tr,
                                    style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600),
                                  ),
                                );
                        })
                      ],
                    )),
              )
            : const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
