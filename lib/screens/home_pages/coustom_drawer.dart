import 'dart:convert';
import 'dart:io';
import 'package:dirise/controller/profile_controller.dart';
import 'package:dirise/utils/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Services/pick_up_address_service.dart';
import '../../controller/cart_controller.dart';
import '../../controller/home_controller.dart';
import '../../iAmHereToSell/whichplantypedescribeyouScreen.dart';
import '../../language/app_strings.dart';
import '../../model/common_modal.dart';
import '../../model/customer_profile/model_city_list.dart';
import '../../model/customer_profile/model_country_list.dart';
import '../../model/customer_profile/model_state_list.dart';
import '../../model/model_address_list.dart';
import '../../model/model_user_delete.dart';
import '../../personalizeyourstore/socialMediaScreen.dart';
import '../../posts/posts_ui.dart';
import '../../repository/repository.dart';
import '../../utils/api_constant.dart';
import '../../vendor/dashboard/dashboard_screen.dart';
import '../../vendor/dashboard/store_open_time_screen.dart';
import '../../vendor/orders/vendor_order_list_screen.dart';
import '../../vendor/payment_info/bank_account_screen.dart';
import '../../vendor/payment_info/withdrawal_screen.dart';
import '../../vendor/products/all_product_screen.dart';
import '../../vendor/products/approve_product.dart';
import '../../widgets/common_colour.dart';
import '../../widgets/common_textfield.dart';
import '../auth_screens/login_screen.dart';
import '../check_out/address/edit_address.dart';
import '../check_out/check_out_screen.dart';
import '../my_account_screens/about_us_screen.dart';
import '../my_account_screens/contact_us_screen.dart';
import '../my_account_screens/faqs_screen.dart';
import '../my_account_screens/profile_screen.dart';
import '../my_account_screens/return_policy_screen.dart';
import '../my_account_screens/social_link_for_account.dart';
import '../my_account_screens/termsconditions_screen.dart';
import '../order_screens/my_orders_screen.dart';
import '../virtual_assets/virtual_assets_screen.dart';
import 'get_job_screen.dart';

