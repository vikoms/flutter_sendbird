import 'package:get/get.dart';

import '../bindings/channel_list_binding.dart';
import '../bindings/home_binding.dart';
import '../bindings/product_binding.dart';
import '../channel_list_screen.dart';
import '../home_screen.dart';
import '../product_list_page.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: Routes.home,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.channels,
      page: () => const ChannelListScreen(),
      binding: ChannelListBinding(),
    ),
    GetPage(
      name: Routes.products,
      page: () => const ProductListPage(),
      binding: ProductBinding(),
    ),
  ];
}
