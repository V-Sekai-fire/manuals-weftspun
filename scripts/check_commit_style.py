#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0 OR MIT
"""Gate: commit subjects are sentence-case prose, no Conventional Commits prefix.

RFD 2026 picked sentence-case prose over Conventional Commits. The rule holds on every
repository we commit to, forks included: a fork's commits stay in our fork (RFD 2294), so
the gate reads no remote and skips nothing.

Every commit reachable from HEAD but not from --base or any --exclude is checked for three
properties:

1. The subject does not begin with a Conventional-Commits prefix
   (`^[a-z]+(\\([^)]+\\))?!?:`, e.g. `feat:`, `fix(parser):`, `chore!:`).
2. The subject opens with an uppercase letter, digit, bracket or backtick
   (`RFD 2026: …` and `[RFD 2026] …` both pass).
3. The subject does not end with a trailing period.

Usage:
    python scripts/check_commit_style.py                    # HEAD~10..HEAD
    python scripts/check_commit_style.py --base origin/main # gate a branch
    python scripts/check_commit_style.py --base origin/main --exclude upstream/master
    python scripts/check_commit_style.py --self-test        # 12 controls

Exit codes: 0 all pass, 1 at least one fails, 2 bad usage.
"""
from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
import tempfile


CONVENTIONAL_RE = re.compile(r"^[a-z][a-z0-9-]*(\([^)]+\))?!?:")
SENTENCE_START_RE = re.compile(r"^([A-Z]|\d|\[|`)")
TRAILING_PERIOD_RE = re.compile(r"\.$")
GIT_ENV = ("GIT_DIR", "GIT_WORK_TREE", "GIT_INDEX_FILE", "GIT_OBJECT_DIRECTORY",
           "GIT_ALTERNATE_OBJECT_DIRECTORIES", "GIT_PREFIX", "GIT_COMMON_DIR")


def git(cwd: str, *args: str) -> str:
    env = {k: v for k, v in os.environ.items() if k not in GIT_ENV}
    return subprocess.check_output(["git", "-C", cwd, *args], text=True, env=env,
                                   stderr=subprocess.STDOUT)


def check_subject(subject: str) -> list[str]:
    problems = []
    if CONVENTIONAL_RE.match(subject):
        problems.append("Conventional-Commits prefix (RFD 2026 says sentence-case prose)")
    if not SENTENCE_START_RE.match(subject):
        problems.append("first char not uppercase / digit / bracket")
    if TRAILING_PERIOD_RE.search(subject):
        problems.append("trailing period")
    return problems


def commits_in_range(base: str, excludes: list[str], cwd: str = ".") -> list[tuple[str, str]]:
    out = git(cwd, "log", "--format=%H%x1f%s", "HEAD", *(f"^{r}" for r in [base, *excludes]),
              "--")
    rows = []
    for line in out.splitlines():
        if "\x1f" not in line:
            continue
        sha, subj = line.split("\x1f", 1)
        rows.append((sha, subj))
    return rows


def gate(base: str, excludes: list[str], cwd: str = ".") -> int:
    try:
        commits = commits_in_range(base, excludes, cwd)
    except subprocess.CalledProcessError as e:
        print(f"error: git log failed: {e.output.strip()}")
        return 2

    if not commits:
        print(f"ok  0 commits in {base}..HEAD")
        return 0

    failures = 0
    for sha, subj in commits:
        problems = check_subject(subj)
        if problems:
            failures += 1
            print(f"FAIL {sha[:12]}  {subj}")
            for p in problems:
                print(f"       - {p}")
        else:
            print(f"ok   {sha[:12]}  {subj[:60]}")
    print("---")
    print(f"{len(commits)} commit(s), {failures} failure(s)")
    return 1 if failures else 0


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", default=None,
                    help="Commit range base (default: HEAD~10)")
    ap.add_argument("--exclude", action="append", default=[], metavar="REF",
                    help="Also skip commits reachable from REF, such as a fork's upstream")
    ap.add_argument("--self-test", action="store_true")
    args = ap.parse_args(argv[1:])

    if args.self_test:
        return self_test()
    return gate(args.base or "HEAD~10", args.exclude)


