import 'dart:convert' as convert;

import 'package:boombox/directory-component/models/directory_listing_model.dart';

class DirectoryParent {
  final String path;
  final List<DirectoryListing> folders;
  final String displayName;

  DirectoryParent({
    required this.path,
    required this.folders,
    required this.displayName,
  });

  factory DirectoryParent.fromJson(Map<String, dynamic> json) =>
      DirectoryParent(
        path: json['path'],
        folders: DirectoryListing.decode(json['folders']),
        displayName: json['displayName'],
      );

  static Map<String, dynamic> toJson(DirectoryParent parent) => {
        'path': parent.path,
        'folders': DirectoryListing.encode(parent.folders),
        'displayName': parent.displayName,
      };

  static String encode(List<DirectoryParent> parent) => convert.json.encode(
        parent
            .map<Map<String, dynamic>>((path) => DirectoryParent.toJson(path))
            .toList(),
      );

  static List<DirectoryParent> decode(String jsonString) =>
      (convert.json.decode(jsonString) as List<dynamic>)
          .map<DirectoryParent>((parent) => DirectoryParent.fromJson(parent))
          .toList();
}
