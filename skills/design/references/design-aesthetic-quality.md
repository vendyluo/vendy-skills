# Design Aesthetic Quality and Production Structure

## App Shell Rules

When building a sidebar + main workspace layout (Slack, Linear, Notion class):
- Decorative backgrounds default to off
- Surface hierarchy uses background-color steps and shadow only
- Match the project's existing press feedback; use scale feedback only when it fits the interaction and motion constraints
- Keep button radius coherent within each existing component type
- Reuse the current radius scale; a new named scale is a separate design-system decision

## Options Guide

When asked for design options, give only enough variations to expose genuinely different decisions, usually two or three:

- **Dimensions to vary**: visual density, typographic personality, color temperature, layout structure, motion character, amount of decoration, level of abstraction
- **Mix approaches when useful**: include a close-to-current option and a bolder departure when both are credible
- **Progress from safe to bold** only when that range helps the user decide
- Accent-color swaps are not distinct options. Vary layout, typeface, motion, or surface treatment when those are the real choices.

## DESIGN.md Scaffold (Optional, Production UIs)

Use this scaffold only when the project already maintains DESIGN.md or the user requests a durable design artifact. Include only sections that make real decisions:

1. **Visual Theme and Atmosphere**: mood, density, design philosophy in 2-3 sentences
2. **Color Palette and Roles**: semantic name + value + functional role for each color token
3. **Typography Rules**: font family, size scale, weight scale, line-height, letter-spacing
4. **Component Stylings**: buttons (all states), cards (if used), inputs, navigation
5. **Layout Principles**: spacing scale, grid columns, whitespace philosophy
6. **Depth and Elevation**: shadow system or background-color-step system; describe each level
7. **Do's and Don'ts**: 5 to 10 guardrails specific to this project
8. **Responsive Behavior**: breakpoints, how navigation collapses, touch target minimums
9. **Agent Prompt Guide**: color reference (name: value pairs) + 3-5 example component prompts with all values inlined

For a single component or quick prototype, skip this artifact. Keep the direction in the current conversation.

## Pre-Handoff Checklist: Strategic Omissions

Check these only when the current task touches the relevant surface. Report out-of-scope product or compliance gaps instead of silently expanding implementation:

- [ ] **404 path** when routing changed
- [ ] **Back navigation** when the touched flow can create a dead end
- [ ] **Form validation** when inputs or error states changed
- [ ] **Skip-to-content** when repeated navigation lacks an equivalent keyboard path
- [ ] **Consent or legal surfaces** when actual jurisdiction, data behavior, or existing policy requires them

When applicable, these are product requirements rather than visual polish and keep their own authorization boundary.

## Reference Material Priority

When source code and a screenshot are both available, inspect both. Source gives exact tokens and structure; the screenshot gives rendered hierarchy, content fit, and the actual visual target. If they disagree, determine which represents the intended current state rather than automatically privileging either one.

When only a URL is provided: fetching returns extracted text only, with no layout information. For visual references, ask for a screenshot rather than inferring from stripped HTML.

## Adding to Existing UI

When extending an existing interface, first understand its visual vocabulary. Match all of the following before writing the first line of new code:
- Copywriting tone and reading level
- Color palette and semantic color roles
- Hover and click states: scale, color shift, underline, background fill
- Animation style: duration, easing, whether interactions bounce or are ease-out
- Shadow and card treatment
- Layout density and whitespace rhythm
- Border radius choices

If swapping in different content would make the new component look out of place, the vocabulary was not matched closely enough.
