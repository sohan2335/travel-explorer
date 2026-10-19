/// A place to explore within a destination.
class Attraction {
  const Attraction(
      {required this.name, required this.imageUrl, this.description = ''});

  final String name;
  final String imageUrl;
  final String description;
}

/// Read-only information used by the explorer, details, and wishlist screens.
class Destination {
  const Destination({
    required this.id,
    required this.name,
    required this.location,
    required this.category,
    required this.imageUrl,
    required this.description,
    required this.bestTimeToVisit,
    required this.attractions,
    this.country = 'India',
    this.source = 'Curated sample content',
  });

  final String id;
  final String name;
  final String location;
  final String category;
  final String imageUrl;
  final String description;
  final String bestTimeToVisit;
  final List<Attraction> attractions;
  final String country;
  final String source;
}
