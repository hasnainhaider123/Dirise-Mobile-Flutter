import 'package:dirise/language/app_strings.dart';
import 'package:dirise/utils/styles.dart';
import 'package:dirise/vendor/dashboard/status_widgets.dart';
import 'package:dirise/widgets/loading_animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../controller/profile_controller.dart';
import '../../controller/vendor_controllers/vendor_dashboard_controller.dart';
import '../../controller/vendor_controllers/vendor_profile_controller.dart';
import '../../widgets/dimension_screen.dart';
import '../orders/orderdetailsscreen.dart';
import 'app_bar.dart';
import 'charts.dart';
import 'plans_widget.dart';
import 'sliver_bar.dart';

class VendorDashBoardScreen extends StatefulWidget {
  const VendorDashBoardScreen({Key? key}) : super(key: key);
  static String route = "/VendorDashBoardScreen";

  @override
  State<VendorDashBoardScreen> createState() => _VendorDashBoardScreenState();
}

class _VendorDashBoardScreenState extends State<VendorDashBoardScreen> {
  final controller = Get.put(VendorDashboardController());
  final vendorProfileController = Get.put(VendorProfileController());
  final profileController = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    // vendorProfileController.getVendorDetails();
    controller.getVendorDashBoard();
  }

  @override
  Widget build(BuildContext context) {
    print("Vendor DashBoard: ${controller.modelVendorDashboard.dashboard}");
    return Container(
      color: Colors.grey.shade100,
      child: SafeArea(
        child: Scaffold(
            appBar: const AppBarScreen(),
            backgroundColor: Colors.grey.shade100,
            body: RefreshIndicator(
              onRefresh: () async {
                await controller.getVendorDashBoard();
                await vendorProfileController.getVendorDetails();
              },
              child: Obx(() {
                if (controller.refreshInt.value > 0) {}
                return controller.modelVendorDashboard.dashboard != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: CustomScrollView(
                          shrinkWrap: true,
                          slivers: [
                            const PlanWidget(),
                            const StatusWidget(),
                            thisMonth(),
                            const DashBoardCharts(),
                            const SliverToBoxAdapter(
                              child: SizedBox(
                                height: 14,
                              ),
                            ),
                            const LatestSalesAppBar(),
                            controller.modelVendorDashboard.order!.isNotEmpty
                                ? SliverList.builder(
                                    itemCount: controller
                                        .modelVendorDashboard.order!.length,
                                    itemBuilder: (context, index) {
                                      final order = controller
                                          .modelVendorDashboard.order![index];
                                      if (kDebugMode) {
                                        // print(jsonEncode(order));
                                        // print("SliverList....    $index");
                                      }
                                      return GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          Get.to(() => OrderDetails(
                                                orderId:
                                                    order.orderId.toString(),
                                              ));
                                        },
                                        child: Container(
                                          color: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: AddSize.size5,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    flex: 5,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "#${order.orderId.toString()}",
                                                          style: GoogleFonts.poppins(
                                                              color: const Color(
                                                                  0xFF454B5C),
                                                              height: 1.5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 15),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        if (DateTime.tryParse(order
                                                                .updatedAt
                                                                .toString()) !=
                                                            null)
                                                          Text(
                                                            DateFormat(
                                                                    "HH:mm a - dd MMM, yyyy")
                                                                .format(DateTime
                                                                    .tryParse(order
                                                                        .updatedAt
                                                                        .toString())!),
                                                            style: GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 13,
                                                                color: const Color(
                                                                    0xFF8C9BB2)),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 6,
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      profileController
                                                                  .selectedLAnguage
                                                                  .value ==
                                                              'English'
                                                          ? order.status
                                                              .toString()
                                                              .capitalize!
                                                          : (order.status ==
                                                                  'order placed')
                                                              ? 'تم تقديم الطلب'
                                                              : (order.status ==
                                                                      'in process')
                                                                  ? 'قيد المعالجة'
                                                                  : (order.status ==
                                                                          'packed')
                                                                      ? 'تم التغليف'
                                                                      : (order.status ==
                                                                              'ready to ship')
                                                                          ? 'جاهز للشحن'
                                                                          : (order.status == 'shipped')
                                                                              ? 'تم الشحن'
                                                                              : (order.status == 'out of delivery')
                                                                                  ? 'خرج للتسليم'
                                                                                  : (order.status == 'delivered')
                                                                                      ? 'تم التسليم'
                                                                                      : (order.status == 'cancel requested')
                                                                                          ? 'تم طلب الإلغاء'
                                                                                          : (order.status == 'cancelled')
                                                                                              ? 'تم الإلغاء'
                                                                                              : (order.status == 'return')
                                                                                                  ? 'تم الإرجاع'
                                                                                                  : (order.status == 'refunded')
                                                                                                      ? 'تم استرداد الأموال'
                                                                                                      : (order.status == 'out for reach')
                                                                                                          ? 'خارج التغطية'
                                                                                                          : (order.status == 'order incomplete')
                                                                                                              ? 'الطلب غير مكتمل'
                                                                                                              : (order.status == 'payment pending')
                                                                                                                  ? 'الدفع معلق'
                                                                                                                  : (order.status == 'payment failed')
                                                                                                                      ? 'فشل الدفع'
                                                                                                                      : (order.status == 'request return order')
                                                                                                                          ? 'طلب إرجاع الطلب'
                                                                                                                          : order.status.toString().capitalize!,
                                                      style: GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14,
                                                          color: const Color(
                                                              0xFFFFB26B)),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 6,
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      "kwd${order.totalPrice}",
                                                      textAlign: TextAlign.end,
                                                      style: GoogleFonts.poppins(
                                                          height: 1.5,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 15,
                                                          color: const Color(
                                                              0xFF454B5C)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: AddSize.size5,
                                              ),
                                              const Divider(
                                                color: Color(0xffEFEFEF),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    })
                                : SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, bottom: 30),
                                      child: Text(
                                        AppStrings.salesNotAvailable.tr,
                                        style: normalStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      )
                    : const LoadingAnimation();
              }),
            )),
      ),
    );
  }

  SliverToBoxAdapter thisMonth() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 18,
          ),
          Text(
            "This Month Report".tr,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF292F45)),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
