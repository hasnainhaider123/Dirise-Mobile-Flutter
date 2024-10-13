import 'package:dirise/screens/tour_travel/review_publish_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:dirise/utils/helper.dart';
import 'package:dirise/widgets/common_textfield.dart';
import '../../controller/profile_controller.dart';
import '../../controller/vendor_controllers/add_product_controller.dart';
import '../../model/common_modal.dart';
import '../../repository/repository.dart';
import '../../utils/api_constant.dart';
import '../../widgets/common_colour.dart';
import 'optional_details_tourandtravel.dart';
class TimingScreenTour extends StatefulWidget {
  dynamic id;
  dynamic startLocation;
  dynamic endLocation;
  dynamic startTime;
  dynamic endEndTime;
  dynamic spot;
  dynamic timingExtraNotes;
  TimingScreenTour({super.key,this.id,this.endLocation,this.startLocation,this.timingExtraNotes,
  this.spot,this.startTime,this.endEndTime});

  @override
  State<TimingScreenTour> createState() => _TimingScreenTourState();
}

class _TimingScreenTourState extends State<TimingScreenTour> {
  String selectedItemDay = 'Am';
  String selectedItemMin = 'Min';
  bool sundaySelected = false;
  bool mondaySelected = false;
  bool tueSelected = false;
  bool wedSelected = false;
  bool thurSelected = false;
  bool friSelected = false;
  bool satSelected = false;
  final formKey1 = GlobalKey<FormState>();
  final Repositories repositories = Repositories();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TextEditingController interValController = TextEditingController();
  TextEditingController spotController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController location1Controller = TextEditingController();
  TextEditingController notesController = TextEditingController();
  final addProductController = Get.put(AddProductController());
  final profileController = Get.put(ProfileController());
  optionalApi() {
    Map<String, dynamic> map = {};

    map['start_time'] = startTimeController.text.trim();
    map['end_time'] = endTimeController.text.trim();
    map['start_location'] = locationController.text.trim();
    map['end_location'] = location1Controller.text.trim();
    map['timing_extra_notes'] = notesController.text.trim();
    map['item_type'] = 'product';
    map['product_type'] = 'booking';
    map['booking_product_type'] = 'tour_travel';
    map['spot'] = spotController.text.trim();
    map['product_availability_id'] = profileController.productAvailabilityId;
    map["id"] = addProductController.idProduct.value.toString();

    FocusManager.instance.primaryFocus!.unfocus();
    repositories.postApi(url: ApiUrls.giveawayProductAddress, context: context, mapData: map).then((value) {
      ModelCommonResponse response = ModelCommonResponse.fromJson(jsonDecode(value));
      print('API Response Status Code: ${response.status}');
      // showToast(response.message.toString());
      if (response.status == true) {
        showToast(response.message.toString());
        if(formKey1.currentState!.validate()){
          if (widget.id != null) {
            Get.to(() => const ReviewandPublishTourScreenScreen());
          } else {
            Get.to(()=> OptionalDetailsTourAndTravel());
          }
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.id != null){
      startTimeController.text = widget.startTime.toString();
      endTimeController.text =widget.endEndTime.toString();
          locationController.text =widget.startLocation.toString();
          location1Controller.text =widget.endLocation.toString();
          notesController.text =widget.timingExtraNotes.toString();
          spotController.text =widget.spot.toString();
    }
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
              'Timing'.tr,
              style: GoogleFonts.poppins(color: const Color(0xff292F45), fontWeight: FontWeight.w600, fontSize: 20),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 18),
        child: Form(
          key: formKey1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                   Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        'Starting Time'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Text color
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      child: CommonTextField(
                        keyboardType: TextInputType.number,
                        hintText: 'Time'.tr,
                        controller: startTimeController,
                        validator: (value){
                          if(value!.trim().isEmpty){
                            return 'Enter time here'.tr;
                          }else{
                            return null;
                          }
                        },
                      )
                  ),
                  6.spaceX,
                  Expanded(
                    child: CommonTextField(
                      keyboardType: TextInputType.name,
                      hintText: 'Location'.tr,
                      controller: locationController,
                      validator: (value){
                        if(value!.trim().isEmpty){
                          return 'Enter location here'.tr;
                        }else{
                          return null;
                        }
                      },
                    )
                  ),
                ],
              ),

              10.spaceY,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                   Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      child: Text(
                        'End  Time'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Text color
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      child: CommonTextField(
                        keyboardType: TextInputType.number,
                        hintText: 'Time'.tr,
                        controller: endTimeController,
                        validator: (value){
                          if(value!.trim().isEmpty){
                            return 'Enter time here'.tr;
                          }else{
                            return null;
                          }
                        },
                      )
                  ),
                  6.spaceX,
                  Expanded(
                    child: CommonTextField(
                      keyboardType: TextInputType.name,
                      hintText: 'Location'.tr,
                      controller: location1Controller,
                      validator: (value){
                        if(value!.trim().isEmpty){
                          return 'Enter location here'.tr;
                        }else{
                          return null;
                        }
                      },
                    )
                  ),
                ],
              ),

              20.spaceY,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                   Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    child: Text(
                      'Spots'.tr,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w300,
                        color: Colors.black, // Text color
                      ),
                    ),
                  ),
                  15.spaceX,
                  SizedBox(
                    width: 120,
                    child: CommonTextField(
                      keyboardType: TextInputType.number,
                      hintText: 'Time'.tr,
                      controller: spotController,
                      validator: (value){
                        if(value!.trim().isEmpty){
                          return 'Enter time here'.tr;
                        }else{
                          return null;
                        }
                      },
                    ),
                  ),
                ],
              ),
              20.spaceY,
               Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: Text(
                  'Extra Notes'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black, // Text color
                  ),
                ),
              ),
              CommonTextField(
                keyboardType: TextInputType.text,
                hintText: 'Notes'.tr,
                controller: notesController,
                validator: (value){
                  if(value!.trim().isEmpty){
                    return 'Enter Notes here'.tr;
                  }else{
                    return null;
                  }
                },
              ),
              40.spaceY,
              InkWell(
                onTap: (){
                  // updateProfile();
                  if(formKey1.currentState!.validate()){
                    optionalApi();
                  }
                },
                child: Container(
                  width: Get.width,
                  height: 50,
                  decoration: BoxDecoration(
                      color: const Color(0xffF5F2F2),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                          color: AppTheme.buttonColor
                      )
                  ),
                  padding: const EdgeInsets.all(10),
                  child:  Center(
                    child: Text(
                      'Save'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff514949), // Text color
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: (){
                  if (widget.id != null) {
                    Get.to(() => const ReviewandPublishTourScreenScreen());
                  } else {
                    Get.to(()=> OptionalDetailsTourAndTravel());
                  }
                },
                child: Container(
                  width: Get.width,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppTheme.buttonColor,
                    borderRadius: BorderRadius.circular(2), // Border radius
                  ),
                  padding: const EdgeInsets.all(10), // Padding inside the container
                  child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Skip'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Text color
                        ),
                      ),
                      Text(
                        'Product will show call for availability'.tr,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Colors.white, // Text color
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}