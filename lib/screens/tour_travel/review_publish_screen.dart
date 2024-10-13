import 'dart:convert';
import 'dart:developer';

import 'package:dirise/addNewProduct/rewardScreen.dart';
import 'package:dirise/screens/tour_travel/sponsors_tourandtravel_screen.dart';
import 'package:dirise/screens/tour_travel/timing_screen.dart';
import 'package:dirise/utils/helper.dart';
import 'package:dirise/widgets/loading_animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bottomavbar.dart';
import '../../controller/profile_controller.dart';
import '../../controller/vendor_controllers/add_product_controller.dart';
import '../../iAmHereToSell/productAccountCreatedSuccessfullyScreen.dart';
import '../../model/common_modal.dart';
import '../../model/product_details.dart';
import '../../repository/repository.dart';
import '../../utils/api_constant.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_colour.dart';
import '../../widgets/common_textfield.dart';
import '../Consultation Sessions/consultation_session_thankyou.dart';
import 'date_range_screen_tour.dart';
import 'eligible_customer_academic.dart';
import 'optional_details_tourandtravel.dart';

class ReviewandPublishTourScreenScreen extends StatefulWidget {
  const ReviewandPublishTourScreenScreen({super.key});

  @override
  State<ReviewandPublishTourScreenScreen> createState() => _ReviewandPublishTourScreenScreenState();
}

