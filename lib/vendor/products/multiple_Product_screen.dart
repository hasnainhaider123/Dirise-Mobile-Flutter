import 'dart:convert';

import '../../controller/vendor_controllers/add_product_controller.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controller/profile_controller.dart';
import '../../model/addMultipleModel.dart';
import '../../model/model_sample_csv.dart';
import '../../repository/repository.dart';
import '../../utils/api_constant.dart';
import '../../widgets/common_button.dart';
import '../authentication/image_widget.dart';
import 'multiple_product_review.dart';

class AddMultipleProductScreen extends StatefulWidget {
  const AddMultipleProductScreen({super.key});

  @override
  State<AddMultipleProductScreen> createState() =>
      _AddMultipleProductScreenState();
}

class _AddMultipleProductScreenState extends State<AddMultipleProductScreen> {
  File featuredImage = File("");
  File galleryImage = File("");
  RxBool showValidation = false.obs;
  final profileController = Get.put(ProfileController());
  bool checkValidation(bool bool1, bool2) {
    if (bool1 == true && bool2 == true) {
      return true;
    } else {
      return false;
    }
  }

  int productID = 0;
  final addProductController = Get.put(AddProductController());
  Map<String, File> images = {};
  void addProduct() {
    Map<String, String> map = {};
    images["csv_file"] = featuredImage;
    // images["gallery_image[0]"] = galleryImage;

    final Repositories repositories = Repositories();
    repositories
        .multiPartApi(
            mapData: map,
            images: images,
            context: context,
            url: ApiUrls.addMultipleProduct,
            onProgress: (int bytes, int totalBytes) {})
        .then((value) {
      AddMultipleModel response = AddMultipleModel.fromJson(jsonDecode(value));
      // addProductController.idProduct.value = response.data!.product!.id.toString();
      // profileController.productID = productID;
      Get.to(MultipleReviewAndPublishScreen(),
          arguments: [response.data.toString()]);
      showToast(response.message.toString());
    });
  }

  Rx<SampleCsvModel> sampleCsvModel = SampleCsvModel().obs;
  final Repositories repositories = Repositories();

  getSampleData() {
    repositories.getApi(url: ApiUrls.sampleCsvFile).then((value) {
      setState(() {
        sampleCsvModel.value = SampleCsvModel.fromJson(jsonDecode(value));
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSampleData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Multiple Products'.tr),
        centerTitle: true,
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
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(left: 30, right: 30, top: 30),
          child: Column(
            children: [
              Text(
                  "Kindly download the following templates to conveniently upload all your products at once\nCopy and paste your products accordingly upload it in the next step."
                      .tr),
              const SizedBox(
                height: 10,
              ),
              ImageWidget1(
                // key: paymentReceiptCertificateKey,
                title: "Upload multiple product".tr,
                file: featuredImage,
                validation: checkValidation(
                    showValidation.value, featuredImage.path.isEmpty),
                filePicked: (File g) {
                  featuredImage = g;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              // ImageWidget(
              //   // key: paymentReceiptCertificateKey,
              //   title: "Click To Edit Uploaded  Image".tr,
              //   file: galleryImage,
              //   validation: checkValidation(showValidation.value, galleryImage.path.isEmpty),
              //   filePicked: (File g) {
              //     galleryImage = g;
              //   },
              // ),
              SizedBox(
                height: 50,
              ),
              CustomOutlineButton(
                title: 'Next'.tr,
                onPressed: () {
                  if (featuredImage.path.isNotEmpty) {
                    addProduct();
                  } else {
                    showToast('Please upload file'.tr);
                  }
                },
              ),
              SizedBox(
                height: 30,
              ),
              CustomOutlineButton(
                backgroundColor: Colors.red,
                title: 'Download demo file'.tr,
                onPressed: () async {
                  final csvUrl = sampleCsvModel.value.data!.csvFile.toString();
                  if (await canLaunch(csvUrl)) {
                    await launch(
                      csvUrl,
                      forceSafariVC: false, // Don't use in-app WebView for iOS
                      forceWebView:
                          false, // Don't use in-app WebView for Android
                    );
                  } else {
                    print('Could not launch $csvUrl');
                  }
                  // final url =
                  //     'https://docs.google.com/spreadsheets/d/1tHDp9nfgd8_g7CeW5jO3DTJrPTNywLYY/export?format=csv';

                  // // Open Safari for iOS and default browser for Android
                  // if (await canLaunch(url)) {
                  //   await launch(url,
                  //       forceSafariVC: false, forceWebView: false);
                  // } else {
                  //   throw 'Could not launch $url';
                  // }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
