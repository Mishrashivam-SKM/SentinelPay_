---
name: SentinelPay AI
colors:
  surface: '#121414'
  surface-dim: '#121414'
  surface-bright: '#383939'
  surface-container-lowest: '#0c0f0e'
  surface-container-low: '#1a1c1c'
  surface-container: '#1e2020'
  surface-container-high: '#282a2a'
  surface-container-highest: '#333535'
  on-surface: '#e2e2e2'
  on-surface-variant: '#bbcabf'
  inverse-surface: '#e2e2e2'
  inverse-on-surface: '#2f3130'
  outline: '#86948a'
  outline-variant: '#3c4a42'
  surface-tint: '#4edea3'
  primary: '#4edea3'
  on-primary: '#003824'
  primary-container: '#10b981'
  on-primary-container: '#00422b'
  inverse-primary: '#006c49'
  secondary: '#c0c1ff'
  on-secondary: '#1000a9'
  secondary-container: '#3131c0'
  on-secondary-container: '#b0b2ff'
  tertiary: '#ffb95f'
  on-tertiary: '#472a00'
  tertiary-container: '#e29100'
  on-tertiary-container: '#523200'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#6ffbbe'
  primary-fixed-dim: '#4edea3'
  on-primary-fixed: '#002113'
  on-primary-fixed-variant: '#005236'
  secondary-fixed: '#e1e0ff'
  secondary-fixed-dim: '#c0c1ff'
  on-secondary-fixed: '#07006c'
  on-secondary-fixed-variant: '#2f2ebe'
  tertiary-fixed: '#ffddb8'
  tertiary-fixed-dim: '#ffb95f'
  on-tertiary-fixed: '#2a1700'
  on-tertiary-fixed-variant: '#653e00'
  background: '#121414'
  on-background: '#e2e2e2'
  surface-variant: '#333535'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  number-data:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '500'
    lineHeight: 24px
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  margin-mobile: 24px
  margin-desktop: 48px
  gutter: 16px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
---

## Brand & Style

The design system is centered on the persona of an invisible, intelligent guardian—a "Safety Copilot" that remains unobtrusive until a moment of decision. The aesthetic blends **High-Contrast Dark Mode** with **Glassmorphism**, creating a sense of depth and technical sophistication. 

The brand personality is authoritative yet calm, avoiding "alarmist" visuals in favor of data-driven confidence. The UI utilizes layered surfaces and translucent materials to represent the AI’s "scanning" process, evoking a futuristic, high-security environment that feels both premium and protective.

## Colors

The system is built on an **AMOLED-first** foundation. 
- **Core Backgrounds:** True Black (#000000) is used for the primary background to maximize contrast and power efficiency.
- **Surface Tiers:** Primary cards use #0A0A0C, while secondary floating elements use #121214.
- **Semantic Logic:** 
    - **Trust:** Emerald Green (#10B981) for safe transactions and high confidence.
    - **Caution:** Amber (#F59E0B) for moderate risk or unverified contacts.
    - **High Risk:** Deep Muted Red (#B91C1C) for blocked or fraudulent alerts.
- **AI Accent:** An Electric Indigo to Violet gradient represents the active AI processing state and premium copilot features.
- **Light Mode:** A warm-neutral off-white (#FAFAF9) is used for accessibility, replacing black with pure white and reversing the surface logic.

## Typography

This design system utilizes **Inter** for its neutral, geometric-humanist clarity. 
- **Numerical Integrity:** For all transaction amounts and UPI IDs, the system must enable **Tabular Figures** (`tnum`) to ensure columns of numbers align perfectly for quick scanning.
- **Readability:** A minimum body size of 16px is enforced for critical transaction details to prevent errors.
- **Hierarchy:** Display styles use tighter letter spacing and heavier weights to anchor the page, while labels use uppercase tracking for a systematic, "dashboard" feel.

## Layout & Spacing

The system follows a strict **8pt grid** to maintain mathematical harmony. 
- **Margins:** A generous 24px side margin on mobile ensures that content feels focused and readable, even on devices with curved edges.
- **Fluidity:** Containers use fluid widths with fixed gutters (16px). 
- **Safe Areas:** Significant bottom padding is reserved for floating action buttons and glassmorphic navigation bars to ensure they do not overlap interactive list items.
- **Transitions:** Layout shifts are governed by spring-based motion (damping: 20, stiffness: 90) to make the UI feel responsive and organic.

## Elevation & Depth

Depth is communicated through **Glassmorphism** and subtle tonal shifts rather than traditional heavy shadows.
- **The Glass Layer:** Floating cards and bottom sheets use a background blur (20px to 30px) and a semi-transparent fill (`rgba(255, 255, 255, 0.04)` in dark mode). 
- **Strokes as Borders:** Surfaces are defined by a 1px inner border (white at 10% opacity) to catch the "light" and define edges against the true black background.
- **The AI Glow:** High-priority AI components (like the Confidence Ring) use a soft, colored outer glow (spread 15px, 20% opacity) matching the Indigo/Violet gradient to suggest active computation.

## Shapes

The shape language is modern and approachable. 
- **Standard Radius:** 0.5rem (8px) for input fields and small chips.
- **Large Radius:** 1rem (16px) for Evidence Cards and main transaction containers.
- **X-Large Radius:** 1.5rem (24px) for Bottom Sheets and the primary Risk Verdict Badge.
- **Circular:** Confidence Rings and user avatars are fully rounded (pill/circle) to provide a soft counterpoint to the structured grid.

## Components

- **Risk Verdict Badge:** A prominent, high-radius header component. It uses the semantic color background (Green/Amber/Red) with a 20% opacity tint and a matching 1px solid border.
- **Confidence Ring:** A circular progress indicator using the AI Gradient. The stroke weight is 4px, representing the percentage of AI certainty.
- **Evidence Card:** A secondary surface (#0A0A0C) containing bulleted "Risk Chips." It uses the glassmorphic stroke to separate it from the main background.
- **Risk Chip:** Small, semantic-colored tags (e.g., "New Merchant," "Unusual Location"). They feature a 0.5px border and no background fill to remain low-profile.
- **Primary Button:** Uses the AI Gradient with white text for "High-Confidence" actions.
- **Secondary/Safety Button:** A ghost-style button with a thick 2px border in Amber or Red for "Block" or "Report" actions.
- **Glassmorphic Bottom Sheet:** Appears for transaction confirmations. It must have a `backdrop-filter: blur(24px)` and a grab-handle at the top.
- **Skeleton Loaders:** Shimmering pulses that move from #0A0A0C to #18181B, used during UPI verification phases.