import 'dart:convert';
import 'dart:developer';

import 'package:dirise/screens/Consultation%20Sessions/review_screen.dart';
import 'package:dirise/utils/helper.dart';
import 'package:dirise/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/profile_controller.dart';
import '../../controller/vendor_controllers/add_product_controller.dart';
import '../../model/create_slots_model.dart';
import '../../model/vendor_models/add_product_model.dart';
import '../../repository/repository.dart';
import '../../utils/api_constant.dart';
import '../../widgets/common_colour.dart';
import 'optional_details.dart';

class DurationScreen extends StatefulWidget {
  int? id;
  dynamic recoveryBlockTime;
  dynamic preparationBlockTime;
  dynamic interval;
  dynamic serviceSlotType;
  dynamic preparationType;
  dynamic recoveryType;

  DurationScreen(
      {super.key, this.recoveryBlockTime, this.preparationBlockTime, this.interval, this.id, this.recoveryType, this.preparationType, this.serviceSlotType});

  @override
  State<DurationScreen> createState() => _DurationScreenState();
}

class _DurationScreenState extends State<DurationScreen> {
  String serviceSlotTime = 'min';
  String preparationTime = 'min';
  String recoveryTime = 'min';
  TextEditingController timeController = TextEditingController();
  String slotText = '';
  String slotText1 = '';
  TextEditingController timeControllerPreparation = TextEditingController();
  TextEditingController timeControllerRecovery = TextEditingController();
  final Repositories repositories = Repositories();
  Rx<CreateSlotsModel> createSlotsModel = CreateSlotsModel().obs;
  final addProductController = Get.put(AddProductController());
  final formKey = GlobalKey<FormState>();

  createDuration() {
    Map<String, dynamic> map = {};
    map['recovery_block_time'] = timeControllerRecovery.text.trim().toString();
    map['preparation_block_time'] = timeControllerPreparation.text.trim().toString();
    map['id'] = addProductController.idProduct.value.toString();
    map['interval_type'] = serviceSlotTime.toString();
    map['preparation_block_time_type'] = preparationTime.toString();
    map['recovery_block_time_type'] = recoveryTime.toString();
    // map['product_type'] = 'booking';
    final Repositories repositories = Repositories();
    FocusManager.instance.primaryFocus!.unfocus();
    repositories.postApi(url: ApiUrls.giveawayProductAddress, context: context, mapData: map).then((value) {
      AddProductModel response = AddProductModel.fromJson(jsonDecode(value));
      print('API Response Status Code: ${response.status}');
      showToast(response.message.toString());
      if (response.status == true) {
        addProductController.idProduct.value = response.productDetails!.product!.id.toString();
        print(addProductController.idProduct.value.toString());
        if (widget.id != null) {
          Get.to(() => const ReviewScreen());
        } else {
          Get.to(() => OptionalDetailsScreen());
        }
      }
    });
  }

