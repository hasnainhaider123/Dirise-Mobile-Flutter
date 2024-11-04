import 'dart:async';
import 'dart:developer';
import 'package:dirise/addNewProduct/addProductStartScreen.dart';
import 'package:dirise/repository/repository.dart';
import 'package:dirise/utils/helper.dart';
import 'package:dirise/utils/shimmer_extension.dart';
import 'package:dirise/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Services/review_publish_service.dart';
import '../../addNewProduct/addProductFirstImageScreen.dart';
import '../../addNewProduct/addProductScreen.dart';
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
import '../orders/remark_screen.dart';
import 'add_product/add_product_screen.dart';

class VendorProductScreen extends StatefulWidget {
  static String route = "/VendorProductScreen";

  const VendorProductScreen({Key? key}) : super(key: key);

  @override
  State<VendorProductScreen> createState() => _VendorProductScreenState();
}

class _VendorProductScreenState extends State<VendorProductScreen> {
  final productController = Get.put(ProductsController());

  final controller = Get.put(AddProductController(), permanent: true);
  final Repositories repositories = Repositories();

  Timer? timer;

  debounceSearch() {
    if (timer != null) timer!.cancel();
    timer = Timer(const Duration(milliseconds: 500), () {
      productController.getProductList(context: context);
    });
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      productController.getProductList(context: context);
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (timer != null) {
      timer!.cancel();
    }
  }

