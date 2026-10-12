import 'package:hugeicons/hugeicons.dart';
import 'package:laundryan/data/app_database.dart';
import 'package:laundryan/l10n/app_localizations.dart';

const Map<String, List<List<dynamic>>> categoryIcons = {
  'shirt': HugeIcons.strokeRoundedShirt01,
  'tshirt': HugeIcons.strokeRoundedTShirt,
  'longSleeves': HugeIcons.strokeRoundedJumpers,
  'sleeveless': HugeIcons.strokeRoundedSleeveless,
  'tankTop': HugeIcons.strokeRoundedTankTop,
  'turtleNeck': HugeIcons.strokeRoundedTurtleNeck,
  'hoodie': HugeIcons.strokeRoundedHoodie,
  'cardigan': HugeIcons.strokeRoundedCardigan,
  'vest': HugeIcons.strokeRoundedVest,
  'suit': HugeIcons.strokeRoundedSuit01,
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
    case 'shirt':
      return l10n.categoryShirt;
    case 'tshirt':
      return l10n.categoryTshirt;
    case 'longSleeves':
      return l10n.categoryLongSleeves;
    case 'sleeveless':
      return l10n.categorySleeveless;
    case 'tankTop':
      return l10n.categoryTankTop;
    case 'turtleNeck':
      return l10n.categoryTurtleNeck;
    case 'hoodie':
      return l10n.categoryHoodie;
    case 'cardigan':
      return l10n.categoryCardigan;
    case 'vest':
      return l10n.categoryVest;
    case 'suit':
      return l10n.categorySuit;
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
    case 'bag':
      return l10n.categoryBag;
    case 'star':
      return l10n.categoryStar;
    case 'heart':
      return l10n.categoryHeart;
    case 'home':
      return l10n.categoryHome;
    default:
      return '';
  }
}

String iconLabel(String key, AppLocalizations l10n) {
  switch (key) {
    case 'shirt':
      return l10n.categoryShirt;
    case 'tshirt':
      return l10n.categoryTshirt;
    case 'longSleeves':
      return l10n.categoryLongSleeves;
    case 'sleeveless':
      return l10n.categorySleeveless;
    case 'tankTop':
      return l10n.categoryTankTop;
    case 'turtleNeck':
      return l10n.categoryTurtleNeck;
    case 'hoodie':
      return l10n.categoryHoodie;
    case 'cardigan':
      return l10n.categoryCardigan;
    case 'vest':
      return l10n.categoryVest;
    case 'suit':
      return l10n.categorySuit;
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
    case 'bag':
      return l10n.categoryBag;
    case 'star':
      return l10n.categoryStar;
    case 'heart':
      return l10n.categoryHeart;
    case 'home':
      return l10n.categoryHome;
    default:
      return key;
  }
}
