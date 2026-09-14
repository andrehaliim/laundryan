// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'59cce38d45eeaba199eddd097d8e149d66f9f3e1';

@ProviderFor(wardrobeDao)
final wardrobeDaoProvider = WardrobeDaoProvider._();

final class WardrobeDaoProvider
    extends $FunctionalProvider<WardrobeDao, WardrobeDao, WardrobeDao>
    with $Provider<WardrobeDao> {
  WardrobeDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wardrobeDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wardrobeDaoHash();

  @$internal
  @override
  $ProviderElement<WardrobeDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WardrobeDao create(Ref ref) {
    return wardrobeDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WardrobeDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WardrobeDao>(value),
    );
  }
}

String _$wardrobeDaoHash() => r'38e2ebe5da11a0a5c452733e2d509377f1700d9a';

@ProviderFor(sessionDao)
final sessionDaoProvider = SessionDaoProvider._();

final class SessionDaoProvider
    extends $FunctionalProvider<SessionDao, SessionDao, SessionDao>
    with $Provider<SessionDao> {
  SessionDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionDaoHash();

  @$internal
  @override
  $ProviderElement<SessionDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SessionDao create(Ref ref) {
    return sessionDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionDao>(value),
    );
  }
}

String _$sessionDaoHash() => r'f2b054de8962e1f7b31602618bcd6121e272adbb';
