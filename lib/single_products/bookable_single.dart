import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dirise/single_products/simple_product.dart';
import 'package:dirise/single_products/variable_single.dart';
import 'package:dirise/single_products/vritual_product_single.dart';
import 'package:dirise/utils/helper.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/cupertino.dart';
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
import '../model/bookable_product_model.dart';
import '../model/common_modal.dart';

// import '../model/filter_by_price_model.dart';
import '../model/get_review_model.dart';
import '../model/giveaway_single_model.dart';
import '../model/model_category_stores.dart';
import '../model/model_single_product.dart';
import '../model/order_models/model_direct_order_details.dart';
import '../model/perdayslotmodel.dart';
import '../model/product_model/model_product_element.dart';
import '../model/releated_product_model.dart';
import '../model/simple_product_model.dart';
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
import 'give_away_single.dart';

class BookableProductScreen extends StatefulWidget {
  const BookableProductScreen({super.key});

  @override
  State<BookableProductScreen> createState() => _BookableProductScreenState();
}

class _BookableProductScreenState extends State<BookableProductScreen> {
  final Repositories repositories = Repositories();

  TextEditingController reviewController = TextEditingController();
  final profileController = Get.put(ProfileController());

  Rx<BookableProductModel> modelSingleProduct = BookableProductModel().obs;
  ModelAddReview modelAddReview = ModelAddReview();
  final locationController = Get.put(LocationController());
  final homeController = Get.put(TrendingProductsController());
  String? selectedValue1;
  String id = Get.arguments;
  String releatedId = "";

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? vectionStartDate;
  DateTime? vectionEndndDate;
  DateTime? _selectedDate;
  List<String> vacationFromDates = [];
  List<String> vacationEndDates = [];

  Map<String, dynamic> get getMap {
    Map<String, dynamic> map = {};
    map["product_id"] = id.toString();
    map["quantity"] =
        map["quantity"] = int.tryParse(productQuantity.value.toString());
    map["key"] = 'fedexRate';
    map["country_id"] = profileController.model.user!.country_id;

    return map;
  }

  Rx<PerDaySlotModel> perDaySlotModel = PerDaySlotModel().obs;
  Future getPerDaySlot(String formattedDate) async {
    repositories
        .getApi(
            url:
                '${ApiUrls.getPerDaySlot}${id.toString()}&date=${formattedDate}')
        .then((value) {
      perDaySlotModel.value = PerDaySlotModel.fromJson(jsonDecode(value));
    });
  }

