import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

extension Interleave<T> on Iterable<T> {
  Iterable<T> interleave(T Function(T element) selector) sync* {
    var list = toList(growable: false);
    for (int i = 0; i < list.length - 1; i++) {
      var element = list[i];
      yield element;
      yield selector(element);
    }
    yield list.last;
  }
}

extension IconUtility on IconData {
  Icon asIcon() {
    return Icon(this);
  }
}

var _defaultColors = {
  "red": 0,
  "pink": 1,
  "purple": 2,
  "deepPurple": 3,
  "indigo": 4,
  "blue": 5,
  "lightBlue": 6,
  "cyan": 7,
  "teal": 8,
  "green": 9,
  "lightGreen": 10,
  "lime": 11,
  "yellow": 12,
  "amber": 13,
  "orange": 14,
  "deepOrange": 15,
  "brown": 16,
  "blueGrey": 17,
};

Color parseColor(String string) {
  var predefined=_defaultColors[string];
  if (predefined == null) {
    int value = int.parse(string, radix: 16);
    return Color(value);
  } else {
    return Colors.primaries[predefined];
    }
}

String clipString(
  String string,
  int maxChars, {
  String suffix = "...",
}) {
  if (string.length > maxChars) {
    return string.substring(0, string.length - suffix.length) + suffix;
  }
  return string;
}
