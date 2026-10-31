# SPDX-License-Identifier: Apache-2.0 OR MIT
"""Remove the AI-writing tells that have one safe rewrite, by editing the parse tree.

Parse first, edit second: markdown-it gives the CommonMark blocks of each heredoc, spaCy gives a
dependency tree per block, and each edit replaces one token's character span. Edits apply from
the end of the file, then the result is re-parsed and refused unless the block structure held
and only the edited tells fell.

Always edited: a clause semicolon becomes a full stop; "serves as" becomes a form of "is".
With --claims, for text we own: a negated half answered by a reply is cut, and the cut is
printed for review. Everything else is reported with a line number.

    pixi run -e gate python scripts/detrope_fix.py [--write] [--claims] <file> ...
    pixi run -e gate python scripts/detrope_fix.py --self-test

Exit codes: 0 done or nothing to edit, 1 verification failed and nothing was written, 2 usage.
"""

import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import md_ast
import trope_nlp
from markdown_it import MarkdownIt

MARKER = re.compile(r"^\s*::")
QUOTED = re.compile(r'"[^"\n]*"')
EDITABLE = ("clause_semicolon", "pompous_verb")
CLAIM_EDITS = ("negative_parallelism",)
REPORT_ONLY = (
    "personified_abstraction",
    "emphasis_fragment",
    "adjective_triplet",
)


def bodies(path, text):
    """(offset in file, body) for each document in the file."""
    if path.endswith(".exs"):
        return [(m.start(1), m.group(1)) for m in md_ast.HEREDOC.finditer(text)]
    return [(0, text)]


def blocks(body):
    """Source line ranges of prose blocks, read from the CommonMark AST, plus the masks that
    hide inline code from the parser while keeping every character offset."""
    out, skip = [], 0
    for tok in MarkdownIt("commonmark").enable("table").parse(body):
        if tok.type in ("table_open", "heading_open"):
            skip += 1
        elif tok.type in ("table_close", "heading_close"):
            skip -= 1
        elif tok.type == "inline" and skip == 0 and tok.map:
            out.append((tok.map[0], tok.map[1], [c for c in tok.children or () if c.type == "code_inline"]))
    return out


def paragraph_slices(body):
    """(offset in body, raw text, masked text) for each prose paragraph, markers excluded."""
    lines = body.splitlines(keepends=True)
    starts, pos = [], 0
    for line in lines:
        starts.append(pos)
        pos += len(line)
    result = []
    for a, b, codes in blocks(body):
        group = []
        for i in range(a, b):
            if MARKER.match(lines[i]):
                if group:
                    result.append((group, codes))
                group = []
            else:
                group.append(i)
        if group:
            result.append((group, codes))
    for group, codes in result:
        raw = "".join(lines[i] for i in group)
        masked = raw
        cursor = 0
        for c in codes:
            needle = c.markup + c.content + c.markup
            at = masked.find(needle, cursor)
            if at >= 0:
                masked = masked[:at] + "x" * len(needle) + masked[at + len(needle):]
                cursor = at + len(needle)
        masked = QUOTED.sub(lambda m: "x" * len(m.group(0)), masked)
        yield starts[group[0]], raw, masked


def _plural(subject):
    if subject is None:
        return False
    if "Plur" in subject.morph.get("Number"):
        return True
    return any(c.dep_ == "cc" and c.lower_ == "and" for c in subject.children)


def _copula(verb, subject):
    tag, plural = verb.tag_, _plural(subject)
    if tag == "VBZ":
        return "is"
    if tag == "VBP":
        return "are"
    if tag == "VBD":
        return "were" if plural else "was"
    if tag == "VB":
        return "be"
    if tag == "NN" and plural:
        return "are"
    return None


def _depth(masked, upto):
    return masked.count("(", 0, upto) - masked.count(")", 0, upto)


def _span_of(tokens):
    return tokens[0].idx, tokens[-1].idx + len(tokens[-1].text)


MAX_CUT = 90


