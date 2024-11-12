import 'dart:convert';

import 'package:dirise/iAmHereToSell/listofquestionScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../controller/profile_controller.dart';
import '../language/app_strings.dart';
import '../model/model_varification.dart';
import '../repository/repository.dart';
import '../utils/api_constant.dart';
import '../widgets/common_colour.dart';
import '../widgets/common_textfield.dart';

class VerificationSelectDateScreen extends StatefulWidget {
  const VerificationSelectDateScreen({super.key});

  @override
  State<VerificationSelectDateScreen> createState() => _VerificationSelectDateScreenState();
}

class _VerificationSelectDateScreenState extends State<VerificationSelectDateScreen> {
  DateTime selectedDate = DateTime.now();
TextEditingController date = TextEditingController();
TextEditingController emailController = TextEditingController();
TextEditingController phoneController = TextEditingController();
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        date.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }
  String selectedRadio = '';
  String code = '';
  void _validateAndProceed() {
    if(date.text.isEmpty){showToast("Please select date by clicking on icon");}
  else  if (selectedRadio == "email" && emailController.text.isEmpty) {
      showToast("Please enter email");
    } else if (selectedRadio == "phone" && phoneController.text.isEmpty) {
      showToast("Please enter phone number");
    } else {
      verificationApi();
    }
  }
  final Repositories repositories = Repositories();
  Future verificationApi() async {
    Map<String, dynamic> map = {};

    map['verification_type'] = 'meeting';
 map['verification_date'] = date.text.toString();
    map['verification_mode_type'] = selectedRadio;
    map['verification_mode'] = selectedRadio == "email"?emailController.text.toString():"+"+code+phoneController.text.toString();
    // map['name'] = _nameController.text.trim();
    // map['phone'] = _mobileNumberController.text.trim();
    // map['password'] = _passwordController.text.trim();
    FocusManager.instance.primaryFocus!.unfocus();
    await repositories.postApi(url: ApiUrls.vendorVerification, context: context, mapData: map).then((value) {
      VarificationModel response = VarificationModel.fromJson(jsonDecode(value));
      // showToast(response.message.toString());

      if (response.status == true) {
        showToast(response.message.toString());
        Get.to(const ListOfQuestionsScreen());
      }
      else{
        showToast(response.message.toString());
      }
    });
  }

  final profileController = Get.put(ProfileController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
              'Verification'.tr,
              style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 20),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select the date, meeting will be conducted over zoom'.tr,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 16, color: Colors.black),
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () => _selectDate(context),
                  child: Image.asset('assets/images/date.png',height: 250,width: Get.width,)),

              const SizedBox(
                height: 20,
              ),
              date.text !=""?
              CommonTextField(hintText: "date".tr,controller: date,):const SizedBox(

              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Where should we send you the meeting link?'.tr,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 20, color: Colors.black),
              ),
              const SizedBox(
                height: 20,
              ),

              Row(
                children: [
                   Radio(
                    value: "email",
                    groupValue: selectedRadio,
                    onChanged: (value) {
                      setState(() {
                        selectedRadio = value.toString();
                      });
                    },
                  ),
                  Expanded(
                    child: CommonTextField(
                      controller: emailController,
                        obSecure: false,
                        // hintText: 'Name',
                        hintText: AppStrings.email.tr,
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'Email is required'.tr),
                          EmailValidator(errorText: 'Please enter valid email address'.tr),
                        ])),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Radio(
                    value: "phone",
                    groupValue: selectedRadio,
                    onChanged: (value) {
                      setState(() {
                        selectedRadio = value.toString();
                      });
                    },
                  ),
                  Expanded(
                    child: IntlPhoneField(
                      textAlign: profileController.selectedLAnguage.value == 'English' ? TextAlign.left  : TextAlign.right,
                      flagsButtonPadding: const EdgeInsets.all(8),
                      dropdownIconPosition: IconPosition.trailing,
                      showDropdownIcon: true,
                      cursorColor: Colors.black,
                      textInputAction: TextInputAction.next,
                      dropdownTextStyle: const TextStyle(color: Colors.black),
                      style: const TextStyle(color: AppTheme.textColor),

                     controller: phoneController,
                      decoration:  InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          hintStyle: const TextStyle(color: AppTheme.textColor),
                          hintText: 'Enter your phone number'.tr,
                          labelStyle: const TextStyle(color: AppTheme.textColor),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppTheme.shadowColor)),
                          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppTheme.shadowColor))),
                      initialCountryCode: profileController.code1.toString(),
                      languageCode:  profileController.code,
                      onCountryChanged: (phone) {
                        // profileController.code = phone.code;
                        // print(phone.code);
                        // print(profileController.code.toString());
                      },
                      onChanged: (phone) {
                        // profileController.code = phone.countryISOCode.toString();
                        // print(phone.countryCode);
                        // print(profileController.code.toString());
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                onTap:_validateAndProceed,
                child: Container(
                  margin: const EdgeInsets.only(left: 15, right: 15),
                  width: Get.width,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xff0D5877), // Border color
                      width: 2.0, // Border width
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
            ],
          ),
        ),
      ),
    );
  }
}
