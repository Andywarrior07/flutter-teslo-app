import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/products/domain/domain.dart';
import 'package:teslo_shop/features/products/presentation/providers/providers.dart';

final productsProvider = StateNotifierProvider<ProductsNotifier, ProductsState>(
  (ref) {
    final productsRepository = ref.watch(productsRepositoryProvider);

    return ProductsNotifier(repository: productsRepository);
  },
);

class ProductsNotifier extends StateNotifier<ProductsState> {
  final ProductsRepository repository;

  ProductsNotifier({required this.repository}) : super(ProductsState()) {
    loadNextPage();
  }

  Future<bool> createUpdateProduct(Map<String, dynamic> productLike) async {
    try {
      final product = await repository.createUpdateProduct(productLike);
      final isProductInList = state.products.any((p) => p.id == product.id);

      if (!isProductInList) {
        state = state.copyWith(products: [...state.products, product]);

        return true;
      }

      state = state.copyWith(
        products: state.products
            .map((p) => p.id == product.id ? product : p)
            .toList(),
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future loadNextPage() async {
    if (state.isLoading || state.isLastPage) return;

    state = state.copyWith(isLoading: true);

    final products = await repository.getProductsByPage(
        limit: state.limit, offset: state.offset);

    if (products.isEmpty) {
      state = state.copyWith(isLoading: false, isLastPage: true);

      return;
    }

    state = state.copyWith(
      isLastPage: false,
      isLoading: false,
      offset: state.offset + 10,
      products: [...state.products, ...products],
    );
  }
}

class ProductsState {
  final bool isLastPage;
  final bool isLoading;
  final int limit;
  final int offset;
  final List<Product> products;

  ProductsState({
    this.isLastPage = false,
    this.isLoading = false,
    this.limit = 10,
    this.offset = 0,
    this.products = const [],
  });

  ProductsState copyWith({
    bool? isLastPage,
    bool? isLoading,
    int? limit,
    int? offset,
    List<Product>? products,
  }) =>
      ProductsState(
        isLastPage: isLastPage ?? this.isLastPage,
        isLoading: isLoading ?? this.isLoading,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        products: products ?? this.products,
      );
}
