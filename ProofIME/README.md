# ProofIME

ProofIME is a macOS input method project for mathematical proof writing.

Inspired by Vietnamese Telex, ProofIME converts shorthand notation into mathematical symbols, allowing users to write proofs more efficiently without searching for Unicode characters.

## Example

Input:

```txt
fa x inn RR => ex y inn ZZ
```

Output:

```txt
∀ x ∈ ℝ ⇒ ∃ y ∈ ℤ
```

## Features

- Real-time mathematical symbol transformation
- Configurable symbol mappings via JSON
- Unicode proof notation support
- SwiftUI desktop application
- Modular transformation engine

## Project Structure

```txt
ProofIME
├── ContentView.swift
├── SymbolEngine.swift
├── SymbolLoader.swift
└── symbols.json
```

### Components

#### SymbolEngine

Responsible for transforming shorthand notation into mathematical symbols.

#### SymbolLoader

Loads symbol mappings from a JSON configuration file.

#### symbols.json

Stores configurable symbol mappings.

Example:

```json
{
  "fa": "∀",
  "ex": "∃",
  "RR": "ℝ"
}
```

## Current Status

### Completed

- SwiftUI application setup
- Symbol transformation engine
- JSON configuration loader
- Unicode symbol replacement

### Planned

- Live symbol reference table
- LaTeX output mode
- User-defined mappings
- macOS Input Method Editor (IME) integration
- Telex-style typing experience

## Inspiration

As a Vietnamese student, I regularly use the Telex input method to type Vietnamese characters efficiently.

ProofIME applies the same concept to mathematical notation, transforming shorthand commands into proof symbols as the user types.

## Technologies

- Swift
- SwiftUI
- Foundation
- JSON

## License

MIT License
