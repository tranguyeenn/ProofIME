# ProofIME

A macOS proof-writing assistant inspired by Vietnamese Telex.

ProofIME converts mathematical shorthand into Unicode symbols and LaTeX expressions while allowing users to define their own notation system through configurable JSON mappings.

---

## Screenshots

| Built-in Unicode | Built-in LaTeX |
|---|---|
| ![](screenshots/default-unicode.png) | ![](screenshots/default-latex.png) |

| Custom Configuration | Custom Symbol Library |
|---|---|
| ![](screenshots/custom-unicode.png) | ![](screenshots/custom-symbols.png) |

---

## Features

- Unicode mathematical notation
- LaTeX output mode
- Token-based parser
- Proof templates
- Custom JSON mappings
- User configuration folder
- TXT export
- TEX export
- Config management UI

## Example

Input:

```text
fa x in RR => ex y in ZZ
```

Unicode:

```text
∀ x ∈ ℝ ⇒ ∃ y ∈ ℤ
```

LaTeX:

```latex
\forall x \in \mathbb{R} \Rightarrow \exists y \in \mathbb{Z}
```

## Motivation

Vietnamese Telex allows users to type accented Vietnamese characters using lightweight keyboard shortcuts.

ProofIME applies the same idea to mathematical notation, replacing repetitive symbol searches with a configurable shorthand system.

## Roadmap

### Completed

- [x] Unicode symbol engine
- [x] LaTeX output mode
- [x] Token-based parser
- [x] Custom JSON mappings
- [x] Proof templates
- [x] TXT export
- [x] TEX export
- [x] User configuration folder

### V1.0

- [ ] Native macOS Input Method (IME)
- [ ] System-wide proof notation input
- [ ] Support for Notes
- [ ] Support for VS Code
- [ ] Support for Obsidian
- [ ] Support for LaTeX editors

## Author

Trang Nguyen

Computer Science + Mathematics @ Georgia State University
