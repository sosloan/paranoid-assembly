# THE POWER OF `ada_real_time.ads`

> *"Only the paranoid survive."* — Andy Grove
>
> *Before a periodic task fires, before an epoch is shared, before a
> deadline is missed — Ada asks a harder question: what is time, and who
> is allowed to invent it?*

**Status:** ✓ COMPLETE
**Subject:** `ada_real_time.ads` (`package Ada.Real_Time`, RavenSPARK / ProfileR1 subset)
**Form:** Power-of writeup, Track 031 style
**Album Tie-In:** ONLY THE PARANOID SURVIVE — Real-Time Session
**Companion:** `ada_synchronous_task_control.ads` (`package Ada.Synchronous_Task_Control`)

---

## QUICK REFERENCE

| Attribute | Value |
|-----------|-------|
| **File** | `ada_real_time.ads` |
| **Companion** | `ada_synchronous_task_control.ads` |
| **Origin** | Ada.Real_Time standard package, RavenSPARK / ProfileR1 annotations |
| **License** | Writeup text CC BY 4.0; package interface is language-standard |
| **Language** | SPARK Ada (Ravenscar-profile real-time subset) |
| **Symbol** | `Ada.Real_Time` / `Clock`, `Time`, `Time_Span` |
| **Critical Declaration** | `--# own protected in ClockTime : Time;` |
| **Bytes of State** | Implementation-defined; analysis treats `ClockTime` as protected own |
| **Power Source** | Typed time algebra + static elaboration gates + hidden representation |
| **Deliberate Omissions** | `To_Duration` / `To_Time_Span` (no relative delays in ProfileR1); `Time_Unit` (implementation-defined real) |

---

## THE FILE, IN FULL

```ada
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

  procedure Split (T  : in     Time;
                   SC :    out Seconds_Count;
                   TS :    out Time_Span);
  --# derives SC, TS from T;

  function Time_Of (SC : Seconds_Count;
                    TS : Time_Span) return Time;

private
  --# hide Ada.Real_Time
end Ada.Real_Time;
```

A private absolute clock, a private relative span, a closed operator algebra,
three static constructors for periods, and one protected own variable the
analyzer must never invent. No Duration bridge. No floating `Time_Unit`.
The package is what remains when relative delay is stripped from the profile
and time is forced to answer SPARK's questions.

---

## WHY IT IS POWERFUL

### 1. It makes the wall clock a protected own variable — not a free function.

```ada
--# own protected in ClockTime : Time;
function Clock return Time;
--# global ClockTime;
```

In ordinary Ada, `Clock` looks like a pure query: call it, get a `Time`.
In RavenSPARK it is something harder. The package owns `ClockTime`. The
value is protected and mode `in` — readable through the runtime, not
writable by application code. Every call to `Clock` is annotated as a
global read of that own variable.

That is Grove's first move applied to time itself. Do not pretend the
clock is free of state. Name the state. Make every consumer declare the
dependency. Flow analysis then sees what a human reviewer hopes to see:
who observed time, and when that observation entered the dataflow.

Without the annotation, a "pure" clock is a lie that analysis cannot
catch. With it, the epoch package, the release calculus, and every
deadline check become accountable imports of one protected fact.

### 2. It separates absolute time from relative span at the type boundary.

`Time` is not `Time_Span`. Both are private. You may add a span to a
time. You may subtract two times and obtain a span. You may not add two
absolute times. You may not treat a duration as a wall-clock instant by
accident of shared representation.

This is the same paranoia that keeps a pressure reading from becoming an
address in `ada-types.txt`. Bits are cheap. Meanings are not. Real-time
systems fail when a programmer confuses "how long" with "when." The
predefined operator set is the gate:

| Expression | Result | Meaning |
|------------|--------|---------|
| `Time + Time_Span` | `Time` | Advance an instant |
| `Time_Span + Time` | `Time` | Same, commute |
| `Time - Time_Span` | `Time` | Retreat an instant |
| `Time - Time` | `Time_Span` | Measure an interval |
| `Time + Time` | *illegal* | Two wall clocks do not sum |
| `Time_Span + wall invent` | *illegal* | Span is not an epoch |

The algebra is small on purpose. Small algebras are auditable. Auditable
algebras survive certification.

### 3. It hides representation so analysis can refuse to care.

```ada
private
  --# hide Ada.Real_Time
  -- we do not need to know the implementation details of this package
  -- for our analysis purposes
```

`--# hide` is not laziness. It is a strategic boundary. Clients and
examiners reason about `Time` and `Time_Span` through the public
contract: constants, operators, `Clock`, constructors, `Split` /
`Time_Of`. The physical tick counter, the epoch origin, the wrap
behavior of the hardware timer — all of that lives behind the private
part and is declared out of scope for flow analysis.

