# SPDX-License-Identifier: Apache-2.0 OR MIT
"""Every GitHub Actions workflow carries a top-level concurrency group that
cancels superseded pull request runs and never cancels anything else.

    python scripts/check_workflow_concurrency.py                 # placed V-Sekai-fire checkouts
    python scripts/check_workflow_concurrency.py --root <workspace>
    python scripts/check_workflow_concurrency.py <files or dirs>
    python scripts/check_workflow_concurrency.py --self-test
"""
import argparse
import re
import sys
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path

import yaml

HERE = Path(__file__).resolve().parent
ROOT = next((c for c in [HERE.parent, *HERE.parent.parents] if (c / ".repo").is_dir()), None)
ORG = "github.com/v-sekai-fire"
PR_EVENTS = {"pull_request", "pull_request_target"}
PR_ONLY = re.compile(r"^\$\{\{\s*github\.event_name\s*==\s*'pull_request'\s*\}\}$")
PR_KEYS = ("github.event.pull_request.number", "github.head_ref", "github.ref")


def events(on) -> set:
    if isinstance(on, str):
        return {on}
    if isinstance(on, list):
        return set(on)
    if isinstance(on, dict):
        return set(on)
    return set()


def problems(text: str) -> list:
    try:
        doc = yaml.safe_load(text)
    except yaml.YAMLError as e:
        return [f"unparseable YAML: {str(e).splitlines()[0]}"]
    if not isinstance(doc, dict):
        return ["not a mapping"]
    on = doc.get("on", doc.get(True))
    evs = events(on)
    if not evs:
        return ["no `on:` triggers"]
    conc = doc.get("concurrency")
    if "workflow_call" in evs:
        if conc is not None and "github.workflow" in str(conc):
            return ["a called workflow's `github.workflow` is its caller's, so this group deadlocks with the caller"]
        return []
    if conc is None:
        return ["no top-level concurrency"]
    if isinstance(conc, str):
        return []
    if not isinstance(conc, dict) or "group" not in conc:
        return ["concurrency has no group"]
    cancel = conc.get("cancel-in-progress", False)
    group = str(conc["group"])
    out = []
    if cancel is True:
        if evs - PR_EVENTS:
            out.append(f"cancel-in-progress: true also cancels {', '.join(sorted(evs - PR_EVENTS))}")
    elif cancel is not False:
        if not PR_ONLY.match(str(cancel).strip()):
            out.append(f"cancel-in-progress is not `${{{{ github.event_name == 'pull_request' }}}}`: {cancel}")
    if cancel is not False and not any(k in group for k in PR_KEYS):
        out.append(f"group `{group}` is not keyed per pull request or ref, so one run cancels another's")
    return out


def placed(root: Path) -> tuple:
    xml = ET.parse(root / ".repo/manifests/default.xml").getroot()
    remotes = {r.get("name"): r.get("fetch", "").lower() for r in xml.findall("remote")}
    default = (xml.find("default").attrib if xml.find("default") is not None else {}).get("remote")
    dirs, pinned, absent = [], [], []
    for p in xml.findall("project"):
        if ORG not in remotes.get(p.get("remote", default), ""):
            continue
        path = root / p.get("path")
        rev = p.get("revision", "")
        if re.fullmatch(r"[0-9a-f]{40}", rev) or rev.startswith("refs/tags/"):
            pinned.append(p.get("path"))
        elif not path.is_dir():
            absent.append(p.get("path"))
        else:
            dirs.append(path / ".github/workflows")
    return dirs, pinned, absent


def files_under(paths) -> list:
    out = []
    for p in paths:
        p = Path(p)
        if p.is_dir():
            out += sorted(f for f in p.iterdir() if f.suffix in (".yml", ".yaml"))
        else:
            out.append(p)
    return out


def workspace(root: Path) -> int:
    dirs, pinned, absent = placed(root)
    files = files_under(d for d in dirs if d.is_dir())
    print(f"  {len(dirs)} placed V-Sekai-fire checkouts read, {len(pinned)} pinned to a tag or SHA not read: "
          f"{', '.join(pinned) or '-'}")
    for p in absent:
        print(f"  FAIL {p}: placed but not checked out")
    return gate(files) or (1 if absent else 0)