def negation_edit(masked, nh, kind, partner):
    cut = _negation_cut(masked, nh, kind, partner)
    if cut is None or cut[1] - cut[0] > MAX_CUT + (30 if kind == "next" else 0):
        return None
    return cut


def _negation_cut(masked, nh, kind, partner):
    """The span to cut when the owner lets a claim be rewritten, as (start, end, capital_at).

    Only the negated half goes; the half that says what the thing is stays. Returns None when
    the cut would take a lead-in or leave a fragment, and the caller reports it instead."""
    sent = nh.sent
    neg = next(c for c in nh.children if c.dep_ == "neg")
    sub = trope_nlp._subject(nh) or (trope_nlp._subject(nh.head) if nh.dep_ in ("ccomp", "conj", "xcomp") else None)
    if kind == "but":
        stop = partner.idx + len(partner.text)
        tail = masked[stop:]
        stop += len(tail) - len(tail.lstrip())
        also = masked[stop : stop + 4]
        if also.lower() == "also" and masked[stop + 4 : stop + 5].isspace():
            stop += 5
        return neg.idx, stop, None
    if kind == "same":
        reply_sub = trope_nlp._subject(partner)
        if sub is None or reply_sub is None or reply_sub.i <= sub.i:
            return None
        before = masked[: sub.idx].rstrip()
        cap = reply_sub.idx if (not before or before[-1] in ".!?:-*") and reply_sub.text[:1].islower() else None
        return sub.idx, reply_sub.idx, cap
    if kind == "next":
        nxt = partner.sent
        end = sent.end_char - 0
        lead = masked[sent[0].idx : sub.idx].strip() if sub is not None else "?"
        if sub is None or lead:
            return None
        stop = nxt[0].idx
        return sent[0].idx, stop, None
    return None


def edits_for(path, text, claims=False):
    """([(start, end, replacement, label)], [(line, tell, sentence)]) for the whole file."""
    nlp = trope_nlp.load()
    edits, findings = [], []
    for base, body in bodies(path, text):
        for off, raw, masked in paragraph_slices(body):
            doc = nlp(masked)
            at = base + off
            for tell, found in trope_nlp.sites(doc).items():
                for anchor, partner in found:
                    line = text.count("\n", 0, at + anchor.idx) + 1
                    if tell == "clause_semicolon":
                        semi, nxt = anchor, partner
                        gap = masked[semi.idx + 1 : nxt.idx] if nxt is not None else None
                        if nxt is None or gap.strip() or not gap or _depth(masked, semi.idx) > 0:
                            findings.append((line, tell + " (not edited: not a plain join)", anchor.sent.text.strip()))
                            continue
                        edits.append((at + semi.idx, at + semi.idx + 1, ".", tell))
                        if nxt.text.isalpha() and nxt.text[0].islower() and nxt.lower_ not in ("i",):
                            edits.append((at + nxt.idx, at + nxt.idx + 1, nxt.text[0].upper(), tell))
                    elif tell == "pompous_verb":
                        verb, as_tok = anchor, partner
                        subject = trope_nlp._subject(verb) or (verb.doc[verb.i - 1] if verb.i else None)
                        word = _copula(verb, subject)
                        if word is None or masked[verb.idx + len(verb.text) : as_tok.idx].strip():
                            findings.append((line, tell + " (not edited: tense not handled)", anchor.sent.text.strip()))
                            continue
                        if verb.text[0].isupper():
                            word = word.capitalize()
                        edits.append((at + verb.idx, at + as_tok.idx + len(as_tok.text), word, tell))
                    elif tell in CLAIM_EDITS and claims and partner is not None:
                        kind, other = partner
                        cut = negation_edit(masked, anchor, kind, other)
                        if cut is None:
                            findings.append((line, tell + " (not edited: would cut a lead-in or a long exclusion list)", anchor.sent.text.strip()))
                            continue
                        start, end, cap = cut
                        edits.append((at + start, at + end, "", tell))
                        if cap is not None:
                            edits.append((at + cap, at + cap + 1, masked[cap].upper(), tell))
                    else:
                        findings.append((line, tell, anchor.sent.text.strip()))
    return edits, findings


