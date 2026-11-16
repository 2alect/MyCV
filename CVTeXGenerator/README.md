# CV template

LuaLaTeX CV template with example content, intended for a public repository.
All project text is in English. Unless explicitly stated otherwise, paths below are
relative to `CVTeXGenerator/`.

## Requirements

- A TeX distribution with `lualatex` available on PATH (for example, MiKTeX).
- VS Code with LaTeX Workshop for editor builds; command-line builds work without VS Code.
- Install missing TeX packages if prompted on the first build.

## Three layers

| Layer | Files | Public repository | Future private fork |
| --- | --- | --- | --- |
| Template and examples | `main.tex`, `style.tex`, `variant.tex`, `content/`, `.vscode/` | Tracked | Tracked |
| Personal content and assets | `private/` | Ignored | Tracked after updating the fork's ignore rules |
| Sensitive contacts and local overrides | `local/` | Always ignored | Always ignored |

Generated files under `build/` are always ignored. PDFs can contain sensitive contacts.

## Build the public example

A fresh clone builds the example without any personal files. `variant.tex` selects
`content/profile.example.tex`; `content/contacts.example.tex` provides dummy contacts.
The example covers the header, application note, residence, languages, skills,
company career tracks, responsibilities, development stacks, education, activities,
and hobbies. Missing photo and logo files are supported.

In VS Code, open the root `MyCV.code-workspace` file or this subproject folder, then open `main.tex` and use **LaTeX Workshop: Build LaTeX project**
(`Ctrl+Alt+B`). Saving also triggers a build. Use **LaTeX Workshop: View LaTeX PDF file**
to view the PDF.

From PowerShell in the `CVTeXGenerator` directory (run `cd CVTeXGenerator` from the repository root first):

```powershell
New-Item -ItemType Directory -Force build | Out-Null
lualatex -interaction=nonstopmode -halt-on-error -file-line-error -synctex=1 -output-directory=build main.tex
lualatex -interaction=nonstopmode -halt-on-error -file-line-error -synctex=1 -output-directory=build main.tex
```

On Linux, use Bash from the same directory:

```bash
mkdir -p build
lualatex -interaction=nonstopmode -halt-on-error -file-line-error -synctex=1 -output-directory=build main.tex
lualatex -interaction=nonstopmode -halt-on-error -file-line-error -synctex=1 -output-directory=build main.tex
```

The second pass updates cross-references if they are added later; the current CV needs only one pass.
Output: `build/main.pdf`. The recipe requires no latexmk or Perl.

## Local personal preview in the public checkout

Keep personal content and images under `private/`. For a new setup, copy
`content/profile.example.tex` to `private/general.tex` and replace its placeholders.
Do not overwrite an existing personal file. Then create an
ignored `local/config.tex`:

```tex
\renewcommand{\cvcontentfile}{private/general.tex}
```

The tracked `variant.tex` continues to select the public example. The local override
changes only what is built on your computer. Neither local data directory is part
of the public repository. Keep separate backups until the private fork is ready.

## Sensitive contacts

Put actual email and telephone values only in ignored `local/contacts.tex`:

```tex
\renewcommand{\cvphone}{+00 123 456 789}
\renewcommand{\cvphonelink}{+00123456789}
\renewcommand{\cvemail}{person@example.com}
```

Each content variant owns its contact policy. The public example loads only
`content/contacts.example.tex`, even if real local contacts exist.
Personal variants load the example defaults and then optionally override them:

```tex
\input{content/contacts.example}
\InputIfFileExists{local/contacts.tex}{}{}
```

`main.tex` selects content but does not load contacts. To preview a fully anonymous
example, comment out the selection in `local/config.tex` and rebuild; no need to
rename the contact file.

Content files use `\cvphonecontact` and `\cvemailcontact`, rather than literal
contact details. Without the local file, safe example values are used.
Escape TeX special characters in text values when necessary.

## Future private fork

Once a private repository is created:

1. Copy the locally preserved `private/` directory into that checkout.
2. Remove `/private/` from `CVTeXGenerator/.gitignore` and `**/private/` from the root `.gitignore` in that fork, leaving all local and build ignore rules intact.
3. Set its tracked `variant.tex` to select `private/general.tex` or another private variant.
4. Commit the personal content and assets in the private fork.
5. Restore `local/contacts.tex` separately on each computer. Do not commit it.

A fork must permit private visibility; otherwise use a separate private repository
based on the same template. This project does not create a remote or change repository visibility.
For company-specific branches, change the tracked selector and the private content
in that fork. An ignored `local/config.tex`, if present, overrides the selector;
remove that override when relying on branch-specific selectors.

## Images

The personal photo defaults to `private/photo.jpg` (35 x 40 mm maximum, aspect ratio preserved).
The example overrides that path to `content/example-photo.jpg` so it never loads a personal photo.
When creating personal content from the example, replace that override with:

