# THE POWER OF `banking.txt`

> *"Only the paranoid survive."* — Andy Grove
>
> *A payments system is not just money in motion. It is state under stress, language under load, and correctness measured in trust.*

**Status:** ✓ COMPLETE  
**Subject:** `banking.txt` (Swiss PTT financial system case study, 1996 flyer)  
**Form:** Power-of writeup, Track 031 style

---

## QUICK REFERENCE

| Attribute | Value |
|-----------|-------|
| **File** | `banking.txt` |
| **Origin** | Ada Information Clearinghouse flyer U126-0596 |
| **Domain** | Swiss post/telegraph/telephone financial services |
| **Scale Stated** | 1.2–1.4 million customer records; ~2 million daily transactions target |
| **Core Platform** | OpenVMS + DEC Rdb + Ada-heavy application stack |
| **Critical Mechanism** | Centralized authoritative customer/account state |
| **Power Source** | Typed software architecture + operational paranoia |

---

## THE FILE, IN FULL

```text
Flyer U126-0596
banking.txt

Ada Used to Automate Swiss Banking System

Based on a flyer by Alan Paterson, Paranor AG.

The Swiss post/telegraph/telephone company includes a
department that runs a financial payments system. Customers
hold interest-bearing accounts, and transactions on these
accounts are made in a similar fashion to 'normal' banks.
In practice, these accounts form the major means of non-cash
payments (also to and from banking accounts) in Switzerland.

The Development

The project is being realized in two phases. First, all
customer information is collected in a central database.
This information comprises:

* Details of the customer, e.g., address(es)
* Details of all accounts held by each customer
* Details of all Postcards (check guarantee, cash
dispenser & EFTPOS) held on each account
* Details of checks issued for each account
This system is the central store of knowledge about all
customers using the financial services of the PTT, which
involves:
* 350 graphical workstations throughout Switzerland
* Between 1.2 and 1.4 million customer records and
approximately the same number of account records
* Approximately 10,000 modifications per day (eight
hours).
* Approximately 20,000 inquiries per day.
* Approximately 7,000 orders for checks per day.

With the system in place (Version 2 is now in operation),
the data records are brought on-line. Work also proceeds on
Versions 3 and 4 of the system, which add functionality.

The Implementation

To date, the system runs only on VAX computers, although
future versions will use Alpha-AXP machines. There is a
central cluster of database servers, connected (by X25) to
remote clusters of VAX workstations. The operating system
is OpenVMS and the database system is DEC RdB. With the
exception of the database interface modules, three macro
assembler files and one C source file, all software is
written in (DEC) Ada. So far in the development, there are
approximately 2,200 Ada source files.

There is extensive use of an in-house CASE tool
supporting OOA/OOD and finite-state automata. The GUI is
implemented with OSF/Motif and is highly structured to use
finite-state automata with the previously mentioned tool.
The GUI is multi-lingual (German, French, Italian), and
adjusts to the mother-tongue of the user, producing output
in the language of the customer. Communication between
workstations and the central server cluster happens via an
in-house Remote Procedure Call mechanism that supports load
distribution, exception passing over the network, and
automatic recovery on errors.

Selecting Ada

Ada has been in use at Paranor, the system developer, since
1985 and there was never any consideration given to the use
of any other language. All active programmers are agreed
that a switch to another language would mean a marked
reduction in programming comfort and ultimately result in an
inferior product. The principal features of Ada which make
it superior include:

* Data abstraction/Information hiding (there is
extensive use of private and derived types)
* Tasking (especially for communication between
computers)
* Generics (extensively used in the GUI)
* Highly readable source code

Phase 2

Phase 2 includes the use of actual financial transactions
and user accounts. This phase is planned to be completed by
Jan. 1995 and to be fully operational in Jan 1996. Ada
enthusiasts around the world await news of the project's
success and can expect to learn that the system, upon its
completion, handles 2,000,000 financial transactions per
day.
```

