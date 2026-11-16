# MyCV

Repository for a CV template and related tools. Each tool lives in its own subdirectory.

## Subprojects

- [CVTeXGenerator](CVTeXGenerator/README.md) - LuaLaTeX CV template, example content, and local personal preview.

For CV editing, open the `CVTeXGenerator` folder directly in VS Code.
The optional `MyCV.code-workspace` file opens that same folder and loads its editor settings;
it is a convenience, not a build dependency. It currently includes only the generator.

See the subproject README for setup, builds, content selection, and contact handling.
Paths in that README are relative to `CVTeXGenerator/`, unless stated otherwise.

This public repository stores the template and examples. Personal content and images
under `CVTeXGenerator/private/` remain local until moved into a private repository.
Sensitive contacts under `CVTeXGenerator/local/` must stay outside Git in both repositories.
