#!/usr/bin/env python3
"""Fail any confidence tag whose word is off RFD 2295's scale or whose p falls outside the word's band.

The bands are read from RFD 2295's source, so the scale and this gate cannot disagree.
    python scripts/check_confidence_tags.py [paths...]
    python scripts/check_confidence_tags.py --self-test
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
SOURCE = ROOT / "rfd" / "2295-agent-replies-state-calibrated-confidence.exs"
TAG = re.compile(r"\(([a-z][a-z ]*?), p=(\d\.\d\d)\)")
ROW = re.compile(r"^\| ([a-z ]+?) \| (\d\.\d\d) \| (\d\.\d\d) \|$")


def read_bands(text: str) -> dict:
    bands = {m.group(1): (float(m.group(2)), float(m.group(3)))
             for m in (ROW.match(line.strip()) for line in text.splitlines()) if m}
    if not bands:
        raise SystemExit(f"FAIL no scale table in {SOURCE}")
    return bands


def problems(text: str, bands: dict, where: str) -> list:
    out = []
    top = max(hi for _, hi in bands.values())
    for m in TAG.finditer(text):
        word, p = m.group(1), float(m.group(2))
        if word not in bands:
            out.append(f"{where}: unknown word {word!r} in {m.group(0)}")
            continue
        lo, hi = bands[word]
        if not (lo <= p < hi or (hi == top and p == top)):
            out.append(f"{where}: p={p:.2f} is outside {word!r} [{lo:.2f}, {hi:.2f}) in {m.group(0)}")
    return out


def default_paths() -> list:
    return sorted(ROOT.glob("logbook/*.md")) + sorted(ROOT.glob("rfd/[0-9][0-9][0-9][0-9]-*.exs"))


def self_test(bands: dict) -> int:
    cases = [
        ("a correct tag passes", "It lands (likely, p=0.80).", 0),
        ("an unknown word fails", "It lands (probable, p=0.80).", 1),
        ("a number outside its band fails", "It lands (likely, p=0.95).", 1),
        ("1.00 is inside almost certain", "It lands (almost certain, p=1.00).", 0),
    ]
    failed = 0
    for name, text, want in cases:
        got = len(problems(text, bands, "planted"))
        ok = got == want
        failed += 0 if ok else 1
        print(f"{'PASS' if ok else 'FAIL'} {name}: {got} problem(s), wanted {want}")
    return 1 if failed else 0


def main(argv: list) -> int:
    bands = read_bands(SOURCE.read_text())
    if "--self-test" in argv:
        return self_test(bands)
    paths = [pathlib.Path(a) for a in argv] or default_paths()
    found = []
    tags = 0
    for path in paths:
        text = path.read_text()
        tags += len(TAG.findall(text))
        found += problems(text, bands, str(path.relative_to(ROOT) if path.is_absolute() else path))
    for line in found:
        print(f"FAIL {line}")
    print(f"{len(paths)} file(s), {tags} tag(s), {len(found)} problem(s)")
    return 1 if found else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
