import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dirise/screens/home_pages/star_of_month.dart';
import 'package:dirise/utils/helper.dart';
import 'package:dirise/widgets/common_colour.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controller/cart_controller.dart';
import '../../controller/google_map_controlleer.dart';
import '../../controller/home_controller.dart';
import '../../controller/homepage_controller.dart';
import '../../controller/location_controller.dart';
import '../../controller/profile_controller.dart';
import '../../controller/service_controller.dart';
import '../../language/app_strings.dart';
import '../../model/add_current_address.dart';
import '../../model/common_modal.dart';
import '../../model/error_log_model.dart';
import '../../model/myDefaultAddressModel.dart';
import '../../repository/repository.dart';
import '../../utils/api_constant.dart';
import '../../vendor/authentication/vendor_plans_screen.dart';
import '../../vendor/dashboard/dashboard_screen.dart';
import '../../vendor/dashboard/showcase.dart';
import '../../vendor/dashboard/store_open_time_screen.dart';
import '../../vendor/orders/vendor_order_list_screen.dart';
import '../../vendor/payment_info/bank_account_screen.dart';
import '../../vendor/payment_info/withdrawal_screen.dart';
import '../../vendor/products/all_product_screen.dart';
import '../../widgets/cart_widget.dart';
import '../auth_screens/login_screen.dart';
import '../search_products.dart';
import '../wishlist/whishlist_screen.dart';
import 'ad_banner.dart';
import 'add-edit-address.dart';
import 'addedit_withlogin.dart';
import 'authers.dart';
import 'coustom_drawer.dart';
import 'popular_products.dart';
import 'category_items.dart';
import 'slider.dart';
import 'trending_products.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final homeController = Get.put(TrendingProductsController(), permanent: true);
  final cartController = Get.put(CartController());
  final serviceController = Get.put(ServiceController(), permanent: true);
  final Repositories repositories = Repositories();
  Rx<ErrorLogModel> errorLog = ErrorLogModel().obs;

  errorApi() {
    Map<String, dynamic> map = {
      "type": "home page location",
      "payload": [
        {
          "street": locationController.street.toString(),
          "city": locationController.city.value,
          "state": locationController.state.toString(),
          "country": locationController.countryName.toString(),
          // "country": "Pakistan",
          "zipcode": locationController.zipcode.value.toString(),
          "town": locationController.town.toString(),
        }
      ]
    };
    print(map.toString());
    print("print error log ");
    repositories
        .postApi(
      url: ApiUrls.insertErrorLog,
      mapData: map,
    )
        .then((value) {
      errorLog.value = ErrorLogModel.fromJson(jsonDecode(value));
      showToast(value.message.toString());

      Get.back();
    });
  }

  final Completer<GoogleMapController> googleMapController = Completer();
  GoogleMapController? mapController;
  final bottomController = Get.put(BottomNavBarController());
  String? _address = "";
  Position? _currentPosition;
  LocationPermission? permission;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      profileController.selectedLAnguage.value == "English"
          ? showToast(
              'Location services are disabled. Please enable the services')
          : showToast('خدمات الموقع غير مفعلّة. يرجى تفعيل الخدمات');
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     content: Text(
      //         'Location services are disabled. Please enable the services')));
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks != null && placemarks.isNotEmpty) {
      Placemark placemark = placemarks[0];

      setState(() {
        locationController.zipcode.value = placemark.postalCode ?? '';
        locationController.street = placemark.street ?? '';
        locationController.shortCode.value = placemark.isoCountryCode ?? '';
        locationController.city.value = placemark.locality ?? '';
        locationController.state = placemark.administrativeArea ?? '';
        locationController.countryName = placemark.country ?? '';
        locationController.town = placemark.subAdministrativeArea ?? '';

        //
        controllerMap.street.value = placemark.street ?? '';
        controllerMap.countryCode.value = placemark.isoCountryCode ?? '';
        controllerMap.city.value = placemark.locality ?? '';
        controllerMap.zipcode.value = placemark.postalCode ?? '';
        controllerMap.state.value = placemark.administrativeArea ?? '';
        controllerMap.country.value = placemark.country ?? '';
        controllerMap.town.value = placemark.subAdministrativeArea ?? '';
        // showToast(locationController.countryName.toString());
        // errorApi();
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('street', placemark.street ?? '');
      await prefs.setString('city', placemark.locality ?? '');
      await prefs.setString('state', placemark.administrativeArea ?? '');
      await prefs.setString('country', placemark.country ?? '');
      await prefs.setString('zipcode', placemark.postalCode ?? '');
      await prefs.setString('shortCode', placemark.isoCountryCode ?? '');
      await prefs.setString('town', placemark.subAdministrativeArea ?? '');
    }
    // errorApi();
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _address =
            '${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e.toString());
    });
  }

  Future<void> _loadSavedAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      locationController.street = prefs.getString('street') ?? '';
      locationController.city.value = prefs.getString('city') ?? '';
      locationController.state = prefs.getString('state') ?? '';
      locationController.countryName = prefs.getString('country') ?? '';
      locationController.shortCode.value = prefs.getString('shortCode') ?? '';
      locationController.zipcode.value = prefs.getString('zipcode') ?? '';
      locationController.town = prefs.getString('town') ?? '';
      _address = prefs.getString('address') ?? '';
      cartController.zipCode = prefs.getString('zipcode') ?? '';
      cartController.city.value = prefs.getString('city') ?? '';
      cartController.address.value = prefs.getString('town') ?? '';

      controllerMap.street.value = prefs.getString('street') ?? '';
      controllerMap.countryCode.value = prefs.getString('shortCode') ?? '';
      controllerMap.city.value = prefs.getString('city') ?? '';
      controllerMap.zipcode.value = prefs.getString('zipcode') ?? '';
      controllerMap.state.value = prefs.getString('state') ?? '';
      controllerMap.country.value = prefs.getString('country') ?? '';
      controllerMap.town.value = prefs.getString('town') ?? '';
      // showToast(locationController.countryName.toString());
      // errorApi();
    });
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
      mapController!.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(
                  _currentPosition!.latitude, _currentPosition!.longitude),
              zoom: 15)));
      // _onAddMarkerButtonPressed(LatLng(_currentPosition!.latitude, _currentPosition!.longitude), "current location");
      setState(() {});
      // location = _currentAddress!;
    }).catchError((e) {
      debugPrint(e.toString());
    });
  }

  addCurrentAddress() {
    Map<String, dynamic> map = {};
    map['zip_code'] = locationController.zipcode.value.toString();
    print('current location${map.toString()}');
    FocusManager.instance.primaryFocus!.unfocus();
    repositories
        .postApi(url: ApiUrls.addCurrentAddress, context: context, mapData: map)
        .then((value) {
      AddCorrentAddressModel response =
          AddCorrentAddressModel.fromJson(jsonDecode(value));
      cartController.countryId = response.data!.countryId.toString();
      // showToast(response.message.toString());
      getAllAsync();
    });
  }

  Future getAllAsync() async {
    // if (!mounted) return;
    // homeController.homeData();
    if (!mounted) return;
    profileController.getDataProfile();
    if (!mounted) return;
    homeController.getVendorCategoriesHome();
    if (!mounted) return;
    homeController.getVendorCategories();
    if (!mounted) return;
    homeController.authorData();
    if (!mounted) return;
    cartController.myDefaultAddressData();
    if (!mounted) return;
    homeController.featuredStores();
    if (!mounted) return;
    homeController.showCaseProductsData();
    if (!mounted) return;
    homeController.trendingData();
    if (!mounted) return;
    homeController.popularProductsData();
    if (!mounted) return;
    cartController.getAddress();
    if (!mounted) return;
  }

  showVendorDialog() {
    if (Platform.isAndroid) {
      showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.vendorRegister,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    10.spaceY,
                    TextButton(
                        onPressed: () {
                          Get.back();
                          Get.toNamed(
                            LoginScreen.route,
                          );
                        },
                        child: Text(AppStrings.createAccount))
                  ],
                ),
              ),
            );
          });
      return;
    }
    if (Platform.isIOS) {
      showDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text(
                "${'To register as vendor partner need to '.tr}"
                "${'create an account first.'.tr}",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 16),
              ),
              actions: [
                CupertinoDialogAction(
                    onPressed: () {
                      Get.back();
                      Get.toNamed(
                        LoginScreen.route,
                      );
                    },
                    child: Text("Create Account".tr))
              ],
            );
          });
      return;
    }
  }

  bool hasShownDialog = false;
  final RxBool _isValue = false.obs;
  final RxBool search = false.obs;
  var vendor = [
    'Dashboard',
    'Order',
    'Products',
    'Store open time',
    'Bank Details',
    'Earnings'
  ];
  var vendorRoutes = [
    VendorDashBoardScreen.route,
    VendorOrderList.route,
    VendorProductScreen.route,
    SetTimeScreen.route,
    BankDetailsScreen.route,
    WithdrawMoney.route,
  ];
  final locationController = Get.put(LocationController());

  final controllerMap = Get.put(ControllerMap());
  sharedTesting() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // sharedPreferences.setString('app_language1', "Arbi");
    String? language = await sharedPreferences.getString('app_language');
    if (language == null) {
      language = 'Null';
    }
    if (language == '') {
      print('empty');
    }
    print('My Current lanague $language');
    // sharedPreferences.setString("app_language", gg);
  }

  @override
  void initState() {
    super.initState();
    sharedTesting();
    homeController.getVendorCategories();
    cartController.getAddress();
    homeController.getVendorCategoriesHome();
    profileController.aboutUsData();
    print(
        "Live Location-----: ${locationController.city.toString()}, ${locationController.zipcode ?? ''} ");
    print(
        "Location-----: ${serviceController.cityController1.text.toString()}, ${serviceController.stateController1.text.toString()}, ${serviceController.countryController1.text ?? ''} ");
    // locationController.checkGps(context);
    // _getCurrentPosition();
    // locationController.getCurrentPosition();
    // _loadSavedAddress();

    // showToast(locationController.countryName.toString());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!hasShownDialog) {
        log('valueee trueee///${hasShownDialog.toString()}');
        _showWelcomeDialog();
        locationController.getAddress();
      } else {
        log('valueee falseee////${hasShownDialog.toString()}');
        locationController.checkGps(context);
        locationController.getAddress();
      }
      // if(!hasShownDialog){
      //   Future.delayed(const Duration(minutes: 1),(){
      //     controllerMap.sellingPickupAddressApiHome();
      //     errorApi();
      //   });
      // }
      // Future.delayed(const Duration(seconds: 5), () {
      //
      //   SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      //     getAllAsync();
      //   });
      // });
    });
    // _showWelcomeDialog();
    // SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    //   getAllAsync();
    // });

    Future.delayed(const Duration(seconds: 7), () {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        addCurrentAddress();
        getAllAsync();
        if (locationController.addressListModel.value.defaultAddress != null) {
          log('himpreettttt:::::${locationController.addressListModel.value.defaultAddress!.city}');
          cartController.city.value =
              locationController.addressListModel.value.defaultAddress!.city;
          log('himpreettttt:::::${cartController.city.value}');
        }
      });
    });
  }

  Future<void> _showWelcomeDialog() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    hasShownDialog = preferences.getBool('hasShownDialog') ?? false;
    log('valueee show model${hasShownDialog.toString()}');
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
                        if (Platform.isAndroid) {
                          SystemNavigator.pop();
                        }
                        if (Platform.isIOS) {
                          Get.back();
                          // FlutterExitApp.exitApp(iosForceExit: true);
                        }
                      },
                      child: Platform.isAndroid
                          ? Text("Exit App".tr)
                          : Text("Do not allow".tr)),
                  TextButton(
                    onPressed: () async {
                      await preferences.setBool('hasShownDialog', true);
                      Navigator.of(context).pop();
                      _getCurrentPosition();
                      addCurrentAddress();
                      homeController.trendingData();
                      homeController.popularProductsData();
                      Future.delayed(const Duration(minutes: 1), () {
                        controllerMap.sellingPickupAddressApiHome();
                        errorApi();
                      });
                      log('valueee clickk...${hasShownDialog.toString()}');
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

  final profileController = Get.put(ProfileController());

  List<Widget> vendorPartner() {
    return [
      GestureDetector(
        onTap: () {
          // if (profileController.model.user == null) {
          //   showVendorDialog();
          //   return;
          // }
          // if (profileController.model.user!.isVendor != true) {
          //   Get.to(() => const VendorPlansScreen());
          //   return;
          // }
          // if (profileController.model.user!.isVendor == true) {
          //   Get.to(() => const VendorDashBoardScreen());
          //   return;
          // }
          // _isValue.value = !_isValue.value;
          // setState(() {});
          Get.to(() => const WishListScreen());
        },
        child: SvgPicture.asset("assets/svgs/heart.svg"),
      ),

      // _isValue.value == true
      //     ? Obx(() {
      //   if (profileController.refreshInt.value > 0) {}
      //`
      //   return profileController.model.user != null
      //       ? Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children:
      //         ? List.generate(
      //         vendor.length,
      //             (index) => Row(
      //           children: [
      //             const SizedBox(
      //               width: 30,
      //             ),
      //             // Expanded(
      //             //   child: TextButton(
      //             //     onPressed: () {
      //             //       Get.toNamed(vendorRoutes[index]);
      //             //     },
      //             //     style: TextButton.styleFrom(
      //             //         visualDensity: const VisualDensity(vertical: -3, horizontal: -3),
      //             //         padding: EdgeInsets.zero.copyWith(left: 16)),
      //             //     child: Row(
      //             //       children: [
      //             //         Expanded(
      //             //           child: Text(
      //             //             vendor[index],
      //             //             style: GoogleFonts.poppins(
      //             //                 fontSize: 16,
      //             //                 fontWeight: FontWeight.w400,
      //             //                 color: Colors.grey.shade500),
      //             //           ),
      //             //         ),
      //             //         const Icon(
      //             //           Icons.arrow_forward_ios_rounded,
      //             //           size: 14,
      //             //         )
      //             //       ],
      //             //     ),
      //             //   ),
      //             // ),
      //           ],
      //         ))
      //         : [],
      //   )
      //       : const SizedBox();
      // })
      //     : const SizedBox(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: bottomController.scaffoldKey,
        appBar: AppBar(
          toolbarHeight: kToolbarHeight + 9,
          backgroundColor: const Color(0xFFEBF3F6),
          surfaceTintColor: Color(0xFFF2F2F2),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Color(0xFFEBF3F6),
            statusBarIconBrightness: Brightness.dark,
          ),
          leading: Padding(
            padding: profileController.selectedLAnguage.value == 'English'
                ? const EdgeInsets.only(left: 8.0)
                : const EdgeInsets.only(right: 12.0),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    bottomController.scaffoldKey.currentState!.openDrawer();

                    // bottomController.updateIndexValue(3);
                  },
                  child: Image.asset('assets/images/menu_new.png',
                      width: 30, height: 30
                      // color: Colors.white,
                      ),
                ),
                const SizedBox(
                  width: 13,
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      search.value = !search.value;
                    });
                  },
                  child: SvgPicture.asset(
                    'assets/svgs/search_icon_new.svg',
                    width: 28,
                    height: 28,
                    // color: Colors.white,
                  ),
                  // child : Image.asset('assets/images/search_icon_new.png')
                ),
              ],
            ),
          ),
          leadingWidth: 120,
          title: Column(
            children: [
              Image.asset(
                'assets/images/new_logo.png',
                width: 62,
                // color: Colors.white,
              ),
              // 5.spaceY,
              // Text(
              //   "LIVE BETTER",
              //   style: GoogleFonts.poppins(
              //     color: const Color(0xFF666666),
              //     fontSize: 14,
              //     fontWeight: FontWeight.w400,
              //   ),
              // )
            ],
          ),
          centerTitle: true,
          actions: const [
            // ...vendorPartner(),
            CartBagCard(),
          ],
          bottom: PreferredSize(
            preferredSize: search.value == true
                ? Size.fromHeight(50.0)
                : Size.fromHeight(0.0),
            child: search.value == true
                ? Hero(
                    tag: "search_tag",
                    child: Material(
                      color: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: TextField(
                          maxLines: 1,
                          style: GoogleFonts.poppins(fontSize: 16),
                          textInputAction: TextInputAction.search,
                          onSubmitted: (vb) {
                            Get.to(() => SearchProductsScreen(
                                  searchText: vb,
                                ));
                          },
                          decoration: InputDecoration(
                              filled: true,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Image.asset(
                                  'assets/icons/search.png',
                                  height: 5,
                                ),
                              ),
                              border: InputBorder.none,
                              enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  borderSide:
                                      BorderSide(color: AppTheme.buttonColor)),
                              disabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  borderSide:
                                      BorderSide(color: AppTheme.buttonColor)),
                              focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  borderSide:
                                      BorderSide(color: AppTheme.buttonColor)),
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(15),
                              hintText: AppStrings.searchFieldText.tr,
                              hintStyle: GoogleFonts.poppins(
                                  color: AppTheme.buttonColor,
                                  fontWeight: FontWeight.w400)),
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ),
          // bottom: PreferredSize(
          //   preferredSize: search.value == true ? Size.fromHeight(20.0) : Size.fromHeight(0.0),
          //   child: search.value == true
          //       ? Container(
          //     decoration: BoxDecoration(
          //       border: Border.all(color: Colors.black)
          //     ),
          //         child: Row(
          //                       // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //                       children: [
          //         SvgPicture.asset(
          //           'assets/images/location.svg',
          //           height: 20,
          //           color: Colors.black,
          //         ),
          //         5.spaceX,
          //         Flexible(
          //             child: Text(
          //               "Deliver to  ${"Pakistan"} , ${"57170"}",
          //               // "Deliver to  ${locationController.city.toString()} , ${locationController.zipcode ?? ''}",
          //               style: GoogleFonts.poppins(
          //                 color: Colors.black,
          //                 fontSize: 14,
          //                 fontWeight: FontWeight.w400,
          //               ),
          //             )
          //           //     Obx(() {return Text(
          //           //     "Deliver to  ${"Pakistan"} , ${"57170"}",
          //           //     // "Deliver to  ${locationController.city.toString()} , ${locationController.zipcode ?? ''}",
          //           //     style: GoogleFonts.poppins(
          //           //       color: Colors.black,
          //           //       fontSize: 14,
          //           //       fontWeight: FontWeight.w400,
          //           //     ),
          //           //   );
          //           // })
          //         ),
          //         5.spaceX,
          //         SvgPicture.asset(
          //           'assets/images/pencilImg.svg',
          //           height: 18,
          //           color: Colors.white,
          //         ),
          //                       ],
          //                     ),
          //       )
          //       : SizedBox.shrink(),
          // ),
        ),
        drawer: const CustomDrawer(),
        backgroundColor: const Color(0xFFEBF3F6),
        body: RefreshIndicator(
            onRefresh: () async {
              await getAllAsync();
            },
            child: Column(
              children: [
                Container(
                  color: const Color(0xFFEBF3F6),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(onTap: () {
                        Get.to(
                          () => profileController.userLoggedIn
                              ? const HomeAddEditAddressLogin()
                              : HomeAddEditAddress(),
                          arguments: 'home',
                        );
                      }, child: Obx(() {
                        return profileController.userLoggedIn &&
                                locationController
                                        .addressListModel.value.status ==
                                    true
                            // && locationController.onTapLocation.value == false
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(width: 10),
                                  SvgPicture.asset(
                                    'assets/images/location.svg',
                                    width: 16,
                                    height: 16,
                                    color: AppTheme.buttonColor,
                                  ),
                                  const SizedBox(width: 10),
                                  profileController.selectedLAnguage.value ==
                                          'English'
                                      ? Flexible(
                                          child: Text(
                                            " Deliver to ${locationController.addressListModel.value.defaultAddress!.city ?? ''}, "
                                            "${locationController.addressListModel.value.defaultAddress!.zipCode ?? ''},"
                                            " ${locationController.addressListModel.value.defaultAddress!.state ?? ''}",
                                            overflow: TextOverflow.visible,
                                            softWrap: true,
                                          ),
                                        )
                                      : Flexible(
                                          child: Text(
                                            "يسلم إلى ${locationController.addressListModel.value.defaultAddress!.city ?? ''},"
                                            " ${locationController.addressListModel.value.defaultAddress!.zipCode ?? ''}, "
                                            "${locationController.addressListModel.value.defaultAddress!.state ?? ' '}",
                                            overflow: TextOverflow.visible,
                                            softWrap: true,
                                          ),
                                        )
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(width: 10),
                                  SvgPicture.asset(
                                    'assets/images/location.svg',
                                    width: 16,
                                    height: 16,
                                    color: AppTheme.buttonColor,
                                  ),
                                  profileController.selectedLAnguage.value ==
                                          'English'
                                      ? Flexible(
                                          child: Text(
                                            serviceController
                                                        .cityController1.text ==
                                                    ""
                                                ? " Add your delivery address"
                                                // ?" Deliver to ${locationController.city.toString()}, ${locationController.zipcode ?? ''}"
                                                : " Deliver to ${serviceController.cityController1.text.toString()}, ${serviceController.stateController1.text.toString()}, ${serviceController.countryController1.text ?? ''}",
                                            // " Deliver to ${locationController.city.toString()}, ${locationController.zipcode ?? ''}",
                                            overflow: TextOverflow.visible,
                                            softWrap: true,
                                          ),
                                        )
                                      : Flexible(
                                          child: Text(
                                            serviceController
                                                        .cityController1.text ==
                                                    ""
                                                ? " أضف عنوان التسليم الخاص بك"
                                                // ?" Deliver to ${locationController.city.toString()}, ${locationController.zipcode ?? ''}"
                                                : " يسلم إلى ${serviceController.cityController1.text.toString()}, ${serviceController.stateController1.text.toString()}, ${serviceController.countryController1.text ?? ''}",
                                            // "يسلم إلى  ${locationController.city.toString()}, ${locationController.zipcode ?? ''}",
                                            overflow: TextOverflow.visible,
                                            softWrap: true,
                                          ),
                                        )
                                ],
                              );
                      })

                          //     :
                          // Row(
                          //   children: [
                          //     profileController.selectedLAnguage.value == 'English'
                          //         ? Center(
                          //         child: Text(
                          //           "   Deliver to ${locationController.city.toString()},${locationController.zipcode ??
                          //               ''}",
                          //         ))
                          //         : Center(
                          //         child: Text(
                          //           "   يسلم إلى ${locationController.city.toString()},${locationController.zipcode ?? ''}",
                          //         ))
                          //   ],
                          // )

                          // if (locationController.zipcode.isNotEmpty)
                          //   Padding(
                          //     padding: const EdgeInsets.symmetric(horizontal: 15),
                          //     child: Column(
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       children: [
                          //         if (!profileController.userLoggedIn)
                          //           Text(
                          //             'Address ',
                          //             style: GoogleFonts.poppins(
                          //               color: Colors.black,
                          //               fontSize: 18,
                          //               fontWeight: FontWeight.w500,
                          //             ),
                          //           ),
                          //         4.spaceY,
                          //         GestureDetector(
                          //           onTap: () {
                          //             Get.to(() => profileController.userLoggedIn
                          //                 ? const HomeAddEditAddressLogin()
                          //                 : HomeAddEditAddress(),
                          //               arguments: 'home',
                          //             );
                          //           },
                          //           child: Row(
                          //             children: [
                          //               SvgPicture.asset(
                          //                 'assets/images/location.svg',
                          //                 height: 20,
                          //                 color: Colors.black,
                          //               ),
                          //               5.spaceX,
                          //               Flexible(
                          //                 child: Obx(() {
                          //                   return Text(
                          //                     "Deliver to  ${locationController.city.toString()} , ${locationController.zipcode ?? ''}",
                          //                     style: GoogleFonts.poppins(
                          //                       color: Colors.black,
                          //                       fontSize: 14,
                          //                       fontWeight: FontWeight.w400,
                          //                     ),
                          //                   );
                          //                 }),
                          //               ),
                          //               5.spaceX,
                          //               SvgPicture.asset(
                          //                 'assets/images/pencilImg.svg',
                          //                 height: 18,
                          //                 color: Colors.white,
                          //               ),
                          //             ],
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   )
                          // else
                          //   const SizedBox.shrink(),

                          ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),

                // Flexible(
                //     child:
                //     Obx(() {return Text(
                //       // "Deliver to  ${"Pakistan"} , ${"57170"}",
                //       "Deliver to  ${locationController.city.toString()} , ${locationController.zipcode ?? ''}",
                //       style: GoogleFonts.poppins(
                //         color: Colors.black,
                //         fontSize: 14,
                //         fontWeight: FontWeight.w400,
                //       ),
                //     );
                //     })
                // ),
                Expanded(
                  child: Container(
                    // color: Color(0xFFF2F2F2).withOpacity(0.6),
                    color: Colors.white,
                    child: const SingleChildScrollView(
                        child: Column(children: [
                      SliderWidget(),
                      CategoryItems(),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   children: [
                      //     Text(
                      //       "Edit categories order",
                      //       style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.buttonColor),
                      //
                      //     ),
                      //     SizedBox(width: 18,)
                      //   ],
                      // ),
                      TrendingProducts(),
                      AdBannerUI(),
                      PopularProducts(),
                      StarOfMonthScreen(),
                      ShowCaseProducts(),
                      AuthorScreen(),
                      SizedBox(
                        height: 30,
                      ),
                    ])),
                  ),
                ),
              ],
            )));
  }
}
