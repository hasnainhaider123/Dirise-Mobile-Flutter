import 'dart:convert';
import 'dart:developer';

import 'package:dirise/addNewProduct/deliverySizeScreen.dart';
import 'package:dirise/addNewProduct/reviewPublishScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bottomavbar.dart';
import '../controller/profile_controller.dart';
import '../controller/vendor_controllers/add_product_controller.dart';
import '../language/app_strings.dart';
import '../model/common_modal.dart';
import '../repository/repository.dart';
import '../screens/auth_screens/otp_screen.dart';
import '../utils/api_constant.dart';
import '../widgets/common_button.dart';
import '../widgets/common_textfield.dart';
import 'giveawaylocation.dart';
import 'locationScreen.dart';

class AddProductPickUpAddressScreen extends StatefulWidget {
  final String? street;
  final String? city;
  final String? state;
  final String? country;
  final String? zipcode;
  final String? town;
  int? id;

  final String? locationstreet;
  final String? locationcity;
  final String? locationstate;
  final String? locationcountry;
  final String? locationzipcode;
  final String? locationtown;
  final String? countryCode;
  AddProductPickUpAddressScreen(
      {Key? key,
      this.street,
      this.city,
      this.state,
      this.country,
      this.zipcode,
      this.town,
      this.id,
      this.locationcity,
      this.locationcountry,
      this.locationstate,
      this.locationstreet,
      this.locationtown,
       this.countryCode,
      this.locationzipcode})
      : super(key: key);

  @override
  State<AddProductPickUpAddressScreen> createState() => _AddProductPickUpAddressScreenState();
}

