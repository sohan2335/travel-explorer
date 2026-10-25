/// These functions only build URLs. They do not fetch prices or book anything.
Uri mapSearch(String query) =>
    Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': query});

Uri placeInformation(String name, String location) => Uri.https(
  'en.wikipedia.org',
  '/w/index.php',
  {'search': '$name $location'},
);

Uri hotelSearch(String place, String city, String style) =>
    mapSearch('$style hotels near $place, $city');

Uri directions({
  required String destination,
  String origin = '',
  String mode = 'transit',
}) => Uri.https('www.google.com', '/maps/dir/', {
  'api': '1',
  'destination': destination,
  'travelmode': mode,
  if (origin.trim().isNotEmpty) 'origin': origin.trim(),
});

const transportModes = <String, String>{
  'transit': 'Bus / public transport',
  'driving': 'Cab / car',
  'walking': 'Walk',
  'bicycling': 'Bicycle',
};
