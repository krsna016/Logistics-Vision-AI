import 'package:csv/csv.dart';
void main() {
  print(const ListToCsvConverter().convert([['a', 'b'], ['c', 'd']]));
}
