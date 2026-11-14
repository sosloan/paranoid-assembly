export type TourEventType = "show" | "travel" | "rest" | "press";

export type ItineraryItem = {
  time: string;
  label: string;
  detail: string;
};

export type TourStop = {
  id: string;
  date: string;
  city: string;
  region: string;
  country: string;
  venue: string;
  type: TourEventType;
  status: "proposed" | "hold" | "routing";
  travelFrom?: {
    city: string;
    mode: "Tour bus" | "Flight" | "Rail";
    distance: string;
    duration: string;
  };
  itinerary: ItineraryItem[];
};

export type TourLeg = {
  id: string;
  name: string;
  dates: string;
  theme: string;
  stops: TourStop[];
};

export const tourLegs: TourLeg[] = [
  {
    id: "CHEF-TOUR-US-01",
    name: "The Proof Circuit",
    dates: "October 8–25, 2026",
    theme: "A southern opening followed by the eastern corridor.",
    stops: [
      {
        id: "ATL-1008",
        date: "2026-10-08",
        city: "Atlanta",
        region: "GA",
        country: "USA",
        venue: "Venue TBA",
        type: "show",
        status: "hold",
        itinerary: [
          { time: "10:00", label: "Crew call", detail: "Production office opens; credentials and radios issued." },
          { time: "13:00", label: "Load-in", detail: "Proof-tree LED wall, playback and backline." },
          { time: "16:30", label: "Soundcheck", detail: "Ordinal Frequencies system calibration at 55Hz." },
          { time: "18:30", label: "Doors", detail: "Guest and accessibility entrances open." },
          { time: "21:00", label: "HOTBOII", detail: "The Architecture of Harmony — full production." },
          { time: "23:30", label: "Bus call", detail: "Overnight departure for Miami." },
        ],
      },
      {
        id: "MIA-1010",
        date: "2026-10-10",
        city: "Miami",
        region: "FL",
        country: "USA",
        venue: "Venue TBA",
        type: "show",
        status: "routing",
        travelFrom: { city: "Atlanta", mode: "Tour bus", distance: "662 mi", duration: "10h 15m" },
        itinerary: [
          { time: "10:00", label: "Hotel arrival", detail: "Mandatory driver and crew rest window." },
          { time: "15:00", label: "Load-in", detail: "Local production handoff and stage inspection." },
          { time: "17:15", label: "Soundcheck", detail: "BottleDroppas trajectory cue rehearsal." },
          { time: "19:00", label: "Doors", detail: "Public entry." },
          { time: "21:15", label: "Show", detail: "138–148 BPM performance sequence." },
        ],
      },
      {
        id: "HOU-1014",
        date: "2026-10-14",
        city: "Houston",
        region: "TX",
        country: "USA",
        venue: "Venue TBA",
        type: "show",
        status: "proposed",
        travelFrom: { city: "Miami", mode: "Flight", distance: "965 mi", duration: "2h 45m" },
        itinerary: [
          { time: "09:30", label: "Airport call", detail: "Group check-in; instruments travel as priority cargo." },
          { time: "14:15", label: "Venue arrival", detail: "Fly-date package and local backline inspection." },
          { time: "17:00", label: "Soundcheck", detail: "Guest rehearsal and frequency sweep." },
          { time: "19:00", label: "Doors", detail: "Public entry." },
          { time: "21:00", label: "Show", detail: "Artist-collaboration edition." },
        ],
      },
      {
        id: "NOLA-1016",
        date: "2026-10-16",
        city: "New Orleans",
        region: "LA",
        country: "USA",
        venue: "Venue TBA",
        type: "show",
        status: "proposed",
        travelFrom: { city: "Houston", mode: "Tour bus", distance: "348 mi", duration: "5h 20m" },
        itinerary: [
          { time: "11:00", label: "Arrival", detail: "Hotel check-in and crew rest." },
          { time: "15:30", label: "Load-in", detail: "Reduced local configuration." },
          { time: "17:30", label: "Soundcheck", detail: "Chaos Theory and Butterfly Pipes focus." },
          { time: "19:30", label: "Doors", detail: "Public entry." },
          { time: "21:30", label: "Show", detail: "Louisiana collaboration program." },
        ],
      },
      {
        id: "CHI-1021",
        date: "2026-10-21",
        city: "Chicago",
        region: "IL",
        country: "USA",
        venue: "Venue TBA",
        type: "show",
        status: "routing",
        travelFrom: { city: "New Orleans", mode: "Tour bus", distance: "925 mi", duration: "14h 10m" },
        itinerary: [
          { time: "09:00", label: "Dark day", detail: "Previous day reserved for driver reset and maintenance." },
          { time: "13:00", label: "Load-in", detail: "Full production returns." },
          { time: "16:30", label: "Soundcheck", detail: "Cold-weather system and RF check." },
          { time: "18:30", label: "Doors", detail: "Public entry." },
          { time: "21:00", label: "Show", detail: "Full Architecture set." },
        ],
      },
      {
        id: "NYC-1025",
        date: "2026-10-25",
        city: "New York",
        region: "NY",
        country: "USA",
        venue: "Venue TBA",
        type: "show",
        status: "hold",
        travelFrom: { city: "Chicago", mode: "Flight", distance: "711 mi", duration: "2h 10m" },
        itinerary: [
          { time: "10:30", label: "Press call", detail: "Editorial interviews and portrait session." },
          { time: "14:00", label: "Load-in", detail: "Full production and broadcast split." },
          { time: "17:00", label: "Soundcheck", detail: "Guest cues and camera rehearsal." },
          { time: "19:00", label: "Doors", detail: "Public entry." },
          { time: "21:15", label: "Show", detail: "US leg finale and archive capture." },
        ],
      },
    ],
  },
  {
    id: "CHEF-TOUR-GLOBAL-02",
    name: "Global Synthesis",
    dates: "November 4–22, 2026",
    theme: "Three international cities connected by mathematics and sound.",
    stops: [
      {
        id: "LON-1104",
        date: "2026-11-04",
        city: "London",
        region: "England",
        country: "UK",
        venue: "Venue TBA",
        type: "show",
        status: "proposed",
        travelFrom: { city: "New York", mode: "Flight", distance: "3,459 mi", duration: "7h 05m" },
        itinerary: [
          { time: "08:30", label: "Arrival", detail: "Carnet clearance and hotel transfer." },
          { time: "13:30", label: "Load-in", detail: "EU/UK power conversion and local rig integration." },
          { time: "17:00", label: "Soundcheck", detail: "Playback redundancy and guest rehearsal." },
          { time: "19:00", label: "Doors", detail: "Public entry." },
          { time: "21:00", label: "Show", detail: "Global Synthesis international premiere." },
        ],
      },
      {
        id: "BER-1110",
        date: "2026-11-10",
        city: "Berlin",
        region: "Berlin",
        country: "Germany",
        venue: "Venue TBA",
        type: "show",
        status: "routing",
        travelFrom: { city: "London", mode: "Rail", distance: "688 mi", duration: "9h 30m" },
        itinerary: [
          { time: "09:00", label: "Travel day", detail: "Equipment continues by bonded freight truck." },
          { time: "14:00", label: "Production call", detail: "Holographic route-line package installed." },
          { time: "17:30", label: "Soundcheck", detail: "Turbine Logic visual sequence." },
          { time: "19:30", label: "Doors", detail: "Public entry." },
          { time: "22:00", label: "Show", detail: "Late Berlin performance." },
        ],
      },
      {
        id: "TYO-1122",
        date: "2026-11-22",
        city: "Tokyo",
        region: "Tokyo",
        country: "Japan",
        venue: "Venue TBA",
        type: "show",
        status: "proposed",
        travelFrom: { city: "Berlin", mode: "Flight", distance: "5,535 mi", duration: "13h 20m" },
        itinerary: [
          { time: "09:00", label: "Press", detail: "Japanese-edition listening session and photography." },
          { time: "13:00", label: "Load-in", detail: "Local production, translation and subtitle checks." },
          { time: "16:30", label: "Soundcheck", detail: "Ordinal Frequencies spatial-audio rehearsal." },
          { time: "18:30", label: "Doors", detail: "Public entry." },
          { time: "20:30", label: "Show", detail: "Global finale and QED archive ceremony." },
        ],
      },
    ],
  },
];

export const tourStops = tourLegs.flatMap((leg) => leg.stops);
