import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../controller/profile_controller.dart';
import '../../model/vendor_models/model_vendor_orders.dart';
import '../../widgets/dimension_screen.dart';
import 'orderdetailsscreen.dart';

class OrderTile extends StatefulWidget {
  const OrderTile({super.key, required this.order});
  final OrderData order;

  @override
  _OrderTileState createState() => _OrderTileState();
}

class _OrderTileState extends State<OrderTile> {
  final profileController = Get.put(ProfileController());
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => OrderDetails(orderId: widget.order.orderId.toString()));
        log('order details: ${widget.order.toJson()}');
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            SizedBox(
              height: AddSize.size5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "#${widget.order.orderId.toString()}",
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF454B5C),
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                            fontSize: 15),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      if (DateTime.tryParse(
                              widget.order.updatedAt.toString()) !=
                          null)
                        Text(
                          DateFormat("HH:mm a - dd MMM, yyyy").format(
                              DateTime.tryParse(
                                  widget.order.updatedAt.toString())!),
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: const Color(0xFF8C9BB2)),
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
                    profileController.selectedLAnguage.value == 'English'
                        ? widget.order.status.toString().capitalize!
                        : (widget.order.status == 'order placed')
                            ? 'تم تقديم الطلب'
                            : (widget.order.status == 'in process')
                                ? 'قيد المعالجة'
                                : (widget.order.status == 'packed')
                                    ? 'تم التغليف'
                                    : (widget.order.status == 'ready to ship')
                                        ? 'جاهز للشحن'
                                        : (widget.order.status == 'shipped')
                                            ? 'تم الشحن'
                                            : (widget.order.status ==
                                                    'out of delivery')
                                                ? 'خرج للتسليم'
                                                : (widget.order.status ==
                                                        'delivered')
                                                    ? 'تم التسليم'
                                                    : (widget.order.status ==
                                                            'cancel requested')
                                                        ? 'تم طلب الإلغاء'
                                                        : (widget.order
                                                                    .status ==
                                                                'cancelled')
                                                            ? 'تم الإلغاء'
                                                            : (widget.order
                                                                        .status ==
                                                                    'return')
                                                                ? 'تم الإرجاع'
                                                                : (widget.order
                                                                            .status ==
                                                                        'refunded')
                                                                    ? 'تم استرداد الأموال'
                                                                    : (widget.order.status ==
                                                                            'out for reach')
                                                                        ? 'خارج التغطية'
                                                                        : (widget.order.status ==
                                                                                'order incomplete')
                                                                            ? 'الطلب غير مكتمل'
                                                                            : (widget.order.status == 'payment pending')
                                                                                ? 'الدفع معلق'
                                                                                : (widget.order.status == 'payment failed')
                                                                                    ? 'فشل الدفع'
                                                                                    : (widget.order.status == 'request return order')
                                                                                        ? 'طلب إرجاع الطلب'
                                                                                        : widget.order.status.toString().capitalize!,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: const Color(0xFFFFB26B)),
                  ),
                ),
                const SizedBox(
                  width: 6,
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "kwd${widget.order.totalPrice}",
                    textAlign: TextAlign.end,
                    style: GoogleFonts.poppins(
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: const Color(0xFF454B5C)),
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
  }
}
