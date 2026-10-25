import '../models/destination_match.dart';

// Small, hand-written examples for demonstrating preference matching offline.
// These tags and visit lengths are NOT researched prices or required stay lengths.
// International transport, visas and live availability are outside this guide.
const destinationMatchProfiles = <String, DestinationMatchProfile>{
  'goa': DestinationMatchProfile(
    budgets: {TripBudget.budget, TripBudget.midRange, TripBudget.premium},
    minDays: 2,
    maxDays: 5,
  ),
  'varkala': DestinationMatchProfile(
    budgets: {TripBudget.budget, TripBudget.midRange},
    minDays: 2,
    maxDays: 4,
  ),
  'manali': DestinationMatchProfile(
    budgets: {TripBudget.budget, TripBudget.midRange},
    minDays: 3,
    maxDays: 6,
  ),
  'munnar': DestinationMatchProfile(
    budgets: {TripBudget.midRange, TripBudget.premium},
    minDays: 2,
    maxDays: 4,
  ),
  'jaipur': DestinationMatchProfile(
    budgets: {TripBudget.budget, TripBudget.midRange, TripBudget.premium},
    minDays: 2,
    maxDays: 3,
  ),
  'rishikesh': DestinationMatchProfile(
    budgets: {TripBudget.budget, TripBudget.midRange},
    minDays: 2,
    maxDays: 4,
  ),
  'hyderabad': DestinationMatchProfile(
    budgets: {TripBudget.budget, TripBudget.midRange, TripBudget.premium},
    minDays: 1,
    maxDays: 3,
  ),
  'agra': DestinationMatchProfile(
    budgets: {TripBudget.budget, TripBudget.midRange},
    minDays: 1,
    maxDays: 2,
  ),
  'paris': DestinationMatchProfile(
    budgets: {TripBudget.midRange, TripBudget.premium},
    minDays: 3,
    maxDays: 6,
  ),
  'rome': DestinationMatchProfile(
    budgets: {TripBudget.midRange, TripBudget.premium},
    minDays: 3,
    maxDays: 5,
  ),
};
