---
name: grill-with-docs
description: Relentlessly grill and stress-test a plan or design, while actively building and updating documentation (CONTEXT.md glossary and ADRs) as decisions crystallize.
---

# Grill with Docs

An active pairing discipline combining relentless stress-testing with real-time documentation. Interview the user through a structured **design tree**, while capturing canonical vocabulary in `CONTEXT.md` and high-impact decisions in `docs/adr/`.

---

## 1. The Grilling Loop

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

### Round Format:

```markdown
❓ **Q1** - **<question title>**: <question body, explaining context, tradeoffs, and options>

💡 **Recommendation**: <your recommended choice and rationale>

---

❓ **Q2** - **<question title>**: <question body, explaining context, tradeoffs, and options>

💡 **Recommendation**: <your recommended choice and rationale>
```

### Grilling Rules:
- **Finding facts is your job**: If a question depends on inspecting code, config, or docs, inspect them directly or run tools/sub-agents. Never ask the user for facts you can discover yourself.
- **Decisions belong to the user**: Present the tradeoffs clearly, give a strong recommendation, and wait for confirmation.
- **Progressive frontier**: As decisions are settled, update the frontier with downstream questions.

---

## 2. Real-Time Domain & Decision Documentation

As questions are answered and decisions crystallize, write them down immediately.

### A. Maintain Glossary (`CONTEXT.md`)
Whenever domain terms are introduced, clarified, or disambiguated:
- Update or create `CONTEXT.md` in the project root (or context subfolder).
- Ensure tight 1–2 sentence definitions of what each concept IS.
- Include `_Avoid_:` for ambiguous synonyms or overloaded words.
- Keep implementation details out of `CONTEXT.md`.

Example `CONTEXT.md`:
```markdown
# Domain Context

## Language

**ScreeningSession**:
A single continuous evaluation instance for a patient's health parameters.
_Avoid_: Assessment, checkup, test

**RiskLevel**:
A calculated categorical tier (Low, Moderate, High, Critical) determining clinical followup.
_Avoid_: Score, grade, severity
```

### B. Record Architecture Decisions (`docs/adr/NNNN-slug.md`)
Only propose/create an ADR when all 3 criteria are met:
1. **Hard to reverse**: High switching/migration cost later.
2. **Surprising without context**: A future engineer might wonder "why was it built like this?".
3. **Real trade-off**: Deliberately chosen among competing alternatives.

ADR Structure (`docs/adr/0001-slug.md`):
```markdown
# 1. {Title of Decision}

**Context & Decision**: {1-3 concise sentences stating the problem, what was chosen, and why.}

**Consequences**: {Key benefits, constraints, or non-obvious downstream impacts.}
```

---

## 3. Completion

The session is complete when:
1. The frontier is empty (no unvisited branches or unresolved assumptions in the design tree).
2. The user has confirmed the decisions.
3. `CONTEXT.md` and any necessary ADRs have been written to disk.
