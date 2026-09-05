# THE POWER OF `BFGoodrich.txt`

> *"Only the paranoid survive."* — Andy Grove
>
> *When software must satisfy two markets, one regulator, and unforgiving physics, architecture becomes strategy.*

**Status:** ✓ COMPLETE  
**Subject:** `BFGoodrich.txt` (IMD-HUMS dual-use avionics software case study)  
**Form:** Power-of writeup, Track 031 style

---

## QUICK REFERENCE

| Attribute | Value |
|-----------|-------|
| **File** | `BFGoodrich.txt` |
| **Program** | Integrated Mechanical Diagnostics Helicopter Usage and Maintenance System (IMD-HUMS) |
| **Primary Doctrine** | **“Data change, not software.”** |
| **Language** | Ada95 |
| **Real-Time Framing** | Source-context alignment with Ravenscar-style deterministic tasking goals |
| **Scale** | 40K SLOC Ada95, 150 high-rate input channels |
| **Operational Loop** | Airborne acquisition → anomaly capture → pilot warning → ground-station reports |
| **Strategic Pressure** | Military + commercial requirements with certification pressure and changing scope |
| **Power Source** | Stable executable core with controlled data/configuration variability |

---

## THE FILE, IN FULL

```text
Flexible software pleases both commercial and military aerospace customers, but is often expensive and puts projects in the red. The rigidity of off-the-shelf software pleases neither market entirely but results in a black bottom line. Meanwhile, aerospace companies have to compete well in both markets to stay profitable.

Sometimes, a paradox can only be solved with a new paradigm. At BFGoodrich Aerospace Aircraft Integrated Systems, software technical leads Mark Chaffee and Hal Clark engineered both flexibility and rigidity in software programming in Ada. The result is the Integrated Mechanical Diagnostics Helicopter Usage and Maintenance System (IMD-HUMS).

"Data change, not software"

The two veteran programmers' paradigm is a mantra that they submitted their design criteria to throughout the two-year project: "Data change, not software." Simple, direct, and revolutionary. The "box," which technically only refers to the main processor unit that flies on the helicopter and measures no more than a foot [30 cm] in any direction, won the engineers the BFGoodrich Engineering Innovation Award in 1998.

The Dual Usage HUMS collects data on and measures the wear and tear that a flight causes a helicopter. It smooths the helicopter's vibration level and the rotor system without dedicated flights, and monitors flight parameters, such as air speed and engine torque, and the helicopter's structural usage. It also performs mechanical diagnostics from drive shafts to gear boxes. Designed to check normal flight use, IMD-HUMS also registers anything out of the ordinary, such as a hard landing.

IMD-HUMS acquires data from 150 input channels at a high sample rate. It stores additional data if it detects an anomalous condition, and displays a warning to the pilot on a three-inch [7.6 cm] cockpit indicator. Up to 20 hours of flight data are stored in an on-board PCMCIA flash memory card. After each flight, the data are transferred to a ground station computer running Windows NT. IMD- HUMS then generates a series of operations, maintenance, and engineering reports. The networked-based system manages all flight maintenance and parts data from the fleet's various locations.

Currently [Fall 1999] in flight test on a CH-53E Naval Helicopter, IMD-HUMS will also be installed in H-60s. According to Chaffee, the testing is "going very well" at Patuxent River Naval Station (PAX). The 40K SLOC of Ada95 code, counting terminal semicolons, is a new system. IMD-HUMS's predecessor was installed in the Agusta A109K2 helicopters used in Switzer-land's REGA air ambulances, and in several Eurocopter models AS350/355s that are used by the Spanish traffic police. The HUMS box was a limited version of the current functions written in C++, and STC certified by the Federal Aviation Administration.

Fluid Requirements

The Navy contracted for the new version for their Sikorsky SH60 and CH53 fleet in 1997. The open architecture is also based on the functional and performance requirements of Sikorsky's commercial S-76s and S-92s. From the design stage onwards, the Dual Use HUMS software had to accommodate requirements changes and yet be precise enough to pass FAA standards for commercial flight certification.

Chaffee and Clark decided to program in Ada specifically because the software had to pass FAA's rigorous standards, in which every line of code, including in the runtime system, must be executed and tested. A veteran of building runtime systems to FAA standards, Aonix agreed to create ObjectAda Real-Time RAVEN™ and use BFGoodrich as the compiler's kick-off customer.

Small Size, Fast Performance

Aonix's RAVEN is based on an emerging standard called the Ravenscar Profile, which accommodates certification requirements for safety-critical, real-time systems. The profile defines a special tasking model that emphasizes small size, fast performance, and deterministic behavior.

Aonix's expert on FAA certification traveled many times from Cambridge, Mass., to iron out wrinkles with Chaffee and Clark in Vergennes, Vt.. "Aonix was solid from the beginning," Chaffee said. "We took advantage of Ada95 and used every possible function. If it's in the Ravenscar, we exploited it."

Chaffee and Clark agree that language issues never stalled the project. In fact, they had very few problems with Ada95 after the initial startup. The wrinkles came from changing requirements and integrating them into the design and hardware. However, the engineers found that their object-oriented design provided them with both the flexibility and solidity that they needed even when a new requirement threatened to "stop the whole show."

"The OOD was robust," Clark said. "We added components and objectives very easily. We still are, as requests for new features come back to us."

HUMS runs on a Power PC, which, again, was a new processor for the two engineers. So were the development and test tools they used. Today, they are using Ada Cast™ for the FAA testing, which they estimate will require four months and 3.5 staff years to pass.

"Not as Painful as C++"

Tools and processor were not the only untested components to the IMD-HUMS development. While Chaffee and Clark are experienced Ada83 programmers, neither had worked in Ada95. Clark, who has tested soft-ware for commercial flight in his career, said that to develop IMD-HUMS in Ada83 would have been "painful, but not as painful as C++." New software development tools, new compiler, new processor, new language, new markets to conquer. No wonder Chaffee and Clark were forced to invent a new software development methodology, to coin a new mantra, and to discover a new design paradigm.
```

