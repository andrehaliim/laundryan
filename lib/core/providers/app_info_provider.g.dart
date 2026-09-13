// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Baca versi app langsung dari pubspec.yaml (via package_info_plus),
/// jadi nggak perlu update manual tiap kali version di pubspec berubah.

@ProviderFor(appInfo)
final appInfoProvider = AppInfoProvider._();

/// Baca versi app langsung dari pubspec.yaml (via package_info_plus),
/// jadi nggak perlu update manual tiap kali version di pubspec berubah.

final class AppInfoProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// Baca versi app langsung dari pubspec.yaml (via package_info_plus),
  /// jadi nggak perlu update manual tiap kali version di pubspec berubah.
  AppInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appInfoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appInfoHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appInfo(ref);
  }
}

String _$appInfoHash() => r'243464b8ffcee95ea7d41242598cf59569105b7f';