Locale locale = const Locale('en', 'US');

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({
    super.key,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final profileController = Get.put(ProfileController());
  updateLanguage(String gg) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("app_language", gg);
  }

  @override
  void initState() {
    super.initState();
    profileController.getDataProfile();
  }

  ModelCountryList? modelCountryList;
  Country? selectedCountry;
  whatsapp() async {
    String contact = "+96565556490";
    String text = '';
    String androidUrl = "whatsapp://send?phone=$contact&text=$text";
    String iosUrl = "https://wa.me/$contact?text=${Uri.parse(text)}";
    String webUrl = 'https://api.whatsapp.com/send/?phone=$contact&text=hi';

    try {
      if (Platform.isIOS) {
        if (await canLaunchUrl(Uri.parse(iosUrl))) {
          await launchUrl(Uri.parse(iosUrl));
        }
      } else {
        if (await canLaunchUrl(Uri.parse(androidUrl))) {
          await launchUrl(Uri.parse(androidUrl));
        }
      }
    } catch(e) {
      print('object');
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
    }
  }
  ModelStateList? modelStateList;
  CountryState? selectedState;
  City? selectedCity;
  ModelCityList? modelCityList;
  final homeController = Get.put(TrendingProductsController());
  bool get userLoggedIn => profileController.userLoggedIn;
  bool isLoggedIn = false;

  checkUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.getString('login_user') != null) {
      isLoggedIn = true;
    } else {
      isLoggedIn = false;
    }
    if (mounted) {
      setState(() {});
    }
  }

  Rx<UserDeleteModel> deleteModal = UserDeleteModel().obs;
  RxString language = "".obs;
  final RxBool _isValue = false.obs;
  var vendor = [
    'Dashboard',
    'Sold Orders',
    'Pending Products',
    'Approved Products',
    'Operating Hours',
    'Social Media',
    'Bank Details',
    'Earnings'
  ];
  var vendorArab = ['لوحة القيادة', 'طلب', 'المنتجات المعلقة', 'المنتجات المعتمدة','ساعات العمل','وسائل التواصل الاجتماعي','التفاصيل المصرفية', 'الأرباح'];
  var vendor1 = [
    'Become a vendor',
    'Pending Products',
    'Approved Products',
  ];
  var vendor1Arab = ['كن بائعًا', 'المنتجات المعلقة', 'المنتجات المعتمدة'];
  var vendorRoutes = [
    VendorDashBoardScreen.route,
    VendorOrderList.route,
    VendorProductScreen.route,
    ApproveProductScreen.route,
    SetTimeScreen.route,
    BankDetailsScreen.route,
    WithdrawMoney.route,
  ];
  var vendorRoutes1 = [
    LoginScreen.route,
    VendorProductScreen.route,
    ApproveProductScreen.route,
  ];
  RxInt stateRefresh = 2.obs;
  Future getStateList({required String countryId, bool? reset}) async {
    if (reset == true) {
      modelStateList = null;
      selectedState = null;
      modelCityList = null;
      selectedCity = null;
    }
    stateRefresh.value = -5;
    final map = {'country_id': countryId};
    await repositories.postApi(url: ApiUrls.allStatesUrl, mapData: map).then((value) {
      modelStateList = ModelStateList.fromJson(jsonDecode(value));
      setState(() {});
      stateRefresh.value = DateTime.now().millisecondsSinceEpoch;
    }).catchError((e) {
      stateRefresh.value = DateTime.now().millisecondsSinceEpoch;
    });
  }

  RxInt cityRefresh = 2.obs;
  String stateIddd = '';
  Future getCityList({required String stateId, bool? reset}) async {
    if (reset == true) {
      modelCityList = null;
      selectedCity = null;
    }
    cityRefresh.value = -5;
    final map = {'state_id': stateId};
    await repositories.postApi(url: ApiUrls.allCityUrl, mapData: map).then((value) {
      modelCityList = ModelCityList.fromJson(jsonDecode(value));
      setState(() {});
      cityRefresh.value = DateTime.now().millisecondsSinceEpoch;
    }).catchError((e) {
      cityRefresh.value = DateTime.now().millisecondsSinceEpoch;
    });
  }

  getCountryList() {
    if (modelCountryList != null) return;
    repositories.getApi(url: ApiUrls.allCountriesUrl).then((value) {
      modelCountryList = ModelCountryList.fromString(value);
    });
  }

  String countryIddd = '';
  final Repositories repositories = Repositories();
  defaultAddressApi() async {
    Map<String, dynamic> map = {};
    map['address_id'] = cartController.selectedAddress.id.toString();
    repositories.postApi(url: ApiUrls.defaultAddressStatus, context: context, mapData: map).then((value) async {
      ModelCommonResponse response = ModelCommonResponse.fromJson(jsonDecode(value));
      if (response.status == true) {
        showToast(response.message.toString());
        Get.back();
      } else {
        showToast(response.message.toString());
      }
    });
  }

  final cartController = Get.put(CartController());
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    Size size = MediaQuery.of(context).size;
    return Drawer(
        child: Container(
      color: Colors.white,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: <Widget>[
            Container(
              height: screenSize.height * 0.28,
              width: screenSize.width,
              decoration: const BoxDecoration(
                color: AppTheme.newPrimaryColor,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: screenSize.height * 0.05,
                  ),
                  Expanded(
                    child: GestureDetector(
                        onTap: () {
                          // Get.to(navigationPage.elementAt(_currentPage))
                          // Get.to(MyProfile());
                        },
                        child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          color: AppTheme.newPrimaryColor,
                          child: Obx(() {
                            if (profileController.refreshInt.value > 0) {}
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  profileController.userLoggedIn
                                      ? profileController.apiLoaded && profileController.model.user != null
                                          ? profileController.model.user!.name ?? ""
                                          : ""
                                      : AppStrings.guestUser.tr,
                                  maxLines: 1,
                                  style: GoogleFonts.poppins(
                                      color: AppTheme.buttonColor, fontSize: 24, fontWeight: FontWeight.w600),
                                ),
                                4.spaceY,
                                Container(
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle),
                                  child: SizedBox(
                                      height: 65,
                                      width: 65,
                                      child: profileController.userLoggedIn
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(1000),
                                              child: SizedBox(
                                                height: 65,
                                                width: 65,
                                                child: profileController.userLoggedIn
                                                    ? Image.network(
                                                  profileController.apiLoaded
                                                      ? profileController.model.user!.profileImage.toString() : "",
                                                        fit: BoxFit.cover,
                                                        height: 65,
                                                        width: 65,
                                                        // errorBuilder: (_, __, ___) => Image.asset(
                                                        //   'assets/images/myaccount.png',
                                                        //   height: 65,
                                                        //   width: 65,
                                                        // ),
                                                      errorBuilder: (_, __, ___) => Image.asset('assets/images/profile-icon.png',  fit: BoxFit.cover,
                                                          height: 65,
                                                          width: 65,),
                                                      )
                                                    // : Image.asset(
                                                    //     'assets/images/myaccount.png',
                                                    //     height: 65,
                                                    //     width: 65,
                                                    //   ),
                                                    : Container(
                                                        decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            color: Colors.white,
                                                            border: Border.all(color: Colors.white)),
                                                        child: const SizedBox(
                                                            height: 65,
                                                            width: 65,
                                                            child: Icon(
                                                              Icons.person,
                                                              color: AppTheme.buttonColor,
                                                              size: 45,
                                                            )),
                                                      ),
                                              ),
                                            )
                                          :  Image.asset('assets/images/profile-icon.png',  fit: BoxFit.cover,
                                        color: AppTheme.buttonColor,
                                        height: 65,
                                        width: 65,),),
                                ),
                                5.spaceY,
                                Text(
                                  profileController.userLoggedIn
                                      ? profileController.apiLoaded && profileController.model.user != null
                                          ? profileController.model.user!.email ?? ""
                                          : ""
                                      : "",
                                  style: GoogleFonts.poppins(
                                      color: AppTheme.buttonColor, fontSize: 16, fontWeight: FontWeight.w400),
                                ),
                                5.spaceY,
                              ],
                            );
                          }),
                        )),
                  ),
                  SizedBox(
                    height: screenSize.height * 0.02,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(
                // height: SizeConfig.heightMultiplier! * .5,
                ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(children: [
                16.spaceY,
                profileController.userLoggedIn
                    ? ListTile(
                        onTap: () {
                          if (profileController.userLoggedIn) {
                            Get.toNamed(ProfileScreen.route);
                          } else {
                            Get.toNamed(LoginScreen.route);
                          }
                        },
                        dense: true,
                        minLeadingWidth: 0,
                        contentPadding: EdgeInsets.zero,
                        minVerticalPadding: 0,
                        visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                        title: Row(
                          children: [
                            Image.asset(height: 25, 'assets/icons/drawerprofile.png'),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: Text(
                                AppStrings.myProfile.tr,
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF2A3032), fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                            profileController.selectedLAnguage.value == 'English' ?
                            Image.asset(
                              'assets/images/forward_icon.png',
                              height: 17,
                              width: 17,
                            ) :
                            Image.asset(
                              'assets/images/back_icon_new.png',
                              height: 17,
                              width: 17,
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
                profileController.userLoggedIn
                    ? const Divider(
                        thickness: 1,
                        color: Color(0x1A000000),
                      )
                    : const SizedBox.shrink(),
                profileController.userLoggedIn
                    ? const SizedBox(
                        height: 5,
                      )
                    : const SizedBox.shrink(),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (profileController.userLoggedIn) {
                      Get.toNamed(VirtualAssetsScreen.route);
                    } else {
                      Get.toNamed(LoginScreen.route);
                    }
                  },
                  child: Row(
                    children: [
                      Image.asset(height: 25, 'assets/icons/ebook.png'),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        AppStrings.eBooks.tr,
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF2A3032), fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      profileController.selectedLAnguage.value == 'English' ?
                      Image.asset(
                        'assets/images/forward_icon.png',
                        height: 17,
                        width: 17,
                      ) :
                      Image.asset(
                        'assets/images/back_icon_new.png',
                        height: 17,
                        width: 17,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  thickness: 1,
                  color: Color(0x1A000000),
                ),
                const SizedBox(
                  height: 5,
                ),
                InkWell(
                  onTap: () {
                    if (profileController.userLoggedIn) {
                      Get.toNamed(MyOrdersScreen.route);
                    } else {
                      Get.toNamed(LoginScreen.route);
                    }
                  },
                  child: Row(
                    children: [
                      Image.asset(height: 25, 'assets/icons/order.png'),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        AppStrings.orders.tr,
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF2A3032), fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      profileController.selectedLAnguage.value == 'English' ?
                      Image.asset(
                        'assets/images/forward_icon.png',
                        height: 17,
                        width: 17,
                      ) :
                      Image.asset(
                        'assets/images/back_icon_new.png',
                        height: 17,
                        width: 17,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  thickness: 1,
                  color: Color(0x1A000000),
                ),

                const SizedBox(
                  height: 5,
                ),
                InkWell(
                  onTap: () {
                    if (profileController.userLoggedIn) {
                      whatsapp();
                    } else {
                      whatsapp();
                    }
                  },
                  child: Row(
                    children: [
                      Image.asset(height: 25, 'assets/images/whatsapp_icon.png'),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        "WhatsApp Support".tr,
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF2A3032), fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      profileController.selectedLAnguage.value == 'English' ?
                      Image.asset(
                        'assets/images/forward_icon.png',
                        height: 17,
                        width: 17,
                      ) :
                      Image.asset(
                        'assets/images/back_icon_new.png',
                        height: 17,
                        width: 17,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  thickness: 1,
                  color: Color(0x1A000000),
                ),
                const SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Get.to(()=>const GetJobTypeScreen());
                  },
                  child: Row(
                    children: [
                      Image.asset(height: 24, 'assets/images/job_icon.png'),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        'Jobs'.tr,
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF2A3032), fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      profileController.selectedLAnguage.value == 'English' ?
                      Image.asset(
                        'assets/images/forward_icon.png',
                        height: 17,
                        width: 17,
                      ) :
                      Image.asset(
                        'assets/images/back_icon_new.png',
                        height: 17,
                        width: 17,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  thickness: 1,
                  color: Color(0x1A000000),
                ),
                const SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Get.toNamed(PublishPostScreen.route);
                  },
                  child: Row(
                    children: [
                      Image.asset(height: 24, 'assets/icons/send_icon.png'),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        'News Feed'.tr,
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF2A3032), fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      profileController.selectedLAnguage.value == 'English' ?
                      Image.asset(
                        'assets/images/forward_icon.png',
                        height: 17,
                        width: 17,
                      ) :
                      Image.asset(
                        'assets/images/back_icon_new.png',
                        height: 17,
                        width: 17,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  thickness: 1,
                  color: Color(0x1A000000),
                ),
                const SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Get.toNamed(FrequentlyAskedQuestionsScreen.route);
                  },
                  child: Row(
                    children: [
                      Image.asset(height: 25, 'assets/icons/faq.png'),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        AppStrings.faq.tr,
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF2A3032), fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      profileController.selectedLAnguage.value == 'English' ?
                      Image.asset(
                        'assets/images/forward_icon.png',
                        height: 17,
                        width: 17,
                      ) :
                      Image.asset(
                        'assets/images/back_icon_new.png',
                        height: 17,
                        width: 17,
                      ),
                    ],
                  ),
                ),
                // const SizedBox(
                //   height: 5,
                // ),
                // const Divider(
                //   thickness: 1,
                //   color: Color(0x1A000000),
                // ),
                // const SizedBox(
                //   height: 5,
                // ),
                // GestureDetector(
                //   behavior: HitTestBehavior.translucent,
                //   onTap: () {},
                //   child: Row(
                //     children: [
                //       Image.asset(height: 25, 'assets/images/digitalreader.png'),
                //       const SizedBox(
                //         width: 20,
                //       ),
                //       Text(
                //         AppStrings.pdfReader.tr,
                //         style: GoogleFonts.poppins(
                //             color: const Color(0xFF2A3032), fontSize: 16, fontWeight: FontWeight.w500),
                //       ),
                //       const Spacer(),
                //       const Icon(
                //         Icons.arrow_forward_ios,
                //         size: 15,
                //       ),
                //     ],
                //   ),
                // ),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  thickness: 1,
                  color: Color(0x1A000000),
                ),
                ...vendorPartner(),
                const Divider(
                  thickness: 1,
                  color: Color(0x1A000000),
                ),
                const SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (userLoggedIn) {
                      cartController.getAddress();
                      cartController.addressLoaded == true
                          ? bottomSheetChangeAddress()
                          : const CircularProgressIndicator();
                    } else {
                      // addAddressWithoutLogin(addressData: cartController.selectedAddress);
                      Get.toNamed(LoginScreen.route);
                    }
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/address.svg',
                        height: 24,
                        width: 24,
                        color: Colors.black,
                      ),
                      //  SvgPicture.asset(height: 24, 'assets/images/referral_email.png'),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        AppStrings.address.tr,
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF2A3032), fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      profileController.selectedLAnguage.value == 'English' ?
                      Image.asset(
                        'assets/images/forward_icon.png',
                        height: 17,
                        width: 17,
                      ) :
                      Image.asset(
                        'assets/images/back_icon_new.png',
                        height: 17,
                        width: 17,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  thickness: 1,
                  color: Color(0x1A000000),
                ),
                const SizedBox(
                  height: 5,
                ),

                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return Container(
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                              child: Obx(() {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                                      child: Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(color: const Color(0xffDCDCDC)),
                                              borderRadius: BorderRadius.circular(15)),
                                          child: RadioListTile(
                                            title: Text('English'.tr),
                                            activeColor: const Color(0xff014E70),
                                            value: "English",
                                            groupValue: profileController.selectedLAnguage.value,
                                            onChanged: (value) {
                                              locale = const Locale('en', 'US');
                                              profileController.selectedLAnguage.value = value!;
                                              updateLanguage("English");
                                              setState(() {});
                                            },
                                          )),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20, right: 20),
                                      child: Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(color: const Color(0xffDCDCDC)),
                                              borderRadius: BorderRadius.circular(15)),
                                          child: RadioListTile(
                                            title: Text('Arabic'.tr),
                                            activeColor: const Color(0xff014E70),
                                            value: "عربي",
                                            groupValue: profileController.selectedLAnguage.value,
                                            onChanged: (value) {
                                              locale = const Locale('ar', 'AR');
                                              profileController.selectedLAnguage.value = value!;
                                              updateLanguage("عربي");
                                              setState(() {});
                                            },
                                          )),
                                    ),

                                    // const SizedBox(
                                    //   height: 10,
                                    // ),
                                    // Padding(
                                    //     padding: const EdgeInsets.only(left: 20, right: 20),
                                    //     child: Container(
                                    //         decoration: BoxDecoration(
                                    //             border: Border.all(color: const Color(0xffDCDCDC)),
                                    //             borderRadius: BorderRadius.circular(15)),
                                    //         child: RadioListTile(
                                    //           title: const Text('Several languages'),
                                    //           activeColor: const Color(0xff014E70),
                                    //           value: "Several languages",
                                    //           groupValue: language.value,
                                    //           onChanged: (value) {
                                    //             print(selectedLAnguage.value.toString());
                                    //             setState(() {
                                    //               language.value = value!;
                                    //             });
                                    //           },
                                    //         ))),
                                    SizedBox(
                                      height: size.height * .08,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Get.updateLocale(locale);
                                        Get.back();
                                      },
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                                          child: Container(
                                            height: 56,
                                            width: MediaQuery.sizeOf(context).width,
                                            color: const Color(0xff014E70),
                                            child: Center(
                                              child: Text(
                                                'Apply'.tr,
                                                style: GoogleFonts.poppins(
                                                    fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              }));
                        });
                  },
                  child: Row(
                    children: [
                      Image.asset(height: 25, 'assets/icons/language.png'),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        AppStrings.language.tr,
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF2A3032), fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      profileController.selectedLAnguage.value == 'English' ?
                      Image.asset(
                        'assets/images/forward_icon.png',
                        height: 17,
                        width: 17,
                      ) :
                      Image.asset(
                        'assets/images/back_icon_new.png',
                        height: 17,
                        width: 17,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  thickness: 1,
                  color: Color(0x1A000000),
                ),
                const SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Get.toNamed(AboutUsScreen.route);
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset(height: 24, 'assets/svgs/about.svg'),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        AppStrings.aboutUs.tr,
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF2A3032), fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      profileController.selectedLAnguage.value == 'English' ?
                      Image.asset(
                        'assets/images/forward_icon.png',
                        height: 17,
                        width: 17,
                      ) :
                      Image.asset(
                        'assets/images/back_icon_new.png',
                        height: 17,
                        width: 17,
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  thickness: 1,
                  color: Color(0x1A000000),
                ),
                const SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Get.to(() => const ContactUsScreen());
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/contactUs.svg',
                        height: 24,
                        width: 24,
                      ),
                      //  SvgPicture.asset(height: 24, 'assets/images/referral_email.png'),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        AppStrings.contactUs.tr,
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF2A3032), fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      profileController.selectedLAnguage.value == 'English' ?
                      Image.asset(
                        'assets/images/forward_icon.png',
                        height: 17,
                        width: 17,
                      ) :
                      Image.asset(
                        'assets/images/back_icon_new.png',
                        height: 17,
                        width: 17,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  thickness: 1,
                  color: Color(0x1A000000),
                ),
                const SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Get.toNamed(TermConditionScreen.route);
                  },
                  child: Row(
                    children: [
                      Image.asset(height: 25, 'assets/icons/termscondition.png'),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        AppStrings.termsCondition.tr,
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF2A3032), fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      profileController.selectedLAnguage.value == 'English' ?
                      Image.asset(
                        'assets/images/forward_icon.png',
                        height: 17,
                        width: 17,
                      ) :
                      Image.asset(
                        'assets/images/back_icon_new.png',
                        height: 17,
                        width: 17,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  thickness: 1,
                  color: Color(0x1A000000),
                ),
                const SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Get.toNamed(ReturnPolicyScreen.route);
                  },
                  child: Row(
                    children: [
                      Image.asset(height: 18, 'assets/icons/policy.png'),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        AppStrings.returnPolicy.tr,
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF2A3032), fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      profileController.selectedLAnguage.value == 'English' ?
                      Image.asset(
                        'assets/images/forward_icon.png',
                        height: 17,
                        width: 17,
                      ) :
                      Image.asset(
                        'assets/images/back_icon_new.png',
                        height: 17,
                        width: 17,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  thickness: 1,
                  color: Color(0x1A000000),
                ),
                profileController.userLoggedIn
                    ? ListTile(
                        onTap: () {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: Text('Delete Account'.tr),
                              content: Text('Do you want to delete your account'.tr),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: Text('Cancel'.tr),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (profileController.userLoggedIn) {
                                      repositories
                                          .postApi(url: ApiUrls.deleteUser, context: context)
                                          .then((value) async {
                                        deleteModal.value = UserDeleteModel.fromJson(jsonDecode(value));
                                        if (deleteModal.value.status == true) {
                                          SharedPreferences shared = await SharedPreferences.getInstance();
                                          await shared.clear();
                                          Get.back();
                                          setState(() {});
                                          Get.toNamed(LoginScreen.route);
                                          profileController.userLoggedIn = false;
                                          profileController.updateUI();
                                          profileController.getDataProfile();
                                          cartController.getCart();
                                          homeController.getAll();
                                        }
                                      });
                                    } else {
                                      showToast("Login first");
                                      // Get.toNamed(LoginScreen.route);
                                    }
                                  },
                                  child: Text('OK'.tr),
                                ),
                              ],
                            ),
                          );
                        },
                        dense: true,
                        minLeadingWidth: 0,
                        contentPadding: EdgeInsets.zero,
                        minVerticalPadding: 0,
                        visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                        title: Row(
                          children: [
                            Image.asset(height: 25, 'assets/icons/drawerprofile.png'),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: Text(
                                AppStrings.deleteAccount.tr,
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF2A3032), fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                            profileController.selectedLAnguage.value == 'English' ?
                            Image.asset(
                              'assets/images/forward_icon.png',
                              height: 17,
                              width: 17,
                            ) :
                            Image.asset(
                              'assets/images/back_icon_new.png',
                              height: 17,
                              width: 17,
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
                profileController.userLoggedIn
                    ? const SizedBox(
                        height: 5,
                      )
                    : const SizedBox.shrink(),
                profileController.userLoggedIn
                    ? const Divider(
                        thickness: 1,
                        color: Color(0x1A000000),
                      )
                    : const SizedBox.shrink(),
                const SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () async {
                    if (profileController.userLoggedIn) {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text('Logout Account'.tr),
                          content: Text('Do you want to logout your account'.tr),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text('Cancel'.tr),
                            ),
                            TextButton(
                              onPressed: () async {
                                if (profileController.userLoggedIn) {
                                  SharedPreferences shared = await SharedPreferences.getInstance();
                                  await shared.clear();
                                  setState(() {});
                                  Get.back();
                                  Get.toNamed(LoginScreen.route);
                                  profileController.userLoggedIn = false;
                                  profileController.updateUI();
                                  profileController.getDataProfile();
                                  cartController.getCart();
                                  homeController.getAll();
                                } else {
                                  showToast("Login first".tr);
                                  // Get.toNamed(LoginScreen.route);
                                }
                              },
                              child: Text('OK'.tr),
                            ),
                          ],
                        ),
                      );
                    } else {
                      Get.toNamed(LoginScreen.route);
                    }
                  },
                  child: Row(
                    children: [
                      Image.asset(height: 25, 'assets/icons/signout.png'),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        profileController.userLoggedIn ? AppStrings.signOut.tr : AppStrings.login.tr,
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF2A3032), fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      profileController.selectedLAnguage.value == 'English' ?
                      Image.asset(
                        'assets/images/forward_icon.png',
                        height: 17,
                        width: 17,
                      ) :
                      Image.asset(
                        'assets/images/back_icon_new.png',
                        height: 17,
                        width: 17,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
              ]),
            ),
          ],
        ),
      ),
    ));
  }

  Future bottomSheetChangeAddress() {
    Size size = MediaQuery.of(context).size;
    cartController.getAddress();
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(20).copyWith(top: 10),
            child: SizedBox(
                width: size.width,
                height: size.height * .88,
                child:
                    // cartController.addressListModel.status == true ?
                    Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 6,
                          decoration:
                              BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(100)),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CommonTextField(
                      onTap: () {
                        // bottomSheet();
                      },
                      obSecure: false,
                      hintText: '+ Add Address',
                    ),
                    Expanded(
                      child: Obx(() {
                        if (cartController.refreshInt11.value > 0) {}
                        List<AddressData> shippingAddress = cartController.addressListModel.address!.shipping ?? [];
                        return CustomScrollView(
                          shrinkWrap: true,
                          slivers: [
                            SliverToBoxAdapter(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Shipping Address",
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 16),
                                    ),
                                  ),
                                  TextButton.icon(
                                      onPressed: () {
                                        bottomSheet(addressData: AddressData());
                                      },
                                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                      icon: const Icon(
                                        Icons.add,
                                        size: 20,
                                      ),
                                      label: Text(
                                        "Add New",
                                        style: GoogleFonts.poppins(fontSize: 15),
                                      ))
                                ],
                              ),
                            ),
                            const SliverPadding(padding: EdgeInsets.only(top: 4)),
                            shippingAddress.isNotEmpty
                                ? SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                    childCount: shippingAddress.length,
                                    (context, index) {
                                      final address = shippingAddress[index];
                                      return GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          cartController.selectedAddress = address;
                                          Get.back();
                                          setState(() {});
                                        },
                                        child: Container(
                                          width: size.width,
                                          margin: const EdgeInsets.only(bottom: 15),
                                          padding: const EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: const Color(0xffDCDCDC))),
                                          child: IntrinsicHeight(
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Icon(Icons.location_on_rounded),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    address.getCompleteAddressInFormat,
                                                    style: GoogleFonts.poppins(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 15,
                                                        color: const Color(0xff585858)),
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    PopupMenuButton(
                                                        color: Colors.white,
                                                        iconSize: 20,
                                                        icon: const Icon(
                                                          Icons.more_vert,
                                                          color: Colors.black,
                                                        ),
                                                        padding: EdgeInsets.zero,
                                                        onSelected: (value) {
                                                          setState(() {});
                                                          Navigator.pushNamed(context, value.toString());
                                                        },
                                                        itemBuilder: (ac) {
                                                          return [
                                                            PopupMenuItem(
                                                              onTap: () {
                                                                bottomSheet(addressData: address);
                                                              },
                                                              // value: '/Edit',
                                                              child: Text("Edit".tr),
                                                            ),
                                                            PopupMenuItem(
                                                              onTap: () {
                                                                cartController.selectedAddress = address;
                                                                cartController.countryName.value =
                                                                    address.country.toString();
                                                                cartController.countryId =
                                                                    address.getCountryId.toString();
                                                                cartController.getCart();
                                                                print(
                                                                    'onTap is....${cartController.countryName.value}');
                                                                print(
                                                                    'onTap is....${cartController.selectedAddress.id.toString()}');
                                                                if (cartController.isDelivery.value == true) {
                                                                  cartController.addressDeliFirstName.text =
                                                                      cartController.selectedAddress.getFirstName;
                                                                  cartController.addressDeliLastName.text =
                                                                      cartController.selectedAddress.getLastName;
                                                                  cartController.addressDeliEmail.text =
                                                                      cartController.selectedAddress.getEmail;
                                                                  cartController.addressDeliPhone.text =
                                                                      cartController.selectedAddress.getPhone;
                                                                  cartController.addressDeliAlternate.text =
                                                                      cartController.selectedAddress.getAlternate;
                                                                  cartController.addressDeliAddress.text =
                                                                      cartController.selectedAddress.getAddress;
                                                                  cartController.addressDeliZipCode.text =
                                                                      cartController.selectedAddress.getZipCode;
                                                                  cartController.addressCountryController.text =
                                                                      cartController.selectedAddress.getCountry;
                                                                  cartController.addressStateController.text =
                                                                      cartController.selectedAddress.getState;
                                                                  cartController.addressCityController.text =
                                                                      cartController.selectedAddress.getCity;
                                                                }

                                                                defaultAddressApi();
                                                                setState(() {});
                                                              },
                                                              // value: '/slotViewScreen',
                                                              child: Text("Default Address".tr),
                                                            ),
                                                            PopupMenuItem(
                                                              onTap: () {
                                                                cartController
                                                                    .deleteAddress(
                                                                  context: context,
                                                                  id: address.id.toString(),
                                                                )
                                                                    .then((value) {
                                                                  if (value == true) {
                                                                    cartController.addressListModel.address!.shipping!
                                                                        .removeWhere((element) =>
                                                                            element.id.toString() ==
                                                                            address.id.toString());
                                                                    cartController.updateUI();
                                                                  }
                                                                });
                                                              },
                                                              // value: '/deactivate',
                                                              child: Text("Delete".tr),
                                                            )
                                                          ];
                                                        }),
                                                    address.isDefault == true
                                                        ? Text(
                                                            "Default",
                                                            style: GoogleFonts.poppins(
                                                                fontWeight: FontWeight.w500,
                                                                fontSize: 15,
                                                                color: const Color(0xff585858)),
                                                          )
                                                        : const SizedBox(),
                                                  ],
                                                ),
                                                // Column(
                                                //   children: [
                                                //     Flexible(
                                                //       child: IconButton(
                                                //           onPressed: () {
                                                //             cartController
                                                //                 .deleteAddress(
                                                //               context: context,
                                                //               id: address.id.toString(),
                                                //             )
                                                //                 .then((value) {
                                                //               if (value == true) {
                                                //                 cartController.addressListModel.address!.shipping!
                                                //                     .removeWhere((element) =>
                                                //                         element.id.toString() == address.id.toString());
                                                //                 cartController.updateUI();
                                                //               }
                                                //             });
                                                //           },
                                                //           icon: const Icon(Icons.delete)),
                                                //     ),
                                                //     InkWell(
                                                //       onTap: () {
                                                //         bottomSheet(addressData: address);
                                                //       },
                                                //       child: Text(
                                                //         'Edit',
                                                //         style: GoogleFonts.poppins(
                                                //             shadows: [
                                                //               const Shadow(
                                                //                   color: Color(0xff014E70), offset: Offset(0, -4))
                                                //             ],
                                                //             color: Colors.transparent,
                                                //             fontSize: 16,
                                                //             fontWeight: FontWeight.w500,
                                                //             decoration: TextDecoration.underline,
                                                //             decorationColor: const Color(0xff014E70)),
                                                //       ),
                                                //     ),
                                                //   ],
                                                // )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ))
                                : SliverToBoxAdapter(
                                    child: Text(
                                      "No Shipping Address Added!",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 16),
                                    ),
                                  ),
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: MediaQuery.of(context).viewInsets.bottom,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                )
                // : const LoadingAnimation(),
                ),
          );
        });
  }

  Future bottomSheet({required AddressData addressData}) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        builder: (context12) {
          return EditAddressSheet(
            addressData: addressData,
          );
        });
  }

  Future addAddressWithoutLogin({required AddressData addressData}) {
    Size size = MediaQuery.of(context).size;
    final TextEditingController firstNameController = TextEditingController(text: addressData.firstName ?? "");
    final TextEditingController emailController = TextEditingController(text: addressData.email ?? "");
    final TextEditingController lastNameController = TextEditingController(text: addressData.lastName ?? "");
    final TextEditingController phoneController = TextEditingController(text: addressData.phone ?? "");
    final TextEditingController alternatePhoneController =
        TextEditingController(text: addressData.alternatePhone ?? "");
    final TextEditingController addressController = TextEditingController(text: addressData.address ?? "");
    final TextEditingController address2Controller = TextEditingController(text: addressData.address2 ?? "");
    final TextEditingController cityController = TextEditingController(text: addressData.city ?? "");
    final TextEditingController countryController = TextEditingController(text: addressData.country ?? "");
    final TextEditingController stateController = TextEditingController(text: addressData.state ?? "");
    final TextEditingController zipCodeController = TextEditingController(text: addressData.zipCode ?? "");
    final TextEditingController landmarkController = TextEditingController(text: addressData.landmark ?? "");
    final TextEditingController titleController = TextEditingController(text: addressData.type ?? "");

    final formKey = GlobalKey<FormState>();
    String code = 'KW';
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: size.width,
              height: size.height * .8,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...commonField(
                          textController: titleController,
                          title: "Title*",
                          hintText: "Title",
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return "Please enter address title";
                            }
                            return null;
                          }),
                      ...commonField(
                          textController: emailController,
                          title: "Email Address*",
                          hintText: "Email Address",
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return "Please enter email address";
                            }
                            if (value.trim().invalidEmail) {
                              return "Please enter valid email address";
                            }
                            return null;
                          }),
                      ...commonField(
                          textController: firstNameController,
                          title: "First Name*",
                          hintText: "First Name",
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return "Please enter first name";
                            }
                            return null;
                          }),
                      ...commonField(
                          textController: lastNameController,
                          title: "Last Name*",
                          hintText: "Last Name",
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return "Please enter Last name";
                            }
                            return null;
                          }),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Phone *'.tr,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500, fontSize: 16, color: const Color(0xff585858)),
                      ),
                      const SizedBox(
                        height: 8,
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
                        controller: alternatePhoneController,
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            hintStyle: TextStyle(color: AppTheme.textColor),
                            hintText: 'Enter your phone number',
                            labelStyle: TextStyle(color: AppTheme.textColor),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(),
                            ),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.shadowColor)),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.shadowColor))),
                        initialCountryCode: profileController.code.toString(),
                        languageCode:  profileController.code,
                        onCountryChanged: (phone) {
                          profileController.code = phone.code;
                          print(phone.code);
                          print(profileController.code.toString());
                        },
                        onChanged: (phone) {
                          profileController.code = phone.countryISOCode.toString();
                          print(phone.countryCode);
                          print(profileController.code.toString());
                        },
                      ),
                      // ...commonField(
                      //     textController: phoneController,
                      //     title: "Phone*",
                      //     hintText: "Enter your phone number",
                      //     keyboardType: TextInputType.number,
                      //     validator: (value) {
                      //       if (value!.trim().isEmpty) {
                      //         return "Please enter phone number";
                      //       }
                      //       if (value.trim().length > 15) {
                      //         return "Please enter valid phone number";
                      //       }
                      //       if (value.trim().length < 8) {
                      //         return "Please enter valid phone number";
                      //       }
                      //       return null;
                      //     }),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Alternate Phone*'.tr,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500, fontSize: 16, color: const Color(0xff585858)),
                      ),
                      const SizedBox(
                        height: 8,
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

                        controller: alternatePhoneController,
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            hintStyle: TextStyle(color: AppTheme.textColor),
                            hintText: 'Enter your phone number',
                            labelStyle: TextStyle(color: AppTheme.textColor),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(),
                            ),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.shadowColor)),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.shadowColor))),
                        initialCountryCode: code.toString(),
                        languageCode:  profileController.code,
                        onCountryChanged: (phone) {
                          code = phone.code;
                          print(phone.code);
                          print(code.toString());
                        },
                        onChanged: (phone) {
                          code = phone.countryISOCode.toString();
                          print(phone.countryCode);
                          print(code.toString());
                        },
                      ),

                      // ...commonField(
                      //     textController: alternatePhoneController,
                      //     title: "Alternate Phone*",
                      //     hintText: "Enter your alternate phone number",
                      //     keyboardType: TextInputType.number,
                      //     validator: (value) {
                      //       // if(value!.trim().isEmpty){
                      //       //   return "Please enter phone number";
                      //       // }
                      //       // if(value.trim().length > 15){
                      //       //   return "Please enter valid phone number";
                      //       // }
                      //       // if(value.trim().length < 8){
                      //       //   return "Please enter valid phone number";
                      //       // }
                      //       return null;
                      //     }),
                      ...commonField(
                          textController: addressController,
                          title: "Address*",
                          hintText: "Enter your delivery address",
                          keyboardType: TextInputType.streetAddress,
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return "Please enter delivery address";
                            }
                            return null;
                          }),
                      ...commonField(
                          textController: address2Controller,
                          title: "Address 2",
                          hintText: "Enter your delivery address",
                          keyboardType: TextInputType.streetAddress,
                          validator: (value) {
                            // if(value!.trim().isEmpty){
                            //   return "Please enter delivery address";
                            // }
                            return null;
                          }),
                      ...fieldWithName(
                        title: 'Country/Region',
                        hintText: 'Select Country',
                        readOnly: true,
                        onTap: () {
                          showAddressSelectorDialog(
                              addressList: modelCountryList!.country!
                                  .map((e) => CommonAddressRelatedClass(
                                      title: e.name.toString(), addressId: e.id.toString(), flagUrl: e.icon.toString()))
                                  .toList(),
                              selectedAddressIdPicked: (String gg) {
                                String previous = ((selectedCountry ?? Country()).id ?? "").toString();
                                selectedCountry =
                                    modelCountryList!.country!.firstWhere((element) => element.id.toString() == gg);
                                cartController.countryCode = gg.toString();
                                cartController.countryName.value = selectedCountry!.name.toString();
                                print('countrrtr ${cartController.countryName.toString()}');
                                print('countrrtr ${cartController.countryCode.toString()}');
                                if (previous != selectedCountry!.id.toString()) {
                                  countryIddd = gg.toString();
                                  getStateList(countryId: countryIddd.toString(), reset: true).then((value) {
                                    setState(() {});
                                  });
                                  setState(() {});
                                }
                              },
                              selectedAddressId: ((selectedCountry ?? Country()).id ?? "").toString());
                        },
                        controller:
                            TextEditingController(text: (selectedCountry ?? Country()).name ?? countryController.text),
                        validator: (v) {
                          if (v!.trim().isEmpty) {
                            return "Please select country";
                          }
                          return null;
                        },
                      ),
                      ...fieldWithName(
                        title: 'State',
                        hintText: 'Select State',
                        controller: TextEditingController(
                            text: (selectedState ?? CountryState()).stateName ?? stateController.text),
                        readOnly: true,
                        onTap: () {
                          if (countryIddd == 'null') {
                            showToast("Select Country First");
                            return;
                          }
                          if (modelStateList == null && stateRefresh.value > 0) {
                            showToast("Select Country First");
                            return;
                          }
                          if (stateRefresh.value < 0) {
                            return;
                          }
                          if (modelStateList!.state!.isEmpty) return;
                          showAddressSelectorDialog(
                              addressList: profileController.selectedLAnguage.value == 'English'
                                  ? modelStateList!.state!
                                      .map((e) => CommonAddressRelatedClass(
                                          title: e.stateName.toString(), addressId: e.stateId.toString()))
                                      .toList()
                                  : modelStateList!.state!
                                      .map((e) => CommonAddressRelatedClass(
                                          title: e.arabStateName.toString(), addressId: e.stateId.toString()))
                                      .toList(),
                              selectedAddressIdPicked: (String gg) {
                                String previous = ((selectedState ?? CountryState()).stateId ?? "").toString();
                                selectedState =
                                    modelStateList!.state!.firstWhere((element) => element.stateId.toString() == gg);
                                cartController.stateCode = gg.toString();
                                cartController.stateName.value = selectedState!.stateName.toString();
                                print('state ${cartController.stateCode.toString()}');
                                print('stateNameee ${cartController.stateName.toString()}');
                                if (previous != selectedState!.stateId.toString()) {
                                  stateIddd = gg.toString();
                                  getCityList(stateId: stateIddd.toString(), reset: true).then((value) {
                                    setState(() {});
                                  });
                                  setState(() {});
                                }
                              },
                              selectedAddressId: ((selectedState ?? CountryState()).stateId ?? "").toString());
                        },
                        suffixIcon: Obx(() {
                          if (stateRefresh.value > 0) {
                            return const Icon(Icons.keyboard_arrow_down_rounded);
                          }
                          return const CupertinoActivityIndicator();
                        }),
                        validator: (v) {
                          if (v!.trim().isEmpty) {
                            return "Please select state";
                          }
                          return null;
                        },
                      ),
                      // if (modelCityList != null && modelCityList!.city!.isNotEmpty)
                      ...fieldWithName(
                        readOnly: true,
                        title: 'City',
                        hintText: 'Select City',
                        controller:
                            TextEditingController(text: (selectedCity ?? City()).cityName ?? cityController.text),
                        onTap: () {
                          if (modelCityList == null && cityRefresh.value > 0) {
                            showToast("Select State First");
                            return;
                          }
                          if (cityRefresh.value < 0) {
                            return;
                          }
                          if (modelCityList!.city!.isEmpty) return;
                          showAddressSelectorDialog(
                              addressList: profileController.selectedLAnguage.value == 'English'
                                  ? modelCityList!.city!
                                      .map((e) => CommonAddressRelatedClass(
                                          title: e.cityName.toString(), addressId: e.cityId.toString()))
                                      .toList()
                                  : modelCityList!.city!
                                      .map((e) => CommonAddressRelatedClass(
                                          title: e.arabCityName.toString(), addressId: e.cityId.toString()))
                                      .toList(),
                              selectedAddressIdPicked: (String gg) {
                                selectedCity =
                                    modelCityList!.city!.firstWhere((element) => element.cityId.toString() == gg);
                                cartController.cityCode = gg.toString();
                                cartController.cityName.value = selectedCity!.cityName.toString();
                                print('state ${cartController.cityName.toString()}');
                                print('state Nameee ${cartController.cityCode.toString()}');
                                setState(() {});
                              },
                              selectedAddressId: ((selectedCity ?? City()).cityId ?? "").toString());
                        },
                        suffixIcon: Obx(() {
                          if (cityRefresh.value > 0) {
                            return const Icon(Icons.keyboard_arrow_down_rounded);
                          }
                          return const CupertinoActivityIndicator();
                        }),
                        validator: (v) {
                          if (v!.trim().isEmpty) {
                            return "Please select state";
                          }
                          return null;
                        },
                      ),
                      if (cartController.countryName.value != 'Kuwait')
                        ...commonField(
                            textController: zipCodeController,
                            title: "Zip-Code*",
                            hintText: "Enter location Zip-Code",
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.trim().isEmpty) {
                                return "Please enter Zip-Code*";
                              }
                              return null;
                            }),
                      if (cartController.countryName.value != 'Kuwait')
                        ...commonField(
                            textController: landmarkController,
                            title: "Landmark",
                            hintText: "Enter your nearby landmark",
                            keyboardType: TextInputType.streetAddress,
                            validator: (value) {
                              // if(value!.trim().isEmpty){
                              //   return "Please enter delivery address";
                              // }
                              return null;
                            }),
                      const SizedBox(
                        height: 16,
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          if (formKey.currentState!.validate()) {
                            cartController.selectedAddress = AddressData(
                                id: "",
                                type: titleController.text.trim(),
                                firstName: firstNameController.text.trim(),
                                lastName: lastNameController.text.trim(),
                                state: stateController.text.trim(),
                                country: countryController.text.trim(),
                                city: cityController.text.trim(),
                                address2: address2Controller.text.trim(),
                                address: addressController.text.trim(),
                                alternatePhone: alternatePhoneController.text.trim(),
                                landmark: landmarkController.text.trim(),
                                phone: phoneController.text.trim(),
                                zipCode: zipCodeController.text.trim(),
                                email: emailController.text.trim(),
                                phoneCountryCode: profileController.code.toString());
                            setState(() {});
                            Get.back();
                            // cartController.updateAddressApi(
                            //     context: context,
                            //     firstName: firstNameController.text.trim(),
                            //     title: titleController.text.trim(),
                            //     lastName: lastNameController.text.trim(),
                            //     state: stateController.text.trim(),
                            //     country: countryController.text.trim(),
                            //     city: cityController.text.trim(),
                            //     address2: address2Controller.text.trim(),
                            //     address: addressController.text.trim(),
                            //     alternatePhone: alternatePhoneController.text.trim(),
                            //     landmark: landmarkController.text.trim(),
                            //     phone: phoneController.text.trim(),
                            //     zipCode: zipCodeController.text.trim(),
                            //     id: addressData.id);
                          }
                        },
                        child: Container(
                          decoration: const BoxDecoration(color: Color(0xff014E70)),
                          height: 56,
                          alignment: Alignment.bottomCenter,
                          child: Align(
                              alignment: Alignment.center,
                              child: Text("Save",
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500, fontSize: 19, color: Colors.white))),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  showAddressSelectorDialog({
    required List<CommonAddressRelatedClass> addressList,
    required String selectedAddressId,
    required Function(String selectedId) selectedAddressIdPicked,
  }) {
    FocusManager.instance.primaryFocus!.unfocus();
    final TextEditingController searchController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            insetPadding: const EdgeInsets.all(18),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: StatefulBuilder(builder: (context, newState) {
                String gg = searchController.text.trim().toLowerCase();
                List<CommonAddressRelatedClass> filteredList =
                    addressList.where((element) => element.title.toString().toLowerCase().contains(gg)).toList();
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: searchController,
                      onChanged: (gg) {
                        newState(() {});
                      },
                      autofocus: true,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.buttonColor, width: 1.2)),
                          enabled: true,
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.buttonColor, width: 1.2)),
                          suffixIcon: const Icon(Icons.search),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                    ),
                    Flexible(
                        child: ListView.builder(
                            itemCount: filteredList.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return ListTile(
                                // dense: true,
                                onTap: () {
                                  selectedAddressIdPicked(filteredList[index].addressId);
                                  FocusManager.instance.primaryFocus!.unfocus();
                                  Get.back();
                                },
                                leading: filteredList[index].flagUrl != null
                                    ? SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: filteredList[index].flagUrl.toString().contains("svg")
                                            ? SvgPicture.network(
                                                filteredList[index].flagUrl.toString(),
                                              )
                                            : Image.network(
                                                filteredList[index].flagUrl.toString(),
                                                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                              ))
                                    : null,
                                visualDensity: VisualDensity.compact,
                                title: Text(filteredList[index].title),
                                trailing: selectedAddressId == filteredList[index].addressId
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.purple,
                                      )
                                    :  Image.asset(
                                  'assets/images/forward_icon.png',
                                  height: 17,
                                  width: 17,
                                )
                              );
                            }))
                  ],
                );
              }),
            ),
          );
        });
  }

  List<Widget> vendorPartner() {
    return [
      ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        textColor: AppTheme.primaryColor,
        iconColor: AppTheme.primaryColor,
        minLeadingWidth: 0,
        onTap: () {
          if (userLoggedIn) {
            _isValue.value = !_isValue.value;
            setState(() {});
          } else {
            Get.to(const LoginScreen());
          }
        },
        title: Row(
          children: [
            const Image(
              height: 25,
              image: AssetImage(
                'assets/icons/vendoricon.png',
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: Text(
                AppStrings.vendorPartner.tr,
                style: GoogleFonts.poppins(color: const Color(0xFF2A3032), fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            if( profileController.selectedLAnguage.value == 'English')
              !_isValue.value == true ?   Image.asset(
                'assets/images/forward_icon.png',
                height: 17,
                width: 17,
              ) :
              Image.asset(
                'assets/images/drop_icon.png',
                height: 17,
                width: 17,
              ),
            if( profileController.selectedLAnguage.value != 'English')
              !_isValue.value == true ?
              Image.asset(
                'assets/images/back_icon_new.png',
                height: 17,
                width: 17,
              ) :
              Image.asset(
                'assets/images/drop_icon.png',
                height: 17,
                width: 17,
              ),
          ],
        ),
      ),
      _isValue.value == true
          ? Obx(() {
              if (profileController.refreshInt.value > 0) {}

              return profileController.model.user != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: profileController.model.user!.isVendor == true
                          ? List.generate(
                              vendor.length,
                              (index) => Row(
                                    children: [
                                      const SizedBox(
                                        width: 30,
                                      ),
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () {
                                            print("Index---:${vendor[index]}");
                                            if (vendor[index] == 'Dashboard' && vendorArab[index] == 'لوحة القيادة') {
                                              Get.toNamed( VendorDashBoardScreen.route);
                                            }
                                            else if(vendor[index] == 'Order' && vendorArab[index] == 'طلب'){
                                              Get.to(const VendorOrderList());
                                            }
                                            else if(vendor[index] == 'Pending Products' && vendorArab[index] == 'المنتجات المعلقة'){
                                              Get.to(const VendorProductScreen());
                                            }
                                            else if(vendor[index] == 'Approved Products' && vendorArab[index] == 'المنتجات المعتمدة'){
                                              Get.to(const ApproveProductScreen());
                                            }
                                            else if(vendor[index] == 'Operating Hours' && vendorArab[index] == 'ساعات العمل'){
                                              Get.to(const SetTimeScreen());
                                            }
                                            else if(vendor[index] == 'Bank Details' && vendorArab[index] == 'التفاصيل المصرفية'){
                                              Get.to(const BankDetailsScreen());
                                            }
                                            else if(vendor[index] == 'Earnings' && vendorArab[index] == 'الأرباح'){
                                              Get.to(const WithdrawMoney());
                                            }
                                            else if(vendor[index] == 'Social Media' && vendorArab[index] == 'وسائل التواصل الاجتماعي'){
                                              Get.to(const SocialMediaStoreAccount());
                                            }
                                            else {
                                              showToast('Your payment is not successfull'.tr);
                                            }
                                          },
                                          style: TextButton.styleFrom(
                                              visualDensity: const VisualDensity(vertical: -3, horizontal: -3),
                                              padding: EdgeInsets.zero.copyWith(left: 16)),
                                          child: Row(
                                            children: [
                                              if( profileController.selectedLAnguage.value == 'English')
                                              Expanded(
                                                child: Text(
                                                  vendor[index],
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.grey.shade500),
                                                ),
                                              ),
                                              if( profileController.selectedLAnguage.value != 'English')
                                                Expanded(
                                                  child: Text(
                                                    vendorArab[index],
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w400,
                                                        color: Colors.grey.shade500),
                                                  ),
                                                ),
                                              profileController.selectedLAnguage.value == 'English' ?
                                              Image.asset(
                                                'assets/images/forward_icon.png',
                                                height: 17,
                                                width: 17,
                                              ) :
                                              Image.asset(
                                                'assets/images/back_icon_new.png',
                                                height: 17,
                                                width: 17,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ))
                          : List.generate(
                              vendor1.length,
                              (index) => Row(
                                    children: [
                                      const SizedBox(
                                        width: 30,
                                      ),
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () {
                                            if (vendor1[index] == 'Become a vendor' &&  vendor1Arab[index] == 'كن بائعًا') {
                                              Get.to(()=> const WhichplantypedescribeyouScreen());
                                            }
                                            else if(vendor1[index] == 'Pending Products' && vendor1Arab[index] == 'المنتجات المعلقة'){
                                              Get.to(const VendorProductScreen());
                                            }
                                            else if(vendor1[index] == 'Approved Products' && vendor1Arab[index] == 'المنتجات المعتمدة'){
                                              Get.to(const ApproveProductScreen());
                                            }
                                            else {
                                              showToast('Your payment is not successfull'.tr);
                                            }
                                          },
                                          style: TextButton.styleFrom(
                                              visualDensity: const VisualDensity(vertical: -3, horizontal: -3),
                                              padding: EdgeInsets.zero.copyWith(left: 16)),
                                          child: Row(
                                            children: [
                                              if( profileController.selectedLAnguage.value != 'English')
                                                Expanded(
                                                  child: Text(
                                                    vendor1Arab[index],
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w400,
                                                        color: Colors.grey.shade500),
                                                  ),
                                                ),
                                              if( profileController.selectedLAnguage.value == 'English')
                                              Expanded(
                                                child: Text(
                                                  vendor1[index],
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.grey.shade500),
                                                ),
                                              ),
                                              const Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                size: 14,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                    )
                  : const SizedBox();
            })
          : const SizedBox.shrink()
    ];
  }
}
