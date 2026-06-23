# ProofIME

ProofIME is a macOS application for writing mathematical proofs faster.

Inspired by Vietnamese Telex input methods, ProofIME converts lightweight shorthand into Unicode mathematical notation and LaTeX expressions in real time. It is designed for students, mathematicians, and anyone tired of hunting through symbol menus while writing proofs.

## Features

### Unicode Output

Convert shorthand into mathematical symbols.

| Input | Output |
| ----- | ------ |
| fa    | ∀      |
| ex    | ∃      |
| inn   | ∈      |
| RR    | ℝ      |
| ZZ    | ℤ      |
| =>    | ⇒      |
| <=>   | ⇔      |

Example:

```text
fa x inn RR => ex y inn ZZ
```

becomes

```text
∀ x ∈ ℝ ⇒ ∃ y ∈ ℤ
```

---

### LaTeX Output

Generate LaTeX-ready notation from the same shorthand.

Example:

```text
fa x inn RR => ex y inn ZZ
```

becomes

```latex
\forall x \in \mathbb{R} \Rightarrow \exists y \in \mathbb{Z}
```

---

### Token-Based Parsing

ProofIME uses token-based parsing rather than naive string replacement.

This prevents accidental transformations such as:

```text
fax
```

becoming

```text
∀x
```

Only complete tokens are converted.

---

### Custom Symbol Mappings

Import custom JSON configurations.

Example:

```json
{
  "qed": "∎",
  "all": "∀",
  "real": "ℝ"
}
```

Users can define their own notation system without modifying source code.

---

### Proof Templates

Generate common proof structures instantly.

Available templates include:

* Direct Proof
* Contradiction
* Contraposition
* Induction
* Universal Proofs
* Existence Proofs
* Existence & Uniqueness Proofs

Example:

```text
/template contradiction
```

expands into a proof skeleton.

---

### Export Tools

Export generated output as:

* TXT
* TEX

or copy directly to the clipboard.

---

### User Configuration Folder

ProofIME automatically loads user-defined configurations from:

```text
~/Library/Application Support/ProofIME/
```

Supported files:

```text
symbols.json
proof_templates.json
```

No manual imports required.

---

## Technology

* Swift
* SwiftUI
* Foundation
* AppKit

---

## Motivation

ProofIME began as an experiment inspired by Vietnamese Telex input methods.

Vietnamese typists use short character sequences to generate accented letters efficiently. ProofIME applies the same idea to mathematical notation, allowing proofs to be written with simple, memorable shortcuts.

Instead of:

```text
Insert Symbol
→ Search Symbol
→ Click Symbol
```

users can type:

```text
fa x inn RR
```

and immediately obtain:

```text
∀ x ∈ ℝ
```

---

## Roadmap

### Completed

* Unicode output
* LaTeX output
* JSON symbol mappings
* Token-based parser
* Proof templates
* TXT/TEX export
* User configuration folder

### Planned

* Keyboard shortcuts
* Template editor
* Symbol search
* Menu bar integration

### V1.0

* Native macOS Input Method Editor (IME)
* System-wide proof notation input
* Works across any macOS application

---

## Author

Trang Nguyen

Computer Science + Mathematics @ Georgia State University
