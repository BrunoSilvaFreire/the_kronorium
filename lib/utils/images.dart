import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

Map<String, ImageProvider Function(Uri url)> _imageProviders = {
  "http": _createNetworkImage,
  "https": _createNetworkImage,
  "file": _createFileImage,
  "asset": _createAssetImage,
  "base64": _createMemoryImage,
};

NetworkImage _createNetworkImage(Uri url) {
  return NetworkImage(url.toString());
}

FileImage _createFileImage(Uri url) {
  return FileImage(File(url.toFilePath()));
}

AssetImage _createAssetImage(Uri url) {
  return AssetImage(url.path);
}

MemoryImage _createMemoryImage(Uri url) {
  var parts = url.pathSegments;
  var base64 = parts[0];
  var data = parts[1];
  return MemoryImage(
    base64Decode(data),
  );
}

ImageProvider<T> imageProviderFromUri<T extends Object>(Uri url) {
  var scheme = url.scheme;
  var provider = _imageProviders[scheme];
  if (provider == null) {
    throw UnsupportedError("Unsupported image scheme: '$scheme' in uri $url");
  }
  return provider(url) as ImageProvider<T>;
}
