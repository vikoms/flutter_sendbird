import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/product.dart';

part 'product_service.g.dart';

@RestApi(baseUrl: 'https://fakestoreapi.com')
abstract class ProductService {
  factory ProductService(Dio dio, {String baseUrl}) = _ProductService;

  @GET('/products')
  Future<List<Product>> getProducts();
}
