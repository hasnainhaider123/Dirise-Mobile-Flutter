import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dirise/language/app_strings.dart';
import 'package:dirise/newAuthScreens/tellUsAboutYourself.dart';
import 'package:dirise/utils/helper.dart';
import 'package:dirise/widgets/common_colour.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_textfield.dart';
import '../bottomavbar.dart';
import '../controller/profile_controller.dart';
import '../model/common_modal.dart';
import '../model/login_model.dart';
import '../repository/repository.dart';
import '../screens/auth_screens/otp_screen.dart';
import '../utils/api_constant.dart';
import 'newOtpScreen.dart';

class CreateAccountNewScreen extends StatefulWidget {
  static String route = "/CreateAccountScreen";

  const CreateAccountNewScreen({Key? key}) : super(key: key);

  @override
  State<CreateAccountNewScreen> createState() => _CreateAccountNewScreenState();
}

class _CreateAccountNewScreenState extends State<CreateAccountNewScreen> {
  final formKey1 = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _referralEmailController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  RxBool hide = true.obs;
  RxBool hide1 = true.obs;
  bool showValidation = false;
  bool? _isValue = false;
  final Repositories repositories = Repositories();
  final profileController = Get.put(ProfileController());
  String? code ='+965';
  registerApi() {
    if (_isValue == false) return;
    Map<String, dynamic> map = {};
    map['first_name'] = firstNameController.text.trim();
    map['last_name'] = lastNameController.text.trim();
    map['email'] = _emailController.text.trim();
    map['password'] = _passwordController.text.trim();
    map['confirm_password'] = _confirmPasswordController.text.trim();
    map['phone'] = phoneNumberController.text.trim();
    map['phone_country_code'] = code ;
    FocusManager.instance.primaryFocus!.unfocus();
    repositories.postApi(url: ApiUrls.newRegisterUrl, context: context, mapData: map).then((value) {
      ModelCommonResponse response = ModelCommonResponse.fromJson(jsonDecode(value));
      profileController.selectedLAnguage.value == "English"
      ? showToast(response.message.toString())
      : showToast("يرجى التحقق من كلمة المرور");
      print("Toast----: ${response.message.toString()}");
      log('map data of SU is ${map.toString()}');
      if (response.status == true) {
        print(response.otp.toString());
        Get.toNamed(NewOtpScreen.route, arguments: [_emailController.text, true, map]);
      }
    });
  }

