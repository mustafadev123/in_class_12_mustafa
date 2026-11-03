# Autumn Product Manager — In-Class 12

Graduate Flutter/Cloud Firestore product catalogue for In-Class 12. The app uses
the `products` collection and requires each core document to contain:

- `name`: trimmed, nonempty string
- `price`: finite, nonnegative Firestore number (zero is valid)

## Implemented

- Create, live read, update, and delete by Firestore document ID
- Awaited writes with visible failure handling and deletion confirmation
- One retained snapshot stream for real-time changes
- Case-insensitive substring search as the user types
- Optional inclusive minimum/maximum price bounds, combined with search
- Reset, input validation, loading, empty, no-match, malformed-data, and error UI
- Unit tests for the five assignment fixtures and filter boundary cases

Client-side filtering is intentional for the five-record class dataset. It is
not the proposed architecture for a large catalogue; discuss that tradeoff in
Q6 and the graduate query-scale investigation if selected.

## Firebase setup (student checkpoint)

1. Create a disposable Firebase project and a **Standard edition**, default
   Cloud Firestore database. Use only fictional class data.
2. Add a collection named `products` and the five records in
   [`fixtures/autumn_products.csv`](fixtures/autumn_products.csv). Enter the
   rows manually; the CSV is not an automatic Firestore import.
3. From this project directory, run:

   ```powershell
   dart pub global activate flutterfire_cli
   firebase login
   flutterfire configure --platforms=android
   flutter pub get
   flutter run
   ```

   On Windows, use `flutterfire.bat` or `firebase.cmd` if PowerShell script
   policy blocks the wrapper scripts.
4. Confirm that FlutterFire replaced the placeholder
   `lib/firebase_options.dart` with options for **your** Firebase project.
5. Run on an Android emulator/device. Do not copy another student's generated
   configuration and do not commit service-account keys, tokens, or signing
   credentials.

The temporary `firebase_options.dart` lets static analysis and unit tests run,
but deliberately stops app startup until step 3 is completed.

## Verification

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Use [`REPORT_TEMPLATE.md`](REPORT_TEMPLATE.md) together with the course-provided
`firebase_evidence_template.txt` while running T1–T8. Replace every placeholder
with your own observation, IDs, screenshots, versions, sources, and limitations.
The TXT is a planner, not the required Word submission. A unit-test pass does
not prove that Firebase or an Android device works.

## Submission

Submit one Word report plus either an accessible GitHub URL or `main.dart`, as
specified by the assignment. If using a repository, identify the submitted
commit. Reopen the LMS submission and save its receipt.
