part of 'product_service.dart';

class _ProductService implements ProductService {
  _ProductService(this._dio, {this.baseUrl}) {
    baseUrl ??= 'https://fakestoreapi.com';
  }

  final Dio _dio;

  String? baseUrl;

  @override
  Future<List<Product>> getProducts() async {
    final response = await _dio.get<List<dynamic>>(
      '$baseUrl/products',
    );
    return response.data!
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