  RxStatus statusSingle = RxStatus.empty();
  String dateTimeString = "";
  getProductDetails({BuildContext? context}) {
    statusSingle = RxStatus.loading();
    repositories.postApi(url: ApiUrls.bookableProductUrl, mapData: {
      "product_id": id.toString(),
      "key": 'fedexRate',
      "is_def_address": homeController.defaultAddressId.toString()
    }).then((value) {
      modelSingleProduct.value =
          BookableProductModel.fromJson(jsonDecode(value));
      if (modelSingleProduct.value.bookingProduct != null) {
        fetchDatesFromApi();
        if (modelSingleProduct.value.bookingProduct!.productVacation != null) {
          for (var vacation
              in modelSingleProduct.value.bookingProduct!.productVacation!) {
            if (vacation.vacationFromDate != null) {
              vacationFromDates.add(vacation.vacationFromDate!);
            }
            if (vacation.vacationFromDate != null) {
              vacationEndDates.add(vacation.vacationToDate!);
            }
          }
        }

        // You can now use vacationFromDates and vacationEndDates as needed
        log("Vacation From Dates: $vacationFromDates");
        log("Vacation End Dates: $vacationEndDates");
        log("modelSingleProduct.product!.toJson().....${modelSingleProduct.value.bookingProduct!.toJson()}");
        ratingRills = ratingRill *
            double.parse(
                modelSingleProduct.value.bookingProduct!.rating.toString());
        imagesList.addAll(
            modelSingleProduct.value.bookingProduct!.galleryImage ?? []);
        imagesList = imagesList.toSet().toList();
        if (modelSingleProduct.value.bookingProduct!.catId != null &&
            modelSingleProduct.value.bookingProduct!.catId!.isNotEmpty) {
          releatedId = modelSingleProduct.value.bookingProduct!.catId!.last.id
              .toString();
        }

        print("releatedId" + releatedId);
        similarProduct();

        statusSingle = RxStatus.success();
      } else {
        statusSingle = RxStatus.empty();
      }
      setState(() {});
    }).catchError((error) {
      statusSingle = RxStatus.error(error.toString());
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
    map["country_id"] =
        profileController.model.user != null && cartController.countryId.isEmpty
            ? profileController.model.user!.country_id
            : cartController.countryId.toString();
    // map["start_date"] = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    map["start_date"] = cartController.formattedDate;
    map["time_sloat"] = cartController.timeSloat;
    map["sloat_end_time"] = cartController.additionalData;
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
      modelSingleProduct.value.bookingProduct!.inWishlist == true;
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
      modelSingleProduct.value.bookingProduct!.inWishlist == true;
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
    map["quantity"] = map["quantity"] = int.tryParse(_counter.toString());
    map["key"] = 'fedexRate';
    map["country_id"] = profileController.model.user != null
        ? profileController.model.user!.country_id
        : '117';
    map["zip_code"] = cartController.zipCode.toString();
    // map["start_date"] = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    // map["time_sloat"] = timeSloat;
    // map["sloat_end_time"] = additionalData;
    map["start_date"] = selectedDate.text.trim();
    map["time_sloat"] = selectedSlot.split("--").first;
    map["sloat_end_time"] = selectedSlot.split("--").last;
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
    // if (!validateSlots()) return;
    Map<String, dynamic> map = {};

    map["cat_id"] = releatedId.toString();

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

  double ratingRills = 0.0;
  int ratingRill = 20;
  List<String> imagesList = [];
  RxInt currentIndex = 0.obs;
  Variants? selectedVariant;
  DateTime? apiStartDate;
  DateTime? apiEndDate;
  void fetchDatesFromApi() async {
    apiStartDate = DateTime.parse(modelSingleProduct
        .value.bookingProduct!.productAvailability!.fromDate!);
    apiEndDate = DateTime.parse(
        modelSingleProduct.value.bookingProduct!.productAvailability!.toDate!);

    setState(() {
      _startDate = apiStartDate;
      _endDate = apiEndDate;
    });
  }

  @override
  void initState() {
    super.initState();
    getProductDetails();
  }

  RxInt productQuantity = 1.obs;
  final cartController = Get.put(CartController());

  CarouselSliderController carouselController = CarouselSliderController();

  final wishListController = Get.put(WishListController());

  RxBool alreadyReview = false.obs;

  int _counter = 1;

  void incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _saveDate(DateTime date) {
    // Save the selected date here
    print("Selected Date: ${date.toLocal().toString().split(' ')[0]}");
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
      duration: const Duration(milliseconds: 300), // Animation duration
      curve: Curves.easeInOut, // Animation curve
    );
  }

  final DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  final TextEditingController selectedDate = TextEditingController();
  DateTime selectedDateTime = DateTime.now();
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  pickDate(
      {required Function(DateTime gg) onPick,
      DateTime? initialDate,
      DateTime? firstDate,
      DateTime? lastDate}) async {
    DateTime lastD = lastDate ?? DateTime(2101);
    DateTime initialD = initialDate ?? firstDate ?? DateTime.now();

    if (lastD.isBefore(firstDate ?? DateTime.now())) {
      lastD = firstDate ?? DateTime.now();
    }

    if (initialD.isAfter(lastD)) {
      initialD = lastD;
    }

    if (initialD.isBefore(firstDate ?? DateTime.now())) {
      initialD = firstDate ?? DateTime.now();
    }

    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: initialD,
        firstDate: firstDate ?? DateTime.now(),
        lastDate: lastD,
        initialEntryMode: DatePickerEntryMode.calendarOnly);
    if (pickedDate == null) return;
    onPick(pickedDate);
    cartController.formattedDate =
        DateFormat('yyyy-MM-dd').format(selectedDateTime);
    getPerDaySlot(cartController.formattedDate);
    // updateValues();
  }

  final GlobalKey slotKey = GlobalKey();
  bool showValidation = false;
  String selectedSlot = "";
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
              onTap: () {
                // setState(() {
                //   search.value = !search.value;
                // });
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
        return modelSingleProduct.value.bookingProduct != null
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
                                    .value.bookingProduct!.discountOff !=
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
                                      " ${modelSingleProduct.value.bookingProduct!.discountOff}${'%'}  ",
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
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 300,
                            viewportFraction: 1,
                            onPageChanged: (index, reason) {
                              currentIndex.value = index;
                            },
                          ),
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
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          modelSingleProduct.value.bookingProduct!.pname
                              .toString()
                              .capitalize!,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: const Color(0xFF19313C)),
                        ),
                        Text(
                          modelSingleProduct
                              .value.bookingProduct!.shortDescription
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
                                    .value.bookingProduct!.discountOff !=
                                '0.00')
                              Expanded(
                                child: Text(
                                  'KWD ${modelSingleProduct.value.bookingProduct!.pPrice.toString()}',
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
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  text:
                                      '${modelSingleProduct.value.bookingProduct!.discountPrice.toString().split('.')[0]}.',
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
                                                      .bookingProduct!
                                                      .shippingDate
                                                      .toString());
                                            },
                                            child: Text(
                                              '${modelSingleProduct.value.bookingProduct!.discountPrice.toString().split('.')[1]}',
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

                        modelSingleProduct.value.bookingProduct!.rating == '0'
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  modelSingleProduct
                                              .value.bookingProduct!.rating !=
                                          '0'
                                      ? RatingBar.builder(
                                          initialRating: double.parse(
                                              modelSingleProduct
                                                  .value.bookingProduct!.rating
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
                                              .value.bookingProduct!.rating !=
                                          '0'
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'RILS'.tr,
                                              style: const TextStyle(
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
                        TextFormField(
                          onTap: () {
                            pickDate(
                                onPick: (DateTime gg) {
                                  if (dateFormat
                                      .parse((modelSingleProduct
                                                  .value
                                                  .bookingProduct!
                                                  .productAvailability!
                                                  .fromDate ??
                                              modelSingleProduct
                                                  .value
                                                  .bookingProduct!
                                                  .productAvailability!
                                                  .toDate)
                                          .toString())
                                      .isAfter(gg)) {
                                    showToast("This date is not available".tr);
                                    return;
                                  }
                                  selectedDate.text = dateFormat.format(gg);
                                  selectedDateTime = gg;
                                },
                                initialDate: selectedDateTime,
                                firstDate: DateTime.now(),
                                lastDate: dateFormat.parse((modelSingleProduct
                                            .value
                                            .bookingProduct!
                                            .productAvailability!
                                            .toDate ??
                                        modelSingleProduct.value.bookingProduct!
                                            .productAvailability!.fromDate)
                                    .toString()));
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return "Please select date".tr;
                            }
                            return null;
                          },
                          readOnly: true,
                          controller: selectedDate,
                          key: GlobalKey<FormFieldState>(),
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                            enabled: true,
                            suffixIcon: Icon(
                              CupertinoIcons.calendar,
                              color: Colors.grey.shade800,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                            hintText: "Select Date".tr,
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                          "Available Slot".tr,
                          style: normalStyle,
                        ),
                        if (perDaySlotModel.value.dataList != null)
                          Wrap(
                            key: slotKey,
                            spacing: 14,
                            children: perDaySlotModel.value.dataList!
                                .map((e) => FilterChip(
                                    label: Text(
                                      "${e.timeSloat.toString().convertToFormatTime} - ${e.timeSloatEnd.toString().convertToFormatTime}",
                                      style: TextStyle(
                                          color: e.isBooked != true
                                              ? Colors.black
                                              : Colors.white),
                                    ),
                                    side: BorderSide(
                                      color: showValidation &&
                                              selectedSlot.isEmpty
                                          ? Theme.of(context).colorScheme.error
                                          : Colors.grey,
                                    ),
                                    backgroundColor: e.isBooked != true
                                        ? Colors.white
                                        : Colors.grey,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0, vertical: 8),
                                    selected: selectedSlot ==
                                        "${e.timeSloat}--${e.timeSloatEnd}",
                                    onSelected: e.isBooked != true
                                        ? (value) {
                                            selectedSlot =
                                                "${e.timeSloat}--${e.timeSloatEnd}";
                                            cartController.timeSloat =
                                                e.timeSloat.toString();
                                            cartController.additionalData =
                                                e.timeSloatEnd.toString();
                                            log('value isssss${cartController.timeSloat.toString()}');
                                            setState(() {});
                                          }
                                        : (value) {
                                            setState(() {});
                                            showToastCenter(
                                                'Slots is already booked'.tr);
                                          }))
                                .toList(),
                          ),
                        if (showValidation && selectedSlot.isEmpty)
                          Text(
                            "Please select available slots".tr,
                            style: normalStyle.copyWith(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 13),
                          ),
                        // if (showValidation && selectedSlot.isEmpty)
                        //   Text(
                        //     "Please select available slots".tr,
                        //     style:
                        //     normalStyle.copyWith(color: Theme
                        //         .of(context)
                        //         .colorScheme
                        //         .error, fontSize: 13),
                        //   ),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                        //   decoration: BoxDecoration(
                        //     color: const Color(0xFF014E70),
                        //     border: Border.all(
                        //       color: const Color(0xFF014E70),
                        //     ),
                        //     borderRadius: BorderRadius.circular(20),
                        //   ),
                        //   child: InkWell(
                        //     onTap: () async {
                        //       log("Vacation From Dates: $vacationFromDates");
                        //       log("fffffff${modelSingleProduct.value.bookingProduct!.productAvailability!.fromDate}");
                        //       log("fffffff${_endDate.toString()}");
                        //       final DateTimeRange? picked = await showDateRangePicker(
                        //         context: context,
                        //         firstDate: DateTime(2020),
                        //         lastDate: DateTime(2101),
                        //         initialDateRange: DateTimeRange(
                        //           start: _startDate ?? DateTime.now(),
                        //           end: _endDate ?? DateTime.now().add(const Duration(days: 1)),
                        //         ),
                        //         builder: (BuildContext context, Widget? child) {
                        //           return Theme(
                        //             data: ThemeData.light().copyWith(
                        //               primaryColor: const Color(0xFF014E70),
                        //               buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                        //               textTheme: const TextTheme(titleLarge: TextStyle(color: Colors.red)),
                        //             ),
                        //             child: child!,
                        //           );
                        //         },
                        //       );
                        //
                        //       if (picked != null) {
                        //         bool isValidRange = true;
                        //
                        //         // Convert vacationFromDates and vacationEndDates to DateTime objects
                        //         List<DateTime> vacationStartDates = vacationFromDates.map((date) => DateFormat('yyyy-MM-dd').parse(date)).toList();
                        //         List<DateTime> vacationToDates = vacationEndDates.map((date) => DateFormat('yyyy-MM-dd').parse(date)).toList();
                        //
                        //         // Validate selected date range against vacation periods
                        //         for (int i = 0; i < vacationStartDates.length; i++) {
                        //           if ((picked.start.isBefore(vacationToDates[i].add(const Duration(days: 1))) &&
                        //               picked.end.isAfter(vacationStartDates[i].subtract(const Duration(days: 1))))) {
                        //             isValidRange = false;
                        //             break;
                        //           }
                        //         }
                        //
                        //         if (!isValidRange) {
                        //           // Show an error message if the selected range is invalid
                        //           ScaffoldMessenger.of(context).showSnackBar(
                        //             const SnackBar(content: Text("The selected date range includes unavailable dates. Please choose a different range.")),
                        //           );
                        //         } else {
                        //           // Process the valid date range
                        //           setState(() {
                        //             _selectedDate = picked.start;
                        //             _startDate = _selectedDate;
                        //             String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
                        //
                        //             // Make the API call with the formatted date
                        //             getPerDaySlot(formattedDate);
                        //           });
                        //         }
                        //       }
                        //     },
                        //     child: const Text(
                        //       "Select date from calendar",
                        //       style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                        //     ),
                        //   ),
                        // ),

                        // const SizedBox(height: 20),
                        // Text(
                        //   _startDate != null
                        //       ? 'Selected Date: ${_startDate!.toLocal().toString().split(' ')[0]}'
                        //       : 'Selected Date: Not selected',
                        //   style: const TextStyle(fontSize: 16),
                        // ),
                        // const SizedBox(height: 20),
                        // if (perDaySlotModel.value.dataList != null)
                        //   Obx(() {
                        //     return   DropdownButtonFormField(
                        //       decoration: InputDecoration(
                        //         border: const OutlineInputBorder(
                        //           borderRadius: BorderRadius.all(Radius.circular(8)),
                        //           borderSide: BorderSide(color: AppTheme.secondaryColor),
                        //         ),
                        //         enabled: true,
                        //         filled: true,
                        //         hintText: "Select Slots".tr,
                        //         labelStyle: GoogleFonts.poppins(color: Colors.black),
                        //         labelText: "Select Slots".tr,
                        //         fillColor: const Color(0xffE2E2E2).withOpacity(.35),
                        //         contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                        //         enabledBorder: const OutlineInputBorder(
                        //           borderRadius: BorderRadius.all(Radius.circular(8)),
                        //           borderSide: BorderSide(color: AppTheme.secondaryColor),
                        //         ),
                        //       ),
                        //       isExpanded: true,
                        //       icon: Image.asset(
                        //         'assets/images/drop_icon.png',
                        //         height: 17,
                        //         width: 17,
                        //       ),
                        //       items: perDaySlotModel.value.dataList!
                        //           .map((e) => DropdownMenuItem(
                        //         value: e.timeSloat.toString(),
                        //         child: Text(e.timeSloat.toString()),
                        //       ))
                        //           .toList(),
                        //       onChanged: (value) {
                        //         if (value == null) return;
                        //         selectedValue1 = value;
                        //         log('slot data iss');
                        //         timeSloat = value.toString();
                        //         var selectedSlot = perDaySlotModel.value.dataList!.firstWhere(
                        //               (element) => element.timeSloat.toString() == timeSloat,
                        //         );
                        //         additionalData = selectedSlot.timeSloatEnd;
                        //       },
                        //     );
                        //   },),
                        SizedBox(
                          height: 28,
                          child: ListView.builder(
                            itemCount: modelSingleProduct
                                .value.bookingProduct!.catId!.length,
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
                                      modelSingleProduct.value.bookingProduct!
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
                                    .value.bookingProduct!.longDescription !=
                                '' &&
                            modelSingleProduct
                                    .value.bookingProduct!.longDescription !=
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
                                  modelSingleProduct.value.bookingProduct!
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
                        const SizedBox(
                          height: 10,
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
                                        .value.bookingProduct!.inStock) ??
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
                        //           cartController.productElementId = id.toString();
                        //           cartController.productQuantity = productQuantity.value.toString();
                        //           directBuyProduct();
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
                        //           addToCartProduct();
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
                                  .value.bookingProduct!.serialNumber
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
                        // Row(
                        //   children: [
                        //     Text(
                        //       'Standard Delivery :'.tr,
                        //       style:
                        //           GoogleFonts.poppins(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
                        //     ),
                        //     const SizedBox(
                        //       width: 20,
                        //     ),
                        //     // const Icon(
                        //     //   Icons.circle,
                        //     //   color: Color(0xFF014E70),
                        //     //   size: 6,
                        //     // ),
                        //     const SizedBox(
                        //       width: 7,
                        //     ),
                        //     Expanded(
                        //       child: Text(
                        //         maxLines: 1,
                        //         overflow: TextOverflow.ellipsis,
                        //         // formattedDate.toString(),
                        //         modelSingleProduct.value.bookingProduct!.shippingDate.toString(),
                        //         style: GoogleFonts.poppins(
                        //             color: const Color(0xFF014E70), fontSize: 14, fontWeight: FontWeight.w500),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(
                        //   height: 10,
                        // ),
                        // Row(
                        //   // mainAxisAlignment: MainAxisAlignment.start,
                        //   // crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Text(
                        //       'Delivery Charges :'.tr,
                        //       style:
                        //           GoogleFonts.poppins(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
                        //     ),
                        //     const SizedBox(
                        //       width: 20,
                        //     ),
                        //     // const Icon(
                        //     //   Icons.circle,
                        //     //   color: Color(0xFF014E70),
                        //     //   size: 6,
                        //     // ),
                        //     const SizedBox(
                        //       width: 7,
                        //     ),
                        //     Expanded(
                        //       child: Text(
                        //         maxLines: 1,
                        //         overflow: TextOverflow.ellipsis,
                        //         modelSingleProduct.value.bookingProduct!.lowestDeliveryPrice == ""
                        //             ? "0"
                        //             : modelSingleProduct.value.bookingProduct!.lowestDeliveryPrice.toString(),
                        //         style: GoogleFonts.poppins(
                        //             color: const Color(0xFF014E70), fontSize: 14, fontWeight: FontWeight.w500),
                        //       ),
                        //     ),
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
                                    .value.bookingProduct!.storemeta!.storeName
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
                            if (modelSingleProduct.value.bookingProduct!
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
                                    .value.bookingProduct!.storemeta!.storeId
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
                              modelSingleProduct.value.bookingProduct!
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
                              modelSingleProduct.value.bookingProduct!
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
                        modelSingleProduct.value.bookingProduct!.storemeta!
                                    .commercialLicense !=
                                ""
                            ? Center(
                                child: CachedNetworkImage(
                                  imageUrl: modelSingleProduct
                                      .value
                                      .bookingProduct!
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
                        modelSingleProduct.value.bookingProduct!.storemeta!
                                    .document2 !=
                                ""
                            ? Center(
                                child: CachedNetworkImage(
                                  imageUrl: modelSingleProduct.value
                                      .bookingProduct!.storemeta!.document2
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
                        GestureDetector(
                          onTap: () {
                            Get.to(() => SingleStoreScreen(
                                storeDetails: VendorStoreData(
                                    id: modelSingleProduct.value.bookingProduct!
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
                        const SizedBox(
                          height: 20,
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
                                          Get.to(
                                              () =>
                                                  const VarientsProductScreen(),
                                              arguments: item.id.toString());
                                        } else if (item.productType ==
                                                'booking' &&
                                            item.itemType == 'product') {
                                          imagesList.clear();
                                          id = item.id.toString();
                                          getProductDetails(context: context);
                                          _scrollToTop();
                                          Get.to(
                                              () =>
                                                  const BookableProductScreen(),
                                              arguments: item.id.toString());
                                        } else if (item.productType ==
                                                'virtual_product' &&
                                            item.itemType ==
                                                'virtual_product') {
                                          Get.to(
                                              () =>
                                                  const VritualProductScreen(),
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
                                                            "No International Shipping Available"
                                                                .tr)
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
