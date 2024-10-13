import 'dart:convert';
import 'package:dirise/model/approved_model_.dart';
import 'package:dirise/model/common_modal.dart';
import 'package:dirise/repository/repository.dart';
import 'package:dirise/utils/api_constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../model/vendor_models/model_vendor_orders.dart';
import '../../model/vendor_models/model_vendor_product_list.dart';

enum ProductTypes{
  all,
  virtual,
  simple,
  booking,
  variant,
}

class ProductsController extends GetxController {
  final Repositories repositories = Repositories();
  RxInt refreshInt = 0.obs;
  bool apiLoaded = false;
  bool apiLoaded1 = false;

  ModelProductsList model = ModelProductsList(pendingProduct: []);
  ApprovedModel model1 = ApprovedModel(approveProduct: []);
  Rx<ModelVendorOrders> modelVendorOrders = ModelVendorOrders().obs;

  void get updateUI => refreshInt.value = DateTime.now().millisecondsSinceEpoch;

  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController searchOrderController = TextEditingController();

  int page = 1;
  int page1 = 1;
  String? selectedValue;
  String? selectedValueSelect;
  String? selectedValue1;

  final List<String> dropdownItems = [
    'All',
    'Giveaway',
    'Product',
    'Job',
    'Service',
    'Virtual',
  ];
  final List<String> dropdownItems1 = [
    'All',
    'Giveaway',
    'Product',
    'Job',
    'Service',
    'Virtual',
  ];
  final List<String> dropdownItems1Arab = [
    'الجميع',
    'يتبرع',
    'منتج',
    'وظيفة',
    'خدمة',
    'افتراضي',
  ];
  Future getProductList({bool? reset,context}) async {
    String url = ApiUrls.myProductsListUrl;
    List<String> params = [];
    if(textEditingController.text.trim().isNotEmpty){
      params.add("search=${textEditingController.text.trim()}");
    }
    params.add("page=$page");
    if (selectedValue1 != null && selectedValue1.toString().isNotEmpty) {
      params.add("filter_type=${selectedValue1 == "All"?"":selectedValue1.toString()}");
    }
    if(params.isNotEmpty){
      url = "$url?${params.join("&")}";
    }
    await repositories.getApi(url: "$url&limit=50",context: context).then((value) {
      apiLoaded = true;
      model = ModelProductsList.fromJson(jsonDecode(value));
      updateUI;
    });
  }
  Future getProductList1({bool? reset,context}) async {
    String url = ApiUrls.myApproved;
    List<String> params = [];
    if(textEditingController.text.trim().isNotEmpty){
      params.add("search=${textEditingController.text.trim()}");
    }
    params.add("page=$page1");
    if (selectedValue != null && selectedValue.toString().isNotEmpty) {
      if(selectedValue == 'الجميع'){
        selectedValueSelect = 'All';
      }else if(selectedValue == 'يتبرع'){
        selectedValueSelect = 'Giveaway';
      }else if(selectedValue == 'منتج'){
        selectedValueSelect = 'Product';
      }else if(selectedValue == 'وظيفة'){
        selectedValueSelect = 'Job';
      }else if(selectedValue == 'خدمة'){
        selectedValueSelect = 'Service';
      }else if(selectedValue == 'افتراضي'){
        selectedValueSelect = 'Virtual';
      }
      params.add("filter_type=${selectedValue == "All"?"":selectedValueSelect.toString()}");
      print("value slected"+selectedValueSelect.toString());
    }
    if(params.isNotEmpty){
      url = "$url?${params.join("&")}";
    }
    await repositories.getApi(url: "$url&limit=50",context: context).then((value) {
      apiLoaded1 = true;
      model1 = ApprovedModel.fromJson(jsonDecode(value));
      updateUI;
    });
  }
  List<OrderData> data = [];
  Future getProductOrderList({bool? reset,context}) async {
    String url = ApiUrls.searchOrderList;
    List<String> params = [];
    if(searchOrderController.text.trim().isNotEmpty){
      params.add("search=${searchOrderController.text.trim()}");
    }
    params.add("page=$page1");
    if (selectedValue != null && selectedValue.toString().isNotEmpty) {
      params.add("keyword=${selectedValue == "All"?"":selectedValue.toString()}");
      print("value slected"+selectedValue.toString());
    }
    if(params.isNotEmpty){
      url = "$url?${params.join("&")}";
    }
    await repositories.getApi(url: "$url&limit=50",context: context).then((value) {
      apiLoaded1 = true;
      modelVendorOrders.value = ModelVendorOrders.fromJson(jsonDecode(value));
      data.addAll( modelVendorOrders.value.order!.data!);
      updateUI;
    });
  }

  Future updateProductStatus({
    required BuildContext context,
    required String productID,
    required String IsPublish,
    required Function(bool gg) changed,
  }) async {
    await repositories
        .postApi(url: ApiUrls.updateProductStatusUrl, mapData: {"product_id": productID,'is_publish':IsPublish}, context: context)
        .then((value) {
      ModelCommonResponse response = ModelCommonResponse.fromJson(jsonDecode(value));
      if (response.status == true) {
        changed(true);
      }
      showToast(response.message.toString());
      updateUI;
    });
    changed(false);
  }
}
