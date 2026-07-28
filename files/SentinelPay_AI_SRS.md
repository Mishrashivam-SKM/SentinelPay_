# SentinelPay AI — Software Requirements Document
### *Your Personal UPI Safety Copilot*
**Version 1.0 — Draft for Engineering Review**

---

## 1. Executive Summary

SentinelPay AI is an on-device, pre-authorization fraud intelligence layer for UPI payments in India. It does not move money, hold balances, or replace any UPI app — it sits *before* the payment, analyzing a QR code or payee, scoring risk, explaining that risk in plain language, and then handing the user off to their installed UPI app (GPay, PhonePe, Paytm, BHIM) via Android UPI Intents to complete the transaction.

The product's defensibility is not a single fraud-detection trick but a fusion pipeline: deterministic checks, statistical anomaly detection, device signals, community signals, and — starting in beta — a fully on-device behavioral model per user. All computation happens locally wherever possible; no user financial data leaves the device unless the user explicitly opts into anonymized community reporting.

**Rationale:** Every existing UPI fraud response (bank SMS alerts, NPCI advisories, after-the-fact reporting apps) is reactive. The moment of maximum leverage — and maximum user attention — is the 3–5 seconds between scanning a QR and tapping "Pay." SentinelPay occupies that moment.

**Acceptance criteria:** A first-time user can go from cold install to a completed, Sentinel-assessed payment in under 90 seconds, without creating an account, and understand *why* SentinelPay gave its verdict without additional explanation from a human.

**Trade-off:** By refusing to become a payment app or hold a banking license, SentinelPay forgoes transaction-fee revenue and must monetize through B2B2C distribution (banks, fintechs) and premium safety tiers instead.

---

## 2. Vision

**3-year vision:** SentinelPay becomes the default trust layer bundled or recommended alongside UPI apps — the "seatbelt" of digital payments in India — eventually licensed as an SDK to banks and NPCI-regulated PSPs rather than remaining a standalone consumer app.

**1-year vision:** A polished, free consumer app with a growing installed base of safety-conscious users (students, parents of elderly users, professionals), a functioning on-device behavior model, and a demonstrable fraud-prevention track record that can be shown to enterprise partners.

**Implementation note:** The roadmap deliberately sequences *trust* (deterministic + explainable rules) before *intelligence* (learned models), because a wrong ML-driven block in month one destroys the credibility the product depends on.

---

## 3. Product Strategy

- **Wedge:** Solve one job extremely well — "tell me if this specific payment is safe" — before expanding into budgeting, insurance, or credit adjacent products.
- **Distribution:** Organic/community-led in beta (student ambassadors, senior-citizen digital literacy programs, fintech Twitter/LinkedIn), then B2B2C licensing.
- **Moat:** Not the ML model itself (replicable), but the accumulated *per-user behavioral history* and the *trust brand* — once a user has been protected once, switching cost is emotional as much as functional.
- **Non-goals (explicit):** SentinelPay will not become a UPI handle issuer, will not store or move funds, will not sell user transaction data, and will not launch with cloud-based LLM fraud scoring as a hard dependency.

**Trade-off:** A narrow wedge limits early monetization surface area but is the only credible way to earn the trust required for a security product.

---

## 4. Problem Statement

UPI fraud in India (QR-code swaps, "collect request" scams, fake customer-care numbers, screen-sharing scams, and social-engineering-driven payments) largely succeeds not because users are careless but because **UPI apps are optimized for payment speed, not payment judgment**. The interface gives no friction, no context, and no memory of the user's normal behavior at the exact moment friction would help most.

Existing mitigations are reactive: banks flag transactions *after* debit, NPCI/RBI publish advisories, and fraud-reporting apps operate post-facto. There is no widely adopted, real-time, explainable, pre-authorization safety layer.

**Acceptance criteria:** The problem statement must be validated against at least 3 documented fraud patterns (QR tampering, collect-request fraud, impersonation-of-known-payee) with a working detection path for each in the MVP.

