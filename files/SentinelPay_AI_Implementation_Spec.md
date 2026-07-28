# SentinelPay AI — Implementation Spec
### SMS Parsing Templates + Behaviour Intelligence (Isolation Forest) Feature Pipeline
**This is the build-ready companion to SRD v2 — hand this directly to the coding agent alongside it.**

---

## Part A — SMS Parsing Engine

### A.1 Design principle

Do NOT use a single mega-regex. Use a **template registry**: an ordered list of `{senderPattern, bodyPattern, extractor}` objects. Each incoming SMS is tested against templates in order; first match wins; no match = discard immediately, never store.

This makes the system:
- Testable (one unit test per template)
- Extensible (add a new bank = add one entry, no core logic changes)
- Debuggable (you always know exactly which template matched, or that none did)

### A.2 Data model for a parsed transaction

```dart
class ParsedTransaction {
  final double amount;
  final TransactionDirection direction; // debit | credit
  final PaymentMethod method;           // upi | card | netbanking | unknown
  final String? payeeIdentifier;        // VPA, merchant name, or masked account
  final DateTime timestamp;             // from SMS metadata if not in body
  final String sourceBank;              // which template matched
  final String matchedTemplateId;       // for debugging/telemetry (never raw text)
}

enum TransactionDirection { debit, credit }
enum PaymentMethod { upi, card, netbanking, unknown }
```

**Critical rule enforced at the type level:** `ParsedTransaction` has no field for raw SMS body. Once extraction happens, the raw string must go out of scope. This isn't just a policy — structure the code so it's structurally impossible to accidentally persist the original text.

### A.3 Template registry — starter set (major Indian banks + UPI apps)

These are based on well-documented, publicly observable SMS alert formats used industry-wide (the same formats every expense-tracker app parses). Treat every regex below as a **starting point your agent must validate against real (test-device) messages** — banks tweak wording periodically, which is why the template library is versioned and updatable (SRD v2, Section 20).