def apply(text, edits):
    """Apply from the end so every earlier offset is still true. An edit inside a larger cut is
    absorbed by it; a partial overlap is an error."""
    cuts = [e for e in edits if e[3] == "negative_parallelism" and e[2] == ""]
    absorbed = {
        c[1] for c in cuts if any(o[3] == "clause_semicolon" and o[2] == "." and c[0] <= o[0] < c[1] for o in edits)
    }
    edits = [
        e for e in edits
        if not (e[3] == "clause_semicolon" and len(e[2]) == 1 and e[2].isupper() and e[0] in absorbed)
    ]
    edits = list({(e[0], e[1], e[2]): e for e in edits}.values())
    edits = [
        e for e in edits
        if not any(o is not e and o[0] <= e[0] and e[1] <= o[1] and (o[1] - o[0]) > (e[1] - e[0]) for o in edits)
    ]
    ordered = sorted(edits, key=lambda e: e[0], reverse=True)
    for (s1, e1, _, _), (s2, e2, _, _) in zip(ordered, ordered[1:]):
        if s1 < e2:
            raise ValueError(f"edits overlap at {s2}-{e2} and {s1}-{e1}")
    for start, end, repl, _ in ordered:
        text = text[:start] + repl + text[end:]
    return text


def structure(path, text):
    """The block shape of every document: the AST with the prose words removed."""
    return [
        [(t.type, t.tag, t.level, bool(t.map)) for t in MarkdownIt("commonmark").enable("table").parse(b)]
        for _, b in bodies(path, text)
    ]


def verify(path, before, after, edits):
    """Re-parse the result. The structure is unchanged and exactly the edited tells fell."""
    problems = []
    if structure(path, before) != structure(path, after):
        problems.append("the markdown block structure changed")
    was, now = trope_nlp.count(_prose(path, before)), trope_nlp.count(_prose(path, after))
    fixed = {
        t: sum(1 for e in edits if e[3] == t and (t == "pompous_verb" or e[2] in (".", "") and e[1] > e[0]))
        for t in EDITABLE + CLAIM_EDITS
    }
    for tell in trope_nlp.TELLS:
        want = was[tell] - fixed.get(tell, 0)
        if now[tell] != want:
            problems.append(f"{tell}: expected {want} after the edit, found {now[tell]}")
    return problems


def _prose(path, text):
    return "\n\n".join(b for _, b in bodies(path, text))


def run(paths, write, claims=False):
    status = 0
    for path in paths:
        text = open(path, encoding="utf8", newline="").read()
        edits, findings = edits_for(path, text, claims)
        label = os.path.relpath(path)
        print(f"{label}: {len(edits)} edit(s), {len(findings)} left for a writer")
        for start, end, repl, tell in sorted(edits):
            line = text.count("\n", 0, start) + 1
            print(f"  edit  {line}: {tell}: {text[start:end]!r} -> {repl!r}")
            if tell in CLAIM_EDITS and not repl:
                print(f"        cut claim: {text[start:end].strip()!r}  (owner reviews; revert if it carried information)")
        for line, tell, sentence in findings:
            print(f"  read  {line}: {tell}: {sentence[:90]}")
        if not edits:
            continue
        after = apply(text, edits)
        problems = verify(path, text, after, edits)
        if problems:
            print("  VERIFY FAILED, nothing written:")
            for p in problems:
                print("   ", p)
            status = 1
        elif write:
            open(path, "w", encoding="utf8", newline="").write(after)
            print("  written and verified")
    return status


FIXTURE = """# SPDX
use RFD.DSL

rfd 1, "Fixture", :discussion do
  prose ~S\"\"\"
  :: decision
  - One beta holds the features the details list; every
    nongoal is abandoned (operator, 2026-10-30).
  :: related
  - RFD66606-2340, the campus; RFD66606-2358, the party; RFD66606-2359, the shop.
  :: problem
  The table serves as the index. The tables function as maps. The server serves assets.
  Run `a; b` to chain. The code fence below keeps its semicolon.

      x = 1; y = 2

  The gate said "a; b" once.
  \"\"\"
end
"""


