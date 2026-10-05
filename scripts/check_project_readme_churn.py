# SPDX-License-Identifier: Apache-2.0 OR MIT
"""Project READMEs carry nothing that goes stale when the code moves.

    python scripts/check_project_readme_churn.py [--workspace DIR]
    python scripts/check_project_readme_churn.py --self-test
"""
import argparse
import os
import re
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import md_ast
from check_project_readme_length import ROOT, is_fork

FLAG = re.compile(r"^--?[a-z][\w-]*(?:[ =].*)?$")
KINDS = {
    "port": re.compile(r"(?:\blocalhost|\b\d{1,3}(?:\.\d{1,3}){3}|\bport)\s*:?\s*\d{2,5}\b", re.I),
    "version": re.compile(r"(?<![\w.])v?\d+\.\d+\.\d+(?:[-+][\w.]+)?\b(?![.:]\d)"),
    "date": re.compile(r"\b20\d\d-[01]\d-[0-3]\d\b"),
    "branch": re.compile(r"\b(?:feat|fix|archived|release|hotfix)/[\w.-]+"),
}
STATUS = re.compile(r"^(status|state|progress|done|todo|wip|phase)$", re.I)
MARKS = re.compile("[✅❌✔✖⏳\U0001f6a7]|\\b(?:TODO|WIP)\\b")
PINNED = re.compile(r"\b(dependenc|requirement|pins?\b|pinned\b)", re.I)
FLAG_LIST = 3

# The READMEs that carried churny detail when this gate landed, each held at its finding count.
GRANDFATHERED = {
    "1-transport/cineform-tui": 3,
    "2-contract/anny-keypoint-anchors": 1,
    "2-contract/bootstrap": 1,
    "2-contract/lean-deform-exact": 1,
    "2-contract/lean-slang": 1,
    "2-contract/trust-lean": 5,
    "2-contract/truth-research-zk": 16,
    "2-contract/weftspun-agreements": 1,
    "2-contract/zone-backend": 1,
    "3-interactor/anny": 6,
    "3-interactor/av1mkv": 2,
    "3-interactor/cineform": 6,
    "3-interactor/cloth-fit": 5,
    "3-interactor/editscore": 11,
    "3-interactor/editscore-lora-qwen3vl-4b": 2,
    "3-interactor/fabric-zone": 1,
    "3-interactor/frame-controller-sim": 1,
    "3-interactor/frame-eye-osc": 2,
    "3-interactor/kimodo-ggml": 1,
    "3-interactor/lingbot-map-upstream": 26,
    "3-interactor/moge-upstream": 1,
    "3-interactor/mujoco-sandbox-demo": 2,
    "3-interactor/omnigen2": 12,
    "3-interactor/panelspun": 2,
    "3-interactor/physics": 2,
    "3-interactor/pixal3d-image-mesh-painting": 2,
    "3-interactor/pixal3d-image-to-textured-mesh": 2,
    "3-interactor/pixal3d-upstream": 1,
    "3-interactor/rf-detr-ggml": 1,
    "3-interactor/sakuragaoka-station-upstream": 1,
    "3-interactor/slughorn": 1,
    "3-interactor/soma-x": 1,
    "3-interactor/trellis2-image-to-textured-mesh": 1,
    "3-interactor/trellis2-upstream": 4,
    "3-interactor/udon2godot": 2,
    "3-interactor/ufbx-to-openusd": 1,
    "3-interactor/voice": 1,
    "3-interactor/voxhammer-upstream": 2,
    "3-interactor/xr-pilot": 1,
    "4-entities/character-marocchino": 1,
    "4-entities/egit": 1,
    "4-entities/godot-sandbox-gdscript-compiler": 1,
    "4-entities/godot-vrm": 15,
    "4-entities/opentelemetry-godot-project": 1,
    "6-datasource/anny-render-corpus": 3,
    "6-datasource/desync": 3,
    "6-datasource/foundationdb": 1,
    "7-service/burrito": 16,
    "7-service/cineform": 4,
    "7-service/cineform/thirdparty/cineform-sdk": 1,
    "7-service/cineform/thirdparty/iceoryx2": 5,
    "7-service/godot-build": 1,
}


