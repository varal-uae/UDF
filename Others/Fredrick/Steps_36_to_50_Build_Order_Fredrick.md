# Steps 36-50 — dependency-free build order

**Owner:** Fredrick · **Team:** UDF · **Date:** 12 August 2026  
**Source:** `My stepsFN06082026.xlsx` → `Fredrick` sheet · **Excel:** `Others/Fredrick/Steps_36_to_50_Implementation_Order.xlsx`

## Track

**Navigation & adaptive shell** — the structural layer the first 35 steps are waiting for. Steps 1–10 gave the frame, 11–20 the input layer, 21–35 the response layer. Every one of those is a *within-screen* concern: there is still no way to move between screens, no tablet layout, no routing, and nothing reachable except a probe page.

All 15 are zero-dependency and verified not already implemented. The order is foundation-first — nothing here is blocked, but following the sequence avoids rework.

## The 15 steps

| # | Layer | Ref ID | Step | Est. time | S. No |
|---|---|---|---|---|---|
| 36 | 36 - Shell Blueprint | SSTLA-012 | Defining the structural assembly blueprint for the mobile split-screen (Contextual Mirror) layout to present evidence and action panels on small screens. | 5 Hours. | 13776 |
| 37 | 37 - Shell Containers | GEN-03270 | Create responsive split-screen and master-detail layout containers for mobile/tablet screens. | 4 Hours | 11488 |
| 38 | 38 - Shell Distribution | SSTLA-010 | Formulate the responsive split-screen grid distributions and layout rules for Micro Task Outsourcing (MTO) panels to maximize readability on small devices. | 8 Hours | 3161 |
| 39 | 39 - Dashboard Grid Spec | SSTLA-018 | Formulating the responsive layout rules to organize parent command sections on 5.5-inch mobile viewports. | 16 Hours. | 2105 |
| 40 | 40 - Navigation Surface | GEN-02334 | Integrate M3 Navigation Rails for tablet views and Bottom App Bars for mobile views. | 4 Hours | 10553 |
| 41 | 41 - Navigation Surface | GEN-02676 | Add a badge counter to the bottom navigation icon that displays the current unread notification count. | 4 Hours | 10894 |
| 42 | 42 - Routing Core | GEN-00999 | Deploy Automated Mobile Deep Link Routing & Context Restoration Engine | 4 Hours | 9233 |
| 43 | 43 - Routing Core | GEN-02082 | Build a deep link routing engine leveraging Navigation component routing. | 4 Hours | 10311 |
| 44 | 44 - Routing Budget | GEN-01474 | Benchmark tab switching latency to ensure view rendering completes under 200ms. | 4 Hours | 9706 |
| 45 | 45 - Content Layout | GEN-00022 | Configure dashboard widgets and audit forms to stack vertically in a single-column or 2x2 grid on mobile. | 4 Hours | 8265 |
| 46 | 46 - Content Guard | GEN-02060 | Ensure text breathes and fits its container without truncating unreadably on 320dp screens. | 4 Hours | 10289 |
| 47 | 47 - Shell State | GEN-02720 | Write the offline UI state management logic that activates when the polling function fails to receive a response within the timeout threshold. | 4 Hours | 10938 |
| 48 | 48 - Shell State | GEN-03437 | Display an "Offline Mode" status banner and pending queue counters on UI screens. | 4 Hours | 11653 |
| 49 | 49 - Destination | IS22-RCGLA-022-AS01 | Build and deploy a responsive preference manager panel inside client settings. | 5 Minutes. | 2039 |
| 50 | 50 - Destination | GEN-03404 | Build the mobile notification preference screen using M3 Switch components. | 4 Hours | 11620 |

## Why this order

**36. SSTLA-012** — The structural blueprint for the split-screen shell, and the first thing to build because everything else in this batch renders inside it. Its own poka-yoke -- "code linters block views that do not extend the master layout wrapper" -- points straight at HabotMasterScaffold from Step 8, so this extends what you already have rather than starting a second layout system.

**37. GEN-03270** — Turns the blueprint into real containers: split-screen and master-detail, switching on the window class the grid tokens already define. Second because a container without a blueprint is a guess, and because Steps 38-39 distribute content inside these containers rather than beside them.

**38. SSTLA-010** — The column distribution inside the split view, plus the pinned-metrics rule its poka-yoke names ("key source metrics are pinned immovably at the top of the viewport"). Needs the containers from Step 37 to exist; needs to be settled before the navigation surfaces claim their own edges of the screen.

**39. SSTLA-018** — The layout rules for command sections on a 5.5-inch viewport -- the Mobile Dashboard Grid Spec. The largest step in the batch at 16 hours. It comes after the split rules because a command section is one pane of that split, and before the nav surfaces because it decides how much room they may take.

**40. GEN-02334** — M3 navigation rails on tablet, bottom app bars on mobile -- the first thing in this codebase that lets a user move between screens rather than within one. Sits on the window-class breakpoints from Step 5 and the shell from Steps 36-39, which is why it is not first despite being the headline.

