import 'dart:convert';
import 'dart:developer';

import 'package:dirise/controller/vendor_controllers/add_product_controller.dart';
import 'package:dirise/singleproductScreen/singleProductPriceScreen.dart';
import 'package:dirise/utils/helper.dart';
import 'package:dropdown_search/dropdown_search.dart';
//
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/home_controller.dart';
import '../controller/profile_controller.dart';
import '../controller/vendor_controllers/vendor_profile_controller.dart';
import '../model/CarsSubCateGoryModel.dart';
import '../model/common_modal.dart';
import '../model/getSubCategoryModel.dart';
import '../model/productCategoryModel.dart';
import '../model/vendor_models/add_product_model.dart';
import '../model/vendor_models/model_add_product_category.dart';
import '../model/vendor_models/model_category_list.dart';
import '../model/vendor_models/model_vendor_details.dart';
import '../model/vendor_models/vendor_category_model.dart';
import '../repository/repository.dart';
import '../utils/api_constant.dart';
import '../utils/styles.dart';
import '../widgets/common_button.dart';
import '../widgets/common_colour.dart';
import '../widgets/common_textfield.dart';
import 'ReviewandPublishScreen.dart';

class ProductInformationScreens extends StatefulWidget {
  int? id;
  String? catid;
  String? name;

  ProductInformationScreens({super.key, this.id, this.name, this.catid});

  @override
  State<ProductInformationScreens> createState() =>
      _ProductInformationScreensState();
}

class _ProductInformationScreensState extends State<ProductInformationScreens> {
  ProductCategoryData? selectedSubcategory;
  SubProductData? selectedProductSubcategory;
  bool showFilters = false;
  final TextEditingController ProductNameController = TextEditingController();
  int vendorID = 0;
  int ProductID = 0;
  int tappedIndex = -1;
  final addProductController = Get.put(AddProductController());
  final profileController = Get.put(ProfileController());
  final homeController = Get.put(TrendingProductsController());
  
  deliverySizeApi() {
    Map<String, dynamic> map = {};
    map['category_id'] = idForChild.join(',').toString();
    map['product_name'] = ProductNameController.text.toString();
    map['item_type'] = 'product';
    map['id'] = addProductController.idProduct.value.toString();
    /////please change this when image ui is done

    final Repositories repositories = Repositories();
    FocusManager.instance.primaryFocus!.unfocus();
    repositories
        .postApi(
            url: ApiUrls.giveawayProductAddress, context: context, mapData: map)
        .then((value) {
      AddProductModel response = AddProductModel.fromJson(jsonDecode(value));
      print('API Response Status Code: ${response.status}');
      showToast(response.message.toString());
      if (response.status == true) {
        addProductController.idProduct.value =
            response.productDetails!.product!.id.toString();
        print(addProductController.idProduct.value.toString());
        if (widget.id != null) {
          Get.to(ProductReviewPublicScreen());
        } else {
          Get.to(SingleProductPriceScreen());
        }
      }
    });
  }

  ModelVendorCategory modelVendorCategory = ModelVendorCategory(usphone: []);
  Rx<ModelCategoryList> productCategoryModel = ModelCategoryList().obs;
  Rx<RxStatus> vendorCategoryStatus = RxStatus.empty().obs;
  final GlobalKey categoryKey = GlobalKey();
  final GlobalKey subcategoryKey = GlobalKey();
  final GlobalKey productsubcategoryKey = GlobalKey();
  Map<String, VendorCategoriesData> allSelectedCategory = {};

  final Repositories repositories = Repositories();

  VendorUser get vendorInfo => vendorProfileController.model.user!;
  final vendorProfileController = Get.put(VendorProfileController());

  void getVendorCategories() {
    vendorCategoryStatus.value = RxStatus.loading();
    repositories
        .getApi(url: ApiUrls.vendorCategoryListUrl, showResponse: false)
        .then((value) {
      modelVendorCategory = ModelVendorCategory.fromJson(jsonDecode(value));
      vendorCategoryStatus.value = RxStatus.success();

      for (var element in vendorInfo.vendorCategory!) {
        allSelectedCategory[element.id.toString()] =
            VendorCategoriesData.fromJson(element.toJson());
      }
      setState(() {});
    }).catchError((e) {
      vendorCategoryStatus.value = RxStatus.error();
    });
  }

  List<ProductCategoryData> fetchedDropdownItems = [];
  List<SubProductData> subProductData = [];

