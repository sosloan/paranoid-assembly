-- Ada.Real_Time — RavenSPARK / ProfileR1 subset
-- SPARK annotations retained for flow analysis of real-time systems.
-- Conversion functions involving Duration (To_Duration, To_Time_Span) are
-- omitted: ProfileR1 has no relative-delay support. Time_Unit is omitted
-- because it is an implementation-defined named real number.

package Ada.Real_Time
  --# own protected in ClockTime : Time;
is

  type Time is private;

  Time_First : constant Time;
  Time_Last  : constant Time;

  type Time_Span is private;

  Time_Span_First : constant Time_Span;
  Time_Span_Last  : constant Time_Span;
  Time_Span_Zero  : constant Time_Span;
  Time_Span_Unit  : constant Time_Span;

  Tick : constant Time_Span;

  function Clock return Time;
  --# global ClockTime;

  -- the following operators are predefined
  -- Time + Time_Span return Time
  -- Time_Span + Time return Time
  -- Time - Time_Span return Time
  -- Time - Time return Time_Span

  -- Time <  Time return Boolean
  -- Time <= Time return Boolean
  -- Time >  Time return Boolean
  -- Time >= Time return Boolean

  -- Time_Span + Time_Span return Time_Span
  -- Time_Span - Time_Span return Time_Span
  --  - Time_Span return Time_Span
  -- Time_Span * Integer return Time_Span
  -- Integer * Time_Span return Time_Span
  -- Time_Span / Time_Span return Integer
  -- Time_Span / Integer return Time_Span

  -- abs Time_Span return Time_Span

  -- Time_Span <  Time_Span return Boolean
  -- Time_Span <= Time_Span return Boolean
  -- Time_Span >  Time_Span return Boolean
  -- Time_Span >= Time_Span return Boolean

  function Nanoseconds  (NS : Integer) return Time_Span;
  function Microseconds (US : Integer) return Time_Span;
  function Milliseconds (MS : Integer) return Time_Span;

  type Seconds_Count is range implementation-defined;
  -- a range may be supplied using the configuration file, see 3.1.4

  procedure Split (T  : in     Time;
                   SC :    out Seconds_Count;
                   TS :    out Time_Span);
  --# derives SC, TS from T;

  function Time_Of (SC : Seconds_Count;
                    TS : Time_Span) return Time;

private
  --# hide Ada.Real_Time
  -- we do not need to know the implementation details of this package
  -- for our analysis purposes
end Ada.Real_Time;
