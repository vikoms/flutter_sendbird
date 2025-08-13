import 'package:get/get.dart';

import '../models/product.dart';
import '../services/product_service.dart';

class ProductController extends GetxController {
  final ProductService _service = Get.find<ProductService>();

  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final result = await _service.getProducts();
      products.assignAll(result);
    } finally {
      isLoading.value = false;
    }
  }
}