That is package discipline at its most useful. Representation may change
when the board changes. The proof obligations on periods, release times,
and suspension objects must not. Hide what the mission does not need to
re-verify on every build.

### 4. It elevates period construction to static elaboration.

SPARK forbids ordinary user-defined function calls in elaboration code
and object initialization. Before RavenSPARK, that rule left almost no
predefined functions callable at library elaboration. `Ada.Real_Time`
punches three carefully licensed holes:

1. **`Clock`** may initialize a constant in a library-level package —
   the classic "Epoch" pattern for coordinated task start (see A.4).
2. **`Nanoseconds` / `Microseconds` / `Milliseconds`** are treated as
   static when their arguments are static — so task periods can be
   declared as library-level constants (see section 4.1).

```ada
Period : constant Time_Span := Milliseconds (50);
Epoch  : constant Time      := Clock;
```

This is not a convenience API. It is infrastructure for Ravenscar
periodics. A cyclic task needs a typed period before it runs. An ensemble
of tasks needs a shared epoch before anyone is released. The language
profile that bans relative delay still has to start the world somehow.
These three constructors plus `Clock`-at-elaboration are that somehow —
and they are static enough for the analyzer to trust.

### 5. It refuses Duration and Time_Unit on purpose.

The full Ada.Real_Time package offers `To_Duration`, `To_Time_Span`, and
the named real `Time_Unit`. ProfileR1 does not. Relative delays are
outside the profile. An implementation-defined real number is a poor
citizen of static analysis. So they are cut.

That cut is the power. A subset that tries to keep every convenience
becomes a superset again. RavenSPARK keeps the algebra that periodic and
absolute-time systems need, and drops the bridges that would reintroduce
`delay` thinking through the side door. Paranoia is often subtraction.

### 6. It gives bounds before it gives arithmetic.

```ada
Time_First, Time_Last : constant Time;
Time_Span_First, Time_Span_Last, Time_Span_Zero, Time_Span_Unit : constant Time_Span;
Tick : constant Time_Span;
```

Before you add, you know the envelope. Before you scale a period by an
integer, you know zero, unit, and the extreme spans. `Tick` names the
implementation's resolution as a first-class constant rather than a
comment in a board support package.

Real-time failure modes include overflow as often as they include
priority inversion. Constants that bound the type are not documentation;
they are the values against which a paranoid designer sizes a mission
timeline.

### 7. Split and Time_Of make the second a named unit without breaking privacy.

```ada
type Seconds_Count is range implementation-defined;

procedure Split (T : in Time; SC : out Seconds_Count; TS : out Time_Span);
--# derives SC, TS from T;

function Time_Of (SC : Seconds_Count; TS : Time_Span) return Time;
```

Absolute time stays private. Still, systems need to talk in whole seconds
plus a residual span — logs, telemetry, human interfaces, configuration
files. `Split` / `Time_Of` are the authorized decomposition. The derives
clause says the only import is `T`. No hidden clock read. No ambient
authority. Round-trip is a pure function of the instant you already hold.

`Seconds_Count`'s range may be fixed by configuration (section 3.1.4).
That is another Grove move: when the bound is mission-specific, put it in
the configuration file, not in folklore.

### 8. The companion package completes the start/stop story.

`Ada.Synchronous_Task_Control` supplies `Suspension_Object` with
`Set_True`, `Set_False`, and `Suspend_Until_True`. Together with an Epoch
initialized from `Clock`, it is the RavenSPARK way to hold a set of tasks
and release them on an event without inventing ad-hoc flags.

The SPARK annotations are deliberately "wrong" relative to Ada parameter
modes:

```ada
procedure Set_True (S : in out Suspension_Object);
--# derives S from ;
```

Ada needs `in out` because the runtime must read the object to decide
whether waiters should run. Flow analysis only needs to know that `S`
receives a fresh value independent of any import. The mismatch is
documented, not papered over. That is honest dual-view engineering:
runtime truth for the kernel, dependency truth for the examiner.

Time without release is a calendar. Release without typed time is a race.
The two packages are one doctrine.

---

## DECLARATION-BY-DECLARATION POWER ANALYSIS

