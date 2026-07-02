# Testing

## Current state

The repository has a `ProofIMETests` target using Swift Testing.

- `LiveReplacementControllerTests` intends to verify that `fa` becomes `∀ ` on a boundary.
- `ProofIMETests.example` is an empty generated placeholder.
- The live-replacement test currently calls `processTrigger` without its required `trigger` argument. Based on source inspection, the test target is not expected to compile until that call is updated. This documentation change does not alter product or test code.

Do not interpret the presence of the target as broad behavioral coverage.

## Running tests

From Xcode, select the `ProofIME` scheme and run Product > Test. From the repository root:

```sh
xcodebuild test \
  -project ProofIME.xcodeproj \
  -scheme ProofIME \
  -destination 'platform=macOS' \
  -derivedDataPath /tmp/ProofIME-DerivedData
```

The project requires a compatible local Xcode/macOS SDK. Using `/tmp` avoids writing Derived Data into the repository and can avoid workspace permission problems.

## Manual smoke test

Until automated coverage is stronger:

1. Launch the reference app and type `fa`, then Space. Confirm the editor contains `∀ ` and the cursor follows the space.
2. Type `contra`, then Return. Confirm the bundled contrapositive body is inserted before the newline.
3. Place the cursor in the middle of text and insert a symbol and a template from their reference panels.
4. Compare `fa x inn RR` in Unicode and LaTeX output modes.
5. Search symbols and templates; favorite a template and relaunch to check persistence.
6. Copy output and save both `.txt` and `.tex` files.
7. Import a valid symbol dictionary, reload, and verify both the list and live replacement. Preserve any existing user config before testing deletion.

These steps test only the standalone app. There is no system input method to test yet.

## Priority test backlog

### Processing

- Space, Tab, and Return trigger preservation.
- No match, empty text, cursor at start/end/middle, and out-of-range cursor.
- Template precedence over symbol rules.
- Exact matching, aliases, and descending priority.
- Unicode outputs where Swift character and AppKit UTF-16 offsets differ.
- Punctuation behavior and reconciliation of tokenizer implementations.

### Loading

- Dictionary and rule-array symbol formats.
- Missing, malformed, and duplicate configuration.
- User-file precedence and intended fallback behavior.
- Template decoding, duplicate IDs/triggers, and missing bundle resources.

### UI and future IME

- Insertion requests and selection replacement.
- Mode consistency between editor and preview.
- InputMethodKit composition/client tests once that target exists.
- A recorded host compatibility matrix before any application-support claim.

## Reporting failures

Include the Xcode version, macOS version, destination, failing command, first relevant compiler/test error, and whether a user config file was present. Avoid attaching private proof text or configuration without redaction.
