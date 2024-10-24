import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dirise/single_products/variable_single.dart';
import 'package:dirise/single_products/vritual_product_single.dart';
import 'package:dirise/utils/helper.dart';
import 'package:dirise/widgets/loading_animation.dart';
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
import '../language/app_strings.dart';
import '../model/add_review_model.dart';
import '../model/common_modal.dart';

// import '../model/filter_by_price_model.dart';
import '../model/get_review_model.dart';
import '../model/giveaway_single_model.dart';
import '../model/model_category_stores.dart';
import '../model/model_single_product.dart';
import '../model/order_models/model_direct_order_details.dart';
import '../model/product_model/model_product_element.dart';
import '../model/releated_product_model.dart';
import '../model/simple_product_model.dart';
import '../repository/repository.dart';
import '../screens/auth_screens/login_screen.dart';
import '../screens/categories/single_category_with_stores/single_store_screen.dart';
import '../screens/check_out/direct_check_out.dart';
import '../screens/my_account_screens/contact_us_screen.dart';
import '../screens/product_details/fullScreenImageViewer.dart';
import '../screens/search_products.dart';
import '../screens/service_single_ui.dart';
import '../utils/api_constant.dart';
import '../utils/styles.dart';
import '../widgets/cart_widget.dart';
import '../widgets/common_colour.dart';
import '../widgets/like_button.dart';
import 'bookable_single.dart';
import 'give_away_single.dart';

class SimpleProductScreen extends StatefulWidget {
  const SimpleProductScreen({super.key});
  // final SingleGiveawayProduct productDetails;
  @override
  State<SimpleProductScreen> createState() => _SimpleProductScreenState();
}

class _SimpleProductScreenState extends State<SimpleProductScreen> {
  final Repositories repositories = Repositories();

  // SingleGiveawayProduct productElement = SingleGiveawayProduct();
  TextEditingController reviewController = TextEditingController();
  final profileController = Get.put(ProfileController());

  // ProductElement get productDetails => productElement;
  Rx<SimpleProductModel> modelSingleProduct = SimpleProductModel().obs;
  ModelAddReview modelAddReview = ModelAddReview();
  final locationController = Get.put(LocationController());

  // bool get isBookingProduct =>  modelSingleProduct.singleGiveawayProduct!.productType == "booking";
  //
  // bool get isVirtualProduct =>  modelSingleProduct.singleGiveawayProduct!.productType == "virtual_product";
  //
  // bool get isVariantType =>  modelSingleProduct.singleGiveawayProduct!.productType == "variants";

  // bool get isVirtualProductAudio => productElement.virtualProductType == "voice";

  // bool get canBuyProduct => productElement.addToCart == true;
  // String dropdownvalue1 = 'red';
  // String dropdownvalue2 = 'l';
  // var items1 = [
  //   'red',
  //   'black',
  //   'white',
  // ];
  // var items2 = [
  //   'l',
  //   'M',
  // ];

  // String selectedSlot = "";
  // final TextEditingController selectedDate = TextEditingController();
  // DateTime selectedDateTime = DateTime.now();
  // final formKey = GlobalKey<FormState>();
  //
  // final DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  // final GlobalKey slotKey = GlobalKey();
  //
  // bool showValidation = false;

  // bool validateSlots() {
  //   if (showValidation == false) {
  //     showValidation = true;
  //     setState(() {});
  //   }
  //   // if (!formKey.currentState!.validate()) {
  //   //   selectedDate.checkEmpty;
  //   //   return false;
  //   // }
  //   // if (isBookingProduct) {
  //   //   if (modelSingleProduct.singleGiveawayProduct == null) {
  //   //     showToast("Please wait loading available slots");
  //   //     return false;
  //   //   }
  //   //   if (modelSingleProduct.singleGiveawayProduct!.serviceTimeSloat == null) {
  //   //     showToast("Slots are not available");
  //   //     return false;
  //   //   }
  //   //   if (selectedSlot.isEmpty) {
  //   //     slotKey.currentContext!.navigate;
  //   //     showToast("Please select slot");
  //   //     return false;
  //   //   }
  //   //   return true;
  //   // }
  //   // if (isVariantType) {
  //   //   if (selectedVariant == null) {
  //   //     showToast("Please select variation");
  //   //     return false;
  //   //   }
  //   // }
  //   return true;
  // }

  // pickDate({required Function(DateTime gg) onPick, DateTime? initialDate, DateTime? firstDate, DateTime? lastDate}) async {
  //   DateTime lastD = lastDate ?? DateTime(2101);
  //   DateTime initialD = initialDate ?? firstDate ?? DateTime.now();
  //
  //   if (lastD.isBefore(firstDate ?? DateTime.now())) {
  //     lastD = firstDate ?? DateTime.now();
  //   }
  //
  //   if (initialD.isAfter(lastD)) {
  //     initialD = lastD;
  //   }
  //
  //   if (initialD.isBefore(firstDate ?? DateTime.now())) {
  //     initialD = firstDate ?? DateTime.now();
  //   }
  //
  //   DateTime? pickedDate = await showDatePicker(
  //       context: context,
  //       initialDate: initialD,
  //       firstDate: firstDate ?? DateTime.now(),
  //       lastDate: lastD,
  //       initialEntryMode: DatePickerEntryMode.calendarOnly);
  //   if (pickedDate == null) return;
  //   onPick(pickedDate);
  //   // updateValues();
  // }

  String id = Get.arguments;
  String releatedId = "";
  String productId = "";

