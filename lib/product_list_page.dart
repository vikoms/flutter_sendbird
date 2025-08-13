import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'base_view.dart';
import 'controllers/product_controller.dart';

class ProductListPage extends BaseView<ProductController> {
  const ProductListPage({super.key});

  @override
  Widget buildView(BuildContext context, ProductController controller) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: controller.products.length,
          itemBuilder: (context, index) {
            final product = controller.products[index];
            return ListTile(
              leading: Image.network(
                product.image,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
              title: Text(product.title),
              subtitle: Text('\$${product.price}'),
            );
          },
        );
      }),
    );
  }
}
