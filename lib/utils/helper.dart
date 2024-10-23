import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/common_colour.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class NewHelper {
  static String countryCodeToEmoji(String countryCode) {
    // 0x41 is Letter A
    // 0x1F1E6 is Regional Indicator Symbol Letter A
    // Example :
    // firstLetter U => 20 + 0x1F1E6
    // secondLetter S => 18 + 0x1F1E6
    // See: https://en.wikipedia.org/wiki/Regional_Indicator_Symbol
    final int firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  static String getDiscountPercentage({
    required String sellingPrice,
    required String actualPrice,
  }) {
    double percent =
        (((actualPrice.toNum - sellingPrice.toNum) / actualPrice.toNum) * 100);
    if (percent == 0 || percent > 100) {
      return "";
    }
    return percent.toStringAsFixed(2);
  }

  Future<File?> addFilePicker({List<String>? allowedExtensions}) async {
    try {
      final item = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
      );
      if (item == null) {
        return null;
      } else {
        return File(item.files.first.path!);
      }
    } on PlatformException catch (e) {
      throw Exception(e);
    }
  }

  Future<File?> addVideoPicker({List<String>? allowedExtensions}) async {
    try {
      final item = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.video : FileType.video,
        allowedExtensions: allowedExtensions,
      );
      if (item == null) {
        return null;
      } else {
        return File(item.files.first.path!);
      }
    } on PlatformException catch (e) {
      throw Exception(e);
    }
  }

  Future<List<File>?> addFilePickerList() async {
    try {
      final item = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg'],
      );
      if (item == null) {
        return null;
      } else {
        return item.files.map((e) => File(e.path!)).toList();
      }
    } on PlatformException catch (e) {
      throw Exception(e);
    }
  }

  Future<File?> addImagePicker(
      {ImageSource imageSource = ImageSource.gallery,
      int imageQuality = 80}) async {
    try {
      final item = await ImagePicker()
          .pickImage(source: imageSource, imageQuality: imageQuality);
      if (item == null) {
        return null;
      } else {
        return await FlutterExifRotation.rotateImage(path: item.path);
      }
    } on PlatformException catch (e) {
      throw Exception(e);
    }
  }

  Future<List<File>?> multiImagePicker({int imageQuality = 80}) async {
    try {
      final item =
          await ImagePicker().pickMultiImage(imageQuality: imageQuality);
      return List.generate(
          min(5, item.length), (index) => File(item[index].path));
    } on PlatformException catch (e) {
      throw Exception(e);
    }
  }

  static showImagePickerSheet({
    required Function(File image) gotImage,
    Function(bool image)? removeImage,
    required BuildContext context,
    bool? removeOption,
  }) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          'Select Image'.tr,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppTheme.primaryColor),
        ),
        cancelButton: CupertinoActionSheetAction(
          child: Text('Cancel'.tr),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop("Cancel");
          },
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: Text('Gallery'.tr),
            onPressed: () {
              // pickImage(
              //     ImageSource.gallery);

              NewHelper()
                  .addImagePicker(imageSource: ImageSource.gallery)
                  .then((v) async {
                CroppedFile? croppedFile = await ImageCropper().cropImage(
                  sourcePath: v!.path,
                  // aspectRatioPresets: [
                  //   // CropAspectRatioPreset.square,
                  //   // CropAspectRatioPreset.ratio3x2,
                  //   // CropAspectRatioPreset.original,
                  //   CropAspectRatioPreset.ratio4x3,
                  //   // CropAspectRatioPreset.ratio16x9
                  // ],
                  uiSettings: [
                    AndroidUiSettings(
                        toolbarTitle: 'Cropper',
                        toolbarColor: Colors.deepOrange,
                        toolbarWidgetColor: Colors.white,
                        initAspectRatio: CropAspectRatioPreset.ratio4x3,
                        lockAspectRatio: true),
                    IOSUiSettings(
                      title: 'Cropper',
                    ),
                    WebUiSettings(
                      context: context,
                    ),
                  ],
                );
                if (croppedFile != null) {
                  gotImage(await FlutterExifRotation.rotateImage(
                      path: croppedFile.path));
                  Get.back();
                }
              });
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Camera'.tr),
            onPressed: () {
              NewHelper()
                  .addImagePicker(imageSource: ImageSource.camera)
                  .then((v) async {
                if (v == null) return;
                final item =
                    await FlutterExifRotation.rotateImage(path: v.path);
                CroppedFile? croppedFile = await ImageCropper().cropImage(
                  sourcePath: item.path,
                  // aspectRatioPresets: [
                  //   // CropAspectRatioPreset.square,
                  //   // CropAspectRatioPreset.ratio3x2,
                  //   // CropAspectRatioPreset.original,
                  //   CropAspectRatioPreset.ratio4x3,
                  //   // CropAspectRatioPreset.ratio16x9
                  // ],
                  uiSettings: [
                    AndroidUiSettings(
                        toolbarTitle: 'Cropper',
                        toolbarColor: Colors.deepOrange,
                        toolbarWidgetColor: Colors.white,
                        initAspectRatio: CropAspectRatioPreset.ratio4x3,
                        lockAspectRatio: true),
                    IOSUiSettings(
                      title: 'Cropper',
                    ),
                    WebUiSettings(
                      context: context,
                    ),
                  ],
                );
                if (croppedFile != null) {
                  gotImage(await FlutterExifRotation.rotateImage(path: v.path));
                  Get.back();
                }
              });

              // NewHelper().addImagePicker(imageSource: ImageSource.camera).then((value) async {
              //   if (value == null) return;
              //   gotImage(await FlutterExifRotation.rotateImage(path: value.path));
              //   Get.back();
              // });
            },
          ),
          if (removeOption == true)
            CupertinoActionSheetAction(
              child: Text('Remove'.tr),
              onPressed: () {
                Get.back();
                if (removeImage != null) {
                  removeImage(true);
                }
              },
            ),
        ],
      ),
    );
  }
}

