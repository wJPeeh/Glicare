# Design System Documentation: Glicare

## 1. Overview & Creative North Star
**The Creative North Star: "The Precision Sanctuary"**

In the world of health tech, most applications feel either overly clinical or generic. This design system rejects the "standard dashboard" aesthetic in favor of a **High-End Editorial** experience. We are building a "Precision Sanctuary"—a digital space that feels as authoritative as a medical lab but as calming and intentional as a premium wellness retreat.

The goal is to break the "template" look. We achieve this through **intentional asymmetry**, high-contrast typography scales, and a departure from traditional structural lines. Instead of boxes and borders, we use light, depth, and tonal shifts to guide the user’s eye. This is not just an app; it is a sophisticated health companion that treats data as art.

---

### 2. Colors & Tonal Depth
Our palette is rooted in the "Precision Sanctuary" ethos, utilizing deep blues and vibrant teals to signify trust and vitality.

*   **Primary (#005f9c) & Secondary (#00675f):** These represent the core of the experience. Use the `primary` token for high-intent actions and the `secondary` (teal) for health-related metrics to create a subconscious distinction between "App Control" and "Biological Data."
*   **The "No-Line" Rule:** Explicitly prohibit the use of 1px solid borders for sectioning content. Boundaries must be defined solely through background color shifts. For example, a `surface-container-low` section should sit on a `surface` background to define its edges. 
*   **The "Glass & Gradient" Rule:** To provide a signature "soul" to the UI, use subtle linear gradients (from `primary` to `primary-container`) for large hero elements. For floating overlays, implement **Glassmorphism**: use `surface-container-lowest` with 80% opacity and a `backdrop-blur` of 20px. This makes the UI feel integrated and layered rather than flat.
*   **Surface Hierarchy:** 
    *   `surface-container-lowest`: Use for primary cards and floating elements.
    *   `surface-container-high`: Use for recessed areas or background containers that need to feel "deeper" than the base.

---

### 3. Typography: The Editorial Voice
We use a dual-font strategy to balance character with readability.

*   **Display & Headlines (Plus Jakarta Sans):** This font brings a modern, geometric clarity. Use `display-lg` and `headline-md` for glucose numbers and major summaries. The slightly wider tracking of Jakarta gives it an "expensive" feel.
*   **Body & Labels (Manrope):** Chosen for its exceptional legibility and friendly, open apertures. Manrope handles the dense health data and small label requirements without feeling cramped.
*   **Hierarchy as Authority:** Use the scale to create a clear "Order of Operations." Your glucose value (`display-lg`) should dominate the screen, while supporting data (`body-sm`) uses a lighter weight and the `on-surface-variant` color to recede.

---

### 4. Elevation & Depth: Tonal Layering
Traditional shadows are a relic. In this design system, depth is achieved through **Tonal Layering** and ambient light.

*   **The Layering Principle:** Stack your surfaces. A `surface-container-lowest` card placed on a `surface-container-low` section creates a natural, soft lift. This creates "visual breathing room" that feels high-end.
*   **Ambient Shadows:** If a floating effect is required (e.g., a critical alert or FAB), use extremely diffused shadows.
    *   **Value:** 0px 12px 32px
    *   **Color:** Use the `on-surface` color at 6% opacity. Never use pure black (#000) for shadows; it looks muddy.
*   **The "Ghost Border" Fallback:** If a border is required for accessibility (e.g., in a high-glare environment), it must be a "Ghost Border": use the `outline-variant` token at **15% opacity**. 

---

### 5. Components
Each component must feel intentional, with soft geometry and high-end finishing.

*   **Buttons:** 
    *   **Primary:** Use a `primary` to `primary-dim` gradient. Shape must be `rounded-full`. This "pill" shape conveys comfort and safety.
    *   **Secondary:** No background. Use `outline` at 20% opacity with `primary` text.
*   **Cards (The Health Insight):** Forbid the use of divider lines. Separate content using the Spacing Scale (specifically `spacing-6` or `spacing-8`). Content within cards should be grouped using `surface-container-high` backgrounds for secondary metrics (e.g., "Time in Range" stats inside a main glucose card).
*   **Input Fields:** Use `surface-container-highest` for the field background with a `rounded-md` corner. Labels should use `label-md` in `on-surface-variant`.
*   **Glicare Progress Rings:** For glucose goals, avoid thin lines. Use thick, soft-rounded strokes with a `primary-container` background track and a `primary` active track.
*   **Chips:** Use `secondary-container` with `on-secondary-container` text for positive health states. Use `tertiary-container` for cautionary states (e.g., "Moderate Impact").

---

### 6. Do's and Don'ts

#### Do
*   **Do** use the `rounded-xl` (1.5rem) setting for major container components to maintain the "soft" brand personality.
*   **Do** prioritize whitespace (`spacing-12` and `spacing-16`) between major modules to create an editorial layout that breathes.
*   **Do** use `tertiary` (orange/gold) for trend alerts; it is more sophisticated and less "alarming" than pure red, unless the state is critical (`error`).

#### Don't
*   **Don't** use 1px solid lines to separate list items. Use vertical spacing or a 1-step shift in surface color.
*   **Don't** use standard "drop shadows" with high opacity. They look dated and cheap.
*   **Don't** overcrowd the screen. If a user's glucose is stable, the UI should reflect that calm with more whitespace and fewer "noise" elements.
*   **Don't** use high-contrast text for secondary information. Stick to the `on-surface-variant` or `on-surface-variant` with 70% opacity.

---

### 7. Spacing & Rhythm
Consistency in rhythm is the hallmark of a Senior-level UI.

*   **Grid:** Use an 8pt grid system.
*   **Horizontal Margins:** Always use `spacing-6` (1.5rem) for mobile screen gutters.
*   **Vertical Rhythm:** Use `spacing-10` between distinct content modules to ensure the "Editorial" look is preserved.