  void fetchDataBasedOnId(int id) async {
    String apiUrl = 'https://admin.diriseapp.com/api/product-category?id=$id';
    await repositories.getApi(url: apiUrl).then((value) {
      productCategoryModel.value =
          ModelCategoryList.fromJson(jsonDecode(value));
      // setState(() {
      //   fetchedDropdownItems = productCategoryModel.productdata ?? [];
      // });
    });
  }

  SubCategoryModel subProductCategoryModel = SubCategoryModel();

  void fetchSubCategoryBasedOnId(int id1) async {
    String apiUrl1 =
        'https://admin.diriseapp.com/api/product-subcategory?category_id=$id1';
    await repositories.getApi(url: apiUrl1).then((value) {
      subProductCategoryModel = SubCategoryModel.fromJson(jsonDecode(value));
      setState(() {
        subProductData = subProductCategoryModel.data ?? [];
      });
    });
  }

  RxString categoryName = "".obs;
  RxString productName = "".obs;
  RxString subName = "".obs;
  RxString id = "".obs;
  bool isItemDetailsVisible = false;
  bool isItemDetailsVisible1 = false;
  bool isItemDetailsVisible2 = false;
  bool isItemDetailsVisible3 = false;
  final productController = Get.put(AddProductController());

  Rx<CarsSubCateGoryModel> carsSubCateGoryModel = CarsSubCateGoryModel().obs;
  String subCategory = '';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getVendorCategories();
    productController.getProductsCategoryList();
    log('sgdsfgsdfg${productController.modelCategoryList?.data!.length}');
    if (productController.modelCategoryList != null &&
        productController.modelCategoryList!.data != null &&
        productController.modelCategoryList!.data!.isNotEmpty) {
      fetchDataBasedOnId(
          productController.modelCategoryList!.data![0].vendorCategory);
    }