class Helpers {
  Helpers.of(BuildContext context) {
    context = context;
  }
  static Future<List<File>?> addMultiImagePicker(
      {int imageQuality = 30}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg', 'heic', 'mp4', 'mov', 'hevc'],
      );

      if (result == null) {
        return null;
      } else {
        List<File> files =
            result.files.map((file) => File(file.path.toString())).toList();
        return files;
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future addImagePicker(
      {ImageSource imageSource = ImageSource.gallery,
      int imageQuality = 100}) async {
    try {
      final item = await ImagePicker()
          .pickImage(source: imageSource, imageQuality: imageQuality);
      if (item == null) {
        return null;
      } else {
        return File(item.path);
      }
    } on PlatformException catch (e) {
      throw Exception(e);
    }
  }

  static launchEmail({required String email}) async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
      // query: 'subject=App Feedback&body=App Version 3.23', //add subject and body here
    );
    await launchUrl(params);
  }

  static makeCall({required String phoneNumber}) async {
    final Uri params = Uri.parse("tel:$phoneNumber");
    await launchUrl(params);
  }

  String convertToBase64(String credentials) {
    final Codec<String, String> stringToBase64 = utf8.fuse(base64);
    return stringToBase64.encode(credentials);
  }

  String base64ToString(String credentials) {
    final Codec<String, String> base64ToString = utf8.fuse(base64);
    return base64ToString.decode(credentials);
  }

  static OverlayEntry overlayLoader(context) {
    OverlayEntry loader = OverlayEntry(builder: (context) {
      final size = MediaQuery.of(context).size;
      return Positioned(
        height: size.height,
        width: size.width,
        top: 0,
        left: 0,
        child: Material(
            color: AppTheme.primaryColor.withOpacity(0.25),
            child: Center(
                child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Lottie.asset("assets/loti/loading.json",
                            frameRate: FrameRate.max))
                    .animate()
                    .scale(duration: 200.ms)
                    .fade(duration: 200.ms))),
      );
    });
    return loader;
  }

  static OverlayEntry overlayLoaderProgress(context,
      {required RxString progress, required text}) {
    OverlayEntry loader = OverlayEntry(builder: (context) {
      final size = MediaQuery.of(context).size;
      return Positioned(
        height: size.height,
        width: size.width,
        top: 0,
        left: 0,
        child: Material(
          color: AppTheme.primaryColor.withOpacity(0.02),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CupertinoActivityIndicator(
                          radius: 20,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Obx(() {
                          return Center(
                              child: Text(
                            progress.value,
                            style: GoogleFonts.poppins(),
                          )
                              // AddText(
                              //   text: "${progress.value}",
                              //   fontWeight: FontWeight.bold,
                              //   fontSize: AddSize.font18,
                              //   color: Colors.black,
                              // ),
                              );
                        }),
                        const SizedBox(
                          height: 30,
                        ),
                        Text(text),
                        // AddText(
                        //   text: text,
                        //   fontSize: AddSize.font16,
                        //   fontWeight: FontWeight.bold,
                        // )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
    return loader;
  }

  static hideLoader(OverlayEntry loader) {
    Timer(const Duration(milliseconds: 250), () {
      try {
        loader.remove();
        // ignore: empty_catches
      } catch (e) {}
    });
  }

  static hideShimmer(OverlayEntry loader) {
    Timer(const Duration(milliseconds: 500), () {
      try {
        loader.remove();
        // ignore: empty_catches
      } catch (e) {}
    });
  }

  static Uri getUri(String baseUrl, String path) {
    String path = Uri.parse(baseUrl).path;
    if (!path.endsWith('/')) {
      path += '/';
    }
    Uri uri = Uri(
        scheme: Uri.parse(baseUrl).scheme,
        host: Uri.parse(baseUrl).host,
        port: Uri.parse(baseUrl)
            .port, //GlobalConfiguration().getValue('base_url')
        path: path + path);
    return uri;
  }

  /*static Future<bool> verifyInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }*/
  static String discount(int price, int saleprice) {
    try {
      // var intprice = int.parse(price);
      //  var intsaleprice = int.parse(saleprice);
      double par = ((price - saleprice) / price) * 100;
      double i = double.parse((par).toStringAsFixed(2));
      return '$i';
    } catch (e) {
      return '';
    }
  }

  static createSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 5),
      backgroundColor: Colors.black,
      content: Text(
        message,
        style: GoogleFonts.poppins(
            fontSize: 14.0, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    ));
  }

  static bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern.toString());
    return (!regex.hasMatch(value)) ? false : true;
  }
}