  _makingPrivacyPolicy() async {
    var url = Uri.parse('https://diriseapp.com/en/privacy-policy/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  _termsCondition() async {
    var url = Uri.parse('https://diriseapp.com/en/terms-and-conditions/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
  signInWithGoogle() async {
    var fcmToken = await FirebaseMessaging.instance.getToken();
    await GoogleSignIn().signOut();
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
      Map<String, dynamic> map = {};
      map['provider'] = "google";
      map['access_token'] = value.credential!.accessToken!;
      map['keyword'] = 'signup';
      repositories.postApi(url: ApiUrls.socialLoginUrl, context: context, mapData: map).then((value) async {
        LoginModal response = LoginModal.fromJson(jsonDecode(value));
        repositories.saveLoginDetails(jsonEncode(response));
        if (response.status == true) {
          showToast(response.message.toString());
          profileController.userLoggedIn = true;
          repositories.saveLoginDetails(jsonEncode(response));
          if(response.user!.alreadyRegistered == true){
              Get.offAllNamed(BottomNavbar.route);
          }else{
            Get.to(const TellUsAboutYourSelf());
          }
        } else {
          showToast(response.message.toString());
        }
      });
    });
  }
  loginWithApple() async {
    // var fcmToken = await FirebaseMessaging.instance.getToken();
    final appleProvider = AppleAuthProvider().addScope("email").addScope("FullName");
    await FirebaseAuth.instance.signInWithProvider(appleProvider).then((value1) async {
      Map<String, dynamic> map = {};
      map['provider'] = "apple";
      map['access_token'] = value1.credential!.accessToken!;
      log(value1.credential!.accessToken.toString());
      repositories.postApi(url: ApiUrls.socialLoginUrl, context: context, mapData: map,showResponse: true).then((value)  async {
        LoginModal response = LoginModal.fromJson(jsonDecode(value));
        repositories.saveLoginDetails(jsonEncode(response));
        if (response.status == true) {
          showToast(response.message.toString());
          profileController.userLoggedIn = true;
          repositories.saveLoginDetails(jsonEncode(response));
          if(response.user!.alreadyRegistered == true){
            Get.offAllNamed(BottomNavbar.route);
          }else{
            Get.to(const TellUsAboutYourSelf());
          }
        } else {
          showToast(response.message.toString());
        }
      });
    });
  }
  @override
  void dispose() {
    super.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading:GestureDetector(
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
              AppStrings.signUp.tr,
              style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 20),
            ),
          ],
        ),
      ),
      body: Form(
        key: formKey1,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Column(
              children: [
                10.spaceY,
                Image.asset('assets/images/new_logo.png',
                  height: 180,),
                20.spaceY,
                CommonTextField(
                  controller: firstNameController,
                  obSecure: false,
                  hintText: AppStrings.firstName.tr,
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Please enter your first name'.tr;
                    }
                    if (value.trim().length < 3) {
                      return 'Please enter at least 3 letter\'s'.tr;
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: size.height * .01,
                ),
                CommonTextField(
                  controller: lastNameController,
                  obSecure: false,
                  // hintText: 'Name',
                  hintText: AppStrings.lastName.tr,
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Last Name is required'.tr;
                    }
                    if (value.trim().length < 3) {
                      return 'Please enter at least 3 letter\'s'.tr;
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: size.height * .01,
                ),
                CommonTextField(
                    controller: _emailController,
                    obSecure: false,
                    // hintText: 'Name',
                    hintText: AppStrings.email.tr,
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

                SizedBox(
                  height: size.height * .01,
                ),
                IntlPhoneField(
                  textAlign: profileController.selectedLAnguage.value == 'English' ? TextAlign.left  : TextAlign.right,
                  flagsButtonPadding: const EdgeInsets.all(8),
                  dropdownIconPosition: IconPosition.trailing,
                  showDropdownIcon: true,
                  cursorColor: Colors.black,
                  textInputAction: TextInputAction.next,
                  dropdownTextStyle: const TextStyle(color: Colors.black),
                  style: const TextStyle(
                      color: AppTheme.textColor
                  ),
                  controller: phoneNumberController,
                  decoration:  InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      hintStyle: const TextStyle(color: AppTheme.textColor),
                      hintText: 'Phone Number'.tr,
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
                    log('search 1111 ${phone.code}');
                    profileController.code = phone.code;
                   // code = phone.dialCode.toString();
                    code=phone.code;
                    print('phone codeis ${code}');
                    print(profileController.code.toString());
                  },
                  validator: (value) {
                    if (value == null || phoneNumberController.text.isEmpty) {
                      return AppStrings.pleaseenterphonenumber.tr;
                    }
                    return null;
                  },
                  onChanged: (phone) {
                    log('search ${phone.countryISOCode}');
                    profileController.code = phone.countryISOCode.toString();
                    print(phone.countryCode);
                    print(profileController.code.toString());
                  },
                ),
                SizedBox(
                  height: size.height * .01,
                ),
                Obx(() {
                  return CommonTextField(
                    controller: _passwordController,
                    hintText: AppStrings.password.tr,
                    obSecure: hide.value,
                    suffixIcon: IconButton(
                      onPressed: () {
                        hide.value = !hide.value;
                      },
                      icon: hide.value ? const Icon(Icons.visibility_off) : const Icon(Icons.visibility),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Password is required'.tr;
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters long'.tr;
                      }
                      if (!RegExp(r"(?=.*\W)(?=.*?[#?!@()$%^&*-_])(?=.*[0-9])").hasMatch(value)) {
                        return 'Password must contain at least 1 special character and 1 numerical'.tr;
                      }
                      return null;
                    },

                  );
                }),
                SizedBox(
                  height: size.height * .01,
                ),
                Obx(() {
                  return CommonTextField(
                    obSecure: hide1.value,
                    controller: _confirmPasswordController,
                    suffixIcon: IconButton(
                      onPressed: () {
                        hide1.value = !hide1.value;
                      },
                      icon: hide1.value ? const Icon(Icons.visibility_off) : const Icon(Icons.visibility),
                    ),
                    hintText: AppStrings.confirmPassword.tr,
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return AppStrings.enterConfirmPassword.tr;
                      }
                      if (value.trim() != _passwordController.text.trim()) {
                        return AppStrings.enterReType.tr;
                      }
                      return null;
                    },
                  );
                }),
                SizedBox(
                  height: size.height * .01,
                ),
                CommonTextField(
                    controller: _referralEmailController,
                    obSecure: false,
                    // hintText: 'Name',
                    hintText: 'Referral Point (Optional)'.tr,


                ),
                SizedBox(
                  height: size.height * .01,
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
                            color: showValidation == false ? AppTheme.buttonColor : Colors.red,
                          ),
                          onChanged: (bool? value) {
                            setState(() {
                              _isValue = value;
                            });
                          }),
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: ' By clicking Register, you agree to the'.tr + ' DIRISE '.tr,
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500, fontSize: 13, color: const Color(0xff808384)),
                            ),
                            TextSpan(
                              text: ' Terms of Service and'.tr,
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500, fontSize: 13, color: const Color(0xff808384)),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  _termsCondition(); // Call your method here
                                },
                            ),
                            TextSpan(
                              text: ' Privacy Policy'.tr,
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500, fontSize: 13, color: const Color(0xff808384)),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  _makingPrivacyPolicy(); // Call your method here
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: size.height * .03,
                ),
                CustomOutlineButton(
                  title: AppStrings.register.tr,
                  onPressed: () {
                    showValidation = true;
                    if (formKey1.currentState!.validate()) {
                      if (_isValue == null || !_isValue!) {
                        showToast('Please accept Terms and Condition');
                      } else {
                        registerApi();
                      }
                    }
                    setState(() {});
                  },
                ),
                SizedBox(
                  height: size.height * .02,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: AppStrings.alreadyAccount.tr,
                        style: GoogleFonts.poppins(color: Colors.black),
                      ),
                      TextSpan(
                        text: AppStrings.login.tr,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.buttonColor,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.back();
                          },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * .02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                   if(Platform.isIOS)
                    GestureDetector(
                      onTap: (){
                        loginWithApple();
                      },
                      child: Container(
                        height: 62,
                        width: 62,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.apple,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: size.width * .02,
                    ),
                    InkWell(
                      onTap: () {
                        signInWithGoogle();
                      },
                      child: Container(
                        height: 62,
                        width: 62,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xffCACACA), width: 2)),
                        child: Center(
                          child: Image.asset(
                            'assets/icons/google.png',
                            height: 27,
                          ),
                        ),
                      ),
                    ),
                  ],
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
