import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dirise/iAmHereToSell/pickUpAddressForsellHere.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_pin_code_fields/flutter_pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bottomavbar.dart';
import '../controller/profile_controller.dart';
import '../controller/vendor_controllers/vendor_profile_controller.dart';
import '../language/app_strings.dart';
import '../model/login_model.dart';
import '../model/vendor_models/model_plan_list.dart';
import '../model/vendor_models/model_vendor_details.dart';
import '../model/vendor_models/vendor_category_model.dart';
import '../repository/repository.dart';
import '../screens/auth_screens/newpasswordscreen.dart';
import '../utils/api_constant.dart';
import '../vendor/authentication/vendor_registration_screen.dart';
import '../widgets/common_colour.dart';
import '../widgets/common_textfield.dart';

class WhatdoyousellScreen extends StatefulWidget {
  final PlanInfoData? selectedPlan;
  final ModelPlansList? modelPlansList;

  const WhatdoyousellScreen({super.key, this.selectedPlan, this.modelPlansList});

  @override
  State<WhatdoyousellScreen> createState() => _WhatdoyousellScreenState();
}

class _WhatdoyousellScreenState extends State<WhatdoyousellScreen> {
  ModelVendorCategory modelVendorCategory = ModelVendorCategory(usphone: []);
  Rx<RxStatus> vendorCategoryStatus = RxStatus.empty().obs;
  final GlobalKey categoryKey = GlobalKey();
  Map<String, VendorCategoriesData> allSelectedCategory = {};
  TextEditingController _otpController = TextEditingController();
  TextEditingController storeName = TextEditingController();
  TextEditingController storeEmail = TextEditingController();
  TextEditingController storeNumber = TextEditingController();
  bool showValidation = false;
  bool? _isValue = false;
  bool showResend = false;
  final Repositories repositories = Repositories();

  VendorUser get vendorInfo => vendorProfileController.model.user!;
  final vendorProfileController = Get.put(VendorProfileController());

  void getVendorCategories() {
    vendorCategoryStatus.value = RxStatus.loading();
    repositories.getApi(url: ApiUrls.vendorCategoryListUrl, showResponse: false).then((value) {
      modelVendorCategory = ModelVendorCategory.fromJson(jsonDecode(value));
      vendorCategoryStatus.value = RxStatus.success();

      for (var element in vendorInfo.vendorCategory!) {
        allSelectedCategory[element.id.toString()] = VendorCategoriesData.fromJson(element.toJson());
      }
      setState(() {});
    }).catchError((e) {
      vendorCategoryStatus.value = RxStatus.error();
      // throw Exception(e);
    });
  }

  void onNextButtonPressed() async {
    if (!validateFields()) return; // Validate all required fields

    // Make API call to register vendor
    vendorregister();
  }

  bool validateFields() {
    if (storeName.text.trim().isEmpty ||
        storeEmail.text.trim().isEmpty ||
        storeNumber.text.trim().isEmpty ||
        allSelectedCategory.isEmpty ||
        _otpController.text.trim().length < 4 ||
        _isValue != true) {
      showToast('Please fill in all required fields and accept terms.');
      return false;
    }
    return true;
  }

  final formKey1 = GlobalKey<FormState>();
  String? vendorRegister;

  PlansType selectedPlan = PlansType.personal;
  static String userInfo = "login_user";
  bool isOtpDone = false;
  Rx<LoginModal> response = LoginModal().obs;
  final profileController = Get.put(ProfileController());
  void vendorregister() {
     DateTime today = DateTime.now(); // Get today's date
    DateTime planStartDate = today; // Assign today as plan start date
    DateTime planExpireDate = DateTime(today.year + 1, today.month, today.day); // Assign next year today as plan expire date


    Map<String, String> map = {};
    map["store_name"] = storeName.text.trim();
    map["store_email"] = storeEmail.text.trim();
    map["store_number"] = storeNumber.text.trim();
    map["store_number"] = storeNumber.text.trim();
    map["vendor_type"] = profileController.vendorType.toString();
    map["category_id"] = allSelectedCategory.entries.map((e) => e.key).toList().join(",");
     map["plan_start_date"] = formatDate(planStartDate);
    map["plan_expire_date"] = formatDate(planExpireDate);
    repositories.postApi(url: ApiUrls.vendorRegistrationUrl, context: context, mapData: map).then((value) async {
      response.value = LoginModal.fromJson(jsonDecode(value));
      LoginModal model = LoginModal();
      SharedPreferences preferences = await SharedPreferences.getInstance();
      if (preferences.getString(userInfo) != null) {
        model = LoginModal.fromJson(jsonDecode(preferences.getString(userInfo)!));
      }
      if (response.value.status == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', storeEmail.text.trim());
        log('message ${allSelectedCategory.entries.map((e) => e.key).toList().join(",")}');
        vendorRegister = 'done';
        showToast('Otp has been successfully sent to your email.'.tr);
        setState(() {
          isOtpDone = true;
          showResend = true;
        });
      }
    });
  }
   String formatDate(DateTime date) {
    // Format the date to "MMM d yyyy" (e.g., Nov 5 2023)
      return DateFormat('yyyy-MM-dd').format(date);
  }


