# In-Class 12 Graduate Report Working Template

Convert the completed report to one Word document. Do not present a prediction,
unit test, or Rules Playground simulation as a measured Android/Firestore result.
Use the course-provided `firebase_evidence_template.txt` as a test-session
checklist; do not submit that TXT in place of this completed Word report.

## Cover and reproducibility

- Student / course / section: `[complete]`
- Course level: **Graduate**
- Platform and Android device/emulator: `[complete]`
- Flutter, Dart, Firebase package, Android, and device versions: `[complete]`
- Firebase project identifier (no secrets): `[complete]`
- Code option and Git commit/version: `[complete]`
- Run steps and unfinished items/limitations: `[complete]`

## Implementation summary

Describe the `products` collection, document IDs, `name`/`price` field types,
CRUD flow, retained snapshot listener, client-side matching policy, validation,
and why this small-dataset design is not suitable for 10,000 products.

## T1–T8 evidence table

For each row, write a prediction before testing, actual result afterward, exact
conditions, relevant document IDs/values, screenshot references, and any change
made before rerunning. Restore exactly the five fixtures before T4/T5.

| Test | Prediction | Exact procedure/conditions | Actual result | Evidence / IDs | Pass, revision, limitation |
|---|---|---|---|---|---|
| T1 Create & read | `[complete before test]` | Unique name at 12.50; compare app/Console | `[observed]` | `[screenshots + ID]` | `[complete]` |
| T2 Live update | `[complete before test]` | Console price edit while app remains open | `[before/after]` | `[screenshots + ID]` | `[complete]` |
| T3 Edit & delete | `[complete before test]` | App edit; duplicate name; delete one by ID | `[observed]` | `[both IDs]` | `[complete]` |
| T4 Search | `[complete before test]` | `cEdAr`; nonexistent name | `[observed]` | `[screenshots]` | `[complete]` |
| T5 Range/combined | `[complete before test]` | 12.50–20; +`tea`; equal; min-only; max-only; Reset | `[counts/names]` | `[screenshots]` | `[complete]` |
| T6 Invalid input | `[complete before test]` | Whitespace, blank/nonnumber/negative/NaN/Infinity, reversed bounds, zero, Cancel | `[observed]` | `[screenshots]` | `[complete]` |
| T7 Offline | `[complete before test]` | Load online; disable actual device networks; reopen offline; reconnect | `[observed]` | `[device controls + ID]` | `[limits]` |
| T8 Rules simulation | `[complete before test]` | One allow and deny in Playground; do not publish draft | `[simulated decisions]` | `[exact path/auth/data]` | `[simulation limits]` |

Expected T5 fixture results: 12.50–20 = Cedar Mug, Harvest Tea, amber
Candle; adding `tea` = Harvest Tea; 12.50–12.50 = Cedar Mug; min 20 =
amber Candle and Wool Scarf; max 12.50 = Autumn Sample and Cedar Mug;
Reset = all five.

## Debugging revision

- Prediction: `[complete before action]`
- What actually happened: `[observed evidence/log]`
- Diagnosis: `[complete]`
- Code/configuration change: `[complete]`
- Rerun result: `[observed evidence]`
- Remaining limitation: `[complete]`

## Q1–Q10

Each response should begin with a prediction, cite a project observation by
test/screenshot/document ID, distinguish observed versus designed behavior, and
cite credible sources. These prompts are reminders, not ready-made answers.

### Q1 — Initialization order

Explain `WidgetsFlutterBinding.ensureInitialized()` before
`Firebase.initializeApp()`. Annotate startup order; report only a controlled
experiment you actually performed, otherwise label the omission outcome a risk.

### Q2 — StreamBuilder versus FutureBuilder

Use T2 to diagram initial read → Console edit → listener event → rebuild. Give a
case where a one-time read is preferable.

### Q3 — NoSQL versus SQL

Compare an actual product document/field type with an earlier SQL row. Design a
category relation both ways; discuss a mobile benefit and integrity tradeoff.

### Q4 — Test mode and access control

State read/create/update/delete roles and authentication assumptions. Reference
T8 allow/deny inputs and explain why hiding a button is not authorization.

### Q5 — Input validation

Use one surprising validation case, its prediction/result/revision, and explain
why Firestore rules must validate independently of the Flutter UI.

### Q6 — 10,000-product catalogue

Compare pagination/limits, Firestore queries/indexes, and a search service under
stated read assumptions. Choose a matching policy and explain how a naive prefix
query changes the current case-insensitive substring requirement.

### Q7 — Listener behavior and cost

Use T2 to discuss latency, reads/billing, bandwidth, server acknowledgement, and
listener lifecycle. Propose and measure a strategy for an all-day screen.

### Q8 — Generated Firebase options

Explain the generated file, identify platform/project without secrets, list two
wrong-project symptoms, and distinguish client configuration from authorization.

### Q9 — Model evolution

Design one optional field with type/default/legacy handling and one malformed
legacy recovery path. Clearly state whether it was implemented.

### Q10 — Offline and local boundaries

Compare T7 with browser `localStorage`, Flutter local storage, and Firestore
cache using platform-specific documentation. State what the screenshot cannot
prove. Design (or actually test and label) a two-device conflicting-price
timeline, including `isFromCache`/`hasPendingWrites` limitations.

## Graduate investigation 1 — `[choose: offline conflict/query scale/access control]`

1. Hypothesis
2. Two plausible approaches and comparison
3. Observed test, safe simulation, or quantitative model with assumptions
4. Counterexample and limitation
5. Justified recommendation and credible sources
6. Explicit list of measured claims versus predictions

## Graduate investigation 2 — `[choose a distinct topic]`

Use the same six-part structure. It must deepen, not duplicate, Q1–Q10.

## Sources, assistance, and limitations

- Cite assignment and official Flutter/Firebase documentation near claims.
- Disclose AI/tool assistance, what suggestions were changed, and what you
  personally verified.
- List incomplete tests and constraints honestly.
- Redact tokens, private keys, personal data, and unrelated account details.

## Final submission check

- [ ] One Word document contains Q1–Q10, T1–T8, screenshots, revision, and two investigations.
- [ ] GitHub URL is accessible or the required main Dart file is attached.
- [ ] Submitted artifact was reopened/tested and LMS receipt was saved.
