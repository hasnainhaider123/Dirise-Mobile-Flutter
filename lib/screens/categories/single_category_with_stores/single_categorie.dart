import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dirise/language/app_strings.dart';
import 'package:dirise/repository/repository.dart';
import 'package:dirise/utils/helper.dart';
import 'package:dirise/widgets/loading_animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../controller/homepage_controller.dart';
import '../../../controller/profile_controller.dart';
import '../../../model/CarsSubCateGoryModel.dart';
import '../../../model/getSubCategoryModel.dart';
import '../../../model/model_category_list.dart';
import '../../../model/model_category_stores.dart';
import '../../../model/product_model/model_product_element.dart';
import '../../../model/vendor_models/model_category_list.dart';
import '../../../model/vendor_models/model_single_vendor.dart';
import '../../../model/vendor_models/vendor_category_model.dart';
import '../../../shop_by_product.dart';
import '../../../utils/api_constant.dart';
import '../../../vendor/authentication/vendor_plans_screen.dart';
import '../../../vendor/dashboard/dashboard_screen.dart';
import '../../../widgets/cart_widget.dart';
import '../../../widgets/common_colour.dart';
import '../../app_bar/common_app_bar.dart';
import '../../auth_screens/login_screen.dart';
import '../../home_pages/coustom_drawer.dart';
import '../../product_details/product_widget.dart';
import '../../search_products.dart';
import 'single_store_screen.dart';

class SingleCategories extends StatefulWidget {
  const SingleCategories({super.key, required this.vendorCategories});

  final VendorCategoriesData vendorCategories;

  @override
  State<SingleCategories> createState() => _SingleCategoriesState();
}

class _SingleCategoriesState extends State<SingleCategories> {
  final Repositories repositories = Repositories();
  int paginationPage = 1;

  VendorCategoriesData get mainCategory => widget.vendorCategories;

  String get categoryID => widget.vendorCategories.id.toString();
  List<ModelCategoryStores>? modelCategoryStores;
  bool allLoaded = false;
  bool paginationLoading = false;

