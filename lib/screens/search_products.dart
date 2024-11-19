import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dirise/repository/repository.dart';
import 'package:dirise/screens/app_bar/common_app_bar.dart';
import 'package:dirise/screens/product_details/product_widget.dart';
import 'package:dirise/screens/service_single_ui.dart';
import 'package:dirise/utils/api_constant.dart';
import 'package:dirise/utils/helper.dart';
import 'package:dirise/widgets/loading_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../controller/profile_controller.dart';
import '../model/model_virtual_assets.dart';
import '../model/product_model/model_product_element.dart';
import '../model/search_model.dart';
import '../single_products/advirtising_single.dart';
import '../single_products/bookable_single.dart';
import '../single_products/give_away_single.dart';
import '../single_products/simple_product.dart';
import '../single_products/variable_single.dart';
import '../single_products/vritual_product_single.dart';
import '../widgets/common_colour.dart';

class SearchProductsScreen extends StatefulWidget {
  final String searchText;

  const SearchProductsScreen({Key? key, required this.searchText})
      : super(key: key);

  @override
  State<SearchProductsScreen> createState() => _SearchProductsScreenState();
}

class _SearchProductsScreenState extends State<SearchProductsScreen> {
  late TextEditingController textEditingController;
  final Repositories repositories = Repositories();
  ModelVirtualAssets modelProductsList = ModelVirtualAssets(product: []);
  Rx<ModelSearch> modelSearch = ModelSearch().obs;
  RxInt refreshInt = 0.obs;
  int page = 1;
  bool allLoaded = false;
  bool paginating = false;
  final ScrollController scrollController = ScrollController();
  final profileController = Get.put(ProfileController());
  Timer? timer;

  debounceSearch() {
    if (timer != null) {
      timer!.cancel();
    }
    searchProducts(reset: true);
  }

  addScrollListener() {
    scrollController.addListener(() {
      if (scrollController.offset >
          (scrollController.position.maxScrollExtent - 10)) {
        searchProducts();
      }
    });
  }

