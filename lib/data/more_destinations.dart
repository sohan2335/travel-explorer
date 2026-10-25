import '../models/destination.dart';

// New city photographs are remote Commons files; the original six work offline.
// Paris/Rome country and high-season fields were checked in the SynthTRIPs CSV.
// Descriptions are short editorial samples; Rome's sights are curated additions.
const moreDestinations = <Destination>[
  Destination(
    id: 'hyderabad',
    name: 'Hyderabad',
    location: 'Telangana, India',
    category: 'Heritage',
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/Charminar_of_Hyderabad_Telangana.jpg/960px-Charminar_of_Hyderabad_Telangana.jpg',
    description:
        'Explore the old city around Charminar, then make time for the hilltop setting of Golconda Fort.',
    bestTimeToVisit: 'October to February (sample seasonal guidance)',
    attractions: [
      Attraction(
        name: 'Charminar',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/Charminar_of_Hyderabad_Telangana.jpg/960px-Charminar_of_Hyderabad_Telangana.jpg',
        description:
            'The four-minaret landmark is a starting point for exploring Hyderabad\'s old-city streets.',
      ),
      Attraction(
        name: 'Golconda Fort',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/Golconda_Fort_Whole.jpg/960px-Golconda_Fort_Whole.jpg',
        description:
            'A historic fort with hillside paths and views. It is a separate stop from the old city; check the route before travelling.',
      ),
    ],
  ),
  Destination(
    id: 'agra',
    name: 'Agra',
    location: 'Uttar Pradesh, India',
    category: 'Heritage',
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/Taj_Mahal,_Agra,_India_edit2.jpg/960px-Taj_Mahal,_Agra,_India_edit2.jpg',
    description:
        'Build a heritage day around the Taj Mahal and Agra Fort, leaving time for travel, entry queues, and a meal.',
    bestTimeToVisit: 'October to March (sample seasonal guidance)',
    attractions: [
      Attraction(
        name: 'Taj Mahal',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/Taj_Mahal,_Agra,_India_edit2.jpg/960px-Taj_Mahal,_Agra,_India_edit2.jpg',
        description:
            'A marble mausoleum beside the Yamuna. Check the official visiting calendar and ticket conditions before planning entry.',
      ),
      Attraction(
        name: 'Agra Fort',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Agra_Fort_1.jpg/960px-Agra_Fort_1.jpg',
        description:
            'A historic fortified complex in Agra. Plan it as its own visit rather than assuming it shares an entrance with the Taj Mahal.',
      ),
    ],
  ),
  Destination(
    id: 'paris',
    name: 'Paris',
    location: 'Paris, France',
    country: 'France',
    category: 'Heritage',
    source:
        'SynthTRIPs: city, country, high season, and attraction names; editorial descriptions',
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/8/84/EiffelTower.jpg/960px-EiffelTower.jpg',
    description:
        'Explore landmark views and neighbourhood walks. Choose one main attraction for an unhurried arrival day.',
    bestTimeToVisit:
        'May to October is the dataset\'s high season; this is not a weather forecast.',
    attractions: [
      Attraction(
        name: 'Eiffel Tower',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/8/84/EiffelTower.jpg/960px-EiffelTower.jpg',
        description:
            'A Paris landmark on the Champ de Mars. Use its official site for current entry slots, then explore the surrounding riverfront.',
      ),
      Attraction(
        name: 'Arc de Triomphe',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/79/Arc_de_Triomphe,_Paris_21_October_2010.jpg/960px-Arc_de_Triomphe,_Paris_21_October_2010.jpg',
        description:
            'A monumental arch at Place Charles de Gaulle. Check visitor information for access and entry arrangements.',
      ),
    ],
  ),
  Destination(
    id: 'rome',
    name: 'Rome',
    location: 'Rome, Italy',
    country: 'Italy',
    category: 'Heritage',
    source:
        'SynthTRIPs: city, country and high season; attractions/descriptions are curated',
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/aa/Rome_(IT),_Kolosseum_--_2013_--_3370-3.jpg/960px-Rome_(IT),_Kolosseum_--_2013_--_3370-3.jpg',
    description:
        'Discover ancient landmarks and public squares. Leave room for walking breaks and check timed-entry requirements.',
    bestTimeToVisit:
        'May to October is the dataset\'s high season; this is not a weather forecast.',
    attractions: [
      Attraction(
        name: 'Colosseum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/a/aa/Rome_(IT),_Kolosseum_--_2013_--_3370-3.jpg/960px-Rome_(IT),_Kolosseum_--_2013_--_3370-3.jpg',
        description:
            'An ancient amphitheatre in Rome. Allow time for ticket checks and use official visitor information for current access.',
      ),
      Attraction(
        name: 'Pantheon',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/0/06/Rome_Pantheon_front.jpg/960px-Rome_Pantheon_front.jpg',
        description:
            'A historic domed building on Piazza della Rotonda. Its surrounding square is another place to pause and explore.',
      ),
    ],
  ),
];
