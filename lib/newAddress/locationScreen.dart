import 'dart:async';
import 'dart:developer';
import 'dart:ffi';
import 'dart:ffi';
import 'dart:ffi';
import 'dart:ffi';
import 'dart:ffi';
import 'dart:ffi';
import 'dart:ui' as ui;
import 'package:dirise/newAddress/pickUpAddressScreen.dart';
import 'package:dirise/utils/api_constant.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/google_map_controlleer.dart';
import '../controller/location_controller.dart';
import '../controller/profile_controller.dart';
import '../controller/service_controller.dart';
import '../widgets/common_button.dart';
import '../widgets/common_colour.dart';
import '../widgets/dimension_screen.dart';
import 'customeraccountcreatedsuccessfullyScreen.dart';

class ChooseAddress extends StatefulWidget {
  ChooseAddress({
    super.key,
  });
  static var chooseAddressScreen = "/chooseAddressScreen";

  @override
  State<ChooseAddress> createState() => _ChooseAddressState();
}

class _ChooseAddressState extends State<ChooseAddress> {
  Position? _currentPosition;
  final serviceController = Get.put(ServiceController());
  final controllerMap = Get.put(ControllerMap());
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      profileController.selectedLAnguage.value == "English"
          ? showToast(
              'Location services are disabled. Please enable the services')
          : showToast( 'تم تعطيل خدمات الموقع. يرجى تفعيل الخدمات.');
      

      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.'),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      controllerMap.getAddressFromLatLng(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          "current location");
      controllerMap.mapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target:
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 15),
      ));
      _onAddMarkerButtonPressed(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          "current location");
      setState(() {});
    }).catchError((e) {
      debugPrint(e);
    });
  }

  String? appLanguage = "English";
  getLanguage() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    appLanguage = sharedPreferences.getString("app_language");
    print("hfgdhfgh$appLanguage");
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getLanguage();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getCurrentPosition();
    });
  }

  String googleApikey = "AIzaSyDXySHy9RuRf6UJmcS1E57SZjdi08NWFxA";
  GoogleMapController? mapController1;
  CameraPosition? cameraPosition;
  String location = "Search Location";
  bool isMarkerDraggable = true;
  Marker? redPinMarker;
  final Set<Marker> markers = {};
  final profileController = Get.put(ProfileController());
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> _onAddMarkerButtonPressed(LatLng lastMapPosition, markerTitle,
      {allowZoomIn = true}) async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/icons/location.png', 140);

    redPinMarker = Marker(
      markerId: MarkerId('redPin'),
      position: lastMapPosition,
      draggable: isMarkerDraggable,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    if (controllerMap.googleMapController.isCompleted) {
      controllerMap.mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: lastMapPosition, zoom: allowZoomIn ? 13 : 10),
        ),
      );
    }
    setState(() {});
  }

  final locationController = Get.put(LocationController());

  @override
  Widget build(BuildContext context) {
    log(appLanguage.toString());
    return WillPopScope(
      onWillPop: () async {
        controllerMap.mapController!.dispose();
        return true;
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusManager.instance.primaryFocus!.unfocus();
        },
        child: Scaffold(
            body: Stack(
          children: [
            GoogleMap(
              zoomGesturesEnabled: true,
              initialCameraPosition: const CameraPosition(
                target: LatLng(0, 0),
                zoom: 14.0, //initial zoom level
              ),
              mapType: MapType.normal,
              onMapCreated: (controller) {
                controllerMap.mapController = controller;
                setState(() async {});
              },
              markers: {
                if (redPinMarker != null) redPinMarker!,
              },
              onCameraMove: (CameraPosition cameraPositions) {
                if (isMarkerDraggable && redPinMarker != null) {
                  setState(() {
                    redPinMarker = redPinMarker!
                        .copyWith(positionParam: cameraPositions.target);
                  });
                }
              },
              onCameraIdle: () async {
                if (redPinMarker != null) {
                  await controllerMap.getAddressFromLatLng(
                      redPinMarker!.position, "current location");
                }
              },
            ),
            Positioned(
                top: 10,
                child: InkWell(
                    onTap: () async {
                      var place = await PlacesAutocomplete.show(
                          context: context,
                          apiKey: googleApikey,
                          mode: Mode.overlay,
                          types: [],
                          strictbounds: false,
                          // components: [
                          //   Component(Component.country, appLanguage == "French" ? "fr" : appLanguage == "Spanish"?"es": appLanguage == "Arabic"?"ar":appLanguage == "English"?"en":"en")
                          // ],
                          onError: (err) {
                            log("error.....   ${err.errorMessage}");
                          });
                      if (place != null) {
                        setState(() {
                          controllerMap.address.value =
                              place.description.toString();
                        });
                        final plist = GoogleMapsPlaces(
                          apiKey: googleApikey,
                          apiHeaders:
                              await const GoogleApiHeaders().getHeaders(),
                        );
                        print(plist);
                        String placeid = place.placeId ?? "0";
                        final detail = await plist.getDetailsByPlaceId(placeid);
                        final geometry = detail.result.geometry!;
                        final lat = geometry.location.lat;
                        final lang = geometry.location.lng;
                        var newlatlang = LatLng(lat, lang);
                        setState(() {
                          controllerMap.address.value =
                              place.description.toString();
                          _onAddMarkerButtonPressed(
                              LatLng(lat, lang), place.description);
                        });
                        controllerMap.mapController?.animateCamera(
                            CameraUpdate.newCameraPosition(
                                CameraPosition(target: newlatlang, zoom: 17)));
                        setState(() {});
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Card(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 15,
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.back();
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  profileController.selectedLAnguage.value !=
                                          'English'
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
                            Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.all(0),
                                width: MediaQuery.of(context).size.width - 80,
                                child: ListTile(
                                  leading: Icon(Icons.location_on_outlined,
                                      color: AppTheme.primaryColor),
                                  title: Text(
                                    controllerMap.address.value.toString(),
                                    style: TextStyle(fontSize: AddSize.font14),
                                  ),
                                  trailing: const Icon(Icons.search),
                                  dense: true,
                                )),
                          ],
                        ),
                      ),
                    ))),
            Positioned(
                bottom: 0,
                child: Container(
                  height: AddSize.size220,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AddSize.padding16,
                      vertical: AddSize.padding10,
                    ),
                    child: Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      height: 200,
                      width: Get.width,
                      decoration: BoxDecoration(color: Colors.white),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: AppTheme.primaryColor,
                                  size: AddSize.size25,
                                ),
                                SizedBox(
                                  width: AddSize.size12,
                                ),
                                Expanded(
                                  child: Text(
                                    controllerMap.address.value.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(
                                            fontWeight: FontWeight.w500,
                                            fontSize: AddSize.font16),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                // InkWell(
                                //   onTap: (){
                                //     showDialog<String>(
                                //         context: context,
                                //         builder: (BuildContext context) => AlertDialog(
                                //           title: Text('Save Location'.tr),
                                //           content: Text('Do you want to save your location.'.tr),
                                //           actions: <Widget>[
                                //             TextButton(
                                //               onPressed: () => Get.back(),
                                //               child: Text('Cancel'.tr),
                                //             ),
                                //             TextButton(
                                //               onPressed: () async {
                                //                 controllerMap.sellingPickupAddressApi1(context);
                                //                 Get.to( PickUpAddressScreen(
                                //                   street:  controllerMap.street.value,
                                //                   city: controllerMap.city.value,
                                //                   state:controllerMap. state.value,
                                //                   country: controllerMap.country.value,
                                //                   town: controllerMap.town.value,
                                //                   zipcode:controllerMap. zipcode.value,
                                //                   shortCode:controllerMap.countryCode.value ,
                                //                 ));
                                //                 // Get.back();
                                //                 // controllerMap.sellingPickupAddressApi(context);
                                //               },
                                //               child: Text('OK'.tr),
                                //             ),
                                //           ],
                                //         ));
                                //   },
                                //   child: Text(
                                //     'Save Location'.tr,
                                //     style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                //         fontWeight: FontWeight.w600,
                                //         fontSize: AddSize.font16,
                                //         color: const Color(0xff014E70)),
                                //   ),
                                // )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          CustomOutlineButton(
                            title: "Confirm Your Location".tr,
                            borderRadius: 11,
                            onPressed: () {
                              Get.to(PickUpAddressScreen(
                                street: controllerMap.street.value,
                                city: controllerMap.city.value,
                                state: controllerMap.state.value,
                                country: controllerMap.country.value,
                                town: controllerMap.town.value,
                                zipcode: controllerMap.zipcode.value,
                                shortCode: controllerMap.countryCode.value,
                              ));
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ))
          ],
        )),
      ),
    );
  }
}