---

## 5. Market Opportunity

- UPI processes tens of billions of transactions monthly in India, and digital payment fraud has grown in step with volume — this is a scale of daily behavior, not a niche.
- Regulatory tailwind: RBI and NPCI have been increasing pressure on the ecosystem for better fraud-prevention UX (cooling periods, contact-list-based first-payment friction), signaling institutional appetite for exactly this kind of layer.
- White space: no dominant "pre-payment copilot" brand exists yet; competitors are either bank-native (limited to that bank's rails) or post-facto reporting tools.

**Trade-off:** Market size claims should be sourced and cited with real, dated figures before appearing in any external-facing deck — this section should not be treated as final without a data pass by the Founder/CPO team against current RBI/NPCI reporting.

---

## 6. Competitive Analysis

| Category | Example type | Strength | Gap SentinelPay exploits |
|---|---|---|---|
| Bank-native fraud alerts | SMS/push post-debit alerts | Trusted channel, backed by regulation | Always after the money has moved |
| UPI app native warnings | In-app "new payee" flags | Built into the payment flow | Generic, not behaviorally personalized, easy to dismiss |
| Fraud reporting apps | Post-fraud reporting/helplines | Useful for recourse | Zero prevention value |
| Government advisories | NPCI/RBI awareness campaigns | Wide reach | No real-time, per-transaction intelligence |

**Rationale for inclusion:** Every competitor operates at the wrong point in time (after fraud) or the wrong level of personalization (generic rule, not this-user's-normal-behavior). SentinelPay's fusion of deterministic + behavioral scoring at decision-time is the differentiated wedge.

**Acceptance criteria:** Before public launch, this table must be refreshed with named, current products via a competitive audit (web research), not left as category placeholders.

---

## 7. User Personas

**1. Ananya, 21, college student.** First salary/allowance via UPI, pays merchants and splits bills constantly, has been targeted by a fake "cashback" QR before. Wants speed but is anxious about looking foolish if scammed.

**2. Rajesh, 45, working professional.** Pays 20+ merchants and vendors monthly, some recurring, some one-off (contractors, e-commerce). Wants low-friction protection that doesn't slow down trusted, repeat payments.

**3. Meena, 68, retired, semi-digital-native.** Uses UPI for utility bills and family transfers, primary target demographic for impersonation and screen-sharing scams. Needs large text, simple language, minimal steps, and a "call a real person" escape hatch conceptually (even if SentinelPay itself doesn't provide support directly).

**4. Parent monitoring persona (secondary):** Adult child who wants peace of mind that an elderly parent's payments are being screened, without invasive surveillance.

**Implementation note:** Meena's persona should directly drive font-size defaults, plain-language copy review, and a "why is this risky" explanation that never uses jargon like "anomaly score" without a lay translation.

---

## 8. Jobs To Be Done

- "When I scan a QR code I don't recognize, help me know in seconds whether it's safe, so I don't have to guess."
- "When I'm about to pay someone new, tell me if this looks like my normal spending pattern, so I catch mistakes before they cost me money."
- "When I've been scammed once, help me feel like it won't happen again without making every future payment annoying."
- "When my parent pays someone, let me trust the system is watching for patterns even when I'm not there."

---

## 9. User Stories

- As a first-time user, I want to try a **Demo Mode** with no account required, so I can evaluate SentinelPay before trusting it with real payments.
- As a returning user, I want SentinelPay to recognize my regular merchants and skip friction for them, so protection doesn't become annoyance.
- As a senior citizen, I want risk explained in one plain sentence with a single clear recommendation, so I don't need to interpret a score.
- As a privacy-conscious user, I want to see and delete my locally stored transaction history at any time.
- As a security engineer, I want every risk decision to be reconstructable from stored evidence, so fraud claims can be audited.

**Acceptance criteria (sample, for the merchant-recognition story):** After 3 successful payments to the same UPI ID, subsequent payments to that ID must show a "Known Payee" badge and reduced friction (single-tap continue) unless a *new* anomaly (amount, time, device) is detected.

---

## 10. Complete User Journey

1. **Launch** → Splash + value prop in one screen.
2. **Onboarding** → 3 screens max: what SentinelPay is, what it isn't (not a wallet), privacy promise (data stays on device).
3. **Choice screen** → *Experience Sentinel AI* (Demo Mode, no real payment) or *Protect My Payments* (real flow).
4. **QR Scan** → Camera-first, large scan target, manual UPI ID entry fallback.
5. **AI Fraud Analysis** → Sub-2-second local analysis with a visible "thinking" state (never a silent freeze).
6. **Risk Explanation** → One headline verdict (Safe / Caution / High Risk) + 2–3 plain-language reasons.
7. **Confidence** → Visual confidence indicator, tied to how much history/evidence supports the verdict.
8. **Continue Securely** → Explicit user confirmation, never auto-forwarding.
9. **Launch installed UPI app** → Android Intent handoff with amount/payee pre-filled where possible.
10. **Payment happens in the external UPI app** (SentinelPay has no visibility into PIN entry or bank rails).
11. **Return to SentinelPay** → User self-reports outcome (paid / cancelled) since Android intents don't reliably return payment status.
12. **Transaction stored locally** → Added to on-device history.
13. **Behaviour Profile updated** → Feeds the local model for future scoring.

**Trade-off (critical, flag to Compliance):** Because UPI intents do not guarantee a reliable callback with payment status on all apps/OS versions, the "did the payment succeed" signal is often self-reported or inferred — this must be communicated honestly in-product ("Did this payment go through?") rather than assumed.

---

## 11. Information Architecture

```
Root
├── Onboarding (first-run only)
├── Home
│   ├── Scan / Pay Safely (primary CTA)
│   ├── Recent Activity (local history)
│   ├── Known Payees
│   └── Safety Score / Behaviour Snapshot
├── Scan Flow
│   ├── QR Scanner
│   ├── Manual UPI ID Entry
│   ├── Risk Analysis (transient)
│   ├── Risk Explanation
│   └── Handoff Confirmation
├── Demo Mode
│   └── Guided fraud scenarios (simulated)
├── History
│   └── Transaction detail (evidence + explanation, replayable)
├── Settings
│   ├── Privacy & Data (export/delete)
│   ├── Notification preferences
│   ├── Accessibility
│   └── About / How SentinelPay Works
```

---

## 12. Navigation

- **Bottom navigation (4 tabs max):** Home, Scan (center, elevated), History, Settings.
- Scan is always one tap from anywhere in the app — this is the core action and must never be buried.
- No hamburger menus; no more than 2 levels of navigation depth for any core flow (violates the "students to seniors" usability bar otherwise).

---

## 13. Screen Inventory

1. Splash
2. Onboarding (3 screens)
3. Mode Choice (Demo vs Protect)
4. Home / Dashboard
5. QR Scanner
6. Manual Entry
7. Analyzing (transient/animated)
8. Risk Verdict — Safe
9. Risk Verdict — Caution
10. Risk Verdict — High Risk
11. Evidence Detail (expandable "why")
12. Handoff Confirmation (choose UPI app if multiple installed)
13. Return / Self-report outcome
14. Transaction History List
15. Transaction Detail
16. Known Payees List
17. Demo Mode Scenario Picker
18. Demo Scenario Walkthrough
19. Settings Home
20. Privacy & Data Controls
21. Accessibility Settings
22. About / How It Works

---

## 14. Screen Specifications

**Risk Verdict Screens (9–11)** — the most important screens in the product:
- Headline verdict in large type, color-coded (never relying on color alone — icon + text required for accessibility).
- One-sentence plain-language reason ("This UPI ID was created recently and hasn't been paid by anyone in your circle before.")
- Confidence indicator (visual bar or ring, labeled numerically for screen readers).
- Primary action always requires explicit confirmation — no default-selected "Continue" that can be triggered by accidental double-tap.
- Secondary action: "See full evidence" → Evidence Detail screen.

**Evidence Detail (11):** Every signal that contributed to the score, in plain language, mapped to the Explainability Engine output (Section 23) — never a raw feature vector.

**Acceptance criteria:** No verdict screen may present a risk level without at least one human-readable reason string; verdicts with zero contributing evidence must default to "Unable to assess — proceed with caution" rather than a false "Safe."

---

## 15. Functional Requirements

- FR1: The system must scan and decode UPI QR codes (both static and dynamic) and extract payee VPA, name, and amount where present.
- FR2: The system must accept manual UPI ID entry as a fallback when camera scanning is unavailable or fails.
- FR3: The system must produce a risk verdict (Safe / Caution / High Risk / Unable to Assess) for every scanned or entered payee before allowing handoff.
- FR4: The system must generate a plain-language explanation for every verdict.
- FR5: The system must hand off to the user's chosen installed UPI app via Android UPI Intent with pre-filled payee/amount where the intent spec allows it.
- FR6: The system must allow the user to self-report payment outcome on return.
- FR7: The system must store transaction and verdict history locally (SQLite) and never transmit it off-device without explicit opt-in.
- FR8: The system must maintain a local behavior profile per user, updated after each transaction.
- FR9: The system must support a Demo Mode with simulated fraud scenarios requiring no real payment or account.
- FR10: The system must allow full data export and deletion from Settings at any time.

---

## 16. Non-Functional Requirements

- **Performance:** Risk analysis must complete in under 2 seconds on a mid-tier Android device (e.g., 4GB RAM, Snapdragon 6-series class) for the deterministic + statistical layers; on-device ML inference (beta) must add no more than 300ms.
- **Reliability:** The app must degrade gracefully to deterministic-only scoring if the local ML model fails to load, never crashing the scan flow.
- **Availability:** Core scan-and-score flow must function fully offline (no network dependency) since NFR conflicts with any cloud-inference approach — this is a hard constraint, not an optimization.
- **Scalability:** Backend (FastAPI + Supabase) must support community-signal aggregation at growing user counts without per-user data ever being individually identifiable server-side.
- **Maintainability:** Each intelligence layer (Section 20) must be independently testable and swappable behind a common interface.
- **Accessibility:** WCAG 2.1 AA minimum across all screens (see Section 32).

**Trade-off:** Full offline-first operation limits how sophisticated the community-intelligence layer can be in real time (it must sync opportunistically rather than query live), which is an acceptable cost for privacy and reliability.

---

## 17. Design System

- **Visual language:** Calm, high-trust, minimal — closer to Apple Wallet/Linear than a typical fintech app with loud gradients and urgency-driven red everywhere.
- **Color use for risk states:** Green (Safe), Amber (Caution), Red (High Risk) — always paired with icon + label text, never color-only signaling.
- **Typography:** One primary typeface, generous line height, minimum 16sp body text, scalable up to 200% for accessibility without breaking layout.
- **Components:** Riverpod-driven, Clean-Architecture-separated widget library — verdict cards, evidence chips, confidence rings, and payee badges as first-class reusable components, not one-off screens.
- **Tone of voice:** Direct, calm, never alarmist. "This looks safe" not "DANGER DETECTED."

---

## 18. Motion Guidelines

- The "Analyzing" state must use motion to communicate *active work*, not decorative flourish — a subtle progress indicator tied to real pipeline stages (Feature Engineering → Risk Fusion → Explainability) rather than a generic spinner, so the user senses genuine analysis.
- Verdict reveal should use a short, single easing transition (200–300ms) — no bouncing or playful motion on a High Risk verdict; save personality for Safe verdicts and Demo Mode.
- Respect system-level "reduce motion" accessibility settings by disabling non-essential animation.

---

## 19. AI Architecture

SentinelPay explicitly avoids a monolithic LLM-wrapper design. The system is a **modular Fraud Intelligence Platform**, where each stage below is a distinct, independently testable component with a defined input/output contract:

```
Feature Engineering
   ↓
QR Intelligence
   ↓
Deterministic Intelligence
   ↓
Statistical Intelligence
   ↓
Device Intelligence
   ↓
Community Intelligence
   ↓
Behaviour Intelligence
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

**Rationale:** A single LLM call cannot be reliably explained, audited, reproduced offline, or made cheap at scale. A modular pipeline lets each layer be replaced, unit-tested, and reasoned about independently — critical for a product whose entire value proposition is *trustworthy explanation*, not just a score.

**Implementation note:** Each layer should expose a typed output object (e.g., `LayerResult { signals: [], confidenceContribution: float, rationale: string[] }`) consumed by the Risk Fusion Engine, so new layers can be added without touching downstream code.

---

## 20. Fraud Intelligence Architecture

- **QR Intelligence:** Validates QR structure against known UPI QR spec, detects malformed/tampered payloads, flags mismatches between displayed merchant name and encoded VPA.
- **Deterministic Intelligence:** Hard rule checks — known-scam VPA patterns, blacklists (community-sourced, Section 20 community layer), suspicious VPA age heuristics where derivable, amount-formatting red flags (e.g., round-trip "refund" scam patterns).
- **Statistical Intelligence:** Per-user distribution modeling of amount, time-of-day, frequency — flags deviations without requiring a trained ML model (mean/variance-based, not a black box) as the MVP baseline before behavior ML ships.
- **Device Intelligence:** Signals available without extra permissions where possible — e.g., time-since-install, whether this is the user's first scan of the day, rooted-device detection as a risk-context modifier (not a hard block).
- **Community Intelligence:** Opt-in anonymized reporting of confirmed-fraud VPAs, aggregated server-side, never traceable back to reporting users, contributing a shared blacklist/graylist.
- **Behaviour Intelligence:** See Section 21.

**Trade-off:** Deterministic and statistical layers alone will have real false negatives against novel scams; this is accepted at MVP in exchange for zero false-positive risk of "black box" blocks that would destroy user trust before the brand is established.

---

## 21. Behaviour Intelligence

Introduced in the beta phase (per roadmap), trained **entirely on-device**, no cloud round-trip.

**Candidate models (in order of MVP-to-beta suitability):**
1. **Incremental statistical learning** (running mean/variance, exponentially weighted) — ships first, cheapest, most explainable.
2. **Isolation Forest** (lightweight, unsupervised, good for tabular anomaly detection on small per-user datasets) — primary beta candidate.
3. **Local Outlier Factor** — considered for density-based anomaly detection once enough transaction volume exists per user.
4. **One-Class SVM** — considered later; higher compute cost, evaluated only if the above underperform on-device within latency budget.

**Signals learned per user, continuously:**
- Merchant frequency and recency
- Beneficiary frequency and recency
- Amount distribution (mean, variance, typical range)
- Payment timing patterns (time of day, day of week)
- Transaction velocity (payments per hour/day)
- Known-merchant and known-beneficiary sets
- Confidence evolution over time (the model should become *more* confident, not just more restrictive, as it sees more of a user's normal behavior)

**Rationale:** A cold-start user has no behavior baseline, so Behaviour Intelligence must gracefully contribute *zero weight* until sufficient history exists (e.g., minimum 10–15 transactions) rather than making early, poorly-informed judgments — the Risk Fusion Engine must treat "insufficient data" as a distinct state, not silently default to low confidence.

**Acceptance criteria:** No behavior-model output may be shown to the user without a corresponding plain-language evidence string (e.g., "You've paid this person 12 times before" or "This amount is unusually large for a first-time payee").

---

## 22. Local ML Roadmap

| Phase | Model | Trigger to enable |
|---|---|---|
| MVP | None (deterministic + statistical only) | Launch |
| Beta, week 1–2 | Incremental statistical learning | Immediately after MVP stabilizes |
| Beta, week 3–6 | Isolation Forest | Once median user has 10+ transactions logged |
| Beta, month 2–3 | Local Outlier Factor (A/B against Isolation Forest) | Sufficient transaction volume for offline eval |
| Post-beta | Federated aggregate insights (optional, opt-in only) | Only if community demand and privacy review both clear it |

**Constraint carried through every phase:** No cloud ML, no paid inference APIs, no user data leaving the device — this is a hard product constraint, not a cost-saving default, and should be treated as a compliance requirement, not an engineering preference.

---

## 23. Explainability Engine

Converts internal layer signals into user-facing, plain-language evidence strings. This is a **first-class engineering component**, not a UI-layer afterthought.

**Design rules:**
- Every signal has a pre-authored, testable natural-language template (e.g., `"This payee has been paid {n} times before"`), never free-generated text from an LLM, to guarantee consistency, auditability, and zero hallucination risk.
- Templates are localized (English + at least Hindi at MVP, given the target demographic) and reviewed for plain-language clarity, especially for the senior-citizen persona.
- The Explainability Engine output is what populates both the Risk Verdict headline reason and the full Evidence Detail screen.

**Acceptance criteria:** A non-technical reviewer (ideally matching the Meena persona) must be able to read any generated explanation and correctly state, in their own words, why the payment was flagged.

---

## 24. Confidence Engine

Distinct from the risk score itself: confidence expresses *how much evidence supports* the verdict, not how risky the payment is.

- A brand-new payee with no behavior history but a suspicious deterministic flag → **High Risk, High Confidence**.
- A brand-new payee with no red flags and no history → **Safe-leaning, Low Confidence** (should be surfaced honestly, e.g., "No red flags found, but this is a new payee so we have limited history").
- A known payee with a full behavior history and no anomalies → **Safe, High Confidence**.

**Rationale:** Conflating "we think it's safe" with "we're sure it's safe" is a trust-destroying failure mode for a security product — the Confidence Engine exists specifically to prevent SentinelPay from ever appearing more certain than its evidence supports.

---

## 25. Database Design

**Local (SQLite, on-device, source of truth for all personal data):**

```
users (local profile, no PII required beyond optional display name)
transactions (id, payee_vpa, payee_name, amount, timestamp, verdict, confidence, evidence_json, user_reported_outcome)
payees (vpa, display_name, first_seen, last_seen, frequency_count, is_known)
behaviour_profile (rolling statistical aggregates, model_version, last_updated)
settings (privacy prefs, accessibility prefs, opt-in flags)
```

**Remote (Supabase, minimal, only for opt-in community layer):**

```
community_reports (anonymized_report_id, vpa_hash, report_type, timestamp)  -- no user linkage stored
blacklist_cache (vpa_hash, risk_tier, source_count, last_updated)
```

**Implementation note:** VPAs in the community layer are stored as salted hashes, never plaintext, and the salt/hashing scheme must be reviewed by the Security team before any data leaves the device — this is a hard gate, not a launch nice-to-have.

**Trade-off:** Hashing prevents plaintext exposure but also prevents fuzzy-matching of near-identical scam VPAs server-side; this is accepted in favor of privacy, with fuzzy detection kept entirely client-side instead.

---

## 26. API Design

FastAPI backend surface is intentionally minimal — most intelligence stays on-device.

```
POST /v1/community/report        -- submit anonymized fraud report
GET  /v1/community/check/{vpa_hash}  -- check hash against aggregated blacklist/graylist
GET  /v1/app/config               -- feature flags, minimum supported app version
POST /v1/telemetry/opt-in-event   -- only fires if user has explicitly opted into analytics
```

**Rationale:** A minimal API surface reduces attack surface and reinforces the "your data doesn't leave your device" promise at an architectural level, not just a policy level.

**Acceptance criteria:** No endpoint may accept or return a raw UPI ID, transaction amount, or user identifier in plaintext; all payee identifiers crossing the network must be pre-hashed client-side.

---

## 27. Security

- All local data encrypted at rest using platform-standard secure storage (Android Keystore-backed encryption for SQLite).
- No hardcoded secrets; Supabase keys scoped to minimum required permissions (community report/check only, never broad table access).
- Certificate pinning for any network calls to the FastAPI backend.
- Rooted/jailbroken device detection used as a *risk-context signal only*, never as a hard app-block (avoids alienating legitimate power users while still factoring elevated risk into scoring).
- Regular dependency vulnerability scanning in CI (GitHub Actions) for both Flutter and FastAPI dependencies.

---

## 28. Privacy

- Default posture: **zero data leaves the device.**
- Community reporting is opt-in, anonymized via salted hashing, and explained in plain language at the point of opt-in (not buried in a ToS).
- Full data export and full data deletion available from Settings at any time, executing immediately and locally.
- No third-party analytics SDKs bundled by default; any future analytics must be opt-in and clearly disclosed.
- Privacy policy must be written in plain language first, legal language second (a plain-language summary at the top of any formal policy document).

**Acceptance criteria:** A privacy audit checklist must confirm zero outbound network calls occur during a full scan-to-payment flow when community reporting is disabled.

---

## 29. Offline Strategy

- Core scan → analyze → verdict → handoff flow must work with zero connectivity, since deterministic, statistical, and behavior layers are all local.
- Community Intelligence layer (the only networked layer) must fail silently and gracefully offline — its absence should reduce confidence slightly, never break the flow or throw a visible error.
- Sync of community blacklist cache happens opportunistically in the background when connectivity is available, not on the critical path of any transaction.

---

## 30. DevOps

- **CI/CD:** GitHub Actions — lint, unit test, and build on every PR; separate pipelines for Flutter app builds and FastAPI backend deploys.
- **Environments:** Local dev → Staging (Supabase free-tier project) → Production (separate Supabase project, stricter row-level security).
- **Release strategy:** Staged rollout via Play Store internal testing → closed beta → open beta → production, gated by crash-free session rate thresholds at each stage.
- **Cost constraint:** Entire stack must run within free tiers (Supabase Free, GitHub Actions free minutes, open-source libraries only) through beta — this is a stated hard constraint, not aspirational.

---

## 31. Testing

- **Unit tests:** Every Fraud Intelligence layer tested independently with fixed input fixtures and expected `LayerResult` outputs.
- **Golden-path fraud scenario tests:** A maintained library of known scam patterns (QR tamper, fake collect request, impersonation) with expected verdicts, run in CI to catch regressions in detection quality.
- **Widget/UI tests:** Flutter widget tests for all Risk Verdict and Evidence Detail screens, including screen-reader label assertions.
- **Manual QA:** Persona-based test passes (specifically including a Meena-persona pass: large text, screen reader, minimal steps) before every release.
- **Security testing:** Static analysis in CI plus a periodic manual penetration-style review of the local encryption and API surface.

---

## 32. Accessibility

- WCAG 2.1 AA minimum, audited before each major release.
- All risk states communicated via icon + text + color (never color alone).
- Minimum touch target size 48x48dp throughout.
- Full screen-reader support (TalkBack) with meaningful labels on every verdict, confidence, and evidence element — no "image1" or unlabeled icon-only buttons.
- Text scalable to 200% without breaking layout (test explicitly against the Meena persona's expected device settings).
- Respect system reduce-motion settings (Section 18).

---

## 33. Analytics

- Default: no analytics collection.
- Opt-in analytics (if enabled by user) limited to product-usage events (e.g., "scan initiated," "verdict shown") — never transaction amounts, VPAs, or payee names.
- All opt-in analytics events reviewed against the Privacy section's plaintext-prohibition rule before implementation.

---

## 34. Release Strategy

1. **Internal alpha** — team + trusted testers, Demo Mode only, no real payment handoff.
2. **Closed beta** — real payment handoff enabled, small cohort across the four personas, Behaviour Intelligence phase 1 (incremental statistical) enabled.
3. **Open beta** — Isolation Forest model enabled, wider public sign-up, community reporting opt-in live.
4. **Production launch** — stabilized model, full accessibility audit passed, privacy audit passed, marketing push toward primary personas.

---

## 35. Beta Roadmap

Per the source directive, within days of MVP: ship Behaviour Intelligence (Section 21–22), trained fully on-device, starting with incremental statistical learning and progressing to Isolation Forest as data volume allows — no cloud ML, no paid APIs, no data leaving the device at any point in this roadmap.

---

## 36. Production Roadmap

- Expand language support beyond English/Hindi based on beta usage data.
- Evaluate Local Outlier Factor vs. Isolation Forest in production A/B once sufficient volume exists.
- Begin B2B2C conversations (bank/fintech SDK licensing) only after a demonstrable, cited fraud-prevention track record from the consumer app.
- Explore parent/guardian companion view (opt-in, consent-based monitoring for senior-citizen users) as a distinct future feature, not an MVP requirement.

---

## 37. Business Model

- **Phase 1 (consumer, free):** No monetization; focused entirely on trust-building and data (behavioral model quality) accumulation.
- **Phase 2 (premium tier, optional):** Advanced features (e.g., family protection dashboard, priority community-blacklist sync) behind a low-cost subscription — never gating core fraud protection behind a paywall, which would undermine the safety mission.
- **Phase 3 (B2B2C licensing):** SDK/white-label licensing to banks and fintechs once the consumer product has a proven track record.

**Trade-off:** Refusing to paywall core safety features is a deliberate trust decision that delays monetization — flagged explicitly for Founder/CEO and CPO sign-off as a strategic, not just product, choice.

---

## 38. Risks

| Risk | Category | Mitigation |
|---|---|---|
| Android UPI Intent doesn't reliably return payment status | Technical | Explicit self-report UX (Section 10), never assume success |
| On-device model false positives erode trust | Product | Conservative confidence thresholds, "Unable to Assess" fallback state |
| Community-reporting layer abused for false blacklisting | Security | Multi-source corroboration required before a hash affects verdicts, not single-report triggers |
| Regulatory ambiguity (RBI/NPCI view of third-party "safety layers") | Compliance | Early legal review; explicit non-payment, non-custodial positioning in all user-facing and regulatory-facing copy |
| Cold-start users get low-value experience before behavior data accumulates | Product | Deterministic + statistical layers must carry full weight at MVP, not treated as filler |

---

## 39. Future Enhancements

- Family/guardian protection dashboards (consent-based).
- Multi-language expansion beyond English/Hindi.
- SDK licensing for bank/fintech partners.
- Optional federated learning exploration (only if privacy review clears it — not assumed).
- Merchant-side verification partnerships (e.g., verified-merchant badges sourced from legitimate business registries).

---

## 40. Engineering Decisions

- **Flutter + Riverpod + Clean Architecture:** chosen for single-codebase Android/iOS reach, testability, and clear separation between UI, domain, and data layers — critical for a codebase where the Fraud Intelligence layers must be independently swappable (Section 19).
- **SQLite over any cloud-first local-first framework:** simplicity, zero vendor lock-in, well-understood encryption story via platform Keystore.
- **FastAPI + Supabase Free over a heavier backend:** minimal surface area matches the "most data never leaves the device" architecture; Supabase Free keeps the beta phase at zero infrastructure cost, with a clear upgrade path if usage outgrows the free tier.
- **No LLM-wrapper architecture:** rejected explicitly (Section 19) in favor of a modular, explainable, offline-capable pipeline — the single most important architectural decision in the product, since it's what makes every other trust and privacy claim credible.

---

*End of document. This SRS is intended as a living source of truth — sections 5 (Market Opportunity) and 6 (Competitive Analysis) in particular should be refreshed with current, cited data before any external-facing use.*