def self_test():
    path = "fixture.exs"
    edits, findings = edits_for(path, FIXTURE)
    after = apply(FIXTURE, edits)
    checks = [
        ("a clause semicolon becomes a sentence, next word capitalised",
         "details list. Every\n    nongoal is abandoned" in after),
        ("a list semicolon is left alone", "the campus; RFD66606-2358, the party; RFD" in after),
        ("serves as becomes is", "The table is the index." in after),
        ("functions as becomes are for a plural subject", "The tables are maps." in after),
        ("a verb that serves something is left alone", "The server serves assets." in after),
        ("a semicolon in a code span is left alone", "`a; b`" in after),
        ("a semicolon in an indented code block is left alone", "x = 1; y = 2" in after),
        ("a quoted semicolon is left alone", '"a; b"' in after),
        ("the section markers survive", ":: decision" in after and ":: related" in after and ":: problem" in after),
        ("the heredoc indentation survives", "\n    nongoal is abandoned (operator" in after),
        ("the edits verify", verify(path, FIXTURE, after, edits) == []),
        ("a second pass finds nothing to edit", edits_for(path, after)[0] == []),
        ("two clause edits and two copulas", len(edits) == 4),
    ]
    broken = FIXTURE.replace("Every\n", "Every\n").replace("the details list; every", "the details list; every")
    bad = apply(FIXTURE, edits).replace("```", "")
    mutated = after.replace(":: related", "\n\n    :: related")
    checks.append(("a result that changes the block structure fails verification",
                   verify(path, FIXTURE, mutated, edits) != []))
    checks.append(("overlapping edits are refused", _overlap_refused()))
    checks += claim_checks()
    failed = 0
    for label, ok in checks:
        print(f"  {'ok  ' if ok else 'BAD '} {label}")
        failed += 0 if ok else 1
    if failed:
        print(f"{failed} of {len(checks)} controls failed")
        return 1
    print(f"ok   {len(checks)} of {len(checks)} controls behaved")
    return 0


def _claim_fixture(body):
    q = chr(34) * 3
    lines = ['rfd 1, "F", :discussion do', "  prose ~S" + q, "  :: problem", "  " + body, "  " + q, "end", ""]
    return chr(10).join(lines)


def claim_checks():
    cases = [
        ("a negated half answered after a semicolon is cut", "It is not a pipeline; it is a star.", "It is a star."),
        ("a negated sentence answered by the next is cut", "It is not a pipeline. It is a star.", "It is a star."),
        ("not just X but Y keeps Y", "The gate is not just a check but a ratchet.", "The gate is a ratchet."),
        ("a lead-in survives the cut", "In practice, it is not a pipeline; it is a star.", "In practice, it is a star."),
    ]
    out = []
    for label, before, want in cases:
        src = _claim_fixture(before)
        edits, _ = edits_for("f.exs", src, claims=True)
        after = apply(src, edits)
        out.append((label, want in after and "not" not in after.split(":: problem")[1]
                    and verify("f.exs", src, after, edits) == []))
    src = _claim_fixture("It is not a pipeline; it is a star.")
    edits, findings = edits_for("f.exs", src)
    out.append(("without --claims the claim is reported, not edited",
                not any(e[3] == "negative_parallelism" for e in edits)
                and any("negative_parallelism" in f[1] for f in findings)))
    return out


def _overlap_refused():
    try:
        apply("abcdef", [(0, 3, "x", "t"), (2, 4, "y", "t")])
    except ValueError:
        return True
    return False


if __name__ == "__main__":
    args = sys.argv[1:]
    if args == ["--self-test"]:
        sys.exit(self_test())
    write = "--write" in args
    claims = "--claims" in args
    files = [a for a in args if not a.startswith("--")]
    if not files:
        print(__doc__)
        sys.exit(2)
    sys.exit(run(files, write, claims))