class _AddProductPickUpAddressScreenState extends State<AddProductPickUpAddressScreen> {
  final TextEditingController streetController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipcodeController = TextEditingController();
  final TextEditingController townController = TextEditingController();
  // final TextEditingController countryController = TextEditingController();
  final TextEditingController specialInstructionController = TextEditingController();
  final addProductController = Get.put(AddProductController());
  RxBool hide = true.obs;
  RxBool hide1 = true.obs;
  bool showValidation = false;
  final Repositories repositories = Repositories();
  final formKey1 = GlobalKey<FormState>();
  String code = "+91";
  String countryCode = '';
  editAddressApi() {
    Map<String, dynamic> map = {};
    if (widget.street != null &&
        widget.city != null &&
        widget.state != null &&
        widget.zipcode != null &&
        widget.town != null) {
      map['city'] = cityController.text.trim();
      map['item_type'] = 'giveaway';
      map['state'] = stateController.text.trim();
      map['zip_code'] = zipcodeController.text.trim();
      map['town'] = townController.text.trim();
      map['country'] = countryController.text.trim();
      map['country_sort_name'] = countryCode.toString();
      map['id'] = addProductController.idProduct.value.toString();
      map['street'] = streetController.text.trim();
      map['special_instruction'] = specialInstructionController.text.trim();
    } else {
      map['city'] = cityController.text.trim();
      map['item_type'] = 'giveaway';
      map['state'] = stateController.text.trim();
      map['zip_code'] = zipcodeController.text.trim();
      map['town'] = townController.text.trim();
      map['country'] = countryController.text.trim();
      map['street'] = streetController.text.trim();
      map['country_sort_name'] = countryCode.toString();
      map['id'] = addProductController.idProduct.value.toString();
      map['special_instruction'] = specialInstructionController.text.trim();
    }

    FocusManager.instance.primaryFocus!.unfocus();
    repositories.postApi(url: ApiUrls.giveawayProductAddress, context: context, mapData: map).then((value) {
      ModelCommonResponse response = ModelCommonResponse.fromJson(jsonDecode(value));
      print('API Response Status Code: ${response.status}');
      showToast(response.message.toString());
      if (response.status == true) {
        if (widget.id != null) {
          Get.to(ReviewPublishScreen());
        } else {
          Get.to(DeliverySizeScreen());
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.id != null) {
      streetController.text = widget.street!;
      cityController.text = widget.city ?? '';
      stateController.text = widget.state ?? '';
      countryController.text = widget.country ?? '';
      zipcodeController.text = widget.zipcode ?? '';
      townController.text = widget.town ?? '';
      countryCode = widget.countryCode ?? '';
    }

    if (widget.locationzipcode != null) {
      streetController.text = widget.locationstreet!;
      cityController.text = widget.locationcity ?? '';
      stateController.text = widget.locationstate ?? '';
      countryController.text = widget.locationcountry ?? '';
      zipcodeController.text = widget.locationzipcode ?? '';
      townController.text = widget.locationtown ?? '';
      countryCode = widget.countryCode ?? '';
    }
  }

  final profileController = Get.put(ProfileController());
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
              "Vendor address".tr,
              style: GoogleFonts.poppins(color: Color(0xff292F45), fontWeight: FontWeight.w600, fontSize: 20),
            ),
          ],
        ),
      ),
      body: Form(
        key: formKey1,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: size.height * .02,
                ),
                Text(
                  "Where do you want to receive your orders".tr,
                  style: GoogleFonts.poppins(color: Color(0xff292F45), fontWeight: FontWeight.w600, fontSize: 16),
                ),
                SizedBox(
                  height: size.height * .02,
                ),
                InkWell(
                  onTap: () {
                    // Get.toNamed("/chooseAddressScreen");
                    Get.to(ChooseAddressForGiveaway());
                  },
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Select your location on the map".tr,
                      style: GoogleFonts.poppins(color: Color(0xff044484), fontWeight: FontWeight.w400, fontSize: 14),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Street*".tr,
                  style: GoogleFonts.poppins(color: Color(0xff044484), fontWeight: FontWeight.w600, fontSize: 14),
                ),
                SizedBox(
                  height: 5,
                ),
                CommonTextField(
                  controller: streetController,
                  obSecure: false,
                  hintText: 'Street'.tr,
                  // validator: (value) {
                  //   if (value!.trim().isEmpty) {
                  //     return 'Street is required'.tr;
                  //   }
                  //   return null; // Return null if validation passes
                  // },
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Country*".tr,
                  style: GoogleFonts.poppins(color: Color(0xff044484), fontWeight: FontWeight.w600, fontSize: 14),
                ),
                SizedBox(
                  height: 5,
                ),
                CommonTextField(
                  controller: countryController,
                  obSecure: false,
                  hintText: 'Country'.tr,
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Country is required'.tr;
                    }
                    return null; // Return null if validation passes
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "City*".tr,
                  style: GoogleFonts.poppins(color: Color(0xff044484), fontWeight: FontWeight.w600, fontSize: 14),
                ),
                SizedBox(
                  height: 5,
                ),
                CommonTextField(
                  controller: cityController,
                  obSecure: false,
                  hintText: 'city'.tr,
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'city is required'.tr;
                    }
                    return null; // Return null if validation passes
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "State*".tr,
                  style: GoogleFonts.poppins(color: Color(0xff044484), fontWeight: FontWeight.w600, fontSize: 14),
                ),
                SizedBox(
                  height: 5,
                ),
                CommonTextField(
                  controller: stateController,
                  obSecure: false,
                  hintText: 'State'.tr,
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'State is required'.tr;
                    }
                    return null; // Return null if validation passes
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Zip Code*".tr,
                  style: GoogleFonts.poppins(color: Color(0xff044484), fontWeight: FontWeight.w600, fontSize: 14),
                ),
                SizedBox(
                  height: 5,
                ),
                CommonTextField(
                  controller: zipcodeController,
                  obSecure: false,
                  hintText: 'Zip Code'.tr,
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'If you dont have any zipcode then write 99999 and make sure write a right zipcode otherwise we cant help in shipping'.tr
                          .tr;
                    }
                    return null; // Return null if validation passes
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Town*".tr,
                  style: GoogleFonts.poppins(color: Color(0xff044484), fontWeight: FontWeight.w600, fontSize: 14),
                ),
                SizedBox(
                  height: 5,
                ),
                CommonTextField(
                  controller: townController,
                  obSecure: false,
                  hintText: 'Town'.tr,
                  // validator: (value) {
                  //   if (value!.trim().isEmpty) {
                  //     return 'Town is required'.tr;
                  //   }
                  //   return null; // Return null if validation passes
                  // },
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Special instruction".tr,
                  style: GoogleFonts.poppins(color: Color(0xff044484), fontWeight: FontWeight.w600, fontSize: 14),
                ),
                SizedBox(
                  height: 5,
                ),
                CommonTextField(
                  controller: specialInstructionController,
                  obSecure: false,
                  hintText: 'Special instruction'.tr,
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: size.height * .02,
                ),
                CustomOutlineButton(
                  title: 'Confirm Your Location'.tr,
                  borderRadius: 11,
                  onPressed: () {
                    if (formKey1.currentState!.validate()) {
                      editAddressApi();
                    }
                    setState(() {});
                  },
                ),
                SizedBox(
                  height: size.height * .02,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
