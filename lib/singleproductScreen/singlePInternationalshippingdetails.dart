import 'dart:convert';
import 'dart:developer';

import 'package:dirise/utils/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controller/profile_controller.dart';
import '../controller/service_controller.dart';
import '../controller/vendor_controllers/add_product_controller.dart';
import '../model/common_modal.dart';
import '../repository/repository.dart';
import '../utils/api_constant.dart';
import '../widgets/common_button.dart';
import '../widgets/common_colour.dart';
import '../widgets/common_textfield.dart';
import 'ReviewandPublishScreen.dart';
import 'optionalDiscrptionsScreen.dart';

class SinglePInternationalshippingdetailsScreen extends StatefulWidget {
  int? id;
  String? Unitofmeasure;
  int? WeightOftheItem;
  int? SelectNumberOfPackages;
  String? SelectTypeMaterial;
  String? SelectTypeOfPackaging;
  String? Length;
  String? Width;
  String? Height;
  dynamic selectTypeMaterial;
  dynamic productType;
  dynamic unitOfMeasure;
  SinglePInternationalshippingdetailsScreen(
      {super.key,
        this.id,
        this.WeightOftheItem,
        this.Unitofmeasure,
        this.SelectTypeOfPackaging,
        this.SelectTypeMaterial,
        this.SelectNumberOfPackages,
        this.Length,
        this.Height,
        this.Width,
        this.selectTypeMaterial,
        this.productType,
        this.unitOfMeasure
      });

  @override
  State<SinglePInternationalshippingdetailsScreen> createState() => _SinglePInternationalshippingdetailsScreenState();
}

class _SinglePInternationalshippingdetailsScreenState extends State<SinglePInternationalshippingdetailsScreen> {
  String selectedItem = 'Item 1';
  TextEditingController dimensionController = TextEditingController();
  TextEditingController dimensionWidthController = TextEditingController();
  TextEditingController dimensionHeightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController numberOfPackagesController = TextEditingController();


  final serviceController = Get.put(ServiceController());
  String unitOfMeasure = 'Cm/Kg';
  Map<String, String> unitOfMeasureMap = {
    'Cm/Kg': 'cm/kg',
    'Lb/Inch': 'inch/lb'
  };
  List<String> unitOfMeasureList = [
    'Cm/Kg',
    'Lb/Inch',
  ];

  String selectNumberOfPackages = '1';
  List<String> selectNumberOfPackagesList = List.generate(30, (index) => (index + 1).toString());

  String selectTypeMaterial = 'Select Material';
  List<String> selectTypeMaterialList = [
    'Select Material',
    'Paper',
    'Plastic',
    'Glass',
    'Metal',
    'Wood',
    'Fabric',
    'Leather',
    'Rubber',
    'Ceramic',
    'Stone',
    'Cardboard',
    'Carton',
    'Foam',
    'Fiberglass',
    'Carbon',
    'fiber',
    'Concrete',
    'Brick',
    'Tile',
    'Vinyl',
    'Plywood',
  ];

