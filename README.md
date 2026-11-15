# CV

A general CV prototype without company-specific tailoring. Built with **LuaLaTeX** (MiKTeX).
All content is in English and currently contains placeholders to replace with verified information.

## Files

- `main.tex` - entry point.
- `content/profile.tex` - CV content.
- `style.tex` - fonts, colors, spacing, and formatting commands.
- `.vscode/settings.json` - LaTeX Workshop recipe without a latexmk/Perl dependency.
- `build/` - generated PDF and auxiliary files; excluded from Git.

## Build in VS Code

Open `main.tex` and run **LaTeX Workshop: Build LaTeX project**
(`Ctrl+Alt+B`). Saving also triggers a build.
Run **LaTeX Workshop: View LaTeX PDF file** to view the result.

## Build from PowerShell

Run from the repository root:

```powershell
New-Item -ItemType Directory -Force build | Out-Null
lualatex -interaction=nonstopmode -halt-on-error -file-line-error -synctex=1 -output-directory=build main.tex
lualatex -interaction=nonstopmode -halt-on-error -file-line-error -synctex=1 -output-directory=build main.tex
```

Output: `build/main.pdf`. Two passes update cross-references.
