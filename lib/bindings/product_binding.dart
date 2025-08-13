import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../controllers/product_controller.dart';
import '../services/product_service.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    final dio = Dio();
    Get.lazyPut<ProductService>(() => ProductService(dio));
    Get.lazyPut<ProductController>(() => ProductController());
  }
}