def run_on_scratch_repo(root: str, remote: str, steps: list[list[str]],
                        args: list[str]) -> tuple[int, str]:
    repo = tempfile.mkdtemp(dir=root)
    ident = ["-c", "user.name=self-test", "-c", "user.email=self-test@example.invalid",
             "-c", "commit.gpgsign=false"]
    git(repo, "init", "-q", "-b", "work")
    git(repo, "remote", "add", "origin", remote)
    for step in [["commit", "-q", "--no-verify", "--allow-empty", "-m", "Base"],
                 ["tag", "base"], *steps]:
        git(repo, *ident, *step)
    env = {k: v for k, v in os.environ.items() if k not in GIT_ENV}
    run = subprocess.run([sys.executable, os.path.abspath(__file__), *args], cwd=repo,
                         env=env, capture_output=True, text=True)
    return run.returncode, run.stdout


def commit(subject: str) -> list[str]:
    return ["commit", "-q", "--no-verify", "--allow-empty", "-m", subject]


def self_test() -> int:
    """6 subject controls, 4 through the CLI on both remotes, 2 on a merged upstream commit."""
    cases = [
        ("Add the macOS and Windows release workflows", 0, "plain sentence"),
        ("RFD 2026: Commit messages sentence case", 0, "RFD prefix, sentence body"),
        ("[urgent] Fix the leaking file descriptor", 0, "bracket-tag open"),
        ("feat: add the release workflow", 2, "conventional-commits + not-capital"),
        ("fix(parser): handle nested arrays", 2, "conventional-commits w/ scope + not-capital"),
        ("Add the workflow.", 1, "trailing period"),
    ]
    all_pass = True
    for subj, expect, label in cases:
        problems = check_subject(subj)
        ok = len(problems) == expect
        marker = "ok   " if ok else "FAIL "
        print(f"  {marker} [{label}] expect={expect} got={len(problems)}: {subj}")
        if not ok:
            for p in problems:
                print(f"       problem: {p}")
            all_pass = False

    fork = "https://github.com/godotengine/godot"
    upstream = [["checkout", "-q", "-b", "upstream", "base"],
                commit("core: fix the scene loader"),
                ["checkout", "-q", "work"],
                commit("Add the release workflow"),
                ["merge", "-q", "--no-ff", "--no-verify", "-m", "Merge the upstream", "upstream"]]
    runs = [(f"remote {remote} subject {subj!r}", remote, [commit(subj)],
             ["--base", "HEAD~1"], expect, subj)
            for remote in ("https://github.com/V-Sekai-fire/manuals-weftspun", fork)
            for subj, expect in (("feat: add the release workflow", 1),
                                 ("Add the release workflow", 0))]
    runs += [("merged upstream prefixed commit read", fork, upstream, ["--base", "base"], 1,
              "core: fix the scene loader"),
             ("merged upstream prefixed commit excluded", fork, upstream,
              ["--base", "base", "--exclude", "upstream"], 0, "")]

    with tempfile.TemporaryDirectory() as root:
        for label, remote, steps, args, expect, failing in runs:
            try:
                got, out = run_on_scratch_repo(root, remote, steps, args)
            except (OSError, subprocess.CalledProcessError) as e:
                got, out = f"error: {getattr(e, 'output', None) or e}", ""
            named = any(line.startswith("FAIL ") and line.endswith(f"  {failing}")
                        for line in out.splitlines())
            ok = got == expect and (expect == 0 or named)
            marker = "ok   " if ok else "FAIL "
            print(f"  {marker} {label} exit={got} (expected {expect})")
            all_pass = all_pass and ok

    print("---")
    print("self-test:", "ok" if all_pass else "FAIL")
    return 0 if all_pass else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
