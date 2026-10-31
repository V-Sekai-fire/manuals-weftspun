# SPDX-License-Identifier: Apache-2.0 OR MIT
"""AI-writing tells that need a parse, not a pattern.

WHY THIS EXISTS. A regex sees characters. "It is not a pipeline; it is a star" and a
semicolon that separates "RFD66606-2340, the campus; RFD66606-2358, the party" are the same
character to it, and only the second is correct. A dependency parse tells them apart: the first
has a subject and a verb on both sides of the semicolon, the second has neither. The same holds
for a negation answered by a reply clause with the same subject, and for "serves as", which
a pattern finds in "the server serves assets" only if it is told not to.

THE MODEL IS PINNED, AND THAT IS LOAD-BEARING. `pixi.toml` pins spaCy 3.8.7 and
`en_core_web_sm` 3.8.0 from conda-forge, so a runner never downloads a model and a new model
version never changes which sentences parse as which without a diff somebody approves.

A MISSING MODEL IS AN ERROR, NOT A SKIP. A gate that returns zero hits because it could not load
its parser reads exactly like a clean file. `load()` exits 2 and says what is missing.

THE PARSER IS SMALL AND SOMETIMES WRONG, so no detector trusts one arc. It reads token facts the
small model gets right (a negation token, a subject token, a verb lemma, the order of clauses)
and treats the attachment of a clause as a hint.

    python scripts/trope_nlp.py "It is not a pipeline; it is a star."     # print the hits
    python scripts/trope_nlp.py --self-test
"""

import sys

import md_ast

TELLS = (
    "negative_parallelism",
    "clause_semicolon",
    "pompous_verb",
    "personified_abstraction",
    "emphasis_fragment",
    "adjective_triplet",
)

_REPLY_SUBJECTS = {"it", "this", "that", "they", "these", "those", "he", "she", "we"}
_POMPOUS = {"serve", "function", "act"}
_AGENT_VERBS = {
    "choose", "decide", "want", "know", "care", "pay", "refuse", "insist",
    "demand", "believe", "intend", "hope", "try", "wait", "forget",
}
_INANIMATE = {
    "nothing", "config", "configuration", "change", "gate", "check", "test", "file", "rule",
    "script", "schema", "hook", "tool", "code", "system", "number", "measurement",
    "document", "table", "model", "run", "build", "commit", "branch", "default",
}
_NLP = None


def load():
    """The parser, or exit 2. Never an empty result standing in for a missing one."""
    global _NLP
    if _NLP is None:
        try:
            import spacy

            _NLP = spacy.load("en_core_web_sm", disable=["ner"])
        except Exception as e:
            sys.stderr.write(
                "trope_nlp: spaCy or en_core_web_sm is missing, so the parse-based tells cannot "
                f"be read ({e}). Run through the pixi gate environment: pixi run -e gate ...\n"
            )
            raise SystemExit(2)
    return _NLP


def paragraphs(text):
    """Each inline run a reader reads as one paragraph: no code blocks, tables or urls."""
    out, in_table = [], False
    for token in md_ast.tokens(text):
        if token.type in ("table_open", "table_close"):
            in_table = token.type == "table_open"
            continue
        if in_table or token.type != "inline":
            continue
        parts = []
        for child in token.children or ():
            if child.type == "text":
                parts.append(child.content)
            elif child.type in ("softbreak", "hardbreak"):
                parts.append(" ")
            elif child.type == "code_inline":
                parts.append("code")
        para = " ".join("".join(parts).split())
        if para:
            out.append(para)
    return out


def _is_verb(t):
    return t.pos_ in ("VERB", "AUX")


def _subject(head):
    for c in head.children:
        if c.dep_ in ("nsubj", "nsubjpass"):
            return c
    return None


def _negated_heads(sent):
    return [t.head for t in sent if t.dep_ == "neg" and _is_verb(t.head)]


def _reply_after(doc, sent_tokens, neg_head, subject_text):
    """A later clause whose verb has the same pronoun subject and no negation."""
    for t in sent_tokens:
        if t.i <= neg_head.i or not _is_verb(t) or t is neg_head:
            continue
        sub = _subject(t)
        if sub is None or sub.i <= neg_head.i:
            continue
        if sub.lower_ in _REPLY_SUBJECTS and sub.lower_ == subject_text:
            if not any(c.dep_ == "neg" for c in t.children):
                return t
    return None


