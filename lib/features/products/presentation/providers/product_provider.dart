import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/products/domain/domain.dart';
import 'package:teslo_shop/features/products/presentation/providers/providers.dart';

final productProvider = StateNotifierProvider.autoDispose
    .family<ProductNotifier, ProductState, String>((ref, productId) {
  final repository = ref.watch(productsRepositoryProvider);

  return ProductNotifier(
    repository: repository,
    productId: productId,
  );
});

class ProductNotifier extends StateNotifier<ProductState> {
  final ProductsRepository repository;

  ProductNotifier({
    required this.repository,
    required String productId,
  }) : super(ProductState(id: productId)) {
    loadProduct();
  }

  Future<void> loadProduct() async {
    try {
      if (state.id == 'new') {
        state = state.copyWith(
          isLoading: false,
          product: _newEmptyProduct(),
        );

        return;
      }

      final product = await repository.getProductById(state.id);

      state = state.copyWith(
        isLoading: false,
        product: product,
      );
    } catch (e) {
      print(e);
    }
  }

  Product _newEmptyProduct() {
    return Product(
      id: 'new',
      title: '',
      price: 0.0,
      description: '',
      slug: '',
      stock: 0,
      sizes: [],
      gender: '',
      tags: [],
      images: [],
    );
  }
}

class ProductState {
  final bool isLoading;
  final bool isSaving;
  final String id;
  final Product? product;

  ProductState({
    required this.id,
    this.isLoading = true,
    this.isSaving = false,
    this.product,
  });

  ProductState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? id,
    Product? product,
  }) =>
      ProductState(
        id: id ?? this.id,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        product: product ?? this.product,
      );
}
