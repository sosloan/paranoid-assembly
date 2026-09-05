# THE POWER OF `cadhvac.txt`

> *"Only the paranoid survive."* — Andy Grove
>
> *SuperHVAC is not a drawing tool. It is an operational doctrine encoded as software: model the building once, keep every discipline on the same object graph, and never let format boundaries become failure boundaries.*

**Status:** ✓ COMPLETE  
**Subject:** `cadhvac.txt` (Ada case study on Byron Informatik's Integrated Engineering System / "Super-CAD")  
**Form:** Power-of writeup, Track 031 style  
**Album Tie-In:** ONLY THE PARANOID SURVIVE — Infrastructure Memory

---

## QUICK REFERENCE

| Attribute | Value |
|-----------|-------|
| **File** | `cadhvac.txt` |
| **Origin** | Ada Information Clearinghouse flyer U149-0596 (1996) |
| **License** | Copyright notice in-file; historical reference text |
| **Architecture** | Ada + object-oriented database + PHIGS/X11 integration stack |
| **System Name** | Integrated Engineering System ("Super-CAD" / SuperHVAC) |
| **Primary Domain** | HVAC engineering + facility management |
| **Core Constraint** | Keep CAD views and textual/administrative views in one shared data model |
| **Critical Design Move** | Database-first object model; CAD tools become clients, not data owners |
| **Reported Scale** | ~900,000 LOC, ~300 person-months, 6 engineers |
| **Power Source** | Strong typing + package boundaries + integrated object state |

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
Engineering System."  The system is far more than a regular 
CAD-system because all information about the objects is 
stored in a database.  The CAD-like applications, when 
plugged into the database, directly manipulate the objects 
in the database; there is no difference between applications 
offering the information CAD-like and textual.  In contrast, 
other CAD systems store the drawings in a separate, internal 
file format; even when coupled with a database, they tend to 
dominate the whole system. 

The Integrated Engineering System helps the design of 
premises to optimize heating, ventilation, and air 
conditioning effectiveness.  The six-person team originally 
developed a kernel for the HVAC engineer.  It combines a 
tight coupling between integrated tools through an 
underlying object-oriented database and a uniform user 
interface.  The system allows an easy integration of new 
tools.  The kernel also fits well for Facility Management 
tasks, namely Building and Cable Management. 

The project is now six years old and the software 
includes CAD-like features for the construction of schemes 
and 3-D plant and building models.  Additionally, it enables 
users to make relevant calculations on these models for heat 
loss and for the dimensioning of pipes and radiators.  In 
facility management applications, the dense information 
available in a fully developed building model is presented 
and used to organize administrative tasks (for  instance, 
services and moves). 

The Development

The application was developed with the Alsys Ada compiler, 
AdaWorld for HP9000/700 following the Object-Oriented Design 
method (from Booch).  It took about 300 person-months for 
the six engineers to develop about 900,000 lines of code.  
The application was developed with the help of several tools 
and third-parties: Object Store (Object Design) as Database, 
PHIGS (Figaro from Liant) and Xll [sic] (Motif for the user-
interface).  A TCP/IP communication network has been used 
for Object Store and X-Windows information exchange. 

The Ada Advantages

Ada was chosen by the team for this project because it 
perfectly meets the requirements of the application.  
"First, Ada is a standard, which enables easy porting on 
every platform. Second, it provides high-quality support 
for large programs developed by several developers.  Third 
and finally, its safety features, like strong typing and 
packages, are a key point, since it allows package 
modification without affecting other program modules," says 
Mr. Duppenthaler, Project Manager. In addition, Byron 
Informatik developers were able to take advantage of code 
reuse, made possible with Ada's generic features. 

Ada's Future with Byron Informatik

In the near future, the application will be ported to 
other Unix workstations and PCs using Solaris.  At the  same 
time, the software will be loaded with enhanced 
capabilities.  Convinced of the benefits of Alsys and Ada,  
Byron Informatik engineers also plan to start developing a 
new facility management tool in Ada.  They are looking 
forward to the release of Ada 95.

For further information, please contact: 
Ann Trib 
Alsys GMBH & Co.KG 
Kleinoberfeld 7 
D-75135 Karlsruhe 
Germany 
Tel: + 49 721 985 530 
Fax: + 49 49 721 985 5398
										
Produced in cooperation with the AdaIC, Ada Software 
Alliance, and ACM SIGAda.


********************** 
The views, opinions, and findings contained in this report are those of 
the author(s) and should not be construed as an official Agency 
position, policy, or decision, unless so designated by other official 
documentation.

Copyright 1996.  IIT Research Institute.  All rights assigned to the 
U.S. Government (Ada Joint Program Office).  Permission to reprint this 
flyer, in whole or in part, is granted, provided the AdaIC is 
acknowledged as the source.
**********************

Ada Information Clearinghouse (AdaIC)
P.O. Box 1866
Falls Church, VA  22041
Telephone:  1-800-AdaIC-11 (1-800/232-4211) or 703/681-2466
Fax:  703/681-2869
E-mail:  adainfo@sw-eng.falls-church.va.us

The AdaIC is sponsored by the Ada Joint Program Office and operated by 
IIT Research Institute.
```

A legacy field report in plain text, but the architecture it describes still feels contemporary: one canonical model, many tools, zero tolerance for divergence.  
Reproduced here for technical analysis with source attribution preserved inline, consistent with the flyer's stated in-text reprint permission and this repository's LICENSE policy note in `README.md`.

---

## WHY IT IS POWERFUL

### 1. It chooses a single source of truth before that phrase was fashionable.

The defining move in SuperHVAC is database-first modeling. Drawings are not sovereign artifacts; they are views into shared objects. That decision removes a major failure mode of engineering software: multiple representations of "the same" system drifting apart until no one can prove which one is true. This is Grove-style paranoia at the data layer: assume drift will happen, then design so drift has nowhere to hide.

### 2. It treats CAD as one interface among many, not the center of the universe.

The flyer explicitly contrasts SuperHVAC with systems where CAD file formats dominate everything around them. SuperHVAC inverts that hierarchy. CAD clients plug into the model alongside textual and administrative workflows, so analysis, operations, and documentation all manipulate the same entities. That is an architectural power move because it keeps visual tooling from becoming a silo.

### 3. It scales by language discipline, not heroics.

Six engineers and 900,000 lines over roughly 300 person-months only works with hard modular boundaries. The team points to Ada packages, generics, and strong typing as the practical mechanism. They are describing survivability engineering: changes remain local, interfaces stay explicit, and reuse is institutionalized. This is how a small team ships a large system without dissolving into accidental complexity.

### 4. It fuses geometry and physics in one operational loop.

The system does not stop at drafting 3-D models; it runs heat-loss and sizing calculations directly over those same models. That means geometric edits and thermodynamic consequences remain close in time and data locality. The design shrinks the gap between "what the building is" and "what the building does," which is exactly where costly HVAC mistakes usually emerge.

### 5. It was built for extension from day one.

The kernel is described as enabling "easy integration of new tools" and already stretches from HVAC design into building and cable management. That reuse path exists because the team invested in object-level integration rather than point-to-point feature stitching. In paranoid terms: they assumed requirements would expand, so they built a center that can absorb new domains without rewriting the whole stack.

### 6. It captures infrastructure reality: systems live longer than hardware cycles.

The text documents planned ports across Unix workstations and Solaris-era PCs. Portability is not positioned as convenience; it is a continuity strategy for long-lived industrial software. SuperHVAC treats platform churn as inevitable and chooses standards-based language/tooling to survive it. The paranoia is temporal: plan for future migration pressure before it arrives.

---

## INSTRUCTION-BY-INSTRUCTION POWER ANALYSIS

| Lines | Text Section | Power |
|------|--------------|-------|
| 1–4 | Title block and Super-CAD claim | Declares this is not generic CAD marketing; the "Super-CAD" framing sets architectural ambition immediately. |
| 8–13 | Developer context | Anchors the problem in HVAC + facility operations, signaling multi-discipline requirements from the start. |
| 17–27 | Database-first system description | The load-bearing statement: CAD and textual applications manipulate one object store. |
| 29–37 | Kernel and integration model | Defines the extensible core (uniform UI + OO DB + integrated tools). |
| 39–47 | Applied engineering functions | Shows that computation (heat loss, sizing) is co-located with geometry, not bolted on later. |
| 51–59 | Toolchain and scale metrics | Gives the concrete build reality: 900k LOC, 300 person-months, and heterogeneous middleware. |
| 63–73 | Ada rationale quote | Names the actual reliability levers: standardization, large-system support, strong typing, package isolation, generics. |
| 77–83 | Portability and roadmap | Confirms longevity strategy and continued investment, not one-off prototype behavior. |
| 98–118 | Provenance and licensing footer | Preserves institutional context and reusability terms for archival integrity. |

Every section carries operational meaning: architecture, scale, language choice, and evolution strategy are all explicit and mutually reinforcing.

---

## VERIFICATION STATUS

✓ **Single-model architecture stated:** The file explicitly says CAD-like and textual tools directly manipulate shared database objects.  
✓ **Scale evidence present:** Team size, person-month effort, and approximate LOC are all named.  
✓ **Language rationale explicit:** Strong typing, package isolation, and generic reuse are directly quoted as selection criteria.  
✓ **Lifecycle intent documented:** Porting and follow-on tool plans are specified, indicating deliberate long-horizon design.

**QED.**

---

## CLOSING

`cadhvac.txt` reads like an old flyer, but its core lesson is modern: paranoid systems engineering starts by denying data fragmentation the right to exist. SuperHVAC centralized truth, constrained interfaces, and used Ada's type discipline to keep a very large codebase survivable for a very small team.

In other words: one model, many views, no drift.  
That is how SuperHVAC survives.