A historical flyer, but the architecture reads like modern infrastructure doctrine.

---

## WHY IT IS POWERFUL

### 1. It makes one database the non-negotiable source of truth.

The writeup centers a single proposition: all customer, account, card, and check state is consolidated into one central database. That choice is not glamorous, but it is load-bearing. When money moves, contradictory state is existential risk. A central authoritative store is paranoia codified as architecture: do not trust copies, do not trust stale replicas, and do not let branch-office drift become financial drift.

### 2. It treats geography as a distributed-systems problem.

Three hundred fifty workstations across Switzerland, linked to clustered servers over X.25, implies non-trivial latency, link variability, and failure domains. The system is described in business terms, but its shape is unmistakably distributed computing under constrained links. The power is in admitting this upfront and building RPC, load distribution, and network exception handling into the core rather than as afterthought patches.

### 3. It acknowledges that failure handling is first-class functionality.

The in-house RPC mechanism is noted for exception passing and automatic recovery. That is the paranoid move: assume faults are normal, not exceptional. In financial systems, "retry later" can become double-charge risk unless semantics are explicit. A design that carries exceptions across the network and automates recovery paths is not convenience; it is survival engineering.

### 4. It scales state mutation and state inquiry explicitly.

The file quotes daily rates for modifications, inquiries, and check orders. Those numbers are strategic telemetry. They inform where concurrency pressure will concentrate and where indexing, locking, and queueing must perform. The power is not in high numbers alone; it is in making workload shape visible so the system can be tuned against real pressure, not generic assumptions.

### 5. It uses language features as operational controls.

Ada's private types, tasking, and generics are presented as reasons for selection, but the deeper reading is control over complexity. Strong typing narrows invalid states; tasking maps naturally to concurrent communication; generics reduce duplication across large GUI and business layers. This is paranoia against entropy: constrain what code can express before production has to absorb the cost.

### 6. It plans migration without pretending away compatibility risk.

The transition path from VAX to Alpha-AXP is named directly. Platform shifts in financial infrastructure are where hidden assumptions break. By staging the system in versions and phases while preserving core architecture, the project avoids the common trap of combining functional change with platform change in one destabilizing leap. That is strategic caution, not inertia.

---

## INSTRUCTION-BY-INSTRUCTION POWER ANALYSIS

| Section | Statement | Power |
|---------|-----------|-------|
| Opening context | Swiss PTT payments as mainstream non-cash channel | Frames this as national infrastructure, not niche tooling. |
| Development scope | Central database of customers/accounts/cards/checks | Declares canonical state boundaries early and explicitly. |
| Scale bullets | Workstations, records, and daily operation counts | Quantifies the load envelope and concurrency reality. |
| Implementation stack | VAX/OpenVMS/DEC Rdb/Ada with minimal non-Ada islands | Shows disciplined stack control and deliberate language strategy. |
| RPC description | Load distribution + exception passing + auto recovery | Encodes failure semantics as a core protocol feature. |
| Language rationale | Data abstraction, tasking, generics, readability | Connects implementation language to system correctness and maintainability. |
| Phase 2 target | 2,000,000 transactions/day | States the intended operational proof point in measurable form. |

Each paragraph does one thing: reduce ambiguity about correctness, scale, or failure posture.

---

## VERIFICATION STATUS

✓ **Authoritative-state design:** Explicitly centralized customer/account knowledge base.  
✓ **Distributed-awareness:** Network topology and remote execution model are documented.  
✓ **Failure posture:** Exception propagation and automatic recovery are built into RPC narrative.  
✓ **Scalability intent:** Daily operation volumes and transaction targets are concretely specified.

**QED.**

---

## CLOSING

`banking.txt` is powerful because it documents a financial system that refuses wishful thinking. It assumes scale, assumes faults, and assumes that trust depends on disciplined state management. Grove's line fits perfectly here: paranoia is not panic; paranoia is architecture that survives contact with production.