```dart
final List<SmsTemplate> templateRegistry = [

  // --- HDFC Bank — UPI debit ---
  SmsTemplate(
    id: 'hdfc_upi_debit_v1',
    senderPattern: RegExp(r'^(HD|VM|VK|JD)-HDFCBK$|^HDFCBK$', caseSensitive: false),
    bodyPattern: RegExp(
      r'Rs\.?\s?([\d,]+\.?\d*)\s?(?:has been)?\s?debited from account\s?[\*Xx\d]+\s?(?:to|towards)\s?(?:VPA\s?)?([\w.\-@]+)?.*?on\s?([\d\-\/]+)',
      caseSensitive: false,
    ),
    extractor: (match, sms) => ParsedTransaction(
      amount: parseAmount(match.group(1)!),
      direction: TransactionDirection.debit,
      method: PaymentMethod.upi,
      payeeIdentifier: match.group(2),
      timestamp: sms.timestamp, // fallback to SMS metadata timestamp
      sourceBank: 'HDFC',
      matchedTemplateId: 'hdfc_upi_debit_v1',
    ),
  ),

  // --- SBI — UPI debit ---
  SmsTemplate(
    id: 'sbi_upi_debit_v1',
    senderPattern: RegExp(r'^(SB|CP|VM|VK)-SBIUPI$|^SBIUPI$|^SBIINB$', caseSensitive: false),
    bodyPattern: RegExp(
      r'(?:Dear\s?(?:UPI\s?)?[Cc]ustomer,?\s?)?(?:Ac\s?[Xx\*\d]+\s?)?debited (?:by|for)?\s?(?:Rs\.?)?\s?([\d,]+\.?\d*)\s?.*?(?:trf to|to)\s?([\w.\-@ ]+?)(?:\s?on|\s?Ref)',
      caseSensitive: false,
    ),
    extractor: (match, sms) => ParsedTransaction(
      amount: parseAmount(match.group(1)!),
      direction: TransactionDirection.debit,
      method: PaymentMethod.upi,
      payeeIdentifier: match.group(2)?.trim(),
      timestamp: sms.timestamp,
      sourceBank: 'SBI',
      matchedTemplateId: 'sbi_upi_debit_v1',
    ),
  ),

  // --- ICICI Bank — UPI debit ---
  SmsTemplate(
    id: 'icici_upi_debit_v1',
    senderPattern: RegExp(r'^(IC|AD|VM|VK)-ICICIB$|^ICICIB$|^ICICIT$', caseSensitive: false),
    bodyPattern: RegExp(
      r'ICICI Bank Acct\s?[Xx\d]+\s?debited with\s?Rs\.?\s?([\d,]+\.?\d*)\s?on\s?[\d\-]+;\s?([\w.\-@ ]+?)\s?credited',
      caseSensitive: false,
    ),
    extractor: (match, sms) => ParsedTransaction(
      amount: parseAmount(match.group(1)!),
      direction: TransactionDirection.debit,
      method: PaymentMethod.upi,
      payeeIdentifier: match.group(2)?.trim(),
      timestamp: sms.timestamp,
      sourceBank: 'ICICI',
      matchedTemplateId: 'icici_upi_debit_v1',
    ),
  ),

  // --- Axis Bank — UPI debit ---
  SmsTemplate(
    id: 'axis_upi_debit_v1',
    senderPattern: RegExp(r'^(AD|AX|VM|VK)-AXISBK$|^AXISBK$', caseSensitive: false),
    bodyPattern: RegExp(
      r'INR\s?([\d,]+\.?\d*)\s?debited.*?A/c no\.?\s?[Xx\d]+.*?(?:to|towards|UPI/)([\w.\-@ ]+?)(?:\s?on|\.)',
      caseSensitive: false,
    ),
    extractor: (match, sms) => ParsedTransaction(
      amount: parseAmount(match.group(1)!),
      direction: TransactionDirection.debit,
      method: PaymentMethod.upi,
      payeeIdentifier: match.group(2)?.trim(),
      timestamp: sms.timestamp,
      sourceBank: 'Axis',
      matchedTemplateId: 'axis_upi_debit_v1',
    ),
  ),

  // --- Generic UPI credit (money received — any bank) ---
  SmsTemplate(
    id: 'generic_upi_credit_v1',
    senderPattern: RegExp(r'.*BK$|.*UPI$', caseSensitive: false), // broad net; body pattern narrows it
    bodyPattern: RegExp(
      r'(?:credited with|credited)\s?(?:Rs\.?|INR)\s?([\d,]+\.?\d*).*?(?:from|by)\s?([\w.\-@ ]+?)(?:\s?on|\.)',
      caseSensitive: false,
    ),
    extractor: (match, sms) => ParsedTransaction(
      amount: parseAmount(match.group(1)!),
      direction: TransactionDirection.credit,
      method: PaymentMethod.upi,
      payeeIdentifier: match.group(2)?.trim(),
      timestamp: sms.timestamp,
      sourceBank: 'Generic',
      matchedTemplateId: 'generic_upi_credit_v1',
    ),
  ),

  // --- Generic card transaction (debit/credit card spend) ---
  SmsTemplate(
    id: 'generic_card_debit_v1',
    senderPattern: RegExp(r'.*BK$|.*BNK$', caseSensitive: false),
    bodyPattern: RegExp(
      r'(?:card|Card)\s?(?:ending|no\.?)?\s?[Xx\d]+\s?.*?(?:used for|spent|debited)\s?(?:Rs\.?|INR)\s?([\d,]+\.?\d*)\s?at\s?([\w.\-@ ]+?)(?:\s?on|\.)',
      caseSensitive: false,
    ),
    extractor: (match, sms) => ParsedTransaction(
      amount: parseAmount(match.group(1)!),
      direction: TransactionDirection.debit,
      method: PaymentMethod.card,
      payeeIdentifier: match.group(2)?.trim(),
      timestamp: sms.timestamp,
      sourceBank: 'Generic',
      matchedTemplateId: 'generic_card_debit_v1',
    ),
  ),
];
```

### A.4 Amount parsing helper

```dart
double parseAmount(String raw) {
  // Strip commas, currency symbols, stray whitespace
  final cleaned = raw.replaceAll(',', '').replaceAll(RegExp(r'[^\d.]'), '');
  return double.tryParse(cleaned) ?? 0.0;
}
```

### A.5 Parsing pipeline (the actual function your agent wires up)

```dart
ParsedTransaction? tryParseSms(SmsMessage sms) {
  for (final template in templateRegistry) {
    if (!template.senderPattern.hasMatch(sms.sender)) continue;
    final match = template.bodyPattern.firstMatch(sms.body);
    if (match == null) continue;
    try {
      final result = template.extractor(match, sms);
      // sms.body / sms object goes out of scope here — never stored beyond this point
      return result;
    } catch (_) {
      continue; // malformed match, try next template rather than throwing
    }
  }
  return null; // no template matched — discard sms entirely, log nothing but a counter
}
```