  searchProducts({bool? reset}) {
    if (reset == true) {
      allLoaded = false;
      paginating = false;
      page = 1;
    }

    if (allLoaded) return;
    if (paginating) return;
    paginating = true;
    refreshInt.value = -2;
    repositories
        .postApi(
            url: ApiUrls.searchProductUrl,
            mapData: {
              'search': textEditingController.text.trim(),
              'page': page,
              'limit': "20",
            },
            showResponse: true)
        .then((value) {
      log('objecttttt${value.toString()}');
      paginating = false;
      if (reset == true) {
        modelProductsList.product = [];
      }
      modelSearch.value = ModelSearch.fromJson(jsonDecode(value));
      // ModelVirtualAssets response = ModelVirtualAssets.fromJson(jsonDecode(value));
      // log('dataaaaaaa${response.product.toString()}');
      // response.product ??= [];
      // if (response.product!.isNotEmpty) {
      //   modelProductsList.product!.addAll(response.product!);
      //   page++;
      // }
      // else {
      //   allLoaded = true;
      // }
      // refreshInt.value = DateTime
      //     .now()
      //     .millisecondsSinceEpoch;
    });
  }

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController(text: widget.searchText);
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      searchProducts();
      addScrollListener();
    });
  }

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
  }

  RxBool isType = false.obs;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: CommonAppBar(
          titleText: "Search".tr,
          backGroundColor: AppTheme.newPrimaryColor,
          textColor: Colors.black,
        ),
        body: RefreshIndicator(onRefresh: () async {
          // await getAllAsync();
        }, child: Obx(() {
          return modelSearch.value.status == 'success'
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        color: AppTheme.newPrimaryColor,
                        child: Column(
                          children: [
                            Hero(
                              tag: "search_tag",
                              child: Material(
                                color: Colors.transparent,
                                surfaceTintColor: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: TextField(
                                    controller: textEditingController,
                                    style: GoogleFonts.poppins(fontSize: 16),
                                    textInputAction: TextInputAction.search,
                                    onChanged: (value) {
                                      debounceSearch();
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
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8)),
                                            borderSide: BorderSide(
                                                color: AppTheme.buttonColor)),
                                        disabledBorder:
                                            const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8)),
                                                borderSide: BorderSide(
                                                    color:
                                                        AppTheme.buttonColor)),
                                        focusedBorder: const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8)),
                                            borderSide: BorderSide(
                                                color: AppTheme.buttonColor)),
                                        fillColor: Colors.white,
                                        contentPadding:
                                            const EdgeInsets.all(15),
                                        hintText: 'Search in Dirise'.tr,
                                        hintStyle: GoogleFonts.poppins(
                                            color: AppTheme.buttonColor,
                                            fontWeight: FontWeight.w400)),
                                    onTap: () {
                                      setState(() {
                                        isType.value = true;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                      if (modelSearch.value.data!.items == null ||
                          modelSearch.value.data!.items!.isEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Image(
                            //     height: context.getSize.height * .24,
                            //     image: const AssetImage(
                            //       'assets/images/bucket.png',
                            //     )),
                            Lottie.asset("assets/loti/wishlist.json"),
                            Center(
                              child: Text(
                                '${textEditingController.text} ${'not found'}'
                                    .tr,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500, fontSize: 22),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            // ElevatedButton(
                            //     onPressed: () {
                            //       // Get.toNamed(editprofileScreen);
                            //     },
                            //     style: ButtonStyle(
                            //       backgroundColor: MaterialStateProperty.all(AppTheme.buttonColor),
                            //       padding: MaterialStateProperty.all(
                            //           const EdgeInsets.symmetric(horizontal: 35, vertical: 13)),
                            //     ),
                            //     child: Text(
                            //       'Shop now!',
                            //       style: GoogleFonts.poppins(
                            //           color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                            //     ))
                          ],
                        ),
                      Container(
                        color: Colors.white,
                        child: Obx(() {
                          if (refreshInt.value > 0) {}
                          return GridView.builder(
                            controller: scrollController,
                            shrinkWrap: true,
                            itemCount: modelSearch.value.data!.items!.length,
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 15),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 5,
                                    mainAxisSpacing: 20,
                                    childAspectRatio: MediaQuery.of(context)
                                            .size
                                            .width /
                                        (MediaQuery.of(context).size.height /
                                            1.3)),
                            itemBuilder: (BuildContext context, int index) {
                              final item =
                                  modelSearch.value.data!.items![index];
                              return GestureDetector(
                                onTap: () {
                                  print(item.id);

                                  if (item.itemType == 'giveaway') {
                                    log('logging 1');
                                    Get.to(() => const GiveAwayProduct(),
                                        arguments: item.id.toString());
                                  } else if (item.productType == 'variants' &&
                                      item.itemType == 'product') {
                                    log('logging 2');
                                    Get.to(() => const VarientsProductScreen(),
                                        arguments: item.id.toString());
                                  } else if (item.productType == 'booking' &&
                                      item.itemType == 'product') {
                                    log('logging 3');
                                    Get.to(() => const BookableProductScreen(),
                                        arguments: item.id.toString());
                                  } else if (item.productType ==
                                          'virtual_product' &&
                                      item.itemType == 'virtual_product') {
                                    log('logging 4');
                                    Get.to(() => VritualProductScreen(),
                                        arguments: item.id.toString());
                                  } else if (item.itemType == 'product') {
                                    if (item.pname
                                            .toLowerCase()
                                            .contains('apartment') ||
                                        item.pname
                                            .toLowerCase()
                                            .contains('car')) {
                                      item.inStock == '-1'
                                          ? Get.to(
                                              () =>
                                                  const AdvirtismentProductScreen(),
                                              arguments: item.id.toString())
                                          : Get.to(
                                              () => const SimpleProductScreen(),
                                              arguments: item.id.toString());
                                    
                                    } else {
                                      log('logging 5 ${item.toString()}');
                                      Get.to(() => const SimpleProductScreen(),
                                          arguments: item.id.toString());
                                    }
                                  } else if (item.itemType == 'service') {
                                    log('logging 6');
                                    Get.to(() => const ServiceProductScreen(),
                                        arguments: item.id.toString());
                                  }
                                },
                                // onTap: (){
                                //
                                //   bottomSheet(productDetails:  ProductElement.fromJson(modelSearch.value.data!.items![index].toJson()), context: context);
                                // },
                                child: item.itemType != 'giveaway'
                                    ? Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border:
                                                Border.all(color: Colors.grey)),
                                        constraints: BoxConstraints(
                                          minWidth: 0,
                                          maxWidth: size.width * .45,
                                        ),
                                        // color: Colors.red,
                                        margin: const EdgeInsets.only(right: 4),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Stack(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  item.discountOff != '0.00'
                                                      ? Container(
                                                          padding: profileController
                                                                      .selectedLAnguage
                                                                      .value ==
                                                                  "English"
                                                              ? const EdgeInsets
                                                                  .all(4)
                                                              : const EdgeInsets
                                                                  .all(8),
                                                          width: 100,
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
                                                                        profileController.selectedLAnguage.value == "English"
                                                                            ? 12
                                                                            : 10,
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
                                                      : const SizedBox.shrink(),
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl: item
                                                                  .featuredImage
                                                                  .toString(),
                                                              height: 100,
                                                              fit: BoxFit.cover,
                                                              errorWidget:
                                                                  (context, url,
                                                                          error) =>
                                                                      Icon(
                                                                Icons
                                                                    .report_gmailerrorred_rounded,
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .error,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 4,
                                                  ),
                                                  // Text(
                                                  //   // "${item.discountPercentage ?? ((((item.pPrice.toString().toNum - item.sPrice.toString().toNum) / item.pPrice.toString().toNum) * 100).toStringAsFixed(2))}${''} Off",
                                                  //   '${item.discountOff.toString()}% Off',
                                                  //   style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xffC22E2E)),
                                                  // ),
                                                  // const SizedBox(
                                                  //   height: 3,
                                                  // ),
                                                  Text(
                                                    item.pname.toString(),
                                                    maxLines: 2,
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  const SizedBox(
                                                    height: 3,
                                                  ),
                                                  item.inStock == "-1"
                                                      ? const SizedBox()
                                                      : Text(
                                                          '${item.inStock.toString()} ${'pieces'.tr}',
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade700,
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                        ),
                                                  const SizedBox(
                                                    height: 3,
                                                  ),
                                                  // Row(
                                                  //   children: [
                                                  //     Expanded(
                                                  //       child: Text(
                                                  //         'KWD ${item.discountPrice.toString()}',
                                                  //         style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                                                  //       ),
                                                  //     ),
                                                  //     Text(
                                                  //       'KWD ${item.pPrice.toString()}',
                                                  //       style:GoogleFonts.poppins(
                                                  //           decoration: TextDecoration.lineThrough,
                                                  //           color: const Color(0xff858484),
                                                  //           fontSize: 13,
                                                  //           fontWeight: FontWeight.w500),
                                                  //     ),
                                                  //   ],
                                                  // )
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
                                                                        child: Text.rich(
                                                                            TextSpan(
                                                                          text:
                                                                              '${item.pPrice.toString().split('.')[0]}.',
                                                                          style: GoogleFonts.poppins(
                                                                              decorationColor: Colors.red,
                                                                              decorationThickness: 2,
                                                                              decoration: TextDecoration.lineThrough,
                                                                              color: const Color(0xff19313B),
                                                                              fontSize: 18,
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
                                                                                      // print("date:::::::::::" + widget.productElement.shippingDate);
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
                                                                        )),
                                                                      )
                                                                    : Flexible(
                                                                        child: Text.rich(
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
                                                                                      // print("date:::::::::::" + widget.productElement.shippingDate);
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
                                                                              style: GoogleFonts.poppins(decorationColor: Colors.red, decorationThickness: 2, decoration: TextDecoration.lineThrough, color: const Color(0xff19313B), fontSize: 18, fontWeight: FontWeight.w600),
                                                                            )
                                                                          ],
                                                                        )),
                                                                      )
                                                                : const SizedBox
                                                                    .shrink(),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            profileController
                                                                        .selectedLAnguage
                                                                        .value ==
                                                                    "English"
                                                                ? Flexible(
                                                                    child: Text
                                                                        .rich(
                                                                            TextSpan(
                                                                      text:
                                                                          '${item.discountPrice.toString().split('.')[0]}.',
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        color: Color(
                                                                            0xFF19313B),
                                                                      ),
                                                                      children: [
                                                                        WidgetSpan(
                                                                          alignment:
                                                                              PlaceholderAlignment.middle,
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
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
                                                                                  // print("date:::::::::::" + widget.productElement.shippingDate);
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
                                                                    )),
                                                                  )
                                                                : Flexible(
                                                                    child: Text
                                                                        .rich(
                                                                            TextSpan(
                                                                      children: [
                                                                        WidgetSpan(
                                                                          alignment:
                                                                              PlaceholderAlignment.bottom,
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
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
                                                                                  // print("date:::::::::::" + widget.productElement.shippingDate);
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
                                                                            fontSize:
                                                                                18,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color:
                                                                                Color(0xFF19313B),
                                                                          ),
                                                                        )
                                                                      ],
                                                                    )),
                                                                  ),
                                                          ],
                                                        )
                                                      : const SizedBox.shrink(),
                                                ],
                                              ),
                                              // Positioned(
                                              //   top: 0,
                                              //   right: 10,
                                              //   child: Obx(() {
                                              //     if (wishListController.refreshFav.value > 0) {}
                                              //     return LikeButton(
                                              //       onPressed: () {
                                              //         if (wishListController.favoriteItems.contains(widget.productElement.id.toString())) {
                                              //           removeFromWishList();
                                              //         } else {
                                              //           addToWishList();
                                              //         }
                                              //       },
                                              //       isLiked: wishListController.favoriteItems.contains(widget.productElement.id.toString()),
                                              //     );
                                              //   }),
                                              // )
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border:
                                                Border.all(color: Colors.grey)),
                                        constraints: BoxConstraints(
                                          minWidth: 0,
                                          maxWidth: size.width * .45,
                                        ),
                                        // color: Colors.red,
                                        margin: const EdgeInsets.only(right: 4),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Stack(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  18.spaceY,
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl: item
                                                                  .featuredImage
                                                                  .toString(),
                                                              height: 100,
                                                              fit: BoxFit.cover,
                                                              errorWidget:
                                                                  (context, url,
                                                                          error) =>
                                                                      Icon(
                                                                Icons
                                                                    .report_gmailerrorred_rounded,
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .error,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  // Text(
                                                  //   // "${item.discountPercentage ?? ((((item.pPrice.toString().toNum - item.sPrice.toString().toNum) / item.pPrice.toString().toNum) * 100).toStringAsFixed(2))}${''} Off",
                                                  //   '${item.discountOff.toString()}% Off',
                                                  //   style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xffC22E2E)),
                                                  // ),
                                                  const SizedBox(
                                                    height: 3,
                                                  ),
                                                  Text(
                                                    item.pname.toString(),
                                                    maxLines: 2,
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  const SizedBox(
                                                    height: 3,
                                                  ),
                                                  item.inStock == "-1"
                                                      ? SizedBox()
                                                      : Text(
                                                          '${item.inStock.toString()} ${'pieces'.tr}',
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade700,
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                        ),
                                                  const SizedBox(
                                                    height: 3,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          'KWD ${item.discountPrice.toString()}',
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                        ),
                                                      ),
                                                      // Text(
                                                      //   'KWD ${item.pPrice.toString()}',
                                                      //   style:GoogleFonts.poppins(
                                                      //       decoration: TextDecoration.lineThrough,
                                                      //       color: const Color(0xff858484),
                                                      //       fontSize: 13,
                                                      //       fontWeight: FontWeight.w500),
                                                      // ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                              Positioned(
                                                right: 0,
                                                top: 0,
                                                child: Container(
                                                  width: 100,
                                                  decoration:
                                                      const BoxDecoration(
                                                          boxShadow: [
                                                        BoxShadow(
                                                          // blurStyle: BlurStyle.outer,
                                                          offset: Offset(2, 3),
                                                          color: Colors.black26,
                                                          blurRadius: 3,
                                                        )
                                                      ],
                                                          color: Color(
                                                              0xFFFFDF33)),
                                                  child: Center(
                                                    child: Text(
                                                      "Free",
                                                      style: GoogleFonts.poppins(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: const Color(
                                                              0xFF0C0D0C)),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                )
              : const LoadingAnimation();
        })));
  }
}
