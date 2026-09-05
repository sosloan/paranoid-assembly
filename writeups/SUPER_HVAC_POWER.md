# THE POWER OF `cadhvac.txt` (SuperHVAC)

> *"Only the paranoid survive."* — Andy Grove
>
> *If a building model lies, every duct, pipe, and service order downstream inherits the lie. SuperHVAC is power because it refuses that lie at the data boundary.*

**Status:** ✓ COMPLETE  
**Subject:** `cadhvac.txt` (Ada Super-CAD / Integrated Engineering System for HVAC)  
**Form:** Power-of writeup, Track 031 style

---

## QUICK REFERENCE

| Attribute | Value |
|-----------|-------|
| **File** | `cadhvac.txt` |
| **Origin** | AdaIC flyer U149-0596 |
| **System Name** | Integrated Engineering System (Super-CAD for HVAC) |
| **Core Team** | 6 engineers |
| **Scale Stated** | ~900,000 LOC over ~300 person-months |
| **Critical Mechanism** | CAD views backed by one object-oriented database model |
| **Power Source** | Unified data model + typed extensibility |

---

## THE FILE, IN FULL

```text
Flyer U149-0596
cadhvac.txt

Ada Used to Develop "Super-CAD" System in the HVAC Industry

The Developer

Byron Informatik is dedicated to software development and
consulting for engineering companies in the HVAC (Heating
Ventilation and Air Conditioning) sector and for companies
doing facility management. Its clientele are from companies
around the world, including from Germany and Switzerland,
and will soon include many more European countries.

The System

Byron Informatik used the Alsys Ada development
environment to develop a super-CAD system, the "Integrated
Engineering System." The system is far more than a regular
CAD-system because all information about the objects is
stored in a database. The CAD-like applications, when
plugged into the database, directly manipulate the objects
in the database; there is no difference between applications
offering the information CAD-like and textual. In contrast,
other CAD systems store the drawings in a separate, internal
file format; even when coupled with a database, they tend to
dominate the whole system.

The Integrated Engineering System helps the design of
premises to optimize heating, ventilation, and air
conditioning effectiveness. The six-person team originally
developed a kernel for the HVAC engineer. It combines a
tight coupling between integrated tools through an
underlying object-oriented database and a uniform user
interface. The system allows an easy integration of new
tools. The kernel also fits well for Facility Management
tasks, namely Building and Cable Management.

The project is now six years old and the software
includes CAD-like features for the construction of schemes
and 3-D plant and building models. Additionally, it enables
users to make relevant calculations on these models for heat
loss and for the dimensioning of pipes and radiators. In
facility management applications, the dense information
available in a fully developed building model is presented
and used to organize administrative tasks (for instance,
services and moves).

The Development

The application was developed with the Alsys Ada compiler,
AdaWorld for HP9000/700 following the Object-Oriented Design
method (from Booch). It took about 300 person-months for
the six engineers to develop about 900,000 lines of code.
The application was developed with the help of several tools
and third-parties: Object Store (Object Design) as Database,
PHIGS (Figaro from Liant) and X11 (Motif for the user-
interface). A TCP/IP communication network has been used
for Object Store and X-Windows information exchange.

The Ada Advantages

Ada was chosen by the team for this project because it
perfectly meets the requirements of the application.
"First, Ada is a standard, which enables easy porting on
every platform. Second, it provides high-quality support
for large programs developed by several developers. Third
and finally, its safety features, like strong typing and
packages, are a key point, since it allows package
modification without affecting other program modules," says
Mr. Duppenthaler, Project Manager. In addition, Byron
Informatik developers were able to take advantage of code
reuse, made possible with Ada's generic features.

Ada's Future with Byron Informatik

In the near future, the application will be ported to
other Unix workstations and PCs using Solaris. At the same
time, the software will be loaded with enhanced
capabilities. Convinced of the benefits of Alsys and Ada,
Byron Informatik engineers also plan to start developing a
new facility management tool in Ada. They are looking
forward to the release of Ada 95.
```

A CAD story on the surface; underneath, it is a database-first concurrency and consistency story.

---

## WHY IT IS POWERFUL

### 1. It demotes drawing files and promotes shared state.

The decisive move is explicit: object information lives in the database, and CAD/textual applications manipulate the same objects directly. That eliminates the classic divergence where drawings become stale projections of a separate truth. SuperHVAC is paranoid in the right place: one model, many interfaces, no silent fork of reality.

### 2. It treats HVAC design as a systems-integration problem, not a drafting problem.

By centering a kernel plus integrated tools, the architecture supports geometry, calculations, and operational data in one environment. Heat-loss analysis and pipe/radiator dimensioning are not exported side jobs; they are computations on canonical model objects. This is how infrastructure software avoids reconciliation debt.

### 3. It chooses extensibility as a first-order requirement.

The file emphasizes easy integration of new tools. In building systems, requirements evolve with standards, equipment, and regulatory shifts. A rigid CAD core calcifies quickly. A kernel designed for tool addition makes change survivable without systemic rewrite risk.

### 4. It scales with disciplined engineering economics.

Six engineers, six years, 300 person-months, 900,000 lines. Those numbers reflect sustained architectural coherence. Large codebases fail when local convenience beats global structure. Here, object orientation, package boundaries, and standardized tooling appear as mechanisms to keep complexity tractable over long horizons.

### 5. It uses Ada's type and package model as a safety envelope.

The project manager's rationale maps directly to failure prevention: strong typing, packages, and generic reuse reduce accidental coupling and runtime ambiguity. In domain software where model errors can propagate into physical installations and facility operations, these language constraints are operational safeguards.

### 6. It keeps portability and communications visible.

The plan to port across Unix workstations and PCs, combined with TCP/IP exchange for ObjectStore and X-Windows, shows attention to system boundaries early. Portability is not a late-stage checkbox; it is a design axis. SuperHVAC survives by assuming platform drift and networked deployment from the start.

---

## INSTRUCTION-BY-INSTRUCTION POWER ANALYSIS

| Section | Statement | Power |
|---------|-----------|-------|
| System definition | Database-backed "super-CAD" with direct object manipulation | Preserves single-source truth across multiple interaction modes. |
| Contrast clause | Rejects separate internal drawing-file dominance | Identifies and avoids the canonical failure mode of CAD silos. |
| Kernel description | Tight coupling through OO database + uniform UI | Creates a stable integration substrate for domain tools. |
| Functional breadth | 3-D modeling + thermal/hydraulic calculations + facility tasks | Demonstrates model reuse across design and operations. |
| Development metrics | 300 person-months, 900k LOC, six-year lifecycle | Signals production-grade scale and sustained maintainability. |
| Ada rationale | Standard portability, large-team support, strong typing, packages, generics | Connects language choice to correctness and evolution safety. |
| Future path | Planned portability and capability expansion | Shows architecture built for continued adaptation. |

The text repeatedly chooses invariants over novelty: shared objects, explicit boundaries, and safe extension.

---

## VERIFICATION STATUS

✓ **Single-model architecture:** CAD-like and textual tools operate over the same database objects.  
✓ **Extensibility intent:** Kernel is explicitly designed for easy integration of new tools.  
✓ **Operational breadth:** Supports both engineering calculations and facility-management workflows.  
✓ **Safety orientation:** Language and package strategy are tied to large-system reliability.

**QED.**

---

## CLOSING

SuperHVAC's power is architectural sobriety: no duplicate truths, no hidden format kingdom, no casual coupling. It is paranoid where it matters—at data ownership, module boundaries, and long-term adaptability. That is how software for physical infrastructure survives.