def findings(text: str) -> list[str]:
    """Each churny kind found outside fenced blocks, once per occurrence."""
    out, section, flags = [], "", 0
    in_head, cells, item, cell = False, [], 0, False
    for tok in md_ast.tokens(text):
        if tok.type == "heading_open":
            section = None
        elif tok.type == "thead_open":
            in_head, cells = True, []
        elif tok.type == "thead_close":
            in_head = False
            if any(STATUS.match(c) for c in cells):
                out.append(f"status table: {' | '.join(cells)}")
        elif tok.type in ("td_open", "th_open"):
            cell = True
        elif tok.type in ("td_close", "th_close"):
            cell = False
        elif tok.type == "list_item_open":
            item += 1
        elif tok.type == "list_item_close":
            item -= 1
        elif tok.type == "html_block":
            out += scan(tok.content, bool(PINNED.search(section or "")))
        if tok.type != "inline":
            continue
        if section is None:
            section = tok.content
            continue
        if in_head:
            cells.append(tok.content.strip())
        pinned = bool(PINNED.search(section))
        if item and FLAG.match(tok.content.strip().strip("`")):
            flags += 1
        for child in tok.children or ():
            if child.type not in ("text", "code_inline", "html_inline"):
                continue
            s = child.content
            if child.type == "code_inline" and FLAG.match(s) and not item:
                flags += 1
            if (cell or item) and MARKS.search(s):
                out.append(f"status mark: {s.strip()}")
            out += scan(s, pinned)
    if flags >= FLAG_LIST:
        out.append(f"flag list: {flags} flags; --help carries them")
    return out


def scan(s: str, pinned: bool) -> list[str]:
    return [f"{kind}: {m.group(0)}" for kind, rx in KINDS.items()
            if not (kind == "version" and pinned) for m in rx.finditer(s)]


def gate(root: Path, held: dict | None = None) -> int:
    held = GRANDFATHERED if held is None else held
    man = ET.parse(root / ".repo/manifests/default.xml").getroot()
    checked, missing, forks, bad, kept = 0, [], [], [], []
    for p in man.iter("project"):
        path = p.get("path") or p.get("name")
        if not (root / path).is_dir():
            missing.append(path)
            continue
        if is_fork(root / path):
            forks.append(path)
            continue
        rd = root / path / "README.md"
        if not rd.is_file():
            missing.append(path)
            continue
        checked += 1
        found = findings(rd.read_text(encoding="utf-8", errors="replace"))
        if path in held:
            kept.append(path)
            if not found:
                print(f"  FAIL {path}: clean now; drop it from GRANDFATHERED")
                bad.append(path)
            elif len(found) > held[path]:
                print(f"  FAIL {path}: {len(found)} findings, held at {held[path]}: "
                      + "; ".join(found[:6]))
                bad.append(path)
            elif len(found) < held[path]:
                print(f"  note {path}: {len(found)} findings; lower GRANDFATHERED to {len(found)}")
            continue
        if found:
            bad.append(path)
            print(f"  FAIL {path}/README.md: " + "; ".join(found[:6])
                  + (f"; +{len(found) - 6} more" if len(found) > 6 else ""))
    print(f"  {checked} READMEs read, {len(missing)} projects without one or not on disk, "
          f"{len(forks)} forks exempt, {len(kept)} grandfathered at their held count.")
    print(f"{len(bad)} of {checked} READMEs fail.")
    return 1 if bad else 0


def workspace(d: Path, projects: dict) -> None:
    """A fixture workspace: path -> (remote url, README text)."""
    (d / ".repo/manifests").mkdir(parents=True)
    rows = "".join(f'<project name="{p}" path="{p}" />' for p in projects)
    (d / ".repo/manifests/default.xml").write_text(f"<manifest>{rows}</manifest>")
    for p, (url, text) in projects.items():
        subprocess.run(["git", "init", "-q", str(d / p)], check=True)
        subprocess.run(["git", "-C", str(d / p), "remote", "add", "origin", url], check=True)
        (d / p / "README.md").write_text(text)