def gate(files) -> int:
    bad = 0
    for f in files:
        try:
            found = problems(f.read_text(encoding="utf-8"))
        except OSError as e:
            found = [f"unreadable: {e.strerror}"]
        for msg in found:
            print(f"  FAIL {f}: {msg}")
        bad += bool(found)
    print(f"{bad} of {len(files)} workflows fail the concurrency rule")
    return 1 if bad else 0


GOOD = """on: [pull_request, push, merge_group]
concurrency:
  group: ${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}
jobs: {}
"""
CONTROLS = [
    ("canonical rule passes", GOOD, True),
    ("publish workflow that never cancels passes",
     "on: {push: {tags: ['v*']}}\nconcurrency: {group: 'rel-${{ github.ref }}', cancel-in-progress: false}\njobs: {}\n", True),
    ("pull_request-only workflow may cancel unconditionally",
     "on: pull_request\nconcurrency: {group: '${{ github.head_ref }}', cancel-in-progress: true}\njobs: {}\n", True),
    ("a called workflow inherits its caller's group", "on: [workflow_call, workflow_dispatch]\njobs: {}\n", True),
    ("no concurrency is rejected", "on: [pull_request]\njobs: {}\n", False),
    ("cancelling pushes to the default branch is rejected",
     "on: [pull_request, push]\nconcurrency: {group: '${{ github.ref }}', cancel-in-progress: true}\njobs: {}\n", False),
    ("a group shared by every pull request is rejected",
     "on: [pull_request]\nconcurrency: {group: '${{ github.workflow }}', "
     "cancel-in-progress: \"${{ github.event_name == 'pull_request' }}\"}\njobs: {}\n", False),
    ("an unrecognised cancel expression is rejected",
     "on: [pull_request, push]\nconcurrency: {group: '${{ github.ref }}', cancel-in-progress: '${{ true }}'}\njobs: {}\n",
     False),
    ("a called workflow sharing its caller's group is rejected",
     "on: [workflow_call, workflow_dispatch]\nconcurrency: '${{ github.workflow }}-${{ github.ref }}'\njobs: {}\n", False),
    ("unparseable YAML is rejected", "on: [pull_request\n", False),
]


def self_test() -> int:
    fails = 0
    for label, text, want in CONTROLS:
        if (not problems(text)) != want:
            fails += 1
            print(f"  FAIL {label}: expected {'pass' if want else 'fail'}")
    with tempfile.TemporaryDirectory() as d:
        d = Path(d)
        if gate([d / "missing.yml"]) == 0:
            fails += 1
            print("  FAIL an unreadable file passed")
        (d / ".repo/manifests").mkdir(parents=True)
        (d / ".repo/manifests/default.xml").write_text(
            '<manifest><remote name="o" fetch="https://github.com/V-Sekai-fire" /><default remote="o" />'
            '<project name="a" path="a" revision="main" /><project name="p" path="p" revision="'
            + "0" * 40 + '" /></manifest>')
        (d / "a/.github/workflows").mkdir(parents=True)
        (d / "a/.github/workflows/ci.yml").write_text(GOOD)
        (d / "p").mkdir()
        if workspace(d) != 0:
            fails += 1
            print("  FAIL a workspace of one good workflow and one pinned project failed")
        (d / "a/.github/workflows/ci.yml").unlink()
        (d / "a").rename(d / "gone")
        if workspace(d) == 0:
            fails += 1
            print("  FAIL a placed project missing from disk passed")
    n = len(CONTROLS) + 3
    if fails:
        print(f"{fails} of {n} controls failed")
        return 1
    print(f"ok   {n} of {n} controls fired in both directions")
    return 0


def main(argv) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("paths", nargs="*")
    ap.add_argument("--self-test", action="store_true")
    ap.add_argument("--root", type=Path, default=ROOT)
    a = ap.parse_args(argv)
    if a.self_test:
        return self_test()
    if a.paths:
        return gate(files_under(a.paths))
    if a.root is None:
        print("FAIL no .repo above this checkout and no paths given, so nothing was checked")
        return 1
    return workspace(a.root)


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
