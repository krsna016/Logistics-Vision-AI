import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
void main() {
  debugPrint(Csv().encode([['a', 'b'], ['c', 'd']]));
}