  Map<String, dynamic> get getMap {
    Map<String, dynamic> map = {};
    map["product_id"] = id.toString();
    map["quantity"] =
        map["quantity"] = int.tryParse(productQuantity.value.toString());
    map["key"] = 'fedexRate';
    map["country_id"] = profileController.model.user!.country_id;

    // if (isBookingProduct) {
    //   map["start_date"] = selectedDate.text.trim();
    //   map["time_sloat"] = selectedSlot.split("--").first;
    //   map["sloat_end_time"] = selectedSlot.split("--").last;
    // }
    // if (isVariantType) {
    //   map["variation"] = selectedVariant!.id.toString();
    // }
    return map;
  }

  final homeController = Get.put(TrendingProductsController());
  RxStatus statusSingle = RxStatus.empty();
  String formattedDate = "";
  String dateTimeString = "";
  double ratingRills = 0.0;
  int ratingRill = 20;

  getProductDetails({BuildContext? context}) {
    statusSingle = RxStatus.loading();
    repositories
        .postApi(context: context, url: ApiUrls.simpleProductUrl, mapData: {
      "product_id": id.toString(),
      "key": 'fedexRate',
      "is_def_address": homeController.defaultAddressId.toString()
    }).then((value) {
      //log('value of data${jsonDecode(value)}');
      modelSingleProduct.value = SimpleProductModel.fromJson(jsonDecode(value));
      if (modelSingleProduct.value.simpleProduct != null) {
        log("modelSingleProduct.product!.toJson().....${modelSingleProduct.value.simpleProduct!.toJson()}");
        imagesList
            .addAll(modelSingleProduct.value.simpleProduct!.galleryImage ?? []);
        imagesList = imagesList.toSet().toList();
        if (modelSingleProduct.value.simpleProduct!.catId != null &&
            modelSingleProduct.value.simpleProduct!.catId!.isNotEmpty) {
          releatedId =
              modelSingleProduct.value.simpleProduct!.catId!.last.id.toString();
          productId = modelSingleProduct.value.simpleProduct!.id.toString();
        }

        // dateTimeString = modelSingleProduct.value.simpleProduct!.shippingDate.toString();

// Parse the string into a DateTime object
//         DateTime dateTime = DateTime.parse(dateTimeString);

// Format the DateTime object to display only the date part
//         formattedDate = "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";

        print("releatedId" + releatedId);
        similarProduct();
        statusSingle = RxStatus.success();
        ratingRills = ratingRill *
            double.parse(
                modelSingleProduct.value.simpleProduct!.rating.toString());
      } else {
        statusSingle = RxStatus.empty();
      }
      setState(() {});
    });

    //     .catchError((error) {
    //   statusSingle = RxStatus.error(error.toString());
    //   setState(() {});
    // });
  }

