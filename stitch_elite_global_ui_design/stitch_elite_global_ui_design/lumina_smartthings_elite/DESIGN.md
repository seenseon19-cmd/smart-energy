---
name: Lumina SmartThings Elite
colors:
  surface: '#f8f9ff'
  surface-dim: '#d8dae0'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3fa'
  surface-container: '#ecedf4'
  surface-container-high: '#e7e8ef'
  surface-container-highest: '#e1e2e9'
  on-surface: '#191c21'
  on-surface-variant: '#414751'
  inverse-surface: '#2e3036'
  inverse-on-surface: '#eff0f7'
  outline: '#727782'
  outline-variant: '#c1c7d3'
  surface-tint: '#0860aa'
  primary: '#00457f'
  on-primary: '#ffffff'
  primary-container: '#005da7'
  on-primary-container: '#bcd6ff'
  inverse-primary: '#a3c9ff'
  secondary: '#0051d5'
  on-secondary: '#ffffff'
  secondary-container: '#316bf3'
  on-secondary-container: '#fefcff'
  tertiary: '#004b56'
  on-tertiary: '#ffffff'
  tertiary-container: '#006573'
  on-tertiary-container: '#5be6ff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d3e3ff'
  primary-fixed-dim: '#a3c9ff'
  on-primary-fixed: '#001c39'
  on-primary-fixed-variant: '#004883'
  secondary-fixed: '#dbe1ff'
  secondary-fixed-dim: '#b4c5ff'
  on-secondary-fixed: '#00174b'
  on-secondary-fixed-variant: '#003ea8'
  tertiary-fixed: '#a2eeff'
  tertiary-fixed-dim: '#2fd9f4'
  on-tertiary-fixed: '#001f25'
  on-tertiary-fixed-variant: '#004e5a'
  background: '#f8f9ff'
  on-background: '#191c21'
  surface-variant: '#e1e2e9'
typography:
  display-lg:
    fontFamily: Cairo
    fontSize: 42px
    fontWeight: '700'
    lineHeight: 52px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Cairo
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Cairo
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
  headline-md:
    fontFamily: Cairo
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Cairo
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Cairo
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Cairo
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  description-sm:
    fontFamily: Cairo
    fontSize: 13px
    fontWeight: '300'
    lineHeight: 18px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  margin-page: 24px
  gutter-grid: 16px
  card-padding: 20px
  stack-gap-sm: 8px
  stack-gap-md: 16px
  stack-gap-lg: 32px
---

## Brand & Style

The design system is engineered for a high-end, global smart home experience that balances corporate reliability with futuristic elegance. It targets homeowners who value seamless automation, professional-grade security, and sophisticated aesthetics.

The visual style is a hybrid of **Corporate Modernism** and **Glassmorphism**. It takes the structured reliability of flagship technology platforms and injects a premium feel through high-fidelity translucency, fluid background gradients, and a meticulous focus on light and depth. The emotional response should be one of "effortless control"—feeling both high-tech and human-centric.

Key aesthetic pillars:
- **Professionalism:** Rooted in deep blues and structured layouts.
- **Fluidity:** Soft gradients and smooth transitions that mimic the invisible flow of smart signals.
- **Transparency:** Glassmorphic surfaces that provide context without visual clutter.

## Colors

The color palette is anchored by **Deep Corporate Blue**, providing a stable, trustworthy foundation for the interface. This is complemented by **Smart Blue** for primary interactions and **Neon Cyan** for technical highlights, such as active connectivity status or sensor data.

The background uses a "Fluid Surface" approach—very subtle linear gradients from a crisp white-blue to a soft grey-blue. This creates a canvas where glassmorphic cards can sit with enough contrast to feel layered.

- **Primary:** Core branding, headers, and essential navigational elements.
- **Secondary (Active):** Interactive components, toggles, and selection states.
- **Tertiary (Tech):** Data visualizations, high-tech status indicators, and subtle accents.
- **Neutrals:** Soft greys used for non-essential text and dividers to maintain a low-friction visual hierarchy.

## Typography

This design system uses **Cairo** exclusively to ensure world-class support for both LTR and RTL scripts, crucial for a global flagship application. 

The typographic hierarchy relies on weight contrast. **Bold (700)** and **SemiBold (600)** are reserved for headlines and interactive labels to convey authority and clarity. **Light (300)** and **Regular (400)** are used for descriptive text and metadata to create an airy, premium feel that doesn't overwhelm the user.

For mobile devices, headline sizes are scaled down to ensure readability within restricted widths, while body text maintains a comfortable 16px minimum to support diverse age demographics in the home.

## Layout & Spacing

The design system utilizes a **Fluid Grid** model built on a 4px baseline unit. 

- **Mobile:** A 4-column layout with 24px side margins.
- **Tablet:** An 8-column layout with 32px margins, allowing for dual-panel dashboard views.
- **Desktop:** A 12-column centered layout with a maximum content width of 1440px.

Spacing is used to group related smart devices. Large gaps (32px) separate functional zones (e.g., Living Room vs. Kitchen), while smaller gaps (16px) define relationships between individual device cards and their status indicators.

## Elevation & Depth

Visual hierarchy is achieved through **Glassmorphism** and **Ambient Shadows**.

1.  **Base Layer:** The fluid background gradient.
2.  **Surface Layer (Cards):** 92% opaque white surfaces with a 20px backdrop blur. These elements use a subtle 1px inner stroke (white at 40% opacity) to simulate the edge of the glass.
3.  **Elevation Shadows:** Instead of neutral black shadows, this design system uses a **Tinted Ambient Shadow**. Specifically: `BoxShadow(color: Color(0x0D2563EB), blurRadius: 20)`. This faint blue tint makes the cards feel like they are floating in a light-filled environment.
4.  **Active Depth:** When an element is pressed, it should scale slightly (98%) and the shadow should tighten, simulating physical proximity to the background surface.

## Shapes

The shape language is defined by ultra-soft, welcoming curves. A standard border radius of **24px** is applied to all primary containers and cards, moving away from "tech-clinical" sharp corners toward a more organic, lifestyle-oriented aesthetic.

Smaller elements like buttons or chips follow a relative scale, but primary interaction points always maintain the signature 24px radius to ensure consistency across the dashboard. High-fidelity icons should mirror this roundedness within their internal paths.

## Components

### Buttons & Interaction
- **Primary Action:** Solid Deep Corporate Blue with white text. 24px corner radius.
- **Secondary/Toggle:** Glassmorphic base. When active, shifts to Smart Blue with a vibrant glow effect.
- **Icons:** Custom high-fidelity strokes. Use a dual-tone approach where the secondary color (Neon Cyan) is used for small technical details within the icon (e.g., the "signal" lines on a Wi-Fi icon).

### Cards
- **Device Cards:** Feature a glassmorphic background, a top-left aligned icon, and bottom-aligned labels. Use the `description-sm` typography for status (e.g., "On", "32% Dimmed").
- **Progress Indicators:** Circular or linear indicators for loading or device states (e.g., thermostat temperature scaling) should use the Neon Cyan accent.

### Inputs & Selection
- **Form Fields:** Use a subtle inset shadow to indicate "hollow" space, with a 1px Smart Blue border on focus.
- **Switches:** Oversized "pill" shapes. The "thumb" should have a subtle 3D-like depth to feel tactile and "squishy."

### Dashboard Specifics
- **Room Chips:** Small rounded-pill filters at the top of the screen to quickly jump between areas of the home. These use a semi-transparent background that becomes solid Smart Blue when selected.