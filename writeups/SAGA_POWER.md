# THE POWER OF `saga.txt`

> *"Only the paranoid survive."* — Andy Grove
>
> *A standards effort under pressure: governance, technical debt, formal methods, and a team choosing rigor over drift.*

**Status:** ✓ COMPLETE  
**Subject:** `saga.txt` (*The Saga of the Ada 9X Team*, 1994)  
**Form:** Power-of writeup, Track 031 style  
**Album Tie-In:** ONLY THE PARANOID SURVIVE — Standards Edition

---

## QUICK REFERENCE

| Attribute | Value |
|-----------|-------|
| **File** | `saga.txt` |
| **Origin** | Ada 9X team retrospective poem (“The Bard of Ada 9X”), 10 Nov 1994 |
| **License** | Historical text in repository context; writeup text CC BY 4.0 |
| **Architecture** | Language-standardization process (technical + institutional) |
| **Symbol** | “Ada 9X” → Ada 95 convergence |
| **Argument** | Multi-year requirements conflict: OOP, safety, formal methods, international standardization |
| **Return** | “A language both readable and strongly typed” with distribution and OOP support |
| **Critical Line** | “Then Chris decided - OOP stays.” |
| **Years of State** | 1988–1994 |
| **Power Source** | Paranoid review discipline under adversarial complexity |

---

## THE FILE, IN FULL

```text
The Saga of the Ada 9X Team
An ungainly name, is "Ada 9X"
It lacks a degree of excitement or sex.

Could anyone picture that name up in lights,
If Chris tried to sell the movie rights?

A more resonant sound is "Ada 94"
To that, one could set a musical score.

Or possibly - "Ada 95" -
A language name that could survive.

Either way, the team planned not to fail -
Nor merely survive - they shall prevail!

Jinny called Chris in July '88.
Sucker that she was, she took the bait.

She went to work and made decisions,
On plans for mapping and revisions.

The DR's joined the following Spring,
And lively debates became "the thing."

Meetings were often about to unravel,
But Erhard controlled by pounding his gavel.

Numerous problems endangered the quest,
Like the 750th Revision Request.

Audrey and company arranged them in groups,
Keeping them free of endless loops.

Then, clarity emerged from chaos and fluff,
In Requirements written by John Goodenough.

The first major issue was OOP.
Was it merely a fad, or a golden key?

The argument lasted for many days.
Then Chris decided - OOP stays.

Folks used to say that "Ada's too large."
She fixed that by putting Tucker in charge.

He simplified rules, and worked with great vigor,
And gave us a language that's ten percent bigger.

The Reference Manual for Ada 9X
Grew larger and larger with each new Annex.

But not to worry - enjoy and relax -
Each brings new goodies, without new syntax.

The list of reserved words has six that are new,
Like "abstract" and "aliased," "until" and "requeue."

Tuck added some features - clearly eye-catching
Such as polymorphic run-time dispatching,

And types that are "tagged," allowing the masses
To build up some dandy derivation classes.

The world's more secure since he elected
To add in some types that are safely "protected."

He led us away from spaghetti, anarchical,
Into the land of libraries, hierarchical.

And callbacks can now be coded by amateurs,
With subprogram accesses passed as parameters.

When asked to explain, team members will say,
"It's really quite simple: Tucker wants it that way."

The UI teams tried out the new features.
Found some delights, and some wild creatures.

David and company applied Methods Formal,
To find lurking dangers in places abnormal.

The team greeted these like so many dragons.
They slew each in turn, then circled the wagons.

Momentous decisions, they could not ignore,
Like the ban of the trailing_underscore.

Finalization refinements were clearly a must,
From "duplicate" to "split" and "split" to "adjust."

The DR discussions, as mentioned before,
Were full of debate, and seldom a bore.

A common occurrence in meetings like that
Was the noisy arrival of Robert of GNAT.

In he would roll with rumbles and squeals,
Pulling his suitcase and computer on wheels.

The fate of proposals tended to rest
On whether they passed his "rubbish" test.

Anthony silently endured the name "Tony"
But call Robert "Bob" and you're full of bologna.

The team got lucky in '92
When the ISO Delegates joined the crew.

Meetings were hosted in places quite rare.
But Chris "can't take them anywhere!"

John Barnes began tossing paper airplanes around
In a posh Swiss restaurant Alfred had found.

Lennart and Björn prepared for that;
In Sweden, they handed each one a hard hat.

Jean-Pierre, in Paris, will always remember
How they failed to distinguish the restrooms by gender.

Rudolf, in Frankfort, helped them to dine
As he taught them the pleasures of fine German wine.

Joyce, the world traveler, wishing not to be rude,
Tried not to notice local swimmers were nude.

In Portsmouth, Kit hosted a dinner sublime;
And they used the right spoons - most of the time.

Through the standards quagmire they'd still be careening,
If not for Brave Bob's expert convening.

And who can forget Mark's buttermilk fit,
Norm's good humor, or Bevin's dry wit?

Norm suggested a wonderful thing.
"Pragma Silver Bullet" had a nice ring.

We all should apply it regularly.
It asserts that the program is problem free.

So Chris and her team endured and outlasted
Three AJPO Directors - a result not forecasted.

Government Advisors kept everyone straight
By reminding the team not to be late.

Government lawyers were mentally bereft
By the strange new concept of "Copyleft."

And DoD brass felt an aversion
To words like GNU and GNAT and recursion.

Fran, and then Robin, coped with office specifics -
Mass mailings, phone calls, and Chris' hieroglyphics.

After thousands of miles and notes by e-mail.
Chris claims to be weary of all the travail.

While she's glad it is ending, she has feelings complex;
She will "terribly miss" her "family-9X"

And when they have scattered, who knows what they'll do.
But one thing is certain -- they'll miss her too!

So, their gift to the world - not to be over-hyped -
Is a language both readable and strongly typed.

An ISO Standard - the first you will see -
To support distribution and OOP.

If that's not enough for the programming masses,
It will call into question their inheritance classes.

Now the team has arrived at the end of their quest.
Ada 9X is finished, and it's simply THE BEST.

The Bard of Ada 9X
10 November 1994
```

