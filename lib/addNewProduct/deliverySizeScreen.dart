import 'dart:convert';

import 'package:dirise/addNewProduct/reviewPublishScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../addNewProduct/internationalshippingdetailsScreem.dart';
import '../controller/profile_controller.dart';
import '../controller/vendor_controllers/add_product_controller.dart';
import '../model/common_modal.dart';
import '../repository/repository.dart';
import '../utils/api_constant.dart';
import '../widgets/common_button.dart';

class DeliverySizeScreen extends StatefulWidget {
  int? id;
  String? selectedRadio;
  DeliverySizeScreen({Key? key, this.id, this.selectedRadio});

  @override
  State<DeliverySizeScreen> createState() => _DeliverySizeScreenState();
}

class _DeliverySizeScreenState extends State<DeliverySizeScreen> {
  String? selectedRadio; // Variable to track the selected radio button
  final addProductController = Get.put(AddProductController());
  deliverySizeApi() {
    Map<String, dynamic> map = {};
    map['delivery_size'] = selectedRadio;
    map['item_type'] = 'giveaway';
    map['id'] = addProductController.idProduct.value.toString();

    final Repositories repositories = Repositories();
    FocusManager.instance.primaryFocus!.unfocus();
    repositories.postApi(url: ApiUrls.giveawayProductAddress, context: context, mapData: map).then((value) {
      ModelCommonResponse response = ModelCommonResponse.fromJson(jsonDecode(value));
      print('API Response Status Code: ${response.status}');
      showToast(response.message.toString());
      if (response.status == true) {
        if(widget.id != null){
          Get.to( ReviewPublishScreen());
        }else{
          Get.to(InternationalshippingdetailsScreen(),arguments:[selectedRadio]);
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.id != null){
      selectedRadio = widget.selectedRadio;
    }
  }

  final profileController = Get.put(ProfileController());
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
              'Delivery Size'.tr,
              style: GoogleFonts.poppins(color: const Color(0xff292F45), fontWeight: FontWeight.w600, fontSize: 20),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose According to Size'.tr,
                style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(
                height: 15,
              ),
              profileController.selectedLAnguage.value == "English"
              ?Row(
                children: [
                  Container(
                   width:230,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(11), color: Colors.grey.shade100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Fits in small car'.tr,
                          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 18),
                        ),
                        Radio(
                          value: 'small_car',
                          groupValue: selectedRadio,
                          onChanged: (value) {
                            setState(() {
                              selectedRadio = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              )
              :Row(
                children: [
                  Container(
                   width:MediaQuery.of(context).size.width*0.9,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(11), color: Colors.grey.shade100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Fits in small car'.tr,
                          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 18),
                        ),
                        Radio(
                          value: 'small_car',
                          groupValue: selectedRadio,
                          onChanged: (value) {
                            setState(() {
                              selectedRadio = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              profileController.selectedLAnguage.value == "English"
              ?Row(
                children: [
                  Container(
                    width:230,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(11), color: Colors.grey.shade100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Need truck'.tr,
                          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 18),
                        ),
                        Radio(
                          value: 'need_truck',
                          groupValue: selectedRadio,
                          onChanged: (value) {
                            setState(() {
                              selectedRadio = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              )
              :Row(
                children: [
                  Container(
                    width:MediaQuery.of(context).size.width*0.9,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(11), color: Colors.grey.shade100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Need truck'.tr,
                          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 18),
                        ),
                        Radio(
                          value: 'need_truck',
                          groupValue: selectedRadio,
                          onChanged: (value) {
                            setState(() {
                              selectedRadio = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              profileController.selectedLAnguage.value == "English"
              ?Row(
                children: [
                  Container(
                    width:230,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(11), color: Colors.grey.shade100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Freight & cargo'.tr,
                          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 18),
                        ),
                        Radio(
                          value: 'freight_cargo',
                          groupValue: selectedRadio,
                          onChanged: (value) {
                            setState(() {
                              selectedRadio = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              )
              :Row(
                children: [
                  Container(
                    width:MediaQuery.of(context).size.width*0.9,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(11), color: Colors.grey.shade100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Freight & cargo'.tr,
                          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 18),
                        ),
                        Radio(
                          value: 'freight_cargo',
                          groupValue: selectedRadio,
                          onChanged: (value) {
                            setState(() {
                              selectedRadio = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Radio button for freight cargo
              SizedBox(
                height: 100,
              ),
              CustomOutlineButton(
                title: 'Next'.tr,
                borderRadius: 11,
                onPressed: () {
                  if (selectedRadio == 'small_car') {
                    deliverySizeApi();
                  } else if (selectedRadio == 'need_truck') {
                    deliverySizeApi();
                  } else if (selectedRadio == 'freight_cargo') {
                    deliverySizeApi();
                  } else {
                    showToast('Select delivery size'.tr);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
