import 'package:flutter/material.dart';
import 'package:green_share/l10n/app_localizations.dart';

class LocalizationHelpers {
  static String getCategory(BuildContext context, String category) {
    final l10n = AppLocalizations.of(context)!;
    switch (category) {
      case 'Clothing': return l10n.categoryClothing;
      case 'Furniture': return l10n.categoryFurniture;
      case 'Books': return l10n.categoryBooks;
      case 'Electronics': return l10n.categoryElectronics;
      case 'Toys': return l10n.categoryToys;
      case 'Other': return l10n.categoryOther;
      default: return category;
    }
  }

  static String getCondition(BuildContext context, String condition) {
    final l10n = AppLocalizations.of(context)!;
    switch (condition) {
      case 'New': return l10n.conditionNew;
      case 'Like New': return l10n.conditionLikeNew;
      case 'Good': return l10n.conditionGood;
      case 'Fair': return l10n.conditionFair;
      default: return condition;
    }
  }

  static String getCity(BuildContext context, String city) {
    final l10n = AppLocalizations.of(context)!;
    switch (city) {
      case 'Amman': return l10n.cityAmman;
      case 'Zarqa': return l10n.cityZarqa;
      case 'Irbid': return l10n.cityIrbid;
      case 'Aqaba': return l10n.cityAqaba;
      case 'Madaba': return l10n.cityMadaba;
      case 'Karak': return l10n.cityKarak;
      case 'Ma\'an': return l10n.cityMaan;
      case 'Tafilah': return l10n.cityTafilah;
      case 'Ajloun': return l10n.cityAjloun;
      case 'Jerash': return l10n.cityJerash;
      case 'Mafraq': return l10n.cityMafraq;
      case 'Balqa': return l10n.cityBalqa;
      case 'All': return l10n.all;
      default: return city;
    }
  }
}