  createSlots() {
    Map<String, dynamic> map = {};

    // map["product_id"] = addProductController.productId.toString();
    map["product_id"] = addProductController.idProduct.value.toString();
    map["todayDate"] = addProductController.formattedStartDate.toString();
    map['recovery_block_time'] = timeControllerRecovery.text.trim().toString();
    map['preparation_block_time'] = timeControllerPreparation.text.trim().toString();
    map["interval"] = timeController.text.trim().toString();
    map['interval_type'] = serviceSlotTime.toString();
    map['preparation_block_time_type'] = preparationTime.toString();
    map['recovery_block_time_type'] = recoveryTime.toString();
    repositories.postApi(url: ApiUrls.productCreateSlots, mapData: map, context: context).then((value) {
      createSlotsModel.value = CreateSlotsModel.fromJson(jsonDecode(value));
      showToast(createSlotsModel.value.message.toString());
      log('dadadadadadadd${createSlotsModel.value.toJson()}');
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.id != null) {
      timeControllerRecovery.text = widget.recoveryBlockTime ?? '';
      timeControllerPreparation.text = widget.preparationBlockTime  ?? '';
      slotText = widget.interval.toString();
      slotText1 = widget.preparationBlockTime.toString();
      timeController.text = widget.interval.toString();
      serviceSlotTime = widget.serviceSlotType.toString();
      preparationTime = widget.preparationType.toString();
      recoveryTime = widget.recoveryType.toString();
    }
  }

  final profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text('Duration'.tr,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: const Color(0xff423E5E),
            )),
        leading: GestureDetector(
          onTap: () {
            Get.back();
            // _scaffoldKey.currentState!.openDrawer();
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: profileController.selectedLAnguage.value != 'English'
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
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                   Expanded(
                    child: Text(
                      'Service Slot Duration'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Text color
                      ),
                    ),
                  ),
                  Expanded(
                      child: CommonTextField(
                        keyboardType: TextInputType.number,
                        hintText: 'Time'.tr,
                        controller: timeController,
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return 'Enter time'.tr;
                          }
                          return null;
                        },
                        onEditingCompleted:() {
                          setState(() {
                            slotText =  timeController.text.toString();
                          });
                        } ,
                      )),
                  6.spaceX,
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: serviceSlotTime,
                      onChanged: (String? newValue) {
                        setState(() {
                          serviceSlotTime = newValue!;
                        });
                      },
                      items: <String>['min', 'hours'].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        filled: true,
                        fillColor: const Color(0xffE2E2E2).withOpacity(.35),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15).copyWith(right: 8),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an item'.tr;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              // 10.spaceY,
              // Align(
              //   alignment: Alignment.topRight,
              //   child: Text('Price 30 KWD'.tr,
              //       style: GoogleFonts.poppins(
              //         fontSize: 14,
              //         fontWeight: FontWeight.w500,
              //         color: const Color(0xffEB4335),
              //       )),
              // ),
              10.spaceY,
              // Text('Allow multiple booking'.tr,
              //     style: GoogleFonts.poppins(
              //       fontSize: 17,
              //       fontWeight: FontWeight.w500,
              //       color: const Color(0xff423E5E),
              //     )),
              // 10.spaceY,
              Text('Preparation Block Time'.tr,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff423E5E),
                  )),
              5.spaceY,
              Container(
                padding: const EdgeInsets.all(9),
                width: Get.width,
                decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFE3E3E3),
                    )),
                child: Text(
                    'This is the time you need to prepare for the service. EXP. '
                        'Preparation time set for two hours Customer at 10 O’clock will be able to book from 12 O’clock the at the earliest. '.tr,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff423E5E),
                    )),
              ),
              20.spaceY,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                   Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        'I need'.tr,
                        textAlign: TextAlign.center,
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
                        controller: timeControllerPreparation,
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return 'Enter time'.tr;
                          }
                          return null;
                        },
                        onEditingCompleted: () {
                          setState(() {
                            slotText1 = timeControllerPreparation.text.toString();
                          });
                        },
                      )),
                  6.spaceX,
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: preparationTime,
                      isDense: true,
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          preparationTime = newValue!;
                        });
                      },
                      items: <String>['min', 'hours'].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        filled: true,
                        fillColor: const Color(0xffE2E2E2).withOpacity(.35),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15).copyWith(right: 8),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an item'.tr;
                        }
                        return null;
                      },
                    ),
                  ),
                  6.spaceX,
                   Expanded(
                    child: Text(
                      'to prepare.'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Text color
                      ),
                    ),
                  ),
                ],
              ),
              20.spaceY,
              Text('Recovery Block Time'.tr,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff423E5E),
                  )),
              5.spaceY,
              Container(
                padding: const EdgeInsets.all(9),
                width: Get.width,
                decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFE3E3E3),
                    )),
                child: Text(
                    'This time you need to rest or organize for the next available.EXP. Recovery time set for 15 minutes. If your service is blocked from 1000 till 1030, customer will be able to book the 1045 for the slot earlier.'
                        .tr,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff423E5E),
                    )),
              ),
              20.spaceY,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                   Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        'I need'.tr,
                        textAlign: TextAlign.center,
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
                        controller: timeControllerRecovery,
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return 'Enter time'.tr;
                          }
                          return null;
                        },
                      )),
                  6.spaceX,
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: recoveryTime,
                      isDense: true,
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          recoveryTime = newValue!;
                        });
                      },
                      items: <String>['min', 'hours'].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        filled: true,
                        fillColor: const Color(0xffE2E2E2).withOpacity(.35),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15).copyWith(right: 8),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an item'.tr;
                        }
                        return null;
                      },
                    ),
                  ),
                  6.spaceX,
                   Expanded(
                    child: Text(
                      'to organize.'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Text color
                      ),
                    ),
                  ),
                ],
              ),
              20.spaceY,
              Text('Your slot will be divided into ${slotText.toString()} and customer will see ${slotText1.toString()} minuets slot '.tr,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff423E5E),
                  )),
              30.spaceY,
              Align(
                alignment: Alignment.bottomRight,
                child: InkWell(
                  onTap: () {
                    if (formKey.currentState!.validate()) {
                      createSlots();
                    }
                  },
                  child: Container(
                    width: 140,
                    decoration: BoxDecoration(
                      color: AppTheme.buttonColor,
                      borderRadius: BorderRadius.circular(2), // Border radius
                    ),
                    padding: const EdgeInsets.all(10), // Padding inside the container
                    child:  Center(
                      child: Text(
                        'Create Slots'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Text color
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              40.spaceY,
              Text('Preview'.tr,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff423E5E),
                  )),
            Obx(() {
                return   createSlotsModel.value.data != null ?
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: createSlotsModel.value.data!.length.clamp(0, 3),
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 30),
                  itemBuilder: (context, index) {
                    var item = createSlotsModel.value.data![index];
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item.timeSloat.toString(),
                                textAlign: TextAlign.start,
                                style:
                                const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item.timeSloatEnd.toString(),
                                textAlign: TextAlign.start,
                                style:
                                const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        20.spaceY
                      ],
                    );
                  },
                ) : const SizedBox.shrink();
              }),
              40.spaceY,
              InkWell(
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    if( createSlotsModel.value.data != null) {
                      createDuration();
                    }else{
                      showToastCenter('Please create slots'.tr);
                    }
                  }
                },
                child: Container(
                  width: Get.width,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xffF5F2F2),
                    borderRadius: BorderRadius.circular(2), // Border radius
                  ),
                  padding: const EdgeInsets.all(10),
                  // Padding inside the container
                  child:  Center(
                    child: Text(
                      'Save'.tr,
                      style: const TextStyle(
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
              // InkWell(
              //   onTap: () {
              //     Get.to(() => OptionalDetailsScreen());
              //   },
              //   child: Container(
              //     width: Get.width,
              //     height: 70,
              //     decoration: BoxDecoration(
              //       color: AppTheme.buttonColor,
              //       borderRadius: BorderRadius.circular(2), // Border radius
              //     ),
              //     padding: const EdgeInsets.all(10),
              //     // Padding inside the container
              //     child:  Column(
              //       crossAxisAlignment: CrossAxisAlignment.center,
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Text(
              //           'Skip'.tr,
              //           style: TextStyle(
              //             fontSize: 16,
              //             fontWeight: FontWeight.bold,
              //             color: Colors.white, // Text color
              //           ),
              //         ),
              //         Text(
              //           'Product will show call for availability'.tr,
              //           style: TextStyle(
              //             fontSize: 11,
              //             fontWeight: FontWeight.w400,
              //             color: Colors.white, // Text color
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
