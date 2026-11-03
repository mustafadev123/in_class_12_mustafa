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

## Graduate Investigation 1 — Query Scale

### Hypothesis

I predict that my current design works well for five products but would waste
time, network data, and Firebase reads with 10,000 products. My app listens to
the whole `products` collection and downloads the records before filtering them
on the phone.

### Two approaches

My current approach downloads every product and then checks the name and price
on the phone. This is simple, and it made search feel instant with the five
class records. However, it would download many products that the user may never
view.

For a larger catalogue, I would request only 25 products at a time. I would send
the price conditions to Firebase so it returns fewer records. For a simple name
search, I could store a lowercase version of each name and search from the start
of that value. If the app must find text in the middle of a name, I would use a
service designed for text search while keeping Firebase as the main product
store.

### Numerical model and assumptions

This is a model, not a measured Firebase bill. I assume there are 10,000 products,
100 users open the catalogue, and each user views only the first 25-product page.

```text
Current design: 10,000 reads × 100 users = 1,000,000 document reads
Paged design:       25 reads × 100 users =     2,500 document reads
Difference:                                  997,500 fewer initial reads
```

The exact use can differ because users may load more pages, records may change,
listeners may reconnect, and Firebase may also count work used by a query's
indexes.

### Counterexample and limitation

Paging is not always better. An administrator exporting all 10,000 products may
eventually need every record. My calculation also assumes each person loads only
the first page. I did not create 10,000 billable class records to test this model.

### Recommendation

I recommend keeping the current phone-side filtering for this five-product
assignment. For a real catalogue with 10,000 products, I would use pages of 25,
send price filters to Firebase, and use a text-search service only when true
substring search is required.

Source: [Firebase billing documentation](https://firebase.google.com/docs/firestore/pricing).

## Graduate Investigation 2 — Access Control and Bypass Attempts

### Hypothesis

I predict that hiding an edit or delete button cannot protect Firebase. A person
could avoid my Flutter screen and send a request another way. Firebase must make
the final access decision.

### Two approaches

The weak approach is to depend on the app interface and temporary test-mode
rules. It is easy for a class demonstration, but it does not identify the user
or safely limit what that person may do.

The stronger approach is to require sign-in and check every request in Firebase
rules. In a real product manager, customers would read products, managers would
create and edit them, and only administrators would delete them. The rules would
also check that the name is text and the price is a number of zero or more.

### Observed safe simulation

I tested an unpublished draft in Firebase Rules Playground using Cedar Mug,
document `VbjNqKUMUFEzVuIDt4cx`.

| Request | Test identity | Actual result |
|---|---|---|
| Read Cedar Mug | Authenticated test user | Allowed |
| Read Cedar Mug | Unauthenticated user | Denied |

The screenshots show `Simulated read allowed` and `Simulated read denied`. I
discarded the draft instead of publishing it because this assignment app does
not contain a real sign-in feature. The simulation did not change the product or
test the Flutter error screen.

### Adversarial bypass analysis

My draft used `request.auth != null` for delete. That condition only asks whether
someone is signed in; it does not ask whether the person is an administrator. I
therefore predict that an ordinary signed-in customer could send a delete request
and the draft would allow it. This is a rule review and prediction, not a delete
test I performed against Cedar Mug.

I also designed two additional safe checks for future Rules Playground testing:
a negative price should be denied, and a product containing an unexpected
`isAdmin` field should be denied. I do not label those as observed results because
I did not capture those simulations.

### Counterexample and limitation

Requiring sign-in does not automatically make an app secure. A signed-in user
may still receive too much power if the rules do not check the person's role.
Rules Playground is useful, but two simulations cannot cover every request,
query, or real sign-in path.

### Recommendation

I recommend combining Firebase sign-in with customer, manager, and administrator
roles. Customers should read, managers should create and update, and only
administrators should delete. Firebase rules should validate the allowed fields
and their values. I would test an allow-and-deny table in the local Firebase
testing tools before publishing the rules.

Source: [Firebase Security Rules documentation](https://firebase.google.com/docs/firestore/security/get-started).
