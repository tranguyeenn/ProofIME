# Contributing

## Ground rules

- Treat the code and tests as the implementation source of truth; update the relevant spec or ADR when behavior changes.
- Do not describe the SwiftUI app as a system-wide IME.
- Keep processing logic independent of SwiftUI and, where practical, AppKit.
- Preserve backward compatibility for documented JSON formats or document a migration.
- Keep unrelated refactors out of focused changes.

## Development setup

Open `ProofIME.xcodeproj` in a compatible Xcode version and use the `ProofIME` scheme. The project currently records Swift 5 mode, a macOS 26.3 application target, and Xcode 26.4.1 project metadata.

Build from the command line with Derived Data outside the repository:

```sh
xcodebuild -project ProofIME.xcodeproj \
  -scheme ProofIME \
  -destination 'platform=macOS' \
  -derivedDataPath /tmp/ProofIME-DerivedData \
  build
```

See [TESTING.md](TESTING.md) for the test command and known baseline issue.

## Change workflow

1. Identify the owning layer in [ARCHITECTURE.md](ARCHITECTURE.md).
2. Add or update tests for externally visible processing behavior.
3. Implement the smallest coherent change.
4. Run the build and tests; manually exercise UI or IME paths that unit tests cannot cover.
5. Update specs, ADRs, roadmap status, and changelog when applicable.

## Code expectations

- Prefer explicit inputs and returned values for engines; avoid hidden UI state.
- Preserve text and cursor position on no-match paths.
- Specify whether offsets use Swift characters, Unicode scalars, or UTF-16 units.
- Make boundary, precedence, and fallback behavior testable.
- Avoid `print` as the only user-facing error path for configuration failures.
- Use fixtures for JSON decoding tests rather than relying only on the application bundle.

## Configuration changes

For symbol work, update [SYMBOL_SPEC.md](SYMBOL_SPEC.md). For templates, update [TEMPLATE_SPEC.md](TEMPLATE_SPEC.md). Include tests for valid input, malformed input, duplicate keys/triggers, and fallback behavior. Do not silently activate decoded fields that previously had no effect without documenting the compatibility consequence.

## Architecture decisions

Add an ADR under `docs/adr/` for decisions that constrain multiple components or are expensive to reverse. Use this shape:

```markdown
# ADR NNN: Title

- Status: Proposed | Accepted | Superseded
- Date: YYYY-MM-DD

## Context
## Decision
## Consequences
```

Proposed ADRs describe direction, not implemented behavior.

## Pull request checklist

- [ ] Build completes.
- [ ] Tests pass, or the known failure and its cause are documented.
- [ ] Manual checks cover changed UI/host behavior.
- [ ] Documentation matches current behavior and status.
- [ ] No claim of host compatibility is made without recorded testing.
- [ ] User configuration is not destroyed on decode or migration failure.
