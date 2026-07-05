class PlaceItem {
  final String id;
  final String title;
  final String subtitle;
  final String location;
  final double rating;
  final String imageUrl;
  final String description;
  final String contact;

  const PlaceItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.rating,
    required this.imageUrl,
    this.description = '',
    this.contact = '',
  });
}
