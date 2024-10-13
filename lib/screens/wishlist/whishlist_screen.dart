import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dirise/language/app_strings.dart';
import 'package:dirise/widgets/loading_animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../controller/cart_controller.dart';
import '../../controller/profile_controller.dart';
import '../../controller/wish_list_controller.dart';
import '../../model/common_modal.dart';
import '../../model/product_model/model_product_element.dart';
import '../../model/trending_products_modal.dart';
import '../../repository/repository.dart';
import '../../single_products/advirtising_single.dart';
import '../../single_products/bookable_single.dart';
import '../../single_products/give_away_single.dart';
import '../../single_products/simple_product.dart';
import '../../single_products/variable_single.dart';
import '../../single_products/vritual_product_single.dart';
import '../../utils/api_constant.dart';
import '../../widgets/cart_widget.dart';
import '../product_details/product_widget.dart';
import '../service_single_ui.dart';

class WishListScreen extends StatefulWidget {
  const WishListScreen({Key? key}) : super(key: key);

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  final _wishListController = Get.put(WishListController());
  final cartController = Get.put(CartController());
  final profileController = Get.put(ProfileController());
  final Repositories repositories = Repositories();

  removeFromWishList(id, int index) {
    repositories
        .postApi(
            url: ApiUrls.removeFromWishListUrl,
            mapData: {
              "product_id": id,
            },
            context: context)
        .then((value) {
      ModelCommonResponse response = ModelCommonResponse.fromJson(jsonDecode(value));
      showToast(response.message);
      if(response.status == true){
        _wishListController.model.value.wishlist!.removeAt(index);
        _wishListController.getYourWishList();
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            AppStrings.myFavourite.tr,
            style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18),
          ),
        ),
        actions: const [
          CartBagCard(isBlackTheme: true),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _wishListController.getYourWishList();
        },
        child: Obx(() {
          if(_wishListController.refreshInt.value > 0){}
          return _wishListController.apiLoaded
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: _wishListController.model.value.wishlist!.isEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Image(
                              //     height: context.getSize.height * .24,
                              //     image: const AssetImage(
                              //       'assets/images/bucket.png',
                              //     )),
                              Lottie.asset("assets/loti/wishlist.json"),
                              Center(
                                child: Text(
                                  AppStrings.whishlistEmpty.tr,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 22),
                                ),
                              ),
                              const SizedBox(height: 20,),
                              // ElevatedButton(
                              //     onPressed: () {
                              //       // Get.toNamed(editprofileScreen);
                              //     },
                              //     style: ButtonStyle(
                              //       backgroundColor: MaterialStateProperty.all(AppTheme.buttonColor),
                              //       padding: MaterialStateProperty.all(
                              //           const EdgeInsets.symmetric(horizontal: 35, vertical: 13)),
                              //     ),
                              //     child: Text(
                              //       'Shop now!',
                              //       style: GoogleFonts.poppins(
                              //           color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                              //     ))
                            ],
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _wishListController.model.value.wishlist!.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio:
                                MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height / 1.2)),
                                itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  print(_wishListController.model.value.wishlist![index].id);
                                  if (_wishListController.model.value.wishlist![index].itemType == 'giveaway') {
                                    Get.to(() => const GiveAwayProduct(), arguments: _wishListController.model.value.wishlist![index].id.toString());
                                  } else if (_wishListController.model.value.wishlist![index].productType == 'variants'&& _wishListController.model.value.wishlist![index].itemType == 'product') {
                                    Get.to(() => const VarientsProductScreen(), arguments: _wishListController.model.value.wishlist![index].id.toString());
                                  } else if (_wishListController.model.value.wishlist![index].productType == 'booking'&& _wishListController.model.value.wishlist![index].itemType == 'product') {
                                    Get.to(() => const BookableProductScreen(), arguments: _wishListController.model.value.wishlist![index].id.toString());
                                  } else if (_wishListController.model.value.wishlist![index].productType == 'virtual_product'&& _wishListController.model.value.wishlist![index].itemType == 'virtual_product') {
                                    Get.to(() =>  VritualProductScreen(), arguments: _wishListController.model.value.wishlist![index].id.toString());
                                  } else if (_wishListController.model.value.wishlist![index].itemType == 'product' && _wishListController.model.value.wishlist![index].showcaseProduct != true) {
                                    Get.to(() => const SimpleProductScreen(), arguments: _wishListController.model.value.wishlist![index].id.toString());
                                  }else if(_wishListController.model.value.wishlist![index].itemType =='service'){
                                    Get.to(() => const ServiceProductScreen(), arguments: _wishListController.model.value.wishlist![index].id.toString());
                                  }else if(_wishListController.model.value.wishlist![index].itemType == 'product' &&  _wishListController.model.value.wishlist![index].showcaseProduct == true){
                                    Get.to(()=>const AdvirtismentProductScreen(),arguments: _wishListController.model.value.wishlist![index].id.toString());
                                  }
                                },
                                child: Container(
                                  height: MediaQuery.of(context).size.height*1,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            _wishListController.model.value.wishlist![index].discountOff != '0.00'
                                                ? Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                  color: const Color(0xFFFF6868),
                                                  borderRadius: BorderRadius.circular(10)),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    " SALE".tr,
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w700,
                                                        color: const Color(0xFFFFDF33)),
                                                  ),
                                                  Text(
                                                    " ${_wishListController.model.value.wishlist![index].discountOff}${'%'}  ",
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                            )
                                                : const SizedBox.shrink(),
                                            IconButton(
                                              onPressed: () {
                                                removeFromWishList(
                                                    _wishListController.model.value.wishlist![index].id.toString(), index);
                                              },
                                              icon: const Icon(
                                                Icons.favorite_rounded,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Center(
                                          child: Image.network(
                                            _wishListController.model.value.wishlist![index].featuredImage.toString(),
                                            height: 100,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Image.asset("assets/images/new_logo.png");
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          _wishListController.model.value.wishlist![index].pName.toString(),
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 16),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                        ),
                                        Text(
                                          _wishListController.model.value.wishlist![index].shortDescription != null ?
                                          _wishListController.model.value.wishlist![index].shortDescription ?? ''
                                              :   _wishListController.model.value.wishlist![index].longDescription ?? '',
                                          maxLines: 2,
                                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF19313C)),
                                        ),
                                        if (_wishListController.model.value.wishlist![index].inStock != '-1')
                                          Text(
                                            _wishListController.model.value.wishlist![index].inStock.toString(),
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xff858484), fontSize: 16),
                                          ),
                                        if (_wishListController.model.value.wishlist![index].inStock != '-1')
                                          const SizedBox(height: 5),
                                        Spacer(),
                                        Row(
                                          children: [
                                            if (_wishListController.model.value.wishlist![index].discountPrice.toString() !=
                                                _wishListController.model.value.wishlist![index].pPrice.toString())
                                              Flexible(
                                                child: Text.rich(
                                                  profileController.selectedLAnguage.value == "English"
                                                      ? TextSpan(
                                                    text:
                                                    '${_wishListController.model.value.wishlist![index].pPrice.toString().split('.')[0]}.',
                                                    style: GoogleFonts.poppins(
                                                        decorationColor: Colors.red,
                                                        decorationThickness: 2,
                                                        decoration: TextDecoration.lineThrough,
                                                        color: const Color(0xff19313B),
                                                        fontSize: 24,
                                                        fontWeight: FontWeight.w600),
                                                    children: [
                                                      WidgetSpan(
                                                        alignment: PlaceholderAlignment.middle,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            const Text(
                                                              'KWD',
                                                              style: TextStyle(
                                                                fontSize: 8,
                                                                fontWeight: FontWeight.w500,
                                                                color: Color(0xFF19313B),
                                                              ),
                                                            ),
                                                            InkWell(
                                                              onTap: () {},
                                                              child: Text(
                                                                '${_wishListController.model.value.wishlist![index].pPrice.toString().split('.')[1]}',
                                                                style: GoogleFonts.poppins(
                                                                    decorationColor: Colors.red,
                                                                    decorationThickness: 2,
                                                                    color: const Color(0xff19313B),
                                                                    fontSize: 8,
                                                                    fontWeight: FontWeight.w600),
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
                                                        alignment: PlaceholderAlignment.bottom,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            const Text(
                                                              'KWD',
                                                              style: TextStyle(
                                                                fontSize: 8,
                                                                fontWeight: FontWeight.w500,
                                                                color: Color(0xFF19313B),
                                                              ),
                                                            ),
                                                            InkWell(
                                                              onTap: () {},
                                                              child: Text(
                                                                '${_wishListController.model.value.wishlist![index].pPrice.toString().split('.')[1]}',
                                                                style: GoogleFonts.poppins(
                                                                    decorationColor: Colors.red,
                                                                    decorationThickness: 2,
                                                                    color: const Color(0xff19313B),
                                                                    fontSize: 8,
                                                                    fontWeight: FontWeight.w600),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                        '.${_wishListController.model.value.wishlist![index].pPrice.toString().split('.')[0]}',
                                                        style: GoogleFonts.poppins(
                                                            decorationColor: Colors.red,
                                                            decorationThickness: 2,
                                                            decoration: TextDecoration.lineThrough,
                                                            color: const Color(0xff19313B),
                                                            fontSize: 24,
                                                            fontWeight: FontWeight.w600),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text.rich(
                                                profileController.selectedLAnguage.value == "English"
                                                    ? TextSpan(
                                                  text:
                                                  '${_wishListController.model.value.wishlist![index].discountPrice.toString().split('.')[0]}.',
                                                  style: GoogleFonts.poppins(
                                                      color: const Color(0xff19313B),
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.w600),
                                                  children: [
                                                    WidgetSpan(
                                                      alignment: PlaceholderAlignment.middle,
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            'KWD',
                                                            style: TextStyle(
                                                              fontSize: 8,
                                                              fontWeight: FontWeight.w500,
                                                              color: Color(0xFF19313B),
                                                            ),
                                                          ),
                                                          InkWell(
                                                            onTap: () {},
                                                            child: Text(
                                                              '${_wishListController.model.value.wishlist![index].discountPrice.toString().split('.')[1]}',
                                                              style: GoogleFonts.poppins(
                                                                  color: const Color(0xff19313B),
                                                                  fontSize: 8,
                                                                  fontWeight: FontWeight.w600),
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
                                                      alignment: PlaceholderAlignment.bottom,
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            'KWD',
                                                            style: TextStyle(
                                                              fontSize: 8,
                                                              fontWeight: FontWeight.w500,
                                                              color: Color(0xFF19313B),
                                                            ),
                                                          ),
                                                          InkWell(
                                                            onTap: () {},
                                                            child: Text(
                                                              '${_wishListController.model.value.wishlist![index].discountPrice.toString().split('.')[1]}',
                                                              style: GoogleFonts.poppins(
                                                                  color: const Color(0xff19313B),
                                                                  fontSize: 8,
                                                                  fontWeight: FontWeight.w600),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                      '.${_wishListController.model.value.wishlist![index].discountPrice.toString().split('.')[0]}',
                                                      style: GoogleFonts.poppins(
                                                          color: const Color(0xff19313B),
                                                          fontSize: 24,
                                                          fontWeight: FontWeight.w600),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                )
              : const LoadingAnimation();
        }),
      ),
    );
  }
}
