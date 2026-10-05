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
    "version": re.compile(r"(?<![\w.])v?\d+\.\d+\.\d+(?:[-+][\w.]+)?\b"),
    "date": re.compile(r"\b20\d\d-[01]\d-[0-3]\d\b"),
    "branch": re.compile(r"\b(?:feat|fix|archived|release|hotfix)/[\w.-]+"),
}
STATUS = re.compile(r"^(status|state|progress|done|todo|wip|phase)$", re.I)
MARKS = re.compile("[✅❌✔✖⏳\U0001f6a7]|\\b(?:TODO|WIP)\\b")
PINNED = re.compile(r"\b(dependenc|requirement|pin)", re.I)
FLAG_LIST = 3

# The READMEs that carried churny detail when this gate landed; each is counted, not skipped.
GRANDFATHERED = {
    "1-transport/cineform-tui",
    "2-contract/anny-keypoint-anchors",
    "2-contract/bootstrap",
    "2-contract/lean-deform-exact",
    "2-contract/lean-slang",
    "2-contract/trust-lean",
    "2-contract/truth-research-zk",
    "2-contract/weftspun-agreements",
    "2-contract/zone-backend",
    "3-interactor/anny",
    "3-interactor/av1mkv",
    "3-interactor/cineform",
    "3-interactor/editscore-lora-qwen3vl-4b",
    "3-interactor/editscore",
    "3-interactor/fabric-zone",
    "3-interactor/frame-controller-sim",
    "3-interactor/frame-eye-osc",
    "3-interactor/kimodo-ggml",
    "3-interactor/lingbot-map-upstream",
    "3-interactor/moge-upstream",
    "3-interactor/mujoco-sandbox-demo",
    "3-interactor/omnigen2",
    "3-interactor/panelspun",
    "3-interactor/physics",
    "3-interactor/pixal3d-image-mesh-painting",
    "3-interactor/pixal3d-image-to-textured-mesh",
    "3-interactor/pixal3d-upstream",
    "3-interactor/rf-detr-ggml",
    "3-interactor/sakuragaoka-station-upstream",
    "3-interactor/slughorn",
    "3-interactor/soma-x",
    "3-interactor/trellis2-image-to-textured-mesh",
    "3-interactor/trellis2-upstream",
    "3-interactor/udon2godot",
    "3-interactor/ufbx-to-openusd",
    "3-interactor/voice",
    "3-interactor/voxhammer-upstream",
    "3-interactor/xr-pilot",
    "4-entities/egit",
    "4-entities/godot-sandbox-gdscript-compiler",
    "4-entities/godot-vrm",
    "4-entities/opentelemetry-godot-project",
    "5-repository/witness-cpp",
    "6-datasource/anny-render-corpus",
    "6-datasource/desync",
    "6-datasource/foundationdb",
    "7-service/burrito",
    "7-service/cineform",
    "7-service/cineform/thirdparty/cineform-sdk",
    "7-service/cineform/thirdparty/iceoryx2",
    "7-service/godot-build",
}


def findings(text: str) -> list[str]:
    """Each churny kind found outside fenced blocks, once per occurrence."""
    out, section, flags = [], "", 0
    header, in_head, cells = None, False, []
    for tok in md_ast.tokens(text):
        if tok.type == "heading_open":
            section = None
        elif tok.type == "thead_open":
            in_head, cells = True, []
        elif tok.type == "thead_close":
            in_head, header = False, cells
            if any(STATUS.match(c) for c in cells):
                out.append(f"status table: {' | '.join(cells)}")
        if tok.type != "inline":
            continue
        if section is None:
            section = tok.content
            continue
        if in_head:
            cells.append(tok.content.strip())
        pinned = bool(PINNED.search(section))
        for child in tok.children or ():
            if child.type not in ("text", "code_inline"):
                continue
            s = child.content
            if child.type == "code_inline" and FLAG.match(s):
                flags += 1
            if MARKS.search(s) and header is not None:
                out.append(f"status mark: {s.strip()}")
            for kind, rx in KINDS.items():
                if kind == "version" and pinned:
                    continue
                out += [f"{kind}: {m.group(0)}" for m in rx.finditer(s)]
    if flags >= FLAG_LIST:
        out.append(f"flag list: {flags} flags; --help carries them")
    return out


def gate(root: Path) -> int:
    man = ET.parse(root / ".repo/manifests/default.xml").getroot()
    checked, missing, forks, bad, held = 0, [], [], [], []
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
        if path in GRANDFATHERED:
            held.append(path)
            if not found:
                print(f"  FAIL {path}: clean now; drop it from GRANDFATHERED")
                bad.append(path)
            continue
        if found:
            bad.append(path)
            print(f"  FAIL {path}/README.md: " + "; ".join(found[:6])
                  + (f"; +{len(found) - 6} more" if len(found) > 6 else ""))
    print(f"  {checked} READMEs read, {len(missing)} projects without one or not on disk, "
          f"{len(forks)} forks exempt, {len(held)} grandfathered and still churny.")
    print(f"{len(bad)} of {checked - len(held)} READMEs outside GRANDFATHERED fail.")
    return 1 if bad else 0


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
    n = len(controls) + 2
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
