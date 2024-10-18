import 'dart:convert';
import 'dart:developer';

import 'package:dirise/controller/profile_controller.dart';
import 'package:dirise/iAmHereToSell/whatdoyousellScreen.dart';
import 'package:dirise/model/vendor_models/newVendorPlanlist.dart';
import 'package:dirise/screens/my_account_screens/termsconditions_screen.dart';
import 'package:dirise/utils/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../repository/repository.dart';
import '../utils/api_constant.dart';
import '../utils/styles.dart';
import '../widgets/common_colour.dart';

class WhichplantypedescribeyouScreen extends StatefulWidget {
  const WhichplantypedescribeyouScreen({super.key});

  @override
  State<WhichplantypedescribeyouScreen> createState() => _WhichplantypedescribeyouScreenState();
}

class _WhichplantypedescribeyouScreenState extends State<WhichplantypedescribeyouScreen> {
  bool showValidation = false;
  bool? _isValue = false;
  int _selectedOption = 0;
  final profileController = Get.put(ProfileController());

  final Repositories repositories = Repositories();
  ModelPlansList? modelPlansList;

  getPlansList() {
    repositories.getApi(url: ApiUrls.vendorPlanUrl).then((value) {
      modelPlansList = ModelPlansList.fromJson(jsonDecode(value));
      setState(() {});
      log("message");
    });
  }

  void vendorregister() {
    if( _selectedOption == 1){
      profileController.vendorType = 'advertisement';
    } else if( _selectedOption == 2){
      profileController.vendorType = 'personal';
    }else{
      profileController.vendorType = 'company';
    }
    Map<String, String> map = {};
    map["vendor_type"] = profileController.vendorType.toString();
    repositories.postApi(url: ApiUrls.vendorRegistrationUrl, context: context, mapData: map).then((value) async {
      if (_selectedOption == 1 || _selectedOption == 2 || _selectedOption == 3 ) {
        if (_isValue == true) {
          Get.to(const WhatdoyousellScreen());
        } else {
          showToast("Agree terms and Conditions".tr);
        }
      } else {
        showToast("Please select a plan first".tr);
      }
    });
  }
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _cloudComparisonKey = GlobalKey();

  void _scrollToCloudComparison() {
    final RenderBox renderBox = _cloudComparisonKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero, ancestor: null).dy;

