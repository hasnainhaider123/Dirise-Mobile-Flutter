import 'dart:convert';
import 'dart:math';
import 'package:dirise/controller/profile_controller.dart';
import 'package:dirise/screens/Consultation%20Sessions/set_store_time.dart';
import 'package:dirise/screens/tour_travel/review_publish_screen.dart';
import 'package:dirise/screens/tour_travel/timing_screen.dart';
import 'package:dirise/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../controller/vendor_controllers/add_product_controller.dart';
import '../../model/jobResponceModel.dart';
import '../../repository/repository.dart';
import '../../utils/api_constant.dart';
import '../../widgets/common_colour.dart';
import '../../widgets/common_textfield.dart';
import 'dateRangemodel.dart';

class DateRangeScreenTour extends StatefulWidget {
  int? id;
  String? from_date;
  String? to_date;
  String? fromLocation;
  String? toLocation;
  String? formExtraNotes;
  String? toExtraNotes;

  DateRangeScreenTour(
      {super.key,
      this.from_date,
      this.to_date,
      this.fromLocation,
      this.toLocation,
      this.id,
      this.formExtraNotes,
      this.toExtraNotes});

  @override
  State<DateRangeScreenTour> createState() => _DateRangeScreenTourState();
}

class _DateRangeScreenTourState extends State<DateRangeScreenTour> {
  final profileController = Get.put(ProfileController());

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  String? formattedStartDate;
  String? formattedStartDate1;
  TextEditingController notesController = TextEditingController();
  TextEditingController fromController = TextEditingController();
  TextEditingController extraController = TextEditingController();
  TextEditingController toController = TextEditingController();
  RxBool isServiceProvide = false.obs;
  String selectedItemDay = 'Location';
  String? dateRangeError;
  final formKey = GlobalKey<FormState>();
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        addProductController.formattedStartDate = DateFormat('yyyy/MM/dd').format(_startDate);
        formattedStartDate = DateFormat('yyyy/MM/dd').format(_startDate);
        dateRangeError = null;
        print('Now Select........${formattedStartDate.toString()}');
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
        formattedStartDate1 = DateFormat('yyyy/MM/dd').format(_endDate);
        dateRangeError = null;
        print('Now Select........${formattedStartDate1.toString()}');
      });
    }
  }

  bool isChecked = false;
  final addProductController = Get.put(AddProductController());
  final Repositories repositories = Repositories();
  void updateProfile() {

    if (formattedStartDate == null || formattedStartDate1 == null) {
      setState(() {
        dateRangeError = 'Please select both start and end dates.'.tr;
      });
      return;
    }
    Map<String, dynamic> map = {};

    map["product_type"] = "booking";
    map["id"] = addProductController.idProduct.value.toString();
    map["from_date"] = formattedStartDate.toString();
    map["to_date"] = formattedStartDate1.toString();
    map["from_location"] = fromController.text.trim().toString();
    map["from_extra_notes"] = notesController.text.trim().toString();
    map["to_location"] = toController.text.trim().toString();
    map["to_extra_notes"] = extraController.text.trim().toString();

    repositories.postApi(url: ApiUrls.giveawayProductAddress, context: context, mapData: map).then((value) {
      print('object${value.toString()}');
      DateRangeInTravelModel response = DateRangeInTravelModel.fromJson(jsonDecode(value));
      if (response.status == true) {
        profileController.productAvailabilityId = response.productDetails!.productAvailabilityId!.id!;
        showToast(response.message.toString());
        if (widget.id != null) {
          Get.to(() => const ReviewandPublishTourScreenScreen());
        } else {
          Get.to(() => TimingScreenTour());
        }

        print('value isssss${response.toJson()}');
      } else {
        showToast(response.message.toString());
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.id != null) {
      formattedStartDate = widget.from_date;
      formattedStartDate1 = widget.to_date;
      fromController.text = widget.fromLocation.toString();
      toController.text = widget.toLocation.toString();
      notesController.text = widget.formExtraNotes.toString();
      extraController.text = widget.toExtraNotes.toString();
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
              'Date'.tr,
              style: GoogleFonts.poppins(color: const Color(0xff292F45), fontWeight: FontWeight.w600, fontSize: 20),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dates range'.tr, style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.w600)),
              15.spaceY,
              Text('The start date and end date which this service offered'.tr,
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400)),
              40.spaceY,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${"Start Date:".tr} ${formattedStartDate ?? ''}',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                        ),
                        10.spaceY,
                        ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateColor.resolveWith((states) => const Color(0xff014E70))),
                          onPressed: () => _selectStartDate(context),
                          child:  Text(
                            'Select Start Date'.tr,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${"End Date:".tr} ${formattedStartDate1 ?? ''}',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateColor.resolveWith((states) => const Color(0xff014E70))),
                          onPressed: () => _selectEndDate(context),
                          child:  Text(
                            'Select End Date'.tr,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              if (dateRangeError != null) // Display error message
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    dateRangeError!,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 40),
               Text(
                'Places'.tr,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              30.spaceY,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                   Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        'From'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Text color
                        ),
                      ),
                    ),
                  ),
                  6.spaceX,
                  Expanded(
                    child: CommonTextField(
                      controller: fromController,
                      obSecure: false,
                      hintText: 'location'.tr,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return "location is required".tr;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              20.spaceY,
               Text(
                'Extra Notes'.tr,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              20.spaceY,
              CommonTextField(
                controller: notesController,
                obSecure: false,
                hintText: 'Notes'.tr,
                validator: (value) {
                  if (value!.trim().isEmpty) {
                    return "Notes is required".tr;
                  }
                  return null;
                },
              ),
              30.spaceY,
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'To'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Text color
                      ),
                    ),
                  ),
                  20.spaceX,
                  Expanded(
                    child: CommonTextField(
                      controller: toController,
                      obSecure: false,
                      hintText: 'Location'.tr,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return "Location is required".tr;
                        }
                        return null;
                      },
                    ),
                  ),
                  20.spaceX,
                  Expanded(
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              isChecked = !isChecked;
                              toController.text = fromController.text;
                            });
                          },
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF000000).withOpacity(.25),
                                width: 1.0,
                              ),
                            ),
                            child: isChecked
                                ? const Icon(
                                    Icons.check,
                                    size: 15,
                                    color: AppTheme.buttonColor,
                                  )
                                : null,
                          ),
                        ),
                        20.spaceX,
                         Expanded(
                          child: Text(
                            'Same as above'.tr,
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              30.spaceY,
               Text(
                'Extra Notes'.tr,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              20.spaceY,
              CommonTextField(
                controller: extraController,
                obSecure: false,
                hintText: 'Notes'.tr,
                validator: (value) {
                  if (value!.trim().isEmpty) {
                    return "Notes is required".tr;
                  }
                  return null;
                },
              ),
              30.spaceY,
              // const Align(
              //   alignment: Alignment.center,
              // child: Text(
              //     '+ Add Place',
              //     style: TextStyle(
              //       fontSize: 16,
              //       fontWeight: FontWeight.bold,
              //       color: Colors.black, // Text color
              //     ),
              //   ),
              // ),
              // 20.spaceY,
              InkWell(
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    updateProfile();
                  }
                },
                child: Container(
                  width: Get.width,
                  height: 50,
                  decoration: BoxDecoration(
                      color: const Color(0xffF5F2F2),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: AppTheme.buttonColor)),
                  padding: const EdgeInsets.all(10), // Padding inside the container
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
              20.spaceY,
              InkWell(
                onTap: () {
                  if (widget.id != null) {
                    Get.to(() => const ReviewandPublishTourScreenScreen());
                  } else {
                    Get.to(() => TimingScreenTour());
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
