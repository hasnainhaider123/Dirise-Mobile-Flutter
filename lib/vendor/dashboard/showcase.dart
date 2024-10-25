import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dirise/language/app_strings.dart';
import 'package:dirise/screens/product_details/product_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controller/home_controller.dart';
import '../../controller/profile_controller.dart';
import '../../controller/wish_list_controller.dart';
import '../../model/common_modal.dart';
import '../../repository/repository.dart';
import '../../single_products/advirtising_single.dart';
import '../../utils/api_constant.dart';
import '../../widgets/common_colour.dart';
import '../../widgets/like_button.dart';

class ShowCaseProducts extends StatefulWidget {
  const ShowCaseProducts({super.key});

  @override
  State<ShowCaseProducts> createState() => _ShowCaseProductsState();
}

class _ShowCaseProductsState extends State<ShowCaseProducts> {
  final homeController = Get.put(TrendingProductsController());
  final profileController = Get.put(ProfileController());
  final Repositories repositories = Repositories();

  void launchURLl(String url) async {
    if (await canLaunch(url)) {
      try {
        await launch(url);
      } catch (e) {
        print('Error launching URL: $url');
        print('Exception: $e');
      }
    } else {
      print('Could not launch $url');
    }
  }

  final wishListController = Get.put(WishListController());

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Column(
      children: [
        const SizedBox(
          height: 60,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              Text(
                AppStrings.showProducts.tr.toUpperCase(),
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox()
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            InkWell(
                onTap: () {
                  // index1 = index1 + 1;
                  // setState(() {
                  //   if (index1 == homeController.trendingModel.value.product!.product!.length - 1) {
                  //     index1 = 0;
                  //   }
                  // });
                  // scrollToItem(index1);
                },
                child: profileController.selectedLAnguage.value != 'English'
                    ? Image.asset(
                        "assets/images/arab_forward.png",
                        width: 40,
                        height: 40,
                      )
                    : Image.asset(
                        "assets/icons/new_arrow.png",
                        width: 35,
                        height: 35,
                      )),
            const SizedBox(
              width: 20,
            )
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          height: 280,
          // margin: const EdgeInsets.fromLTRB(15, 20, 15, 0),
          child: Obx(() {
            return homeController.getShowModal.value.showcaseProduct != null
                ? ListView.builder(
                    itemCount: homeController
                        .getShowModal.value.showcaseProduct!.length,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      final item = homeController
                          .getShowModal.value.showcaseProduct![index];
                      return InkWell(
                        onTap: () {
                          Get.to(() => const AdvirtismentProductScreen(),
                              arguments: item.id.toString());
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Stack(
                            children: [
                              Container(
                                width: size.width * .92,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.withOpacity(
                                            0.2), // Shadow color with opacity
                                        spreadRadius:
                                            2, // How far the shadow spreads
                                        blurRadius: 2, // Softness of the shadow
                                        offset: const Offset(0,
                                            0) // Changes position of shadow (horizontal, vertical)
                                        ),
                                  ],
                                ),
                                // constraints: BoxConstraints(
                                //   // maxHeight: 100,
                                //   minWidth: 0,
                                //   maxWidth: size.width,
                                // ),
                                // color: Colors.red,
                                // margin: const EdgeInsets.only(right: 9,left: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        CachedNetworkImage(
                                            imageUrl:
                                                item.featuredImage.toString(),
                                            height: 150,
                                            width: 150,
                                            fit: BoxFit.cover,
                                            errorWidget: (_, __, ___) =>
                                                Image.asset(
                                                    'assets/images/new_logo.png')),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // const SizedBox(
                                              //   height: 10,
                                              // ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(),
                                                  if (item.countryName
                                                          .toString()
                                                          .toLowerCase() ==
                                                      'kuwait city')
                                                    Image.asset(
                                                        'assets/svgs/flagk.png'),
                                                  Text(
                                                    item.countryName.toString(),
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: const Color(
                                                            0xFF19313C)),
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Obx(() {
                                                    if (wishListController
                                                            .refreshFav.value >
                                                        0) {}
                                                    return LikeButtonCat(
                                                      onPressed: () {
                                                        if (wishListController
                                                            .favoriteItems
                                                            .contains(item.id
                                                                .toString())) {
                                                          repositories
                                                              .postApi(
                                                                  url: ApiUrls
                                                                      .removeFromWishListUrl,
                                                                  mapData: {
                                                                    "product_id":
                                                                        item.id
                                                                            .toString(),
                                                                  },
                                                                  context:
                                                                      context)
                                                              .then((value) {
                                                            ModelCommonResponse
                                                                response =
                                                                ModelCommonResponse
                                                                    .fromJson(
                                                                        jsonDecode(
                                                                            value));
                                                            log('api response is${response.toJson()}');
                                                            showToast(response
                                                                .message);
                                                            wishListController
                                                                .getYourWishList();
                                                            wishListController
                                                                .favoriteItems
                                                                .remove(item.id
                                                                    .toString());
                                                            wishListController
                                                                .updateFav;
                                                            setState(() {});
                                                          });
                                                        } else {
                                                          repositories
                                                              .postApi(
                                                                  url: ApiUrls
                                                                      .addToWishListUrl,
                                                                  mapData: {
                                                                    "product_id":
                                                                        item.id
                                                                            .toString(),
                                                                  },
                                                                  context:
                                                                      context)
                                                              .then((value) {
                                                            ModelCommonResponse
                                                                response =
                                                                ModelCommonResponse
                                                                    .fromJson(
                                                                        jsonDecode(
                                                                            value));
                                                            showToast(response
                                                                .message);
                                                            if (response
                                                                    .status ==
                                                                true) {
                                                              wishListController
                                                                  .getYourWishList();
                                                              wishListController
                                                                  .favoriteItems
                                                                  .add(item.id
                                                                      .toString());
                                                              wishListController
                                                                  .updateFav;
                                                            }
                                                          });
                                                        }
                                                      },
                                                      isLiked:
                                                          wishListController
                                                              .favoriteItems
                                                              .contains(item.id
                                                                  .toString()),
                                                    );
                                                  }),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              Text(
                                                item.pname.toString(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.poppins(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500,
                                                    color: const Color(
                                                        0xFF19313C)),
                                              ),

                                              // Row(
                                              //   children: [
                                              //     Text(
                                              //       item.catId.toString(),
                                              //       maxLines: 1,
                                              //       overflow:
                                              //           TextOverflow.ellipsis,
                                              //       style: GoogleFonts.poppins(
                                              //           fontSize: 12,
                                              //           fontWeight:
                                              //               FontWeight.w400,
                                              //           color: const Color(
                                              //               0xFF19313C)),
                                              //     ),
                                              //     Text(
                                              //       item.catId.toString(),
                                              //       maxLines: 1,
                                              //       overflow:
                                              //           TextOverflow.ellipsis,
                                              //       style: GoogleFonts.poppins(
                                              //           fontSize: 12,
                                              //           fontWeight:
                                              //               FontWeight.w400,
                                              //           color: const Color(
                                              //               0xFF19313C)),
                                              //     ),
                                              //   ],
                                              // ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              // Row(
                                              //   children: [
                                              //     Text(
                                              //       "yokun",
                                              //       style: GoogleFonts.poppins(
                                              //           fontSize: 11,
                                              //           fontWeight:
                                              //               FontWeight.w400,
                                              //           color: const Color(
                                              //               0xFF19313C)),
                                              //     ),
                                              //     const SizedBox(
                                              //       width: 6,
                                              //     ),
                                              //     Text(
                                              //       "gmc",
                                              //       style: GoogleFonts.poppins(
                                              //           fontSize: 11,
                                              //           fontWeight:
                                              //               FontWeight.w400,
                                              //           color: const Color(
                                              //               0xFF19313C)),
                                              //     ),
                                              //     const SizedBox(
                                              //       width: 6,
                                              //     ),
                                              //     Text(
                                              //       "used",
                                              //       style: GoogleFonts.poppins(
                                              //           fontSize: 11,
                                              //           fontWeight:
                                              //               FontWeight.w400,
                                              //           color: const Color(
                                              //               0xFF19313C)),
                                              //     ),
                                              //     const SizedBox(
                                              //       width: 6,
                                              //     ),
                                              //     Text(
                                              //       "2024",
                                              //       style: GoogleFonts.poppins(
                                              //           fontSize: 11,
                                              //           fontWeight:
                                              //               FontWeight.w400,
                                              //           color: const Color(
                                              //               0xFF19313C)),
                                              //     ),
                                              //   ],
                                              // ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              Align(
                                                alignment: Alignment.topRight,
                                                child: Text.rich(
                                                  profileController
                                                              .selectedLAnguage
                                                              .value ==
                                                          "English"
                                                      ? TextSpan(
                                                          text:
                                                              '${item.discountPrice.toString().split('.')[0]}.',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 32,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Color(
                                                                0xFF19313B),
                                                          ),
                                                          children: [
                                                            WidgetSpan(
                                                              alignment:
                                                                  PlaceholderAlignment
                                                                      .middle,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  const Text(
                                                                    'KWD',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          8,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Color(
                                                                          0xFF19313B),
                                                                    ),
                                                                  ),
                                                                  InkWell(
                                                                    onTap: () {
                                                                      // print("date:::::::::::" + widget.productElement.shippingDate);
                                                                    },
                                                                    child: Text(
                                                                      '${item.discountPrice.toString().split('.')[1]}',
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            8,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        color: Color(
                                                                            0xFF19313B),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : TextSpan(
                                                          children: [
                                                            WidgetSpan(
                                                              alignment:
                                                                  PlaceholderAlignment
                                                                      .bottom,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  const Text(
                                                                    'KWD',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          8,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Color(
                                                                          0xFF19313B),
                                                                    ),
                                                                  ),
                                                                  InkWell(
                                                                    onTap: () {
                                                                      // print("date:::::::::::" + widget.productElement.shippingDate);
                                                                    },
                                                                    child: Text(
                                                                      '${item.discountPrice.toString().split('.')[1]}',
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            8,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        color: Color(
                                                                            0xFF19313B),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  '.${item.discountPrice.toString().split('.')[0]}',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 32,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Color(
                                                                    0xFF19313B),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: item.shortDescription !=
                                                              null &&
                                                          item.shortDescription!
                                                                  .length >
                                                              60
                                                      ? "${item.shortDescription!.substring(0, 60)}..." // Truncate description
                                                      : item.shortDescription
                                                          .toString(), // Show full description if less than 80 characters
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: const Color(
                                                          0xFF19313C)),
                                                ),
                                                TextSpan(
                                                  text:
                                                      " Details", // "Details" link
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.blue,
                                                      decoration: TextDecoration
                                                          .underline),
                                                  recognizer:
                                                      TapGestureRecognizer()
                                                        ..onTap = () {
                                                          // Handle the "Details" tap, for example by navigating to a detailed view
                                                          debugPrint(
                                                              "Details tapped");
                                                          Get.to(
                                                              () =>
                                                                  const AdvirtismentProductScreen(),
                                                              arguments: item.id
                                                                  .toString());
                                                          // You can use Navigator or Get.to() for navigation
                                                        },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            launchURLl(
                                                'tel:${item.vendorDetails!.phoneNumber.toString()}');
                                          },
                                          child: SvgPicture.asset(
                                            'assets/svgs/phonee.svg',
                                            width: 25,
                                            height: 25,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            String phoneNumber = item
                                                .vendorDetails!.phoneNumber
                                                .toString();

                                            // Remove any spaces in the phone number
                                            phoneNumber =
                                                phoneNumber.replaceAll(
                                                    ' ', ''); // Remove spaces

                                            String whatsappUrl =
                                                'https://wa.me/$phoneNumber';
                                            launchURLl(whatsappUrl);
                                          },
                                          child: SvgPicture.asset(
                                            'assets/svgs/chat-dots.svg',
                                            width: 25,
                                            height: 25,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // SizedBox(height: 10,),
                                    // Align(
                                    //   alignment: Alignment.center,
                                    //   child: Center(
                                    //     child: CachedNetworkImage(
                                    //         imageUrl: item.featuredImage.toString(),
                                    //         height: 150,
                                    //         fit: BoxFit.fill,
                                    //         errorWidget: (_, __, ___) => Image.asset('assets/images/new_logo.png')
                                    //     ),
                                    //   ),
                                    // ),
                                    // const SizedBox(
                                    //   height: 10,
                                    // ),
                                    //
                                    // const SizedBox(
                                    //   height: 3,
                                    // ),
                                    // Text(
                                    //   item.pname.toString(),
                                    //   maxLines: 2,
                                    //   style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500,color: Color(0xFF19313C)),
                                    // ),
                                    // const SizedBox(
                                    //   height: 3,
                                    // ),
                                    // Text(
                                    //   item.shortDescription.toString(),
                                    //   maxLines: 2,
                                    //   style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500,color: Color(0xFF19313C)),
                                    // ),
                                    // const SizedBox(
                                    //   height: 3,
                                    // ),
                                  ],
                                ),
                              ),
                              profileController.selectedLAnguage.value ==
                                      "English"
                                  ? Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            // boxShadow: [
                                            //   const BoxShadow(
                                            //     // blurStyle: BlurStyle.outer,
                                            //     offset: Offset(2, 3),
                                            //     color: Colors.black26,
                                            //     blurRadius: 3,
                                            //   )
                                            // ],
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(8)),
                                            color: const Color(0xFF27D6FF)
                                                .withOpacity(0.6)),
                                        child: Text(
                                          " Showcase ".tr,
                                          style: GoogleFonts.poppins(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white),
                                        ),
                                      ),
                                    )
                                  : Positioned(
                                      left: 0,
                                      top: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            boxShadow: [
                                              const BoxShadow(
                                                // blurStyle: BlurStyle.outer,
                                                offset: Offset(2, 3),
                                                color: Colors.black26,
                                                blurRadius: 3,
                                              )
                                            ],
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(8)),
                                            color: const Color(0xFF27D6FF)
                                                .withOpacity(0.6)),
                                        child: Text(
                                          " Showcase ".tr,
                                          style: GoogleFonts.poppins(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white),
                                        ),
                                      ),
                                    )
                            ],
                          ),
                        ),
                      );
                    })
                : const SizedBox.shrink();
          }),
        ),
      ],
    );
  }
}