    _scrollController.animateTo(
      position,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }
  @override
  void initState() {
    super.initState();

    getPlansList();
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
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Which cloud type suits you?'.tr,
              style: GoogleFonts.poppins(color: const Color(0xff292F45), fontWeight: FontWeight.w600, fontSize: 18),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              20.spaceY,
              Center(
                child: Text(
                  'Dirise cloud space'.tr,
                  style: GoogleFonts.poppins(color: const Color(0xff0D5877), fontWeight: FontWeight.w500, fontSize: 19),
                ),
              ),
              30.spaceY,
              Center(
                child: Text(
                  'A cloud area is the area that you are going to rent from dirise for a period of 12 months for your business'.tr,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: const Color(0xff514949), fontWeight: FontWeight.w400, fontSize: 13),
                ),
              ),
              // Text(
              //   'Startups:'.tr,
              //   style: GoogleFonts.poppins(color: const Color(0xff0D5877), fontWeight: FontWeight.w500, fontSize: 16),
              // ),
              // Text(
              //   'For start ups that want to sell their products in the Dirise platform.'.tr,
              //   style: GoogleFonts.poppins(color: const Color(0xff514949), fontWeight: FontWeight.w400, fontSize: 13),
              // ),
              // Text(
              //   'Enterprise:'.tr,
              //   style: GoogleFonts.poppins(color: const Color(0xff0D5877), fontWeight: FontWeight.w500, fontSize: 16),
              // ),
              // Text(
              //   'For companies with commercial license and corporate bank account.'.tr,
              //   style: GoogleFonts.poppins(color: const Color(0xff514949), fontWeight: FontWeight.w400, fontSize: 13),
              // ),
              const SizedBox(
                height: 20,
              ),   
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  profileController.selectedLAnguage.value == "English"
                  ?Image.asset('assets/images/monthtrail.png',width: 120,)
                  :Image.asset('assets/images/cloudspace.png',width: 120,),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Showcasing cloud space'.tr,
                style: GoogleFonts.poppins(color: const Color(0xff0D5877), fontWeight: FontWeight.w600, fontSize: 19),
              ),
              Text(
                'S-space'.tr,
                style: GoogleFonts.poppins(color: const Color(0xff0D5877), fontWeight: FontWeight.w600, fontSize: 19),
              ),
              Text(
                'Limited to showcasing only, any payments will be done outside the platform.'.tr,
                style: GoogleFonts.poppins(color: const Color(0xff514949), fontWeight: FontWeight.w400, fontSize: 13),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Cloud office space'.tr,
                style: GoogleFonts.poppins(color: const Color(0xff0D5877), fontWeight: FontWeight.w600, fontSize: 19),
              ),
              Text(
                'C-space'.tr,
                style: GoogleFonts.poppins(color: const Color(0xff0D5877), fontWeight: FontWeight.w600, fontSize: 19),
              ),
              Text(
                'For small business that are in the process of becoming an official business'.tr,
                style: GoogleFonts.poppins(color: const Color(0xff514949), fontWeight: FontWeight.w400, fontSize: 13),
              ),
               const SizedBox(
                height: 20,
              ),
              Text(
                'Enterprise cloud space'.tr,
                style: GoogleFonts.poppins(color: const Color(0xff0D5877), fontWeight: FontWeight.w600, fontSize: 19),
              ),
              Text(
                'E-space'.tr,
                style: GoogleFonts.poppins(color: const Color(0xff0D5877), fontWeight: FontWeight.w600, fontSize: 19),
              ),
              Text(
                'For companies with commercial license and corporate bank account'.tr,
                style: GoogleFonts.poppins(color: const Color(0xff514949), fontWeight: FontWeight.w400, fontSize: 13),
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: _scrollToCloudComparison,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Full comparison'.tr,
                          style: GoogleFonts.poppins(color: const Color(0xff0D5877), fontWeight: FontWeight.w500, fontSize: 15,
                          decoration: TextDecoration.underline
                          ),
                        ),
                        Text(
                          'Read more info'.tr,
                          style: GoogleFonts.poppins(color: const Color(0xff0D5877), fontWeight: FontWeight.w500, fontSize: 15,
                          decoration: TextDecoration.underline
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              GestureDetector(
                onTap: (){
                  setState(() {
                    _selectedOption = 1;
                    profileController.selectedPlan = '1';
                  });
                },
                child: Container(
                  width: Get.width,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey.shade200,
                    border: _selectedOption == 1 ? Border.all(color: const Color(0xff0D5877)) : const Border(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Showcasing cloud space'.tr,
                              style: GoogleFonts.poppins(
                                  color: const Color(0xff0D5877), fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            5.spaceY,
                            Text(
                              'Showcasing only'.tr,
                              style: GoogleFonts.poppins(
                                  color: const Color(0xff111727), fontWeight: FontWeight.w400, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      // Radio(
                      //   value: 1,
                      //   groupValue: _selectedOption,
                      //   onChanged: (value) {
                      //     setState(() {
                      //       _selectedOption = value!;
                      //       profileController.selectedPlan = value.toString();
                      //     });
                      //   },
                      // ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              if (_selectedOption == 1) ...[
                Container(
                    padding: const EdgeInsets.all(10),
                    width: Get.width,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: const [
                      BoxShadow(
                          offset: Offset(1, 1),
                          color: Colors.grey,
                          blurRadius: 1,
                          blurStyle: BlurStyle.outer,
                          spreadRadius: 1)
                    ]),
                    child: Column(
                      children: [
                        // Text(
                        //   "Showcasing Cloud Space ",
                        //   style: GoogleFonts.poppins(
                        //       color: const Color(0xff111727), fontWeight: FontWeight.w600, fontSize: 16),
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Cloud description  ".tr,
                                  style: GoogleFonts.poppins(
                                      color: AppTheme.buttonColor, fontWeight: FontWeight.w500, fontSize: 18),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  "Limited to showcasing only  ".tr,
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xff111727), fontWeight: FontWeight.w600, fontSize: 10),
                                ),
                              ],
                            ),
                            profileController.selectedLAnguage.value == "English"
                            ?Image.asset('assets/images/monthtrail.png',width: 80,)
                            :Image.asset('assets/images/cloudspace.png',width: 80,),
                          ],
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Text(
                          "Owners of the showcasing cloud can only showcase their products, all payments will be done outside of the dirise platform. Customers will contact the vendor directly through a phone number or messages".tr,
                          style: GoogleFonts.poppins(
                              color: const Color(0xff111727), fontWeight: FontWeight.w400, fontSize: 10),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        profileController.selectedLAnguage.value == "English"
                        ?Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset("assets/images/cart_img_neww.png",height: 80, width: 80),
                                Text(
                                  "500 products".tr,
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xff111727), fontWeight: FontWeight.w500, fontSize: 12),
                                ),
                                3.spaceY,
                                Text(
                                  "Per 12 months".tr,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xff5AC036), fontWeight: FontWeight.w500, fontSize: 10),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset("assets/images/camera.png",height: 80, width: 80),
                                Text(
                                  "Product photography".tr,
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xff111727), fontWeight: FontWeight.w500, fontSize: 12),
                                ),
                                3.spaceY,
                                Text(
                                  "Available upon request".tr,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xff5AC036), fontWeight: FontWeight.w500, fontSize: 10),
                                ),
                              ],
                            ),
                            // SvgPicture.asset(
                            //         "assets/svgs/product_photography.svg",
                            //   height: 175,
                            //   width: 175,
                            //       ),
                          ],
                        )
                        :Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset("assets/images/product1.png",height: 80, width: 80),
                                Text(
                                  "500 products".tr,
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xff111727), fontWeight: FontWeight.w500, fontSize: 12),
                                ),
                                3.spaceY,
                                Text(
                                  "Per 12 months".tr,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xff5AC036), fontWeight: FontWeight.w500, fontSize: 10),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset("assets/images/product2.png",height: 80, width: 80),
                                Text(
                                  "Product photography".tr,
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xff111727), fontWeight: FontWeight.w500, fontSize: 12),
                                ),
                                3.spaceY,
                                Text(
                                  "Available upon request".tr,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xff5AC036), fontWeight: FontWeight.w500, fontSize: 10),
                                ),
                              ],
                            ),
                            // SvgPicture.asset(
                            //         "assets/svgs/product_photography.svg",
                            //   height: 175,
                            //   width: 175,
                            //       ),
                          ],
                        ),
                        30.spaceY,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/product3.png",height: 80, width: 80),
                            Text(
                              "Receive payments".tr,
                              style: GoogleFonts.poppins(
                                  color: const Color(0xff111727), fontWeight: FontWeight.w500, fontSize: 12),
                            ),
                            3.spaceY,
                            Text(
                              "Never allowed".tr,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  color: const Color(0xffEB4335), fontWeight: FontWeight.w500, fontSize: 10),
                            ),
                          ],
                        ),
                        // Center(
                        //     child: Image.asset(
                        //       "assets/images/p1_new.png",
                        //     )),
                        Center(
                            child: profileController.selectedLAnguage.value == "English"
                            ?Image.asset("assets/images/plan1.png",)
                            :Image.asset("assets/images/showcasecloudspace.png",)
                        ),
                      ],
                    )),
              ],
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: (){
                  setState(() {
                    _selectedOption = 2;
                    profileController.selectedPlan = '2';
                  });
                },
                child: Container(
                  width: Get.width,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey.shade200,
                    border: _selectedOption == 2 ? Border.all(color: const Color(0xff0D5877)) : const Border(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cloud office space'.tr,
                              style: GoogleFonts.poppins(
                                  color: const Color(0xff0D5877), fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            5.spaceY,
                            Text(
                              'Small businesses & startups '.tr,
                              style: GoogleFonts.poppins(
                                  color: const Color(0xff111727), fontWeight: FontWeight.w400, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      // Radio(
                      //   value: 2,
                      //   groupValue: _selectedOption,
                      //   onChanged: (value) {
                      //     setState(() {
                      //       _selectedOption = value!; // Update selected option
                      //       profileController.selectedPlan = value.toString();
                      //     });
                      //   },
                      // ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              if (_selectedOption == 2) ...[
                Container(
                    padding: const EdgeInsets.all(10),
                    width: Get.width,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: const [
                      BoxShadow(
                          offset: Offset(1, 1),
                          color: Colors.grey,
                          blurRadius: 1,
                          blurStyle: BlurStyle.outer,
                          spreadRadius: 1)
                    ]),
                    child: Column(
                      children: [
                        // Text(
                        //   "Cloud Office Space ",
                        //   style: GoogleFonts.poppins(
                        //       color: const Color(0xff111727), fontWeight: FontWeight.w600, fontSize: 16),
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Cloud description  ".tr,
                                  style: GoogleFonts.poppins(
                                      color: AppTheme.buttonColor, fontWeight: FontWeight.w500, fontSize: 18),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  "Small businesses & start ups  ".tr,
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xff111727), fontWeight: FontWeight.w600, fontSize: 10),
                                ),
                              ],
                            ),
                            profileController.selectedLAnguage.value == "English"
                            ?Image.asset('assets/images/monthtrail.png',width: 80,)
                            :Image.asset('assets/images/cloudspace.png',width: 80,),
                          ],
                        ),
                        Text(
                          "For businesses that are working on getting the required official document to be recognized as an official company".tr,
                          style: GoogleFonts.poppins(
                              color: const Color(0xff111727), fontWeight: FontWeight.w400, fontSize: 10),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Center(
                            child: profileController.selectedLAnguage.value =="English"
                            ?Image.asset("assets/images/p2_new.png",)
                            :Image.asset("assets/images/cloudspace2.png",)
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                offset: const Offset(.1, .1,
                                ),
                                blurRadius: 20.0,
                                spreadRadius: 1.0,
                              ),
                            ],
                          ),
                          child: Center(
                              child: profileController.selectedLAnguage.value == "English"
                              ?Image.asset("assets/images/plan2.png",)
                              :Image.asset("assets/images/officecloudspace.png",)
                          ),
                        ),
                      ],
                    )),
              ],
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: (){
                  setState(() {
                    _selectedOption = 3;
                    profileController.selectedPlan = '3';
                  });
                },
                child: Container(
                  width: Get.width,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey.shade200,
                    border: _selectedOption == 3 ? Border.all(color: const Color(0xff0D5877)) : const Border()),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enterprise cloud space'.tr,
                              style: GoogleFonts.poppins(
                                  color: const Color(0xff0D5877), fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            5.spaceY,
                            Text(
                              'Established official businesses '.tr,
                              style: GoogleFonts.poppins(
                                  color: const Color(0xff111727), fontWeight: FontWeight.w400, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      // Radio(
                      //   value: 3,
                      //   groupValue: _selectedOption,
                      //   onChanged: (value) {
                      //     setState(() {
                      //       _selectedOption = value!; // Update selected option
                      //       profileController.selectedPlan = value.toString();
                      //     });
                      //   },
                      // ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              if (_selectedOption == 3) ...[
                Container(
                    padding: const EdgeInsets.all(10),
                    width: Get.width,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: const[
                       BoxShadow(
                          offset: Offset(1, 1),
                          color: Colors.grey,
                          blurRadius: 1,
                          blurStyle: BlurStyle.outer,
                          spreadRadius: 1)
                    ]),
                    child: Column(
                      children: [
                        // Text(
                        //   "Enterprise Cloud Space  ",
                        //   style: GoogleFonts.poppins(
                        //       color: const Color(0xff111727), fontWeight: FontWeight.w600, fontSize: 16),
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Cloud description  ".tr,
                                    style: GoogleFonts.poppins(
                                        color: AppTheme.buttonColor, fontWeight: FontWeight.w500, fontSize: 18),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    "Official businesses  ".tr,
                                    style: GoogleFonts.poppins(
                                        color: const Color(0xff111727), fontWeight: FontWeight.w500, fontSize: 16),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    "This cloud is suitable for any official business that has already been established with a corporate bank account".tr,
                                    style: GoogleFonts.poppins(
                                        color: const Color(0xff514949), fontWeight: FontWeight.w400, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            profileController.selectedLAnguage.value == "English"
                            ?Image.asset('assets/images/monthtrail.png',width: 80)
                            :Image.asset('assets/images/cloudspace.png',width: 80),
                          ],
                        ),
                        const SizedBox(
                          height: 14,
                        ),
                        Center(
                            child:profileController.selectedLAnguage.value == "English"
                            ?Image.asset("assets/images/p3_new.png",)
                            :Image.asset("assets/images/cloudspace3.png",)
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                offset: const Offset(.1, .1,
                                ),
                                blurRadius: 20.0,
                                spreadRadius: 1.0,
                              ),
                            ],
                          ),
                          child: Center(
                              child: profileController.selectedLAnguage.value == "English"
                                  ?Image.asset("assets/images/plan2.png",)
                                  :Image.asset("assets/images/officecloudspace.png",)
                          ),
                        ),
                      ],
                    )),
              ],
              const SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Clouds comparison'.tr,
                  style: GoogleFonts.poppins(color: const Color(0xff014E70), fontWeight: FontWeight.w500, fontSize: 24),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              // Container(
              //   padding: const EdgeInsets.only(bottom: 10, top: 10),
              //   margin: const EdgeInsets.only(left: 10, right: 10),
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(4),
              //     border: Border.all(color: const Color(0xff353A21), width: 1.0),
              //   ),
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.start,
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Container(
              //         color: Colors.white,
              //         child: Table(
              //           // Remove TableBorder to remove lines between columns
              //           // border: TableBorder.all(color: Colors.black),
              //           columnWidths: const {
              //             0: FlexColumnWidth(3),
              //           },
              //           children: [
              //             TableRow(children: [
              //               Text(
              //                 'Cloud'.tr,
              //                 style: GoogleFonts.poppins(
              //                   color: const Color(0xff0D0C0C),
              //                   fontWeight: FontWeight.w600,
              //                   fontSize: 10,
              //                 ),
              //               ),
              //               Text(
              //                 'Showcasing'.tr,
              //                 style: GoogleFonts.poppins(
              //                   color: const Color(0xff0D0C0C),
              //                   fontWeight: FontWeight.w600,
              //                   fontSize: 10,
              //                 ),
              //               ),
              //               Text(
              //                 'Office'.tr,
              //                 style: GoogleFonts.poppins(
              //                   color: const Color(0xff0D0C0C),
              //                   fontWeight: FontWeight.w600,
              //                   fontSize: 10,
              //                 ),
              //               ),
              //               Text(
              //                 'Enterprise'.tr,
              //                 style: GoogleFonts.poppins(
              //                   color: const Color(0xff0D0C0C),
              //                   fontWeight: FontWeight.w600,
              //                   fontSize: 10,
              //                 ),
              //               ),
              //             ]),
              //           ],
              //         ),
              //       ),
              //       Container(
              //         color: Colors.white,
              //         child: Table(
              //           border: TableBorder.all(color: Colors.black),
              //           columnWidths: const {
              //             0: FlexColumnWidth(3), // Adjust the value (3) as needed to increase or decrease the width
              //           },
              //           children: const [
              //             TableRow(children: [
              //               Text(
              //                 '11 Month + 500 Products',
              //                 style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              //               ),
              //               Text(
              //                 '10 KWD',
              //                 style: TextStyle(fontSize: 12),
              //               ),
              //               Text(
              //                 '11 KWD',
              //                 style: TextStyle(fontSize: 12),
              //               ),
              //               Text(
              //                 '12 KWD',
              //                 style: TextStyle(fontSize: 12),
              //               ),
              //             ]),
              //             TableRow(children: [
              //               Text(
              //                 '1st Month Charge Only',
              //                 style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              //               ),
              //               Icon(
              //                 Icons.check,
              //                 color: Colors.green,
              //               ),
              //               Icon(
              //                 Icons.check,
              //                 color: Colors.green,
              //               ),
              //               Icon(
              //                 Icons.check,
              //                 color: Colors.green,
              //               ),
              //             ]),
              //             TableRow(children: [
              //               Text(
              //                 '1st Month Charge Only',
              //                 style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              //               ),
              //               Icon(
              //                 Icons.cancel_outlined,
              //                 color: Colors.red,
              //               ),
              //               Icon(
              //                 Icons.cancel_outlined,
              //                 color: Colors.red,
              //               ),
              //               Text(
              //                 'Must',
              //                 style: TextStyle(fontSize: 12),
              //               ),
              //             ]),
              //             TableRow(children: [
              //               Text(
              //                 'Selling ',
              //                 style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              //               ),
              //               Text(
              //                 'Advertising only',
              //                 style: TextStyle(fontSize: 12),
              //               ),
              //               Icon(
              //                 Icons.check,
              //                 color: Colors.green,
              //               ),
              //               Icon(
              //                 Icons.check,
              //                 color: Colors.green,
              //               ),
              //             ]),
              //             TableRow(children: [
              //               Text(
              //                 'Receiving Money',
              //                 style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              //               ),
              //               Icon(
              //                 Icons.cancel_outlined,
              //                 color: Colors.red,
              //               ),
              //               Icon(
              //                 Icons.check,
              //                 color: Colors.green,
              //               ),
              //               Icon(
              //                 Icons.check,
              //                 color: Colors.green,
              //               ),
              //             ]),
              //             TableRow(children: [
              //               Text(
              //                 'Withdrawing earning',
              //                 style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              //               ),
              //               Icon(
              //                 Icons.cancel_outlined,
              //                 color: Colors.red,
              //               ),
              //               Text(
              //                 'Verified deliveries',
              //                 style: TextStyle(fontSize: 12),
              //               ),
              //               Text(
              //                 'Documents Review',
              //                 style: TextStyle(fontSize: 12),
              //               ),
              //             ]),
              //             TableRow(children: [
              //               Text(
              //                 'Fees',
              //                 style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              //               ),
              //               Icon(
              //                 Icons.cancel_outlined,
              //                 color: Colors.red,
              //               ),
              //               Text(
              //                 'Up to 5%',
              //                 style: TextStyle(fontSize: 12),
              //               ),
              //               Text(
              //                 'Up to 5%',
              //                 style: TextStyle(fontSize: 12),
              //               ),
              //             ]),
              //           ],
              //         ),
              //       ),
              //       Container(
              //         color: Colors.white,
              //         child: Table(
              //           border: TableBorder.all(color: Colors.black),
              //           columnWidths: const {
              //             0: FlexColumnWidth(1), // Adjust the value (3) as needed to increase or decrease the width
              //           },
              //           children: const [
              //             TableRow(children: [
              //               Text('Extra 500 products', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              //               Text(
              //                 '4 KWD',
              //                 style: TextStyle(fontSize: 12),
              //               ),
              //             ]),
              //             TableRow(children: [
              //               Text('Photography session', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              //               Text(
              //                 'Available upon request',
              //                 style: TextStyle(fontSize: 12),
              //               ),
              //             ]),
              //             TableRow(children: [
              //               Text('Photography session with discription',
              //                   style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              //               Text(
              //                 'Available upon request',
              //                 style: TextStyle(fontSize: 12),
              //               ),
              //             ]),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              Container(
                  key: _cloudComparisonKey,
                  child: profileController.selectedLAnguage.value == "English"
              ?Image.asset('assets/images/table.png')
              :Image.asset('assets/images/table1.png')),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: (){
                  launchUrlString("tel://+965 6555 6490");
                },
                child: Align(
                  alignment: Alignment.center,
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        color: const Color(0xff014E70),
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                      ),
                      children: [
                        TextSpan(
                          text: 'Contact '.tr,
                        ),
                        TextSpan(
                          text: '+965 6555 6490',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(
                          text: ' if you need assistance'.tr,
                        ),
                      ],
                    ),
                  ),
                ),

              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Transform.translate(
                    offset: const Offset(-6, 0),
                    child: Checkbox(
                        visualDensity: const VisualDensity(horizontal: -1, vertical: -3),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        value: _isValue,
                        side: BorderSide(
                          color: showValidation == false ? const Color(0xff0D5877) : Colors.red,
                        ),
                        onChanged: (bool? value) {
                          setState(() {
                            _isValue = value;
                          });
                        }),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: (){
                        Get.to(()=> const TermConditionScreen());
                      },
                      child: Text(
                        'I agree to DIRISE terms & condition, privacy policy and DIRISE free program*'.tr,
                        style: GoogleFonts.poppins(
                            color: const Color(0xff7B7D7C), fontWeight: FontWeight.w400, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  vendorregister();
                },
                child: Container(
                  width: Get.width,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xff0D5877), // Border color
                      width: 1.0, // Border width
                    ),
                    borderRadius: BorderRadius.circular(2), // Border radius
                  ),
                  padding: const EdgeInsets.all(10), // Padding inside the container
                  child:   Center(
                    child: Text(
                      'Next'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.buttonColor, // Text color
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
