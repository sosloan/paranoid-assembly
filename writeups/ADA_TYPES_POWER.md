# THE POWER OF `ada-types.txt`

> *"Only the paranoid survive."* — Andy Grove
>
> *Before a task runs, before a lock contends, before a bit reaches a device,
> Ada asks a harder question: is this value allowed to exist here?*

**Status:** ✓ COMPLETE
**Subject:** `ada-types.txt` (Ada 95 language overview)
**Form:** Power-of writeup, Track 031 style

---

## QUICK REFERENCE

| Attribute | Value |
|-----------|-------|
| **File** | `ada-types.txt` |
| **Origin** | Ada 95 language overview, attributed to Laurent Guerby |
| **License** | Source text copyright retained by its author |
| **Language** | Ada 95 |
| **Critical Construct** | A type together with a constraint forms a subtype |
| **Primary Guarantee** | Operations apply only to meaningful values and interfaces |
| **Concurrency Model** | Tasks, rendezvous, and protected objects |
| **Power Source** | Static checking paired with explicit low-level escape hatches |

---

## THE FILE, IN FULL

`ada-types.txt` is a 596-line overview of Ada 95. Because it is an authored
reference text rather than source code under a repository license, this writeup
does not reproduce it in full. Its structure is the argument:

1. Objects, types, classes, operations, and static evaluation.
2. Elaboration, declarations, and controlled lifetimes.
3. Packages, private types, generics, separate compilation, and interfacing.
4. Tasks, protected objects, rendezvous, timing, and scheduling.
5. Exceptions and deliberately bounded low-level programming facilities.

Its central proposition is short enough to quote: “Every object has an
associated type.” From that starting point, the text makes type information,
visibility, synchronization, representation, and exceptions part of the
program’s enforceable design rather than conventions remembered by exhausted
humans.

---

## WHY IT IS POWERFUL

### 1. It makes invalid state expensive to express.

The file describes a type as a set of values with associated operations, then
adds subtypes that constrain that set. This is not decorative classification.
It gives a programmer a way to state that a value belongs in a particular
operating envelope and lets the compiler and runtime enforce that claim.

Grove’s paranoia begins before deployment: assume an incorrect value will
arrive eventually, and give it fewer places to hide.

### 2. It distinguishes types that look alike because mistakes do not.

Derived Ada types are distinct, even when they share a representation or an
ancestor. A programmer cannot silently substitute one for another merely
because both happen to fit in the same bits. Conversion must be explicit.

That protects interfaces from the oldest systems error: treating a plausible
number as the right number. A pressure reading, a duration, and an address can
all be machine words. They are not interchangeable facts.

### 3. It places the abstraction boundary where optimization needs it.

Packages separate the visible logical interface from the private
representation. The source explicitly notes that the private part can provide
the physical information needed for efficient code generation without exposing
that dependency to clients.

This is the mature compromise between clean architecture and silicon reality.
Clients receive a stable contract; implementers retain enough representation
control to meet a timing or memory budget. Neither side must pretend the other
constraint does not exist.

### 4. It makes concurrency a language-level obligation.

Tasks carry independent threads of control. Protected objects collect shared
state and synchronized operations together, allowing concurrent readers while
requiring exclusive access for procedures and entries. Rendezvous state the
point at which two tasks must meet.

The important move is syntactic containment. The synchronization policy lives
with the data it protects instead of being scattered as lock/unlock folklore
through every caller. That reduces the number of places where a race can
survive unnoticed.

### 5. It treats lifecycle as executable design.

Elaboration creates declared objects; finalization removes them as scope ends.
Controlled types permit defined initialization and finalization actions. The
file connects those actions to consistent resources and the prevention of
storage leakage.

Infrastructure fails at boundaries: startup, shutdown, timeout, and error
unwinding. Ada makes those boundaries language concepts. The paranoid system
does not reserve lifecycle discipline for a code-review checklist.

### 6. It preserves static certainty across compilation boundaries.

Separate compilation does not waive interface checking. The source emphasizes
that procedure arguments are checked whether declaration and call occupy one
compilation unit or many. Child library units extend a hierarchy without
forcing unrelated dependents to rebuild.

Large systems require local change without global amnesia. This model preserves
the compiler’s knowledge of contracts while allowing a library to grow.

### 7. It allows low-level control without making it the default.

Representation clauses, `System`, atomic and volatile variables, pragmas, and
inter-language interfaces acknowledge that systems software eventually meets
registers, devices, foreign ABIs, and memory layouts. Ada permits that contact
explicitly.

