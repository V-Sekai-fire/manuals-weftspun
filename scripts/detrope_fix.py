# SPDX-License-Identifier: Apache-2.0 OR MIT
"""Remove the AI-writing tells that have one safe rewrite, by editing the parse tree.

ORDER OF WORK, AND IT IS THE POINT. The text is parsed first and edited second.

    1. Parse the document structure. markdown-it-py gives the blocks of the CommonMark AST, each
       with its source line range. An RFD source is Elixir, so the heredoc bodies are the
       documents. Code, tables and headings are not prose and are never offered to the editor.
    2. Parse each prose block into a dependency tree with spaCy. Every token carries its
       character offset in the source, its part of speech, its morphology and its head.
    3. Find the tells as nodes of that tree. A semicolon is a clause join only when a verb with
       a subject sits on each side of it. "serves as" is a copula only when the verb's
       lemma is serve, function or act and the next word is "as".
    4. Compute each edit as a replacement of one token's character span, never a text search.
       The verb's tense and the subject's number come from the token's morphology, and the first
       word of the new sentence is capitalised only when the parse says it is a lowercase word.
    5. Apply the edits from the end of the file backwards, so each offset is still true.
    6. Parse the result again and check it: the block structure is unchanged, the fixed tells are
       gone and no other tell appeared.

WHAT IS NOT EDITED. Negative parallelism, preambles, personified abstractions, emphasis
fragments and adjective triplets change what a sentence says or need a writer's choice, and
`prose-detrope` forbids rewriting a claim. They are reported with a line number.

    pixi run -e gate python scripts/detrope_fix.py <file> ...             # dry run, prints the edits
    pixi run -e gate python scripts/detrope_fix.py --write <file> ...     # applies them
    pixi run -e gate python scripts/detrope_fix.py --self-test

Exit codes: 0 nothing to edit, or edits applied and verified, 1 an edit failed verification
and nothing was written, 2 bad usage or no parser.
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
REPORT_ONLY = (
    "negative_parallelism",
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


def edits_for(path, text):
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
                    else:
                        findings.append((line, tell, anchor.sent.text.strip()))
    return edits, findings


def apply(text, edits):
    """Apply from the end so every earlier offset is still true. Overlap is an error."""
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
    fixed = {t: sum(1 for e in edits if e[3] == t and (t != "clause_semicolon" or e[2] == ".")) for t in EDITABLE}
    for tell in trope_nlp.TELLS:
        want = was[tell] - fixed.get(tell, 0)
        if now[tell] != want:
            problems.append(f"{tell}: expected {want} after the edit, found {now[tell]}")
    return problems


def _prose(path, text):
    return "\n\n".join(b for _, b in bodies(path, text))


def run(paths, write):
    status = 0
    for path in paths:
        text = open(path, encoding="utf8", newline="").read()
        edits, findings = edits_for(path, text)
        label = os.path.relpath(path)
        print(f"{label}: {len(edits)} edit(s), {len(findings)} left for a writer")
        for start, end, repl, tell in sorted(edits):
            line = text.count("\n", 0, start) + 1
            print(f"  edit  {line}: {tell}: {text[start:end]!r} -> {repl!r}")
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
    failed = 0
    for label, ok in checks:
        print(f"  {'ok  ' if ok else 'BAD '} {label}")
        failed += 0 if ok else 1
    if failed:
        print(f"{failed} of {len(checks)} controls failed")
        return 1
    print(f"ok   {len(checks)} of {len(checks)} controls behaved")
    return 0


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
    files = [a for a in args if not a.startswith("--")]
    if not files:
        print(__doc__)
        sys.exit(2)
    sys.exit(run(files, write))
