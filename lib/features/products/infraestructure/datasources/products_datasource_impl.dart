import 'package:dio/dio.dart';
import 'package:teslo_shop/config/constants/environment.dart';
import 'package:teslo_shop/features/products/domain/domain.dart';
import 'package:teslo_shop/features/products/infraestructure/errors/product_errors.dart';
import 'package:teslo_shop/features/products/infraestructure/mappers/product_mapper.dart';

class ProductsDatasourceImpl extends ProductsDatasource {
  final String accessToken;
  late final Dio dio;

  ProductsDatasourceImpl({required this.accessToken})
      : dio = Dio(
          BaseOptions(
            baseUrl: Environment.apiUrl,
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          ),
        );

  @override
  Future<Product> createUpdateProduct(Map<String, dynamic> productLike) async {
    try {
      final String? productId =
          productLike['id'] != 'new' ? productLike['id'] : null;
      final String url =
          productId == null ? '/products' : '/products/$productId';

      productLike.remove('id');
      productLike['images'] = await _uploadImages(productLike['images']);

      if (productId != null) {
        final response = await dio.patch(url, data: productLike);
        final product = ProductMapper.jsonToEntity(response.data);

        return product;
      }

      final response = await dio.post(
        url,
        data: productLike,
      );
      final product = ProductMapper.jsonToEntity(response.data);

      return product;
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    try {
      final response = await dio.get('/products/$id');
      final product = ProductMapper.jsonToEntity(response.data);

      return product;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) {
        throw ProductNotFound();
      }

      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<Product>> getProductByTerm(String term) {
    // TODO: implement getProductByTerm
    throw UnimplementedError();
  }

  @override
  Future<List<Product>> getProductsByPage(
      {int limit = 10, int offset = 0}) async {
    final response =
        await dio.get<List>('/products?limit=$limit&offset=$offset');
    final List<Product> products = [];

    for (final product in response.data ?? []) {
      products.add(ProductMapper.jsonToEntity(product));
    }

    return products;
  }

  Future<String> _uploadImage(String image) async {
    try {
      final fileName = image.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(image, filename: fileName),
      });

      final response = await dio.post('/files/product', data: formData);

      return response.data['image'];
    } catch (e) {
      throw Exception();
    }
  }

  Future<List<String>> _uploadImages(List<String> images) async {
    final imagesToUpload = images.where((img) => img.startsWith('/')).toList();
    final imagesToIgnore = images.where((img) => !img.startsWith('/')).toList();

    if (imagesToUpload.isEmpty) return images;

    final List<Future<String>> uploadJob =
        imagesToUpload.map(_uploadImage).toList();
    final newImages = await Future.wait(uploadJob);

    return [...imagesToIgnore, ...newImages];
  }
}