### A.6 First-run bulk parse (bootstrap job)

```dart
Future<int> bootstrapFromSmsHistory() async {
  final messages = await SmsQuery().querySms(
    kinds: [SmsQueryKind.inbox],
    count: 5000, // cap the read to a reasonable ceiling
  );

  int matched = 0;
  int ignored = 0;

  for (final sms in messages) {
    final parsed = tryParseSms(sms);
    if (parsed != null) {
      await localDb.insertTransaction(parsed, source: 'sms_historical');
      matched++;
    } else {
      ignored++; // increment counter only — never store the message
    }
    // sms falls out of scope naturally per iteration
  }

  await localDb.logParseSummary(matched: matched, ignored: ignored); // metadata only
  return matched;
}
```

**Agent note:** Run this inside an isolate (Dart `compute()` or a background isolate), not on the UI thread — with a few thousand messages this must not block the Historical Parse Progress screen from rendering smoothly.

### A.7 Test fixture format (for CI, per SRD v2 Section 31)

```dart
final testFixtures = [
  TestFixture(
    templateId: 'hdfc_upi_debit_v1',
    sampleBody: 'Rs.500.00 debited from account XX1234 to VPA merchant@okaxis on 12-06-26',
    expectedAmount: 500.00,
    expectedDirection: TransactionDirection.debit,
    expectedPayee: 'merchant@okaxis',
  ),
  // ... one fixture minimum per template, more for edge cases (missing fields, odd spacing)
];
```

---

## Part B — Behaviour Intelligence: Isolation Forest Feature Pipeline

### B.1 Why Isolation Forest, mechanically