This “file in full” is not assembly, but it behaves like one: every paragraph pins down a design choice under competing constraints.

---

## WHY IT IS POWERFUL

### 1. It names the core invariant in five words.

“Data change, not software” is the load-bearing line. It compresses a full change-management philosophy into one rule: preserve executable stability, move variability into controlled data forms. In regulated real-time systems, this directly reduces recertification churn and lowers integration risk when requirements shift late.

This is paranoia as architecture: assume requirements will keep moving, then make sure the most expensive artifact to re-prove changes the least.

### 2. It solves a real dual-use conflict, not a toy abstraction.

The text is explicit about commercial and military tension. One side demands certifiability and lifecycle discipline; the other demands adaptability and cost control. IMD-HUMS is presented as a system built to survive both. That makes the writeup important: it captures a pattern for organizations that cannot choose a single customer model.

The impact is strategic. A dual-use platform that fails either constituency becomes unprofitable or non-deployable.

### 3. It integrates sensing, diagnosis, and operations into one pipeline.

The file describes high-rate acquisition across 150 channels, anomaly-triggered extra capture, cockpit alerting, onboard retention, post-flight transfer, and maintenance reporting. This is a full observability chain from edge sensor to fleet decision.

Infrastructure is defined by downstream dependence. When maintenance schedules and parts logistics consume your outputs, your software is no longer “application code”; it is operational substrate.

### 4. It treats certification pressure as a design-time force.

The source reports a project certification target requiring broad line and runtime execution testing. Whether phrased in standards language or program language, the effect is the same: architecture must be provable, test plans must be exhaustive, and runtime behavior cannot hide complexity.

