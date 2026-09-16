import 'package:hugeicons/hugeicons.dart';

class WardrobeCategoryModel {
  final String name;
  final String label;
  final List<List<dynamic>> icon;

  const WardrobeCategoryModel({
    required this.name,
    required this.label,
    required this.icon,
  });
}

const wardrobeCategories = [
  WardrobeCategoryModel(
    name: 'Kaos / T-Shirt',
    label: 'Kaos',
    icon: HugeIcons.strokeRoundedShirt01,
  ),
  WardrobeCategoryModel(
    name: 'Kemeja',
    label: 'Kemeja',
    icon: HugeIcons.strokeRoundedKurta,
  ),
  WardrobeCategoryModel(
    name: 'Celana Panjang',
    label: 'C. Panjang',
    icon: HugeIcons.strokeRoundedJoggerPants,
  ),
  WardrobeCategoryModel(
    name: 'Celana Pendek',
    label: 'C. Pendek',
    icon: HugeIcons.strokeRoundedBoxer,
  ),
  WardrobeCategoryModel(
    name: 'Jaket / Hoodie',
    label: 'Jaket',
    icon: HugeIcons.strokeRoundedHoodie,
  ),
  WardrobeCategoryModel(
    name: 'Kaos Kaki',
    label: 'Kaos Kaki',
    icon: HugeIcons.strokeRoundedSocks,
  ),
  WardrobeCategoryModel(
    name: 'Pakaian Dalam',
    label: 'Underwear',
    icon: HugeIcons.strokeRoundedUnderpants01,
  ),
  WardrobeCategoryModel(
    name: 'Lainnya',
    label: 'Other',
    icon: HugeIcons.strokeRoundedHanger,
  ),
];