  String emailAddress = ""; // Declare email variable

  void getEmailFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    emailAddress = prefs.getString('email') ?? "";
    log("ddddddd" + emailAddress);
  }

  late bool check;
  String? otpVerify;
  Map<String, dynamic> tempMap = {};

  verifyOtp() async {
    String? token = await FirebaseMessaging.instance.getToken();
    String? token1 = await FirebaseMessaging.instance.getToken();
    if (_otpController.text.trim().isEmpty) {
      showToast("Please enter otp".tr);
      return;
    }
    if (_otpController.text.trim().length < 4) {
      showToast("Enter complete otp".tr);
      return;
    }
    FocusManager.instance.primaryFocus!.unfocus();
    Map<String, dynamic> map = {};
    map['email'] = storeEmail.text.trim();
    map['otp'] = _otpController.text.trim();
    map['fcm_token'] = Platform.isAndroid ? token.toString() : token1.toString();
    map['key'] = 'forget';
    repositories.postApi(url: ApiUrls.verifyOtpEmail, context: context, mapData: map).then((value) async {
      LoginModal response = LoginModal.fromJson(jsonDecode(value));
      profileController.selectedLAnguage.value == "English"
          ?showToast(response.message)
          :showToast("تم تسجيل الدخول إلى حسابك بنجاح");
      print("Toast---: ${response.message}");
      showToast(response.message);
      print("Toast----: ${response.message.toString()}");
      if (response.status == true) {
        otpVerify = "done";
        Get.to(SellingPickupAddress());
        // if (check == true) {
        //   repositories.saveLoginDetails(jsonEncode(response));
        //   Get.offAllNamed(BottomNavbar.route);
        // } else {
        //   Get.offNamed(NewPasswordScreen.route, arguments: [emailAddress]);
        // }
      }
    });
  }

  late Timer _resendTimer;
  int _secondsRemaining = 30;
  bool _resendEnabled = true;

  void _startTimer() {
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _resendEnabled = true; // Enable the resend button after 30 seconds
          _resendTimer.cancel();
        }
      });
    });
  }

  void _resendOTP() {
    if (_resendEnabled) {
      // Call vendorregister() only if the resend button is enabled
      vendorregister();
      setState(() {
        _resendEnabled = false; // Disable the resend button
        _secondsRemaining = 30; // Reset the timer
      });
      _startTimer(); // Restart the timer
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getVendorCategories();
    getEmailFromSharedPreferences();
    _startTimer();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _resendTimer.cancel();
  }

  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: GoogleFonts.poppins(
      fontSize: 22,
      color: const Color.fromRGBO(30, 60, 87, 1),
    ),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.withOpacity(0.5)), // Border for each box
      borderRadius: BorderRadius.circular(8), // Border radius for each box
    ),
  );
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
              'What do you sell?'.tr,
              style: GoogleFonts.poppins(color: const Color(0xff292F45), fontWeight: FontWeight.w600, fontSize: 20),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey1,
          child: Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This is where your product will be shown. Category can’t be changed later.'.tr,
                  style: GoogleFonts.poppins(color: const Color(0xff111727), fontSize: 13, fontWeight: FontWeight.w400),
                ),
                const SizedBox(
                  height: 20,
                ),
                Obx(() {
                  if (kDebugMode) {
                    print(modelVendorCategory.usphone!
                        .map((e) => DropdownMenuItem(value: e, child: Text( profileController.selectedLAnguage.value == 'English' ?
                    e.name.toString().capitalize! :  e.arabName.toString().capitalize!)))
                        .toList());
                  }
                  return DropdownButtonFormField<VendorCategoriesData>(
                    key: categoryKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    icon: vendorCategoryStatus.value.isLoading
                        ? const CupertinoActivityIndicator()
                        : Image.asset(
                      'assets/images/drop_icon.png',
                      height: 17,
                      width: 17,
                    ),
                    iconSize: 30,
                    iconDisabledColor: const Color(0xff97949A),
                    iconEnabledColor: const Color(0xff97949A),
                    value: allSelectedCategory.isEmpty ? null : allSelectedCategory.values.first,
                    style: GoogleFonts.poppins(color: Colors.black, fontSize: 16),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      filled: true,
                      fillColor: const Color(0xffE2E2E2).withOpacity(.35),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10).copyWith(right: 8),
                      focusedErrorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: AppTheme.secondaryColor)),
                      errorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Color(0xffE2E2E2))),
                      focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: AppTheme.secondaryColor)),
                      disabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: AppTheme.secondaryColor),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: AppTheme.secondaryColor),
                      ),
                    ),
                    items: modelVendorCategory.usphone!
                        .map((e) => DropdownMenuItem(value: e, child: Text(profileController.selectedLAnguage.value == 'English' ?
                    e.name.toString().capitalize! :  e.arabName.toString().capitalize!)))
                        .toList(),
                    hint: Text('Category'.tr),
                    onChanged: (value) {
                      // Remove the previously selected item
                      allSelectedCategory.clear();
                      if (value != null) {
                        allSelectedCategory[value.id.toString()] = value;
                        setState(() {});
                      }
                    },
                    validator: (value) {
                      if (allSelectedCategory.isEmpty) {
                        return "Please select Category".tr;
                      }
                      return null;
                    },
                  );
                }),
                const SizedBox(
                  height: 10,
                ),
                CommonTextField(
                  hintText: 'Store Name*'.tr,
                  controller: storeName,
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Please enter valid store Name'.tr;
                    }
                    return null; // Return null if validation passes
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                CommonTextField(
                  hintText: 'Store Email*'.tr,
                  controller: storeEmail,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter email address'.tr;
                    }
                    final emailValidator = EmailValidator(errorText: 'Please enter valid email address'.tr);
                    if (!emailValidator.isValid(value)) {
                      return emailValidator.errorText;
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                IntlPhoneField(
                  textAlign: profileController.selectedLAnguage.value == 'English' ? TextAlign.left  : TextAlign.right,
                  // key: ValueKey(profileController.code),
                  flagsButtonPadding: const EdgeInsets.all(8),
                  dropdownIconPosition: IconPosition.trailing,
                  showDropdownIcon: true,
                  cursorColor: Colors.black,
                  textInputAction: TextInputAction.next,
                  dropdownTextStyle: const TextStyle(color: Colors.black),
                  style: const TextStyle(color: AppTheme.textColor),
                  controller: storeNumber,
                  decoration:  InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      hintStyle: const TextStyle(color: AppTheme.textColor),
                      hintText: 'Store Number*'.tr,
                      labelStyle: const TextStyle(color: AppTheme.textColor),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                      enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppTheme.shadowColor)),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppTheme.shadowColor))),
                  initialCountryCode: profileController.code1.toString(),
                  languageCode:  profileController.code,
                  invalidNumberMessage: profileController.selectedLAnguage.value == 'English'
                      ? 'Invalid phone number'
                      : 'رقم الهاتف غير صالح',
                  onCountryChanged: (phone) {
                    profileController.code = phone.code;
                    print("1.fdfgds---: ${phone.code}");
                    print("2.fdfgds---: ${profileController.code.toString()}");
                  },
                  validator: (value) {
                    if (value == null || storeNumber.text.isEmpty) {
                      return AppStrings.pleaseenterphonenumber.tr;
                    }
                    return null;
                  },
                  onChanged: (phone) {
                    profileController.code = phone.countryISOCode.toString();
                    print("3.fdfgds---: ${phone.countryCode}");
                    print("4.fdfgds---: ${profileController.code.toString()}");
                  },
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
                      child: Text(
                        'By clicking next, you agree to the DIRISE Terms of Service and Privacy Policy'.tr,
                        style: GoogleFonts.poppins(
                            color: const Color(0xff292F45), fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Obx(() {
                  return GestureDetector(
                    onTap: () {
                      if (formKey1.currentState!.validate()) {
                        if (_isValue == true) {
                          response.value.message == 'You are successfully registered as a seller Please check your mail for verify your account.'
                              ? const SizedBox()
                              : vendorregister();
                        } else {
                          showToast('Please accept terms of service'.tr);
                        }
                      }
                    },
                    child: response.value.message == 'You are successfully registered as a seller Please check your mail for verify your account.'
                        ? Container(
                            width: Get.width,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xff0D5877), // Border color
                                width: 1.0, // Border width
                              ),
                              borderRadius: BorderRadius.circular(2), // Border radius
                            ),
                            padding: const EdgeInsets.all(10),
                            // Padding inside the container
                            child:  Center(
                              child: Text(
                                'Send Otp'.tr,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black, // Text color
                                ),
                              ),
                            ),
                          )
                        : Container(
                            width: Get.width,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xff0D5877), // Border color

                              borderRadius: BorderRadius.circular(2), // Border radius
                            ),
                            padding: const EdgeInsets.all(10),
                            // Padding inside the container
                            child:  Center(
                              child: Text(
                                'Send Otp'.tr,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, // Text color
                                ),
                              ),
                            ),
                          ),
                  );
                }),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Verification'.tr,
                  style: GoogleFonts.poppins(color: const Color(0xff292F45), fontWeight: FontWeight.w600, fontSize: 20),
                ),
                Text(
                  'Enter verification code'.tr,
                  style: GoogleFonts.poppins(color: const Color(0xff1D2C3D), fontWeight: FontWeight.w400, fontSize: 14),
                ),
                PinCodeFields(
                  length: 4,
                  controller: _otpController,
                  fieldBorderStyle: FieldBorderStyle.square,
                  responsive: true,
                  fieldHeight: 50.0,
                  fieldWidth: 60.0,
                  borderWidth: 1.0,
                  activeBorderColor: Colors.black,
                  activeBackgroundColor: Colors.black.withOpacity(.10),
                  borderRadius: BorderRadius.circular(5.0),
                  keyboardType: TextInputType.number,
                  autoHideKeyboard: true,
                  fieldBackgroundColor: Colors.white.withOpacity(.10),
                  borderColor: Colors.black,
                  textStyle: GoogleFonts.poppins(
                    fontSize: 25.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  onComplete: (output) {},
                ),
                // GestureDetector(
                //   onTap: () {
                //     if (_isValue == true) {
                //       verifyOtp();
                //     } else {
                //       showToast('please accept Terms and Condition'.tr);
                //     }
                //   },
                //   child: Align(
                //     alignment: Alignment.centerRight,
                //     child: Container(
                //       padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                //       decoration: BoxDecoration(
                //           color: const Color(
                //             0xff1D2C3D,
                //           ),
                //           borderRadius: BorderRadius.circular(5)),
                //       child: Text(
                //         'Click here to verify the Otp'.tr,
                //         style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 14),
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(
                  height: 10,
                ),
                showResend == true
                    ? RichText(
                        text: TextSpan(
                          text: 'If you don\'t receive a code, '.tr,
                          style: const TextStyle(fontFamily: 'Your App Font Family', color: Colors.black),
                          children: [
                            if (_secondsRemaining > 0)
                              TextSpan(
                                text: 'Wait $_secondsRemaining seconds to resend',
                                style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xff014E70)),
                              )
                            else
                              TextSpan(
                                text: 'Resend OTP'.tr,
                                recognizer: TapGestureRecognizer()..onTap = _resendOTP,
                                style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xff014E70)),
                              ),
                          ],
                        ),
                      )
                    : const SizedBox(),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    // if (vendorRegister == 'done' && otpVerify == 'done') {
                    //   if (_isValue == true) {
                    //     verifyOtp();
                    //   } else {
                    //     showToast('please accept Terms and Condition'.tr);
                    //   }
                    // }
                    if (_isValue == true) {
                      verifyOtp();
                    } else {
                      showToast('Please accept terms and condition'.tr);
                    }
                  },
                  child: vendorRegister == 'done' && otpVerify == 'done'
                      ? Container(
                          width: Get.width,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xff0D5877), // Border color
                            borderRadius: BorderRadius.circular(2), // Border radius
                          ),
                          padding: const EdgeInsets.all(10),
                          // Padding inside the container
                          child:  Center(
                            child: Text(
                              'Click here to verify the Otp'.tr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Text color
                              ),
                            ),
                          ),
                        )
                      : Container(
                          width: Get.width,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xff0D5877), // Border color
                              width: 2.0, // Border width
                            ),
                            borderRadius: BorderRadius.circular(2), // Border radius
                          ),
                          padding: const EdgeInsets.all(10),
                          // Padding inside the container
                          child:  Center(
                            child: Text(
                              'Click here to verify the Otp'.tr,
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
      ),
    );
  }
}
