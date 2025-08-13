import 'package:get/get.dart';

import '../bindings/channel_list_binding.dart';
import '../bindings/home_binding.dart';
import '../channel_list_screen.dart';
import '../home_screen.dart';
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
  ];
}