The escape hatches are named because they are dangerous. `Unchecked_Conversion`
is described as reinterpretation rather than a normal conversion, and
unprotected shared variables demand a disciplined protocol. The language does
not deny risk; it marks it.

### 8. It gives failure a typed route instead of a silent one.

Subtype violations raise `Constraint_Error`; declared exceptions identify
application failures; handlers define recovery at a known scope. The result is
not that failures disappear. It is that exceptional control transfer is visible
in the architecture.

That is strategic paranoia: detect a violated assumption near its boundary,
carry its meaning forward, and decide deliberately whether the system can
continue.

---

## CONSTRUCT-BY-CONSTRUCT POWER ANALYSIS

| Source area | Construct | Power |
|-------------|-----------|-------|
| III.1.1 | Type and object | Couples a permitted value set to the operations that may act on it. |
| III.1.1 | Subtype constraint | Turns a narrower operating range into an executable check and optimization fact. |
| III.1.2 | Tagged type and class-wide type | Supports controlled extension and dispatch without erasing type identity. |
| III.1.3 | Overload resolution | Requires the compiler to choose one legal meaning rather than accept ambiguity. |
| III.1.5 | Static evaluation | Moves knowable work and error detection before runtime. |
| III.2 | Elaboration and finalization | Gives construction and teardown defined semantic boundaries. |
| III.3 | Package and private type | Separates a stable client contract from representation and implementation detail. |
| III.3.4–III.3.6 | Generics and separate compilation | Enables reuse and growth while retaining compile-time interface checks. |
| III.4 | Task type | Names an active unit with an independent thread of control. |
| III.4.3 | Protected object | Co-locates shared data and its synchronization policy. |
| III.4.5–III.4.7 | Select, timing, and scheduling | Makes waits, deadlines, and readiness part of the program model. |
| III.5 | Exception and handler | Preserves failure meaning and selects a recovery scope. |
| III.6 | Representation clause and pragma | Exposes hardware control as an explicit, reviewable decision. |
| III.6.3–III.6.4 | Atomic, volatile, and unchecked facilities | Provides necessary low-level tools while declaring their proof burden. |

The file’s power is not a single instruction. It is a sequence of gates: type,
scope, interface, synchronization, representation, and recovery. Each gate
removes one class of accidental behavior before it reaches the machine.

---

## THE PARANOIA CONNECTION

Ada’s model applies Grove’s doctrine before the CPU sees an instruction:

1. **Assume values are hostile to their context.** Types and subtypes state
   where each value is valid.
2. **Assume interfaces will outlive implementations.** Packages and private
   types protect clients from representation churn.
3. **Assume concurrent access will happen at the worst moment.** Protected
   objects make synchronization a property of shared state.
4. **Assume low-level shortcuts can invalidate assumptions.** Atomic,
   representation, and unchecked facilities are explicit declarations of risk.
5. **Assume errors must be handled intentionally.** Exceptions preserve the
   identity and scope of a failed assumption.

> *Only the paranoid survive.* In Ada, paranoia is a type declaration that
> refuses to let the wrong value impersonate the right one.

---

## SCALE OF IMPACT

- **Hardware:** representation clauses, `System`, volatile and atomic objects
  connect portable declarations to device registers, layouts, and memory
  ordering.
- **Software:** packages, generics, and separately compiled units support
  long-lived systems whose components evolve independently.
- **Concurrency:** tasks and protected objects describe synchronization and
  communication without requiring every caller to implement a private locking
  protocol.
- **Cost per check:** static rules cost compile-time analysis; dynamic subtype
  and synchronization checks pay only where the declared semantics require
  them.

---

## VERIFICATION STATUS

✓ **Type discipline:** the source specifies static type checking and a unique
meaning for every designator.
✓ **Constraint detection:** a violated subtype constraint raises
`Constraint_Error`.
✓ **Protected access:** protected functions allow concurrent read-only access;
protected procedures and entries provide exclusive read/write access.
✓ **Interface checking:** separate compilation retains compile-time checks
across unit boundaries.
✓ **Representation control:** absent a representation clause or pragma, the
compiler may choose the representation; a programmer may make the choice
explicit when the hardware contract requires it.

**QED.**

---

## CLOSING

`ada-types.txt` does not celebrate assembly by pretending that every systems
problem is an opcode. It identifies the conditions under which an opcode can
be trusted: a value has a meaning, an interface has a boundary, a shared object
has a synchronization rule, and a hardware-dependent choice is visible.

That is infrastructure shaped by strategic doctrine. The most valuable
instruction is often the one the type system prevented from ever being emitted.

**Only the paranoid survive. ✓**
