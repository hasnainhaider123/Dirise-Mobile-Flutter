import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dirise/screens/Consultation%20Sessions/review_screen.dart';
import 'package:dirise/addNewProduct/rewardScreen.dart';
import 'package:dirise/controller/vendor_controllers/add_product_controller.dart';
import 'package:dirise/singleproductScreen/product_information_screen.dart';
import 'package:dirise/singleproductScreen/singlePInternationalshippingdetails.dart';
import 'package:dirise/singleproductScreen/singleProductDiscriptionScreen.dart';
import 'package:dirise/singleproductScreen/singleProductPriceScreen.dart';
import 'package:dirise/singleproductScreen/singleProductReturnPolicy.dart';
import 'package:dirise/singleproductScreen/singleproductDeliverySize.dart';
import 'package:dirise/tellaboutself/ExtraInformation.dart';
import 'package:dirise/utils/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../addNewProduct/addProductFirstImageScreen.dart';
import '../controller/profile_controller.dart';
import '../controller/service_controller.dart';
import '../model/common_modal.dart';
import '../model/getShippingModel.dart';
import '../model/product_details.dart';
import '../model/returnPolicyModel.dart';
import '../repository/repository.dart';
import '../screens/Seminars &  Attendable Course/review_screen.dart';
import '../screens/Virtual course & Classes Webinars/review_screen_webinar.dart';
import '../screens/academic programs/review_screen_academic.dart';
import '../screens/extendedPrograms/review_screen_academic.dart';
import '../screens/tour_travel/review_publish_screen.dart';
import '../utils/api_constant.dart';
import '../widgets/common_button.dart';
import '../widgets/common_colour.dart';
import 'optionalClassificationScreen.dart';
import 'optionalDiscrptionsScreen.dart';

class ProductReviewPublicScreen extends StatefulWidget {
  const ProductReviewPublicScreen({super.key});

  @override
  State<ProductReviewPublicScreen> createState() => _ProductReviewPublicScreenState();
}

class _ProductReviewPublicScreenState extends State<ProductReviewPublicScreen> {
  String selectedItem = 'Item 1';
  final serviceController = Get.put(ServiceController());
  final addProductControllerNew = Get.put(ProfileController());
  RxBool isServiceProvide = false.obs;
  RxBool isTellUs = false.obs;
  RxBool isReturnPolicy = false.obs;
  RxBool isInternationalPolicy = false.obs;
  RxBool optionalDescription = false.obs;
  RxBool optionalClassification = false.obs;
  RxBool isDeliverySize = false.obs;
  RxBool isShippingPolicy = false.obs;
  RxBool isDiscrptionPolicy = false.obs;
  RxBool isImageProvide = false.obs;
  RxBool isOtherImageProvide = false.obs;
  final Repositories repositories = Repositories();
  RxInt returnPolicyLoaded = 0.obs;
  final addProductController = Get.put(AddProductController());
  String productId = "";
  final profileController = Get.put(ProfileController());
  Rx<RxStatus> vendorCategoryStatus = RxStatus
      .empty()
      .obs;

  ReturnPolicyModel? modelReturnPolicy;

  getReturnPolicyData() {
    repositories.getApi(url: ApiUrls.returnPolicyUrl).then((value) {
      setState(() {
        modelReturnPolicy = ReturnPolicyModel.fromJson(jsonDecode(value));
      });
      print("Return Policy Data: $modelReturnPolicy"); // Print the fetched data
      returnPolicyLoaded.value = DateTime
          .now()
          .millisecondsSinceEpoch;
    });
  }

  GetShippingModel? modelShippingPolicy;

  getShippingPolicyData() {
    repositories.getApi(url: ApiUrls.getShippingPolicy).then((value) {
      setState(() {
        modelShippingPolicy = GetShippingModel.fromJson(jsonDecode(value));
      });
    });
  }


