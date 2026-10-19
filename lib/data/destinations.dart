import '../models/destination.dart';
import 'more_destinations.dart';

// Local Commons photos and licenses: docs/IMAGE_CREDITS.md.

/// Bundled sample content: no account, API key, or backend is required.
const List<Destination> destinations = [
  Destination(
    id: 'goa',
    name: 'Goa',
    location: 'Goa, India',
    category: 'Beaches',
    imageUrl: 'assets/images/palolem_beach.jpg',
    description:
        'Slow down by the sea, wander through colorful streets, and build a day around sandy shores and coastal views.',
    bestTimeToVisit: 'November to February',
    attractions: [
      Attraction(
          name: 'Palolem Beach',
          imageUrl: 'assets/images/palolem_beach.jpg',
          description:
              'A beach stop in South Goa, suited to an unhurried coastal visit. Explore the beachfront and use the map for nearby food and stays.'),
      Attraction(
          name: 'Fort Aguada',
          imageUrl: 'assets/images/fort_aguada.jpg',
          description:
              'A historic coastal fort in Goa. It is a separate trip from Palolem Beach, so check the actual journey before combining them in one day.'),
      Attraction(
          name: 'Fontainhas',
          imageUrl: 'assets/images/fontainhas_goa.jpg',
          description:
              'A neighbourhood in Panaji known for colourful streets and heritage buildings. Use the surrounding-area map to explore local lanes and nearby cafés.'),
    ],
  ),
  Destination(
    id: 'varkala',
    name: 'Varkala',
    location: 'Kerala, India',
    category: 'Beaches',
    imageUrl: 'assets/images/varkala_beach.jpg',
    description:
        'Explore a relaxed coastal escape with cliffside walks, open sea views, and time to enjoy the beach at your own pace.',
    bestTimeToVisit: 'November to February',
    attractions: [
      Attraction(
          name: 'Varkala Beach', imageUrl: 'assets/images/varkala_beach.jpg'),
      Attraction(
          name: 'Varkala Cliff', imageUrl: 'assets/images/varkala_cliff.jpg'),
    ],
  ),
  Destination(
    id: 'manali',
    name: 'Manali',
    location: 'Himachal Pradesh, India',
    category: 'Mountains',
    imageUrl: 'assets/images/solang_valley.jpg',
    description:
        'Imagine crisp mountain mornings, forest paths, and a cozy afternoon exploring the lanes of a Himalayan town.',
    bestTimeToVisit: 'March to June',
    attractions: [
      Attraction(
          name: 'Solang Valley', imageUrl: 'assets/images/solang_valley.jpg'),
      Attraction(
          name: 'Hadimba Devi Temple',
          imageUrl: 'assets/images/hadimba_devi_temple.jpg'),
      Attraction(name: 'Old Manali', imageUrl: 'assets/images/old_manali.jpg'),
    ],
  ),
  Destination(
    id: 'munnar',
    name: 'Munnar',
    location: 'Kerala, India',
    category: 'Mountains',
    imageUrl: 'assets/images/top_station_munnar.jpg',
    description:
        'Take a gentle journey through rolling hills and tea country, with scenic viewpoints and quiet moments along the way.',
    bestTimeToVisit: 'September to March',
    attractions: [
      Attraction(
          name: 'Mattupetty Dam', imageUrl: 'assets/images/mattupetty_dam.jpg'),
      Attraction(
          name: 'Top Station',
          imageUrl: 'assets/images/top_station_munnar.jpg'),
    ],
  ),
  Destination(
    id: 'jaipur',
    name: 'Jaipur',
    location: 'Rajasthan, India',
    category: 'Heritage',
    imageUrl: 'assets/images/hawa_mahal.jpg',
    description:
        'Discover courtyards, intricate architecture, and lively streets in a city that invites you to look closely at every detail.',
    bestTimeToVisit: 'October to March',
    attractions: [
      Attraction(name: 'Hawa Mahal', imageUrl: 'assets/images/hawa_mahal.jpg'),
      Attraction(name: 'Amber Fort', imageUrl: 'assets/images/amber_fort.jpg'),
      Attraction(
          name: 'City Palace',
          imageUrl: 'assets/images/city_palace_jaipur.jpg'),
    ],
  ),
  Destination(
    id: 'rishikesh',
    name: 'Rishikesh',
    location: 'Uttarakhand, India',
    category: 'Adventure',
    imageUrl: 'assets/images/shivpuri_rishikesh.jpg',
    description:
        'Bring an adventurous spirit to riverside trails and hill views, then leave room for a peaceful evening beside the Ganges.',
    bestTimeToVisit: 'March to April and September to November',
    attractions: [
      Attraction(
          name: 'Shivpuri', imageUrl: 'assets/images/shivpuri_rishikesh.jpg'),
      Attraction(
          name: 'Neer Garh Waterfall',
          imageUrl: 'assets/images/neer_garh_waterfall.jpg'),
      Attraction(
          name: 'Triveni Ghat',
          imageUrl: 'assets/images/triveni_ghat_rishikesh.jpg'),
    ],
  ),
  ...moreDestinations,
];
