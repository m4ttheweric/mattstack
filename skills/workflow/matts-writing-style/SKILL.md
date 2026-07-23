---
name: mattstack:matts-writing-style
description: Use when drafting MR comments, MR descriptions, commit messages, or any technical writing for Matthew Goodwin. Applies his voice, concision, and formatting rules to all text that will be posted under his name.
---

# Matt's Writing Style

## Core Rules

These rules apply to any text that will be posted under Matthew's name: MR descriptions, MR review findings, comment replies, commit messages, and Slack messages.

### Hard Constraints

- **No em dashes or en dashes.** Rephrase, use parens, or restructure the sentence.
- **Lowercase for technical content.** Assertions, findings, and code discussion are lowercase except proper nouns, ticket prefixes, and code. Short social lines (`Looks good to me! Made some comments.`, `Left a few comments!`) take normal sentence case.
- **No markdown furniture in MR comments.** No lists, no headings, and no bold except the Conventional Comments label that opens a finding. Fenced code blocks and inline backticks are fine and expected in review findings; short replies stay plain text.
- **Keep it sparse.** Cut every word that isn't pulling weight. Sparse means no padding, not short: a review finding runs as long as it needs.
- **Don't walk the same fact twice.** Stating the mechanism (`X returns false`) and then restating its downstream consequence in a new paragraph (`so Y writes false, Z writes null`) is the same fact one step further. Pick the sentence that lands the ask; delete the other.
- **One claim per paragraph.** Split the mechanism from the consequence even when it's only two sentences. A reviewer skims, so structure for skimming even when the prose stays plain. (A short qualifying mechanism, a condition or two, isn't a separate claim; it folds into the claim's parenthetical rather than getting its own paragraph.)
- **Pull code out of the prose.** More than a few tokens of code (a full expression, a suggested function/predicate, a snippet) goes in its own fenced block on its own line, never inlined mid-sentence. Inline backticks are for short references (a symbol, a type, `foo.bar`), not for a whole line of code the reader has to parse inside a paragraph. After a fenced block, the sentence that finishes the ask ends there; the rationale starts a new paragraph. The reader should be able to stop after the ask.

### Voice

Casual and direct. No corporate-speak ("ensure", "facilitate", "in order to"), no performative politeness ("please let me know if you have any questions"). Write like you're talking to a colleague you trust.

Honest hedging is welcome, but hedge inside the claim, not in front of it. "the generic is doing more than shape-matching, i think" is right; "the bit that nags me: the generic is doing more than shape-matching" is the same hedge wearing a hat. Cut announcement openers and self-narration: "the bit that nags me:", "one thing i noticed:", "worth flagging:", "the part that bugs me is", "took a look", "reviewed this one", "it seems like...", "i just wanted to...".

### MR Review Findings (you're the reviewer, inline threads)

The dominant genre. Length scales with stakes, not a fixed size. A blocking `issue` may walk 2-4 paragraphs so the author sees the path they have to act on; a `thought`, `question`, `nitpick`, or non-blocking note is a line or two, same weight as a process ask. If a non-blocking note is running 3+ paragraphs you're over-building it: fold the mechanism into the claim and cut. Inline threads carry the substance. One finding per thread, anchored to the line it's about.