  @override
  void initState() {
    super.initState();
    getCategoryFilter();
    getCategoryStores(
      page: paginationPage,
    );
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollController.addListener(() {
        paginateApi();
      });
    });
  }

  Future<String> _fetchProductCount(String storeId) async {
    try {
      String url = ApiUrls.getVendorInfoUrl + storeId;
      String response = await repositories.getApi(url: url);
      ModelSingleVendor vendor =
          ModelSingleVendor.fromJson(jsonDecode(response));
      return vendor.productCount.toString();
    } catch (e) {
      // Handle errors
      return '0';
    }
  }

  paginateApi() {
    if (_scrollController.offset >
        _scrollController.position.maxScrollExtent - 40) {
      getCategoryStores(page: paginationPage);
    }
  }

  RxInt refreshInt = 0.obs;

  Map<String, String> selectedIds = {};

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

  final profileController = Get.put(ProfileController());

  showVendorDialog() {
    if (Platform.isAndroid) {
      showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.vendorRegister,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    10.spaceY,
                    TextButton(
                        onPressed: () {
                          Get.back();
                          Get.toNamed(
                            LoginScreen.route,
                          );
                        },
                        child: Text(AppStrings.createAccount))
                  ],
                ),
              ),
            );
          });
      return;
    }
    if (Platform.isIOS) {
      showDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text(
                "${'To register as vendor partner need to '.tr}"
                "${'create an account first.'.tr}",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 16),
              ),
              actions: [
                CupertinoDialogAction(
                    onPressed: () {
                      Get.back();
                      Get.toNamed(
                        LoginScreen.route,
                      );
                    },
                    child: Text("Create Account".tr))
              ],
            );
          });
      return;
    }
  }

  final RxBool _isValue = false.obs;

  List<Widget> vendorPartner() {
    return [];
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
  String subCategory = '';

  Future getCategoryStores(
      {required int page, String? search, bool? resetAll}) async {
    if (resetAll == true) {
      allLoaded = false;
      paginationLoading = false;
      paginationPage = 1;
      modelCategoryStores = null;
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
    print("Category_id-----:::${categoryID}");
    paginationLoading = true;
    refreshInt.value = DateTime.now().millisecondsSinceEpoch;
    if (modelCategoryList == null) {
      await repositories
          .getApi(
              url: "${ApiUrls.getCategoryStoresUrl}$url", showResponse: true)
          .then((value) {
        modelCategoryStores ??= [];
        paginationLoading = false;
        refreshInt.value = DateTime.now().millisecondsSinceEpoch;
        final response = ModelCategoryStores.fromJson(jsonDecode(value));
        if (response.user!.data!.isNotEmpty &&
            !modelCategoryStores!
                .map((e) => e.user!.currentPage.toString())
                .toList()
                .contains(response.user!.currentPage.toString())) {
          modelCategoryStores!.add(response);
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
      subCategory = kk;
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
        modelCategoryStores ??= [];
        paginationLoading = false;
        refreshInt.value = DateTime.now().millisecondsSinceEpoch;
        final response = ModelCategoryStores.fromJson(jsonDecode(value));
        if (response.user!.data!.isNotEmpty &&
            !modelCategoryStores!
                .map((e) => e.user!.currentPage.toString())
                .toList()
                .contains(response.user!.currentPage.toString())) {
          modelCategoryStores!.add(response);
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
        modelCategoryStores ??= [];
        paginationLoading = false;
        refreshInt.value = DateTime.now().millisecondsSinceEpoch;
        final response = ModelCategoryStores.fromJson(jsonDecode(value));
        if (response.user!.data!.isNotEmpty &&
            !modelCategoryStores!
                .map((e) => e.user!.currentPage.toString())
                .toList()
                .contains(response.user!.currentPage.toString())) {
          modelCategoryStores!.add(response);
          paginationPage++;
        } else {
          allLoaded = true;
        }
        setState(() {});
      });
    }
  }

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

  List<CarsSubCateGoryModel> model = <CarsSubCateGoryModel>[];
  // Future getSubCategory() async {
  //   Map<String, dynamic> map = {};
  //   map['category_id'] = subCategory.toString();
  //   repositories.postApi(url: ApiUrls.subCategory, mapData: map, showResponse: true).then((value) {
  //     SubCategoryModel newSubCategoryModel = SubCategoryModel.fromJson(jsonDecode(value));
  //
  //     // Append new data to the existing list
  //     if (carsSubCateGoryModel.value.data != null) {
  //       carsSubCateGoryModel.value.data!.subCategories!.addAll(newSubCategoryModel.data!.subc);
  //     } else {
  //       carsSubCateGoryModel.value = newSubCategoryModel;
  //     }
  //
  //     // Trigger UI update
  //     subCategoryModel.refresh();
  //   });
  // }

  final RxBool search = false.obs;
  final ScrollController _scrollController = ScrollController();
  final bottomController = Get.put(BottomNavBarController());

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  final scaffoldKey1 = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey1,
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: kToolbarHeight + 20,
        backgroundColor: Color(0xFFF2F2F2),
        surfaceTintColor: Color(0xFFF2F2F2),
        leading: Padding(
          padding: EdgeInsets.only(right: 8, left: 8),
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
              : SizedBox.shrink(),
        ),
      ),
      drawer: const CustomDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          // await getCategoryFilter();
          // await getCategoryStores(page: paginationPage, resetAll: true);
        },
        child: CustomScrollView(
          shrinkWrap: true,
          controller: _scrollController,
          slivers: [
            if (modelCategoryStores != null)
              for (var i = 0; i < modelCategoryStores!.length; i++) ...list1(i)
            else
              const SliverToBoxAdapter(
                child: LoadingAnimation(),
              ),
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
                          if (modelCategoryList!.vendorSubCategory!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: StatefulBuilder(builder: (c, newState) {
                                return PopupMenuButton(
                                  position: PopupMenuPosition.under,
                                  child: Container(
                                    height: 36,
                                    constraints: BoxConstraints(
                                        maxWidth: context.getSize.width * .75),
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                                                left: 8, right: 10),
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
                                                  color:
                                                      const Color(0xff014E70)),
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                            Icons.keyboard_arrow_down_outlined,
                                            color: Color(0xff014E70))
                                      ],
                                    ),
                                  ),
                                  itemBuilder: (c) {
                                    return modelCategoryList!.vendorSubCategory!
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
                                      padding: const EdgeInsets.only(right: 10),
                                      child: StatefulBuilder(
                                          builder: (c, newState) {
                                        return PopupMenuButton(
                                          position: PopupMenuPosition.under,
                                          child: Container(
                                            height: 36,
                                            constraints: BoxConstraints(
                                                maxWidth:
                                                    context.getSize.width *
                                                        .75),
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 0, 10, 0),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: const Color(
                                                        0xff014E70)),
                                                // color: const Color(0xffEBF1F4),
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(22)),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Flexible(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8, right: 10),
                                                    child: Text(
                                                      e.selectedCategory != null
                                                          ? e.selectedCategory!
                                                              .title
                                                              .toString()
                                                          : e.title.toString(),
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
                                                      const EdgeInsets.all(8.0),
                                                  child: Image.asset(
                                                      'assets/images/Arrow down.png',
                                                      color: Color(0xff014E70)),
                                                ),
                                                // const Icon(Icons.keyboard_arrow_down_outlined, color: Color(0xff014E70))
                                              ],
                                            ),
                                          ),
                                          itemBuilder: (c) {
                                            return e.childCategory!
                                                .map((ee) => PopupMenuItem(
                                                      child: Text(
                                                          ee.title.toString()),
                                                      onTap: () {
                                                        e.selectedCategory = ee;
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
                                              position: PopupMenuPosition.under,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10),
                                                child: Container(
                                                  height: 36,
                                                  constraints: BoxConstraints(
                                                      maxWidth: context
                                                              .getSize.width *
                                                          .75),
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          10, 0, 10, 0),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: const Color(
                                                            0xff014E70)),
                                                    color:
                                                        const Color(0xffEBF1F4),
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
                                                    .map((ee) => PopupMenuItem(
                                                          child: Text(ee.title
                                                              .toString()),
                                                          onTap: () {
                                                            subCategory = ee.id
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
                          //   children: subCategoryModel.value.data!.map((e) => Padding(
                          //     padding: const EdgeInsets.only(right: 10),
                          //     child: StatefulBuilder(builder: (c, newState) {
                          //       return PopupMenuButton(
                          //         position: PopupMenuPosition.under,
                          //         child: Container(
                          //           height: 36,
                          //           constraints: BoxConstraints(maxWidth: context.getSize.width * .75),
                          //           padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          //           decoration: BoxDecoration(
                          //               border: Border.all(color: const Color(0xff014E70)),
                          //               color: const Color(0xffEBF1F4),
                          //               borderRadius: BorderRadius.circular(22)),
                          //           child: Row(
                          //             mainAxisSize: MainAxisSize.min,
                          //             children: [
                          //               // Flexible(
                          //               //   child: Padding(
                          //               //     padding: const EdgeInsets.only(left: 8, right: 10),
                          //               //     child: Text(
                          //               //       e.selectedCategory != null
                          //               //           ? e.selectedCategory!.title.toString()
                          //               //           : e.title.toString(),
                          //               //       style: GoogleFonts.poppins(
                          //               //           fontSize: 14,
                          //               //           fontWeight: FontWeight.w500,
                          //               //           color: const Color(0xff014E70)),
                          //               //     ),
                          //               //   ),
                          //               // ),
                          //               const Icon(Icons.keyboard_arrow_down_outlined, color: Color(0xff014E70))
                          //             ],
                          //           ),
                          //         ),
                          //         itemBuilder: (c) {
                          //           return e.childCategory!
                          //               .map((ee) => PopupMenuItem(
                          //             child: Text(ee.title.toString()),
                          //             onTap: () {
                          //               e.selectedCategory = ee;
                          //               getCategoryStores(page: 1, resetAll: true);
                          //               getSubCategory();
                          //               isSelect = true;
                          //               newState(() {});
                          //             },
                          //           ))
                          //               .toList();
                          //         },
                          //       );
                          //     }),
                          //   ))
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
                                                    color:
                                                        const Color(0xffEBF1F4),
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
                        if (selectedValue1 == "Shop by product" ||
                            selectedValue1 == 'تسوق حسب المنتج') {
                          Get.to(
                            () => ShopProductScreen(
                                vendorCategories: widget.vendorCategories),
                            arguments: widget.vendorCategories.id.toString(),
                          );
                        }
                        print("Selected value: " + selectedValue1.toString());
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
                          selectedValue1 ?? 'Shop by vendor'.tr,
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
            const SliverToBoxAdapter(
                // child: SizedBox(
                //   height: 20,
                // ),
                ),
            if (modelCategoryStores != null)
              for (var i = 0; i < modelCategoryStores!.length; i++) ...list(i)
            else
              const SliverToBoxAdapter(
                child: LoadingAnimation(),
              ),
            if (modelCategoryStores != null && modelCategoryStores!.isEmpty)
              SliverToBoxAdapter(
                child: Center(child: Text(AppStrings.notHaveAnyProduct.tr)),
              ),
            SliverToBoxAdapter(
              child: Obx(() {
                if (refreshInt.value > 0) {}
                return paginationLoading && modelCategoryStores != null
                    ? const LoadingAnimation()
                    : const SizedBox.shrink();
              }),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> list(int i) {
    return [
      if (modelCategoryStores![i].promotionData != null &&
          modelCategoryStores![i].promotionData!.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16).copyWith(top: 10),
            child: GestureDetector(
              onTap: () {
                final kk = modelCategoryStores![i].promotionData![min(
                    i % 3, modelCategoryStores![i].promotionData!.length - 1)];
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
                  // height: context.getSize.height * .3,
                  // width: double.maxFinite,
                  // child: CachedNetworkImage(
                  //   imageUrl: modelCategoryStores![i]
                  //       .promotionData![min(i % 3, modelCategoryStores![i].promotionData!.length - 1)]
                  //       .banner
                  //       .toString(),
                  //   fit: BoxFit.contain,
                  //   width: context.getSize.width,
                  //   errorWidget: (_, __, ___) =>
                  //   const Icon(
                  //     Icons.error_outline,
                  //     color: Colors.red,
                  //   ),
                  // )).animate().fade(duration: 300.ms)
                ),
              ),
            ),
          ),
        ),
      SliverList.builder(
        itemCount: modelCategoryStores![i].user!.data!.length,
        itemBuilder: (context, index) {
          final store = modelCategoryStores![i].user!.data![index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () {
                Get.to(
                  () => SingleStoreScreen(storeDetails: store),
                  arguments: mainCategory.name.toString().tr,
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xffDCDCDC)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 10, 15, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 85,
                        width: 100,
                        child: Hero(
                          tag: store.storeLogo.toString(),
                          child: Material(
                            color: Colors.transparent,
                            surfaceTintColor: Colors.transparent,
                            child: CachedNetworkImage(
                              imageUrl: store.storeLogo.toString(),
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  Image.asset('assets/images/new_logo.png'),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.storeName.toString(),
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5, bottom: 5),
                              child: Text(
                                store.description.toString(),
                                maxLines: 1,
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.withOpacity(.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            // Use FutureBuilder to fetch product count
                            FutureBuilder<String>(
                              future: _fetchProductCount(store.id.toString()),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text(
                                    'Loading...',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xff014E70),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text(
                                    'Error',
                                    style: GoogleFonts.poppins(
                                      color: Colors.red,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                } else {
                                  String productCount = snapshot.data ?? '0';
                                  return Text(
                                    "$productCount ${AppStrings.items.tr}",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xff014E70),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      if (modelCategoryStores![i].product!.isNotEmpty)
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Text(
                  AppStrings.relatedProduct.tr,
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 440,
                margin: const EdgeInsets.only(top: 20),
                child: ListView.builder(
                    itemCount: modelCategoryStores![i].product!.length,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (BuildContext context, int index) {
                      final item = modelCategoryStores![i].product![index];
                      return ProductUI(
                        isSingle: false,
                        productElement: item,
                        onLiked: (value) {
                          modelCategoryStores![i].product![index].inWishlist =
                              value;
                        },
                      );
                    }),
              ),
            ],
          ),
        ),
      const SliverToBoxAdapter(
        child: SizedBox(
          height: 20,
        ),
      ),
    ];
  }

  List<Widget> list1(int i) {
    return [
      if (modelCategoryStores![i].promotionData != null &&
          modelCategoryStores![i].promotionData!.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16).copyWith(top: 10),
            child: GestureDetector(
              onTap: () {
                final kk = modelCategoryStores![i].promotionData![min(
                    i % 3, modelCategoryStores![i].promotionData!.length - 1)];
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
                      height: context.getSize.height * .3,
                      width: double.maxFinite,
                      child: CachedNetworkImage(
                        imageUrl: modelCategoryStores![i]
                            .promotionData![min(
                                i % 3,
                                modelCategoryStores![i].promotionData!.length -
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
      const SliverToBoxAdapter(
        child: SizedBox(
          height: 20,
        ),
      ),
    ];
  }
}
