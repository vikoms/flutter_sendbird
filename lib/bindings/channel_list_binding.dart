import 'package:get/get.dart';

import '../controllers/channel_list_controller.dart';

class ChannelListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChannelListController>(() => ChannelListController());
  }
}
