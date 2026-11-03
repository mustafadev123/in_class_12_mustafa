# T1-T8 Screenshot Evidence Index

Use this index when placing images into the Word report. Preserve the distinction
between what an image visibly proves and what was observed during the test.

## Baseline

- `Screenshot_20261102_212719.jpg` — Android app loaded the five baseline
  fixtures from Firestore with numeric prices and visible document IDs.

## T1 — Create and read

- `Screenshot_20261102_212924.jpg` — App displays temporary `T1 Maple Bowl` at
  `$12.50` with ID `ikjQiuiOYIV7Nz1DXqCe`.
- `Screenshot 2026-11-02 212942.png` — Firestore Console displays the same ID,
  name, and numeric price `12.5`.

Result: pass. App and Console identities and values matched.

## T2 — Live update

- `Screenshot 2026-11-02 213112.png` — Console value changed to numeric `14.75`.
- `Screenshot_20261102_213118.jpg` — The already-open app displays `$14.75` for
  the same ID without a manual refresh.

Result: pass. The retained snapshot listener delivered the Console change.

## T3 — Edit and delete by ID

- `Screenshot_20261102_213219.jpg` — App-edited original appears at `$16.25`.
- `Screenshot 2026-11-02 213227.png` — Console confirms `$16.25` on original ID
  `ikjQiuiOYIV7Nz1DXqCe`.
- `Screenshot_20261102_213308.jpg` — Two same-name products are visible with
  distinct IDs: duplicate `c5Kd4z7BOs6Rocdd4Tm0` at `$9.99` and original
  `ikjQiuiOYIV7Nz1DXqCe` at `$16.25`.
- `Screenshot_20261102_213455.jpg` — After cleanup, the baseline five remain;
  snackbar documents deletion of the original temporary ID.
- `Screenshot 2026-11-02 213509.png` — Console shows the restored five-document
  fixture collection.

Observed result: pass. During the test, duplicate ID `c5Kd4z7BOs6Rocdd4Tm0`
was deleted while original ID `ikjQiuiOYIV7Nz1DXqCe` remained. The supplied
screenshots show the two IDs before deletion but do not show the duplicate-ID
deletion snackbar; state that limitation rather than claiming the cleanup image
proves which duplicate was deleted.

## T4 — Case-insensitive search

- `Screenshot_20261102_213524.jpg` — Mixed-case `cEDAR` returns Cedar Mug only.
- `Screenshot_20261102_213533.jpg` — `pinecone` produces the distinct
  `No products found.` state.

Result: pass. Matching is case-insensitive substring matching.

## T5 — Price range and combined filters

- `Screenshot_20261102_213636.jpg` — Inclusive range `[12.50, 20]` returns
  Cedar Mug, Harvest Tea, and amber Candle.
- `Screenshot_20261102_213644.jpg` — Search text `tea` was entered during the
  combined range test, but the keyboard obscures the result. Prefer a retake
  with the keyboard dismissed and Harvest Tea visible.
- `Screenshot_20261102_213706.jpg` — Equal bounds `[12.50, 12.50]` return Cedar
  Mug only.
- `Screenshot_20261102_213719.jpg` — Minimum-only `20` returns amber Candle and
  Wool Scarf.
- `Screenshot_20261102_213734.jpg` — Maximum-only `12.50` returns Autumn Sample
  and Cedar Mug.
- `Screenshot_20261102_213745.jpg` — Reset restores the five fixtures and clears
  all controls.

Observed result: pass for every boundary/combination case. Retake the combined
`tea` image for stronger visual evidence.

## T6 — Validation and cancellation

- `Screenshot_20261102_213923.jpg` — Whitespace-only/empty name is rejected.
- `Screenshot_20261102_213943.jpg` — Empty price is rejected with a finite,
  nonnegative price message.
- `Screenshot_20261102_214029.jpg` — Invalid pasted price is rejected with the
  same validation message.
- `Screenshot_20261102_214119.jpg` — Zero-price product is accepted and displayed
  as `$0.00`, ID `XSC9CAWWAipvfEA7ZUEs`.
- `Screenshot_20261102_214128.jpg` — Snackbar confirms cleanup deletion of the
  temporary zero-price record.

Observed result: pass. Cancel wrote no data, a reopened create form was empty,
invalid/nonfinite/negative values and reversed bounds were rejected, and zero
was accepted. Not every subcase has its own screenshot; record the complete
procedure and actual observations in the T6 table.

## T7 — Offline persistence

- `Screenshot_20261102_214356.jpg` — The five cached fixtures remain displayed,
  including Cedar Mug ID `VbjNqKUMUFEzVuIDt4cx` at `$12.50`.
- `WhatsApp Image 2026-11-02 at 9.50.43 PM.jpeg` — The same five records and IDs
  appear after the test sequence.

Observed result: pass. Products remained visible in-session and after a cold
restart while Wi-Fi and mobile data were disabled; values still matched after
reconnection. Limitation: the screenshots do not visibly prove both Android
network toggles were disabled, and cached visibility alone does not prove server
state or acknowledgement. The app does not display `isFromCache` or
`hasPendingWrites` metadata.

## T8 — Rules Playground

- `Screenshot 2026-11-02 214831.png` — Proposed unpublished authenticated-read
  rule produces `Simulated read allowed`.
- `Screenshot 2026-11-02 214902.png` — Playground inputs/rules context for the
  authenticated simulation.
- `Screenshot 2026-11-02 214927.png` — Unauthenticated request produces
  `Simulated read denied`; the banner also shows the rules are unpublished.

Result: pass as a safe simulation. The draft was discarded, not published.
This does not test Flutter UI failure handling or a real Authentication flow.

## Recommended retakes before submission

1. Combined T5: show min `12.50`, max `20`, search `tea`, keyboard dismissed,
   and Harvest Tea as the only visible result.
2. T7: capture Android Quick Settings with Wi-Fi and mobile data visibly off,
   then the cached app list. If a single screenshot cannot show both, use two
   consecutively labeled images and state the test sequence.
3. Optional T3 strengthening: repeat with temporary duplicate records and capture
   the delete-confirmation dialog showing the selected duplicate document ID,
   followed by the surviving original ID.