| Line / region | Declaration | Power |
|---------------|-------------|-------|
| own annotation | `own protected in ClockTime : Time` | Names the clock as package state; forbids application writes; feeds flow analysis. |
| `type Time is private` | Absolute instant | Prevents forging wall-clock values from bare integers. |
| `type Time_Span is private` | Relative duration | Separates "how long" from "when." |
| `Time_First` / `Time_Last` | Envelope constants | Make overflow a design input, not a surprise. |
| `Time_Span_Zero` / `Unit` / `First` / `Last` | Span basis | Give arithmetic an origin, a step, and bounds. |
| `Tick` | Resolution constant | Surfaces timer granularity in the public contract. |
| `Clock` + `global ClockTime` | Time observation | Every read of now is an explicit global dependency. |
| predefined `Time`/`Time_Span` ops | Closed algebra | Legal combinations only; illegal ones never type-check. |
| `Nanoseconds` / `Microseconds` / `Milliseconds` | Static constructors | Permit library-level periods when arguments are static. |
| elaboration rule for `Clock` | Epoch pattern | Coordinates multi-task start without relative delay. |
| `Seconds_Count` | Configurable whole-second range | Mission-sized bound via configuration file. |
| `Split` / `derives SC, TS from T` | Pure decomposition | Residual span without a second clock read. |
| `Time_Of` | Pure composition | Rebuild an instant from authorized parts. |
| `private` / `--# hide` | Representation firewall | Analysis stays on the contract, not the BSP. |
| omitted `To_Duration` / `To_Time_Span` | Profile cut | Blocks relative-delay thinking in ProfileR1. |
| omitted `Time_Unit` | Profile cut | Removes an implementation-defined real from static surface. |

Every line either names a dependency, closes an algebra, bounds a type,
authorizes elaboration, or refuses a footgun. Remove the own annotation
and the clock becomes invisible state. Remove the private types and
integers impersonate deadlines. Remove the static constructors and
periods fall out of library elaboration. Remove the omissions and the
profile's delay ban becomes theater.

---

## THE PARANOIA CONNECTION

`Ada.Real_Time` applies Grove's doctrine to the one resource every
deadline shares:

1. **Assume "now" is shared state.** Own it. Protect it. Annotate every read.
2. **Assume absolute and relative will be confused.** Make them distinct private types with a closed operator set.
3. **Assume representation will change with the board.** Hide it; prove against the contract.
4. **Assume periods must exist before tasks run.** License static constructors and epoch `Clock` at elaboration.
5. **Assume convenience APIs reintroduce banned behavior.** Cut Duration bridges and `Time_Unit` under ProfileR1.
6. **Assume start/stop needs a second primitive.** Pair the clock with `Suspension_Object` and document the flow/runtime dual view.

> *Only the paranoid survive.* In RavenSPARK, paranoia is a clock you
> cannot invent, a span you cannot mistake for an instant, and a period
> that is legal before any task is released.

---

## SCALE OF IMPACT

- **Hardware:** `Tick` and the hidden representation bind portable Ada to the platform timer; analysis does not re-litigate the BSP each time.
- **Software:** Library-level epochs and millisecond periods are the backbone of Ravenscar cyclic systems, release trains, and watchdog math.
- **Concurrency:** With `Ada.Synchronous_Task_Control`, timed systems gain a fail-closed start gate instead of ad-hoc boolean races.
- **Certification:** SPARK own/global/derives annotations turn time observation into flow-visible fact — the kind of fact examiners can discharge.
- **Cost per call:** `Clock` is a protected read; span constructors with static arguments collapse at elaboration; operator calls are ordinary typed arithmetic on the private representation.

---

## VERIFICATION STATUS

✓ **Clock ownership:** `ClockTime` is package-own, protected, mode `in`; `Clock` is annotated `--# global ClockTime`.
✓ **Type separation:** `Time` and `Time_Span` are distinct private types; only the predefined mixed operators connect them.
✓ **Elaboration licenses:** `Clock` may initialize library-level constants; `Nanoseconds` / `Microseconds` / `Milliseconds` are static for static arguments.
✓ **Flow on Split:** `--# derives SC, TS from T` — residual decomposition depends only on the supplied instant.
✓ **ProfileR1 omissions:** No `To_Duration`, no `To_Time_Span`, no `Time_Unit` — relative delay stays outside the analyzed surface.
✓ **Representation firewall:** `--# hide Ada.Real_Time` keeps implementation detail out of client analysis.
✓ **Companion coordination:** `Suspension_Object` operations derive a fresh `S` from no imports, matching analysis needs while Ada modes satisfy the runtime.

**QED.**

---

## CLOSING

`Ada.Real_Time` is not a stopwatch library. It is the typed admission that
time is state, that instants are not intervals, and that a real-time
profile earns its restrictions only if the remaining API is still strong
enough to start an ensemble of tasks on a shared epoch and keep their
periods honest.

The package does almost nothing a board support package could not fake
with integers. That is the point. Integers would compile. They would not
confess their dependencies. They would not refuse `Time + Time`. They
would not make a 50-millisecond period a static library fact. They would
not hide the timer behind a contract an examiner can discharge without
re-reading the silicon manual.

Infrastructure is what remains after paranoia removes every way to be
accidentally wrong about when.

**Only the paranoid survive. ✓**