That pressure explains language, profile, and tool decisions better than any style preference would.

### 5. Deterministic tasking is used as a risk-control mechanism.

The text associates the effort with RAVEN and an emerging Ravenscar profile emphasizing small size, speed, and deterministic behavior. In system terms, that is a deliberate restriction strategy: reduce concurrency ambiguity so timing and safety arguments remain tractable.

Paranoid systems do not maximize expressive freedom. They maximize confidence per execution.

### 6. It documents architecture surviving toolchain novelty.

New compiler, new processor, new test tools, new language version, and shifting requirements appeared simultaneously. Most programs break under that stack of novelty. This one reportedly held by anchoring on a doctrine and an object-oriented decomposition that absorbed additions without structural collapse.

The technical impact is resilience under compounded uncertainty.

### 7. It records an early, practical form of product-line engineering.

Without using modern jargon, the document describes configurable behavior over a reusable core serving multiple aircraft programs and operators. That is product-line architecture in substance: shared platform, variant policy surfaces, common verification discipline.

This remains a canonical strategy for expensive, long-lived systems.

### 8. It demonstrates that doctrine can be executable.

Grove’s principle is often quoted as management philosophy. Here it becomes implementation behavior: check for anomalies early, capture context before loss, preserve deterministic execution, and design for requirement shocks.

The impact is not rhetorical. It is measurable in uptime, certifiability, and fleet-level maintenance quality.

---

## INSTRUCTION-BY-INSTRUCTION POWER ANALYSIS

`BFGoodrich.txt` is prose, so the “instructions” are architectural assertions.

| Line Range | Assertion | Why It Is Load-Bearing |
|------------|-----------|-------------------------|
| 1–4 | Flexibility-vs-rigidity business paradox + IMD-HUMS response | Establishes the system-level conflict the architecture must resolve. |
| 6–8 | “Data change, not software” doctrine | Defines the governing invariant for change control and certification stability. |
| 10–12 | 150-channel acquisition, anomaly capture, cockpit warning, 20-hour retention, ground reporting | Shows full closed-loop operational design, not isolated telemetry ingestion. |
| 14 | 40K SLOC Ada95, predecessor context, active flight testing | Quantifies scale and maturity; this is production-grade, not conceptual. |
| 18 | Fluid requirements with commercial + military alignment | Proves this is a moving-target program, validating the doctrine’s necessity. |
| 20 | Source-reported certification/testing expectation including runtime | Explains why language/runtime/toolchain choices prioritize analyzability. |
| 24 | RAVEN/Ravenscar framing around deterministic tasking | Connects real-time concurrency constraints to certifiability and performance. |
| 28–30 | OOD robustness under requirement churn | Evidence that architectural modularity absorbed change without rewrites. |
| 32–36 | New processor/tools/language plus long verification effort | Captures delivery risk surface and the cost of proving safety-critical software. |

Remove any row and you lose a major component of the system’s argument.

---

## VERIFICATION STATUS

✓ **Doctrine verification:** Primary principle is explicitly quoted in the source (“Data change, not software”).  
✓ **Constraint verification:** Source names dual-use market pressure, fluid requirements, and certification/testing burden.  
✓ **Scale verification:** Source specifies 40K SLOC, 150 channels, and multi-stage data lifecycle.  
✓ **Real-time framing verification:** Source ties effort to RAVEN and an emerging Ravenscar-profile model for deterministic tasking.  
✓ **Operational impact verification:** Source describes outputs feeding maintenance and engineering decisions across distributed fleet operations.

**QED.**

---

## CLOSING

`BFGoodrich.txt` deserves reverence because it captures a rare thing: a safety-critical team turning doctrine into architecture under live operational pressure. The file is a blueprint for surviving requirement volatility without surrendering certifiability.

Its lesson is still current: in high-consequence systems, adaptability belongs in data, while correctness lives in a stable core that can be proven, repeated, and trusted.
