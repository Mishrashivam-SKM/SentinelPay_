# SentinelPay AI — Software Requirements Document (v2)
### *Your Personal UPI Safety Copilot*
**Version 2.0 — ML-First MVP, SMS-Bootstrapped, Fully On-Device**

---

## 0. What Changed from v1 (read this first)

This version reflects one strategic pivot: **the ML model ships as part of MVP, not as a Phase 2 add-on.**

The reason this is now possible: instead of waiting for the user to complete 15–20 *live* transactions inside SentinelPay before the model has anything to learn from (the cold-start problem in v1), the app bootstraps its training data on first run by **reading the user's existing SMS inbox**, extracting historical bank/UPI transaction messages (which every bank and UPI app already sends), parsing them into structured transactions, and training the local model on that history immediately — before the user has ever made a single payment through SentinelPay.

Everything else about the "no cloud, no data leaves the device" promise is unchanged and, if anything, more load-bearing now: SMS content is sensitive, so it must never leave the device, never be transmitted, and never be logged remotely, under any circumstance.

**MVP is now:** SMS permission → parse transaction history → build local dataset → train local ML model → Scan/Pay flow scores every new payment using that model from day one.

---

## 1. Executive Summary

SentinelPay AI is an on-device, pre-authorization fraud intelligence layer for UPI payments. It is not a payment app, wallet, or bank — it sits before the payment, scores risk using a locally trained ML model, explains the verdict in plain language, and hands off to the user's installed UPI app via Android Intents.

The core innovation in this version: SentinelPay solves the cold-start problem by parsing the user's **existing SMS transaction history** on first run to build an initial local dataset, so the ML model is trained and active from the very first scan — not after weeks of usage. All parsing, storage, and training happen on-device. SMS content is never transmitted anywhere, in any form, at any time.

**Acceptance criteria:** A first-time user with a normal SMS history of bank/UPI alerts should have a working, non-empty behavior model within seconds of granting SMS permission, before making their first SentinelPay-mediated payment.

---

## 2. Vision

Unchanged from v1: SentinelPay becomes the default trust layer for UPI payments, eventually licensed to banks/fintechs as an SDK. What changes here is *time to value* — v1 required weeks of live usage to feel personalized; v2 feels personalized on day one because it already knows the user's real payment history from SMS.

---

## 3. Product Strategy

- **Wedge:** Same as v1 — "tell me if this specific payment is safe."
- **New differentiator:** Instant personalization from day one, because the model isn't starting from zero. This is a meaningfully stronger first-run experience and should be a headline feature in onboarding copy, not a buried technical detail.
- **Non-goals (explicit, expanded):** SentinelPay will not transmit SMS content anywhere, will not use SMS data for anything other than local transaction-pattern feature extraction, will not read non-transactional SMS content (OTPs, personal messages) into any stored dataset, and will not retain raw SMS text longer than needed to extract structured fields.

---

## 4. Problem Statement

Same core problem as v1 (UPI fraud exploits the speed-over-judgment gap at payment time), plus one added problem this version solves: **fraud-prevention tools that require weeks of "learning the user" before they're useful lose the user's trust and attention in the meantime.** SMS-bootstrapped training closes that gap.

---

## 5. Market Opportunity

Unchanged from v1 — still needs a real data/citation pass before external use. Note for this version: SMS-based transaction parsing is a proven pattern already used by mainstream Indian expense-tracking apps (e.g., apps that auto-categorize spending from bank SMS), which is useful precedent to cite for both market validation and Play Store approval reasoning.

---

## 6. Competitive Analysis

Same structure as v1, with one addition to the table:

| Category | Example type | Strength | Gap SentinelPay exploits |
|---|---|---|---|
| SMS-based expense trackers | Auto-categorize spend from bank SMS | Good at parsing, zero fraud focus | Purely retrospective, no pre-payment risk scoring |

SentinelPay is the only category combining SMS-based historical parsing **with** pre-payment fraud scoring, rather than doing one or the other.

