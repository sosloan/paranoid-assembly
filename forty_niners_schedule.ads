-- forty_niners_schedule.ads
-- Ada translation of writeups/FORTY_NINERS_TRAVEL_POWER.md
-- Subject: San Francisco 49ers 2026 season travel model
-- Origin form: NASA FPP module Nfl.SanFrancisco49ers.schedule
--
-- A season is not just eighteen dates. It is fuel, borders, time zones,
-- recovery windows, and one team trying to stay coherent while the map
-- keeps moving underneath it.

package Forty_Niners_Schedule is

   -- Venue class for every ordered week, including international edge cases
   -- and the recovery bye. Mirrors FPP enum SiteKind.
   type Site_Kind is
     (Home,
      Away,
      International_Home,
      International_Away,
      Bye);

   -- Fixed field widths for the typed travel leg.
   Opponent_Width : constant := 28;
   Venue_Width    : constant := 28;
   City_Width     : constant := 16;
   Region_Width   : constant := 12;
   Kickoff_Width  : constant := 10;

   subtype Opponent_Name is String (1 .. Opponent_Width);
   subtype Venue_Name    is String (1 .. Venue_Width);
   subtype City_Name     is String (1 .. City_Width);
   subtype Region_Name   is String (1 .. Region_Width);
   subtype Kickoff_Name  is String (1 .. Kickoff_Width);

   -- One typed travel leg: week, opponent, venue class, geography, kickoff.
   -- Mirrors FPP struct TravelLeg.
   type Travel_Leg is record
      Week          : Positive;
      Opponent      : Opponent_Name;
      Kind          : Site_Kind;
      Venue         : Venue_Name;
      City          : City_Name;
      Region        : Region_Name;
      Kickoff_Label : Kickoff_Name;
   end record;

   -- Fixed-length season container. Load-bearing declaration:
   -- eighteen ordered slots, no phantom Week 19, no dropped bye.
   -- Mirrors FPP: array SeasonSchedule = [18] TravelLeg
   subtype Week_Index is Positive range 1 .. 18;
   type Season_Schedule is array (Week_Index) of Travel_Leg;
   Week_1 : constant Travel_Leg :=
     (Week          => 1,
      Opponent      => "Los Angeles Rams            ",
      Kind          => International_Away,
      Venue         => "Melbourne Cricket Ground    ",
      City          => "Melbourne       ",
      Region        => "Australia   ",
      Kickoff_Label => "2026-09-10");
   Week_2 : constant Travel_Leg :=
     (Week          => 2,
      Opponent      => "Miami Dolphins              ",
      Kind          => Home,
      Venue         => "Levi's Stadium              ",
      City          => "Santa Clara     ",
      Region        => "CA          ",
      Kickoff_Label => "2026-09-20");
   Week_3 : constant Travel_Leg :=
     (Week          => 3,
      Opponent      => "Arizona Cardinals           ",
      Kind          => Home,
      Venue         => "Levi's Stadium              ",
      City          => "Santa Clara     ",
      Region        => "CA          ",
      Kickoff_Label => "2026-09-27");
   Week_4 : constant Travel_Leg :=
     (Week          => 4,
      Opponent      => "Denver Broncos              ",
      Kind          => Home,
      Venue         => "Levi's Stadium              ",
      City          => "Santa Clara     ",
      Region        => "CA          ",
      Kickoff_Label => "2026-10-04");
   Week_5 : constant Travel_Leg :=
     (Week          => 5,
      Opponent      => "Seattle Seahawks            ",
      Kind          => Away,
      Venue         => "Lumen Field                 ",
      City          => "Seattle         ",
      Region        => "WA          ",
      Kickoff_Label => "2026-10-11");
   Week_6 : constant Travel_Leg :=
     (Week          => 6,
      Opponent      => "Washington Commanders       ",
      Kind          => Home,
      Venue         => "Levi's Stadium              ",
      City          => "Santa Clara     ",
      Region        => "CA          ",
      Kickoff_Label => "2026-10-19");
   Week_7 : constant Travel_Leg :=
     (Week          => 7,
      Opponent      => "Atlanta Falcons             ",
      Kind          => Away,
      Venue         => "Mercedes-Benz Stadium       ",
      City          => "Atlanta         ",
      Region        => "GA          ",
      Kickoff_Label => "2026-10-25");
   -- Bye is scheduled operational state, not omission.
   Week_8 : constant Travel_Leg :=
     (Week          => 8,
      Opponent      => "BYE                         ",
      Kind          => Bye,
      Venue         => "Recovery Window             ",
      City          => "Santa Clara     ",
      Region        => "CA          ",
      Kickoff_Label => "2026-11-01");
   Week_9 : constant Travel_Leg :=
     (Week          => 9,
      Opponent      => "Las Vegas Raiders           ",
      Kind          => Home,
      Venue         => "Levi's Stadium              ",
      City          => "Santa Clara     ",
      Region        => "CA          ",
      Kickoff_Label => "2026-11-08");
   Week_10 : constant Travel_Leg :=
     (Week          => 10,
      Opponent      => "Dallas Cowboys              ",
      Kind          => Away,
      Venue         => "AT&T Stadium                ",
      City          => "Arlington       ",
      Region        => "TX          ",
      Kickoff_Label => "2026-11-15");
   -- International home: Mexico City designation without hiding travel burden.
   Week_11 : constant Travel_Leg :=
     (Week          => 11,
      Opponent      => "Minnesota Vikings           ",
      Kind          => International_Home,
      Venue         => "Estadio Banorte             ",
      City          => "Mexico City     ",
      Region        => "Mexico      ",
      Kickoff_Label => "2026-11-22");
   Week_12 : constant Travel_Leg :=
     (Week          => 12,
      Opponent      => "Seattle Seahawks            ",
      Kind          => Home,
      Venue         => "Levi's Stadium              ",
      City          => "Santa Clara     ",
      Region        => "CA          ",
      Kickoff_Label => "2026-11-29");
   Week_13 : constant Travel_Leg :=
     (Week          => 13,
      Opponent      => "New York Giants             ",
      Kind          => Away,
      Venue         => "MetLife Stadium             ",
      City          => "East Rutherford ",
      Region        => "NJ          ",
      Kickoff_Label => "2026-12-06");
   Week_14 : constant Travel_Leg :=
     (Week          => 14,
      Opponent      => "Los Angeles Rams            ",
      Kind          => Home,
      Venue         => "Levi's Stadium              ",
      City          => "Santa Clara     ",
      Region        => "CA          ",
      Kickoff_Label => "2026-12-13");
   Week_15 : constant Travel_Leg :=
     (Week          => 15,
      Opponent      => "Los Angeles Chargers        ",
      Kind          => Away,
      Venue         => "SoFi Stadium                ",
      City          => "Inglewood       ",
      Region        => "CA          ",
      Kickoff_Label => "2026-12-17");
   Week_16 : constant Travel_Leg :=
     (Week          => 16,
      Opponent      => "Kansas City Chiefs          ",
      Kind          => Away,
      Venue         => "Arrowhead Stadium           ",
      City          => "Kansas City     ",
      Region        => "MO          ",
      Kickoff_Label => "2026-12-27");
   Week_17 : constant Travel_Leg :=
     (Week          => 17,
      Opponent      => "Philadelphia Eagles         ",
      Kind          => Home,
      Venue         => "Levi's Stadium              ",
      City          => "Santa Clara     ",
      Region        => "CA          ",
      Kickoff_Label => "2027-01-03");
   Week_18 : constant Travel_Leg :=
     (Week          => 18,
      Opponent      => "Arizona Cardinals           ",
      Kind          => Away,
      Venue         => "State Farm Stadium          ",
      City          => "Glendale        ",
      Region        => "AZ          ",
      Kickoff_Label => "TBD       ");

   -- Ordered season itinerary: eighteen auditable travel legs.
   Schedule : constant Season_Schedule :=
     [1  => Week_1,
      2  => Week_2,
      3  => Week_3,
      4  => Week_4,
      5  => Week_5,
      6  => Week_6,
      7  => Week_7,
      8  => Week_8,
      9  => Week_9,
      10 => Week_10,
      11 => Week_11,
      12 => Week_12,
      13 => Week_13,
      14 => Week_14,
      15 => Week_15,
      16 => Week_16,
      17 => Week_17,
      18 => Week_18];

end Forty_Niners_Schedule;
