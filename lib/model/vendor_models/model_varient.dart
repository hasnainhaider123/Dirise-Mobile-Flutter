import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';

import 'model_attribute.dart';

class AddMultipleItems {
  Map<String, GetAttrvalues>? attributes = {};
  File variantImages = File("");
  bool live = false;
  final GlobalKey variantImageKey = GlobalKey();
  TextEditingController variantSku = TextEditingController();
  TextEditingController variantPrice = TextEditingController();
  TextEditingController variantStock = TextEditingController();
  TextEditingController shortDescription  = TextEditingController();
  TextEditingController longDescription = TextEditingController();

  AddMultipleItems({
    this.attributes,

  });

  AddMultipleItems.fromServer({
    required Map<String, GetAttrvalues> attr,
    required String filePath,
    required String variantSkuLive,
    required String variantPriceLive,
    required String variantStockLive,
    required String shortDescriptionLive,
    required String longDescriptionLive,

  }){
    attributes = attr;
    variantSku.text = variantSkuLive;
    variantPrice.text = variantPriceLive;
    variantStock.text = variantStockLive;
    shortDescription.text = shortDescriptionLive;
    longDescription.text = longDescriptionLive;
    variantImages = File(filePath);
    live = true;
  }

}