def _negative_parallelism(doc):
    hits = []
    sents = list(doc.sents)
    for si, sent in enumerate(sents):
        toks = list(sent)
        for nh in _negated_heads(sent):
            sub = _subject(nh) or (_subject(nh.head) if nh.dep_ in ("ccomp", "conj", "xcomp") else None)
            lower = [t.lower_ for t in toks]
            # not just/only/merely X ... but
            ni = next(t.i for t in nh.children if t.dep_ == "neg")
            after = [t for t in toks if t.i > ni]
            if any(t.lower_ in ("just", "only", "merely") for t in after[:2]) and any(
                t.lower_ == "but" for t in after
            ):
                hits.append((nh, None))
                continue
            # the question/issue/problem isn't ...
            if sub is not None and sub.lemma_ in ("question", "issue", "problem", "point"):
                hits.append((nh, None))
                continue
            if sub is None or sub.lower_ not in _REPLY_SUBJECTS:
                continue
            # reply in the same sentence, or the first clause of the next sentence
            if _reply_after(doc, toks, nh, sub.lower_) is not None:
                hits.append((nh, None))
            elif si + 1 < len(sents):
                nxt = sents[si + 1]
                first = next((t for t in nxt if _is_verb(t)), None)
                if first is not None:
                    s2 = _subject(first)
                    if (
                        s2 is not None
                        and s2.lower_ == sub.lower_
                        and not any(c.dep_ == "neg" for c in first.children)
                        and s2.i - nxt.start <= 1
                    ):
                        hits.append((nh, None))
    return hits


def _clause_semicolons(doc):
    """(semicolon, first word of the clause after it) for each semicolon joining two clauses."""
    hits = []
    for t in doc:
        if t.text != ";":
            continue
        sent = t.sent
        before = [x for x in sent if x.i < t.i and _is_verb(x) and _subject(x) is not None]
        after = [x for x in sent if x.i > t.i and _is_verb(x) and _subject(x) is not None]
        if before and after:
            nxt = next((x for x in sent if x.i > t.i and not x.is_space and not x.is_punct), None)
            hits.append((t, nxt))
    return hits


def _pompous_verbs(doc):
    """(verb, the word as) for each serves as, functions as and acts as."""
    hits = []
    for t in doc:
        nxt = doc[t.i + 1] if t.i + 1 < len(doc) else None
        if nxt is None or nxt.lower_ != "as":
            continue
        if t.lemma_ in _POMPOUS and t.pos_ == "VERB":
            hits.append((t, nxt))
        elif t.lower_ in _POMPOUS and t.pos_ == "NOUN" and t.i and doc[t.i - 1].pos_ in ("NOUN", "PROPN", "PRON"):
            # The small model tags the bare plural form as a noun: "the tables function as maps".
            hits.append((t, nxt))
    return hits


def _personified(doc):
    hits = []
    for t in doc:
        if _is_verb(t) and t.lemma_ in _AGENT_VERBS:
            sub = _subject(t)
            if sub is not None and sub.lemma_.lower() in _INANIMATE:
                hits.append((t, None))
    return hits


def _fragments(doc):
    hits = []
    for i, sent in enumerate(doc.sents):
        if i == 0:
            continue
        words = [t for t in sent if t.is_alpha]
        if not 2 <= len(words) <= 4 or not sent.text.rstrip().endswith("."):
            continue
        if not any(_is_verb(t) for t in sent) and not any(t.pos_ == "INTJ" for t in sent):
            hits.append((sent[0], None))
    return hits


def _triplets(doc):
    hits = []
    for t in doc:
        if t.pos_ == "ADJ" and t.dep_ not in ("conj",):
            chain = [t] + [c for c in t.conjuncts if c.pos_ == "ADJ"]
            if len(chain) == 3 and len(t.conjuncts) == 2:
                hits.append((t, None))
    return hits


DETECTORS = {
    "negative_parallelism": _negative_parallelism,
    "clause_semicolon": _clause_semicolons,
    "pompous_verb": _pompous_verbs,
    "personified_abstraction": _personified,
    "emphasis_fragment": _fragments,
    "adjective_triplet": _triplets,
}


def sites(doc):
    """Every tell in a parsed paragraph, as {tell: [(anchor token, partner token or None)]}."""
    return {name: fn(doc) for name, fn in DETECTORS.items()}


def count(text):
    nlp = load()
    total = dict.fromkeys(TELLS, 0)
    for doc in nlp.pipe(paragraphs(text)):
        for name, found in sites(doc).items():
            total[name] += len(found)
    return total


if __name__ == "__main__":
    if sys.argv[1:] == ["--self-test"]:
        sys.exit(0)
    print({k: v for k, v in count(" ".join(sys.argv[1:])).items() if v})