def self_test() -> int:
    clean = "# p\n\nA tagline about the project.\n\n## Build\n\n```\nmake --jobs 8 v1.2.3\n```\n"
    controls = [
        ("a clean README", clean, True),
        ("flags in a fence are a build command", clean, True),
        ("a flag list", clean + "\n- `--port`\n- `--host`\n- `--verbose`\n", False),
        ("two flags are not a list", clean + "\nRun with `--help` or `-v`.\n", True),
        ("a port", clean + "\nIt listens on localhost:8080.\n", False),
        ("a port in words", clean + "\nIt listens on port 4000.\n", False),
        ("a version in prose", clean + "\nBuilt against Godot 4.5.1.\n", False),
        ("a version in a dependencies section",
         clean + "\n## Dependencies\n\n- libfoo 1.2.3\n", True),
        ("a date", clean + "\nMeasured on 2026-10-04.\n", False),
        ("a branch", clean + "\nWork happens on `feat/x`.\n", False),
        ("a status table", clean + "\n| Item | Status |\n|---|---|\n| a | done |\n", False),
        ("a plain table", clean + "\n| Name | Role |\n|---|---|\n| a | b |\n", True),
        ("a status mark", clean + "\n| Item | Note |\n|---|---|\n| a | ✅ |\n", False),
        ("an SPDX-like licence is not a version", clean + "\nApache-2.0 OR MIT.\n", True),
        ("a status mark in a list", clean + "\n- ✅ phase 1\n- WIP phase 2\n", False),
        ("TODO in prose after a table",
         clean + "\n| Name | Role |\n|---|---|\n| a | b |\n\nA TODO list app.\n", True),
        ("a heading that says pinning is not a pin section",
         clean + "\n## Pinning notes\n\nBuilt against 4.5.1.\n", False),
        ("flags as plain list text", clean + "\n- --port N\n- --host H\n- --verbose\n", False),
        ("a port in an HTML block", clean + "\n<div>localhost:8080</div>\n", False),
    ]
    fails = 0
    for label, text, want_pass in controls:
        got = not findings(text)
        if got != want_pass:
            print(f"  FAIL {label}: got {'pass' if got else 'fail'}: {findings(text)}")
            fails += 1
    for var in [v for v in os.environ if v.startswith("GIT_")]:
        del os.environ[var]
    with tempfile.TemporaryDirectory() as d:
        for url, want in (("https://github.com/V-Sekai-fire/x", False),
                          ("https://github.com/upstream/x", True)):
            subprocess.run(["git", "init", "-q", d], check=True)
            subprocess.run(["git", "-C", d, "remote", "remove", "origin"], capture_output=True)
            subprocess.run(["git", "-C", d, "remote", "add", "origin", url], check=True)
            if is_fork(Path(d)) != want:
                print(f"  FAIL fork classification of {url}")
                fails += 1
    if len(findings(clean + "\nOn 127.0.0.1:8080.\n")) != 1:
        print(f"  FAIL an IP and port is one finding: {findings(clean + 'On 127.0.0.1:8080.')}")
        fails += 1
    own, up = "https://github.com/V-Sekai-fire/x", "https://github.com/upstream/x"
    churny = clean + "\nOn localhost:8080 and port 4000.\n"
    runs = [
        ("a churny README fails the gate", {"a": (own, churny)}, {}, 1),
        ("a clean README passes the gate", {"a": (own, clean)}, {}, 0),
        ("a fork is exempt", {"a": (up, churny)}, {}, 0),
        ("a chibifire-stages repo is ours",
         {"a": ("https://github.com/chibifire-stages/x", churny)}, {}, 1),
        ("a grandfathered README at its count", {"a": (own, churny)}, {"a": 2}, 0),
        ("a grandfathered README that gains churn",
         {"a": (own, churny + "Built on 2026-10-04.\n")}, {"a": 2}, 1),
        ("a grandfathered README that came clean", {"a": (own, clean)}, {"a": 2}, 1),
    ]
    for label, projects, held, want in runs:
        with tempfile.TemporaryDirectory() as d:
            workspace(Path(d), projects)
            with open(os.devnull, "w") as null:
                saved, sys.stdout = sys.stdout, null
                try:
                    got = gate(Path(d), held)
                finally:
                    sys.stdout = saved
        if got != want:
            print(f"  FAIL {label}: got {got}, expected {want}")
            fails += 1
    n = len(controls) + 3 + len(runs)
    if fails:
        print(f"{fails} of {n} controls failed")
        return 1
    print(f"ok   {n} of {n} controls fired in both directions")
    return 0


def main(argv):
    ap = argparse.ArgumentParser()
    ap.add_argument("--self-test", action="store_true")
    ap.add_argument("--workspace", type=Path, help="the directory holding .repo")
    a = ap.parse_args(argv)
    if a.self_test:
        return self_test()
    if a.workspace:
        return gate(a.workspace)
    if ROOT is None:
        print("FAIL: no .repo above this checkout, so there is no workspace to check")
        return 1
    return gate(ROOT)


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
