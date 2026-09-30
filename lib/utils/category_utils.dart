import 'package:hugeicons/hugeicons.dart';
import 'package:laundryan/data/app_database.dart';
import 'package:laundryan/l10n/app_localizations.dart';

const Map<String, List<List<dynamic>>> categoryIcons = {
  'tshirt': HugeIcons.strokeRoundedShirt01,
  'shirt': HugeIcons.strokeRoundedShirt01,
  'outerwear': HugeIcons.strokeRoundedHoodie,
  'longPants': HugeIcons.strokeRoundedJoggerPants,
  'shorts': HugeIcons.strokeRoundedShortsPants,
  'skirt': HugeIcons.strokeRoundedDress01,
  'underwear': HugeIcons.strokeRoundedUnderpants01,
  'socks': HugeIcons.strokeRoundedSocks,
  'bag': HugeIcons.strokeRoundedShoppingBag01,
  'star': HugeIcons.strokeRoundedStar,
  'heart': HugeIcons.strokeRoundedFavourite,
  'home': HugeIcons.strokeRoundedHome01,
};

List<List<dynamic>> iconFor(String key) =>
    categoryIcons[key] ?? HugeIcons.strokeRoundedShoppingBag01;



String categoryName(Category c, AppLocalizations l10n) {
  final name = c.name;
  if (name != null && name.isNotEmpty) return name;
  switch (c.defaultKey) {
    case 'tshirt':
      return l10n.categoryTshirt;
    case 'shirt':
      return l10n.categoryShirt;
    case 'outerwear':
      return l10n.categoryOuterwear;
    case 'longPants':
      return l10n.categoryLongPants;
    case 'shorts':
      return l10n.categoryShorts;
    case 'skirt':
      return l10n.categorySkirt;
    case 'underwear':
      return l10n.categoryUnderwear;
    case 'socks':
      return l10n.categorySocks;
    default:
      return '';
  }
}