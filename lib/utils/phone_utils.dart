import 'package:url_launcher/url_launcher.dart';

/// 08xx -> 628xx, buang spasi/strip/plus.
String normalizePhone(String raw) {
  var d = raw.replaceAll(RegExp(r'[^0-9+]'), '');
  if (d.startsWith('+')) d = d.substring(1);
  if (d.startsWith('0')) d = '62${d.substring(1)}';
  return d;
}

Future<bool> openWhatsApp(String phone, String message) async {
  final uri = Uri.parse(
    'https://wa.me/${normalizePhone(phone)}?text=${Uri.encodeComponent(message)}',
  );
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}