class _ReviewandPublishTourScreenScreenState extends State<ReviewandPublishTourScreenScreen> {
  String selectedItem = 'Item 1';
  RxBool isServiceProvide = false.obs;
  RxBool isTime = false.obs;
  RxBool isDuration = false.obs;
  RxBool isOperational = false.obs;
  RxBool isSponsors = false.obs;
  RxBool eligibleCustomer = false.obs;
  final Repositories repositories = Repositories();
  final addProductController = Get.put(AddProductController());
  Rx<ModelProductDetails> productDetailsModel = ModelProductDetails().obs;
  Rx<RxStatus> vendorCategoryStatus = RxStatus.empty().obs;
  final profileController = Get.put(ProfileController());
  getVendorCategories(String id) async {
    try {
      var value = await repositories.getApi(url: ApiUrls.getProductDetailsUrl + id);
      productDetailsModel.value = ModelProductDetails.fromJson(jsonDecode(value));
      productDetailsModel.refresh(); // Ensure the state is updated
    } catch (e) {
      log("Error fetching vendor categories: $e");
    }
  }
  completeApi() {
    Map<String, dynamic> map = {};

    map['is_complete'] = true;
    map['id'] = addProductController.idProduct.value.toString();
    FocusManager.instance.primaryFocus!.unfocus();
    repositories.postApi(url: ApiUrls.giveawayProductAddress, context: context, mapData: map).then((value) {
      ModelCommonResponse response = ModelCommonResponse.fromJson(jsonDecode(value));
      print('API Response Status Code: ${response.status}');
      showToast(response.message.toString());
      if (response.status == true) {
        Get.to(() => const ProductAccountCreatedSuccessfullyScreen());
      }});}
  @override
  void initState() {
    super.initState();
    getVendorCategories(addProductController.idProduct.value.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: (){
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
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 10),
        //     child: Text(
        //       'Skip',
        //       style: GoogleFonts.poppins(color: Color(0xff0D5877), fontWeight: FontWeight.w400, fontSize: 18),
        //     ),
        //   )
        // ],
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
      body: Obx(() {
        return productDetailsModel.value.productDetails != null
            ? SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.only(left: 15, right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                       Text(
                        'Tour & Travel'.tr,
                        style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
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
                                'Date Range'.tr,
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
                        Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              width: Get.width,
                              padding: EdgeInsets.all(10),
                              decoration:
                              BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(11)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  30.spaceY,
                                  Text('${"Dates range:".tr} ${productDetailsModel.value.productDetails!.product!.productAvailability!.fromDate ?? ""} to ${productDetailsModel.value.productDetails!.product!.productAvailability!.toDate ?? ""}'),
                                  Text('${"From Location:".tr} ${productDetailsModel.value.productDetails!.product!.fromLocation ?? ""} '),
                                  Text('${"To Location:".tr} ${productDetailsModel.value.productDetails!.product!.toLocation ?? ""} '),
                                  Text('${"From ExtraNotes:".tr} ${productDetailsModel.value.productDetails!.product!.fromExtraNotes ?? ""} '),
                                  Text('${"To ExtraNotes:".tr} ${productDetailsModel.value.productDetails!.product!.toExtraNotes ?? ""} '),

                                ],
                              ),
                            ),
                            Positioned(
                                right: 10,
                                top: 20,
                                child: GestureDetector(
                                    onTap: () {
                                      Get.to(DateRangeScreenTour(
                                        id: productDetailsModel.value.productDetails!.product!.id,
                                         from_date: productDetailsModel.value.productDetails!.product!.productAvailability!.fromDate,
                                        to_date: productDetailsModel.value.productDetails!.product!.productAvailability!.toDate,
                                        fromLocation: productDetailsModel.value.productDetails!.product!.startLocation,
                                        toLocation: productDetailsModel.value.productDetails!.product!.endLocation,
                                        formExtraNotes: productDetailsModel.value.productDetails!.product!.fromExtraNotes,
                                        toExtraNotes: productDetailsModel.value.productDetails!.product!.toExtraNotes,
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
                            isTime.toggle();
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
                                'Timing'.tr,
                                style: GoogleFonts.poppins(
                                  color: AppTheme.primaryColor,
                                  fontSize: 15,
                                ),
                              ),
                              GestureDetector(
                                child: isTime.value != true
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
                                    isTime.toggle();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                       if (isTime.value == true)
                         Stack(
                           children: [
                             Container(
                               margin: EdgeInsets.only(top: 10),
                               width: Get.width,
                               padding: EdgeInsets.all(10),
                               decoration:
                               BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(11)),
                               child: Column(
                                 mainAxisAlignment: MainAxisAlignment.start,
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   30.spaceY,
                                   Text('${"start Location :".tr} ${productDetailsModel.value.productDetails!.product!.startLocation ?? ""}'),
                                   Text('${"end Location :".tr} ${productDetailsModel.value.productDetails!.product!.endLocation ?? ""}'),
                                   Text('${"timing ExtraNotes :".tr} ${productDetailsModel.value.productDetails!.product!.timingExtraNotes ?? ""}'),
                                   Text('${"start Time :".tr} ${productDetailsModel.value.productDetails!.product!.fromLocation ?? ""}'),
                                   Text('${"end Time :".tr} ${productDetailsModel.value.productDetails!.product!.toLocation ?? ""}'),
                                   Text('${"spot :".tr} ${productDetailsModel.value.productDetails!.product!.spot ?? ""}'),
                                 ],
                               ),
                             ),
                             Positioned(
                                 right: 10,
                                 top: 20,
                                 child: GestureDetector(
                                     onTap: () {
                                       Get.to(TimingScreenTour(
                                         id: productDetailsModel.value.productDetails!.product!.id,
                                         spot: productDetailsModel.value.productDetails!.product!.spot,
                                         endEndTime: productDetailsModel.value.productDetails!.product!.fromLocation,
                                         endLocation: productDetailsModel.value.productDetails!.product!.endLocation,
                                         startLocation: productDetailsModel.value.productDetails!.product!.startLocation,
                                         startTime: productDetailsModel.value.productDetails!.product!.fromLocation,
                                         timingExtraNotes:productDetailsModel.value.productDetails!.product!.timingExtraNotes ,
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
                            isOperational.toggle();
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
                                'Operational details '.tr,
                                style: GoogleFonts.poppins(
                                  color: AppTheme.primaryColor,
                                  fontSize: 15,
                                ),
                              ),
                              GestureDetector(
                                child: isOperational.value != true
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
                                    isOperational.toggle();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isOperational.value == true)
                        Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              width: Get.width,
                              padding: EdgeInsets.all(10),
                              decoration:
                              BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(11)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${"Location:".tr} ${productDetailsModel.value.productDetails!.product!.bookable_product_location ?? ""}'),
                                  Text('${"Host name:".tr} ${productDetailsModel.value.productDetails!.product!.host_name ?? ""}'),
                                  Text('${"Program name:".tr} ${productDetailsModel.value.productDetails!.product!.program_name ?? ""}'),
                                  Text('${"Program goal:".tr} ${productDetailsModel.value.productDetails!.product!.program_goal ?? ""}'),
                                  Text('${"Program Description:".tr} ${productDetailsModel.value.productDetails!.product!.program_desc ?? ""}'),
                                ],
                              ),
                            ),
                            Positioned(
                                right: 10,
                                top: 20,
                                child: GestureDetector(
                                    onTap: () {
                                      Get.to(OptionalDetailsTourAndTravel(
                                        id: productDetailsModel.value.productDetails!.product!.id,
                                        hostNameController:
                                        productDetailsModel.value.productDetails!.product!.host_name,
                                        locationController: productDetailsModel
                                            .value.productDetails!.product!.bookable_product_location,
                                        programDescription:
                                        productDetailsModel.value.productDetails!.product!.program_desc,
                                        programGoalController:
                                        productDetailsModel.value.productDetails!.product!.program_goal,
                                        programNameController:
                                        productDetailsModel.value.productDetails!.product!.program_name,
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
                            isSponsors.toggle();
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
                                'Sponsors'.tr,
                                style: GoogleFonts.poppins(
                                  color: AppTheme.primaryColor,
                                  fontSize: 15,
                                ),
                              ),
                              GestureDetector(
                                child: isSponsors.value != true
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
                                    isSponsors.toggle();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isSponsors.value == true)
                        Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              width: Get.width,
                              padding: EdgeInsets.all(10),
                              decoration:
                              BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(11)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${"Sponsor type:".tr} ${productDetailsModel.value.productDetails!.product!.bookable_product_location ?? ""}'),
                                  Text('${"Sponsor name:".tr} ${productDetailsModel.value.productDetails!.product!.host_name ?? ""}'),
                                ],
                              ),
                            ),
                            Positioned(
                                right: 10,
                                top: 20,
                                child: GestureDetector(
                                    onTap: () {
                                      Get.to(SponsorsScreenTourAndTravel(
                                        id: productDetailsModel.value.productDetails!.product!.id,
                                        sponsorName: productDetailsModel.value.productDetails!.product!.host_name,
                                        sponsorType: productDetailsModel.value.productDetails!.product!.bookable_product_location,
                                        image : productDetailsModel.value.productDetails!.product!.productSponsors!.sponsorLogo.toString(),
                                        sponsorsID: productDetailsModel.value.productDetails!.product!.productSponsors!.id.toString(),
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
                            eligibleCustomer.toggle();
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
                                'Eligible Customers'.tr,
                                style: GoogleFonts.poppins(
                                  color: AppTheme.primaryColor,
                                  fontSize: 15,
                                ),
                              ),
                              GestureDetector(
                                child: eligibleCustomer.value != true
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
                                    eligibleCustomer.toggle();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (eligibleCustomer.value == true)
                        Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              width: Get.width,
                              padding: EdgeInsets.all(10),
                              decoration:
                              BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(11)),
                              child:  Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${"Age range:".tr} ${productDetailsModel.value.productDetails!.product!.eligible_min_age ?? ""} to  ${productDetailsModel.value.productDetails!.product!.eligible_max_age ?? ""}'),
                                  Text('${"eligible gender :".tr} ${productDetailsModel.value.productDetails!.product!.eligible_gender ?? ""}'),
                                ],
                              ),
                            ),
                            Positioned(
                                right: 10,
                                top: 20,
                                child: GestureDetector(
                                    onTap: () {
                                      Get.to(EligibleCustomersTourAndTravel(
                                        id: productDetailsModel.value.productDetails!.product!.id,
                                        eligibleGender: productDetailsModel.value.productDetails!.product!.eligible_gender,
                                        eligibleMaxAge: productDetailsModel.value.productDetails!.product!.eligible_max_age,
                                        eligibleMinAge: productDetailsModel.value.productDetails!.product!.eligible_min_age,
                                      ));
                                    },
                                    child: Text(
                                      'Edit'.tr,
                                      style: TextStyle(color: Colors.red, fontSize: 13),
                                    )))
                          ],
                        ),
                      const SizedBox(height: 20),
                      CustomOutlineButton(
                        title: 'Confirm'.tr,
                        borderRadius: 11,
                        onPressed: () {
                          completeApi();

                        },
                      ),
                    ],
                  ),
                ),
              )
            : const LoadingAnimation();
      }),
    );
  }
}
