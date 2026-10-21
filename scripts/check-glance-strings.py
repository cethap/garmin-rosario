#!/usr/bin/env python3
"""Checks that the glance uses only the strings and the code it can load.

The glance loads only the code annotated (:glance) and only the string resources marked scope="glance".
Looking up any other string from the glance crashes it on the watch ("Symbol Not Found Error"), and
neither the compiler (even with -w) nor the unit tests, which run as the full app, notice. So this check
reads the code annotated (:glance) and fails when:

- it looks up a string (Rez.Strings.<id>) that is not marked scope="glance" in the base strings
  (resources/) or in a language's strings (resources-<lang>/), or that a language leaves out;
- it calls a function or creates a class that only code outside the glance defines, such as the labels in
  source/RosaryLabels.mc, whose strings the glance cannot load;
- a string is marked scope="glance" but the glance never looks it up: every glance-scoped string takes
  room in the glance's 32KB.

Usage: python3 scripts/check-glance-strings.py   (exits 0 when the glance is clean, 1 otherwise)
"""
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ANNOTATION = re.compile(r"\(\s*((?::\w+\s*)+)\)")
DECLARATION = re.compile(r"\s*(?:(?:static|private|protected|public|hidden)\s+)*(module|class|function|const|var)\s+(\w+)")
STRING_ID = re.compile(r"\bRez\s*\.\s*Strings\s*\.\s*(\w+)")
CALL = re.compile(r"\b(\w+)\s*\(")
NOT_CALLS = {"if", "for", "while", "switch", "return", "function", "catch", "new", "and", "or", "instanceof", "has"}
LANGUAGE_FOLDER = re.compile(r"resources-([a-z]{3})$")
# Methods of the (:glance) app class that the system calls only for the full-screen app, never for the
# glance: the code in them may use anything.
FULL_APP_ONLY = {"getInitialView"}


def code_only(text):
    """The source with comments and string and character literals blanked out (same length and lines)."""
    out = []
    i, n = 0, len(text)
    while i < n:
        c = text[i]
        if text.startswith("//", i):
            end = text.find("\n", i)
            end = n if end < 0 else end
            out.append(" " * (end - i))
            i = end
        elif text.startswith("/*", i):
            end = text.find("*/", i + 2)
            end = n if end < 0 else end + 2
            out.append(re.sub(r"[^\n]", " ", text[i:end]))
            i = end
        elif c in "\"'":
            j = i + 1
            while j < n and text[j] != c and text[j] != "\n":
                j += 2 if text[j] == "\\" else 1
            out.append(c + " " * (min(j, n) - i - 1) + (c if j < n else ""))
            i = j + 1
        else:
            out.append(c)
            i += 1
    return "".join(out)


def block_end(code, start):
    """Index just past the brace block that opens at or after start."""
    depth = 0
    for i in range(code.index("{", start), len(code)):
        if code[i] == "{":
            depth += 1
        elif code[i] == "}":
            depth -= 1
            if depth == 0:
                return i + 1
    return len(code)


def glance_spans(code):
    """[start, end) spans of the code the glance runs: the declarations annotated (:glance), less the
    FULL_APP_ONLY methods inside them."""
    spans = []
    for match in ANNOTATION.finditer(code):
        if ":glance" not in match.group(1).split():
            continue
        declaration = DECLARATION.match(code, match.end())
        if not declaration:
            continue
        if declaration.group(1) in ("const", "var"):
            spans.append((declaration.start(), code.find(";", declaration.end()) + 1))
        else:
            spans.append((declaration.start(), block_end(code, declaration.end())))
    for match in re.finditer(r"\bfunction\s+(\w+)", code):
        if match.group(1) in FULL_APP_ONLY:
            spans = cut(spans, match.start(), block_end(code, match.end()))
    return spans


def cut(spans, start, end):
    """The spans less [start, end)."""
    result = []
    for a, b in spans:
        if end <= a or b <= start:
            result.append((a, b))
            continue
        if a < start:
            result.append((a, start))
        if end < b:
            result.append((end, b))
    return result


def line_of(text, index):
    return text.count("\n", 0, index) + 1


def read_sources():
    """For every source file: (path, code, glance spans)."""
    sources = []
    for path in sorted((ROOT / "source").rglob("*.mc")):
        code = code_only(path.read_text(encoding="utf-8"))
        sources.append((path, code, glance_spans(code)))
    return sources


def read_strings():
    """{folder name: {string id: scope}} for the base strings and each language's."""
    folders = {}
    for folder in sorted(ROOT.glob("resources*")):
        if folder.name != "resources" and not LANGUAGE_FOLDER.match(folder.name):
            continue
        strings = {}
        for xml in sorted(folder.rglob("*.xml")):
            for element in ET.parse(xml).getroot().iter("string"):
                strings[element.get("id")] = element.get("scope", "")
        if strings:
            folders[folder.name] = strings
    return folders


def main():
    sources = read_sources()
    glance_names, other_names = set(), {}
    used_ids, calls = {}, []
    for path, code, spans in sources:
        inside = lambda index: any(start <= index < end for start, end in spans)
        for match in re.finditer(r"\b(function|class)\s+(\w+)", code):
            if inside(match.start()):
                glance_names.add(match.group(2))
            else:
                other_names.setdefault(match.group(2), f"{path.relative_to(ROOT)}:{line_of(code, match.start())}")
        for start, end in spans:
            for match in STRING_ID.finditer(code, start, end):
                used_ids.setdefault(match.group(1), f"{path.relative_to(ROOT)}:{line_of(code, match.start())}")
            for match in CALL.finditer(code, start, end):
                if match.group(1) not in NOT_CALLS:
                    calls.append((match.group(1), f"{path.relative_to(ROOT)}:{line_of(code, match.start())}"))

    problems = []
    for name, where in calls:
        if name in other_names and name not in glance_names:
            problems.append(f"{where}: the glance calls {name}, which only code outside the glance defines "
                            f"({other_names[name]})")

    folders = read_strings()
    if "resources" not in folders:
        problems.append("resources/: no base strings found")
    for string_id, where in sorted(used_ids.items()):
        for folder, strings in folders.items():
            if string_id not in strings:
                problems.append(f"{where}: the glance looks up {string_id}, which {folder}/ leaves out")
            elif strings[string_id] != "glance":
                problems.append(f"{where}: the glance looks up {string_id}, which {folder}/ does not mark "
                                f"scope=\"glance\"")
    for folder, strings in folders.items():
        for string_id, scope in sorted(strings.items()):
            if scope == "glance" and string_id not in used_ids:
                problems.append(f"{folder}/: {string_id} is marked scope=\"glance\" but the glance never "
                                f"looks it up")

    if problems:
        print("Glance strings FAILED:")
        for problem in problems:
            print("  " + problem)
        return 1
    print(f"Glance strings OK: the glance looks up {len(used_ids)} strings, each glance-scoped in "
          f"{', '.join(folders)}; {len(calls)} calls in glance code, none to code outside the glance.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