  completeApi() {
    Map<String, dynamic> map = {};

    map['is_complete'] = true;
    map['id'] = addProductController.idProduct.value.toString();

    FocusManager.instance.primaryFocus!.unfocus();
    repositories.postApi(url: ApiUrls.giveawayProductAddress, context: context, mapData: map,showResponse: true).then((value) {
      ModelCommonResponse response = ModelCommonResponse.fromJson(jsonDecode(value));
      print('API Response Status Code: ${response.status}');
      showToast(response.message.toString());
      if (response.status == true) {
        if(profileController.productDetailsModel.value.productDetails!.product!.bookingProductType == 'appointment'){
          print('1');
          Get.to(const ReviewScreen());
        }
       else if(profileController.productDetailsModel.value.productDetails!.product!.bookingProductType == 'academic_program'){
          print('2');
          Get.to(const ReviewScreenAcademic());
        }
        else if(profileController.productDetailsModel.value.productDetails!.product!.bookingProductType == 'monthly_program'){
          print('3');
          Get.to(()=> const ReviewScreenExtendedPrograms());
        }
        else if(profileController.productDetailsModel.value.productDetails!.product!.bookingProductType == 'tour_travel'){
          print('4');
          Get.to(() => const ReviewandPublishTourScreenScreen());
        }
        else  if(profileController.productDetailsModel.value.productDetails!.product!.bookingProductType == 'webinar'){
          print('5');
          Get.to(()=> const ReviewScreenSeminarAndAttendable());
        }
        else  if(profileController.productDetailsModel.value.productDetails!.product!.bookingProductType == 'seminar'){
          print('6');
          Get.to(()=> const ReviewScreenWebinars());
        } else {
          Get.to(const ExtraInformation());
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    profileController.getVendorCategories(addProductController.idProduct.value.toString());
    getReturnPolicyData();
  }

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
              profileController.selectedLAnguage.value != 'English' ?
              Image.asset(
                'assets/images/forward_icon.png',
                height: 19,
                width: 19,
              ) :
              Image.asset(
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
              'Review & Publish'.tr,
              style: GoogleFonts.poppins(color: const Color(0xff292F45), fontWeight: FontWeight.w600, fontSize: 20),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(left: 15, right: 15),
          child: Obx(() {
            return profileController.productDetailsModel.value.productDetails != null
                ? Column(
              children: [
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () {
                    setState(() {
                      isImageProvide.toggle();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.secondaryColor)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Featured Image'.tr,
                          style: GoogleFonts.poppins(
                            color: AppTheme.primaryColor,
                            fontSize: 15,
                          ),
                        ),
                        GestureDetector(
                          child: isImageProvide.value != true
                              ? Image.asset(
                            'assets/images/drop_icon.png',
                            height: 17,
                            width: 17,
                          )
                              : Image.asset(
                            'assets/images/up_icon.png',
                            height: 17,
                            width: 17,
                          ),
                          onTap: () {
                            setState(() {
                              isImageProvide.toggle();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                if (isImageProvide.value == true)
                  Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: Get.width,
                        padding: const EdgeInsets.all(10),
                        decoration:
                        BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(11)),
                        child: Obx(() {
                          return  profileController.productDetailsModel.value.productDetails!.product!.featuredImage != null ?
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                profileController.productDetailsModel.value.productDetails!.product!.featuredImage,
                                height: 200,)
                            ],
                          ) : const SizedBox();
                        }),
                      ),
                      profileController.selectedLAnguage.value == "English"
                      ?Positioned(
                          right: 10,
                          top: 20,
                          child: GestureDetector(
                              onTap: () {
                                File imageFile = File(
                                    profileController.productDetailsModel.value.productDetails!.product!.featuredImage);
                                File imageFile1 = File(
                                    profileController.productDetailsModel.value.productDetails!.product!.galleryImage![0]);

                                Get.to(AddProductFirstImageScreen(
                                  id: profileController.productDetailsModel.value.productDetails!.product!.id,
                                  image: imageFile,
                                  galleryImg: imageFile1,


                                ));
                              },
                              child:  Text(
                                'Edit'.tr,
                                style: TextStyle(color: Colors.red, fontSize: 13),
                              )))
                      :Positioned(
                          left: 10,
                          top: 20,
                          child: GestureDetector(
                              onTap: () {
                                File imageFile = File(
                                    profileController.productDetailsModel.value.productDetails!.product!.featuredImage);
                                File imageFile1 = File(
                                    profileController.productDetailsModel.value.productDetails!.product!.galleryImage![0]);

                                Get.to(AddProductFirstImageScreen(
                                  id: profileController.productDetailsModel.value.productDetails!.product!.id,
                                  image: imageFile,
                                  galleryImg: imageFile1,


                                ));
                              },
                              child:  Text(
                                'Edit'.tr,
                                style: TextStyle(color: Colors.red, fontSize: 13),
                              )))
                    ],
                  ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isOtherImageProvide.toggle();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.secondaryColor)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Other Image'.tr,
                          style: GoogleFonts.poppins(
                            color: AppTheme.primaryColor,
                            fontSize: 15,
                          ),
                        ),
                        GestureDetector(
                          child: isOtherImageProvide.value != true
                              ? Image.asset(
                            'assets/images/drop_icon.png',
                            height: 17,
                            width: 17,
                          )
                              : Image.asset(
                            'assets/images/up_icon.png',
                            height: 17,
                            width: 17,
                          ),
                          onTap: () {
                            setState(() {
                              isOtherImageProvide.toggle();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                if (isOtherImageProvide.value == true)
                  Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: Get.width,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: addProductControllerNew.productDetailsModel.value.productDetails != null &&
                            addProductControllerNew.productDetailsModel.value.productDetails!.product != null &&
                            addProductControllerNew.productDetailsModel.value.productDetails!.product!.galleryImage != null &&
                            addProductControllerNew.productDetailsModel.value.productDetails!.product!.galleryImage!.isNotEmpty
                            ? GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(), // Prevent scrolling in the grid
                          itemCount: addProductControllerNew.productDetailsModel.value.productDetails!.product!.galleryImage!.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // 2 images per row
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1, // Adjust aspect ratio as needed
                          ),
                          itemBuilder: (context, index) {
                            String imageUrl = addProductControllerNew.productDetailsModel.value.productDetails!.product!.galleryImage![index];
                            return Column(
                              children: [
                                20.spaceY,
                                Flexible(
                                  child: Image.network(
                                    imageUrl,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            );
                          },
                        )
                            :  Text('No images available'.tr),
                      ),
                      profileController.selectedLAnguage.value == "English"
                      ?Positioned(
                        right: 10,
                        top: 20,
                        child: GestureDetector(
                          onTap: () {
                            if (addProductControllerNew.productDetailsModel.value.productDetails != null &&
                                addProductControllerNew.productDetailsModel.value.productDetails!.product != null &&
                                addProductControllerNew.productDetailsModel.value.productDetails!.product!.galleryImage != null &&
                                addProductControllerNew.productDetailsModel.value.productDetails!.product!.galleryImage!.isNotEmpty) {
                              // Assuming you want to edit the first image for simplicity
                              File imageFile = File(addProductControllerNew.productDetailsModel.value.productDetails!.product!.galleryImage![0]);
                              Get.to(AddProductFirstImageScreen(
                                id: addProductControllerNew.productDetailsModel.value.productDetails!.product!.id,
                                image: imageFile,
                              ));
                            }
                          },
                          child:  Text(
                            'Edit'.tr,
                            style: TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                      )
                      :Positioned(
                        left: 10,
                        top: 20,
                        child: GestureDetector(
                          onTap: () {
                            if (addProductControllerNew.productDetailsModel.value.productDetails != null &&
                                addProductControllerNew.productDetailsModel.value.productDetails!.product != null &&
                                addProductControllerNew.productDetailsModel.value.productDetails!.product!.galleryImage != null &&
                                addProductControllerNew.productDetailsModel.value.productDetails!.product!.galleryImage!.isNotEmpty) {
                              // Assuming you want to edit the first image for simplicity
                              File imageFile = File(addProductControllerNew.productDetailsModel.value.productDetails!.product!.galleryImage![0]);
                              Get.to(AddProductFirstImageScreen(
                                id: addProductControllerNew.productDetailsModel.value.productDetails!.product!.id,
                                image: imageFile,
                              ));
                            }
                          },
                          child:  Text(
                            'Edit'.tr,
                            style: TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () {
                    setState(() {
                      isServiceProvide.toggle();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.secondaryColor)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Item Details'.tr,
                          style: GoogleFonts.poppins(
                            color: AppTheme.primaryColor,
                            fontSize: 15,
                          ),
                        ),
                        GestureDetector(
                          child: isServiceProvide.value != true
                              ? Image.asset(
                            'assets/images/drop_icon.png',
                            height: 17,
                            width: 17,
                          )
                              : Image.asset(
                            'assets/images/up_icon.png',
                            height: 17,
                            width: 17,
                          ),
                          onTap: () {
                            setState(() {
                              isServiceProvide.toggle();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                if (isServiceProvide.value == true)
                  const SizedBox(height: 10),
                if (isServiceProvide.value == true)
                  Stack(
                    children: [
                      Container(
                        width: Get.width,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(11)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            20.spaceY,
                            Text(
                                '${"product name:".tr} ${ profileController.productDetailsModel.value.productDetails!.product!
                                    .pname ?? ""}'),
                            Text(
                                '${"product Type:".tr} ${ profileController.productDetailsModel.value.productDetails!.product!
                                    .productType ?? ''}'),
                           if(profileController.productDetailsModel.value.productDetails!.product!
                               .catId !="")
                            Text(
                                '${"Category ID:".tr} ${ profileController.productDetailsModel.value.productDetails!.product!
                                    .catId ?? ''}'),
                            Text('${"product ID:".tr} ${ profileController.productDetailsModel.value.productDetails!.product!.id ??
                                ""}'),
                          ],
                        ),
                      ),
                      profileController.selectedLAnguage.value == "English"
                      ?Positioned(
                          right: 10,
                          top: 20,
                          child: GestureDetector(
                              onTap: () {
                                Get.to(ProductInformationScreens(
                                  id: profileController.productDetailsModel.value.productDetails!.product!.id,
                                  name: profileController.productDetailsModel.value.productDetails!.product!.pname,
                                  catid: profileController.productDetailsModel.value.productDetails!.product!.pname,
                                ));
                              },
                              child:  Text(
                                'Edit'.tr,
                                style: TextStyle(color: Colors.red, fontSize: 13),
                              )))
                      :Positioned(
                          left: 10,
                          top: 20,
                          child: GestureDetector(
                              onTap: () {
                                Get.to(ProductInformationScreens(
                                  id: profileController.productDetailsModel.value.productDetails!.product!.id,
                                  name: profileController.productDetailsModel.value.productDetails!.product!.pname,
                                  catid: profileController.productDetailsModel.value.productDetails!.product!.pname,
                                ));
                              },
                              child:  Text(
                                'Edit'.tr,
                                style: TextStyle(color: Colors.red, fontSize: 13),
                              )))
                    ],
                  ),
                const SizedBox(height: 20),
                // tell us

                GestureDetector(
                  onTap: () {
                    setState(() {
                      isTellUs.toggle();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.secondaryColor,)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Price'.tr,
                          style: GoogleFonts.poppins(
                            color: AppTheme.primaryColor,
                            fontSize: 15,
                          ),
                        ),
                        GestureDetector(
                          child: isTellUs.value != true
                              ? Image.asset(
                            'assets/images/drop_icon.png',
                            height: 17,
                            width: 17,
                          )
                              : Image.asset(
                            'assets/images/up_icon.png',
                            height: 17,
                            width: 17,
                          ),
                          onTap: () {
                            setState(() {
                              isTellUs.toggle();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                if (isTellUs.value == true)
                  const SizedBox(height: 20),
                if (isTellUs.value == true)
                  Stack(
                    children: [
                      Container(
                        width: Get.width,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(11)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            20.spaceY,
                            Text('${"Price:".tr} ${ profileController.productDetailsModel.value.productDetails!.product!.pPrice ?? ""} KWD'),
                            Text('${"Fixed Discounted Price :".tr} ${ profileController.productDetailsModel.value.productDetails!.product!.fixedDiscountPrice ?? ""} KWD'),
                            Text('${"Discount Percentage:".tr} ${ profileController.productDetailsModel.value.productDetails!.product!.discountPercent ?? ''}'),
                          ],
                        ),
                      ),
                      profileController.selectedLAnguage.value == "English"
                      ?Positioned(
                          right: 10,
                          top: 20,
                          child: GestureDetector(
                              onTap: () {
                                File imageFile = File(
                                    profileController.productDetailsModel.value.productDetails!.product!.featuredImage);
                                Get.to(SingleProductPriceScreen(
                                  id: profileController.productDetailsModel.value.productDetails!.product!.id,
                                  price: profileController.productDetailsModel.value.productDetails!.product!.pPrice,
                                  fixDiscount:
                                  profileController.productDetailsModel.value.productDetails!.product!.fixedDiscountPrice,
                                  percentage: profileController.productDetailsModel.value.productDetails!.product!
                                      .discountPercent,
                                  isDelivery:  profileController.productDetailsModel.value.productDetails!.product!.isOnsale,
                                  image: imageFile,
                                ));
                              },
                              child:  Text(
                                'Edit'.tr,
                                style: TextStyle(color: Colors.red, fontSize: 13),
                              )))
                      :Positioned(
                          left: 10,
                          top: 20,
                          child: GestureDetector(
                              onTap: () {
                                File imageFile = File(
                                    profileController.productDetailsModel.value.productDetails!.product!.featuredImage);
                                Get.to(SingleProductPriceScreen(
                                  id: profileController.productDetailsModel.value.productDetails!.product!.id,
                                  price: profileController.productDetailsModel.value.productDetails!.product!.pPrice,
                                  fixDiscount:
                                  profileController.productDetailsModel.value.productDetails!.product!.fixedDiscountPrice,
                                  percentage: profileController.productDetailsModel.value.productDetails!.product!
                                      .discountPercent,
                                  isDelivery:  profileController.productDetailsModel.value.productDetails!.product!.isOnsale,
                                  image: imageFile,
                                ));
                              },
                              child:  Text(
                                'Edit'.tr,
                                style: TextStyle(color: Colors.red, fontSize: 13),
                              )))
                    ],
                  ),

                // tell us
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isDiscrptionPolicy.toggle();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.secondaryColor)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Description'.tr,
                          style: GoogleFonts.poppins(
                            color: AppTheme.primaryColor,
                            fontSize: 15,
                          ),
                        ),
                        GestureDetector(
                          child: isDiscrptionPolicy.value != true
                              ? Image.asset(
                            'assets/images/drop_icon.png',
                            height: 17,
                            width: 17,
                          )
                              : Image.asset(
                            'assets/images/up_icon.png',
                            height: 17,
                            width: 17,
                          ),
                          onTap: () {
                            setState(() {
                              isDiscrptionPolicy.toggle();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (isDiscrptionPolicy.value == true)
                const SizedBox(height: 20),
                if (isDiscrptionPolicy.value == true)
                  Stack(
                    children: [
                      Container(
                        width: Get.width,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.grey.shade200,borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            20.spaceY,
                            Text('${"Short Description:".tr} ${ profileController.productDetailsModel.value.productDetails!.product!.shortDescription ?? ""}'),
                            if( profileController.productDetailsModel.value.productDetails!.product!.inStock == '-1')
                               Text('${"Stock/spot quantity :".tr} ${'No need'.tr}'),
                            if( profileController.productDetailsModel.value.productDetails!.product!.inStock != '-1')
                              Text('${"Stock/spot quantity :".tr} ${ profileController.productDetailsModel.value.productDetails!.product!.inStock ?? ''}'),
                            Text('${"Set stock/spot alert:".tr} ${ profileController.productDetailsModel.value.productDetails!.product!.stockAlert ?? ''}'),
                            Text('${"SEO Tags:".tr} ${ profileController.productDetailsModel.value.productDetails!.product!.seoTags ?? ''}'),
                          ],
                        ),
                      ),
                      profileController.selectedLAnguage.value == "English"
                      ?Positioned(
                          right: 10,
                          top: 20,
                          child: GestureDetector(
                              onTap: () {
                                Get.to(SingleProductDiscriptionScreen(
                                  id: profileController.productDetailsModel.value.productDetails!.product!.id,
                                  description: profileController.productDetailsModel.value.productDetails!.product!.shortDescription,
                                  stockquantity: profileController.productDetailsModel.value.productDetails!.product!.inStock,
                                  setstock: profileController.productDetailsModel.value.productDetails!.product!.stockAlert,
                                  sEOTags: profileController.productDetailsModel.value.productDetails!.product!.seoTags,
                                  noNeed: profileController.productDetailsModel.value.productDetails!.product!.noNeedStock,
                                  longDescription: profileController.productDetailsModel.value.productDetails!.product!.longDescription,
                                ));
                              },
                              child: Text(
                                'Edit'.tr,
                                style: TextStyle(color: Colors.red, fontSize: 13),
                              )))
                      :Positioned(
                          left: 10,
                          top: 20,
                          child: GestureDetector(
                              onTap: () {
                                Get.to(SingleProductDiscriptionScreen(
                                  id: profileController.productDetailsModel.value.productDetails!.product!.id,
                                  description: profileController.productDetailsModel.value.productDetails!.product!.shortDescription,
                                  stockquantity: profileController.productDetailsModel.value.productDetails!.product!.inStock,
                                  setstock: profileController.productDetailsModel.value.productDetails!.product!.stockAlert,
                                  sEOTags: profileController.productDetailsModel.value.productDetails!.product!.seoTags,
                                  noNeed: profileController.productDetailsModel.value.productDetails!.product!.noNeedStock,
                                  longDescription: profileController.productDetailsModel.value.productDetails!.product!.longDescription,
                                ));
                              },
                              child: Text(
                                'Edit'.tr,
                                style: TextStyle(color: Colors.red, fontSize: 13),
                              )))
                    ],
                  ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isDeliverySize.toggle();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.secondaryColor)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Delivery Size'.tr,
                          style: GoogleFonts.poppins(
                            color: AppTheme.primaryColor,
                            fontSize: 15,
                          ),
                        ),
                        GestureDetector(
                          child: isDeliverySize.value != true
                              ? Image.asset(
                            'assets/images/drop_icon.png',
                            height: 17,
                            width: 17,
                          )
                              : Image.asset(
                            'assets/images/up_icon.png',
                            height: 17,
                            width: 17,
                          ),
                          onTap: () {
                            setState(() {
                              isDeliverySize.toggle();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (isDeliverySize.value == true)
                  Stack(
                    children: [
                      Container(
                        width: Get.width,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.grey.shade200,borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            20.spaceY,
                            Text(
                                '${"Who will pay the shipping:".tr} ${ profileController.productDetailsModel.value.productDetails!
                                    .product!.shippingPay}'),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                                '${"Choose Delivery According To Package Size :".tr} ${ profileController.productDetailsModel.value
                                    .productDetails!.product!.deliverySize}'),
                          ],
                        ),
                      ),
                      profileController.selectedLAnguage.value == "English"
                      ?Positioned(
                          right: 10,
                          top: 20,
                          child: GestureDetector(
                              onTap: () {
                                Get.to(SingleProductDeliverySize(
                                    id: profileController.productDetailsModel.value.productDetails!.product!.id,
                                    whowillpay: profileController.productDetailsModel.value.productDetails!.product!
                                        .shippingPay,
                                    packagSize: profileController.productDetailsModel.value.productDetails!.product!
                                        .deliverySize));
                              },
                              child:  Text(
                                'Edit'.tr,
                                style: TextStyle(color: Colors.red, fontSize: 13),
                              )))
                      :Positioned(
                          left: 10,
                          top: 20,
                          child: GestureDetector(
                              onTap: () {
                                Get.to(SingleProductDeliverySize(
                                    id: profileController.productDetailsModel.value.productDetails!.product!.id,
                                    whowillpay: profileController.productDetailsModel.value.productDetails!.product!
                                        .shippingPay,
                                    packagSize: profileController.productDetailsModel.value.productDetails!.product!
                                        .deliverySize));
                              },
                              child:  Text(
                                'Edit'.tr,
                                style: TextStyle(color: Colors.red, fontSize: 13),
                              )))
                    ],
                  ),
                if (isDeliverySize.value == true)
                const SizedBox(height: 20),
                // return policy
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isReturnPolicy.toggle();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.secondaryColor)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'return policy'.tr,
                          style: GoogleFonts.poppins(
                            color: AppTheme.primaryColor,
                            fontSize: 15,
                          ),
                        ),
                        GestureDetector(
                          child: isReturnPolicy.value != true
                              ? Image.asset(
                            'assets/images/drop_icon.png',
                            height: 17,
                            width: 17,
                          )
                              : Image.asset(
                            'assets/images/up_icon.png',
                            height: 17,
                            width: 17,
                          ),
                          onTap: () {
                            setState(() {
                              isReturnPolicy.toggle();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (isReturnPolicy.value == true)
                  Stack(
                    children: [
                      Container(
                        width: Get.width,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.grey.shade200,borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            20.spaceY,
                            Text(
                                '${"Policy Name:".tr} ${ profileController.productDetailsModel.value.productDetails!.product!
                                    .returnPolicyDesc!.title ?? ""}'),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                                '${"Policy Description:".tr} ${ profileController.productDetailsModel.value.productDetails!.product!
                                    .returnPolicyDesc!.policyDiscreption ?? ""}'),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                                '${"Return with In:".tr} ${ profileController.productDetailsModel.value.productDetails!.product!
                                    .returnPolicyDesc!.days ?? ""}'),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                                '${"Return Shipping Fees:".tr} ${ profileController.productDetailsModel.value.productDetails!
                                    .product!.returnPolicyDesc!.returnShippingFees ?? ""}'),
                          ],
                        ),
                      ),
                      profileController.selectedLAnguage.value == "English"
                      ?Positioned(
                          right: 10,
                          top: 20,
                          child: GestureDetector(
                              onTap: () {
                                Get.to(SingleProductReturnPolicy(
                                  id: profileController.productDetailsModel.value.productDetails!.product!.id,
                                  policyName:
                                  profileController.productDetailsModel.value.productDetails!.product!.returnPolicyDesc!
                                      .title,
                                  policyDescription: profileController.productDetailsModel
                                      .value.productDetails!.product!.returnPolicyDesc!.policyDiscreption,
                                  returnShippingFees: profileController.productDetailsModel
                                      .value.productDetails!.product!.returnPolicyDesc!.returnShippingFees,
                                  returnWithIn:
                                  profileController.productDetailsModel.value.productDetails!.product!.returnPolicyDesc!
                                      .days,
                                ));
                              },
                              child:  Text(
                                'Edit'.tr,
                                style: TextStyle(color: Colors.red, fontSize: 13),
                              )))
                      :Positioned(
                          left: 10,
                          top: 20,
                          child: GestureDetector(
                              onTap: () {
                                Get.to(SingleProductReturnPolicy(
                                  id: profileController.productDetailsModel.value.productDetails!.product!.id,
                                  policyName:
                                  profileController.productDetailsModel.value.productDetails!.product!.returnPolicyDesc!
                                      .title,
                                  policyDescription: profileController.productDetailsModel
                                      .value.productDetails!.product!.returnPolicyDesc!.policyDiscreption,
                                  returnShippingFees: profileController.productDetailsModel
                                      .value.productDetails!.product!.returnPolicyDesc!.returnShippingFees,
                                  returnWithIn:
                                  profileController.productDetailsModel.value.productDetails!.product!.returnPolicyDesc!
                                      .days,
                                ));
                              },
                              child:  Text(
                                'Edit'.tr,
                                style: TextStyle(color: Colors.red, fontSize: 13),
                              )))
                    ],
                  ),
                if (isReturnPolicy.value == true) 
                const SizedBox(height: 20),
                // modelReturnPolicy != null
                //     ? ListView.builder(
                //         shrinkWrap: true,
                //         physics: AlwaysScrollableScrollPhysics(),
                //         itemCount: modelReturnPolicy!.returnPolicy!.length,
                //         itemBuilder: (context, index) {
                //           var returnPolicy = modelReturnPolicy!.returnPolicy![index];
                //           return Container(
                //             padding: EdgeInsets.all(10),
                //             decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                //             child: Column(
                //               mainAxisAlignment: MainAxisAlignment.start,
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 Text('Policy Name: ${returnPolicy.title ?? ""}'),
                //                 Text('Return Policy Description : ${returnPolicy.policyDiscreption ?? ""}'),
                //                 Text('Return Within: ${returnPolicy.days ?? ""}'),
                //                 Text('Return Shipping Fees: ${returnPolicy.returnShippingFees ?? ""}'),
                //               ],
                //             ),
                //           );
                //         })
                //     : const CircularProgressIndicator(),

                GestureDetector(
                  onTap: () {
                    setState(() {
                      isInternationalPolicy.toggle();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.secondaryColor)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Item Weight & Dimensions'.tr,
                          style: GoogleFonts.poppins(
                            color: AppTheme.primaryColor,
                            fontSize: 15,
                          ),
                        ),
                        GestureDetector(
                          child: isInternationalPolicy.value != true
                              ? Image.asset(
                            'assets/images/drop_icon.png',
                            height: 17,
                            width: 17,
                          )
                              : Image.asset(
                            'assets/images/up_icon.png',
                            height: 17,
                            width: 17,
                          ),
                          onTap: () {
                            setState(() {
                              isInternationalPolicy.toggle();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (isInternationalPolicy.value == true)
                  Stack(
                    children: [
                      Container(
                        width: Get.width,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.grey.shade200,borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            20.spaceY,
                            Text(
                                '${"Unit of measure:".tr} ${ profileController.productDetailsModel.value.productDetails!.productDimentions!.units ?? ""}'),
                            Text(
                                '${"Weight Of the Item:".tr} ${ profileController.productDetailsModel.value.productDetails!.productDimentions!.weight ?? ""}'),
                            Text(
                                '${"Select Number Of Packages:".tr} ${ profileController.productDetailsModel.value.productDetails!.productDimentions!.numberOfPackage ?? ""}'),
                            Text(
                                '${"Select Type Material:".tr} ${ profileController.productDetailsModel.value.productDetails!.productDimentions!.material ?? ""}'),
                            Text(
                                '${"Select Type Of Packaging:".tr} ${ profileController.productDetailsModel.value.productDetails!.productDimentions!.typeOfPackages ?? ""}'),
                            Text('${"Length X Width X Height:".tr} ${ profileController.productDetailsModel.value.productDetails!.productDimentions!.boxLength ?? ""}X' +
                                "${ profileController.productDetailsModel.value.productDetails!.productDimentions!.boxWidth ?? ""}X"
                                    "${ profileController.productDetailsModel.value.productDetails!.productDimentions!.boxHeight ?? ""}"),
                          ],
                        ),
                      ),
                      profileController.selectedLAnguage.value == "English"
                      ?Positioned(
                          right: 10,
                          top: 20,
                          child: GestureDetector(
                              onTap: () {
                                Get.to(SinglePInternationalshippingdetailsScreen(
                                  id: profileController.productDetailsModel.value.productDetails!.product!.id,
                                  WeightOftheItem: profileController.productDetailsModel.value.productDetails!.productDimentions!.weight,
                                  Unitofmeasure: profileController.productDetailsModel.value.productDetails!.productDimentions!.units,
                                  SelectTypeOfPackaging: profileController.productDetailsModel.value.productDetails!.productDimentions!.typeOfPackages,
                                  SelectTypeMaterial: profileController.productDetailsModel.value.productDetails!.productDimentions!.material,
                                  SelectNumberOfPackages: profileController.productDetailsModel.value.productDetails!.productDimentions!.numberOfPackage,
                                  Length: "${ profileController.productDetailsModel.value.productDetails!.productDimentions!.boxLength}",
                                  Width: "${ profileController.productDetailsModel.value.productDetails!.productDimentions!.boxWidth ?? ""}",
                                  Height: "${ profileController.productDetailsModel.value.productDetails!.productDimentions!.boxHeight ?? ""}",
                                  selectTypeMaterial:addProductControllerNew.productDetailsModel.value.productDetails!.productDimentions!.material.toString(),
                                  productType : addProductControllerNew.productDetailsModel.value.productDetails!.productDimentions!.typeOfPackages == 'custom_packaging' ? 'your packaging' : 'custom packaging',
                                  unitOfMeasure : addProductControllerNew.productDetailsModel.value.productDetails!.productDimentions!.weightUnit == 'inch/lb' ? 'Lb/Inch' : 'Cm/Kg',
                                ));
                              },
                              child:  Text(
                                'Edit'.tr,
                                style: TextStyle(color: Colors.red, fontSize: 13),
                              )))
                      :Positioned(
                          left: 10,
                          top: 20,
                          child: GestureDetector(
                              onTap: () {
                                Get.to(SinglePInternationalshippingdetailsScreen(
                                  id: profileController.productDetailsModel.value.productDetails!.product!.id,
                                  WeightOftheItem: profileController.productDetailsModel.value.productDetails!.productDimentions!.weight,
                                  Unitofmeasure: profileController.productDetailsModel.value.productDetails!.productDimentions!.units,
                                  SelectTypeOfPackaging: profileController.productDetailsModel.value.productDetails!.productDimentions!.typeOfPackages,
                                  SelectTypeMaterial: profileController.productDetailsModel.value.productDetails!.productDimentions!.material,
                                  SelectNumberOfPackages: profileController.productDetailsModel.value.productDetails!.productDimentions!.numberOfPackage,
                                  Length: "${ profileController.productDetailsModel.value.productDetails!.productDimentions!.boxLength}",
                                  Width: "${ profileController.productDetailsModel.value.productDetails!.productDimentions!.boxWidth ?? ""}",
                                  Height: "${ profileController.productDetailsModel.value.productDetails!.productDimentions!.boxHeight ?? ""}",
                                  selectTypeMaterial:addProductControllerNew.productDetailsModel.value.productDetails!.productDimentions!.material.toString(),
                                  productType : addProductControllerNew.productDetailsModel.value.productDetails!.productDimentions!.typeOfPackages == 'custom_packaging' ? 'your packaging' : 'custom packaging',
                                  unitOfMeasure : addProductControllerNew.productDetailsModel.value.productDetails!.productDimentions!.weightUnit == 'inch/lb' ? 'Lb/Inch' : 'Cm/Kg',
                                ));
                              },
                              child:  Text(
                                'Edit'.tr,
                                style: TextStyle(color: Colors.red, fontSize: 13),
                              )))
                    ],
                  ),
                if (isInternationalPolicy.value == true)
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      optionalDescription.toggle();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.secondaryColor)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Optional Description'.tr,
                          style: GoogleFonts.poppins(
                            color: AppTheme.primaryColor,
                            fontSize: 15,
                          ),
                        ),
                        GestureDetector(
                          child: optionalDescription.value != true
                              ? Image.asset(
                            'assets/images/drop_icon.png',
                            height: 17,
                            width: 17,
                          )
                              : Image.asset(
                            'assets/images/up_icon.png',
                            height: 17,
                            width: 17,
                          ),
                          onTap: () {
                            setState(() {
                              optionalDescription.toggle();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (optionalDescription.value == true)
                  const SizedBox(
                  height: 20,
                ),
                if (optionalDescription.value == true)
                  Stack(
                    children: [
                      Container(
                        width: Get.width,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.grey.shade200,borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            20.spaceY,
                            Text('${"Meta Title:".tr} ${ profileController.productDetailsModel.value.productDetails!.product!.metaTitle ?? ""}'),
                            Text('${"Meta Description:".tr} ${ profileController.productDetailsModel.value.productDetails!.product!.metaDescription ?? ""}'),
                            Text('${"Meta Tags:".tr} ${ profileController.productDetailsModel.value.productDetails!.product!.metaTags ?? ""}'),
                          ],
                        ),
                      ),
                      profileController.selectedLAnguage.value == "English"
                      ?Positioned(
                          right: 10,
                          top: 10,
                          child: GestureDetector(
                              onTap: () {
                                Get.to(OptionalDiscrptionsScreen(
                                  id: profileController.productDetailsModel.value.productDetails!.product!.id ?? "",
                                  MetaTitle: profileController.productDetailsModel.value.productDetails!.product!.metaTitle ?? "",
                                  MetaDescription: profileController.productDetailsModel.value.productDetails!.product!.metaDescription ?? "",
                                  metaTags: profileController.productDetailsModel.value.productDetails!.product!.metaTags ?? "",
                                ));
                              },
                              child:  Text(
                                'Edit'.tr,
                                style: TextStyle(color: Colors.red, fontSize: 13),
                              )))
                      :Positioned(
                          left: 10,
                          top: 10,
                          child: GestureDetector(
                              onTap: () {
                                Get.to(OptionalDiscrptionsScreen(
                                  id: profileController.productDetailsModel.value.productDetails!.product!.id ?? "",
                                  MetaTitle: profileController.productDetailsModel.value.productDetails!.product!.metaTitle ?? "",
                                  MetaDescription: profileController.productDetailsModel.value.productDetails!.product!.metaDescription ?? "",
                                  metaTags: profileController.productDetailsModel.value.productDetails!.product!.metaTags ?? "",
                                ));
                              },
                              child:  Text(
                                'Edit'.tr,
                                style: TextStyle(color: Colors.red, fontSize: 13),
                              )))
                    ],
                  ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      optionalClassification.toggle();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.secondaryColor)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Optional Classification'.tr,
                          style: GoogleFonts.poppins(
                            color: AppTheme.primaryColor,
                            fontSize: 15,
                          ),
                        ),
                        GestureDetector(
                          child: optionalClassification.value != true
                              ? Image.asset(
                            'assets/images/drop_icon.png',
                            height: 17,
                            width: 17,
                          )
                              : Image.asset(
                            'assets/images/up_icon.png',
                            height: 17,
                            width: 17,
                          ),
                          onTap: () {
                            setState(() {
                              optionalClassification.toggle();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (optionalClassification.value == true)
                  Stack(
                    children: [
                      Container(
                        width: Get.width,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.grey.shade200),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            20.spaceY,
                            Text('${"Product Code:".tr} ${ profileController.productDetailsModel.value.productDetails!.product!.productCode ?? ""}'),
                            Text('${"Promotion Code:".tr} ${ profileController.productDetailsModel.value.productDetails!.product!.promotionCode ?? ""}'),
                            Text('${"Package details:".tr} ${ profileController.productDetailsModel.value.productDetails!.product!.packageDetail ?? ""}'),
                            Text('${"Serial Number:".tr} ${ profileController.productDetailsModel.value.productDetails!.product!.serialNumber ?? ""}'),
                            Text('${"Product number:".tr} ${ profileController.productDetailsModel.value.productDetails!.product!.productNumber ?? ""}'),
                          ],
                        ),
                      ),
                      profileController.selectedLAnguage.value == "English"
                      ?Positioned(
                          right: 10,
                          top: 10,
                          child: GestureDetector(
                              onTap: () {
                                Get.to(OptionalClassificationScreen(
                                  id: profileController.productDetailsModel.value.productDetails!.product!.id ?? "",
                                  Productnumber:
                                  profileController.productDetailsModel.value.productDetails!.product!.productNumber ?? "",
                                  ProductCode:
                                  profileController.productDetailsModel.value.productDetails!.product!.productCode ?? "",
                                  PromotionCode:
                                  profileController.productDetailsModel.value.productDetails!.product!.promotionCode ?? "",
                                  SerialNumber:
                                  profileController.productDetailsModel.value.productDetails!.product!.serialNumber ?? "",
                                  Packagedetails:
                                  profileController.productDetailsModel.value.productDetails!.product!.packageDetail ?? "",
                                ));
                              },
                              child:  Text(
                                'Edit'.tr,
                                style: TextStyle(color: Colors.red, fontSize: 13),
                              )))
                      :Positioned(
                          left: 10,
                          top: 10,
                          child: GestureDetector(
                              onTap: () {
                                Get.to(OptionalClassificationScreen(
                                  id: profileController.productDetailsModel.value.productDetails!.product!.id ?? "",
                                  Productnumber:
                                  profileController.productDetailsModel.value.productDetails!.product!.productNumber ?? "",
                                  ProductCode:
                                  profileController.productDetailsModel.value.productDetails!.product!.productCode ?? "",
                                  PromotionCode:
                                  profileController.productDetailsModel.value.productDetails!.product!.promotionCode ?? "",
                                  SerialNumber:
                                  profileController.productDetailsModel.value.productDetails!.product!.serialNumber ?? "",
                                  Packagedetails:
                                  profileController.productDetailsModel.value.productDetails!.product!.packageDetail ?? "",
                                ));
                              },
                              child:  Text(
                                'Edit'.tr,
                                style: TextStyle(color: Colors.red, fontSize: 13),
                              )))
                    ],
                  ),
                const SizedBox(
                  height: 20,
                ),

                CustomOutlineButton(
                  title: 'Confirm'.tr,
                  borderRadius: 11,
                  onPressed: () {
                    if(profileController.productDetailsModel.value.productDetails != null ){
                      profileController.thankYouValue = profileController.productDetailsModel.value.productDetails!.product!.itemType;
                    }
                    completeApi();
                    log('dadadada${profileController.thankYouValue.toString()}');
                    // Get.to(RewardScreen());
                  },
                ),
                const SizedBox(
                  height: 40,
                ),

              ],
            )
                : const Center(
                child: CircularProgressIndicator(
                  color: Colors.grey,
                ));
          }),
        ),
      ),
    );
  }
}
