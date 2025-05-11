// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoryViewModelHash() => r'5f5cd39ac523c0ab70949bc163b39a4b7d5c61e3';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$CategoryViewModel
    extends BuildlessAutoDisposeAsyncNotifier<List<BookModel>> {
  late final String category;

  FutureOr<List<BookModel>> build({
    required String category,
  });
}

/// See also [CategoryViewModel].
@ProviderFor(CategoryViewModel)
const categoryViewModelProvider = CategoryViewModelFamily();

/// See also [CategoryViewModel].
class CategoryViewModelFamily extends Family<AsyncValue<List<BookModel>>> {
  /// See also [CategoryViewModel].
  const CategoryViewModelFamily();

  /// See also [CategoryViewModel].
  CategoryViewModelProvider call({
    required String category,
  }) {
    return CategoryViewModelProvider(
      category: category,
    );
  }

  @override
  CategoryViewModelProvider getProviderOverride(
    covariant CategoryViewModelProvider provider,
  ) {
    return call(
      category: provider.category,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'categoryViewModelProvider';
}

/// See also [CategoryViewModel].
class CategoryViewModelProvider extends AutoDisposeAsyncNotifierProviderImpl<
    CategoryViewModel, List<BookModel>> {
  /// See also [CategoryViewModel].
  CategoryViewModelProvider({
    required String category,
  }) : this._internal(
          () => CategoryViewModel()..category = category,
          from: categoryViewModelProvider,
          name: r'categoryViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$categoryViewModelHash,
          dependencies: CategoryViewModelFamily._dependencies,
          allTransitiveDependencies:
              CategoryViewModelFamily._allTransitiveDependencies,
          category: category,
        );

  CategoryViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.category,
  }) : super.internal();

  final String category;

  @override
  FutureOr<List<BookModel>> runNotifierBuild(
    covariant CategoryViewModel notifier,
  ) {
    return notifier.build(
      category: category,
    );
  }

  @override
  Override overrideWith(CategoryViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: CategoryViewModelProvider._internal(
        () => create()..category = category,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        category: category,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<CategoryViewModel, List<BookModel>>
      createElement() {
    return _CategoryViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryViewModelProvider && other.category == category;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CategoryViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<List<BookModel>> {
  /// The parameter `category` of this provider.
  String get category;
}

class _CategoryViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<CategoryViewModel,
        List<BookModel>> with CategoryViewModelRef {
  _CategoryViewModelProviderElement(super.provider);

  @override
  String get category => (origin as CategoryViewModelProvider).category;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