**41. GEN-02676** — The unread badge on the bottom navigation icon. Directly after the bar it attaches to, and it reuses the status vocabulary and badge component from Step 28 rather than inventing a second kind of badge.

**42. GEN-00999** — The deep-link context manager -- the step names the file. Restores where a user was, not just which screen. Placed after the navigation surfaces because a restored context has to land on a real destination, and before the routing engine because the engine is what calls it.

**43. GEN-02082** — The route table and link parser on top of Step 42. Split from it deliberately: parsing a URL and restoring a context are different failures with different fixes, and the sheet lists them as two steps.

**44. GEN-01474** — The 200ms tab-switch budget, measured. Last of the navigation work because it is the check on all of it -- a benchmark written before the tabs exist measures nothing. Consumes the motion ceiling already set in Step 11.

**45. GEN-00022** — Dashboard widgets and audit forms stacking to a single column or a 2x2 grid on mobile. The first consumer of the grid spec from Step 39, and the step that proves the shell can actually hold content rather than just divide space.

**46. GEN-02060** — Text fits its container without unreadable truncation at 320dp -- the narrowest device in your matrix. Deliberately after the layout steps rather than before: this is the guard that catches what they broke, and it has nothing to check until they exist.

**47. GEN-02720** — The offline state machine, triggered when polling passes its timeout. Before the banner because the banner is a view of this state; building the view first means inventing a second source of truth for whether the app is offline.

**48. GEN-03437** — The Offline Mode banner and pending-queue counters, rendering the state from Step 47. Its metric is a contrast ratio (4.5:1 floor, 7:1 optimal), which the WCAG engine from Step 4 measures directly -- one of the few GEN-* rows in this batch with a metric that genuinely fits its step.

**49. IS22-RCGLA-022-AS01** — The preference manager panel: the first real destination the shell hosts, rather than a probe screen. Richly specified -- mapped preference columns, responsive containers, a spacing decision and a poka-yoke that freezes transitions until a change is written. Needs the shell (36-40) to have somewhere to put it.

**50. GEN-03404** — The notification preference screen, built from M3 switches inside the panel Step 49 delivers. Last because it is the narrowest and most dependent thing in the batch: a screen, inside a panel, inside a shell, reached through a route -- every layer below it built first.

## Why four layout steps before a single navigation control

A navigation rail is an edge of a layout. Deciding where the rail goes before deciding how the screen divides means moving it twice. SSTLA-012 (Step 36) names the constraint itself — its poka-yoke blocks any view that does not extend the master layout wrapper shipped as Step 8 — so this batch extends that scaffold rather than starting a second layout system.

## Data quality flags

No selected row has a contaminated Expected Output this time — an improvement on the last two batches. Four rows carry a **Metric Name that does not describe their step**, and three rich rows have an **empty Completion Measure**:

| S. No | Step | Problem |
|---|---|---|
| 10311 | deep link routing engine | Metric = "Push Notification Click-Through Rate (%)" |
| 9706 | tab-switch latency | Metric = "Information Architecture Task Success Rate" — the 200ms budget is in the Setup Step itself |
| 9233 | deep link context manager | Metric = "Syntax Validity" — thin, but gateable |
| 10289 | 320dp text fitting | Metric = "Step Completion Rate (%)" — generic |
| 13776 / 3161 / 2105 | the three split-screen layout rows | Completion Measures column is **empty** on all three, despite rich Setup Step and poka-yoke columns |
| 2039 | preference manager panel | Estimated Time reads **"5 Minutes"** for a responsive settings panel with database writes — an estimation error, not a scope signal |

## Row quality

Four of the 15 are richly specified the way Steps 1–20 were: **36 (SSTLA-012), 38 (SSTLA-010), 39 (SSTLA-018), 49 (IS22-RCGLA-022)**. The eleven GEN-* rows share a boilerplate Expected Output and Completion Measure, so their gates will derive from the Setup Step, Description and Metric Name. Same ratio as Steps 21–35.

## Still open from earlier batches

- **Step 6 (RCGLA-012)** — Partial, pending your zoom-lock decision.
- **Step 31 (IS38-SGTIM-018)** — Partial, pending physical-device confirmation of the overscroll stretch.
- **Step 5 (SSTLA-004)** — awaiting a reviewer quality score.

None of these blocks this batch.

## Next candidates (Steps 51+)

S.No 389 (swipeable ENUM chip arrays), 3172 (expiry timeline tracker), 3084 (binary checklist steppers), 10839 (WCAG 2.2 AA + screen reader audit), 12786 (accessibility hints), 9222 (first-load / Core Web Vitals), 10124 (segmented buttons), 11092 (autocomplete menu), 11037 (offline fallback queue).

---
*Selection pool: 682 of 1,314 assigned steps have zero dependencies; 35 done leaves 647; 415 of those are front-end steps with uncontaminated output columns. Total effort for this batch: roughly 73 hours, 9–10 working days.*
