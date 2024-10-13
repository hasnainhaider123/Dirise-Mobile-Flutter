import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/common_colour.dart';
import '../orders/vendor_order_list_screen.dart';

class LatestSalesAppBar extends StatefulWidget {
  const LatestSalesAppBar({super.key});

  @override
  State<LatestSalesAppBar> createState() => _LatestSalesAppBarState();
}

class _LatestSalesAppBarState extends State<LatestSalesAppBar> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.grey.shade100,
      surfaceTintColor: Colors.grey.shade100,
      pinned: true,
      leading: const SizedBox.shrink(),
      leadingWidth: 0,
      primary: false,
      toolbarHeight: 68,
      titleSpacing: 0,
      title: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        height: 68,
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            color: Colors.white),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Latest Sales".tr,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(height: 1.5, color: const Color(0xff454B5C), fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Get.toNamed(VendorOrderList.route);
                    },
                    style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 10)),
                    child: Text(
                      "See All".tr,
                      style: GoogleFonts.poppins(
                          decorationColor: AppTheme.buttonColor,
                          height: 1.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.buttonColor,
                          fontSize: 14),
                    ))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    "${'Order No'}".tr,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: const Color(0xFF52AC1A)),
                  ),
                ),
                const SizedBox(
                  width: 6,
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "Status".tr,
                    style: GoogleFonts.poppins(
                        height: 1.5, fontWeight: FontWeight.w600, fontSize: 14, color: const Color(0xFF52AC1A)),
                  ),
                ),
                const SizedBox(
                  width: 6,
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "Earning".tr,
                    textAlign: TextAlign.end,
                    style: GoogleFonts.poppins(
                        height: 1.5, fontWeight: FontWeight.w600, fontSize: 14, color: const Color(0xFF52AC1A)),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
