# Symbol and replacement rule specification

## Status

Two JSON shapes are implemented by `SymbolLoader`: a legacy dictionary and a replacement-rule array. The bundled `symbols.json` uses the dictionary shape. Some decoded rule fields are not yet enforced; those limitations are called out below.

## Storage and precedence

The bundled default is `ProofIME/Resources/symbols.json`. At runtime, the app first checks:

```text
~/Library/Application Support/ProofIME/symbols.json
```

If that file exists, it replaces the bundled source rather than merging with it. A malformed user file currently yields an empty mapping/rule set and console output; it does not fall back to the bundle. Import copies a selected JSON file to this path without validation.

## Legacy dictionary format

```json
{
  "fa": "∀",
  "inn": "∈",
  "RR": "ℝ"
}
```

Each property name is an exact, case-sensitive trigger and each value is its Unicode output. Dictionary entries converted to rules receive Unicode mode, `requiresBoundary: true`, priority `0`, and no aliases.

## Rule-array format

```json
[
  {
    "trigger": "fa",
    "output": "∀",
    "mode": "Unicode",
    "requiresBoundary": true,
    "priority": 10,
    "aliases": ["forall"]
  }
]
```

All six keys are required by the synthesized `Codable` decoder, even though five properties have Swift default values. `mode` must be exactly `"Unicode"` or `"LaTeX"`.

| Field | Type | Current behavior |
|---|---|---|
| `trigger` | string | Exact, case-sensitive match. |
| `output` | string | Replacement text. |
| `mode` | enum string | Decoded, but not used to filter rules. |
| `requiresBoundary` | boolean | Decoded, but not consulted. Live replacement is boundary-driven regardless. |
| `priority` | integer | Rules are sorted descending; first matching rule wins. |
| `aliases` | string array | Included in `ReplacementEngine` exact matching. |

Duplicate triggers are not validated. In the rule engine, sorted first-match order determines the result; equal-priority ordering should not be relied upon. In mapping conversion, duplicate keys can cause `Dictionary(uniqueKeysWithValues:)` to trap. Treat triggers as unique.

## Built-in triggers

The bundle currently contains:

| Group | Triggers |
|---|---|
| Quantifiers/membership | `fa`, `ex`, `inn`, `nin` |
| Number sets | `RR`, `ZZ`, `QQ`, `NN`, `CC` |
| Implication | `=>`, `<=>` |
| Logic | `andd`, `orr`, `nott` |
| Sets | `sub`, `psub`, `empty` |
| Proof notation | `there4`, `becuz` |
| Relations | `!=`, `>=`, `<=`, `equiv`, `approx` |
| Greek letters | `eps`, `del`, `lam`, `alp`, `bet` |

The exact outputs are defined in `ProofIME/Resources/symbols.json`.

## LaTeX behavior

`SymbolLoader.loadLatexMappings()` is a hard-coded dictionary, separate from `symbols.json`. `SymbolEngine` uses it for the output preview when LaTeX mode is selected. It splits on literal spaces and preserves empty space-separated segments; punctuation-attached tokens do not match.

Live editor replacement uses rules loaded from the symbol file and is not filtered by the selected mode. Consequently, selecting LaTeX does not make boundary-triggered editor replacements emit LaTeX.

## Matching examples

With built-in configuration:

```text
fa + Space     -> ∀ 
RR + Tab       -> ℝ<TAB>
unknown + Space -> unchanged token plus normal Space
```

In batch preview, `fa RR` transforms but `fa, RR` leaves `fa,` unchanged because the preview splits only on spaces.

## In progress and planned

In progress: validation, unified mode semantics, one tokenizer/boundary contract, and safe duplicate handling.

Planned: versioned schemas, merge/override policy, last-known-good recovery, preferences-based editing, and atomic import/export. Until these exist, back up user configuration before using deletion controls.