Isolation Forest isolates anomalies by randomly partitioning the feature space — points that are "different" get isolated in fewer splits than normal points. No labeled fraud data required (you don't have any), works on small datasets (~200 rows is fine), and is cheap enough to train on-device in well under a second.

**On-device library choice:** since Flutter/Dart has no mature native Isolation Forest package, the pragmatic path is:
- Implement a lightweight Isolation Forest directly in Dart (it's a genuinely simple algorithm — a few hundred lines), **or**
- Use `tflite_flutter` with a pre-structured anomaly-detection model exported from a Python-trained equivalent, retrained on-device via a small custom training loop.

**Recommendation for MVP: implement Isolation Forest natively in Dart.** It avoids a TFLite dependency, keeps the whole pipeline auditable in one language, and 200-row training runs are fast enough that a pure-Dart implementation is not a performance risk.

### B.2 Feature vector — exact fields per transaction

Every transaction (SMS-derived or live) is converted into this fixed-length numeric vector before being fed to the model:

```dart
class TransactionFeatureVector {
  final double amountNormalized;       // amount / user's rolling mean amount
  final double amountZScore;           // (amount - mean) / stddev, over rolling window
  final int hourOfDay;                 // 0-23
  final int dayOfWeek;                 // 0-6
  final double payeeFrequency;         // count of prior txns to this payee / window size
  final double daysSinceLastToPayee;   // capped at e.g. 365 if never seen before
  final int isKnownPayee;              // 0 or 1 (seen 3+ times before)
  final double velocityLastHour;       // count of txns in the last 60 minutes
  final double velocityLast24h;        // count of txns in the last 24 hours
  final int methodEncoded;             // 0=upi, 1=card, 2=netbanking, 3=unknown

  List<double> toVector() => [
    amountNormalized,
    amountZScore,
    hourOfDay.toDouble(),
    dayOfWeek.toDouble(),
    payeeFrequency,
    daysSinceLastToPayee,
    isKnownPayee.toDouble(),
    velocityLastHour,
    velocityLast24h,
    methodEncoded.toDouble(),
  ];
}
```

### B.3 Feature computation (from the rolling 200-transaction window)

```dart
TransactionFeatureVector computeFeatures(
  ParsedTransaction txn,
  List<ParsedTransaction> rollingWindow, // most recent 200, chronologically ordered
) {
  final amounts = rollingWindow.map((t) => t.amount).toList();
  final mean = amounts.isEmpty ? txn.amount : amounts.reduce((a, b) => a + b) / amounts.length;
  final variance = amounts.isEmpty
      ? 1.0
      : amounts.map((a) => pow(a - mean, 2)).reduce((a, b) => a + b) / amounts.length;
  final stddev = sqrt(variance) == 0 ? 1.0 : sqrt(variance); // avoid div-by-zero

  final payeeTxns = rollingWindow
      .where((t) => t.payeeIdentifier == txn.payeeIdentifier)
      .toList();

  final lastToPayee = payeeTxns.isEmpty
      ? null
      : payeeTxns.map((t) => t.timestamp).reduce((a, b) => a.isAfter(b) ? a : b);

  final hourAgo = txn.timestamp.subtract(Duration(hours: 1));
  final dayAgo = txn.timestamp.subtract(Duration(hours: 24));

  return TransactionFeatureVector(
    amountNormalized: mean == 0 ? 1.0 : txn.amount / mean,
    amountZScore: (txn.amount - mean) / stddev,
    hourOfDay: txn.timestamp.hour,
    dayOfWeek: txn.timestamp.weekday,
    payeeFrequency: rollingWindow.isEmpty ? 0.0 : payeeTxns.length / rollingWindow.length,
    daysSinceLastToPayee: lastToPayee == null
        ? 365.0
        : txn.timestamp.difference(lastToPayee).inDays.toDouble().clamp(0, 365),
    isKnownPayee: payeeTxns.length >= 3 ? 1 : 0,
    velocityLastHour: rollingWindow.where((t) => t.timestamp.isAfter(hourAgo)).length.toDouble(),
    velocityLast24h: rollingWindow.where((t) => t.timestamp.isAfter(dayAgo)).length.toDouble(),
    methodEncoded: encodeMethod(txn.method),
  );
}

int encodeMethod(PaymentMethod m) {
  switch (m) {
    case PaymentMethod.upi: return 0;
    case PaymentMethod.card: return 1;
    case PaymentMethod.netbanking: return 2;
    case PaymentMethod.unknown: return 3;
  }
}
```

### B.4 Isolation Forest — core structure (native Dart, MVP-sized)

```dart
class IsolationTree {
  IsolationTree? left;
  IsolationTree? right;
  int? splitFeatureIndex;
  double? splitValue;
  int size = 0; // number of points at this node (for leaf depth estimation)

  static IsolationTree build(List<List<double>> data, int depth, int maxDepth) {
    final node = IsolationTree();
    node.size = data.length;
    if (depth >= maxDepth || data.length <= 1) return node;

    final featureIndex = Random().nextInt(data[0].length);
    final values = data.map((row) => row[featureIndex]).toList();
    final minV = values.reduce(min);
    final maxV = values.reduce(max);
    if (minV == maxV) return node; // no split possible, treat as leaf

    final splitValue = minV + Random().nextDouble() * (maxV - minV);
    final leftData = data.where((row) => row[featureIndex] < splitValue).toList();
    final rightData = data.where((row) => row[featureIndex] >= splitValue).toList();

    node.splitFeatureIndex = featureIndex;
    node.splitValue = splitValue;
    node.left = build(leftData, depth + 1, maxDepth);
    node.right = build(rightData, depth + 1, maxDepth);
    return node;
  }

  double pathLength(List<double> point, int depth) {
    if (splitFeatureIndex == null) return depth + _c(size);
    if (point[splitFeatureIndex!] < splitValue!) {
      return left!.pathLength(point, depth + 1);
    } else {
      return right!.pathLength(point, depth + 1);
    }
  }

  static double _c(int n) {
    if (n <= 1) return 0;
    return 2 * (log(n - 1) + 0.5772156649) - (2 * (n - 1) / n); // avg path length normalizer
  }
}

class IsolationForest {
  final List<IsolationTree> trees = [];
  final int numTrees;
  final int sampleSize;

  IsolationForest({this.numTrees = 100, this.sampleSize = 128});

  void train(List<List<double>> data) {
    trees.clear();
    final maxDepth = (log(sampleSize) / log(2)).ceil();
    for (int i = 0; i < numTrees; i++) {
      final sample = _subsample(data, sampleSize);
      trees.add(IsolationTree.build(sample, 0, maxDepth));
    }
  }

  double anomalyScore(List<double> point) {
    final avgPathLength = trees.map((t) => t.pathLength(point, 0)).reduce((a, b) => a + b) / trees.length;
    final cN = IsolationTree._c(sampleSize);
    // Standard Isolation Forest score: closer to 1 = more anomalous, closer to 0.5 = normal
    return pow(2, -avgPathLength / cN).toDouble();
  }

  List<List<double>> _subsample(List<List<double>> data, int n) {
    if (data.length <= n) return data;
    final shuffled = List.of(data)..shuffle();
    return shuffled.sublist(0, n);
  }
}
```

**Tuning notes for the agent:**
- `numTrees: 100` and `sampleSize: 128` (or `min(128, dataset.length)`) are standard defaults from the original Isolation Forest paper — don't over-engineer this for MVP.
- Training 100 trees on <=200 rows with 10 features is on the order of milliseconds on a modern phone — no need for isolates for training itself, though the SMS bootstrap parse (Part A.6) still should use one.
- Anomaly score output is in `(0, 1)`; conventionally, scores **above ~0.6** are treated as anomalous, but this threshold must be tuned against your own test scenarios (Section B.6) rather than trusted blindly out of the box.

### B.5 Wiring the score into the Risk Fusion Engine

```dart
class BehaviourIntelligenceResult {
  final double anomalyScore;       // 0.0 - 1.0
  final bool sufficientData;       // false if rollingWindow.length < 15
  final List<String> evidenceKeys; // e.g. ['unusual_amount', 'new_payee', 'off_hours']
}

BehaviourIntelligenceResult scoreBehaviour(
  ParsedTransaction candidate,
  List<ParsedTransaction> rollingWindow,
  IsolationForest model,
) {
  if (rollingWindow.length < 15) {
    return BehaviourIntelligenceResult(
      anomalyScore: 0.5, // neutral — Confidence Engine must treat this as low-confidence, not "safe"
      sufficientData: false,
      evidenceKeys: ['insufficient_history'],
    );
  }

  final features = computeFeatures(candidate, rollingWindow);
  final score = model.anomalyScore(features.toVector());

  final evidence = <String>[];
  if (features.amountZScore.abs() > 2.0) evidence.add('unusual_amount');
  if (features.isKnownPayee == 0) evidence.add('new_payee');
  if (features.velocityLast24h > 10) evidence.add('high_velocity');

  return BehaviourIntelligenceResult(
    anomalyScore: score,
    sufficientData: true,
    evidenceKeys: evidence,
  );
}
```

Each `evidenceKey` maps directly to an Explainability Engine template (SRD v2, Section 23) — e.g., `'new_payee'` maps to *"You haven't paid this person before."* Never surface the raw anomaly score to the user directly; it always routes through this evidence-key to plain-language template mapping.

### B.6 Retraining trigger (wire into app lifecycle)

```dart
Future<void> maybeRetrainModel() async {
  final txnsSinceLastTrain = await localDb.countTransactionsSince(behaviourProfile.lastTrainedAt);
  final hoursSinceLastTrain = DateTime.now().difference(behaviourProfile.lastTrainedAt).inHours;

  if (txnsSinceLastTrain >= 10 || hoursSinceLastTrain >= 24) {
    final window = await localDb.getRollingWindow(limit: 200);
    final vectors = window.map((t) => computeFeatures(t, window).toVector()).toList();
    final forest = IsolationForest();
    forest.train(vectors);
    await modelStore.save(forest); // local serialization, never network-bound
    await localDb.updateBehaviourProfile(lastTrainedAt: DateTime.now(), sampleCount: window.length);
  }
}
```

Call this after every successful transaction save (both SMS-bootstrap and live), and once at app foreground if the time-based trigger has elapsed.

---

## Part C — What your agent should build first, in exact order

1. `ParsedTransaction` model + local SQLite schema (SRD v2, Section 25).
2. Template registry (Part A.3) with **3-4 templates minimum** (start with your own bank + one or two others you can test against real SMS on a dev device) — don't try to cover every bank on day one; expand iteratively.
3. `tryParseSms` + bulk bootstrap job (A.5-A.6), wired to the SMS Permission Explainer -> Historical Parse Progress screens.
4. Feature vector computation (B.3).
5. Native Isolation Forest (B.4) — this is self-contained and can be unit-tested completely independently of the rest of the app before wiring it in.
6. `scoreBehaviour` (B.5) wired into the existing Risk Fusion Engine alongside deterministic/statistical layers.
7. Retrain trigger (B.6) wired into the transaction-save lifecycle.
8. Only then: QR scan -> verdict screen -> Android Intent handoff (already specced in SRD v2, Sections 10, 19).

**Validation gate before moving past step 3:** manually verify parsed output against at least 20 real SMS messages on a real test device from your own bank. Regex-based parsing looks correct in isolation and then fails silently against real-world formatting quirks (extra whitespace, unicode currency symbols, slightly different date formats) — this is the single most likely source of "the model has no data" bugs downstream.