```tex
\renewcommand{\cvphotofile}{private/photo.jpg}
```

The header places name and contacts on the left, the photo in the center, and an application
note on the right. Set the note in the selected content with `\renewcommand{\cvapplicationnote}{...}`.
Company and institution icons use local paths passed to their heading commands.
Icons fit within 49 x 49 CSS pixels at 96 dpi (about 13 x 13 mm), with rounded corners.
Missing icons display a rounded outline labeled `Icon`; a missing photo displays a placeholder.
Personal images belong only in the private fork.

## Template files

- `main.tex` loads styles, the content selector, and an optional local selector override.
- `style.tex` defines typography, the header, company career tracks, education, and image placeholders.
- `variant.tex` chooses the content file. A missing selected file is a build error.
- `content/profile.example.tex` demonstrates every section without personal data.
- `content/contacts.example.tex` defines safe contacts and contact-rendering commands.
- `.vscode/settings.json` configures two LuaLaTeX passes, build on save, and the PDF viewer.

After changing variants, rebuild: `build/main.pdf` is shared by variants and may still show
the previous content until compilation succeeds.

## Before committing

Review staged files. `private/` must stay ignored in the public checkout; `local/`
must stay ignored in both repositories. Never force-add sensitive files. Git does
not back up ignored files, and `git clean -fdx` can delete them.

## Optional copy watermark

Create `local/watermark.txt` as a single UTF-8 line of 1 to 128 characters.
Use `content/watermark.example.txt` as an example. Include the recipient, issue date,
and preferably a random nonce. This file stays outside Git. Without it, no watermark
or watermark metadata is added. Empty or invalid configured secrets fail the build.

LuaLaTeX computes SHA-256 over a versioned, length-delimited combination of the
secret, the SHA-256 of the selected content file, and the SHA-256 of the selected
profile photo (or an explicit missing-photo marker). A subtle 5 pt light-gray copy ID (15% black) is
printed at the bottom center of every page (2.5 mm above the edge). The 128-bit ID and full fingerprint are
also stored in custom PDF metadata. The plaintext secret is not stored in the PDF.
The mark does not require a second TeX pass or shell escape.

Changing the secret, content bytes, or photo bytes changes the mark on rebuild.
Other included files, contact overrides, logos, and style files are not part of this
source fingerprint. A simple hash is not encryption: predictable recipient/date
strings can be guessed; use a nonce if the mapping should be harder to guess.

From `CVTeXGenerator/`, inspect a PDF and optionally check it against source inputs:

```text
texlua watermark/verify.lua build/main.pdf
texlua watermark/verify.lua build/main.pdf local/watermark.txt private/general.tex private/photo.jpg
```

For integrity of an issued PDF, retain the exact original PDF and create its record
only after the final build:

```text
texlua watermark/verify.lua --record build/main.pdf
texlua watermark/verify.lua build/main.pdf
```

This writes `build/main.pdf.sha256`. Keep this trusted record privately; when checking
another copy, place the original record next to it with the matching `.pdf.sha256`
name. The verifier refuses to overwrite existing records. A modified PDF produces
exit code 1; invalid input produces 2. Without a trusted record it reports integrity
as unknown, even if the copy ID remains readable.

An embedded source fingerprint cannot authenticate arbitrary edits to a finished PDF:
replacing an image can leave both the visible ID and metadata untouched. The external
whole-file hash detects those changes. Neither mechanism is a digital signature or
proof of who redistributed a copy. Marks may be removed, cropped, or lost in conversion.
All `.pdf.sha256` records and generated PDFs should remain outside Git.

Run deterministic fingerprint checks with `texlua watermark/test.lua` after creating
`build/`. The implementation uses LuaTeX's built-in SHA-256 and PDF reader; no Python
packages or additional TeX packages are required.

## Page decoration

An optional illustration can be placed as a background at the bottom of every page. Set its path
in the selected content file, so each company variant can choose its own image:

```tex
\renewcommand{\cvfooterimage}{private/footer.png}
```

Keep it next to `private/photo.jpg` and the `private/icons/` directory; it belongs in
the future private repository. The public example has no decoration by default.
Missing files are silently skipped. Images fit within 85% of the text width and 32 mm height,
with preserved aspect ratio, with its bottom edge 5.5 mm above the page edge. The image is rendered automatically
in monochrome with a maximum ink density of
`black!10`, lighter than the watermark (`black!15`). The source image is not modified. A white-backed
PDF luminosity mask preserves tonal details and handles transparent PNGs. The mask
is inverted into gray ink opacity, so no white rectangle or border is painted.
Responsibility blocks have no opaque background, allowing the decoration to show
through behind text. A wide image
with a transparent background works best. The copy watermark remains below it.
The illustration is in the background, so body text renders above it. The copy ID is centered below the illustration at 2.5 mm above the bottom edge. Neither element reserves text space; printers with large unprintable margins may clip them.