  //
  addToCartProduct({int? counter,String? sid}) {
    // if (!validateSlots()) return;
    Map<String, dynamic> map = {};
    map["product_id"] = sid??id.toString();
    map["quantity"] =
        map["quantity"] = counter ?? int.tryParse(_counter.toString());
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
        Get.back();
        cartController.getCart();
      }
    });
  }

  //

  addToWishList() {
    repositories
        .postApi(
            url: ApiUrls.addToWishListUrl,
            mapData: {
              "product_id": id.toString(),
            },
            context: context)
        .then((value) {
      modelSingleProduct.value.simpleProduct!.inWishlist == true;
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
      modelSingleProduct.value.simpleProduct!.inWishlist == true;
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

  directBuyProduct({int? counter, String? sid}) {
    // if (!validateSlots()) return;
    Map<String, dynamic> map = {};

    // cartController.isVariantType = isVariantType;
    // if (isVariantType) {
    //   cartController.selectedVariant = selectedVariant!.id.toString();
    // }
     log('id is id $id and sid$sid');
    map["product_id"] = sid?? id.toString();
   
    map["quantity"] =
        map["quantity"] = counter ?? int.tryParse(_counter.toString());
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
    print(releatedId);
    // if (!validateSlots()) return;
    Map<String, dynamic> map = {};

    // cartController.isVariantType = isVariantType;
    // if (isVariantType) {
    //   cartController.selectedVariant = selectedVariant!.id.toString();
    // }
    map["cat_id"] = releatedId.toString();
    map["product_id"] = productId.toString();

    // if (isBookingProduct) {
    //   map["start_date"] = selectedDate.text.trim();
    //   map["time_sloat"] = selectedSlot.split("--").first;
    //   map["sloat_end_time"] = selectedSlot.split("--").last;
    // }
    // if (isVariantType) {
    //   map["variation"] = selectedVariant!.id.toString();
    // }
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

  final RxBool search = false.obs;
  List<String> imagesList = [];
  RxInt currentIndex = 0.obs;
  RxInt currentIndex1 = 1.obs;
  Variants? selectedVariant;

  @override
  void initState() {
    super.initState();
    // id = Get.arguments[0];
    print(id);
    // productElement = widget.productDetails;
    // imagesList.add(productElement.featuredImage.toString());
    // imagesList.addAll(productElement.galleryImage ?? []);
    getProductDetails();
  }

  RxInt productQuantity = 1.obs;
  final cartController = Get.put(CartController());

  // bool get checkLoaded => modelSingleProduct.singleGiveawayProduct!.pname != null;

  CarouselSliderController carouselController = CarouselSliderController();

  final wishListController = Get.put(WishListController());

  //
  // Future getPublishPostData() async {
  //   repositories.getApi(url: ApiUrls.releatedProduct + releatedId.toString()).then((value) {
  //     modelGetReview.value = ReleatedProductModel .fromJson(jsonDecode(value));
  //   });
  // }

  RxBool alreadyReview = false.obs;

  // final profileController = Get.put(ProfileController());
  int _counter = 1;

  void incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Size size = Size.zero;

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
    // log('data out item is ${modelSingleProduct.value.simpleProduct.toString()}');
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
                width: 28,
                height: 28,
                // color: Colors.white,
              ),
              // child : Image.asset('assets/images/search_icon_new.png')
            ),
          ],
        ),
        actions: const [
          // ...vendorPartner(),
          CartBagCard(),
          // Icon(
          //   Icons.more_vert,
          //   color: Color(0xFF014E70),
          // ),
          SizedBox(
            width: 10,
          )
        ],
        titleSpacing: 0,
        bottom: PreferredSize(
          preferredSize: search.value == true
              ? Size.fromHeight(50.0)
              : Size.fromHeight(0.0),
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
              : SizedBox.shrink(),
        ),
      ),
      body: Obx(() {
        return modelSingleProduct.value.simpleProduct != null
            ? SingleChildScrollView(
                controller: _scrollController,
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (modelSingleProduct
                                    .value.simpleProduct!.discountOff !=
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
                                      " ${modelSingleProduct.value.simpleProduct!.discountOff}${'%'}  ",
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            // Container(
                            //   padding: EdgeInsets.symmetric(vertical: 7, horizontal: 25),
                            //   decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(30),
                            //       border: Border.all(color: Color(0xFFFFDF33)),
                            //       color: Color(0xFFFFDF33).withOpacity(.25)),
                            //   child: Text(
                            //     "Free",
                            //     style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 11, color: Colors.black),
                            //   ),
                            // ),
                            const Spacer(),
                            // Text(
                            //   "512 ",
                            //   style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12, color: Color(0xFf000000)
                            //       .withOpacity(.50)),
                            //
                            // ),
                            Obx(() {
                              if (wishListController.refreshFav.value > 0) {}
                              return LikeButtonCat(
                                onPressed: () {
                                  if (wishListController.favoriteItems
                                      .contains(id.toString())) {
                                    removeFromWishList();
                                  } else {
                                    if (profileController.userLoggedIn) {
                                      addToWishList();
                                      setState(() {});
                                    } else {
                                      Get.to(const LoginScreen());
                                    }
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
                        CarouselSlider(
                          options: CarouselOptions(
                              height: 300,
                              viewportFraction: 1,
                              onPageChanged: (daf, sda) {
                                currentIndex.value = daf;
                                currentIndex1.value = daf + 1;
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
                                      height: 300,
                                      fit: BoxFit.contain,
                                      errorWidget: (_, __, ___) => Image.asset(
                                          'assets/images/new_logo.png')),
                                );
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
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
                        const SizedBox(
                          height: 30,
                        ),
                        // Center(child: Image.asset("assets/svgs/single.png")),
                        Obx(() => Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 18),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
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
                                  color: Color(0xFF014E70),
                                ),
                              ),
                            )),
                        // SizedBox(height: 20,),
                        // SizedBox(
                        //   height: 58,
                        //   child: ListView.builder(
                        //       itemCount: 10,
                        //       shrinkWrap: true,
                        //       scrollDirection: Axis.horizontal,
                        //       physics: AlwaysScrollableScrollPhysics(),
                        //       itemBuilder: (BuildContext context, int index) {
                        //         return  Image.asset("assets/svgs/single.png",height: 56,width: 86,);
                        //       },
                        //
                        //   ),
                        // ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          modelSingleProduct.value.simpleProduct!.pname
                              .toString()
                              .capitalize!,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: const Color(0xFF19313C)),
                        ),
                        Text(
                          modelSingleProduct
                              .value.simpleProduct!.shortDescription
                              .toString()
                              .capitalize!,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: const Color(0xFF19313C)),
                        ),

                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.end,
                        //   children: [
                        //     Text("Cashback : ", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color:Colors.black),),
                        //     Text("1.5% ", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color:Color(0xFFFF0000)),),
                        //     Text("dicoins", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color:Colors.black),),
                        //   ],
                        // ),
                        const SizedBox(
                          height: 6,
                        ),

                        // Row(
                        //   children: [
                        //     widget.productElement.discountOff !=  '0.00'? Expanded(
                        //       child: Text(
                        //         'KWD ${widget.productElement.pPrice.toString()}',
                        //         style: GoogleFonts.poppins(
                        //             decorationColor: Colors.red,
                        //             decorationThickness: 2,
                        //             decoration: TextDecoration.lineThrough,
                        //             color: const Color(0xff19313B),
                        //             fontSize: 16,
                        //             fontWeight: FontWeight.w600),
                        //       ),
                        //     ): const SizedBox.shrink(),
                        //     const SizedBox(
                        //       width: 7,
                        //     ),
                        //     Expanded(
                        //       child: Text.rich(
                        //         TextSpan(
                        //           text: '${widget.productElement.discountPrice.toString().split('.')[0]}.',
                        //           style: const TextStyle(
                        //             fontSize: 24,
                        //             fontWeight: FontWeight.w600,
                        //             color: Color(0xFF19313B),
                        //           ),
                        //           children: [
                        //             WidgetSpan(
                        //               alignment: PlaceholderAlignment.middle,
                        //               child: Column(
                        //                 mainAxisAlignment: MainAxisAlignment.start,
                        //                 children: [
                        //                   const Text(
                        //                     'KWD',
                        //                     style: TextStyle(
                        //                       fontSize: 8,
                        //                       fontWeight: FontWeight.w500,
                        //                       color: Color(0xFF19313B),
                        //                     ),
                        //                   ),
                        //                   InkWell(
                        //                     onTap: () {
                        //                       print("date:::::::::::" + widget.productElement.shippingDate);
                        //                     },
                        //                     child: Text(
                        //                       '${widget.productElement.discountPrice.toString().split('.')[1]}',
                        //                       style: const TextStyle(
                        //                         fontSize: 8,
                        //                         fontWeight: FontWeight.w600,
                        //                         color: Color(0xFF19313B),
                        //                       ),
                        //                     ),
                        //                   ),
                        //                 ],
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // )

                        Row(
                          children: [
                            if (modelSingleProduct
                                    .value.simpleProduct!.discountOff !=
                                '0.00')
                              Flexible(
                                child: Text.rich(
                                  profileController.selectedLAnguage.value ==
                                          "English"
                                      ? TextSpan(
                                          text:
                                              '${modelSingleProduct.value.simpleProduct!.pPrice.toString().split('.')[0]}.',
                                          style: GoogleFonts.poppins(
                                              decorationColor: Colors.red,
                                              decorationThickness: 2,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              color: const Color(0xff19313B),
                                              fontSize: 24,
                                              fontWeight: FontWeight.w600),
                                          children: [
                                            WidgetSpan(
                                              alignment:
                                                  PlaceholderAlignment.middle,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'KWD',
                                                    style: TextStyle(
                                                      fontSize: 8,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Color(0xFF19313B),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      // print("date:::::::::::" + widget.simpleProduct.shippingDate);
                                                    },
                                                    child: Text(
                                                      '${modelSingleProduct.value.simpleProduct!.pPrice.toString().split('.')[1]}',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              decorationColor:
                                                                  Colors.red,
                                                              decorationThickness:
                                                                  2,
                                                              // decoration: TextDecoration.lineThrough,
                                                              color: const Color(
                                                                  0xff19313B),
                                                              fontSize: 8,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : TextSpan(
                                          children: [
                                            WidgetSpan(
                                              alignment:
                                                  PlaceholderAlignment.bottom,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'KWD',
                                                    style: TextStyle(
                                                      fontSize: 8,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Color(0xFF19313B),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      // print("date:::::::::::" + widget.simpleProduct.shippingDate);
                                                    },
                                                    child: Text(
                                                      '${modelSingleProduct.value.simpleProduct!.pPrice.toString().split('.')[1]}',
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
                                                          fontSize: 8,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  '.${modelSingleProduct.value.simpleProduct!.pPrice.toString().split('.')[0]}',
                                              style: GoogleFonts.poppins(
                                                  decorationColor: Colors.red,
                                                  decorationThickness: 2,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  color:
                                                      const Color(0xff19313B),
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w600),
                                            )
                                          ],
                                        ),
                                ),
                              ),
                            const SizedBox(width: 7),
                            Flexible(
                              child: Text.rich(
                                profileController.selectedLAnguage.value ==
                                        "English"
                                    ? TextSpan(
                                        text:
                                            '${modelSingleProduct.value.simpleProduct!.discountPrice.toString().split('.')[0]}.',
                                        style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF19313B)),
                                        children: [
                                          WidgetSpan(
                                            alignment:
                                                PlaceholderAlignment.middle,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'KWD',
                                                  style: TextStyle(
                                                      fontSize: 8,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Color(0xFF19313B)),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    print("date:::::::::::" +
                                                        modelSingleProduct
                                                            .value
                                                            .simpleProduct!
                                                            .shippingDate
                                                            .toString());
                                                  },
                                                  child: Text(
                                                    '${modelSingleProduct.value.simpleProduct!.discountPrice.toString().split('.')[1]}',
                                                    style: const TextStyle(
                                                        fontSize: 8,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Color(0xFF19313B)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    : TextSpan(
                                        children: [
                                          WidgetSpan(
                                            alignment:
                                                PlaceholderAlignment.bottom,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'KWD',
                                                  style: TextStyle(
                                                      fontSize: 8,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Color(0xFF19313B)),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    print("date:::::::::::" +
                                                        modelSingleProduct
                                                            .value
                                                            .simpleProduct!
                                                            .shippingDate
                                                            .toString());
                                                  },
                                                  child: Text(
                                                    '${modelSingleProduct.value.simpleProduct!.discountPrice.toString().split('.')[1]}',
                                                    style: const TextStyle(
                                                        fontSize: 8,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Color(0xFF19313B)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '.${modelSingleProduct.value.simpleProduct!.discountPrice.toString().split('.')[0]}',
                                            style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF19313B)),
                                          )
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                        modelSingleProduct.value.simpleProduct!.rating == '0'
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  modelSingleProduct
                                              .value.simpleProduct!.rating !=
                                          '0'
                                      ? RatingBar.builder(
                                          initialRating: double.parse(
                                              modelSingleProduct
                                                  .value.simpleProduct!.rating
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
                                              .value.simpleProduct!.rating !=
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
                        if (modelSingleProduct
                            .value.simpleProduct!.catId!.isNotEmpty)
                          Column(
                            children: [
                              const SizedBox(
                                height: 15,
                              ),
                              SizedBox(
                                height: 28,
                                child: ListView.builder(
                                  itemCount: modelSingleProduct
                                      .value.simpleProduct!.catId!.length,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 7, horizontal: 37),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF014E70)
                                                .withOpacity(.07),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            modelSingleProduct
                                                .value
                                                .simpleProduct!
                                                .catId![index]
                                                .title
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
                              const SizedBox(
                                height: 15,
                              ),
                            ],
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
                                    .value.simpleProduct!.longDescription !=
                                '' &&
                            modelSingleProduct
                                    .value.simpleProduct!.longDescription !=
                                null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // const Icon(Icons.circle,color: Colors.grey,size: 10,),
                              const SizedBox(
                                width: 7,
                              ),
                              Expanded(
                                child: Text(
                                  modelSingleProduct.value.simpleProduct!
                                          .longDescription ??
                                      '',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: const Color(0xFF19313C)),
                                ),
                              ),
                            ],
                          ),
                        // Row(
                        //   crossAxisAlignment: CrossAxisAlignment.center,
                        //   children: [
                        //     const Icon(Icons.circle,color: Colors.grey,size: 10,),
                        //     const SizedBox(
                        //       width: 7,
                        //     ),
                        //     Text(
                        //       'Shipping Type'.tr,
                        //       style: GoogleFonts.poppins(
                        //
                        //           color:  Colors.grey,
                        //           fontSize: 14,
                        //           fontWeight: FontWeight.w500),
                        //     ),
                        //     5.spaceX,
                        //     Expanded(
                        //       child: Text(
                        //               modelSingleProduct.value.simpleProduct!.shippingDate.toString(),
                        //         style: GoogleFonts.poppins(
                        //
                        //             color:  const Color(0xFf014E70),
                        //             fontSize: 14,
                        //             fontWeight: FontWeight.w600),
                        //       ),
                        //     ),
                        //
                        //
                        //
                        //   ],
                        // ),
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
                                        .value.simpleProduct!.inStock) ??
                                    0;
                                if (inStock == -1) {
                                  print("1---: ${inStock}");
                                  setState(() {
                                    _counter++;
                                  });
                                } else if (inStock == 0) {
                                  print("2---: ${inStock}");
                                  showToastCenter('Product out of stock'.tr);
                                } else if (_counter >= inStock) {
                                  showToastCenter('Product out of stock'.tr);
                                } else {
                                  setState(() {
                                    print("3---: ${inStock}");
                                    _counter++;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Expanded(
                        //       child: InkWell(
                        //         onTap: () {
                        //           cartController.productElementId = id.toString();
                        //           cartController.productQuantity = productQuantity.value.toString();
                        //           directBuyProduct();
                        //         },
                        //         child: Container(
                        //           padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                        //           decoration: BoxDecoration(
                        //             color: Colors.red,
                        //             borderRadius: BorderRadius.circular(20),
                        //           ),
                        //           child: Center(
                        //             child: Text(
                        //               "Buy Now".tr,
                        //               style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //     SizedBox(width: 10,),
                        //     InkWell(
                        //       onTap: () {
                        //         addToCartProduct();
                        //       },
                        //       child: Container(
                        //         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                        //         decoration: BoxDecoration(
                        //           color: const Color(0xFF014E70),
                        //           border: Border.all(
                        //             color: const Color(0xFF014E70),
                        //           ),
                        //           borderRadius: BorderRadius.circular(20),
                        //         ),
                        //         child: Text(
                        //           "ADD TO CART".tr,
                        //           style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
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
                            // const Icon(Icons.circle, color: Colors.grey, size: 6,),
                            const SizedBox(
                              width: 7,
                            ),
                            Text(
                              modelSingleProduct
                                      .value.simpleProduct!.serialNumber ??
                                  '',
                              style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        // SizedBox(height: 10,),
                        // Row(
                        //   // mainAxisAlignment: MainAxisAlignment.start,
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Text(
                        //       'Brand :',
                        //       style: GoogleFonts.poppins(
                        //
                        //           color: Colors.black,
                        //           fontSize: 16,
                        //           fontWeight: FontWeight.w500),
                        //     ),
                        //
                        //     const SizedBox(
                        //       width: 20,
                        //     ),
                        //     Expanded(
                        //       child: Column(
                        //         children: [
                        //           Row(
                        //             mainAxisAlignment: MainAxisAlignment.start,
                        //             // crossAxisAlignment: CrossAxisAlignment.start,
                        //             children: [
                        //               Icon(Icons.circle, color: Colors.grey, size: 6,),
                        //               const SizedBox(
                        //                 width: 7,
                        //               ),
                        //               Expanded(
                        //                 child: Text(
                        //                   '(7 days free & easy return) Seller Policy',
                        //                   style: GoogleFonts.poppins(
                        //
                        //                       color: Colors.grey,
                        //                       fontSize: 14,
                        //                       fontWeight: FontWeight.w500),
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //           SizedBox(height: 10,),
                        //
                        //
                        //         ],
                        //       ),
                        //     )
                        //
                        //   ],
                        // ),
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
                            // const Icon(
                            //   Icons.circle,
                            //   color: Color(0xFF014E70),
                            //   size: 6,
                            // ),
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
                              'Delivery:'.tr,
                              style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            // const Icon(
                            //   Icons.circle,
                            //   color: Color(0xFF014E70),
                            //   size: 6,
                            // ),
                            const SizedBox(
                              width: 7,
                            ),
                            Expanded(
                              child: Text(
                                // formattedDate.toString(),
                                modelSingleProduct
                                        .value.simpleProduct!.shippingDate
                                        .toString()
                                        .toLowerCase()
                                        .contains('next day delivery')
                                    ? 'Tomorrow'
                                    : modelSingleProduct
                                        .value.simpleProduct!.shippingDate
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
                            // const Icon(
                            //   Icons.circle,
                            //   color: Color(0xFF014E70),
                            //   size: 6,
                            // ),
                            const SizedBox(
                              width: 7,
                            ),
                            Expanded(
                              child: Text(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                modelSingleProduct.value.simpleProduct!
                                            .lowestDeliveryPrice ==
                                        ""
                                    ? "0"
                                    : modelSingleProduct.value.simpleProduct!
                                        .lowestDeliveryPrice
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                modelSingleProduct
                                    .value.simpleProduct!.storemeta!.storeName
                                    .toString(),
                                style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            if (modelSingleProduct.value.simpleProduct!
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
                                    .value.simpleProduct!.storemeta!.storeId
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
                              modelSingleProduct
                                  .value.simpleProduct!.storemeta!.storeLocation
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
                              modelSingleProduct
                                  .value.simpleProduct!.storemeta!.storeCategory
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
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Column(
                        //       mainAxisAlignment: MainAxisAlignment.start,
                        //       crossAxisAlignment: CrossAxisAlignment.start,
                        //       children: [
                        //
                        //         Text(
                        //           'Store rating',
                        //           style: GoogleFonts.poppins(
                        //
                        //               color: Colors.grey,
                        //               fontSize: 12,
                        //               fontWeight: FontWeight.w400),
                        //         ),
                        //       ],
                        //
                        //     ),
                        //
                        //   ],
                        // ),

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
                        modelSingleProduct.value.simpleProduct!.storemeta!
                                    .commercialLicense !=
                                ""
                            ? Center(
                                child: CachedNetworkImage(
                                  imageUrl: modelSingleProduct
                                      .value
                                      .simpleProduct!
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
                        // modelSingleProduct.value.simpleProduct!.storemeta!.document2 != ""?
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

                        modelSingleProduct.value.simpleProduct!.storemeta!
                                    .document2 !=
                                ""
                            ? Center(
                                child: CachedNetworkImage(
                                  imageUrl: modelSingleProduct
                                      .value.simpleProduct!.storemeta!.document2
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
                        const SizedBox(
                          height: 20,
                        ),
                        // Center(child: Image.asset("assets/svgs/licence.png")),

                        GestureDetector(
                          onTap: () {
                            Get.to(() => SingleStoreScreen(
                                storeDetails: VendorStoreData(
                                    id: modelSingleProduct.value.simpleProduct!
                                        .vendorInformation!.storeId)));
                          },
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 150,
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
                        const SizedBox(
                          height: 20,
                        ),
                        // GestureDetector(
                        //   onTap: (){
                        //     Get.to(
                        //             () => SingleStoreScreen(storeDetails:  VendorStoreData(id:
                        //         modelSingleProduct.value.simpleProduct!.vendorInformation!.storeId
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
                        //           style:
                        //           GoogleFonts.poppins(color: const Color(0xFF014E70), fontSize: 14, fontWeight: FontWeight.w500),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        //
                        // const SizedBox(
                        //   height: 10,
                        // ),
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
                                    var similarcounter = 1;
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return GestureDetector(
                                          onTap: () {
                                            log('dasdadadad ${item.itemType}');
                                            if (item.itemType == 'giveaway') {
                                              Get.to(
                                                  () => const GiveAwayProduct(),
                                                  arguments:
                                                      item.id.toString());
                                            } else if (item.productType ==
                                                    'variants' &&
                                                item.itemType == 'product') {
                                              Get.to(
                                                  () =>
                                                      const VarientsProductScreen(),
                                                  arguments:
                                                      item.id.toString());
                                            } else if (item.productType ==
                                                    'booking' &&
                                                item.itemType == 'product') {
                                              Get.to(
                                                  () =>
                                                      const BookableProductScreen(),
                                                  arguments:
                                                      item.id.toString());
                                            } else if (item.productType ==
                                                    'virtual_product' &&
                                                item.itemType ==
                                                    'virtual_product') {
                                              Get.to(
                                                  () => VritualProductScreen(),
                                                  arguments:
                                                      item.id.toString());
                                            } else if (item.itemType ==
                                                'product') {
                                              imagesList.clear();
                                              id = item.id.toString();
                                              getProductDetails(
                                                  context: context);
                                              _scrollToTop();
                                              Get.to(
                                                  () =>
                                                      const SimpleProductScreen(),
                                                  arguments:
                                                      item.id.toString());
                                            } else if (item.itemType ==
                                                'service') {
                                              imagesList.clear();
                                              id = item.id.toString();
                                              getProductDetails(
                                                  context: context);
                                              _scrollToTop();
                                              Get.to(
                                                  () =>
                                                      const ServiceProductScreen(),
                                                  arguments:
                                                      item.id.toString());
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
                                                      blurStyle:
                                                          BlurStyle.outer,
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
                                                      if (item.discountOff !=
                                                          '0.00')
                                                        Container(
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
                                                        ),
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
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Center(
                                                          child:
                                                              CachedNetworkImage(
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
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: const Color(
                                                            0xFF19313C)),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    item.shortDescription
                                                        .toString()
                                                        .capitalize!,
                                                    style: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 12,
                                                        color: const Color(
                                                            0xFF19313C)),
                                                  ),
                                                  item.itemType != 'giveaway'
                                                      ? Row(
                                                          children: [
                                                            item.discountOff !=
                                                                    '0.00'
                                                                ? Flexible(
                                                                    child: Text.rich(profileController.selectedLAnguage.value ==
                                                                            "English"
                                                                        ? TextSpan(
                                                                            text:
                                                                                '${item.pPrice.toString().split('.')[0]}.',
                                                                            style: GoogleFonts.poppins(
                                                                                decorationColor: Colors.red,
                                                                                decorationThickness: 2,
                                                                                decoration: TextDecoration.lineThrough,
                                                                                color: const Color(0xff19313B),
                                                                                fontSize: 24,
                                                                                fontWeight: FontWeight.w600),
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
                                                                                        style: GoogleFonts.poppins(
                                                                                            decorationColor: Colors.red,
                                                                                            decorationThickness: 2,
                                                                                            // decoration: TextDecoration.lineThrough,
                                                                                            color: const Color(0xff19313B),
                                                                                            fontSize: 8,
                                                                                            fontWeight: FontWeight.w600),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          )
                                                                        : TextSpan(
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
                                                                                        style: GoogleFonts.poppins(
                                                                                            decorationColor: Colors.red,
                                                                                            decorationThickness: 2,
                                                                                            // decoration: TextDecoration.lineThrough,
                                                                                            color: const Color(0xff19313B),
                                                                                            fontSize: 8,
                                                                                            fontWeight: FontWeight.w600),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              TextSpan(
                                                                                text: '.${item.pPrice.toString().split('.')[0]}',
                                                                                style: GoogleFonts.poppins(decorationColor: Colors.red, decorationThickness: 2, decoration: TextDecoration.lineThrough, color: const Color(0xff19313B), fontSize: 24, fontWeight: FontWeight.w600),
                                                                              )
                                                                            ],
                                                                          )),
                                                                  )
                                                                : const SizedBox
                                                                    .shrink(),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Flexible(
                                                              child: Text.rich(
                                                                profileController
                                                                            .selectedLAnguage
                                                                            .value ==
                                                                        "English"
                                                                    ? TextSpan(
                                                                        text:
                                                                            '${item.discountPrice.toString().split('.')[0]}.',
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                24,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color: Color(0xFF19313B)),
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
                                                                                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w500, color: Color(0xFF19313B)),
                                                                                ),
                                                                                InkWell(
                                                                                  onTap: () {
                                                                                    print("date:::::::::::" + item.shippingDate.toString());
                                                                                  },
                                                                                  child: Text(
                                                                                    '${item.discountPrice.toString().split('.')[1]}',
                                                                                    style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Color(0xFF19313B)),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : TextSpan(
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
                                                                                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w500, color: Color(0xFF19313B)),
                                                                                ),
                                                                                InkWell(
                                                                                  onTap: () {
                                                                                    print("date:::::::::::" + item.shippingDate.toString());
                                                                                  },
                                                                                  child: Text(
                                                                                    '${item.discountPrice.toString().split('.')[1]}',
                                                                                    style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Color(0xFF19313B)),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          TextSpan(
                                                                            text:
                                                                                '.${item.discountPrice.toString().split('.')[0]}',
                                                                            style: const TextStyle(
                                                                                fontSize: 24,
                                                                                fontWeight: FontWeight.w600,
                                                                                color: Color(0xFF19313B)),
                                                                          )
                                                                        ],
                                                                      ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : const SizedBox.shrink(),
                                                  // const SizedBox(height: 8),

                                                  if (item.inStock != "-1")
                                                    Text(
                                                      '${'QTY'.tr}: ${item.inStock} ${'piece'.tr}',
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
                                                            // const SizedBox(height: 7),
                                                            if (item.shippingDate !=
                                                                "No International Shipping Available")
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    'shipping'
                                                                        .tr,
                                                                    style: GoogleFonts.poppins(
                                                                        color: const Color(
                                                                            0xff858484),
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                  if (item.lowestDeliveryPrice !=
                                                                      null)
                                                                    Text(
                                                                      'KWD ${item.lowestDeliveryPrice.toString()}',
                                                                      style: GoogleFonts.poppins(
                                                                          color: const Color(
                                                                              0xff858484),
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                  if (item.shippingDate !=
                                                                      null)
                                                                    Text(
                                                                      item.shippingDate
                                                                          .toString(),
                                                                      maxLines:
                                                                          2,
                                                                      style: GoogleFonts.poppins(
                                                                          color: const Color(
                                                                              0xff858484),
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w500),
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
                                                                      text: 'international shipping not available'
                                                                          .tr,
                                                                      style: GoogleFonts.poppins(
                                                                          color: const Color(
                                                                              0xff858484),
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                      children: [
                                                                        TextSpan(
                                                                            text: ' contact us'
                                                                                .tr,
                                                                            style: GoogleFonts.poppins(
                                                                                decoration: TextDecoration.underline,
                                                                                color: AppTheme.buttonColor,
                                                                                fontSize: 13,
                                                                                fontWeight: FontWeight.w500)),
                                                                        TextSpan(
                                                                            text: ' for the solution'
                                                                                .tr,
                                                                            style: GoogleFonts.poppins(
                                                                                color: const Color(0xff858484),
                                                                                fontSize: 13,
                                                                                fontWeight: FontWeight.w500)),
                                                                      ]),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          children: [
                                                            // profileController.selectedLAnguage.value == "English"
                                                            // ?ElevatedButton(
                                                            //   onPressed: () {
                                                            //     cartController.productElementId = id.toString();
                                                            //     cartController.productQuantity = productQuantity.value.toString();
                                                            //     directBuyProduct();
                                                            //   },
                                                            //   style: ElevatedButton.styleFrom(
                                                            //     backgroundColor: Colors.red,
                                                            //     surfaceTintColor: Colors.red,
                                                            //   ),
                                                            //   child: FittedBox(
                                                            //     child: Text(
                                                            //       "  Buy Now  ".tr,
                                                            //       style: GoogleFonts.poppins(
                                                            //           fontSize: 16,
                                                            //           fontWeight: FontWeight.w500,
                                                            //           color: Colors.white),
                                                            //     ),
                                                            //   ),
                                                            // )
                                                            // :SizedBox(
                                                            //   width:130,
                                                            //   child: ElevatedButton(
                                                            //     onPressed: () {
                                                            //       cartController.productElementId = id.toString();
                                                            //       cartController.productQuantity = productQuantity.value.toString();
                                                            //       directBuyProduct();
                                                            //     },
                                                            //     style: ElevatedButton.styleFrom(
                                                            //       backgroundColor: Colors.red,
                                                            //       surfaceTintColor: Colors.red,
                                                            //     ),
                                                            //     child: FittedBox(
                                                            //       child: Text(
                                                            //         "  Buy Now  ".tr,
                                                            //         style: GoogleFonts.poppins(
                                                            //             fontSize: 16,
                                                            //             fontWeight: FontWeight.w500,
                                                            //             color: Colors.white),
                                                            //       ),
                                                            //     ),
                                                            //   ),
                                                            // ),
                                                            // ElevatedButton(
                                                            //   onPressed: () {
                                                            //     addToCartProduct();
                                                            //   },
                                                            //   style: ElevatedButton.styleFrom(
                                                            //     backgroundColor: AppTheme.buttonColor,
                                                            //     surfaceTintColor: AppTheme.buttonColor,
                                                            //   ),
                                                            //   child: FittedBox(
                                                            //     child: Text(
                                                            //       "Add to Cart".tr,
                                                            //       style: GoogleFonts.poppins(
                                                            //           fontSize: 16,
                                                            //           fontWeight: FontWeight.w500,
                                                            //           color: Colors.white),
                                                            //     ),
                                                            //   ),
                                                            // ),
                                                            // if (item.itemType != 'giveaway')
                                                            //   Row(
                                                            //     mainAxisAlignment: MainAxisAlignment.center,
                                                            //     crossAxisAlignment: CrossAxisAlignment.center,
                                                            //     children: [
                                                            //       GestureDetector(
                                                            //         onTap: () {
                                                            //           // Get.to(() => ProductDescription(
                                                            //           // product: item,
                                                            //           // modelRelated: modelRelated
                                                            //           // ));
                                                            //         },
                                                            //         child: Text(
                                                            //           "Show Details".tr,
                                                            //           style: GoogleFonts.poppins(
                                                            //               color: Colors.black,
                                                            //               fontSize: 16,
                                                            //               fontWeight: FontWeight.w500),
                                                            //         ),
                                                            //       ),
                                                            //     ],
                                                            //   )
                                                            // else
                                                            //   Container(
                                                            //     color: AppTheme.buttonColor,
                                                            //     padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                            //     child: Center(
                                                            //       child: GestureDetector(
                                                            //         onTap: () {
                                                            //           // Get.to(() => ProductDescription(
                                                            //           // product: item,
                                                            //           // modelRelated: modelRelated
                                                            //           // ));
                                                            //         },
                                                            //         child: Text(
                                                            //           "Enter to Giveaway".tr,
                                                            //           style: GoogleFonts.poppins(
                                                            //               color: Colors.white,
                                                            //               fontSize: 16,
                                                            //               fontWeight: FontWeight.w500),
                                                            //         ),
                                                            //       ),
                                                            //     ),
                                                            //   ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Quantity : '.tr,
                                                        style:
                                                            GoogleFonts.poppins(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                      ),
                                                      const Spacer(),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.remove,
                                                          color:
                                                              Color(0xFF014E70),
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            if (similarcounter >
                                                                1) {
                                                              similarcounter--;
                                                            }
                                                          });
                                                        },
                                                      ),
                                                      Text(
                                                        '$similarcounter',
                                                        style: GoogleFonts.poppins(
                                                            color: const Color(
                                                                0xFF014E70),
                                                            fontSize: 26,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.add,
                                                          color:
                                                              Color(0xFF014E70),
                                                        ),
                                                        // onPressed: incrementCounter,
                                                        onPressed: () {
                                                          int inStock =
                                                              int.tryParse(item
                                                                      .inStock) ??
                                                                  0;
                                                          if (inStock == -1) {
                                                            print(
                                                                "1---: ${inStock}");
                                                            setState(() {
                                                              similarcounter++;
                                                            });
                                                          } else if (inStock ==
                                                              0) {
                                                            print(
                                                                "2---: ${inStock}");
                                                            showToastCenter(
                                                                'Product out of stock'
                                                                    .tr);
                                                          } else if (similarcounter >=
                                                              inStock) {
                                                            showToastCenter(
                                                                'Product out of stock'
                                                                    .tr);
                                                          } else {
                                                            setState(() {
                                                              print(
                                                                  "3---: ${inStock}");
                                                              similarcounter++;
                                                            });
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 30,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: profileController
                                                                    .selectedLAnguage
                                                                    .value ==
                                                                "English"
                                                            ? ElevatedButton(
                                                                onPressed: () {
                                                                  cartController
                                                                          .productElementId =
                                                                      id.toString();
                                                                  cartController
                                                                          .productQuantity =
                                                                      productQuantity
                                                                          .value
                                                                          .toString();

                                                                  directBuyProduct(
                                                                      counter:
                                                                          similarcounter,
                                                                      sid: item
                                                                          .id.toString());
                                                        
                                                                },
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                  surfaceTintColor:
                                                                      Colors
                                                                          .red,
                                                                  minimumSize:
                                                                      const Size(
                                                                          double
                                                                              .infinity,
                                                                          40), // Use double.infinity for full width
                                                                ),
                                                                child:
                                                                    FittedBox(
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
                                                              )
                                                            : SizedBox(
                                                                width: 130,
                                                                child:
                                                                    ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    cartController
                                                                            .productElementId =
                                                                        id.toString();
                                                                    cartController
                                                                            .productQuantity =
                                                                        productQuantity
                                                                            .value
                                                                            .toString();
                                                                    log("this is item id${item.id}");
                                                                    directBuyProduct(
                                                                        counter:
                                                                            similarcounter,
                                                                        sid: item
                                                                            .id.toString());
                                                                  },
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red,
                                                                    surfaceTintColor:
                                                                        Colors
                                                                            .red,
                                                                  ),
                                                                  child:
                                                                      FittedBox(
                                                                    child: Text(
                                                                      "  Buy Now  "
                                                                          .tr,
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color:
                                                                              Colors.white),
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
                                                            addToCartProduct(
                                                              counter:
                                                                  similarcounter,
                                                                  sid: item.id.toString(),
                                                            );
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                AppTheme
                                                                    .buttonColor,
                                                            surfaceTintColor:
                                                                AppTheme
                                                                    .buttonColor,
                                                            minimumSize: const Size(
                                                                double.infinity,
                                                                40), // Use double.infinity for full width
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
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
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
