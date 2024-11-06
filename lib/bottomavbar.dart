import 'dart:async';
import 'dart:io';
import 'package:dirise/addNewProduct/internationalshippingdetailsScreem.dart';
import 'package:dirise/language/app_strings.dart';
import 'package:dirise/routers/my_routers.dart';
import 'package:dirise/screens/auth_screens/login_screen.dart';
import 'package:dirise/screens/home_pages/coustom_drawer.dart';
import 'package:dirise/screens/home_pages/homepage_screen.dart';
import 'package:dirise/screens/return_policy.dart';
import 'package:dirise/screens/wishlist/whishlist_screen.dart';
import 'package:dirise/utils/api_constant.dart';
import 'package:dirise/utils/helper.dart';
import 'package:dirise/vendor/authentication/vendor_registration_screen.dart';
import 'package:dirise/vendor/dashboard/dashboard_screen.dart';
import 'package:dirise/vendor/shipping_policy.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'addNewProduct/addProductStartScreen.dart';
import 'controller/cart_controller.dart';
import 'controller/home_controller.dart';
import 'controller/homepage_controller.dart';
import 'controller/location_controller.dart';
import 'controller/profile_controller.dart';
import 'newAuthScreens/signupScreen.dart';
import 'screens/categories/categories_screen.dart';
import 'widgets/common_colour.dart';
import 'screens/my_account_screens/myaccount_scrren.dart';

class BottomNavbar extends StatefulWidget {
  static String route = "/BottomNavbar";
  const BottomNavbar({Key? key}) : super(key: key);

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  final bottomController = Get.put(BottomNavBarController());
  final profileController = Get.put(ProfileController());
  final cartController = Get.put(CartController());
  bool get userLoggedIn => profileController.userLoggedIn;
  final pages = [
    const HomePage(),
    const CategoriesScreen(),
    const WishListScreen(),
    const MyAccountScreen(),
  ];

  bool isLoggedIn = false;
  bool allowExitApp = false;
  Timer? _timer;
  final homeController = Get.put(TrendingProductsController());
  @override
  void initState() {
    super.initState();
    profileController.checkLanguage();
    homeController.homeData();
    homeController.getVendorCategories();
    // locationController.checkGps(context);
    checkUser();
    // _showWelcomeDialog();
  }

  final locationController = Get.put(LocationController());

  Future<void> checkUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    isLoggedIn = preferences.getString('login_user') != null;
    if (mounted) setState(() {});
  }

  Future<void> _showWelcomeDialog() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool hasShownDialog = preferences.getBool('hasShownDialog') ?? false;

    if (!hasShownDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await showDialog(
          context: context,
          barrierDismissible:
              false, // Prevents dialog from being dismissed by tapping outside
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async {
                // Prevent back button from dismissing the dialog
                return false;
              },
              child: AlertDialog(
                title: Text("Purpose of collecting location".tr),
                content: Text(
                    "This app collects location data to show your current city and zip code, and also for shipping information, even when the app is closed or not in use."
                        .tr),
                actions: [
                  TextButton(
                    onPressed: () {
                      // Navigator.of(context).pop();
                      // showToast('message');
                      FlutterExitApp.exitApp(iosForceExit: true);
                      // if (Platform.isAndroid) {
                      //   SystemNavigator.pop();
                      // } else if (Platform.isIOS) {
                      //   showToast('message');
                      //   exit(0);
                      // }
                    },
                    child: Text("Exit App".tr),
                  ),
                  TextButton(
                    onPressed: () async {
                      await preferences.setBool('hasShownDialog', true);
                      Navigator.of(context).pop();
                      locationController.checkGps(context);
                    },
                    child: Text("Allow".tr),
                  ),
                ],
              ),
            );
          },
        );
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    stopTimer();
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  bool exitApp() {
    if (allowExitApp) {
      stopTimer();
      hideToast();
      return true;
    }

    allowExitApp = true;
    stopTimer();
    showToast("Press again to exit app".tr, gravity: ToastGravity.CENTER);
    _timer = Timer(const Duration(milliseconds: 500), () {
      allowExitApp = false;
    });
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (bottomController.pageIndex.value != 0) {
          bottomController.pageIndex.value = 0;
          return false;
        } else {
          return exitApp();
        }
      },
      child: Obx(() {
        return Scaffold(
          body: pages[bottomController.pageIndex.value],
          backgroundColor: const Color(0xFFEBF3F6),
          bottomNavigationBar: buildMyNavBar(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Visibility(
            child: GestureDetector(
              onTap: () {
                if (userLoggedIn) {
                  Get.to(const AddProductOptionScreen());
                } else {
                  Get.to(const LoginScreen());
                }
              },
              child: Container(
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                    color: const Color(0xFFEBF3F6),
                    borderRadius: BorderRadius.circular(100)),
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.buttonColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(9.0),
                    child: Center(
                      child:
                          profileController.selectedLAnguage.value == 'English'
                              ? Image.asset(
                                  'assets/images/Sell-White-EN.png',
                                  height: 30,
                                )
                              : Image.asset(
                                  'assets/images/Sell-White-AR.png',
                                  height: 30,
                                ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget buildMyNavBar() {
    const padding = EdgeInsets.only(bottom: 2, top: 3);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SafeArea(
          bottom: true,
          child: Card(
            color: const Color(0xFFEBF3F6),
            elevation: 0,
            child: Column(
              children: [
                const SizedBox(
                  height: 11,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: MaterialButton(
                          padding: padding,
                          onPressed: () {
                            bottomController.updateIndexValue(0);
                          },
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              'assets/images/home_new.png',
                              width: 30,
                              color: bottomController.pageIndex.value == 0
                                  ? AppTheme.buttonColor
                                  : AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: MaterialButton(
                          padding: padding,
                          onPressed: () {
                            bottomController.updateIndexValue(1);
                          },
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              'assets/images/category_new.png',
                              width: 30,
                              color: bottomController.pageIndex.value == 1
                                  ? AppTheme.buttonColor
                                  : AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: MaterialButton(
                          padding: padding,
                          onPressed: () {
                            if (userLoggedIn) {
                              bottomController.updateIndexValue(2);
                              setState(() {});
                            } else {
                              Get.to(const LoginScreen());
                            }
                          },
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              'assets/images/fav_new.png',
                              width: 30,
                              color: bottomController.pageIndex.value == 2
                                  ? AppTheme.buttonColor
                                  : AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: MaterialButton(
                          padding: padding,
                          onPressed: () {
                            bottomController.updateIndexValue(3);
                          },
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              'assets/images/profile_new.png',
                              width: 30,
                              height: 30,
                              color: bottomController.pageIndex.value == 3
                                  ? AppTheme.buttonColor
                                  : AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