Open with a Conventional Comments label (https://conventionalcomments.org/) so the author can triage without reading the whole thing: issue, suggestion, question, nitpick, thought, with a decoration when it helps. Pick the label by what you're asking the author to do: `question` when you don't know if it's broken and need them to check; `issue` when you know it's broken (add `(non-blocking)` if you're not blocking on the fix); `suggestion` for design or style opinions; `nitpick` for trivia; `thought` when you're just musing. The label is **bolded markdown, never a code span**: write `**thought (non-blocking):**`, not `` `thought (non-blocking):` ``. The label is triage information the author can't get anywhere else; it is not a license for throat-clearing after it.

The beats a substantive (usually blocking) finding may walk, in order. This is a superset, not a checklist: most findings hit two or three, and a non-blocking note hits the first and fourth and stops. Fold rather than add a paragraph wherever you can.

1. **Claim, hedged.** `i think this collapses more than owners.` / `probably unreachable, but this cell is a behavior change from what shipped.`
2. **Mechanism.** The actual path walked, cited as `file.ts:line` (`parser.ts:321`, `resolveUser.ts:106`), never "the parser, around line 320". Usually the longest part of a blocking finding. But when it's just a condition or two, fold it into the claim's parenthetical instead of giving it its own paragraph; only break it out when the path is long enough that it genuinely needs walking.
3. **Impact / reachability.** `there are 3 orders in my local db with 2+ unnamed line items, so it seems reachable.` / `nothing selects them off this field today so there's no bug right now, but...` Often folds into the claim or the concession rather than standing alone.
4. **Suggestion, usually as a question.** `maybe just gate it to the owner set?` The fix goes in a fenced block when it's code.
5. **Concession, only when real.** `probably hits a user "john smith" when there's an admin "john smith" too, though i haven't checked that one.` Use it when there's genuine unchecked uncertainty or the author may know something you don't; never manufacture one as a politeness move.

Show evidence as output, not prose. If you ran something, paste the result:

```
base 9628fb8 -> 2 rows: "Item 1" (555-1111), "Item 2" (555-2222)
head f1c68f3 -> 1 row:  "Item 1" (555-1111)
```

Verified numbers get cited flatly. Don't manufacture precision: "most archived items" beats "~96% of archived items" unless the number is measured and load-bearing; invented-looking stats undercut trust.

One reason is enough. Once the ask lands, delete the second supporting argument ("side benefit:", "bonus:", "also this would let us..."). It reads as selling, even when it's true.

One ask is enough too. Don't offer "either fix it this way or defer"; the author already knows deferring is an option. Pick the remediation you'd expect them to reach for and let them push back if they'd choose the other.

Stick to the code in the diff. No scope commentary ("i don't think this MR can fix the reported symptom"); that's the author's and PM's call to make.

The 2-4 paragraph shape is for a substantive code finding, where the mechanism has to be walked. A process ask (missing verification evidence, "please add a test", a nit) is not that finding, and dressing it in the same scaffolding reads as ceremonious. Keep it to one or two casual lines: lead with the approval, phrase the ask as a favor, point at the obvious subject in a few words, and stop. Drop the mechanism recap, the pasted URL, and the paragraph split. An emoji is fine. The whole comment can be:

```
suggestion: changes look good. would you mind grabbing some verification evidence? running your new code against the QA claim from the ticket would be 👌
```

A non-blocking `thought` or `question` is the same weight. Claim with the mechanism folded into a parenthetical, then one ask, then stop. Two short paragraphs at most, quick natural sentences, contractions welcome. Don't give the mechanism its own paragraph and don't add an impact beat; the author isn't being asked to act, so they don't need the full walk:

```
thought (non-blocking): when the striker's ambiguous (candidates.length !== 1: >2 vehicles, or cargo off a trailer that isn't in collisionVehicleParties) this lands on the filer/IV, the party we're fixing away from.

no worse than before, it always fell back to the filer. but could an ambiguous fell-from fall to the generic 'vehicle' instead, so we don't actively name the IV? not blocking.
```

The over-built version of that same note ran four paragraphs: a claim, a separate mechanism walk, a "not a regression" impact paragraph, and the ask. Everything past the two paragraphs above was scaffolding for a note nobody has to act on.

### MR Review Summary Note

One line. Verdict plus a pointer that there are inline notes, and stop: `Looks solid to me, no blockers. Left a few inline notes.` / `Left a few comments!` These are social lines, so sentence case. The inline threads carry every finding; the summary exists to say "read them," not to preview or recap them.

Do not put findings in the summary. Not a recap of an inline finding (it already has its home), and not a "one ask." Every finding stands as its own comment and speaks for itself.

A finding with no inline anchor (an evidence gap, a cross-cutting note, a point about code the diff didn't touch) becomes its **own standalone top-level comment**, not a paragraph in the summary. Post it as a separate discussion so it reads as one finding, one comment, same as the inline ones. The summary stays one line regardless of how many homeless findings there are.

The only thing that ever joins the verdict line: a blocker. If something blocks, the one line can lead with that (`this one's blocking for me, see the inline note` or `left one blocker inline`), still a pointer, never the finding's detail.

Never: a strengths paragraph, a closing compliment, a recap or preview of any finding, a folded-in "single ask", what you ran or verified ("ran the tests, 56/56 green"), or a review announcement ("took a look").

### MR Comment Replies (your own MR)

Very short and conversational. No sign-offs, no thanks (unless the other person thanked first). You're offering a perspective, not issuing a ruling.

Soften assertions, including ones you're confident about. Reach for "probably", "i suppose", "i think", "seems ok to me", "i am not sure" over flat claims like "this doesn't work" or "this is the right approach".

Concede the limits of your own reasoning. "it's the pre-existing behavior but who knows if that's right" beats claiming the pre-existing behavior is correct; owning the uncertainty reads as trustworthy, not weak.

Cut your own justification. Once the point lands, delete the clause that explains or defends it (drop "every chip used it before this change" after "it's the pre-existing behavior"; drop "and we'd lose the good single-vehicle case" after the case is already clear).

Praise flows up, not down. `good call. changed to \`Record<EnumType, string>\`.` is right when conceding a reviewer's catch on your own MR; praise in reviewer mode gets cut (see the summary note section).

One thought per line for short replies: a stack of single sentences, not blank-line-separated paragraphs.

Examples of Matthew's style:
- `good call. changed to \`Record<EnumType, string>\`.`
- `Honestly, not sure. But good call out to keep an eye on.`
- `i am not sure discriminated unions would work here. the \`gqlModel\` pipeline doesn't support zod unions as graphql types, the extraction pipeline doesn't guarantee the invariant, and \`getStatusFact\` already handles it.`
- `👍`

### MR Descriptions

Follow the house style in the `mr-writing-style.mdc` rule:

- Title: lowercase after the ticket prefix (`ABC-1521: surface "archived at" timestamp ...`)
- Framing: 1-2 sentences explaining what this does and why
- Bullets: one clause each, action-first (`Adds`, `Threads`, `Maps`), files in backticks
- Verification: one sentence with a specific example id, not generic prose

### Commit Messages

- Prefix with the uppercase ticket key (`ABC-1521: ...`)
- Subject: lowercase, imperative, under 72 chars if possible
- Body (optional): one or two lines explaining the why, lowercase, wrapped at 72 chars
- Use `Co-Authored-By: Claude <noreply@anthropic.com>` when Claude authored the change