---

## 7. User Personas

Unchanged (Ananya, Rajesh, Meena, parent-monitoring persona) — see v1 Section 7. One addition: **all four personas must be comfortable granting SMS permission.** For Meena's persona especially, the SMS-permission ask must be explained in one plain sentence with a concrete example ("We'll read your bank's payment alerts, like 'Rs 500 debited to XYZ', to learn your normal spending pattern — nothing else, and it never leaves your phone.").

---

## 8. Jobs To Be Done

Same as v1, plus:
- "When I install this app, I don't want to start from zero — use what my bank already tells me about my spending to protect me immediately."

---

## 9. User Stories

- As a new user, I want SentinelPay to understand my normal payment behavior from my SMS history immediately, so I don't have to "train" the app manually over weeks.
- As a privacy-conscious user, I want to see exactly which SMS messages were used and what data was extracted from them, so I can verify nothing unexpected was read.
- As a user, I want to revoke SMS permission at any time and have the app fall back gracefully to rule-based scoring only.
- As a security-minded user, I want confirmation that my SMS content itself (not just derived transaction data) is deleted after parsing, if I choose that setting.

**Acceptance criteria:** Revoking SMS permission mid-use must not crash the app; it must fall back to deterministic + statistical scoring (per v1 Sections 15–16) with a clear in-app notice that behavior-model quality has been reduced.

---

## 10. Complete User Journey

1. **Launch** → Splash.
2. **Onboarding** → Explains: what SentinelPay is, what it isn't, and the SMS-permission ask with a concrete plain-language example (see Section 7).
3. **SMS Permission Request** → Native Android permission dialog, triggered only after the in-app explanation screen (never a cold OS-level prompt with no context).
4. **Historical SMS Parse (first-run only)** → On-device background job scans SMS inbox for bank/UPI transaction patterns, extracts structured transactions, discards non-matching messages immediately (never stored).
5. **Local Dataset Built** → Structured transaction table populated (payee/merchant where derivable, amount, timestamp, payment method).
6. **Model Trained** → Isolation Forest (or chosen model) trained on this dataset, on-device, before the user has made a single live payment.
7. **Mode Choice** → Demo Mode or Protect My Payments, same as v1.
8. **QR Scan** → Same mechanism as v1 (`upi://` URL parsing).
9. **AI Fraud Analysis** → Now includes the trained behavior model's anomaly score from step 6, alongside deterministic/statistical layers — active from the very first scan.
10. **Risk Explanation** → Plain-language verdict, now able to say things like *"This amount is unusual compared to your typical UPI payments"* even on a brand-new payee, because the model already has real history.
11. **Continue Securely → Android Intent handoff** → Same as v1.
12. **Return / Self-report outcome** → Same as v1.
13. **Transaction stored locally, model incrementally updated** → New live transactions are added to the same rolling dataset used for training (see Section 21).

---

## 11. Information Architecture

Same as v1, with one addition under Settings:

```
Settings
├── Privacy & Data
│   ├── SMS Access (view what's read, revoke permission)
│   ├── View Parsed Transaction History
│   ├── Export/Delete All Data
│   └── Delete Raw SMS Cache (if retained temporarily)
```

---

## 12. Navigation

Unchanged from v1.

---

## 13. Screen Inventory

All 22 screens from v1, plus:

