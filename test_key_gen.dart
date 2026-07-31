import 'dart:convert';

void main() {
  final list = List<int>.generate(32, (i) => DateTime.now().microsecondsSinceEpoch % 255);
  print(list);
  print(base64UrlEncode(list));
}