  String? selectTypeOfPackaging;
  Map<String, String> selectTypeOfPackagingMap = {
    'your packaging': 'your_packaging',
    'custom packaging': 'custom_packaging'
  };
  List<String> selectTypeOfPackagingList = [
    'your packaging',
    'custom packaging',
  ];
  final formKey = GlobalKey<FormState>();
  RxBool hide = true.obs;
  RxBool hide1 = true.obs;
  bool showValidation = false;
  bool? _isValue = false;
  final Repositories repositories = Repositories();
  String code = "+91";
  final addProductController = Get.put(AddProductController());
  shippingDetailsApi() {
    Map<String, dynamic> map = {};
    map['weight_unit'] = unitOfMeasureMap[unitOfMeasure];
    map['item_type'] = 'product';
    map['weight'] = weightController.text.trim();
    map['number_of_package'] = numberOfPackagesController.text.trim();
    map['material'] = selectTypeMaterial;
    map['box_length'] = dimensionController.text.trim();
    map['box_width'] = dimensionWidthController.text.trim();
    map['box_height'] = dimensionHeightController.text.trim();
    map['type_of_packages'] = selectTypeOfPackagingMap[selectTypeOfPackaging];
    map['id'] = addProductController.idProduct.value.toString();

    FocusManager.instance.primaryFocus!.unfocus();
    repositories.postApi(url: ApiUrls.giveawayProductAddress, context: context, mapData: map).then((value) {
      ModelCommonResponse response = ModelCommonResponse.fromJson(jsonDecode(value));
      showToast(response.message.toString());
      if (response.status == true) {
        log('dsgdgsdfg${numberOfPackagesController.text.toString()}');
        if(widget.id != null){

          Get.to(ProductReviewPublicScreen());
        }else{
          Get.to(() => OptionalDiscrptionsScreen());

        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.id != null){
      // unitOfMeasure = widget.Unitofmeasure.toString();
      weightController.text = widget.WeightOftheItem.toString();
      // selectTypeMaterial = widget.SelectTypeMaterial.toString();
      dimensionController.text = widget.Length.toString();
      dimensionWidthController.text = widget.Width.toString();
      dimensionHeightController.text = widget.Height.toString();
      numberOfPackagesController.text = widget.SelectNumberOfPackages.toString();
      // selectTypeOfPackaging = widget.SelectTypeOfPackaging.toString();
      if(widget.selectTypeMaterial != ''){
        selectTypeMaterial = widget.selectTypeMaterial.toString();
      }
      // if(widget.productType != ''){
      //   selectTypeOfPackaging = widget.productType.toString();
      // }
      if(widget.unitOfMeasure != ''){
        unitOfMeasure = widget.unitOfMeasure.toString();
      }
    }
  }

  final profileController = Get.put(ProfileController());
  final formKey5 = GlobalKey<FormState>();
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
              'Item Weight & Dimensions'.tr,
              style: GoogleFonts.poppins(color: const Color(0xff292F45), fontWeight: FontWeight.w600, fontSize: 20),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(left: 15, right: 15),
          child: Form(
            key: formKey5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We use this information to estimate your shipping prices. If you plan to ship internationally or your item is bigger than 5kg or 0.05 CBM then you must fill all the details below.'.tr,
                  style: GoogleFonts.poppins(color: const Color(0xff292F45), fontWeight: FontWeight.w500, fontSize: 18),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Unit of measure'.tr,
                  style: GoogleFonts.poppins(color: const Color(0xff292F45), fontWeight: FontWeight.w500, fontSize: 16),
                ),
                const SizedBox(height: 5),
                DropdownButtonFormField<String>(
                  value: unitOfMeasure,
                  onChanged: (String? newValue) {
                    setState(() {
                      unitOfMeasure = newValue!;
                    });
                  },
                  items: unitOfMeasureList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an item'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Weight'.tr,
                  style: GoogleFonts.poppins(color: const Color(0xff292F45), fontWeight: FontWeight.w500, fontSize: 16),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  decoration: InputDecoration(
                    counterStyle: GoogleFonts.poppins(
                      color: AppTheme.primaryColor,
                      fontSize: 25,
                    ),
                    counter: const Offstage(),
                    errorMaxLines: 2,
                    contentPadding: const EdgeInsets.all(15),
                    fillColor: Colors.grey.shade100,
                    hintText: 'Weight'.tr,
                    hintStyle: GoogleFonts.poppins(
                      color: AppTheme.primaryColor,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    focusedErrorBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: AppTheme.secondaryColor)),
                    errorBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: AppTheme.secondaryColor)),
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
                    if (value!.trim().isEmpty) {
                      return 'weight is required'.tr;
                    }
                    double? weight = double.tryParse(value);
                    if (weight == null || weight <= 0) {
                      return 'Weight must be greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Number of packages'.tr,
                  style: GoogleFonts.poppins(color: const Color(0xff292F45), fontWeight: FontWeight.w500, fontSize: 16),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: numberOfPackagesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    counterStyle: GoogleFonts.poppins(
                      color: AppTheme.primaryColor,
                      fontSize: 25,
                    ),
                    counter: const Offstage(),
                    errorMaxLines: 2,
                    contentPadding: const EdgeInsets.all(15),
                    fillColor: Colors.grey.shade100,
                    hintText: 'Number of packages'.tr,
                    hintStyle: GoogleFonts.poppins(
                      color: AppTheme.primaryColor,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    focusedErrorBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: AppTheme.secondaryColor)),
                    errorBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: AppTheme.secondaryColor)),
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
                    if (value!.trim().isEmpty) {
                      return 'Number of Package is required'.tr;
                    }
                    return null; // Return null if validation passes
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Material'.tr,
                  style: GoogleFonts.poppins(color: const Color(0xff292F45), fontWeight: FontWeight.w500, fontSize: 16),
                ),
              const SizedBox(height: 5),
                DropdownButtonFormField<String>(

                  value: selectTypeMaterial,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectTypeMaterial = newValue!;
                    });
                  },
                  items: selectTypeMaterialList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
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
                  hint: Text("Select Material".tr),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an item'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Box dimension L X W X H (Optional)'.tr,
                    style: GoogleFonts.poppins(color: const Color(0xff292F45), fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: Text(
                          'Length'.tr,
                          style: GoogleFonts.poppins(color: const Color(0xff292F45), fontWeight: FontWeight.w500, fontSize: 16),
                        ),),
                    10.spaceX,
                    Expanded(
                      child: Text(
                        'Width'.tr,
                        style: GoogleFonts.poppins(color: const Color(0xff292F45), fontWeight: FontWeight.w500, fontSize: 16),
                      ),),
                    10.spaceX,
                    Expanded(
                      child: Text(
                        'Height'.tr,
                        style: GoogleFonts.poppins(color: const Color(0xff292F45), fontWeight: FontWeight.w500, fontSize: 16),
                      ),),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                        child: CommonTextField(
                      controller: dimensionController,
                      obSecure: false,
                      keyboardType: TextInputType.number,
                      hintText: 'Length X '.tr,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Length is required'.tr;
                        }
                        double? weight = double.tryParse(value);
                        if (weight == null || weight <= 0) {
                          showToast('Length must be greater than 0',);
                          return null;
                        }
                        return null;
                      },
                    )),
                    10.spaceX,
                    Expanded(
                        child: CommonTextField(
                      controller: dimensionWidthController,
                      obSecure: false,
                      hintText: 'Width X'.tr,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Width is required'.tr;
                        }
                        double? weight = double.tryParse(value);
                        if (weight == null || weight <= 0) {
                          showToast('Width must be greater than 0');
                          return null;
                        }
                        return null; // Return null if validation passes
                      },
                    )
                    ),
                    10.spaceX,
                    Expanded(
                        child: CommonTextField(
                      controller: dimensionHeightController,
                      obSecure: false,
                      hintText: 'Height X'.tr,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Height is required'.tr;
                        }
                        double? weight = double.tryParse(value);
                        if (weight == null || weight <= 0) {
                          showToast('Height must be greater than 0');
                          return null;
                        }
                        return null; // Return null if validation passes
                      },
                    )),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Package type'.tr,
                  style: GoogleFonts.poppins(color: const Color(0xff292F45), fontWeight: FontWeight.w500, fontSize: 16),
                ),
                const SizedBox(height: 5),
                DropdownButtonFormField<String>(
                  value: selectTypeOfPackaging,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectTypeOfPackaging = newValue!;
                    });
                  },
                  items: selectTypeOfPackagingList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
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
                  hint: Text("Select Type".tr,
                  style: TextStyle(fontWeight: FontWeight.w600),),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an item'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomOutlineButton(
                  title: 'Confirm'.tr,
                  borderRadius: 11,
                  onPressed: () {
                    if (formKey5.currentState!.validate()) {
                      shippingDetailsApi();
                    }
                  },
                ),
                const SizedBox(height: 20),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
