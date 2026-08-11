import 'package:intl/intl.dart';

final NumberFormat pkrFormat = NumberFormat.currency(
  locale: 'en_PK',
  symbol: 'PKR ',
  decimalDigits: 0,
);

final DateFormat shortDateFormat = DateFormat('MMM d, yyyy');
final DateFormat monthDayFormat = DateFormat('MMM d');