extension ConvertToNum on String {
  Duration get durationTime {
    return Duration(
      hours: split(":").first.toNum.toInt(),
      minutes: split(":")[1].toNum.toInt(),
    );
  }

  String get normalTime {
    if (split(":").length > 1) {
      return "${split(":").first}:${split(":")[1]}";
    }
    return this;
  }

  num? get convertToNum {
    return num.tryParse(this);
  }

  num get toNum {
    return num.tryParse(this) ?? 0;
  }

  bool get invalidEmail {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern.toString());
    return (regex.hasMatch(this)) ? false : true;
  }

  String? validateEmpty(String gg) {
    return trim().isEmpty ? "$gg is required" : null;
  }

  String get checkNullable {
    if (this == "null") return "";
    return this;
  }

  String get checkHTTP {
    return contains("https://") || contains("http://") ? split("/").last : "";
  }

  String get convertToFormatTime {
    return "${split(":")[0]}:${split(":")[1]}";
  }
}

// extension CheckNull on String?{
//   String get checkNull{
//     return this ?? "";
//   }
// }

// extension GG on dynamic{
//
//   String get checkNullable{
//     if(this == null) return"";
//     return toString();
//   }
// }

extension GetTotal on List<num> {
  num get getTotal {
    return sum;
  }
}

extension Spacing on num {
  SizedBox get spaceX => SizedBox(
        width: toDouble(),
      );
  SizedBox get spaceY => SizedBox(
        height: toDouble(),
      );
}

extension GetContext on BuildContext {
  Size get getSize => MediaQuery.of(this).size;

  Future get navigate async {
    return await Scrollable.ensureVisible(this,
        alignment: .25, duration: const Duration(milliseconds: 600));
  }
}

GlobalKey<FormFieldState> textFieldKey = GlobalKey<FormFieldState>();

extension ValidateErrors on TextEditingController {
  bool get checkEmpty {
    if (text.trim().isNotEmpty) return false;
    BuildContext? context1 = textFieldKey.currentContext;
    if (context1 != null) {
      context1.navigate;
      return true;
    } else {
      return false;
    }
  }

  bool get checkNum {
    if ((num.tryParse(text.trim()) ?? 0) > 0) return false;
    BuildContext? context1 = textFieldKey.currentContext;
    if (context1 != null) {
      context1.navigate;
      return true;
    } else {
      return false;
    }
  }

  bool get checkEmail {
    if (!text.trim().invalidEmail) return false;
    BuildContext? context1 = textFieldKey.currentContext;
    if (context1 != null) {
      context1.navigate;
      return true;
    } else {
      return false;
    }
  }

  bool get checkPhoneNumber {
    if (text.trim().length >= 10) return false;
    BuildContext? context1 = textFieldKey.currentContext;
    if (context1 != null) {
      context1.navigate;
      return true;
    } else {
      return false;
    }
  }

  bool get checkBothWithNum {
    // print("checkEmpty.....   $checkEmpty");
    // print("checkNum.....   $checkNum");
    return checkEmpty || checkNum;
  }

  bool get checkBothWithEmail {
    // print("checkEmpty.....   $checkEmpty");
    // print("checkNum.....   $checkNum");
    return checkEmpty || checkEmail;
  }

  bool get checkBothWithPhone {
    // print("checkEmpty.....   $checkEmpty");
    // print("checkNum.....   $checkNum");
    return checkEmpty || checkPhoneNumber;
  }
}

extension WidgetExtensions on Widget {
  Widget get toShimmer {
    return Shimmer.fromColors(
      baseColor: Colors.grey,
      highlightColor: Colors.white,
      child: this,
    );
  }

  SliverToBoxAdapter get toBoxAdapter => SliverToBoxAdapter(
        child: this,
      );
}

extension ConvertToDateon on Duration {
  DateTime get fromTodayStart {
    DateTime now = DateTime.now();
    DateTime gg = DateTime(now.year, now.month, now.day);
    return gg.add(this);
  }
}

const audioType = [
  "mp3",
  ".mp3",
];
