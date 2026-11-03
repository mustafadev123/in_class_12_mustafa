# Q1-Q10 Draft Answers

These answers use my Android tests, project code, and screenshots. I label ideas
that I did not build or test as designs or predictions.

## Q1 — Why I initialize Flutter before Firebase

In my `main()` method, I first call
`WidgetsFlutterBinding.ensureInitialized()`. Next, I wait for
`Firebase.initializeApp()`. Only after Firebase is ready do I call `runApp()`.
I use this order because Firebase needs to speak to the Android system before my
first screen starts. The first call makes that connection to the Android system
ready early.

I did not remove this line and claim that the app failed, because I did not run
that experiment. My prediction is that leaving it out could cause a startup
error on some platforms because the app would ask Firebase to use phone services
before Flutter had prepared them. Flutter's own documentation says this call is
needed when work must happen before `runApp()`. My successful Android launch and
the five products appearing show that my chosen startup order worked, but they do
not prove every other order would fail.

Source: [Flutter documentation for `ensureInitialized`](https://api.flutter.dev/flutter/widgets/WidgetsFlutterBinding/ensureInitialized.html).

## Q2 — Live stream versus one-time read

I use a `StreamBuilder` because this screen should stay current while it is open.
In T2, I kept the app open and changed `T1 Maple Bowl`, document
`ikjQiuiOYIV7Nz1DXqCe`, from `$12.50` to `$14.75` in Firebase Console. The phone
showed `$14.75` without a refresh. My observed sequence was:

```text
App opens → first list arrives → Console price changes → new list arrives → screen updates
```

A `FutureBuilder` is better for one answer that I request once. If this screen
had used a one-time read, the `$14.75` change would not have arrived on its own.
The user would have needed to reload the page or press a refresh button. I would
use a one-time read for something such as a report that must show a fixed copy of
the data at the moment the user requested it.

Source: [Firebase documentation for real-time updates](https://firebase.google.com/docs/firestore/query-data/listen).

## Q3 — Firebase documents compared with SQL rows

Firebase is called NoSQL because it stores documents inside collections instead
of storing rows inside fixed tables. My `products` collection contains one
document per product. For example, Cedar Mug has document ID
`VbjNqKUMUFEzVuIDt4cx`, a text `name`, and a numeric `price` of `12.50`.

In my earlier SQL work, I would place the same values in one row of a `products`
table with columns such as `id`, `name`, and `price`. SQL normally expects rows
to follow the table's defined columns. Firebase is more flexible, so an older
document can exist without a new field. That flexibility helps a phone app change
over time, but it also means bad or incomplete documents can exist. My app checks
the name and price when it reads a document and shows an invalid-product warning
instead of silently trusting bad data.

For categories, my Firebase design would store a small category ID such as
`home` in each product and keep category details in a separate `categories`
collection. In SQL, I would store `category_id` and connect it to a category row.
SQL can strongly prevent a product from pointing to a missing category. Firebase
needs careful rules and app checks to provide similar protection.

Source: [Cloud Firestore data model](https://firebase.google.com/docs/firestore/data-model).

## Q4 — Why test mode is unsafe

I used test mode only for this disposable class project. Test mode is unsafe for
a real app because people may be able to read, change, or delete data without
being approved. Hiding the delete button does not protect the database. A person
could skip my screen and send a request directly, so the database must make the
final decision.

My proposed real access plan is:

- A signed-in customer may read products.
- A signed-in manager may create and edit products.
- Only an administrator may delete products.
- Every create or edit must contain a nonempty text name and a number that is
  zero or greater.

I did not add sign-in to this assignment, so this is a design rather than a
finished feature. In T8, I safely tested an unpublished draft in Rules
Playground. An authenticated read was allowed, and the same unauthenticated read
was denied. I then discarded the draft instead of publishing it. This proved how
that draft treated those two example requests; it did not test a real sign-in
screen or the Flutter error screen.

Source: [Firebase Security Rules guide](https://firebase.google.com/docs/firestore/security/get-started).

## Q5 — How I stop invalid input

Before saving, my product form removes extra space from the name and rejects an
empty name. It accepts the price only when it is a real number, is not infinite,
and is zero or greater. My filters use the same kind of checks. Empty price limits
mean no limit, equal limits are allowed, and the minimum cannot be greater than
the maximum.

In T6, I tried a blank name, blank price, letters, a negative number, `NaN`,
`Infinity`, and a backwards range. The app showed clear errors and did not crash.
I also confirmed that zero was valid by creating `T6 Zero Test` at `$0.00`, then
deleting it. Cancel wrote nothing, and opening a new create form showed empty
fields. The nonfinite values were useful because text can sometimes be turned
into a special number even though it should never be a product price. The extra
finite-number check prevented that write.

Form checks improve the experience, but they are not security. A changed app or
a direct request can skip my form. A real release must repeat the name, type, and
price checks in Firebase rules.

## Q6 — What I would change for 10,000 products

My current design listens to the whole `products` collection and then filters on
the phone. This is reasonable for the five class records because it is simple
and makes search instant. It is a poor choice for 10,000 products. The first load
could bring 10,000 documents to the phone even when the user wants one item. That
would waste reads, time, memory, battery, and network data.

For a large catalogue, I would request a small page, such as 25 products, and
load the next page only when needed. I would send exact price limits and simple
ordered filters to Firebase so unwanted products are not downloaded. Under a
simple assumption of 10,000 stored products, my current first load can read about
10,000 documents. A 25-item first page reads about 25 matching documents, plus
any index work Firebase charges for. The exact bill depends on the query and
indexes, so this is a model, not a measured bill from my five-item test.

My current name rule is case-insensitive substring search. A basic Firebase
prefix search would change that rule because it matches the start of a name, not
text in the middle, and case handling also needs a normalized field. If true
substring search is required at this size, I would use a search service designed
for text search and keep Firebase as the main product store. If prefix search is
acceptable, I would store a lowercase search name and use a Firebase query with
pages and limits.

Source: [Firebase billing and listener guidance](https://firebase.google.com/docs/firestore/pricing).

## Q7 — Live updates, cost, and an all-day screen

My app opens one live connection for the product list. T2 showed its benefit:
the `$12.50 → $14.75` Console change appeared on the phone without a refresh.
The phone first had its local view, then it received a later change. That screen
update shows that the app received an event, but a screenshot by itself does not
prove when the server accepted a different device's write.

The live connection improves freshness, but it uses network data and document
reads. Firebase charges document reads when matching documents are added or
updated in a listener. Reconnecting can also cause new reads, especially after a
long offline period. Keeping unnecessary screens listening all day can therefore
use more battery and reads.

For a screen left open all day, I would listen only while the catalogue screen
is visible. I would request only the current page or category instead of every
product. I would measure the Firebase Usage page before and after a controlled
one-hour test, record the number of changes, and compare reads and phone battery
use with a version that refreshes only when the user asks. I did not perform that
all-day measurement, so it is my proposed test.

Sources: [Firebase real-time listener behavior](https://firebase.google.com/docs/firestore/query-data/listen) and [Firebase billing documentation](https://firebase.google.com/docs/firestore/pricing).

## Q8 — What the generated Firebase options file does

I ran FlutterFire configuration for Android. It generated
`lib/firebase_options.dart` and connected package
`com.example.autumn_product_manager` to Firebase project
`autumn-product-manager-mustafa`. My startup code passes those values to
`Firebase.initializeApp()`.

The file tells the app which Firebase project and Android app record to contact.
FlutterFire generates it so I do not have to copy several project values by
hand. The values identify the app and project; they do not grant permission to
read or change data. Firebase rules still decide what a request may do.

If I configured the wrong project, two warning signs would be: the five expected
products would be missing or different, and changes in my intended Console would
not appear in the phone app. I checked the project during configuration and then
saw the same document IDs and values in both places. I do not include private
account information or authorization codes in the report.

Sources: [FlutterFire setup](https://firebase.google.com/docs/flutter/setup) and [Firebase configuration explanation](https://firebase.google.com/docs/projects/learn-more#config-files-objects).

## Q9 — How I would add stock

I would add a `stock` field as a whole number that is zero or greater. New
products would start at zero unless the manager enters another value. Zero would
mean that the product is known but currently unavailable.

This field is not implemented in my submitted app; it is a design. If I added it,
the create and edit form would gain a Stock box, each product card would display
the amount, and the save checks would reject negative or decimal stock. For old
documents that have no `stock`, I would display `Stock not recorded` instead of
pretending the value is zero. This distinction matters because missing data and
an actual stock of zero do not mean the same thing.

For a malformed older document such as `stock: "eight"`, I would keep the
product visible with a warning and disable stock-changing actions until a manager
fixes it. This follows the approach already used in my app: a document with a bad
name or price is shown as invalid instead of being hidden.

## Q10 — Offline use and storage boundaries

Browser `localStorage` keeps simple text for one browser and website. Normal
Flutter local storage keeps data on one phone. Neither one automatically makes
that data available on another device. Firebase keeps the main documents in the
cloud and its Android library also keeps a local copy of data that the app has
already used. Firebase documentation states that Android offline persistence is
enabled by default.

In T7, I first loaded Cedar Mug online at `$12.50`, ID
`VbjNqKUMUFEzVuIDt4cx`. I disabled Wi-Fi and mobile data. The five products
remained visible during that session and after I closed and reopened the app
offline. After reconnecting, the ID and price still matched Firebase Console.
This supports the conclusion that the phone had a saved local copy. It does not
prove that the screen was showing the newest server value while offline. My app
does not display `isFromCache` or `hasPendingWrites`, and the screenshots do not
show those facts. The offline screenshot also does not visibly prove both network
switches were off, so I state the tested steps and that evidence limitation.

My two-device conflict example is a design, not a completed test. I predict this
sequence:

1. Phone A and Phone B both read a price of `$12.50`.
2. Phone A goes offline and changes it to `$13.00`.
3. Phone B stays online and changes it to `$14.00`; the server accepts `$14.00`.
4. Phone A reconnects and sends its pending `$13.00` change.
5. If Phone A's write reaches the server last, the final value may become
   `$13.00` because Firebase documents say repeated changes to one document use
   last-write-wins behavior.

For real inventory or money values, I would avoid silently accepting that result.
I would keep a change time or version, use a controlled server-side update, and
warn the manager when the value changed after the edit screen opened.

Source: [Firebase offline data documentation](https://firebase.google.com/docs/firestore/manage-data/enable-offline).



