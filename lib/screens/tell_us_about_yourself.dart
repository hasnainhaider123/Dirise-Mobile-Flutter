import 'dart:convert';

import 'package:dirise/screens/tour_travel/date_range_screen_tour.dart';
import 'package:dirise/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controller/profile_controller.dart';
import '../controller/vendor_controllers/add_product_controller.dart';
import '../model/common_modal.dart';
import '../repository/repository.dart';
import '../utils/api_constant.dart';
import 'Consultation Sessions/date_range_screen.dart';
import 'Seminars &  Attendable Course/seminars_date_screen.dart';
import 'Virtual course & Classes Webinars/webinars_date_screen.dart';
import 'academic programs/date_range_screen.dart';
import 'extendedPrograms/date_range_screen.dart';
import 'my_account_screens/contact_us_screen.dart';


class TellUsYourSelfScreen extends StatefulWidget {
  const TellUsYourSelfScreen({super.key});

  @override
  State<TellUsYourSelfScreen> createState() => _TellUsYourSelfScreenState();
}

class _TellUsYourSelfScreenState extends State<TellUsYourSelfScreen> {

  final Repositories repositories = Repositories();
  final addProductController = Get.put(AddProductController());
  final profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return  Scaffold(
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
              'Item Type'.tr,
              style: GoogleFonts.poppins(color: const Color(0xff292F45), fontWeight: FontWeight.w600, fontSize: 20),
            ),
          ],
        ),
      ),
      body:SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50,horizontal: 10),
          child: Column(
              children:[
                // Text("Item Type".tr,style:GoogleFonts.poppins(fontSize:20,fontWeight:FontWeight.w500)),
                // const SizedBox(height: 30,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13,),
                  child: Text("What’s best that align with your bookable product & service ?".tr,style:GoogleFonts.poppins(fontSize:20)),
                ),
                const SizedBox(height: 20,),
                GestureDetector (
                  onTap: (){
                    Map<String, dynamic> map = {};
                    map['booking_product_type'] = 'appointment';
                    map['id'] = addProductController.idProduct.value.toString();
                    repositories.postApi(url: ApiUrls.giveawayProductAddress, context: context, mapData: map).then((value) {
                      ModelCommonResponse response = ModelCommonResponse.fromJson(jsonDecode(value));
                      if (response.status == true) {
                        Get.to(()=> DateRangeScreen());
                      }
                    });
                  },
                  child: Container(
                    width:size.width,
                    decoration:  BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10),),
                      image: DecorationImage(
                        // image: AssetImage('assets/images/consultion.png'),
                        image: profileController.selectedLAnguage.value == "English"
                        ?AssetImage('assets/images/consultion.png')
                        :AssetImage('assets/images/consultionarabic.png'),
                        // fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF37C666).withOpacity(0.10),
                          offset: const Offset(.1, .1,
                          ),
                          blurRadius: 20.0,
                          spreadRadius: 1.0,
                        ),
                      ],
                    ),
                   height: size.height*.26,
                   //  child:  Padding(
                   //    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                   //    child: Column(
                   //        crossAxisAlignment: CrossAxisAlignment.start,
                   //        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   //        children:[
                   //          Text('Consultation Sessions  '.tr,style:GoogleFonts.poppins(fontSize:26,fontWeight:FontWeight.w500)),
                   //          4.spaceY,
                   //          Text('General category for one on one appointments '.tr,style:GoogleFonts.poppins(fontSize:20)),
                   //          4.spaceY,
                   //          Text('Doctors, coaches, lawyers, stylists that need scheduling Design - personal - Financial Consultation ..etc.'.tr,style:GoogleFonts.poppins(fontSize:16))
                   //
                   //        ]),
                   //  )
                   //  ,// add your child widgets here
                  ),
                ),
                // const SizedBox(height: 10,),
                GestureDetector(
                  onTap: (){
                    Map<String, dynamic> map = {};
                    map['booking_product_type'] = 'academic_program';
                    map['id'] = addProductController.idProduct.value.toString();
                    repositories.postApi(url: ApiUrls.giveawayProductAddress, context: context, mapData: map).then((value) {
                      ModelCommonResponse response = ModelCommonResponse.fromJson(jsonDecode(value));
                      if (response.status == true) {
                        Get.to(()=> AcademicDateScreen());
                      }
                    });
                  },
                  child: Container(
                    width:size.width,
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                      image: DecorationImage(
                        // image: AssetImage('assets/images/academic.png'),
                        image : profileController.selectedLAnguage.value == "English"
                        ?AssetImage('assets/images/academic.png')
                        :AssetImage('assets/images/academicarabic.png'),
                        // fit: BoxFit.cover,
                      ),
                    ),
                    height: size.height*.26,
                    // child:  Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                    //   child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       children:[
                    //         Text('Academic Programs'.tr,style:GoogleFonts.poppins(fontSize:26,fontWeight:FontWeight.w500)),
                    //         Text('Monthly & yearly scheduling for educational programs'.tr,style:GoogleFonts.poppins(fontSize:20))
                    //       ]),
                    // )
                    // ,// add your child widgets here
                  ),
                ),
                // const SizedBox(height: 20,),
                GestureDetector(
                  onTap: (){
                    Map<String, dynamic> map = {};
                    map['booking_product_type'] = 'monthly_program';
                    map['id'] = addProductController.idProduct.value.toString();
                    repositories.postApi(url: ApiUrls.giveawayProductAddress, context: context, mapData: map).then((value) {
                      ModelCommonResponse response = ModelCommonResponse.fromJson(jsonDecode(value));
                      if (response.status == true) {
                        Get.to(()=> ExtendedProgramsScreenDateScreen());
                      }
                    });
                  },
                  child: Container(
                    width:size.width,
                    decoration:  BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                      image: DecorationImage(
                        // image: AssetImage('assets/images/extended.png'),
                        image : profileController.selectedLAnguage.value == "English"
                        ?AssetImage('assets/images/extended.png')
                        :AssetImage('assets/images/extendedarabic.png'),
                        // fit: BoxFit.cover,
                      ),
                    ),
                    // adjust the width and height as needed
                    height: size.height*.26,
                    // child:  Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                    //   child: Column(
                    //
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //
                    //       children:[
                    //         Text('Extended Programs'.tr,style:GoogleFonts.poppins(fontSize:30,fontWeight:FontWeight.w500)),
                    //         Text('Weekly & Monthly programs'.tr,style:GoogleFonts.poppins(fontSize:20)),
                    //         Text('Flexible scheduling for programs and group training '.tr,style:GoogleFonts.poppins(fontSize:18))
                    //
                    //       ]),
                    // )
                    // ,// add your child widgets here
                  ),
                ),
                // const SizedBox(height: 20,),
                GestureDetector(
                  onTap: (){
                    Map<String, dynamic> map = {};
                    map['booking_product_type'] = 'tour_travel';
                    map['id'] = addProductController.idProduct.value.toString();
                    repositories.postApi(url: ApiUrls.giveawayProductAddress, context: context, mapData: map).then((value) {
                      ModelCommonResponse response = ModelCommonResponse.fromJson(jsonDecode(value));
                      if (response.status == true) {
                        Get.to(()=> DateRangeScreenTour());
                      }
                    });
                  },
                  child: Container(
                    width:size.width,
                    decoration:  BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                      image: DecorationImage(
                        // image: AssetImage('assets/images/tour_travles.png'),
                        image : profileController.selectedLAnguage.value == "English"
                        ?AssetImage('assets/images/tour_travles.png')
                        :AssetImage('assets/images/tour-travelarabic.png'),
                        // fit: BoxFit.cover,
                      ),
                    ),
                    // adjust the width and height as needed
                    height: size.height*.26,
                    // child:  Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                    //   child: Column(
                    //
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //
                    //       children:[
                    //         Text('Tour & Travel'.tr,style:GoogleFonts.poppins(fontSize:30,fontWeight:FontWeight.w500)),
                    //         Text('Focused more on dates & time at a location '.tr,style:GoogleFonts.poppins(fontSize:18))
                    //
                    //       ]),
                    // )
                    // ,// add your child widgets here
                  ),
                ),
                // const SizedBox(height: 20,),
                GestureDetector(
                  onTap: (){
                    Map<String, dynamic> map = {};
                    map['booking_product_type'] = 'seminar';
                    map['id'] = addProductController.idProduct.value.toString();
                    repositories.postApi(url: ApiUrls.giveawayProductAddress, context: context, mapData: map).then((value) {
                      ModelCommonResponse response = ModelCommonResponse.fromJson(jsonDecode(value));
                      if (response.status == true) {
                        Get.to(()=> DateRangeSeminarsScreen());
                      }
                    });
                  },
                  child: Container(
                    width:size.width,
                    decoration:  BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                      image: DecorationImage(
                        // image: AssetImage('assets/images/class_courses.png'),
                        image : profileController.selectedLAnguage.value == "English"
                        ?AssetImage('assets/images/class_courses.png')
                        :AssetImage('assets/images/attendablearabic.png'),
                        // fit: BoxFit.cover,
                      ),
                    ),
                    // adjust the width and height as needed
                    height: size.height*.26,
                    // child:  Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                    //   child: Column(
                    //
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //
                    //       children:[
                    //         Text('Attendable Seminars, Courses & Classes'.tr,style:GoogleFonts.poppins(fontSize:28,fontWeight:FontWeight.w500)),
                    //         Text('Gather your customers at a location that you choose. '.tr,style:GoogleFonts.poppins(fontSize:18))
                    //
                    //       ]),
                    // )
                    // ,// add your child widgets here
                  ),
                ),
                // const SizedBox(height: 20,),
                GestureDetector (
                  onTap: (){
                    Map<String, dynamic> map = {};
                    map['booking_product_type'] = 'webinar';
                    map['id'] = addProductController.idProduct.value.toString();
                    repositories.postApi(url: ApiUrls.giveawayProductAddress, context: context, mapData: map).then((value) {
                      ModelCommonResponse response = ModelCommonResponse.fromJson(jsonDecode(value));
                      if (response.status == true) {
                        Get.to(()=> DateRangeWebiinarsScreen());
                      }
                    });
                  },
                  child: Container(
                    width:size.width,
                    decoration:  BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                      image: DecorationImage(
                        // image: AssetImage('assets/images/virtual_class.png'),
                        image : profileController.selectedLAnguage.value == "English"
                        ?AssetImage('assets/images/virtual_class.png')
                        :AssetImage('assets/images/virtualwebinararabic.png'),
                        // fit: BoxFit.cover,
                      ),
                    ),
                    // adjust the width and height as needed
                    height: size.height*.26,
                    // child:  Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                    //   child: Column(
                    //
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //
                    //       children:[
                    //         Text('Virtual Webinars, Courses & Classes'.tr,style:GoogleFonts.poppins(fontSize:28,fontWeight:FontWeight.w500)),
                    //         Text('Focused more on dates & time at a location '.tr,style:GoogleFonts.poppins(fontSize:18))
                    //
                    //       ]),
                    // )
                    // ,// add your child widgets here
                  ),
                ),
                const SizedBox(height: 20,),
                GestureDetector(
                  onTap: (){
                    Get.to(() => const ContactUsScreen());
                  },
                  child: Container(
                    width:size.width,
                    decoration:  BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(10)),
                      image: DecorationImage(
                        // image: AssetImage('assets/images/last_img.png'),
                        image : profileController.selectedLAnguage.value == "English"
                        ?AssetImage('assets/images/last_img.png')
                        :AssetImage('assets/images/othersarabic.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    // adjust the width and height as needed
                    height: size.height*.26,
                    // child:  Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                    //   child: Column(
                    //
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //
                    //       children:[
                    //         Text('Others'.tr,style:GoogleFonts.poppins(fontSize:28,fontWeight:FontWeight.w500)),
                    //         Text('Not available in your region'.tr,style:GoogleFonts.poppins(fontSize:22,fontWeight:FontWeight.w500)),
                    //         Expanded(child: Text('Use our system to your advantage. If you are not sure, we are happy to hear from you. contact us  '.tr,
                    //             overflow: TextOverflow.ellipsis,
                    //             style:GoogleFonts.poppins(fontSize:18)))
                    //
                    //
                    //       ]),
                    // )
                    // ,// add your child widgets here
                  ),
                ),
                // Text("Extra information",),
                // Text("This is an optional step for some products")
              ]
        
          ),
        ),
      ),
    );
  }
}