23. SMS Permission Explainer (pre-permission-prompt context screen)
24. Historical Parse Progress (first-run only, shows "Learning your payment patterns…")
25. Parsed Transaction Review (optional — lets user see/edit what was extracted before it's used for training)
26. SMS Access Settings (view/revoke)

---

## 14. Screen Specifications

**SMS Permission Explainer (23):** Must state, in one sentence each: (a) what will be read, (b) what won't be read, (c) that nothing leaves the device, (d) that permission can be revoked anytime. No legal jargon on this screen — plain language only, legal detail lives in the full privacy policy.

**Historical Parse Progress (24):** Must show real progress (e.g., "Found 47 payment messages, analyzing patterns…"), not a fake spinner — same principle as the v1 "Analyzing" screen (Section 18), extended to the first-run bootstrap.

**Parsed Transaction Review (25):** Optional but strongly recommended — shows the user a sample of what was extracted (e.g., "Amazon — ₹1,240 — 12 Jun") so they can sanity-check the parser and build trust in what the app "knows" about them, rather than it being invisible.

---

## 15. Functional Requirements

All FR1–FR10 from v1 remain, plus:

- FR11: The system must request SMS read permission with a preceding in-app explanation screen, never a bare OS prompt.
- FR12: The system must parse SMS content on-device using local pattern matching (regex/heuristics) to identify bank and UPI transaction alerts, extracting: amount, transaction type (debit/credit), payment method (UPI/card/net-banking, where derivable from sender/keywords), merchant/payee name (where present), and timestamp.
- FR13: The system must immediately discard any SMS content that does not match a recognized transaction pattern — non-transactional messages must never be stored, logged, or retained in any form.
- FR14: The system must never transmit raw SMS content or parsed transaction data off-device, under any configuration, including crash reporting or diagnostics.
- FR15: The system must allow the user to view a summary of parsed historical transactions before they're used for model training.
- FR16: The system must allow the user to revoke SMS permission at any time, after which the app must fall back to deterministic + statistical scoring only, without crashing or requiring reinstall.
- FR17: The system must train the local ML model using both SMS-derived historical transactions and live in-app transactions, treating them as the same underlying dataset.
- FR18: The system must allow the user to delete the raw SMS-derived dataset independently of deleting live SentinelPay transaction history.

---

## 16. Non-Functional Requirements

All from v1, plus:

- **Performance:** Historical SMS parse + initial model training must complete in under 30 seconds on a mid-tier Android device for a typical inbox size (hundreds to low thousands of messages), running as a background/async task with visible progress — never blocking the UI thread.
- **Privacy (elevated from v1):** SMS content parsing must happen entirely in-memory or in a local encrypted store; under no circumstance may raw SMS text be included in logs, crash reports, or any network-bound payload — this is now the single highest-priority NFR in the product, given the sensitivity of SMS access.
- **Compliance:** The app must comply with Google Play's SMS/Call Log Permissions policy, which restricts this permission to a narrow set of approved use cases and requires a Permissions Declaration Form — this is a launch-blocking dependency, not a post-launch item (see Section 27, Risks).

---

## 17–18. Design System & Motion Guidelines

Unchanged from v1, with one addition: the Historical Parse Progress screen (13.24) should use the same "real progress, not decorative spinner" motion principle already established for the Analyzing screen — extend the existing pattern rather than invent a new one.

---

## 19. AI Architecture

Updated pipeline — SMS Intelligence is now a **feature-engineering input source**, not a separate scoring layer:

```
SMS Ingestion (permission-gated, on-device only)
   ↓
SMS Parsing → Structured Transaction Extraction
   ↓
Feature Engineering  ←──────────────┐
   ↓                                │
QR Intelligence                     │  (live transactions feed back
   ↓                                │   into the same feature store)
Deterministic Intelligence          │
   ↓                                │
Statistical Intelligence            │
   ↓                                │
Device Intelligence                 │
   ↓                                │
Community Intelligence              │
   ↓                                │
Behaviour Intelligence (ML) ────────┘
   ↓
Risk Fusion Engine
   ↓
Confidence Engine
   ↓
Evidence Engine
   ↓
Explainability Engine
   ↓
Recommendation Engine
   ↓
Final Risk Assessment
```

**Rationale:** SMS parsing is not itself a "fraud signal" — it's the data-sourcing mechanism that makes Behaviour Intelligence usable from day one instead of week three. Keeping it architecturally separate (an ingestion source feeding the same Feature Engineering stage as live transactions) means the rest of the pipeline from v1 is untouched — the fusion, confidence, and explainability logic doesn't need to know or care whether a given transaction came from SMS history or a live SentinelPay-mediated payment.

---

## 20. Fraud Intelligence Architecture — SMS Parsing Detail

**Parsing approach (on-device, no cloud NLP):**
- Pattern-match against known bank/UPI SMS sender IDs and message templates (banks use fairly consistent formats, e.g., `"Rs 500.00 debited from A/c ...XXXX on 12-Jun-26 to VPA merchant@bank. Ref No 123456"`).
- Extract via regex/rule-based parsing: amount, debit/credit direction, VPA or account reference, date, and a coarse "payment method" bucket (UPI vs. card vs. net-banking vs. cash-adjacent), inferred from keywords and sender patterns.
- Messages that don't match any known bank/UPI template are ignored and never stored — this includes OTPs, promotional SMS, and personal messages.
- Maintain a local, updatable library of bank SMS templates/sender IDs (ships with the app, can be updated via app updates — not a live cloud lookup) so new banks/formats can be supported over time without requiring any network call at parse time.

**Trade-off:** Rule-based SMS parsing will not achieve 100% extraction accuracy across every bank's SMS format variations — this is accepted at MVP, with the Parsed Transaction Review screen (13.25) acting as a transparency/trust mechanism rather than a data-quality guarantee. Missed or misparsed messages simply mean less training data, not incorrect verdicts.

---

## 21. Behaviour Intelligence

**Model:** Isolation Forest, chosen from MVP (not phased in later, per this version's directive) — it's lightweight, unsupervised, and well suited to a mixed-feature tabular dataset with no labeled fraud examples, which is exactly what both SMS-derived and live transaction data look like.

**Training data pipeline:**
1. First run: SMS-derived historical transactions populate the initial training set.
2. Ongoing: every live SentinelPay-mediated transaction is added to the same table.
3. **Rolling window:** model trains on the most recent 200 transactions (SMS-derived + live, combined and time-ordered), aging out older entries automatically — bounded compute cost, and recency-weighted behavior modeling.
4. **Retrain trigger:** every 10 new transactions, or every 24 hours, whichever comes first — never retrains synchronously on the critical path of a payment scan.

**Signals extracted per transaction (same as v1 Section 21, now populated from SMS on day one):** merchant/payee frequency and recency, amount distribution, timing patterns, transaction velocity, known-payee set.

**Cold-start handling:** if SMS parsing yields fewer than ~15–20 usable transactions (e.g., a new bank account, limited SMS history), the app must gracefully state this ("We found limited payment history — protection will improve as you use SentinelPay") rather than pretending to have full confidence.

**Acceptance criteria:** A user with a normal 6+ month SMS history should have a trained model with non-trivial behavior signal *before completing their first live SentinelPay transaction* — this is the core acceptance bar for the whole pivot described in this version.

---

## 22. Local ML Roadmap (revised)

| Phase | Model | Status |
|---|---|---|
| MVP | Isolation Forest, trained on SMS-bootstrapped + live rolling 200-transaction window | **Ships at launch, not deferred** |
| Post-MVP | Local Outlier Factor, A/B'd against Isolation Forest once sufficient live volume exists | Evaluated after MVP stabilizes |
| Post-MVP | Incremental statistical layer as a lightweight fallback when SMS permission is denied/revoked | Ships alongside MVP as the no-permission fallback path, not a separate phase |

**Constraint carried through every phase:** No cloud ML, no paid inference APIs, no user data — SMS or transactional — leaving the device, ever.

---

## 23–24. Explainability Engine & Confidence Engine

Unchanged in mechanism from v1 (Sections 23–24), with one addition: explanation templates must be able to reference SMS-derived history distinctly from live history where relevant (e.g., *"Based on your past 6 months of payments, this amount is typical for you"* vs. *"You've made 3 payments through SentinelPay to this payee"*), so the user understands the model isn't starting from nothing, without overclaiming precision on SMS-derived data specifically (Section 20's parsing accuracy trade-off).

---

## 25. Database Design (updated)

```
transactions (
  id, source ENUM('sms_historical','live'),
  payee_vpa, payee_name, amount, direction, timestamp,
  payment_method, verdict, confidence, evidence_json,
  user_reported_outcome
)

payees (vpa, display_name, first_seen, last_seen, frequency_count, is_known)

behaviour_profile (
  rolling_window_size, model_version, last_trained_at,
  training_sample_count, feature_store_ref
)

sms_parse_log (
  id, parsed_at, match_status ENUM('matched','ignored'),
  -- NOTE: stores metadata about the parse operation only,
  -- never raw SMS text, once parsing completes
)

settings (
  sms_permission_granted BOOLEAN,
  sms_raw_retention_enabled BOOLEAN,  -- default FALSE
  privacy_prefs, accessibility_prefs, opt_in_flags
)
```

**Implementation note:** `sms_raw_retention_enabled` defaults to **false** — raw SMS text is held only transiently in memory during parsing and is not written to disk unless the user explicitly opts in (e.g., for debugging/review purposes), and even then it's local-only and separately deletable from the derived transaction data.

---

## 26. API Design

Unchanged from v1 (Section 26) — the API surface remains minimal and never touches SMS data in any form. This is worth restating explicitly given how sensitive the new data source is: **no endpoint in this system may ever accept, log, or transmit SMS content, parsed or raw, under any circumstance.**

---

## 27. Security

All v1 items apply, plus:
- SMS content, while in transient memory during parsing, must be handled in a way that avoids being swept into OS-level backups, crash dumps, or third-party crash-reporting SDKs (explicitly disable/exclude SMS-adjacent memory regions or fields from any crash reporting tool integrated later).
- The `sms_parse_log` table must be reviewed to confirm it truly contains only metadata (timestamps, match/no-match status) and never message bodies, even accidentally, as part of code review before every release touching the parser.

---

## 28. Privacy

All v1 principles apply, reinforced:
- SMS access is opt-in, explained in plain language before the OS permission prompt (Section 14).
- Raw SMS text is parsed transiently and not persisted by default.
- Derived transaction data (amount, timestamp, coarse payee/method) is what's actually stored and used for training — this is a meaningfully smaller and less sensitive dataset than the SMS inbox itself, and privacy copy should make this distinction clear to users.
- Full visibility (Parsed Transaction Review, Section 13.25) and full deletion (both derived data and any transiently-retained raw cache) available at any time.

---

## 29. Offline Strategy

Unchanged from v1 — everything described in this version (SMS parsing, model training, scoring) is already fully on-device and requires zero connectivity, which is actually *more* consistent with the offline-first NFR than v1's original phased ML roadmap was, since there's no "waiting for enough live data" period where the app feels less capable.

---

## 30. DevOps

Unchanged from v1, plus: CI should include a specific automated check that scans build artifacts and dependency SDKs for any inadvertent SMS-content logging paths (grep-style check for SMS content flowing into any logging or analytics call), given how easy this class of bug is to introduce accidentally.

---

## 31. Testing

All v1 testing requirements apply, plus:
- **SMS parser test suite:** a maintained library of real (anonymized/synthetic) bank/UPI SMS formats from major Indian banks and UPI apps, with expected extraction output, run in CI to catch regressions as banks change their SMS formats over time.
- **Privacy regression test:** an automated test asserting that no raw SMS text appears in any local log file, database table (other than transient memory), or mocked network call during a full parse-and-train cycle.
- **Permission-revocation test:** explicit test confirming the app degrades gracefully (no crash, clear fallback messaging) when SMS permission is revoked mid-session.

---

## 32. Accessibility

Unchanged from v1 — extend existing accessibility requirements to the three new screens (SMS Explainer, Parse Progress, Parsed Transaction Review).

---

## 33. Analytics

Unchanged from v1 core principle (opt-in only, no financial data). Explicit addition: analytics must never include SMS parse counts tied to identifiable content, sender names, or message samples — aggregate counts only (e.g., "X transactions parsed"), and only if the user has opted in.

---

## 34. Release Strategy

Revised for this version:
1. **Internal alpha** — Demo Mode + SMS parsing/training tested against team members' real (consented) SMS history, no live payment handoff yet.
2. **Closed beta** — full flow live, including real payment handoff, small cohort, explicit focus on validating SMS parser accuracy across different banks/devices before wider release.
3. **Play Store Permissions Declaration submitted and approved** — hard gate before any public beta (see Risks, Section 38) — this cannot be skipped or worked around.
4. **Open beta → Production**, same structure as v1.

---

## 35–36. Beta & Production Roadmap

Revised: since ML ships at MVP in this version, the "beta roadmap" from v1 (introducing behavior intelligence after MVP) is now folded into MVP itself. Beta phase instead focuses on: parser accuracy across more banks, Local Outlier Factor evaluation against Isolation Forest, and expanding the local SMS-template library based on real-world parse-failure data (collected only as aggregate, non-content metrics per Section 33).

---

## 37. Business Model

Unchanged from v1 (Section 37) — free core product, optional premium tier never gating core safety, B2B2C licensing later. Worth noting: the SMS-bootstrapped instant-personalization feature is a strong candidate for marketing/positioning ("protected from day one," not "protected after a few weeks") but should not become a premium-gated feature — it's foundational to the core trust promise, not an upsell.

---

## 38. Risks (updated — new risks specific to this version)

| Risk | Category | Mitigation |
|---|---|---|
| **Google Play SMS permission policy rejection** | Compliance — **highest severity, launch-blocking** | Submit Permissions Declaration Form early, with clear in-app disclosure and a fully functional no-SMS fallback path, since Play reviewers specifically check that the app remains usable without the restricted permission |
| Users decline SMS permission | Product | Deterministic + statistical fallback (v1 Sections 15–16) must be a fully first-class experience, not a degraded afterthought |
| Bank SMS format changes break parser | Technical | Parser template library shipped as an updatable local asset; parse-failure telemetry (aggregate only) used to prioritize fixes |
| Perceived creepiness of SMS access, even if privacy-respecting | Trust/Product | Front-load the Parsed Transaction Review screen and plain-language explainer; make "what we read" fully inspectable, not just claimed |
| Accidental SMS content leakage via logging/crash tools | Security | Automated CI check (Section 30) + manual security review before every release touching the parser |
| iOS has no equivalent SMS-read capability | Technical/Scope | This SMS-bootstrap feature is **Android-only** by platform constraint; iOS roadmap (if pursued) needs a different cold-start strategy — flag explicitly, don't assume parity |

---

## 39. Future Enhancements

Unchanged from v1, plus: explore a privacy-preserving iOS cold-start alternative (e.g., manual quick-import of recent transaction amounts, since iOS does not permit SMS content access) if/when iOS is prioritized.

---

## 40. Engineering Decisions

All v1 decisions apply. New decision for this version:

- **SMS parsing kept fully rule-based/regex, not ML-based:** chosen deliberately so extraction behavior is deterministic, auditable, and testable against a fixed template library — using an on-device NLP model for parsing would add complexity and unpredictability to the one part of the system handling the most sensitive raw input, with no clear accuracy benefit at this stage.
- **Isolation Forest chosen over incremental-stats-only for MVP:** justified specifically because SMS bootstrapping removes the cold-start problem that made a full ML model premature in v1 — with real historical data available immediately, there's no reason to ship a weaker statistical-only model first.

---

*End of v2. The single hard gate on this entire version is Section 38's Play Store Permissions Declaration risk — recommend confirming feasibility of SMS-permission approval for this app category before your AI agent invests significant build time, since a rejection here affects the core architecture, not just a feature.*