  String publish = '';
  final addProductController = Get.put(AddProductController());
  final profileController = Get.put(ProfileController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      appBar: AppBar(
        title: Text('All Pending Product'.tr,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: const Color(0xff423E5E),
            )),
        leading: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: profileController.selectedLAnguage.value != 'English'
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
              ),
            ),
          ],
        ),
      ),
      body: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: AddSize.padding16, vertical: AddSize.padding10),
          child: Column(children: [
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade300,
                                // offset: Offset(2, 2),
                                blurRadius: 05)
                          ]),
                      child: TextField(
                        controller: productController.textEditingController,
                        maxLines: 1,
                        style: GoogleFonts.poppins(fontSize: 17),
                        textAlignVertical: TextAlignVertical.center,
                        textInputAction: TextInputAction.search,
                        onChanged: (value) {
                          debounceSearch();
                        },
                        decoration: InputDecoration(
                            filled: true,
                            suffixIcon: IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.search,
                                color: AppTheme.lightblack,
                                size: AddSize.size25,
                              ),
                            ),
                            border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: AddSize.padding20,
                                vertical: AddSize.padding10),
                            hintText: 'Search Products'.tr,
                            hintStyle: GoogleFonts.poppins(
                                fontSize: AddSize.font16,
                                color: Colors.black,
                                fontWeight: FontWeight.w400)),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const AddProductOptionScreen());
                    },
                    child: Container(
                      height: AddSize.size20 * 2.5,
                      width: AddSize.size20 * 2.5,
                      decoration: BoxDecoration(
                        color: AppTheme.buttonColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                          child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: AddSize.size25,
                      )),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            profileController.selectedLAnguage.value == 'English'
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 200,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xffEBF1F4),
                        border: Border.all(color: Color(0xff014E70)),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Text(
                          'All'.tr,
                          style: TextStyle(color: Colors.black),
                        ),
                        value: productController.selectedValue1,
                        onChanged: (String? newValue) {
                          setState(() {
                            productController.getProductList1(context: context);
                            productController.selectedValue1 = newValue;
                            print("value" +
                                productController.selectedValue1.toString());
                          });
                        },
                        items: productController.dropdownItems1
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        underline: SizedBox(), // Removes the default underline
                      ),
                    ),
                  )
                : Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 200,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xffEBF1F4),
                        border: Border.all(color: Color(0xff014E70)),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Text(
                          'الجميع'.tr,
                          style: TextStyle(color: Colors.black),
                        ),
                        value: productController.selectedValue1,
                        onChanged: (String? newValue) {
                          setState(() {
                            productController.getProductList1(context: context);
                            productController.selectedValue1 = newValue;
                            print("value" +
                                productController.selectedValue1.toString());
                          });
                        },
                        items: productController.dropdownItems1Arab
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        underline: SizedBox(), // Removes the default underline
                      ),
                    ),
                  ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await productController.getProductList(context: context);
                },
                child: Obx(() {
                  if (productController.refreshInt.value > 0) {}
                  return ListView.builder(
                    itemCount: productController.apiLoaded
                        ? productController.model.pendingProduct!.isEmpty
                            ? 1
                            : productController.model.pendingProduct!.length
                        : 5,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      if (!productController.apiLoaded) {
                        return shimmerLoader(index);
                      }
                      if (productController.model.pendingProduct!.isEmpty) {
                        return Center(
                          child: Text("No Product Added".tr),
                        );
                      }
                      final item =
                          productController.model.pendingProduct![index];
                      return Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: AddSize.padding16,
                                    vertical: AddSize.padding10),
                                child: Row(children: [
                                  SizedBox(
                                      height: AddSize.size80,
                                      width: AddSize.size80,
                                      child: Image.network(
                                          item.featuredImage ?? "",
                                          errorBuilder: (_, __, ___) =>
                                              Image.asset(
                                                  'assets/images/new_logo.png'))),
                                  SizedBox(
                                    width: AddSize.size10,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                profileController
                                                            .selectedLAnguage
                                                            .value ==
                                                        "English"
                                                    ? item.pname ??
                                                        "${'Product'} ${item.id}"
                                                    : item.pname ??
                                                        "${item.id} ${'منتج'}",
                                                style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                // log('dadad${item.itemType.toString()}');
                                                // log(item.itemType);
                                                print(
                                                    "Item Type----:${item.itemType}");
                                                if (item.itemType ==
                                                    "giveaway") {
                                                  addProductController
                                                          .idProduct.value =
                                                      item.id.toString();
                                                  Get.to(ReviewPublishScreen());
                                                }
                                                if (item.itemType ==
                                                    "product") {
                                                  addProductController
                                                          .idProduct.value =
                                                      item.id.toString();
                                                  Get.to(
                                                      ProductReviewPublicScreen());
                                                }
                                                if (item.itemType == "job") {
                                                  addProductController
                                                          .idProduct.value =
                                                      item.id.toString();
                                                  Get.to(
                                                      JobReviewPublishScreen());
                                                }
                                                if (item.itemType ==
                                                    "service") {
                                                  addProductController
                                                          .idProduct.value =
                                                      item.id.toString();
                                                  Get.to(
                                                      ReviewPublishServiceScreen());
                                                }
                                                if (item.itemType ==
                                                    "virtual_product") {
                                                  addProductController
                                                          .idProduct.value =
                                                      item.id.toString();
                                                  Get.to(
                                                      VirtualReviewandPublishScreen());
                                                } else if (item.itemType ==
                                                    null) {
                                                  Get.to(
                                                      AddProductFirstImageScreen());
                                                }
                                              },
                                              // onTap: () {
                                              //
                                              //   // Get.to(()=> AddProductScreen(productId: (item.id ?? "").toString(),));
                                              // },
                                              child: Container(
                                                  height: AddSize.size25,
                                                  width: AddSize.size25,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40),
                                                      border: Border.all(
                                                          color: AppTheme
                                                              .buttonColor)),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.edit,
                                                      color:
                                                          AppTheme.buttonColor,
                                                      size: AddSize.size15,
                                                    ),
                                                  )),
                                            ),
                                            10.spaceX,
                                            GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (context1) {
                                                      return AlertDialog(
                                                        title: Text(
                                                          "Are you sure you want to delete this product?"
                                                              .tr,
                                                          style: titleStyle,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        actions: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    controller
                                                                            .productId =
                                                                        item.id
                                                                            .toString();
                                                                    controller
                                                                        .deleteProductForAll(
                                                                            context);

                                                                    productController
                                                                        .model
                                                                        .pendingProduct!
                                                                        .removeAt(
                                                                            index);
                                                                    setState(
                                                                        () {});

                                                                    // Get.back();
                                                                  },
                                                                  child: Text(
                                                                      "Delete"
                                                                          .tr)),
                                                              ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    Get.back();
                                                                  },
                                                                  child: Text(
                                                                      "Cancel"
                                                                          .tr)),
                                                            ],
                                                          ),
                                                        ],
                                                      );
                                                    });
                                              },
                                              child: Container(
                                                  height: AddSize.size25,
                                                  width: AddSize.size25,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40),
                                                      border: Border.all(
                                                          color: Colors.red)),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                      size: AddSize.size15,
                                                    ),
                                                  )),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          (item.categoryName ?? "").toString(),
                                          style: normalStyle,
                                        ),
                                        const SizedBox(
                                          height: 3,
                                        ),
                                        item.inStock == "-1"
                                            ? SizedBox.shrink()
                                            : Text(
                                                '${'QTY'.tr}: ${item.inStock} ${'piece'.tr}',
                                                style: normalStyle,
                                              ),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "KWD ${item.discountPrice ?? "0"}",
                                                  style: GoogleFonts.poppins(
                                                    color: AppTheme.buttonColor,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                              // FlutterSwitch(
                                              //   showOnOff: true,
                                              //   width: AddSize.size30 * 2.2,
                                              //   height: AddSize.size20 * 1.3,
                                              //   padding: 2,
                                              //   valueFontSize: AddSize.font12,
                                              //   activeTextFontWeight: FontWeight.w600,
                                              //   inactiveText: " Out".tr,
                                              //   activeText: "  In".tr,
                                              //   inactiveTextColor: const Color(0xFFEBEBEB),
                                              //   activeTextColor: const Color(0xFFFFFFFF),
                                              //   inactiveTextFontWeight: FontWeight.w600,
                                              //   inactiveColor: Colors.grey.shade400,
                                              //   activeColor: AppTheme.buttonColor,
                                              //   onToggle: (val) {
                                              //     publish = val.toString();
                                              //     productController.updateProductStatus(
                                              //         changed: (bool value1) {
                                              //           if (value1 == true) {
                                              //             productController.model.pendingProduct![index].isPublish =
                                              //             !productController.model.pendingProduct![index].isPublish!;
                                              //             // log('in out ${ productController.model1.approveProduct![index].isPublish.toString()}');
                                              //
                                              //             setState(() {
                                              //
                                              //             });
                                              //             // productController.model.pendingProduct![index].isPublish = !productController.model.pendingProduct![index].isPublish!;
                                              //             // publish = productController.model1.approveProduct![index].isPublish.toString();
                                              //             // setState(() {});
                                              //           }
                                              //         },
                                              //         context: context,
                                              //         productID: item.id.toString(),
                                              //         IsPublish: publish,
                                              //     );
                                              //   },
                                              //   value: item.isPublish!,
                                              // )
                                            ]),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              profileController.selectedLAnguage
                                                          .value ==
                                                      "English"
                                                  ? "${("${item.productType ?? ""}".capitalize!).toString().replaceAll("_product".tr, "").replaceAll("Single".tr, "Simple".tr).replaceAll("Variants".tr, "Variable".tr).replaceAll("Booking".tr, "Bookable".tr)} Product"
                                                      .tr
                                                  : " منتج ${("${item.productType ?? ""}".capitalize!).toString().replaceAll("_product".tr, "").replaceAll("single".tr, "بسيط".tr).replaceAll("variants".tr, "عامل".tr).replaceAll("booking".tr, "قابل للحجز".tr)}"
                                                      .tr,
                                              style: GoogleFonts.poppins(
                                                color: AppTheme.buttonColor,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15,
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Get.to(() => RemarkScreen(),
                                                    arguments: [
                                                      productController
                                                          .model
                                                          .pendingProduct![
                                                              index]
                                                          .id
                                                          .toString()
                                                    ]);
                                              },
                                              child: Text(
                                                "Remark".tr,
                                                style: GoogleFonts.poppins(
                                                  color: AppTheme.buttonColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ])),
                          ),
                          const SizedBox(
                            height: 14,
                          )
                        ],
                      );
                    },
                  );
                }),
              ),
            ),
          ])),
    );
  }

  Container shimmerLoader(int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: AddSize.padding16, vertical: AddSize.padding10),
          child: Row(children: [
            SizedBox(
                height: AddSize.size80,
                width: AddSize.size80,
                child: const Image(
                  image: AssetImage('assets/images/voicebook.png'),
                )).convertToShimmer,
            SizedBox(
              width: AddSize.size10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Testate Book'.tr,
                          style: GoogleFonts.poppins(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ).convertToShimmerWithContainer,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                          height: AddSize.size25,
                          width: AddSize.size25,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(color: AppTheme.buttonColor)),
                          child: Center(
                            child: Icon(
                              Icons.edit,
                              color: AppTheme.buttonColor,
                              size: AddSize.size15,
                            ),
                          )).convertToShimmer
                    ],
                  ),
                  3.spaceY,
                  Text(
                    'History Logic'.tr,
                    style: GoogleFonts.poppins(
                      color: const Color(0xff676E73),
                      fontSize: 14,
                    ),
                  ).convertToShimmerWithContainer,
                  4.spaceY,
                  Text('5 ${'piece'.tr}',
                      style: GoogleFonts.poppins(
                        color: const Color(0xff676E73),
                        fontSize: 14,
                      )).convertToShimmerWithContainer,
                  4.spaceY,
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'KWD 6.350',
                          style: GoogleFonts.poppins(
                            color: AppTheme.buttonColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ).convertToShimmerWithContainer,
                        FlutterSwitch(
                          showOnOff: true,
                          width: AddSize.size30 * 2.2,
                          height: AddSize.size20 * 1.4,
                          padding: 2,
                          valueFontSize: AddSize.font12,
                          activeTextFontWeight: FontWeight.w600,
                          inactiveText: " Out".tr,
                          activeText: "  In".tr,
                          inactiveTextColor: const Color(0xFFEBEBEB),
                          activeTextColor: const Color(0xFFFFFFFF),
                          inactiveTextFontWeight: FontWeight.w600,
                          inactiveColor: Colors.grey.shade400,
                          activeColor: AppTheme.buttonColor,
                          onToggle: (val) {
                            setState(() {
                              // state1 = val;
                            });
                          },
                          value: index.isEven,
                        ).convertToShimmer
                      ])
                ],
              ),
            ),
          ])),
    );
  }
}