    fetchSubCategoryBasedOnId(ProductID);
    if (widget.id != null) {
      ProductNameController.text = widget.name.toString();
      // productController.modelCategoryList!.vendorCategoryName = widget.catid.toString();
    }
  }

  String idChild = '';
  List<int?> idForChild = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
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
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Product Information'.tr,
              style: GoogleFonts.poppins(
                  color: const Color(0xff292F45),
                  fontWeight: FontWeight.w600,
                  fontSize: 20),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product name'.tr,
                style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 18),
              ),
              CommonTextField(
                  controller: ProductNameController,
                  obSecure: false,
                  hintText: 'Name'.tr,
                  validator: MultiValidator([
                    RequiredValidator(errorText: 'Product Name is required'.tr),
                  ])),
              const SizedBox(
                height: 10,
              ),
              if (productController.modelCategoryList != null)
                Text(
                  profileController.selectedLAnguage.value == 'English'
                      ? productController.modelCategoryList!.vendorCategoryName
                          .toString()
                      : productController
                          .modelCategoryList!.vendorCategoryArabName
                          .toString(),
                  style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
              const SizedBox(
                height: 10,
              ),
              // const Text(
              //   'Select Vendor Category',
              //   style: TextStyle(fontWeight: FontWeight.bold),
              // ),
              // /// Inside the build method of your stateful widget
              // GestureDetector(
              //   onTap: () {
              //     isItemDetailsVisible = !isItemDetailsVisible;
              //     idForChild.clear();
              //     productCategoryModel.value = ModelCategoryList();
              //     setState(() {});
              //   },
              //   child: Container(
              //     padding: const EdgeInsets.all(10),
              //     height: 50,
              //     decoration: BoxDecoration(
              //         color: Colors.grey.shade200,
              //         borderRadius: BorderRadius.circular(10),
              //         border: Border.all(color: Colors.grey.shade400, width: 1)),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text(
              //           categoryName.value == "" ? 'Select category to choose' : categoryName.value,
              //         ),
              //         Icon(Icons.arrow_drop_down_sharp),
              //       ],
              //     ),
              //   ),
              // ),

              // this is for search
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     const Text(
              //       'Search Vendor Category',
              //       style: TextStyle(fontWeight: FontWeight.bold),
              //     ),
              //     const SizedBox(height: 5),
              //     TextField(
              //       onChanged: (value) {
              //         fetchedDropdownItems = modelVendorCategory.usphone!
              //             .where((element) =>
              //             element.name.toLowerCase().contains(value.toLowerCase()))
              //             .map((vendorCategory) => ProductCategoryData(
              //             id: vendorCategory.id,
              //             title: vendorCategory.name)) // Convert vendor category to product category
              //             .toList();
              //         setState(() {});
              //       },
              //       decoration: InputDecoration(
              //         hintText: 'Search',
              //         prefixIcon: const Icon(Icons.search),
              //         border: OutlineInputBorder(
              //           borderRadius: BorderRadius.circular(10),
              //         ),
              //       ),
              //     ),
              //     const SizedBox(height: 10),
              //     ListView.builder(
              //       itemCount: fetchedDropdownItems.length,
              //       shrinkWrap: true,
              //       physics: const NeverScrollableScrollPhysics(),
              //       itemBuilder: (context, index) {
              //         var data = fetchedDropdownItems[index];
              //         return GestureDetector(
              //           onTap: () {
              //             fetchDataBasedOnId(data.id);
              //             isItemDetailsVisible = !isItemDetailsVisible;
              //             categoryName.value = data.title.toString();
              //             id.value = data.id.toString();
              //             setState(() {
              //               tappedIndex = index;
              //             });
              //           },
              //           child: Container(
              //             margin: const EdgeInsets.only(bottom: 5),
              //             padding: const EdgeInsets.all(10),
              //             height: 50,
              //             decoration: BoxDecoration(
              //                 color: Colors.grey.shade200,
              //                 borderRadius: BorderRadius.circular(10),
              //                 border: Border.all(color: tappedIndex == index ? AppTheme.buttonColor : Colors.grey.shade400, width: 2)),
              //             child: Text(data.title),
              //           ),
              //         );
              //       },
              //     ),
              //   ],
              // ),

              // Visibility(
              //   visible: isItemDetailsVisible,
              //   child: ListView.builder(
              //       itemCount: modelVendorCategory.usphone!.length,
              //       shrinkWrap: true,
              //       physics: const NeverScrollableScrollPhysics(),
              //       itemBuilder: (context, index) {
              //         var data = modelVendorCategory.usphone![index];
              //         return GestureDetector(
              //           onTap: () {
              //             fetchDataBasedOnId(data.id);
              //             isItemDetailsVisible = !isItemDetailsVisible;
              //             categoryName.value = data.name.toString();
              //             id.value = data.id.toString();
              //             setState(() {});
              //           },
              //           child: Container(
              //               margin: EdgeInsets.only(bottom: 5),
              //               padding: const EdgeInsets.all(10),
              //               height: 50,
              //               decoration: BoxDecoration(
              //                   color: Colors.grey.shade200,
              //                   borderRadius: BorderRadius.circular(10),
              //                   border: Border.all(color: Colors.grey.shade400, width: 1)),
              //               child: Text(data.name)),
              //         );
              //       }),
              // ),
              const SizedBox(
                height: 10,
              ),
              Obx(() {
                bool showButton = productCategoryModel.value.data != null &&
                    productCategoryModel.value.data!
                        .any((value) => value.childCategory != null);

                return showButton
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            showFilters = !showFilters;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Color(0xff292F45),
                              borderRadius: BorderRadius.circular(11)),
                          child: Text(
                            'Filters(Optional)'.tr,
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                        ),
                      )
                    : const SizedBox();
              }),

              const SizedBox(
                height: 15,
              ),
              showFilters
                  ? Wrap(
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      runAlignment: WrapAlignment.start,
                      spacing: 6,
                      children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: carsSubCateGoryModel.value.data != null
                                ? Row(
                                    children: [
                                      if (carsSubCateGoryModel.value.data!
                                          .subCategories!.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          child: StatefulBuilder(
                                              builder: (c, newState) {
                                            return SizedBox(
                                              height: 40,
                                              child: ListView.builder(
                                                  itemCount: model.length,
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemBuilder: (c, i) {
                                                    return ListView.builder(
                                                      itemCount: 1,
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemBuilder:
                                                          (context, index) {
                                                        //   final subCategorys = carsSubCateGoryModel.value.data!.subCategories![index];
                                                        return PopupMenuButton(
                                                          position:
                                                              PopupMenuPosition
                                                                  .under,
                                                          child: Container(
                                                            height: 36,
                                                            constraints: BoxConstraints(
                                                                maxWidth: context
                                                                        .getSize
                                                                        .width *
                                                                    .75),
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    10,
                                                                    0,
                                                                    10,
                                                                    0),
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  color: const Color(
                                                                      0xff014E70)),
                                                              // color: const Color(0xffEBF1F4),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          22),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Flexible(
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left: 8,
                                                                        right:
                                                                            10),
                                                                    child: Text(
                                                                      model[i]
                                                                          .data!
                                                                          .subCategories![
                                                                              index]
                                                                          .title
                                                                          .toString(),
                                                                      //     carsSubCateGoryModel.value.data!.subCategories![index].title.toString(),
                                                                      style: GoogleFonts
                                                                          .poppins(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.w500,
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
                                                          itemBuilder: (c) {
                                                            return model[i]
                                                                .data!
                                                                .subCategories!
                                                                .map((ee) =>
                                                                    PopupMenuItem(
                                                                      child: Text(ee
                                                                          .title
                                                                          .toString()),
                                                                      onTap:
                                                                          () {
                                                                        subCategory = ee
                                                                            .id
                                                                            .toString();
                                                                        idForChild
                                                                            .clear();
                                                                        idForChild
                                                                            .add(int.tryParse(subCategory));
                                                                        getSubCategory();
                                                                        newState(
                                                                            () {});
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
                        ])
                  : const SizedBox(),
              showFilters
                  ? Obx(() {
                      return productCategoryModel.value.data != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: productCategoryModel.value.data!
                                  .map((e) => Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            e.title.toString(),
                                            style: normalStyle,
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          // DropdownButtonFormField<int>(
                                          //   isExpanded: true,
                                          //   icon: const Icon(
                                          //       Icons.keyboard_arrow_down),
                                          //   iconDisabledColor:
                                          //       const Color(0xff97949A),
                                          //   iconEnabledColor:
                                          //       const Color(0xff97949A),
                                          //   decoration: InputDecoration(
                                          //     border: InputBorder.none,
                                          //     filled: true,
                                          //     fillColor: const Color(0xffE2E2E2)
                                          //         .withOpacity(.35),
                                          //     contentPadding:
                                          //         const EdgeInsets.symmetric(
                                          //             horizontal: 15,
                                          //             vertical: 14),
                                          //     focusedErrorBorder:
                                          //         const OutlineInputBorder(
                                          //             borderRadius:
                                          //                 BorderRadius.all(
                                          //                     Radius.circular(
                                          //                         8)),
                                          //             borderSide: BorderSide(
                                          //                 color: AppTheme
                                          //                     .secondaryColor)),
                                          //     errorBorder:
                                          //         const OutlineInputBorder(
                                          //             borderRadius:
                                          //                 BorderRadius.all(
                                          //                     Radius
                                          //                         .circular(8)),
                                          //             borderSide: BorderSide(
                                          //                 color: Color(
                                          //                     0xffE2E2E2))),
                                          //     focusedBorder:
                                          //         const OutlineInputBorder(
                                          //             borderRadius:
                                          //                 BorderRadius.all(
                                          //                     Radius.circular(
                                          //                         8)),
                                          //             borderSide: BorderSide(
                                          //                 color: AppTheme
                                          //                     .secondaryColor)),
                                          //     disabledBorder:
                                          //         const OutlineInputBorder(
                                          //       borderRadius: BorderRadius.all(
                                          //           Radius.circular(8)),
                                          //       borderSide: BorderSide(
                                          //           color: AppTheme
                                          //               .secondaryColor),
                                          //     ),
                                          //     enabledBorder:
                                          //         const OutlineInputBorder(
                                          //       borderRadius: BorderRadius.all(
                                          //           Radius.circular(8)),
                                          //       borderSide: BorderSide(
                                          //           color: AppTheme
                                          //               .secondaryColor),
                                          //     ),
                                          //   ),
                                          //   items: e.childCategory!
                                          //       .asMap()
                                          //       .entries
                                          //       .map((ee) => DropdownMenuItem(
                                          //             value: ee.key,
                                          //             child: Text(
                                          //               ee.value.title
                                          //                   .toString(),
                                          //               overflow: TextOverflow
                                          //                   .ellipsis,
                                          //               style:
                                          //                   GoogleFonts.poppins(
                                          //                 color: const Color(
                                          //                     0xff463B57),
                                          //               ),
                                          //             ),
                                          //           ))
                                          //       .toList(),
                                          //   validator: (value) {
                                          //     if (!e.childCategory!
                                          //         .map((k) => k.selected)
                                          //         .toList()
                                          //         .contains(true)) {
                                          //       return "Please select any one category"
                                          //           .tr;
                                          //     }
                                          //     return null;
                                          //   },
                                          //   hint: Text('Select Category'.tr),
                                          //   onChanged: (value) {
                                          //     e.childCategory![value!]
                                          //         .selected = true;
                                          //     idForChild.add(
                                          //         e.childCategory![value].id);
                                          //     idChild = idForChild.join(',');
                                          //     getSubCategory();
                                          //     print(
                                          //         'vafjdfhdjf ${idForChild.toString()}');
                                          //     print(
                                          //         'vafjdfhdjf ${idChild.toString()}');
                                          //     setState(() {});
                                          //   },
                                          // ),
                                          DropdownSearch<int>(
                                            popupProps: PopupProps.menu(
                                              showSearchBox:
                                                  true, // Enable the search box
                                              searchDelay: Duration(
                                                  milliseconds:
                                                      300), // Optional: Add debounce delay
                                              searchFieldProps: TextFieldProps(
                                                decoration: InputDecoration(
                                                  labelText: "Search Category",
                                                  filled: true,
                                                  fillColor:
                                                      const Color(0xffE2E2E2)
                                                          .withOpacity(.35),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 15,
                                                          vertical: 14),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color: AppTheme
                                                            .secondaryColor),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            dropdownDecoratorProps:
                                                DropDownDecoratorProps(
                                              dropdownSearchDecoration:
                                                  InputDecoration(
                                                filled: true,
                                                fillColor:
                                                    const Color(0xffE2E2E2)
                                                        .withOpacity(.35),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15,
                                                        vertical: 14),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: AppTheme
                                                          .secondaryColor),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: const Color(
                                                          0xffE2E2E2)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: AppTheme
                                                          .secondaryColor),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: AppTheme
                                                          .secondaryColor),
                                                ),
                                                hintText: 'Select Category'.tr,
                                              ),
                                            ),
                                            items: e.childCategory!
                                                .asMap()
                                                .entries
                                                .map((ee) => ee.key)
                                                .toList(),
                                            itemAsString: (int? item) {
                                              if (item == null) return '';
                                              return e
                                                  .childCategory![item].title
                                                  .toString();
                                            },
                                            validator: (value) {
                                              if (!e.childCategory!
                                                  .map((k) => k.selected)
                                                  .toList()
                                                  .contains(true)) {
                                                return "Please select any one category"
                                                    .tr;
                                              }
                                              return null;
                                            },
                                            compareFn:
                                                (int? item, int? selectedItem) {
                                              return item ==
                                                  selectedItem; // Comparison logic for non-String types
                                            },
                                            filterFn:
                                                (int? item, String? query) {
                                              // Filters the list of items based on the search query
                                              if (query == null ||
                                                  query.isEmpty) return true;
                                              return e
                                                  .childCategory![item!].title
                                                  .toLowerCase()
                                                  .contains(
                                                      query.toLowerCase());
                                            },
                                            onChanged: (value) {
                                              e.childCategory![value!]
                                                  .selected = true;
                                              idForChild.add(
                                                  e.childCategory![value].id);
                                              idChild = idForChild.join(',');
                                              getSubCategory();
                                              print(
                                                  'Selected Categories: ${idForChild.toString()}');
                                              print(
                                                  'Child Category ID: ${idChild.toString()}');
                                              setState(() {});
                                            },
                                            selectedItem:
                                                null, // Set this if you want to have an initially selected value
                                          ),

                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Wrap(
                                            alignment: WrapAlignment.start,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.start,
                                            runAlignment: WrapAlignment.start,
                                            spacing: 6,
                                            children: e.childCategory!
                                                .where((element) =>
                                                    element.selected == true)
                                                .map((ee) => Chip(
                                                    visualDensity:
                                                        const VisualDensity(
                                                            vertical: -2,
                                                            horizontal: -4),
                                                    label: Text(
                                                      ee.title.toString(),
                                                      style: normalStyle,
                                                    ),
                                                    onDeleted: () {
                                                      ee.selected = false;
                                                      idForChild.remove(ee.id);
                                                      print(
                                                          'after remove ${idForChild.toString()}');
                                                      print(
                                                          'after remove ${idChild.toString()}');
                                                      setState(() {});
                                                    }))
                                                .toList(),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                        ],
                                      ))
                                  .toList(),
                            )
                          : const SizedBox();
                    })
                  : SizedBox(),
              const SizedBox(
                height: 20,
              ),
              CustomOutlineButton(
                title: 'Confirm'.tr,
                borderRadius: 11,
                onPressed: () {
                  if (ProductNameController.text.trim().isEmpty) {
                    showToast("Please enter product name".tr);
                  }
                  // else if (categoryName.value == "") {
                  //   showToast("Please Select Vendor Category");
                  // }
                  // else if (categoryName.value == "") {
                  //   showToast("Please Select Vendor Category");
                  // }
                  // else if (categoryName.value == "") {
                  //   showToast("Please Select Vendor Category");
                  // }
                  else {
                    deliverySizeApi();
                    profileController.thankYouValue = 'Product';
                  }
                },
              ),
              30.spaceY,
            ],
          ),
        ),
      ),
    );
  }
}
