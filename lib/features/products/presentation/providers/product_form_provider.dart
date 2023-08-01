import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:teslo_shop/config/constants/environment.dart';
import 'package:teslo_shop/features/products/domain/domain.dart';
import 'package:teslo_shop/features/products/presentation/providers/providers.dart';
import 'package:teslo_shop/shared/infrastructure/inputs/inputs.dart';

final productFormProvider = StateNotifierProvider.autoDispose
    .family<ProductFormNotifier, ProductFormState, Product>((ref, product) {
  final onSubmitCallback =
      ref.watch(productsProvider.notifier).createUpdateProduct;

  return ProductFormNotifier(
    product: product,
    onSubmitCallback: onSubmitCallback,
  );
});

class ProductFormNotifier extends StateNotifier<ProductFormState> {
  final Future<bool> Function(Map<String, dynamic> productLike)?
      onSubmitCallback;

  ProductFormNotifier({
    this.onSubmitCallback,
    required Product product,
  }) : super(ProductFormState(
          id: product.id,
          price: Price.dirty(product.price),
          slug: Slug.dirty(product.slug),
          stock: Stock.dirty(product.stock),
          title: Title.dirty(product.title),
          sizes: product.sizes,
          gender: product.gender,
          description: product.description,
          tags: product.tags.join(','),
          images: product.images,
        ));

  Future<bool> onFormSubmit() async {
    _touchedEverything();

    if (!state.isFormValid) return false;

    if (onSubmitCallback == null) return false;

    final productLike = {
      'id': state.id,
      'price': state.price.value,
      'slug': state.slug.value,
      'stock': state.stock.value,
      'title': state.title.value,
      'sizes': state.sizes,
      'gender': state.gender,
      'description': state.description,
      'tags': state.tags.split(','),
      'images': state.images
          .map((img) =>
              img.replaceAll('${Environment.apiUrl}/files/product/', ''))
          .toList(),
    };

    try {
      return await onSubmitCallback!(productLike);
    } catch (e) {
      return false;
    }
  }

  void _touchedEverything() {
    state = state.copyWith(
      isFormValid: Formz.validate([
        Price.dirty(state.price.value),
        Slug.dirty(state.slug.value),
        Stock.dirty(state.stock.value),
        Title.dirty(state.title.value),
      ]),
    );
  }

  void updateProductImages(String imagePath) {
    state = state.copyWith(images: [
      ...state.images,
      imagePath,
    ]);
  }

  void onTitleChanged(String value) {
    state = state.copyWith(
      title: Title.dirty(value),
      isFormValid: Formz.validate([
        Price.dirty(state.price.value),
        Slug.dirty(state.slug.value),
        Stock.dirty(state.stock.value),
        Title.dirty(value),
      ]),
    );
  }

  void onSlugChanged(String value) {
    state = state.copyWith(
      slug: Slug.dirty(value),
      isFormValid: Formz.validate([
        Price.dirty(state.price.value),
        Slug.dirty(value),
        Stock.dirty(state.stock.value),
        Title.dirty(state.title.value),
      ]),
    );
  }

  void onPriceChanged(double value) {
    state = state.copyWith(
      price: Price.dirty(value),
      isFormValid: Formz.validate([
        Price.dirty(value),
        Slug.dirty(state.slug.value),
        Stock.dirty(state.stock.value),
        Title.dirty(state.title.value),
      ]),
    );
  }

  void onStockChanged(int value) {
    state = state.copyWith(
      stock: Stock.dirty(value),
      isFormValid: Formz.validate([
        Price.dirty(state.price.value),
        Slug.dirty(state.slug.value),
        Stock.dirty(value),
        Title.dirty(state.title.value),
      ]),
    );
  }

  void onSizesChanged(List<String> sizes) {
    state = state.copyWith(sizes: sizes);
  }

  void onGenderChanged(String gender) {
    state = state.copyWith(gender: gender);
  }

  void onDescriptionChanged(String value) {
    state = state.copyWith(description: value);
  }

  void onTagsChanged(String value) {
    state = state.copyWith(tags: value);
  }

  void onImagesChanged(List<String> images) {
    state = state.copyWith(images: images);
  }
}

class ProductFormState {
  final bool isFormValid;
  final String? id;
  final Price price;
  final Slug slug;
  final Stock stock;
  final Title title;
  final List<String> sizes;
  final String gender;
  final String description;
  final String tags;
  final List<String> images;

  ProductFormState({
    this.isFormValid = false,
    this.id,
    this.price = const Price.dirty(0.0),
    this.slug = const Slug.dirty(''),
    this.stock = const Stock.dirty(0),
    this.title = const Title.dirty(''),
    this.gender = 'men',
    this.description = '',
    this.tags = '',
    this.sizes = const [],
    this.images = const [],
  });

  ProductFormState copyWith({
    bool? isFormValid,
    String? id,
    Price? price,
    Slug? slug,
    Stock? stock,
    Title? title,
    List<String>? sizes,
    String? gender,
    String? description,
    String? tags,
    List<String>? images,
  }) =>
      ProductFormState(
        isFormValid: isFormValid ?? this.isFormValid,
        id: id ?? this.id,
        price: price ?? this.price,
        slug: slug ?? this.slug,
        stock: stock ?? this.stock,
        title: title ?? this.title,
        gender: gender ?? this.gender,
        description: description ?? this.description,
        tags: tags ?? this.tags,
        sizes: sizes ?? this.sizes,
        images: images ?? this.images,
      );
}
