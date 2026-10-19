import '../models/day_plan.dart';

bool palaceOpenOn(DateTime date) => date.weekday != DateTime.friday;

// A curated example. Transfer durations are planning buffers, not live estimates.
const hyderabadDemo = <DayPlanStop>[
  DayPlanStop(540, 60, 'Travel from MGBS',
      'Allow a transfer buffer; check current public transport or auto options.',
      origin: 'Mahatma Gandhi Bus Station, Hyderabad',
      destination: 'Chowmahalla Palace, Hyderabad'),
  DayPlanStop(600, 120, 'Chowmahalla Palace',
      'The palace recommends about two hours. Check tickets and opening hours before leaving.'),
  DayPlanStop(720, 30, 'Head to Charminar',
      'The palace lists Charminar less than 1 km away. Check the walking route and your comfort.',
      origin: 'Chowmahalla Palace, Hyderabad',
      destination: 'Charminar, Hyderabad'),
  DayPlanStop(750, 60, 'Explore Charminar',
      'Enjoy the monument area; confirm access and ticket arrangements for entering.'),
  DayPlanStop(810, 60, 'Lunch & a break',
      'Choose a nearby place that suits your budget and food preferences.'),
  DayPlanStop(870, 60, 'Explore Laad Bazaar',
      'Browse the market around Charminar. Allow time for rest and your return journey.'),
  DayPlanStop(930, 60, 'Return to MGBS',
      'Check current routes and leave extra time for traffic.',
      origin: 'Laad Bazaar, Hyderabad',
      destination: 'Mahatma Gandhi Bus Station, Hyderabad'),
];
