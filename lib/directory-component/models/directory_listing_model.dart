import 'dart:convert' as convert;

class DirectoryListing {
  final String path;
  final List<String> files;

  DirectoryListing({
    required this.path,
    required this.files,
  });

  factory DirectoryListing.fromJson(Map<String, dynamic> json) =>
      DirectoryListing(
        path: json['path'],
        files: (convert.json.decode(json['files']) as List)
            .map((e) => e as String)
            .toList(),
      );

  static Map<String, dynamic> toJson(DirectoryListing listing) => {
        'path': listing.path,
        'files': convert.json.encode(listing.files),
      };

  static String encode(List<DirectoryListing> listing) => convert.json.encode(
        listing
            .map<Map<String, dynamic>>((path) => DirectoryListing.toJson(path))
            .toList(),
      );

  static List<DirectoryListing> decode(String jsonString) => (convert.json
          .decode(jsonString) as List<dynamic>)
      .map<DirectoryListing>((listing) => DirectoryListing.fromJson(listing))
      .toList();
}
