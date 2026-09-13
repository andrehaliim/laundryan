import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_info_provider.g.dart';

/// Baca versi app langsung dari pubspec.yaml (via package_info_plus),
/// jadi nggak perlu update manual tiap kali version di pubspec berubah.
@riverpod
Future<String> appInfo(Ref ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.appName} v${info.version}+${info.buildNumber}';
}