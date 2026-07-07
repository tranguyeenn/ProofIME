# Proof template specification

## Status

Built-in template loading and expansion are implemented. User template overrides, structured fields, context-aware selection, and theorem-aware completions are planned.

## Source and schema

Templates are decoded from bundled `ProofIME/Resources/proof_templates.json` as an array:

```json
[
  {
    "id": "contradiction",
    "trigger": "contr",
    "title": "Proof by Contradiction",
    "body": "Proof by contradiction:\nSuppose <#negation of statement#>."
  }
]
```

All fields are required strings:

- `id`: stable identity used by SwiftUI lists and persisted favorites.
- `trigger`: exact, case-sensitive expansion token.
- `title`: display label used by the reference panel and search.
- `body`: inserted plain text, including newlines and placeholder notation.

IDs and triggers should be unique. The loader does not currently validate uniqueness. `TemplateEngine` returns the first matching trigger.

## Implemented behavior

- The loader reads the bundle on each access and returns an empty array after a missing-resource or decode error.
- Search matches trigger, title, or body using localized case-insensitive containment.
- Favorites are stored as comma-separated IDs in `@AppStorage("favoriteTemplateIDs")` and sort before other results.
- Clicking a template or favorite inserts its body at the current selection/cursor.
- Typing a trigger followed by Space, Tab, or Return expands it through `LiveReplacementController`.
- Template expansion is checked before symbol replacement for the same token.
- The typed boundary is appended after the body.

Example:

```text
contr + Space
```

inserts the built-in contradiction body followed by a space.

## Placeholders

Text such as `<#work#>` is currently literal body content. It resembles editor placeholders but ProofIME does not parse it, navigate between fields, validate completion, or substitute context.

When authoring templates, keep placeholders concise and descriptive:

```text
<#hypothesis#>
<#work#>
<#conclusion#>
```

Do not depend on nested or escaped placeholder syntax; no formal placeholder parser exists.

## User configuration limitation

`AppConfig` defines:

```text
~/Library/Application Support/ProofIME/proof_templates.json
```

and the Config menu can delete that file. However, `ProofTemplateLoader` does not read it, and the current import action imports symbols only. Editing or placing a file at that path has no effect on loaded templates.

## Built-in catalog

The bundle currently includes direct, contrapositive, contradiction, cases, biconditional, universal, constructive existence, unique existence, subset, set equality, and divisibility proof skeletons. Bodies are writing aids, not verified proofs.

## In progress and planned

In progress: decide override/merge behavior, validate files, add loader tests, and align template token boundaries with the canonical tokenizer.

Planned: user import/export and editing, structured field navigation, contextual ranking, and context-aware theorem/proof templates. Any contextual feature must preserve deterministic user control and keep proof text processing local unless a future network feature is separately designed and consented to.
