class ApplicationFeature {
  final String icon;
  final String name;
  final String description;
  final bool? isEnabled;

  const ApplicationFeature({
    required this.icon,
    required this.name,
    required this.description,
    this.isEnabled,
  });
}
