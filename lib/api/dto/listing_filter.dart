class ListingFilter {
  final String title;
  final String query;
  final String? year;
  final String? type;
  final String displayName;

  const ListingFilter({
    required this.title,
    required this.query,
    this.year,
    this.type,
    required this.displayName,
  });

  // Predefined filters for the listing page
  static const List<ListingFilter> predefinedFilters = [
    ListingFilter(
      title: 'Action Movies',
      query: 'action',
      type: 'movie',
      displayName: 'Action Movies',
    ),
    ListingFilter(
      title: 'Batman Movies',
      query: 'Batman',
      type: 'movie',
      displayName: 'Batman Collection',
    ),
    ListingFilter(
      title: 'Latest 2022',
      query: 'movie',
      year: '2022',
      type: 'movie',
      displayName: 'Latest 2022 Movies',
    ),
    ListingFilter(
      title: 'Comedy Movies',
      query: 'comedy',
      type: 'movie',
      displayName: 'Comedy Movies',
    ),
    ListingFilter(
      title: 'Marvel Movies',
      query: 'Marvel',
      type: 'movie',
      displayName: 'Marvel Universe',
    ),
    ListingFilter(
      title: 'Horror Movies',
      query: 'horror',
      type: 'movie',
      displayName: 'Horror Movies',
    ),
  ];
}