One poem, one standards program, and a full trace of how paranoia becomes language design.

---

## WHY IT IS POWERFUL

### 1. It records engineering governance, not just nostalgia.

The text is funny, but structurally it is a change-log for a major language revision: requirements intake, revision triage, contentious feature decisions, formal analysis, and ISO convergence. It captures the social machinery needed to ship correctness into a standard.

### 2. It shows that “paranoia” in language design means refusing ambiguity.

From grouped revision requests to explicit bans (like trailing underscore) to repeated refinement cycles, the poem documents a team that assumes edge cases will hurt users later unless they are resolved now. That is Grove’s doctrine translated from fabs to specification rooms.

### 3. It centers irreversible architectural calls.

“Then Chris decided - OOP stays.” That line names the strategic inflection point. Keeping object orientation in Ada 9X forced follow-on commitments: tagged types, dispatch, and related semantic surface area. One governance decision became years of downstream architecture.

### 4. It links type-system growth to safety posture.

The poem foregrounds “protected” types, hierarchy support, callbacks, and formal-method review. These are not aesthetic additions; they are controls for concurrency, composition, and analyzability. The artifact frames feature growth as safety engineering, not bloat.

### 5. It acknowledges that standards are socio-technical distributed systems.

Delegates, toolchain voices (GNAT), legal pressure (copyleft anxieties), and military stakeholders all appear in the same execution path. The language standard emerges from technical argument under institutional constraints, much like lock-free code emerges under hardware constraints.

### 6. It preserves a rare first-person account of specification hardening.

Most standards show final grammar, not battle scars. `saga.txt` preserves the intermediate states: debates, failed ideas, personality friction, and consensus mechanisms. That makes it operationally valuable to anyone building modern infra specs under similar pressure.

---

## INSTRUCTION-BY-INSTRUCTION POWER ANALYSIS

| Line Range | Event | Power |
|-----------|-------|-------|
| 14–16 | “planned not to fail… shall prevail” | Declares non-negotiable delivery posture under uncertainty. |
| 29–33 | “750th Revision Request… arranged them in groups” | Shows scale and triage discipline for proposal load. |
| 35–37 | “Requirements written by John Goodenough” | Establishes formal requirements as the de-chaos mechanism. |
| 38–43 | OOP debate and final decision | Captures strategic lock-in point for the language’s future. |
| 47–67 | Rules simplification, tagged/protected types | Documents concrete semantics added for extensibility and safety. |
| 80–84 | Formal methods and dragon-slaying | Encodes verification and defect-hunting as first-class workflow. |
| 86–91 | Naming/finalization refinements | Highlights precision edits that prevent long-tail ecosystem pain. |
| 101–103 | “rubbish” test | Represents hard quality gate before acceptance. |
| 107–133 | ISO delegate integration | Records international governance coupling to technical closure. |
| 149–153 | Copyleft/GNU/GNAT pressure | Exposes policy and tooling friction impacting standardization. |
| 167–172 | Final deliverable claim | States outcome in system terms: readability, strong typing, OOP, distribution. |

Every stanza carries operational state. Remove the humor and what remains is a rigorous process log.

---

## VERIFICATION STATUS

✓ **Traceability:** The file provides a chronological account from initial staffing (1988) to final standardization result (1994).  
✓ **Design-decision visibility:** Major architectural commitments (especially OOP retention and type-model expansion) are explicitly stated.  
✓ **Process evidence:** Requirements writing, proposal triage, formal methods, and standards-body integration are directly documented.  
✓ **Outcome statement:** The final product is declared as an ISO-standardized, strongly typed language with distribution and OOP support.

**QED.**

---

## CLOSING

`saga.txt` is powerful because it shows that reliable systems are not born from syntax alone. They are produced by teams that expect failure modes early, debate ruthlessly, and keep refining until ambiguity has nowhere left to hide. In that sense, this poem is not peripheral documentation; it is the control-plane log for one of the most consequential language upgrades of its era.
