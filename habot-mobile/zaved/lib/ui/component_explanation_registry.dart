import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Registry storing Plain English Explanations for all Global Reference IDs.
class ComponentExplanationRegistry {
  static final Map<String, String> _explanations = {
    'TTMCS-003-A02': '''This task focuses on **Mobile Architecture Infrastructure** and **Material Design 3 Tokenization**. You are establishing the baseline requirements and layout grids for the application.

Here is what you need to build across the stack:

**1. Minimum OS & Base Layout System** You must configure the project to support a strict minimum of iOS 14 and Android 8. From there, you must establish global layout hooks that lock narrow smartphones into a strict 4-column layout matrix, expanding to an 8-column configuration on tablets.

**2. MD3 Dynamic Color Pairings** The application must be wrapped in a root context provider that injects Material 3 design tokens. You must explicitly utilize dynamic color pairings (e.g., matching md.sys.color.background with md.sys.color.on-background) to maintain contrast in shifting ambient light.

**3. The Hardcode Assassin (Mistake-Proofing / Poka-Yoke)** The workspace compilation routine must physically fail if any component tries to bypass the standard design token values with unmapped, hardcoded color values or layout overrides.''',

    'BPTR-0725-A02': '''Imagine you are building the ultimate **"Data Entry Bouncer"** for numeric fields like **Child's Age** and **Earnings**. If a user types "Ten" instead of "10", it breaks the database. This task enforces input masking based on exact specification logs.

Here are the three things you need to build:

**1. Native Number Pad Override** When the user taps these specific text boxes, the app must bypass the standard QWERTY keyboard and force the native numeric keypad to open, reducing tap count and cognitive load.

**2. Physical Keystroke Rejection (Poka-Yoke)** The frontend must act as a physical shield. Using embedded RegEx and input formatters, the text box must physically reject and ignore any alphabetic keystrokes at the DOM/widget level.

**3. Boundary Validation & Inline Errors** You must pull the minimum and maximum bounds for age and earnings from the validation logs. If the user violates these bounds, the system must display clear, inline error messaging directly below the text field.''',

    'SLPLU-014-A02': '''This task focuses on **System Architecture Health** and **Data Visualization**. You are building an interactive "Trace Time Line Chart" to track app latency and performance SLAs (Service Level Agreements) in real-time.

Here are the three things you need to build:

**1. The Interactive SLA Chart** You must build a lightweight line chart tracking milliseconds over time. It requires touch-and-hold gestures to view specific latency values, pinch-to-zoom capabilities for historical data, and clean axes optimized for narrow mobile screens.

**2. The Locked Red Threshold (Poka-Yoke)** The chart must render a hard, high-contrast red alert line indicating the exact SLA failure threshold. Crucially, the chart must lock the Y-axis constraints so users cannot "zoom out" to visually flatten or hide a latency spike.

**3. Automated Ticketing** If the trace time line crosses the red SLA threshold, the system must trigger an automated workflow to generate a UI ticket assigned to the Data Architect, ensuring immediate visibility into structural decay.''',

    'AWCV-013-A02': '''Imagine you are building **"Tinder for Executive Decisions."** To eliminate long meetings, executives will look at a mobile card and simply swipe right to agree or left to disagree on a project consensus.

Here are the three main things you need to build:

**1. The Swipe Interface** The top pane shows the data, and the bottom pane holds massive "Agree" and "Disagree" buttons. The layout must support rapid touch-gesture handling (swiping the card) to register a binary vote.

**2. The Ticking Clock (Auto-Abstain Poka-Yoke)** An expiration timer is set on the voting card. If the timer counts down to zero and the executive hasn't voted, the UI automatically logs their vote as "Abstain" and forces the workflow forward to prevent bottlenecks.

**3. Anti-Meeting Blocker** The UI must physically hide any option to schedule internal video calls about the topic unless explicitly linked to an unresolved system error, forcing rapid, async decision-making.''',

    'SCTSS-018-A02': '''This task focuses on **Interaction & Trust Patterns** for Explainable AI (XAI). You are building a "Trust Layer Accordion" to reveal exactly why an AI made a specific decision or generated a specific code snippet.

Users won't trust an AI decision unless they can verify the 'Why' behind it. However, showing the full logic by default clutters the mobile screen. You must build a collapsible panel that balances cleanliness with transparency.

Here is what you need to build across the stack:

**1. The Rationale Accordion (UI/UX)**
Directly beneath any AI-generated output block, you must build a collapsible accordion labeled 'Show Reasoning'. When opened, it must display the AI's logic, formatted data source citations (from Vector Search), and a confidence score. It must use a strict `max-height` with overflow scrolling to prevent the explanation from taking over the entire screen.

**2. The Forced-Read Lock (Mistake-Proofing / Poka-Yoke)**
To prevent users from blindly accepting AI outputs without checking the facts, the main "Approve" button MUST remain physically locked (disabled) until the user expands the Rationale Accordion at least once.

**3. The Low-Confidence Auto-Expand**
If the AI's confidence score drops below a certain threshold, the accordion must automatically expand on page load and pulse yellow, actively chasing the user to read the warning before they can proceed.''',

    'REF-377-A12': '''This task focuses on **Motion & Animation Systems** and **Form Interaction**. You are building a "Progressive Stepper Wizard" that reveals one question at a time to reduce user fatigue.

To keep the experience fast and game-like, the screens slide in and out laterally. However, if a user double-clicks the "Next" button quickly, it can cause glitches or submit data twice. 

Here is what you need to build across the stack:

**1. The 200ms Animation Lock (Mistake-Proofing / Poka-Yoke)**
During the exact 200ms it takes for the screen to slide in or out, the "Next" and "Previous" buttons must be physically disabled. This prevents rapid clicking and ensures 100% reliable state transitions. Previous steps must also be unmounted from the DOM to prevent accidental back-edits.

**2. The Chaser Pulse (UX)**
If a user stalls on a screen for too long, the system must trigger a subtle pulsing animation on the "Next" button to gently chase them into continuing the flow.

**3. Reduced Motion Support (Accessibility)**
The animation engine must check the device's accessibility settings. If the user prefers reduced motion, the sliding animations must automatically disable, falling back to instant transitions.''',

    'BPTR-0334-A15': '''This task focuses on **Typography Systems** and **Accessibility**. You are configuring the "Typographic Scaling Ratios" for the entire application.

When text doesn't scale properly on smaller screens, users are forced to pinch-to-zoom, which breaks the layout. 

Here is what you need to build across the stack:

**1. Fluid Scaling & Strict WCAG Ratios (UI/UX)**
You must implement fluid typography scaling (using clamp functions) so fonts scale dynamically and remain highly legible without zooming. You must also enforce strict contrast ratios, targeting WCAG AAA (7.0:1) to ensure high visibility in outdoor mobile environments.

**2. The Custom Font Blocker (Mistake-Proofing / Poka-Yoke)**
Developers often tweak font sizes manually to make things fit, ruining the visual hierarchy. You must implement a system that physically removes the ability to use custom font-size inputs. If a developer uses an unauthorized font size or bypasses the token scale, it must trigger visual breakage in staging or fail the build.''',

    'TTMCS-002-A01': '''This task focuses on **Design System Hardening** and **Semantic Colors**. You are establishing "Binary Semantic Color Gates" (e.g., Green for compliant/true, Red for non-compliant/false).

When field workers are outside in the sun, they need to know instantly if an input is valid without reading long text reports.

Here is what you need to build across the stack:

**1. Semantic Intent Tokens (UI/UX)**
You must set up a global semantic state color scheme mapped to Material Design 3. The colors must dynamically adapt to Light and Dark modes while strictly maintaining WCAG 2.1 AA accessibility ratios. The text must use bold treatments alongside these validation color flags to maximize legibility.

**2. The Raw Hex Assasin (Mistake-Proofing / Poka-Yoke)**
You must completely disable raw style choices to preserve global color uniformity. The application engine's linting process must block styling declarations that bypass the validated dynamic token layer. Inserting raw hex keys (like #FF0000) must stop code compilation routines and reject the pull request.''',

    'USMBL-014-A01': '''This task focuses on **UI/UX Layout** and **Onboarding Patterns**. You are building "Empty State Boilerplates."

When a user opens a dashboard and they haven't created any data yet, a blank white screen looks broken and causes panic. You need to replace empty arrays with a friendly onboarding mechanism.

Here is what you need to build across the stack:

**1. Centered Flexbox Orientation** You must build a component that perfectly centers an illustration, a short text prompt, and a primary CTA (Call to Action) button.

**2. The Chaser Pulse (UX)** To visually guide the user, the primary CTA button must pulse gently, "chasing" the user to initiate data entry.

**3. Conditional Rendering (Architecture)** The boilerplate must automatically detect null or empty datasets. If the array length is 0, it dynamically swaps the data table for this empty state component, ensuring users always have a clear path forward.''',

    'BPTR-0725-A01': '''Imagine you are asking a user for their **Child's Age** and their **Earnings**. If they type "Ten" instead of "10", it breaks the database. This task is about building a "Poka-Yoke" (mistake-proofing) system to make it physically impossible for the user to enter anything other than numbers.

Here are the three things you need to build:

**1. The Number Pad Override** When the user taps the text box on their phone, the app must **not** show the standard QWERTY (ABC) keyboard. Instead, it must force the phone to pop up the native numeric keypad (123). This reduces the user's cognitive load and saves them from switching keyboard tabs.

**2. The Physical Blocker (Input Masking)** Even if the user has an external keyboard or tries to paste text, the app acts as a physical bouncer. If they press a letter (like "A" or "Z"), the text box completely ignores the keystroke. It will only accept numbers.

**3. Boundaries & Inline Errors** You need to set minimum and maximum rules (e.g., a child's age cannot be 300). If they type something outside of these boundaries, a clear, red error message must immediately appear directly below the text box.''',

    'DPNDL-011-A01': '''This task requires you to build the **Global Top Application Bar** (the fixed header at the very top of your app). This bar acts as the anchor for the entire application, telling the user exactly where they are and giving them quick access to menus.

Here are the three main things you need to build:

**1. The Strict 64dp Structure** The top bar must be exactly 64dp tall---no more, no less. It is broken into three zones:
- **Left Zone:** A button to open the side navigation menu.
- **Center Zone:** A title that dynamically changes based on what page the user is currently looking at.
- **Right Zone:** Quick-action shortcut buttons (like settings or profile).

**2. Phantom Padding & Fixed Scrolling** The icons in the header might look small, but they need "phantom padding." This means adding invisible clickable space around the icons so users with larger fingers can tap them easily without missing. Additionally, when the user scrolls down the page, this header must remain permanently fixed at the top of the screen.

**3. The Code Security (Mistake-Proofing)** The task mandates compile-time safety for the routing linkages. This means if a developer tries to add this top bar to a screen but forgets to hook up the menu button or the title logic, the code physically will not compile, preventing a broken header from ever reaching production.''',

    'AWCV-013-A01': '''Imagine you are building **"Tinder for Executive Decisions."** Instead of scheduling a 30-minute meeting to discuss a project change, executives receive a notification, look at a card on their phone, and simply swipe right to approve or swipe left to reject.

Here are the three main things you need to build:

**1. The Swipe Interface (Tinder-Style UX)** The screen is divided into two halves. The top half shows the facts (the data pane: what the decision is about). The bottom half contains massive buttons to Agree or Disagree. The user can either tap the buttons or physically swipe the card left or right on their screen to vote.

**2. The Ticking Clock (Auto-Abstain)** Executives often ignore emails, which stalls projects. To fix this, you must build an Expiration Timer on the card. If the timer counts down to zero and the executive hasn't swiped, the code must automatically log their vote as "Abstain" and force the project forward anyway.

**3. The Anti-Meeting Blocker** To completely eliminate "groupthink" and wasted time, the interface intentionally hides any option to schedule a video call about the decision. The system forces them to read the data and make a choice on the spot.''',

    'REF-362-A01': '''Imagine you are building a smart **"Auto-Corrector & Bouncer"** for your app's text boxes. When users are typing things like Dates, IDs, or Currency, they often make mistakes or forget the exact format (like adding dashes or commas). This task forces the app to do the heavy lifting for them.

Here are the three main things you need to build:

**1. The Auto-Formatter & Keyboard Trigger** When the user taps a field (like a Date field), two things happen instantly: the phone automatically pops up the correct keyboard (the number pad, not the alphabet), and as they type, the text box formats itself automatically (e.g., typing "12252026" magically spaces out to "12 / 25 / 2026").

**2. The Invisible Bouncer (Keystroke Nullification)** The code acts as a physical bouncer at the door of the database. If a user tries to type a letter "A" into a Currency or Date field, the text box completely ignores it. The bad keystroke is nullified before it even registers on the screen.

**3. The "3-Strike" Helper Tooltip** If a user is confused and tries to type an invalid character 3 times in a row, the app realizes they are struggling. On the 3rd failed attempt, a tiny, helpful popup (a micro-tooltip) appears next to the box, showing them the exact format they need to use.''',

    'BLGTA-048': '''Imagine you are building a strict **"Multiple Choice Only" categorization tool** for complex tax and accounting expenses. Because typing things manually causes massive headaches for accountants (due to spelling errors or wrong categories), you must completely disable the user's ability to type freely.

Here are the three main things you need to build:

**1. The "No Typing Allowed" Picklists (Bottom Sheets)** Instead of regular text boxes, users must tap a field and select from a pop-up menu (a native bottom sheet or action sheet).
- If the list of options is short, just show the big, easy-to-tap buttons.
- If the list has more than 10 options, you must add a search bar inside that pop-up menu so they can filter the choices quickly.

**2. The Checkmark & Touch Targets** Because users will be doing this on mobile, the buttons in the menu must be large and easy to hit. Once they tap an option, there must be a highly visible checkmark next to their selection so they have absolute confidence in what they just picked.

**3. The Submit Freeze (Mistake-Proofing)** To prevent users from accidentally skipping a question, the "Submit" button at the bottom of the screen must be completely frozen (disabled and greyed out). It will only unlock once every single mandatory dropdown has a valid selection.''',

    'DSDD-002': '''The core goal of this task is to stop users from uploading massive, heavy files (like giant PDFs of financial statements) that will crash your servers or eat up mobile data, and to present a clean error message when they are blocked.

**1. The Backend & Cloud Security (The Perimeter Bouncer)** Before data even reaches your main servers, your API Gateway must act as a bouncer. It looks at the size of the incoming file (the Content-Length header). If the payload exceeds a strict limit (e.g., trying to upload a 50MB file on a cellular network), the API Gateway instantly physically cuts the connection. By rejecting it at the "edge," you save money on server costs (Cloud Run compute waste).

**2. The Database Layer (The Django Models)** On the database side, you must create Django database models specifically for "Income Statements." Furthermore, if a user's upload gets blocked by the bouncer, the backend must instantly generate an automated "incident ticket" tracking that a dropped packet occurred, saving it into the database for analytics.

**3. The Frontend & Design (The Warning Signs)** When the API Gateway rejects the upload, the mobile app needs to handle it gracefully instead of just freezing.
- **Progressive Loaders:** While the app is trying to upload, it must show a loading indicator.
- **The Error UI:** When the upload fails, the app must display a "Sending Failed: Payload Over Limit" message.
- **Strict Design Rules:** The design must use Material Design Cards, adhere to a strict 8dp layout grid, use sentence-case for error text, and pull exact colors from the system's "error container" tonal palette.''',

    'FIEVR-002': '''The goal of this task is to make your app **"Offline-First"** by silently downloading its master rulebook the moment the user opens the app.

Instead of the app constantly asking the database for rules every time a user taps a button (which is slow and uses mobile data), the app will download a single JSON file (the Universal Data Dictionary - UDD) on launch and save it directly to the phone's local memory.

Here are the three main things you need to build:

**1. The Background Sync & Caching (The Engine)** When the app opens, it must immediately reach out to the API to fetch the UDD JSON file. It then saves (caches) this data locally on the phone. By following Google's "Offline-First Architecture" guidelines, you ensure that even if the user drives into a tunnel and loses cell service, the app still knows exactly how to function because the rules are saved locally.

**2. Non-Blocking Skeleton Loaders (The UX/Design)** Fetching data takes a second or two. You are strictly forbidden from freezing the app or locking the screen while this happens. Instead, the UI must display "Skeleton Loaders" (those gray, shimmering placeholder boxes you see on apps like YouTube or LinkedIn before content loads) and a subtle "syncing" indicator, allowing the user to start looking at the app while the rules download in the background.

**3. Zero Data Loss & Perimeter Limits (The Architecture)** Because you have strict API Gateway payload limits (from your previous tickets), this JSON rulebook must be extremely lightweight. Your target metric is a **99% to 100% sync success rate**. If the connection drops mid-download, the app must queue the action and retry without losing any data.''',

    'Row-1367.0 (API Gateway Rate Limits)': '''This is primarily a **Backend Infrastructure & Security** task, but it directly impacts how the frontend behaves.

Imagine you are setting up a **"Speed Limit"** for how fast your app is allowed to talk to your servers. To prevent hackers from spamming your system (DDoS attacks) or to stop a glitchy phone from making 1,000 requests a second, your API Gateway acts as a traffic cop.

Here is what you need to build across the stack:

**1. The API Speed Limit (Backend Security)** You must configure your Cloud API Gateway to enforce a strict quota based on OWASP security standards. Each user/device is only allowed between 60 and 150 requests per minute. Anything over that limit gets physically blocked with an "HTTP 429: Too Many Requests" error. You also force TLS 1.3 to ensure the connection is heavily encrypted.

**2. The Device Metadata Tracker (Frontend Data)** Before making requests, the app needs to gather specific hardware data (Mobile Platform, OS Version, Device Type, Screen Dimensions). This data is attached to the API calls so the backend security knows exactly *who* and *what* is making the requests, making it easier to identify and block malicious bots.

**3. The "Slow Down" UX (Frontend Design)** When a user (or a bug) actually hits that speed limit and receives the HTTP 429 error, the app cannot just crash. It needs a graceful "Too Many Requests" UI to tell the user to wait a moment before trying again.''',

    'UFHT-037': '''This task is all about building an **"Urgent Referral & Share Hub"**. It merges a time-sensitive notification system with a frictionless way for users to generate and share a custom link.

*(Note: The ticket data mentions both a Referral Link Generator and a 30-day "Benefits/Life Event" window. This usually means the system is incentivizing users to refer peers or take immediate action within a strict time limit).*

Here are the three main things you need to build:

**1. The Shapeshifting Referral Card** You need to build a Material Design "Outlined Card" that holds the user's custom referral link. However, it must be highly responsive. On a tablet or web, it looks like a full card. On a narrow mobile phone, the UI must automatically collapse this large card into a tiny "Floating Action Button" (FAB) in the corner to save screen space.

**2. The One-Tap Native Share (No Copy/Pasting)** Users hate manually copying links. You need to hook into the native Mobile OS sharing system (like the iOS Share Sheet or Android Share Intent). When they tap a social button, it should instantly pop open their phone's native menu to text or message the link to a friend.

**3. The Urgency Engine (Timers & Deep Links)** There is a strict deadline attached to this action (e.g., a 14-day window).
- **The UI:** You must build a highly visible countdown timer banner (e.g., "14 Days Left") using high-contrast accent colors.
- **The Flow:** When the system sends the user a push notification ("Action Required"), tapping that notification must "deep link" them directly into this specific referral/action screen, bypassing the home screen completely.''',

    'GTBPU-001': '''This task focuses on building the absolute first thing a user sees---a seamless transition from the app's loading screen (Splash) into a highly accessible, foolproof Login and Profile tracking card. It is heavily focused on mobile usability and preventing user frustration right at the front door.

Here are the three main things you need to build:

**1. The Seamless "No-Drop" Transition** The app must transition smoothly from the Splash screen directly into a single-column interactive form. There can be no abrupt flashes or jarring jumps. The goal is to get the user into an interactive state within the first few seconds of opening the app to prevent them from abandoning it.

**2. Fat-Finger Friendly & Fluid Design (Accessibility)** This UI must pass strict accessibility checks.
- **Touch Targets:** Every button and text field must be at least 48px tall so they are easy to tap without precision.
- **Mandatory Fields:** Any required field must be clearly marked with a red asterisk (*).
- **Fluid Layout:** Text must scale up or down depending on the user's phone settings, and the mobile screen must have exactly a 16px margin on the edges.

**3. Rotation & Keyboard Immunity** When the user taps a text box, the phone's keyboard pops up. Your layout must automatically push itself up so the keyboard doesn't hide the text fields. Additionally, if the user rotates their phone sideways, the app must perfectly remember whatever they were typing and adapt its shape elastically, rather than deleting their text and resetting the page.''',

    'MCCEA-001': '''While the previous task was about building the login screen for the *user*, this task is about building the **"Admin Dashboard"** for the people tracking those users. Specifically, you are building an analytics engine to monitor "Churn"---exactly where and when users give up and drop out of the sign-up process.

*(Note: Your ticket data includes some strict UI rules carried over from the login screen, meaning this data-heavy admin view must be just as mobile-friendly and accessible as the front-end app).*

Here are the three main things you need to build:

**1. Shapeshifting "Adaptive Container" Charts** Analytics dashboards look great on large desktop monitors but become an unreadable mess on mobile phones. You must build "adaptive containers."
- On a desktop, it shows a full, complex data chart.
- On a mobile phone, that exact same container automatically simplifies the data, turning complex graphs into high-level summary cards that are easy to read in a single column.

**2. Real-Time Streaming (No Refreshing Needed)** This dashboard tracks sign-up drops in real-time. The frontend must hook into a live data stream (Pub/Sub). As users drop off the platform, the charts must update instantly on the screen without the admin ever needing to hit the refresh button.

**3. Fat-Finger Friendly Data Controls** Even though this is a complex analytics tool, the strict usability rules still apply. Any interactive element---like date-range pickers, chart toggles, or export buttons---must be at least 48px tall and wide. Furthermore, if the admin rotates their phone sideways to look at a chart, the app must perfectly remember their filter settings and not reset the page.''',

    'OPMV-002': '''This task requires you to build a **"Dynamic Leaderboard & Points Ledger"**. It tracks user performance points (which act like actual money) and ranks them into different tiers.

*(Note: Just like previous tasks, this ticket includes strict API security rules to prevent massive payload uploads, meaning this ledger must be lightweight and handle errors gracefully).*

Here are the three main things you need to build:

**1. Subtle Color-Coded Tiers** You are building a list or table of users/performance records. Based on a user's current tier (e.g., Bronze, Silver, Gold), the background color of their specific row must change automatically. The key word here is *subtle*---you must use soft, light background colors so the text on top remains perfectly readable and passes WCAG accessibility standards.

**2. The Responsive Shapeshifter (Mobile to Web)** A standard data table looks great on a desktop monitor but is terrible on a phone.
- On a Web or Tablet screen, this should look like a standard, wide Data Table with columns.
- On a Mobile screen, it must transform into a vertical list of stacked "Cards" so users don't have to scroll horizontally to see their points.

**3. Zero-Tolerance Ledger & Instant UI Updates** Because these points hold monetary value, the data must be 100% accurate. When a qualifying event happens (like redeeming points), the backend processes it in under 1 second, and the frontend UI must update the user's tier and row color instantly via a real-time state listener.''',

    'TECH-ENG-005': '''This is primarily a **Data Engineering & Backend** task, but it requires a frontend administrative dashboard to monitor the health of the data stream.

You are building a **"Live Event Firehose."** Every time something happens in your system (a click, an error, a transaction), it fires an event into Google BigQuery. To ensure the database doesn't crash, you must build a strict bouncer (Schema Validation) that checks every piece of data before it enters the database.

Here is what you need to build across the stack:

**1. The BigQuery Schema (The Blueprint)** You must define the exact columns for the database table. It must include exactly five things:
- **Event Name** (What happened?)
- **Timestamp** (When did it happen?)
- **Service Hash** (A unique ID for security/tracking)
- **Latency Metric** (How many milliseconds did it take?)
- **Error Code** (Did it fail? If not, this is blank/null).

**2. 100% Zero-Tolerance Validation** The ticket states there is a "zero-tolerance" policy for bad data. If an incoming event is missing the latency_metric or the timestamp is formatted incorrectly, the pipeline must reject it completely. It is either a 100% Pass or a Fail.

**3. The Monitoring Dashboard (Frontend)** Administrators need to see this streaming pipeline in action. You need to build a UI that shows the live events flowing into BigQuery, along with a prominent "Pass/Fail" indicator for the schema health.''',

    'TECH-ENG-023': '''This task requires you to build a **"Universal Engineering Notification Center"**---essentially a high-priority, unified inbox specifically for your engineering team to monitor system health and infrastructure alerts.

Here are the three main things you need to build across the stack:

**1. The Alert Taxonomy (The Rulebook)** Before building the UI, you must define exactly *what* events trigger an alert. This means creating a strict list of infrastructure alert types (e.g., "Server CPU > 90%", "API Gateway 429 Errors", or "Database Connection Dropped").

**2. The 99.9% Delivery Guarantee (Backend)** Because these are critical infrastructure alerts, an email going to spam is unacceptable. The backend must be configured using Google Cloud Monitoring standards to guarantee that at least 95% (ideally 100%) of these notifications hit the engineer's device within a strict time window (SLA). The system needs a way to track if a message was successfully delivered.

**3. The Unified Inbox (Frontend Design & UX)** The engineers need a fast, readable dashboard to see these alerts. It needs to clearly highlight the severity of the issue (Critical vs. Warning) and allow them to acknowledge or dismiss the alert quickly so the team knows who is handling the problem.''',

    'TECH-ENG-038': '''This is a **DevOps & Frontend Accessibility** task. You are building a strict robotic "Bouncer" (a CI/CD Linter Gate) for your code repository that ensures the app is fully usable by people with visual impairments.

Here is what you need to build across the stack:

**1. The CI/CD Linter Gate (The DevOps Bouncer)** Whenever a developer tries to publish an update to the app or website, a script (like Google Cloud Build) automatically scans their code. It uses tools like axe-core to check for missing "ARIA labels" (or in Flutter, "Semantic labels"). These are the invisible text tags that screen readers use to describe buttons to blind users.

**2. The 100% Zero-Tolerance Rule** This scanner is ruthless. To meet strict WCAG 2.2 AA standards, the compliance rate must be exactly 100%. If a developer forgets to add an accessibility label to even a single button, the pipeline immediately triggers a "FAIL" state, completely blocking the code from going live until it is fixed.

**3. The CI/CD Dashboard (The Frontend)** Engineers need a dashboard to see exactly why their code was rejected. You need to build a UI that shows the pipeline execution status, highlights the exact accessibility failures, and provides clear Pass/Fail metrics.''',

    'NLM-APS-003': '''This is a **High-Level Cloud Security & Compliance** task specifically tailored for an Enterprise AI environment (NotebookLM).

Normally, in standard software, security keys are set to "auto-rotate" every 90 days to keep things safe. However, in ultra-secure Enterprise environments, the customer demands absolute control over their data. If a key auto-rotates in the middle of a massive machine-learning task, it can break everything. Therefore, this ticket strictly requires you to disable auto-rotation.

Here is what you need to build across the stack:

**1. The "Never Rotate" Rule (Backend Security)** You must configure the Customer-Managed Encryption Keys (CMEK) and the Virtual Private Cloud Service Controls (VPC-SC) so that the Key Rotation Policy is strictly set to **"Never" (Manual rotation only)**.

**2. 100% Compliance Validation (The Poka-Yoke)** Because this involves NIST (National Institute of Standards and Technology) and ISO 27001 compliance, the system has a near-zero tolerance for error. The compliance engine must verify that the configuration is accurate. If a rogue admin tries to turn on "auto-rotate," the system must flag it as a "FAIL" and instantly block the change to maintain the 100% optimal compliance metric.

**3. The Enterprise Security Console (Frontend UX)** Security administrators need a dashboard to view the status of their encryption keys, see the VPC-SC enforcement status, and visually verify that their compliance score is at a perfect 100% (Pass).''',

    'PELCE-019-01': '''This task is focused on **UX Writing & Component Architecture**. You are building a strict library of Call-To-Action (CTA) buttons that eliminate all user confusion by communicating exactly what the machine will do when tapped.

Here is what you need to build across the stack:

**1. "English Code" System Verbs (UX Writing)** Friendly but vague button text like "Let's Go", "Next", or "Awesome" is strictly forbidden. Every primary button must use a strict "machine-action verb" (e.g., "AUTHORIZE", "SUBMIT", "DELETE", "AUTHENTICATE"). The user must know the exact database action they are triggering.

**2. The 100% Width Pill Button (UI Design)** The button design is highly regimented. You must use a Material Design 3 "Filled Button". On mobile devices, this button must span 100% of the screen width (minus standard padding) and feature a strict 100px border-radius, creating a distinct "pill" shape.

**3. The Component Enforcer (Code Security)** To maintain the required "95% - 100% UI Design-System Adherence Rate," developers cannot be trusted to type whatever they want into a button. You must build a custom Flutter button component that checks its own text label. If a developer tries to use a non-compliant verb, the code will throw an error.''',

    'IRBCA-061-A05': '''This task focuses on building a highly secure, ergonomic **"Board Resolution Approval"** screen for Corporate Secretaries and Board Members. Because this deals with legally binding digital signatures, the interface must be extremely deliberate, secure, and accessible.

Here are the three main things you need to build across the stack:

**1. The Ghost Button (DOM Eradication for Security)** Standard apps just "grey out" a button if you aren't allowed to click it. For strict legal compliance, if a user is *not* an authorized board signatory, the approval button must be completely eradicated from the code (removed from the widget tree/DOM entirely) to remove any clutter or confusion. It literally does not exist for them.

**2. The Ergonomic Thumb-Sweep (Mobile UX)** When an authorized board member uses their phone, the approval button---a Material Design 3 Floating Action Button (FAB)---must sit perfectly in the bottom-right corner. This places it directly in the natural "sweep path" of a user's right thumb, making the legal sign-off frictionless.

**3. High-Density Legal Text & High-Contrast Colors** Legal resolutions are long. The text block must use "high-density typography" (tight, highly readable text) so the board member doesn't have to scroll endlessly. Furthermore, the screen must use a strict, high-contrast color palette to boldly differentiate a "Pending Signature" state (e.g., stark yellow/black) from a "Final Document" state.''',

    'PELCE-019-14': '''While your previous task was to *build* the strict "Machine-Action Verb" buttons, this task is about building the **"Design System Repository Manager."** You need an administrative interface to officially version-control, save, and merge those finalized buttons into your company's core UI library.

Because this deals with ISO 9001 Quality Management standards, there is a strict emphasis on tracking exactly *what* is being merged (versions, dependencies) and ensuring the process is marked as 100% "Complete".

Here are the three main things you need to build across the stack:

**1. The Component Preview Pane** Even though this is an admin dashboard, it must display a live preview of the UI component being merged. The preview must strictly demonstrate the rules from the previous step: Material 3 Filled Buttons, a 100px perfect-pill border radius, and a 100% screen width layout for the mobile preview.

**2. The ISO 9001 Metadata Tracker** The UI must display atomic-level data about the code being merged. You need data fields clearly listing the Library Name, Library Version, Component Count, Installation Status, and Dependency List.

**3. The "Machine-Action" Merge Controls** Following your own UX writing rules, the buttons the admin uses to approve this merge cannot say "Looks good!" or "Finish." They must use strict English Code system verbs like "MERGE REPOSITORY," "SAVE COMPONENT," or "UPDATE LIBRARY."''',

    'HSCPE-007': '''This task bridges the gap between **Deep Backend Infrastructure** and **Frontend UI/UX**.

Your backend engineers are tuning the hard drives (EXT4 Filesystem) to make the Redis database run faster. However, the system administrators need a dashboard to monitor these active tuning parameters. Because server dashboards often get overly complex and break on mobile devices, your primary goal is to build a clean, strictly formatted UI that respects typography rules and handles network throttling gracefully.

Here are the three main things you need to build across the stack:

**1. Strict Material 3 Typography (The Data View)** The dashboard will display the active storage parameters. You are strictly required to use the Material Design 3 body-medium text token for these parameters. To prove compliance, the UI must actually output its own atomic typography data (Font Name, Size, Line Height) to the compliance tracker.

**2. The Smart Data Stacker (Responsive Mobile UI)** A massive table of database metrics looks terrible on a phone. The interface must be "clean and focused." On mobile devices, the data must automatically transform from a wide table into a neatly stacked vertical "Data Sheet" so the administrator doesn't have to scroll horizontally.

**3. The Throttling Defender (Security Fallback UX)** Server dashboards constantly poll the backend for live data. If the network spikes, the API Gateway (from your previous tasks) will block the dashboard. When this happens, the UI must catch the block and render an elegant, contextual popup alert stating exactly: "Too Many Requests, Retrying in X Seconds", complete with a live countdown, rather than crashing or showing a generic error.''',

    'RCGLA-028-A01': '''We need to build the core foundation for how the app looks on a phone. Specifically, you are creating the "Mobile-First" rules that stop users from having to scroll left and right.

Instead of stretching a web page across a tiny screen, we are forcing all content to automatically stack on top of each other when viewed on a handheld device.

Here are the three main things you need to build across the stack:

**1. The 360px Stacking Rule (Responsive Architecture)** You are establishing a technical limit. When the phone's screen is 360 logical pixels wide (a standard compact phone size), the app *must* instantly turn into a single, clean column that scrolls vertically. Any horizontal information (like a wide multi-column data table) must collapse into a vertical feed of stacked "cards."

**2. Standardized Spacing (The 16dp Gutter)** To make the app easy to read and touch with one thumb, you are locking the gaps between all content blocks to exactly 16dp increments.

**3. The Invisible Wall (Mistake-Proofing)** To guarantee a bug-free experience, you are adding strict code parameters (overflow-x: hidden) that create an invisible wall on the left and right sides of the screen. This physically blocks any "bad code" from causing content to bleed off the side of the screen, removing the need for users to pinch-to-zoom.''',

    'BPWSO-007-12': '''This task bridges **Graph Database Architecture** and **Frontend Accessibility**. You are building an interactive "Terminal Alert & Lineage Canvas"---a dashboard where engineers can visually track data pipelines and see automated code linter errors.

Because graph databases map complex relationships, the system must strictly prevent "infinite loops" (closed-loop cycles). When an error like this occurs, the UI must alert the user using highly accessible, strictly formatted error text.

Here is what you need to build across the stack:

**1. The AAA Accessible Alert Terminal (UI/UX)** When the Linter finds an error, it spits out a terminal alert. This text *must* use a distinct red typography scale. Crucially, the red text against its background must pass the strictest WCAG 2.2 AAA contrast ratio requirement (≥7:1). If it's a dark background, you need a vibrant, light red; if it's a light background, a deep, dark crimson.

**2. The Panning Lineage Canvas (Mobile UX)** Engineers need to see the "pipeline route" that caused the error. You must build an interactive canvas where users can pan and drag around the network graph.
- The lines connecting nodes must use a high-visibility secondary accent color.
- Every clickable node or link *must* have a minimum 48dp touch target.
- On small mobile screens, the deep, granular trace logs must be hidden inside expandable accordion drawers to save space.

**3. The Cycle-Blocker Engine (Backend/Logic Poka-Yoke)** The code must contain structural validation logic that physically blocks any data ingestion that creates an invalid closed-loop cycle (e.g., Node A points to Node B, which points back to Node A). If this happens, it immediately triggers the high-latency latency alarm and renders the red terminal alert on the frontend.''',

    'USMBL-017-A01': '''This task focuses on **Micro-Interaction Architecture** and **Data Integrity**. You are building an "Anti-Hammering" Submit Button (the LoadingSubmitButton).

When users experience slow network speeds, they often repeatedly mash the "Submit" button out of frustration. This causes the app to send duplicate requests to the database, resulting in duplicate payments or corrupted data. This task creates a foolproof system to prevent that, while keeping the user informed.

Here is what you need to build across the stack:

**1. The Dimension-Locked Spinner (UI/UX)** When the user taps "Submit", the button text instantly disappears and is replaced by a smooth Material Design spinner. Crucially, the button must **not** change its height or width when this happens. If the button shrinks or grows, it will cause the entire page layout to jump, which feels glitchy and broken. The button must also shift to a muted color to clearly indicate it is disabled.

**2. The Form Lockdown (State Management)** The moment the button is tapped, the code must instantly "grey out" and lock all adjacent form fields (text boxes, checkboxes). This prevents the user from changing their data while the app is actively trying to send it.

**3. The Deadlock Breaker (Safety Timeout)** If the app sends the data but the server crashes or the user's cell service drops mid-route, you cannot leave the app frozen in an infinite loading state. You must program a "Global Timeout Bound" (e.g., 15 seconds). If the server doesn't respond in time, the local clock forces the button to reset, unlocking the form and allowing the user to try again.''',

    'ARCPE-005-01': '''This task focuses on building an **"AI Confidence Scorer"** component for a data analytics dashboard.

When your application uses an LLM (Large Language Model) to generate an answer or process data, the AI usually outputs a "confidence score" (how sure it is that its answer is correct). To help human reviewers rapidly triage and review the AI's work, you need to build dynamic visual indicators that display this score.

Here is what you need to build across the stack:

**1. High-Contrast Pill Badges (UI/UX)** You must design a "pill" shaped badge that sits next to the AI's output. The color of this badge must change dynamically based on the score (e.g., Green for 95% confident, Red for 40% confident). To ensure "rapid human triage," the text inside these badges must be highly scannable and pass strict WCAG 2.1 AA contrast ratios (at least 4.5:1 against the background).

**2. The Accessibility Target (The 48px Rule)** Even though pill badges are often small, the ticket strictly dictates an optimal "Touch Target Size" of 48px to pass accessibility standards. This means the invisible, clickable area surrounding the badge must be large enough that a user on a mobile device can easily tap it with a thumb to see more details without accidentally tapping the wrong thing.

**3. Dynamic Logic Mapping (Frontend Code)** The frontend code must include a logic router. It evaluates the numerical score coming from the database and automatically maps it to the correct visual state (color, icon, and semantic label) before rendering it on the screen.''',

    'CCPME-002-A16': '''This task is focused on building a **"Multi-Step Registration Wizard"** specifically designed to handle dynamic data---like a parent registering multiple children for a service, school, or clinic.

Because form fatigue is a major reason users abandon sign-ups, this interface must be broken down into clear steps, handle errors gracefully, and adapt heavily based on whether the user is on a phone or a computer.

Here is what you need to build across the stack:

**1. The Brand-Aware Progress Bar (UI/UX)** Users need to know exactly how long this registration will take. You must build a linear progress bar at the very top of the form (e.g., Step 2 of 4). It must use your core brand colors to clearly indicate active versus completed steps.

**2. Inline Error Mapping (Mistake-Proofing)** If a parent forgets to type a child's last name or enters an invalid birthdate, the red error text must appear *directly underneath that specific text box* (inline), rather than clumping all the errors into a giant red box at the top of the screen.

**3. The Mobile Bottom-Sheet (Responsive Architecture)** Complex forms with multiple dropdowns and "Add Another Child" buttons get incredibly cluttered on a phone screen. To solve this, the mobile view must utilize a "Bottom Sheet"---a card that slides up from the bottom of the screen over the form, allowing users to make selections or add a child without navigating away from the page.''',

    'HSCPE-021': '''This task bridges **Reliability Engineering** (System Startup Probes) and **Information Security** (Document Access). You are building a secure "System Initialization & Document Repository" dashboard.

When the app boots up or accesses a secure database, it runs a series of startup checks (probes) to verify the user's security clearance. It then loads the documents they are allowed to see, while strictly locking down the ones they aren't.

Here is what you need to build across the stack:

**1. The Scannable Milestone Icons (MD3 Typography & Iconography)** As the system loads (checking security keys, fetching documents), the user must see the progress. You are required to use explicit, highly scannable Material Design 3 icons (e.g., loading spinners transitioning into crisp checkmarks or lock icons) arranged neatly in grid rows so the user instantly understands the system's status.

**2. The Mobile Log Tabs (Responsive UX)** A system startup generates a massive wall of text logs (initialization logs). On a tiny mobile screen, this would push all useful interface elements off the page. You must hide these deep, granular logs behind clean UI "Tabs", saving mobile display space while still allowing engineers to tap in and read them if something goes wrong.

**3. The Crisp Lock Banners & Security Poka-Yoke** Once the repository loads, the system must visually enforce Document Isolation. If a user does not have the clearance for a specific file, the system must drop the fetch request entirely. On the UI, this restricted file must display a "crisp visual lock banner," clearly showing a lock icon and providing an "Request Access" pathway rather than just crashing.''',

    'IS26-RCGLA-024-AS01-A01': '''This task focuses on **Core UI Framework & Responsive Layout** combined with **Micro-Interaction Engineering**. You are building a highly intelligent "Floating Action Button" (FAB)---the primary button that hovers in the bottom-right corner of the app to create a new item or launch a wizard.

Because this button launches critical system actions, it must be context-aware, responsive, and spam-proof.

Here is what you need to build across the stack:

**1. The Shapeshifting Button (Responsive UX)** A small circular button with an icon is perfect for a phone. However, on a large desktop monitor, a tiny circle looks lost. You must build a button that automatically shapeshifts. On mobile viewports, it collapses into a standard, clean icon button. On large monitors, it automatically expands to display a full, descriptive text label alongside the icon.

**2. The Security Ghost (Contextual Access)** If a user is logged in but does not have the correct "Write Permissions" to create a new item, they shouldn't even see the button. The code must evaluate the user's access level and, if unauthorized, completely hide the button from the interface so they cannot interact with it.

**3. Anti-Spam Shield (Double-Tap Prevention)** Users tend to double-tap or rapidly click buttons when systems are loading. Your button must include strict "double-tap prevention logic" (Poka-Yoke). The instant it is clicked once, it must physically block any subsequent clicks from firing duplicate creation requests into the database while the first request is processing, backed by standard Material ripple animations to confirm the tap.''',

    'RCGLA-043-A01': '''This task focuses on **High-Density Interface Layout Design** and **Client-Side Grid Optimization**. You are building a heavy-duty, responsive "Operational Data Table" (a data grid) for corporate records.

Because standard data tables are notoriously terrible on mobile phones (forcing users to scroll horizontally endlessly), this component must be heavily optimized to compress cleanly, truncate long text gracefully, and remain completely usable on small touchscreens.

Here is what you need to build across the stack:

**1. The "No Horizontal Scroll" Mobile Grid (Responsive UX)** To prevent ugly horizontal scrolling on cell phones, the table must dynamically drop or hide non-essential columns on mobile devices, keeping only the most critical tracking metrics visible. As the screen gets wider (Tablet/Web), the table expands to show the full column set.

**2. Strict Padding, Truncation, & Touch Targets (UI/Accessibility)** You must adhere to strict, hardcoded spatial rules to maintain high density without sacrificing accessibility:
- **Padding:** Table cells must have exactly 6dp top/bottom padding and 8dp left padding.
- **Touch Targets:** Every row must have a minimum height of 48dp so support workers can easily tap a row on a touchscreen.
- **Truncation:** Any text that is too long for its cell must be explicitly truncated (e.g., using an ellipsis ...) rather than breaking to a new line and ruining the row heights.

**3. The Bad-Data Bouncer (Frontend Engineering Poka-Yoke)** The UI component must validate the data before rendering. If a row is missing a unique tracking identifier (transaction ID), the tabular layout engine must programmatically drop that entry entirely to prevent the UI from crashing or displaying corrupted data.''',

    'CBSV-007-A02': '''This task is focused on **Metadata Engineering & Distributed Systems Architecture**. You are building an administrative dashboard for a "Data Dictionary" (the Universal Ingestion and Lookup Matrix). The team is deciding whether to let users update this dictionary directly via this UI or force them to use code deployments (Git).

Regardless of that decision, administrators need a highly readable, searchable interface to view these dictionary versions and data mappings across all devices.

Here is what you need to build across the stack:

**1. "Search-as-you-type" Filtering (UI/UX)** Data dictionaries are massive. You must build a dynamic filter box at the top of the interface. As the user types into it, the list of data rows below must instantly filter down to match the text, without requiring them to hit a "Search" button.

**2. Collapsible Details & Shadow Elevations (Mobile Layout)** On small screens, a wide data grid is impossible to read. The UI must use a clean list of cards. Each card represents a row of data, and it must feature a "collapsible details" mechanism (an accordion or expansion tile). When tapped, it expands to show the deeper metadata. Crucially, these cards must use Material Design elevation shadows to clearly separate one piece of content from the next.

**3. The Blank-Cell Blocker (Poka-Yoke Backend/Validation)** To ensure data standardization, you must implement a rigid mistake-proofing check. If an administrator attempts to save or ingest a lookup line, the system must scan the master columns. If even a single required cell is left blank, the ingestion pipeline must physically block the save action and throw an error.''',

    'EDBAA-015-15': '''This task represents the final "lockdown" phase of your frontend architecture. You are building a **Component Library Documentation Archive**---a read-only dashboard that displays the final, approved UI components and their accompanying release documentation.

Because this codebase is being permanently "frozen" as the master template, the components displayed here must be perfectly accessible, and the metadata tracking them must be 100% complete.

Here is what you need to build across the stack:

**1. Locked Sizing & Crisp Boundaries (UI/UX)** To ensure the UI components look perfect on any device and pass modern WCAG readability indexes, you must lock the sizing scales (preventing the device's default text settings from breaking the layouts). Furthermore, when displaying data in tabular formats, you must use crisp, hard-lined boundaries to divide the content cleanly, avoiding messy or ambiguous spacing.

**2. Immediate Tactile Feedback (Micro-Interactions)** Because these are the master components, they must demonstrate perfect interactivity. Every single touchable element must trigger an immediate, responsive visual click feedback indicator (like a Material Design ripple effect) the millisecond a user taps it.

**3. Immutable Metadata Archiving (Data Tracking)** You are building the administrative view for this archive. It must track the specific atomic data fields for every document (Title, URL, Last Updated, Accessibility Status, Access Log). To meet the strict *DAMA-DMBOK2 Metadata Management Standard*, the system must ensure this data is 100% complete before allowing an administrator to mark the archive process as "Complete".''',

    'RCGLA-021-A01': '''This task is the foundational **"Responsive Grid Engine"** for your entire application. Before building any more screens or buttons, you must define the mathematical skeleton of the app so it knows exactly how to stretch, shrink, and rearrange itself depending on the device the user is holding.

Here is what you need to build across the stack:

**1. The 4-8-12 Column Rule (Layout Architecture)** You are establishing the strict structural grid of the app.
- **Mobile (< 600dp):** The screen uses a 4-column grid. Anything that was side-by-side on a desktop must collapse into a single vertical column.
- **Tablet (600 - 840dp):** The screen uses an 8-column grid.
- **Desktop (> 840dp):** The screen uses a standard 12-column grid.

**2. Fluid Margins (Design Tokens)** The empty space on the edges of the screen (margins) must adapt logically. On a smartphone, the margins must be tightly set to 16dp to maximize usable space. On larger screens, the margins expand to 24dp. This must be driven by core system variables, not hardcoded CSS.

**3. The Table-Clipping Shield (Poka-Yoke)** Data tables are notoriously bad at shrinking. To prevent a massive data table from blowing out the layout and forcing a user to scroll horizontally on their phone, you must apply a strict constraint (the equivalent of max-width: 100%). This ensures elements are forcibly contained within the viewport boundaries, guaranteeing full scannability and touch isolation on a tight 360px portrait screen.''',

    'ACRAE-011': '''This task bridges **Mobile UX/UI** with strict **API Perimeter Security**. You are building a mobile-first AI chat interface, but the core focus is actually on how the app handles network stress and rate limits (the "429 Too Many Requests" error).

To protect the backend servers from being DDoSed (either by malicious users or by a buggy infinite-retry loop in the app), the API Gateway is strictly rate-limited. Your frontend must handle these limits gracefully without freezing the app or annoying the user.

Here is what you need to build across the stack:

**1. The M3 Chat Interface (UI/UX)** Users initiate the chat via a Floating Action Button (FAB). The chat interface itself must use Material Design 3 (M3) standards: chat bubbles must use the "Rounded Large" shape and inherit the "Surface" color token for their backgrounds. The list must scroll perfectly smoothly, ensuring touch response times stay below the 100ms optimal threshold.

**2. The Graceful Degradation (Rate-Limit UX)** If the user spams the chat and triggers a backend rate limit (429 error), the UI must *not* crash or throw a massive, blocking error modal. Instead, it must gracefully degrade: the "Send" button should temporarily disable itself, and a subtle Snackbar should slide up gently saying "Slow down."

**3. Exponential Backoff (The Poka-Yoke)** Under the hood, if a network request fails due to a rate limit, the app must use "exponential backoff." This means if it tries to reconnect, it waits 1 second, then 2 seconds, then 4 seconds, etc. This physically prevents a runaway bug from draining the user's battery and hammering the backend.''',

    'ANSA-020-09': '''This task focuses on **Core UI Framework & Responsive Navigation**. You are building the primary navigation skeleton for your application dashboards using strict Material Design 3 (M3) standards.

Because dashboards are heavily data-driven, vertical screen space is incredibly valuable. Your navigation must automatically adapt its shape based on the device to maximize the room available for data.

Here is what you need to build across the stack:

**1. The Adaptive Shapeshifter (NavigationSuiteScaffold)** You must implement a dynamic layout engine.
- On a Mobile phone (Compact viewport), the app displays a standard **Bottom Navigation Bar**.
- On a Tablet or Desktop (Medium/Expanded viewports), that bottom bar automatically morphs into a left-aligned **Navigation Rail**, freeing up the entire vertical height of the screen for data grids and charts.

**2. M3 Motion & Transitions** This cannot be a jarring, instantaneous snap. As the user resizes their window (or rotates a tablet), the transition between the Bottom Nav and the Navigation Rail must use smooth Material 3 motion animations to guide the user's eye.

**3. The 48dp Thumb Target Rule (Accessibility)** Whether the buttons are on the bottom of a phone or the side of a desktop monitor, you must enforce a strict 48dp minimum hit box for every navigation icon. This ensures the app remains fully thumb-accessible and passes baseline ergonomic standards.''',

    'BLGTA-001-11': '''This task focuses on **Form UX & Data Architecture Cleanliness**. You are building a welcoming initial input form for users, but the core technical requirement is about how the "Submit" button works.

To prevent app crashes, race conditions, and corrupted data, every primary button must adhere to the "Single-Line Action" rule. This means a button click triggers exactly *one* atomic action or API call, rather than trying to execute three or four separate functions simultaneously.

Here is what you need to build across the stack:

**1. The "One Button, One Action" Rule (Data Architecture)** When the user taps the primary button at the bottom of the form, it must trigger exactly one single, atomic function. If multiple things need to happen (e.g., save user, send welcome email, update analytics), that orchestration must happen on the *backend*. The mobile UI button is only responsible for a single API dispatch, preventing the frontend from freezing or double-firing.

**2. The Welcoming M3 Form (Visual UI)** The form itself must be clean and un-intimidating. You are strictly required to use Material Design 3 "Outlined TextFields." This specific design token provides a clear, highly visible boundary around the input area, making it obvious where the user needs to tap.

**3. Smart Keyboards & Focus Paths (Micro-UX)** To make the form truly frictionless, you must engineer the keyboard interactions. When the screen opens, the first text field must automatically focus and pop open the keyboard. Furthermore, you must optimize the keyboard types---if the field asks for an email, the phone keyboard must automatically show the "@" symbol. If it asks for a phone number, it must only show the number pad.''',

    'MCIIM-020-13': '''This task focuses on building a fair, transparent, and responsive **HR Metric & Target Adjustment** interface. In automated performance tracking, reality sometimes shifts rapidly (e.g., a territory is reassigned, a product is delayed, or a market shifts). To ensure "fairness in automated tracking," HR needs the ability to apply "Contextual Modifiers" (multipliers or target adjustments) to an employee's goals.

Here is what you need to build across the stack:

**1. The Contextual Visual Tags (UI/UX)** When a multiplier is active on a user's target, it must be completely transparent. You must design highly visible visual tags (pill-shaped badges) that clearly display the active multiplier (e.g., "1.2x Market Shift" or "Q3 Adjustment"). These tags must be coded to wrap fluidly across any screen size without clipping or breaking the layout.

**2. Full-Width Mobile Adjustments (Ergonomics)** HR managers need to make these adjustments on the fly from their phones when sudden reality changes occur. To make this interface as fast and error-proof as possible, any dropdown menus used to select these modifiers must span the absolute full width of the mobile screen, creating massive, foolproof touch targets.

**3. Software Testing Compliance (The Verification)** This UI directly impacts employee compensation and tracking, meaning layout bugs are unacceptable. The UI must be built with strict wrapping constraints so that it mathematically passes the ISO/IEC/IEEE 29119 testing standards for fluid viewport rendering.''',

    'ANSA-020-15': '''This task is the crucial "Orientation Test" for your **Adaptive Dashboard Navigation**. You have built the navigation skeleton, and now you must prove that the layout shapeshifts correctly when the physical device is rotated or the browser window is expanded.

Because dashboards require massive amounts of vertical space to display charts and data grids, keeping a thick navigation bar at the bottom of a landscape screen is a waste of real estate. The system must adapt instantly.

Here is what you need to build and test across the stack:

**1. The Orientation Shapeshifter (NavigationSuiteScaffold)** When the user holds their phone vertically (Compact Portrait), they see a Bottom Navigation Bar. The millisecond they rotate their phone sideways (Landscape/Medium viewport), the bottom bar must disappear and instantly reappear as a left-aligned Navigation Rail. This frees up the entire vertical height of the screen for data.

**2. Fluid M3 Motion** This transition cannot be a jarring, instantaneous snap that disorients the user. You must utilize Material 3 motion specifications (like a Shared Axis or Fade Through animation) so the icons smoothly glide or fade from the bottom to the side during the rotation.

**3. Uncompromised Accessibility (48dp Targets)** Even as the navigation elements change shape and location, their clickable hit-boxes cannot shrink. You must mathematically enforce a strict 48dp minimum touch target for every navigation icon, ensuring the app remains perfectly thumb-accessible regardless of how the user holds their device.''',

    'DPRBR-004': '''This task bridges **DevSecOps Network Security** and **High-Converting E-Commerce UX**. You are building a secure "Campaign Target SKU" (Product Selection) interface.

Behind the scenes, the API Gateway is strictly enforcing modern TLS 1.3 security, meaning older, slower connections are instantly dropped to prevent the app from freezing on a "Secure Connection Loading..." screen. On the frontend, your job is to build a hyper-optimized, responsive product grid that handles these security states elegantly while driving the user toward a checkout action.

Here is what you need to build across the stack:

**1. The Fluid SKU Grid (Responsive UX)** You must build a product selection layout that adapts perfectly to the screen. On a desktop or tablet, the products display in a fluid, multi-column grid. On a compact mobile device, this horizontal grid must instantly collapse into a clean, vertical single-column list to prevent horizontal scrolling.

**2. Above-the-Fold & Extreme Elevation (Conversion UI)** The primary goal of this screen is conversion. The major checkout action button MUST remain strictly "above the fold" (visible on the screen immediately without the user having to scroll down). To draw the eye, this specific button must feature "extreme elevation shading" (a heavy Material Design drop shadow) to spotlight it as the primary transactional element.

**3. In-Pane Security Fallbacks (Graceful Error Handling)** If the strict TLS 1.3 network handshake fails or an authentication error occurs, the UI cannot crash. You must design a seamless fallback alert that renders *within* the primary viewing container (not as a blocking modal). It must use clear contrasting secure-status icons (like a locked padlock) and standard typography weights to explain the error safely.''',

    'BPTR-0803-A01': '''This task focuses on **Mobile Systems Engineering** and **Data Integrity**. You are building an edge-level validation form---meaning the mobile device itself strictly checks and masks the user's input before it ever tries to talk to the database or network.

The goal is to physically eliminate "garbage in, garbage out" scenarios. If a user tries to submit an incomplete form or improperly formatted data, the app blocks them immediately.

Here is what you need to build across the stack:

**1. Regex Input Masking (The Edge-Level Bouncer)** Text fields must enforce strict Regex (Regular Expression) rules as the user types. For example, a phone number field must automatically format itself and reject letters, ensuring the local database (SQLite) never receives corrupted data that would break a backend pipeline.

**2. Mandatory Indicators & 48dp Targets (UI/UX)** Every mandatory field (Critical Data Element or CDE) must be marked with an asterisk (*). To comply with accessibility and mobile ergonomics, every single text input field must be at least 48px tall (min-height: 48px) to provide an easy, comfortable thumb target.

**3. The "Hard Stop" & Sticky Errors (Mistake-Proofing)** If the user attempts to move forward without filling out the required CDEs, the system must trigger a "Hard Stop," completely blocking forward navigation. The UI must instantly display sticky error states: the input borders turn a stark red, and high-contrast error text appears directly beneath the 48px input field to guide the user's thumb to the exact mistake.''',

    'NSKFI-005-A01': '''This task focuses on **Mobile Form Ergonomics** and **Data Integrity** (Mistake-Proofing). You are building a smart form engine that corrects users as they type, ensuring bad data never reaches your database while saving the user thousands of frustrating screen taps.

There are two main mechanisms you must build:

**1. Native Keyboard Mapping (The Contextual Pad)** When a user taps an input field asking for a phone number or a date, they should not see the standard QWERTY text keyboard. The code must explicitly map the input type so the mobile OS automatically slides up the correct native keyboard (e.g., a large, thumb-friendly Number Pad for dates, or a keyboard with an "@" symbol for emails).

**2. Real-Time Input Masking (The Invisible Bouncer)** As the user types, the text field must actively format the input and reject invalid characters. If they are typing a date, the field must automatically inject the slashes (e.g., "08/17/2026") so the user doesn't have to hunt for the slash key. If the field requires capital letters, it forces capitalization.

**3. Inline Validation & Submission Blocking (Poka-Yoke)** If the user manages to type an invalid or malformed input, the UI must immediately display inline validation messaging directly beneath the Material TextField. Crucially, the main "Submit" button must remain completely disabled until the regex (Regular Expression) validation passes, forcing the user to fix the error on the spot.''',

    'PCDE-016': '''This task bridges **Information Security (ISO 27001)** and **Payroll UX**. You are building an employee payroll register dashboard. Because this dashboard handles highly sensitive financial data (like bank account numbers/IBANs and salaries), it must be built with strict visual security controls while remaining easy for HR managers to read on small screens.

Here is what you need to build across the stack:

**1. The Regex Mask (Data Privacy Poka-Yoke)** When the dashboard displays an employee's IBAN (International Bank Account Number), it absolutely cannot show the full string on the screen. The UI must apply a Regular Expression (Regex) mask that visually blocks all characters *except* the last 4 digits (e.g., •••• •••• •••• 1234). This must be a flawless 100% masking accuracy rate to pass ISO 27001 requirements.

**2. Gross vs. Net Visual Distinction (Typography & Color)** Payroll sheets are dense with numbers. To help managers instantly tell the difference between Gross Pay and Net Deductions, you must use distinct accent colors (e.g., a subtle green tint for Gross, a subtle red/gray for Deductions). You must strictly adhere to Material typography rules to ensure these numbers remain perfectly legible, regardless of screen width.

**3. Mobile Modals & Tooltips (Responsive Ergonomics)** A giant spreadsheet of salary properties is impossible to read on a phone. On mobile views, related salary attributes must be grouped into clean, smooth "Modal Panels" (pop-ups or bottom sheets) to optimize vertical space. Furthermore, complex payroll variables must feature an intuitive "Tooltip" control (an info icon) that a manager can tap to understand the calculation, preventing confusion.''',

    'FLADE-011-06': '''This task focuses on **Critical Systems UI Architecture** and **Site Reliability Engineering (SRE)**. You are building the "Shakti Alert Panel"---the nuclear option for UI notifications.

When a Priority 1 (P1) architectural breach occurs or a critical manual override is triggered, every single user must be immediately aware. This cannot be a standard popup or a polite toast message. It must be a hostile, un-ignorable, global red banner that takes over the top of the interface.

Here is what you need to build across the stack:

**1. The Absolute Z-Index (Global Visibility)** This banner must be hardcoded to sit at the absolute highest layer of the application (equivalent to z-index: 10000 in CSS). It must span the entire width of the screen (100vw) and be pinned to the top (position: fixed). It must render *above* all navigation bars, modals, or dropdowns.

**2. The "No-Dismiss" Rule (Poka-Yoke)** Standard alerts have an 'X' button or allow the user to swipe them away. You must explicitly **disable and omit all dismissal mechanisms**. The user cannot swipe it away, they cannot tap the background to close it, and there is no close button. It remains permanently locked to the screen until the backend resolves the breach.

**3. SRE Handbook Observability Compliance** Because this is a critical system alert, it must adhere to the *Google SRE Handbook* standards for monitoring distributed systems, ensuring 100% alert coverage. The UI component must log exactly who saw it and when, tracking the Step Execution ID and Execution Status.''',

    'AEETE-002-A07': '''This task focuses on **Frontend Mobile Engineering** and **Marketing Analytics**. You are building the "Experiment State Preserver" for an A/B testing framework.

When a marketing team runs an A/B test (an "experiment"), they need to know if Version A or Version B works better. If a user opens the app and sees Version A, but then closes the app and sees Version B the next day, the test data is completely ruined.

To prevent this, you must build a system that strictly locks the user into their assigned experiment variant for a minimum of 14 days, regardless of how many times they close and reopen the app.

Here is what you need to build across the stack:

**1. The 14-Day Session Lock (Redux & Local Storage)** You must configure the frontend state management (e.g., Redux in a React Native/Flutter equivalent environment) to intercept the A/B test variant assignment. Once assigned, this data cannot just live in RAM---it must be written to persistent local storage (or a persistent cookie) with a hardcoded expiration of 14 days. When the user reopens the app, the state manager must check local storage *before* asking the server for a variant, guaranteeing seamless session continuity.

**2. WCAG Contrast Compliance (Accessibility Standard)** Because these A/B tests alter the UI, you must guarantee that *neither* variant breaks accessibility rules. The UI components used in the experiment must strictly pass WCAG 2.1 AA standards (minimum 4.5:1 text contrast).''',

    'HSFVS-001-A08': '''This task focuses on **Mobile Architecture & UI Development**, specifically dealing with strict navigation routing. You are building a linear progression flow (like an onboarding wizard or a multi-step checkout).

To prevent users from "hacking" the app or encountering bugs by skipping steps (e.g., forcing their way to Step 3 without completing Step 2), the underlying routing graph must enforce a strict chain of custody. Every time the app navigates to a new screen, it must pass the "Predecessor ID" (the ID of the screen they just came from) as a mandatory argument. If that ID is missing or incorrect, the app blocks the navigation.

Here is what you need to build across the stack:

**1. The ViewPager with Snap-Scrolling (Responsive UX)** Visually, this linear progression must be represented as a swipeable flow. You must implement a "ViewPager" mechanism where the user can swipe left or right to move between steps. The code must enforce "scroll snapping" (meaning the screen smoothly locks into place and cannot get stuck halfway between two screens).

**2. Dot Indicators (Wayfinding)** At the bottom of the screen, you must include standard dot indicators. These dots provide visual feedback showing the user exactly where they are in the linear flow (e.g., Dot 2 of 4 is highlighted).

**3. The Predecessor ID Lock (Routing Poka-Yoke)** Under the hood, the mobile routing graph must be strictly typed. The function that opens the next page cannot just be a simple goToNextPage(). It must be structured as goToNextPage(required String predecessorId). If this argument is null or invalid, the routing engine must throw an exception and block the transition to preserve the integrity of the Data Flow Diagram.''',

    'ERMWD-007-08': '''This task focuses on **Operations Engineering** and **Data Standardization**. You are building a time-sensitive data entry screen for operations workers. The core technical requirement is ensuring that every button on the frontend maps to a strictly named, single-verb API endpoint (e.g., POST /verify, not POST /saveAndProcess) to maintain perfect backend schema alignment.

Here is what you need to build across the stack:

**1. The Strict API Verb Mapping (Architecture)** To hit the 100% "Schema/Field Naming Standardization Rate," the frontend code must map its submit actions to exact, system-verifiable verbs. When a user clicks "Submit", the frontend function must be a clean, single-action trigger that matches the DAMA-DMBOK2 naming conventions configured in the backend.

**2. Double-Entry Verification (Mistake-Proofing / Poka-Yoke)** Operations data is critical. To prevent typos on mobile devices, you must build a "double-entry" input system. The worker must type their input into one field, and then type it again into a confirmation field. The primary action button remains disabled or throws an error until both fields match perfectly.

**3. The Urgent Timer & Typography (UI/UX)** The task is time-bound. You must display a countdown timer at the top of the screen utilizing the system's "Error Color" (typically a stark red) to ensure the worker cannot ignore it. All input fields must strictly use the Material Design "Title Medium" typography token for maximum legibility. Finally, the screen must feature a clear Top App Bar allowing the worker to safely "Exit" the task if needed.''',

    'NQSDV-003': '''This task bridges strict **Payment Systems Auditing** and **High-Performance Edge Security**. You are building a user-facing dashboard that displays the results of complex mathematical verifications running on payment gateway "cash drops" (financial reconciliations).

Behind the scenes, the infrastructure relies on lightning-fast, ultra-secure TLS 1.3 connections. If a connection drops (or if someone tries to hack the connection using an older, slower protocol), the load balancers instantly kill it. Your UI needs to reflect these financial and security checks clearly and elegantly to the user without crashing or blocking their view.

Here is what you need to build across the stack:

**1. The High-Contrast Status Cards (UI/UX)** The results of the payment verifications must be rendered in specialized Material Design cards. Because this is financial auditing data, you must apply strict typographic visual weights (bold headers, high-contrast numbers) so users can easily scan the data. You must construct these cards with clean interface separation lines (dividers) and consistent border padding to keep the layout organized.

**2. Non-Blocking Security Notifications (Graceful UX)** If the system detects a network drop, a reconnection event (like stepping off Wi-Fi), or a TLS handshake failure, the UI must inform the user gracefully. You must **not** use massive, blocking dialog boxes that freeze the screen. Instead, use clean, inline text descriptions or subtle snackbars outlining the system validation status.

**3. SUS Benchmark Compliance (Usability)** The entire goal of this interface is to make complex financial and security data extremely easy to read. The layout and typography must be structured to hit an "Optimal" System Usability Scale (SUS) score of 80-90, as defined by the Nielsen Norman Group.''',

    'HC-IAM-0107': '''This task focuses on **Data Governance & Immutability** based on the strict *DAMA-DMBOK Data Modelling standards*. You are building an administrative view for "Analytical Logs."

Because these logs are used for security and operational auditing, they must be strictly **"Append-Only."** This means that once a log entry is written to the database, it can never be altered, modified, or deleted by anyone---not even an administrator. To enforce this on the frontend, you must physically remove or disable any UI elements that imply the data can be changed.

Here is what you need to build across the stack:

**1. The Immutable UI (No-Edit Bouncer)** When displaying the data table or log list, you must completely disable or eradicate all "Edit," "Update," or "Delete" buttons. There should be no pencil icons, no trash can icons, and no swipe-to-delete gestures. The view is strictly read-only.

**2. Visual Clarity (Trust Markers)** To prevent user confusion as to why they cannot edit the rows, the interface should include a clear visual indicator or badge (e.g., "Append-Only Record" or "Protected Table") letting the administrator know this data is permanently locked for compliance reasons.

**3. Compliance Telemetry Tracking** The UI component must track atomic data fields (Step Execution ID, Execution Status, User ID, etc.) to report its own Schema Design Compliance Rate, ensuring 100% adherence to the append-only rule.''',

    'MCIIM-010-12': '''This task focuses on **Image Processing UI** and **Cognitive Load Reduction**. You are building a highly focused "Document Isolator" interface for mobile data entry.

When a user needs to verify or type information from a massive, dense document (like a scanned invoice or contract), it is incredibly frustrating to constantly pinch, zoom, and scroll around the image to find the right sentence. Instead, the backend sends a "Bounding-Box" (a cropped snippet of the exact sentence they need to look at). Your job is to display *only* that snippet on the screen, locked in place, alongside a text input field.

Here is what you need to build across the stack:

**1. The Frozen Image Snippet (No-Gesture Poka-Yoke)** The cropped image must be displayed in a fixed-aspect container. To ensure "pure cognitive focus," you must strictly **disable all gestures on the image**. The user cannot scroll it, and they cannot pinch-to-zoom (equivalent to touch-action: none in CSS). The image is simply a frozen reference point.

**2. Strict Touch Padding (Fat-Finger Friendly)** Directly below the frozen image snippet is the text input field where the user types what they see. You must enforce strict padding rules around this input field (e.g., minimum 48px height and significant surrounding margin) to ensure they can tap it instantly without accidentally triggering other elements.

**3. ISO 9001 Metadata Compliance** The UI component must track and report atomic step data (Step Execution ID, Status, Timestamp) to prove 100% Process Step Execution Conformance, hitting the Six Sigma benchmark for flawless data entry workflows.''',

    'ETMDI-022-17': '''This task bridges **Operations & Business Analysis** with **Strict UI Compliance**. You are building an interface that handles conditional data (showing or hiding complex information based on user choices) while strictly enforcing how the system speaks to the user.

Business operations require predictable, unambiguous language. Buttons cannot use fluffy "human" terms like "Let's Go!" or "Okay." They must use strict machine-action verbs like "EXECUTE", "APPROVE", or "VALIDATE".

Here is what you need to build across the stack:

**1. The "Anti-Fluff" Verb Blocker (Poka-Yoke)** To guarantee a 100% UI Design-System Adherence Rate, you must build a custom button widget that checks its own text label. If a developer tries to compile the app with a button that says "Click Here", the code must throw a fatal error. It will only accept a predefined list of approved operational verbs.

**2. Unambiguous Typography** The labels on these buttons must use explicit Material Design 3 typography parameters. The font name, size, line height, and weight must be strictly locked in so the text is instantly readable, eliminating any ambiguity on tap.

**3. Conditional Expansion Panels (Adaptive UX)** Because operational data can be dense, the UI must use "Conditional UI Elements" driven by IF/ELSE logic. Complex details should be hidden inside smooth Material 3 Expansion Panels. Furthermore, the layout must adapt: on mobile, it uses stacked expansion panels; on desktop, it uses adaptive pane logic to show the data side-by-side.''',

    'AMLCO-014': '''This task bridges strict **Anti-Money Laundering (AML) Compliance** and seamless **Identity & Access Management (IAM)**. You are building an "Automated Query Gate"---a secure dashboard used to track public reputation metrics, protected by a zero-trust API gateway.

Because compliance officers and administrators need rapid, frictionless access to this system from their phones, the security cannot be clunky. You must implement a silent token refresh system and biometric logins, so users aren't constantly forced to type their passwords every time their session expires.

Here is what you need to build across the stack:

**1. Seamless Biometric Auth & Token Refresh (Security)** The API Gateway uses stateless JWTs to physically block unauthorized traffic at the edge. On the frontend, if a token expires and the app receives a 401 Unauthorized error, it must attempt a "silent background refresh." If that fails, it must smoothly slide up a biometric prompt (FaceID/Fingerprint) rather than kicking the user all the way back to a hard login screen.

**2. Oversized Toggles & MD3 Login (Mobile UX)** The login interface itself must be incredibly clean and non-intrusive. It must use standard Material Design 3 (MD3) text fields for credentials and feature an **oversized toggle switch** for the "Keep me logged in" functionality, maximizing interactive speed on mobile screens.

**3. The Query Gate & Outline Accents (Data Visualization)** Once inside the system, the actual AML Query Gate must display public reputation metrics. You must use **Material 3 Chips** to elegantly summarize text metadata (e.g., Risk Level, Verification Status). To keep the complex data organized, you are required to use clean outline accents (outlined containers/cards) to clearly map the layout boundaries, paired with highly visible typography.''',

    'BCDLD-013-A01': '''This task focuses on **UI/UX Engineering** and **User Behavioral Tracking**. You are building a mandatory "Daily VAP (Vitality and Prosperity) Health Check" that appears the moment a user opens the app.

Because you need high participation rates for this data collection, the interface must be completely frictionless but impossible to ignore.

Here is what you need to build across the stack:

**1. The Focus-Trapping Modal (Interruptive UX)** When the app launches, this widget must fire immediately as an "interruptive modal." It must trap the user's focus entirely. This means the background behind the pop-up becomes darkened and frozen---the user cannot scroll the app behind it, and they cannot tap outside the box to dismiss it. They *must* answer the questions to proceed.

**2. Massive 48dp Toggles (Ergonomics)** The questions are simple binary choices (Yes/No). To make answering them as fast as possible, you must use oversized toggle switches. These switches must physically guarantee a minimum touch target area of 48x48dp so the user can blindly tap them with their thumb without missing.

**3. Crisp Visual States (Mistake-Proofing)** The toggles must feature highly distinct visual states. A "Yes" should look unmistakably active and positive, while a "No" should look clearly inactive or negative, ensuring the user knows exactly what they just submitted.''',

    'TTMCS-011-A01': '''This task focuses on **Core Design Systems & UI Theming**. You are stepping away from individual screens to build the underlying "Material Design 3 (MD3) Expressive Theme Engine" that powers the entire application.

Instead of using bulky borders or lines to separate content, the app will use dynamic color scaling and emphasized typography to establish a visual hierarchy, which saves precious screen real estate on mobile devices and speeds up visual processing by 4x.

Here is what you need to build across the stack:

**1. The 5-Color MD3 Engine (Design & Theming)** You must define 5 key baseline colors via the Material Theme Builder. These colors map to semantic roles (Primary, Secondary, Tertiary, Error, Surface). The app must seamlessly render in both Light and Dark modes using these dynamic tokens, guaranteeing a minimum WCAG contrast ratio of 4.5:1.

**2. Responsive Typography (Window Size Classes)** Text sizes cannot be static. You must map the typography to Window Size Classes. If a user is on a Desktop monitor, the main header should use the massive displayLarge text token. If they shrink the window or view it on a Mobile phone, that exact same header must gracefully scale down to headlineLarge so it doesn't break the screen.

**3. The PR Code Blocker (Mistake-Proofing)** To enforce 100% adherence to this new design system, developers are strictly forbidden from typing custom hex codes. You must write an automated test that scans the code during a Pull Request (PR). If it finds a hardcoded color, the PR fails instantly, forcing the developer to use the authorized Theme token registry.''',

    'SSELC-004-A01': '''This task focuses on **Advanced Frontend Systems Engineering** and **Back-Office Operations**. You are building a "Twin-Pane/Split-Screen Master Layout" that will be the foundational template for all custom exception review portals in the administrative back office.

When operators are reviewing system data (like validating an ID against a user profile), they lose significant time if they have to constantly switch between windows or tabs. A split-screen layout places the primary evidence (e.g., an ID scan) cleanly on the left, and the action fields (e.g., approve/reject buttons and text inputs) on the right.

Here is what you need to build across the stack:

**1. The Dual-Pane 12-Column Master (Adaptive Architecture)** You must create a foundational master layout component using a responsive 12-column grid.
- **Web/Desktop View:** The layout locks into a side-by-side split-screen mode (e.g., 6 columns for the left pane, 6 columns for the right pane). The left pane renders the primary evidence, and the right pane handles actions.
- **Mobile View:** The dual panes must automatically collapse and stack into a linear, single-column configuration (vertical scrolling) to maximize legibility on compact screens.

**2. Fluid Variables & Clean Backgrounds (UI/UX)** The layout parameters must use fluid container variables so assets scale elegantly across different screen sizes. To reduce cognitive load, the background zones behind these panes must utilize clean, neutral shades, maximizing the legibility of the content sitting on top.

**3. Ergonomic Paddings & Bounds (Accessibility)** This layout is for operators moving fast. The interactive items (buttons, inputs) within the right pane must use proper finger-reach bounds (e.g., 48dp minimum targets). The padding between the components and the panes must adhere to exact structural layout spacing multiples (e.g., an 8dp grid system).''',

    'BPTR-0035-A01': '''This task bridges **Backend Database Architecture** and **Frontend Mobile Engineering**. You are building a strict "Inbound Lead Form" that physically prevents users from submitting bad or incomplete data.

To protect the Cloud SQL database from "garbage in, garbage out" scenarios, the mobile app acts as the first line of defense. By strictly validating the inputs on the device (at the edge) before a network call is ever made, you save battery life, reduce server load, and eliminate user frustration.

Here is what you need to build across the stack:

**1. Context-Aware Native Keyboards (Ergonomics)** When a user taps on a specific field (like a Zip Code or Phone Number), the app must automatically trigger the correct native keyboard (e.g., the large numeric dialpad). This saves the user from manually switching keyboard tabs and prevents them from accidentally typing letters into a number field.

**2. Client-Side Regex & High-Contrast Errors (Mistake-Proofing)** As the user types, the form must use Regex patterns to validate the data in real-time. If a user enters invalid data (an "entry break"), the text box border must dynamically update to a high-contrast system error color (e.g., stark red), and inline helper text must appear beneath it explaining the issue.

**3. The Blurred Submission Blocker (State Management)** The primary "Submit" button must be visually disabled (blurred out or greyed out) until every single mandatory field (Critical Data Element) passes the Regex validation and NOT NULL checks.

**4. Responsive "Lanes" (Adaptive UI)** On a narrow mobile screen, the form fields must stack in a single-focus vertical lane to keep the user's attention secured. On wider tablet or web viewports, the layout must expand symmetrically, placing text blocks side-by-side using relative viewport percentages.''',

    'BPTR-0407-A01': '''This task focuses on **UI/UX Engineering** and **Micro-Interactions**. You are building an "Animated Masked Input Field" that actively trains users on how to format their data (like phone numbers or dates) without frustrating them.

When an app silently rejects invalid keystrokes (e.g., ignoring a letter typed into a number field), users get confused because they think their keyboard is broken. To fix this, you must build explicit, localized feedback mechanisms that correct the user instantly without blocking their screen with pop-ups.

Here is what you need to build across the stack:

**1. Haptic Feedback & Localized Shakes (Micro-Interactions)** Instead of triggering an annoying popup that blocks the mobile keyboard, the text field itself must provide localized feedback. If a user types an invalid character, the text box must physically "shake" left and right (using an animation amplitude) and trigger the phone's native vibration (haptic feedback) to instantly halt and correct them.

**2. Dynamic Expanding Errors** When an error occurs, the red inline helper text must smoothly expand directly below the text field. The speed of this inline red-text must be configured so it feels responsive and prevents the user from having to scroll to find their mistake.

**3. The 3-Strike Tutorial Tooltip (Mistake-Proofing)** The code must intercept invalid keystrokes at the DOM/widget level. If a user struggles and makes 3 failed attempts (invalid keystrokes) in a row, the UI must automatically trigger an auto-expanding format tutorial tooltip to explicitly teach the user the correct format.''',

    'MUFCE-004-A01': '''This task focuses on **Client Onboarding Engineering** and **Usability Systems Design**. You are building a "Dynamic Additional Information Required Form" (AIF).

When a user signs up but is missing crucial profile data, presenting them with a massive, vague, 20-question form causes cognitive overload and leads to form abandonment. To fix this, you must build a highly focused, step-by-step onboarding journey that only asks for exactly what is missing, one piece at a time.

Here is what you need to build across the stack:

**1. Single-Milestone Focus & Sliding Animations (UX/UI)** Instead of a long scrolling page, the screen must display only a single data milestone (e.g., "Enter your Address") per viewport canvas to maximize focus. When the user completes it, the UI must use a fluid sliding page animation to transition to the next missing field.

**2. Dynamic Keyboard Margins & High-Contrast Borders (Ergonomics)** When the user taps a text field, the mobile software keyboard pops up. Your layout must dynamically shift its bottom margins to ensure the input field is never hidden behind the keyboard. The input blocks themselves must feature high-contrast outer borders, and the text labels must use precise typography weights to ensure total legibility.

**3. Explanatory Context & Locked Submittals (Mistake-Proofing)** People hesitate to give personal data if they don't know why it's needed. Every input field must have clear contextual helper text explaining *why* the app is asking for this information. Finally, the main "Submit" button must remain completely locked until every required variable is provided, preventing incomplete profile creations.''',

    'RCGLA-040-A01': '''This task focuses on **Mobile Interaction Modeling** and **Context Isolated Component Architecture**. You are building a highly focused, foolproof "Data Entry Card" component.

To eliminate user confusion and prevent data entry errors, the system is moving away from messy, multi-input forms. Instead, you must build standalone, single-purpose interaction modules where users focus completely on one single data item at a time.

Here is what you need to build across the stack:

**1. The Single-Input Rule (Mistake-Proofing / Poka-Yoke)** This is the most critical architectural rule: A Data Entry Card is strictly allowed to have only **one** input box. If a developer tries to embed two or more input boxes inside this card component, the validation tools must instantly block the deployment.

**2. Dynamic Red Flashes (Validation UX)** The card must map explicit text layout sizes for field titles. Alongside the isolated input field, you must position validation text lines. If the user enters invalid data (a block status), the code must program dynamic color rules that flash the card's background red to instantly grab their attention.

**3. Anti-Nesting & Stacking Rules (Mobile-First UI)** To preserve lightning-fast layout render loops and clean visual simplicity, you must completely disable multi-layer nested card variations (no cards inside of cards). The cards must use forced standard rounded corners and, on mobile viewports, stack strictly in a single vertical column.''',

    'RCGLA-040': '''This task focuses on **Mobile Interaction Modeling** and **Context Isolated Component Architecture**. You are building a highly focused, foolproof "Data Entry Card" component.

To eliminate user confusion and prevent data entry errors, the system is moving away from messy, multi-input forms. Instead, you must build standalone, single-purpose interaction modules where users focus completely on one single data item at a time.

Here is what you need to build across the stack:

**1. The Single-Input Rule (Mistake-Proofing / Poka-Yoke)** This is the most critical architectural rule: A Data Entry Card is strictly allowed to have only **one** input box. If a developer tries to embed two or more input boxes inside this card component, the validation tools must instantly block the deployment.

**2. Dynamic Red Flashes (Validation UX)** The card must map explicit text layout sizes for field titles. Alongside the isolated input field, you must position validation text lines. If the user enters invalid data (a block status), the code must program dynamic color rules that flash the card's background red to instantly grab their attention.

**3. Anti-Nesting & Stacking Rules (Mobile-First UI)** To preserve lightning-fast layout render loops and clean visual simplicity, you must completely disable multi-layer nested card variations (no cards inside of cards). The cards must use forced standard rounded corners and, on mobile viewports, stack strictly in a single vertical column.''',

    'ANSA-013-A01': '''This task focuses on **Core Layout Architecture** and **Mobile Interface Component Engineering**. You are building a "Persistent Header Layout System" (a fixed Top App Bar).

When users scroll through long, complex data forms, they often lose track of important context (like the `trace_id` they need if they have to call support). This task ensures a compact, highly functional header stays glued to the top of the screen at all times.

Here is what you need to build across the stack:

**1. The 56dp Frosted Glass Header (UI/UX)** On mobile devices, screen real estate is precious. This header must be strictly capped at **56dp** in height. Because the main work area will scroll smoothly underneath it, the header must use a "frosted glass" effect (background blur) combined with a subtle divider line on the bottom edge. This ensures the scrolling text beneath it remains legible without the header looking heavy or bulky.

**2. Contextual Action Shortcuts & Security (Mistake-Proofing)** The right edge of the header is reserved for action shortcuts (like "Edit" or "Save"). However, the system must employ contextual security: if the logged-in user lacks the necessary permissions for those actions, the buttons must automatically and completely disappear from the UI.

**3. Always-Visible Identifiers** The header must always display essential task details, such as the current `trace_id` and network connectivity state flags, alongside a consistent back-navigation button on the left.''',

    'ANSA-013': '''This task focuses on **Core Layout Architecture** and **Mobile Interface Component Engineering**. You are building a "Persistent Header Layout System" (a fixed Top App Bar).

When users scroll through long, complex data forms, they often lose track of important context (like the `trace_id` they need if they have to call support). This task ensures a compact, highly functional header stays glued to the top of the screen at all times.

Here is what you need to build across the stack:

**1. The 56dp Frosted Glass Header (UI/UX)** On mobile devices, screen real estate is precious. This header must be strictly capped at **56dp** in height. Because the main work area will scroll smoothly underneath it, the header must use a "frosted glass" effect (background blur) combined with a subtle divider line on the bottom edge. This ensures the scrolling text beneath it remains legible without the header looking heavy or bulky.

**2. Contextual Action Shortcuts & Security (Mistake-Proofing)** The right edge of the header is reserved for action shortcuts (like "Edit" or "Save"). However, the system must employ contextual security: if the logged-in user lacks the necessary permissions for those actions, the buttons must automatically and completely disappear from the UI.

**3. Always-Visible Identifiers** The header must always display essential task details, such as the current `trace_id` and network connectivity state flags, alongside a consistent back-navigation button on the left.''',

    'ANSA-018-A01': '''This task focuses on **Mobile Rendering Performance Engineering**. You are building a high-performance "Smooth Scroller Wrapper" for long data lists.

When users scroll through massive data directories (like transaction logs or records), a stuttering or choppy layout feels unpolished and causes them to accidentally click the wrong items. Your goal is to build an optimized list container that runs at a locked 60fps (or ≥58fps) on mid-range phones, allowing rows to glide effortlessly under rapid thumb flicks.

Here is what you need to build across the stack:

**1. Hardware-Accelerated Inertia (The Engine)** You must build a lightweight wrapper (under 20 lines of core logic) that utilizes hardware acceleration (GPU). As the user flicks the screen, the list must use momentum physics to scroll smoothly and slow down naturally. It must also pause off-screen content updates to save processing power.

**2. The Nested-Scroll Blocker (Mistake-Proofing / Poka-Yoke)** A common cause of layout stuttering is when developers accidentally put a vertical scrolling list *inside* another vertical scrolling list (conflicting interaction loops). You must programmatically block nested vertical scroll boxes within the layout to guarantee performance.

**3. Visual Hierarchies & Tinted Scrollbars (UI/UX)** The list must sit inside strict 16px margins so it doesn't bleed to the edges of the device. The scrollbar "track" must be custom-colored to match the interface tones seamlessly. Finally, the data rows inside the list must limit complex text overlays so the device processor isn't overwhelmed during rapid scrolls.''',

    'ANSA-018': '''This task focuses on **Mobile Rendering Performance Engineering**. You are building a high-performance "Smooth Scroller Wrapper" for long data lists.

When users scroll through massive data directories (like transaction logs or records), a stuttering or choppy layout feels unpolished and causes them to accidentally click the wrong items. Your goal is to build an optimized list container that runs at a locked 60fps (or ≥58fps) on mid-range phones, allowing rows to glide effortlessly under rapid thumb flicks.

Here is what you need to build across the stack:

**1. Hardware-Accelerated Inertia (The Engine)** You must build a lightweight wrapper (under 20 lines of core logic) that utilizes hardware acceleration (GPU). As the user flicks the screen, the list must use momentum physics to scroll smoothly and slow down naturally. It must also pause off-screen content updates to save processing power.

**2. The Nested-Scroll Blocker (Mistake-Proofing / Poka-Yoke)** A common cause of layout stuttering is when developers accidentally put a vertical scrolling list *inside* another vertical scrolling list (conflicting interaction loops). You must programmatically block nested vertical scroll boxes within the layout to guarantee performance.

**3. Visual Hierarchies & Tinted Scrollbars (UI/UX)** The list must sit inside strict 16px margins so it doesn't bleed to the edges of the device. The scrollbar "track" must be custom-colored to match the interface tones seamlessly. Finally, the data rows inside the list must limit complex text overlays so the device processor isn't overwhelmed during rapid scrolls.''',

    'SLPLU-008-A01': '''This task focuses on **Front-End Performance Optimization** and **Mobile UI Motion Design**. You are building an `AsyncFormSkeletonLoader` for a lead generation form.

When users are on weak cellular connections, staring at a blank screen while a form loads causes them to abandon the app. Even worse, if the form finally loads and pushes elements down the screen (layout shift), users might accidentally tap the wrong button. You are solving this by building a "Progressive Loading" skeleton screen.

Here is what you need to build across the stack:

**1. Dimension-Locked Skeleton Shapes (Zero Layout Shift)** You must build placeholder blocks (skeletons) that exactly match the final validated shapes and heights of the text fields they represent. When the real data finishes loading, the skeletons simply vanish and the real fields appear without moving the layout a single pixel.

**2. Rhythmic Opacity Pulsing & Theme Sync (UI/UX)** The placeholder blocks cannot be static; they must feature an automated, looping opacity pulse to give predictable, rhythmic visual motion feedback. The blocks must use neutral, desaturated grey fills that automatically adapt to the user's base Dark or Light application theme.

**3. Gesture Blocking & Timeout Fallbacks (Poka-Yoke)** While the form is in this pulsing skeleton state, all interactive gesture event listeners must be completely blocked (the user cannot tap or scroll the ghost fields) to prevent early form submissions. Additionally, you must implement a strict timeout threshold. If the network drops and the form takes too long to load, the skeletons must vanish and instantly prompt an inline "Network Retry" dialog.''',

    'SLPLU-008': '''This task focuses on **Front-End Performance Optimization** and **Mobile UI Motion Design**. You are building an `AsyncFormSkeletonLoader` for a lead generation form.

When users are on weak cellular connections, staring at a blank screen while a form loads causes them to abandon the app. Even worse, if the form finally loads and pushes elements down the screen (layout shift), users might accidentally tap the wrong button. You are solving this by building a "Progressive Loading" skeleton screen.

Here is what you need to build across the stack:

**1. Dimension-Locked Skeleton Shapes (Zero Layout Shift)** You must build placeholder blocks (skeletons) that exactly match the final validated shapes and heights of the text fields they represent. When the real data finishes loading, the skeletons simply vanish and the real fields appear without moving the layout a single pixel.

**2. Rhythmic Opacity Pulsing & Theme Sync (UI/UX)** The placeholder blocks cannot be static; they must feature an automated, looping opacity pulse to give predictable, rhythmic visual motion feedback. The blocks must use neutral, desaturated grey fills that automatically adapt to the user's base Dark or Light application theme.

**3. Gesture Blocking & Timeout Fallbacks (Poka-Yoke)** While the form is in this pulsing skeleton state, all interactive gesture event listeners must be completely blocked (the user cannot tap or scroll the ghost fields) to prevent early form submissions. Additionally, you must implement a strict timeout threshold. If the network drops and the form takes too long to load, the skeletons must vanish and instantly prompt an inline "Network Retry" dialog.''',

    'SGTIM-006-A01': '''This task focuses on **Frontend Interaction Development** and **Component Architecture**. You are building a "Swipeable Tab Navigation System" for data-heavy dashboards.

When users are viewing massive, multi-part datasets, you need to break the information into approachable categories using horizontal tabs. To make navigating these tabs feel native and fast on a phone, users must be able to simply swipe left or right on the screen to switch categories.

Here is what you need to build across the stack:

**1. Swipe Gestures & URL Syncing (Interaction Logic)** The tabs must be linked to screen gestures (swiping left/right changes the tab and the data pane). Additionally, the active tab must sync with the application's URL. This allows users to bookmark or share a link to a specific tab.

**2. The Fallback Bouncer & Filter Memory (Mistake-Proofing)** If someone clicks a broken link with an invalid tab URL parameter, the system must catch the error and automatically default back to the first tab, preventing the app from crashing. Furthermore, if a user types a search filter in Tab 1 and swipes to Tab 2, that filter must remain active so they don't have to re-type it.

**3. Responsive Tab Scaling & Item Counts (UI/UX)** The tabs must drastically change their behavior based on the screen size:
* **Mobile:** The screen is too small to fit all tabs. The tab bar must be horizontally scrollable. The text must be strictly set to 14sp to remain highly readable.
* **Desktop:** With massive screen real estate, the tabs must spread evenly across the toolbar. Furthermore, desktop tabs must explicitly embed item count indicators directly inside the text labels (e.g., "Active Users (142)").''',

    'SGTIM-006': '''This task focuses on **Frontend Interaction Development** and **Component Architecture**. You are building a "Swipeable Tab Navigation System" for data-heavy dashboards.

When users are viewing massive, multi-part datasets, you need to break the information into approachable categories using horizontal tabs. To make navigating these tabs feel native and fast on a phone, users must be able to simply swipe left or right on the screen to switch categories.

Here is what you need to build across the stack:

**1. Swipe Gestures & URL Syncing (Interaction Logic)** The tabs must be linked to screen gestures (swiping left/right changes the tab and the data pane). Additionally, the active tab must sync with the application's URL. This allows users to bookmark or share a link to a specific tab.

**2. The Fallback Bouncer & Filter Memory (Mistake-Proofing)** If someone clicks a broken link with an invalid tab URL parameter, the system must catch the error and automatically default back to the first tab, preventing the app from crashing. Furthermore, if a user types a search filter in Tab 1 and swipes to Tab 2, that filter must remain active so they don't have to re-type it.

**3. Responsive Tab Scaling & Item Counts (UI/UX)** The tabs must drastically change their behavior based on the screen size:
* **Mobile:** The screen is too small to fit all tabs. The tab bar must be horizontally scrollable. The text must be strictly set to 14sp to remain highly readable.
* **Desktop:** With massive screen real estate, the tabs must spread evenly across the toolbar. Furthermore, desktop tabs must explicitly embed item count indicators directly inside the text labels (e.g., "Active Users (142)").''',

    'SCTSS-008-A01': '''This task focuses on **Data Validation** and **Mobile Interaction Ergonomics**. You are building "Interactive Masked Input Components" for high-stakes data entry forms (like banking details or weekly payroll tasks).

When a user types on a small mobile screen, backspacing to fix formatting errors is tedious. To prevent "dirty data" from breaking your backend BigQuery pipelines, the frontend must format the text automatically as the user types, acting as a physical shield against bad data.

Here is what you need to build across the stack:

**1. Real-Time Visual Formatting (UX)** As the user types a date, phone number, or currency, the input field must automatically inject the correct spacing and symbols (e.g., typing "1234567890" automatically transforms into "(123) 456-7890"). This eliminates cognitive load and guides the user without them having to think about the format.

**2. Physical Keystroke Rejection (Mistake-Proofing)** The code must intercept keystrokes at the lowest level (DOM/Widget level). If a user attempts to type an alphabet letter into a phone number or currency field, the text box must physically ignore the input, completely blocking the restricted keystroke from appearing on the screen.

**3. The "Save" Button Chaser (State Management)** Even with masking, a user might leave a field incomplete. The primary "Save" button must remain strictly disabled (greyed out) until every field matches the exact validation bounds. This "chases" the user to fix their own typo instantly before they can proceed.''',

    'SCTSS-008': '''This task focuses on **Data Validation** and **Mobile Interaction Ergonomics**. You are building "Interactive Masked Input Components" for high-stakes data entry forms (like banking details or weekly payroll tasks).

When a user types on a small mobile screen, backspacing to fix formatting errors is tedious. To prevent "dirty data" from breaking your backend BigQuery pipelines, the frontend must format the text automatically as the user types, acting as a physical shield against bad data.

Here is what you need to build across the stack:

**1. Real-Time Visual Formatting (UX)** As the user types a date, phone number, or currency, the input field must automatically inject the correct spacing and symbols (e.g., typing "1234567890" automatically transforms into "(123) 456-7890"). This eliminates cognitive load and guides the user without them having to think about the format.

**2. Physical Keystroke Rejection (Mistake-Proofing)** The code must intercept keystrokes at the lowest level (DOM/Widget level). If a user attempts to type an alphabet letter into a phone number or currency field, the text box must physically ignore the input, completely blocking the restricted keystroke from appearing on the screen.

**3. The "Save" Button Chaser (State Management)** Even with masking, a user might leave a field incomplete. The primary "Save" button must remain strictly disabled (greyed out) until every field matches the exact validation bounds. This "chases" the user to fix their own typo instantly before they can proceed.''',

    'SSTLA-025-A01': '''This task focuses on **Mobile Infrastructure & Session State Management**. You are building an "Orientation-Aware Layout Wrapper" to protect user data from being wiped out.

When a user rotates their phone from portrait to landscape, mobile operating systems often destroy and rebuild the entire screen layout. If the user was halfway through filling out a complex form, this rotation can wipe out all their typed data, causing massive frustration. Your job is to engineer a system that perfectly preserves their progress no matter how they hold their device.

Here is what you need to build across the stack:

**1. The Global State Saver (Data Preservation)** You must implement state management logic (like Flutter's `RestorationMixin` or persistent session states) that caches form inputs in real-time. When the device flips and the screen rebuilds, the UI must instantly repopulate the text fields so the user's progress is kept perfectly intact.

**2. The Rotation Transition Lock (Mistake-Proofing / Poka-Yoke)** When a screen rotates, the layout briefly stretches and animates. If a user accidentally taps the "Submit" button during this split-second animation loop, it can fire half-completed or corrupted states down the network lines. The layout controller must automatically block and disable the submission keys until the rotation animation is completely finished.

**3. Cross-Platform Consistency** While this is primarily a mobile issue, the solution must be responsive. The layout must adapt gracefully from a vertical mobile stack to a wider landscape or tablet view without losing a single character of input.''',

    'SSTLA-025': '''This task focuses on **Mobile Infrastructure & Session State Management**. You are building an "Orientation-Aware Layout Wrapper" to protect user data from being wiped out.

When a user rotates their phone from portrait to landscape, mobile operating systems often destroy and rebuild the entire screen layout. If the user was halfway through filling out a complex form, this rotation can wipe out all their typed data, causing massive frustration. Your job is to engineer a system that perfectly preserves their progress no matter how they hold their device.

Here is what you need to build across the stack:

**1. The Global State Saver (Data Preservation)** You must implement state management logic (like Flutter's `RestorationMixin` or persistent session states) that caches form inputs in real-time. When the device flips and the screen rebuilds, the UI must instantly repopulate the text fields so the user's progress is kept perfectly intact.

**2. The Rotation Transition Lock (Mistake-Proofing / Poka-Yoke)** When a screen rotates, the layout briefly stretches and animates. If a user accidentally taps the "Submit" button during this split-second animation loop, it can fire half-completed or corrupted states down the network lines. The layout controller must automatically block and disable the submission keys until the rotation animation is completely finished.

**3. Cross-Platform Consistency** While this is primarily a mobile issue, the solution must be responsive. The layout must adapt gracefully from a vertical mobile stack to a wider landscape or tablet view without losing a single character of input.''',

    'RCGLA-033-A01': '''This task focuses on **Mobile UI Development** and **Interface Architecture**. You are building a "Responsive Supporting Pane Layout" to display contextual help, documentation, or secondary metrics without cluttering the user's primary workspace.

When users are filling out a complex form or analyzing a chart, they often need reference material (tips, trace metrics, etc.). On a large monitor, you can easily show this side-by-side. On a mobile phone, trying to cram two panels next to each other creates an unusable, squished interface.

Here is what you need to build across the stack:

**1. The Side-Sheet Architecture (Web/Desktop)** On extra-wide windows, the layout must present a standard Material Design "Side-Sheet." The primary task sits on the left, and the vital documentation/supporting pane sits cleanly on the right, providing contextual tips right alongside the workflow.

**2. Mobile Reflow & Masking (Responsive UX)** On a smartphone, the primary entry rows must stretch to fill the tiny canvas fluidly. The supporting pane must automatically respond in one of two ways:
* **Reflow:** It drops down and stacks vertically beneath the main focus components.
* **Masking:** It hides completely behind a clean menu link or collapsible group wrapper (like an accordion), waiting for the user to tap it.

**3. The Hardcode Blocker (Mistake-Proofing / Poka-Yoke)** Developers must use the official, fluid layout wrappers. If a developer attempts to hardcode fixed screen layouts or static pixel widths, the pre-release code checks (linters) will automatically fail the build, forcing them to use the standard responsive component wraps.''',

    'RCGLA-033': '''This task focuses on **Mobile UI Development** and **Interface Architecture**. You are building a "Responsive Supporting Pane Layout" to display contextual help, documentation, or secondary metrics without cluttering the user's primary workspace.

When users are filling out a complex form or analyzing a chart, they often need reference material (tips, trace metrics, etc.). On a large monitor, you can easily show this side-by-side. On a mobile phone, trying to cram two panels next to each other creates an unusable, squished interface.

Here is what you need to build across the stack:

**1. The Side-Sheet Architecture (Web/Desktop)** On extra-wide windows, the layout must present a standard Material Design "Side-Sheet." The primary task sits on the left, and the vital documentation/supporting pane sits cleanly on the right, providing contextual tips right alongside the workflow.

**2. Mobile Reflow & Masking (Responsive UX)** On a smartphone, the primary entry rows must stretch to fill the tiny canvas fluidly. The supporting pane must automatically respond in one of two ways:
* **Reflow:** It drops down and stacks vertically beneath the main focus components.
* **Masking:** It hides completely behind a clean menu link or collapsible group wrapper (like an accordion), waiting for the user to tap it.

**3. The Hardcode Blocker (Mistake-Proofing / Poka-Yoke)** Developers must use the official, fluid layout wrappers. If a developer attempts to hardcode fixed screen layouts or static pixel widths, the pre-release code checks (linters) will automatically fail the build, forcing them to use the standard responsive component wraps.''',

    'CCBPB-011-A01': '''This task focuses on **Financial Compliance Guardrails** and **System Operations**. You are building a live "Budget vs. Actual Expenditure Alert" system to replace slow, retroactive monthly accounting reviews. 

When a team is spending money, they need to know instantly if they are approaching or exceeding their budget. If they actually hit the absolute limit, the app must physically stop them from spending more money.

Here is what you need to build across the stack:

**1. The Sticky Warning Banner (UI/UX)** You must build a standardized banner layout component that anchors cleanly just below the header lines. This banner is pinned firmly to the top of the viewport so it stays visible even when the user scrolls down the page. It condenses complex spreadsheet data into a highly visible, concise message.

**2. Dynamic Error Colors (Material 3)** The banner's visibility and color are driven by global conditional display properties. If the spending limit is breached, the banner must dynamically shift to bold system warning colors, specifically utilizing the `md.sys.color.errorContainer` property to emphasize the critical condition.

**3. The 100% Hard Lockout (Mistake-Proofing / Poka-Yoke)** This is a strict financial control: the interface must physically block new purchase submissions the moment spending metrics cross the 100% hard limit. Additionally, any budget tracking interface built without this alert hook will automatically fail the build pipeline validation.''',

    'CCBPB-011': '''This task focuses on **Financial Compliance Guardrails** and **System Operations**. You are building a live "Budget vs. Actual Expenditure Alert" system to replace slow, retroactive monthly accounting reviews. 

When a team is spending money, they need to know instantly if they are approaching or exceeding their budget. If they actually hit the absolute limit, the app must physically stop them from spending more money.

Here is what you need to build across the stack:

**1. The Sticky Warning Banner (UI/UX)** You must build a standardized banner layout component that anchors cleanly just below the header lines. This banner is pinned firmly to the top of the viewport so it stays visible even when the user scrolls down the page. It condenses complex spreadsheet data into a highly visible, concise message.

**2. Dynamic Error Colors (Material 3)** The banner's visibility and color are driven by global conditional display properties. If the spending limit is breached, the banner must dynamically shift to bold system warning colors, specifically utilizing the `md.sys.color.errorContainer` property to emphasize the critical condition.

**3. The 100% Hard Lockout (Mistake-Proofing / Poka-Yoke)** This is a strict financial control: the interface must physically block new purchase submissions the moment spending metrics cross the 100% hard limit. Additionally, any budget tracking interface built without this alert hook will automatically fail the build pipeline validation.''',

    'IS07-FIEVR-012-AS01-A01': '''This task focuses on **Client-Side Verification Architecture** and **Pure Mathematical Logic Engineering**. You are building a "Local Reconciliation Gate"---a smart financial or data-entry form that double-checks the user's math locally on their device before allowing them to submit.

By checking the math directly on the phone or browser, you avoid sending bad data to the server, which saves data bandwidth and prevents unnecessary network round-trips. 

Here is what you need to build across the stack:

* **"On-Blur" Local Validation:** You must connect verification triggers to run every time an active form field loses focus (when the user taps away from the text box).
* **The Fail-Closed Zero-Balance Lock (Mistake-Proofing):** The submission pathway remains completely locked until all entry lines perfectly balance out (producing a zero balance). Furthermore, the module must default to a "Fail-Closed" state, blocking submissions if any input is null or empty.
* **Error Accents & 2-Minute Timeouts:** When calculations do not match, the form must transition border outlines to error accent colors and render helper text detailing exactly how to fix the mismatch. If an error goes unresolved for two minutes, the interface must aggressively highlight the exact line causing the variance. Conversely, perfect entries receive clear balance checkmarks.''',

    'IS07-FIEVR-012-AS01': '''This task focuses on **Client-Side Verification Architecture** and **Pure Mathematical Logic Engineering**. You are building a "Local Reconciliation Gate"---a smart financial or data-entry form that double-checks the user's math locally on their device before allowing them to submit.

By checking the math directly on the phone or browser, you avoid sending bad data to the server, which saves data bandwidth and prevents unnecessary network round-trips. 

Here is what you need to build across the stack:

* **"On-Blur" Local Validation:** You must connect verification triggers to run every time an active form field loses focus (when the user taps away from the text box).
* **The Fail-Closed Zero-Balance Lock (Mistake-Proofing):** The submission pathway remains completely locked until all entry lines perfectly balance out (producing a zero balance). Furthermore, the module must default to a "Fail-Closed" state, blocking submissions if any input is null or empty.
* **Error Accents & 2-Minute Timeouts:** When calculations do not match, the form must transition border outlines to error accent colors and render helper text detailing exactly how to fix the mismatch. If an error goes unresolved for two minutes, the interface must aggressively highlight the exact line causing the variance. Conversely, perfect entries receive clear balance checkmarks.''',

    'SSELC-032': '''This task focuses on **Coordinate-Based Image Cropping** and **Visual Isolation**. You are building an image cropper that renders only a specific pixel bounding box (x, y, width, height) received from a data source.

**1. Bounding Box Coordinate Array Parsing** The cropping engine accepts a bounding box array defining exact pixel coordinates.
**2. CustomPainter Pixel Mask Rendering** Renders only the specified pixel snippet region of an image canvas using CustomPainter overlays.
**3. Cropped Snippet Container** Positions the isolated pixel snippet preview container beside or above data-entry metadata fields.
**4. Workspace Scroll Lock** Disables root page scrolling using `NeverScrollableScrollPhysics` while the workspace is active.''',

    'SSELC-032-A01': '''This task focuses on **Coordinate-Based Image Cropping** and **Visual Isolation**. You are building an image cropper that renders only a specific pixel bounding box (x, y, width, height) received from a data source.

**1. Bounding Box Coordinate Array Parsing** The cropping engine accepts a bounding box array defining exact pixel coordinates.
**2. CustomPainter Pixel Mask Rendering** Renders only the specified pixel snippet region of an image canvas using CustomPainter overlays.
**3. Cropped Snippet Container** Positions the isolated pixel snippet preview container beside or above data-entry metadata fields.
**4. Workspace Scroll Lock** Disables root page scrolling using `NeverScrollableScrollPhysics` while the workspace is active.''',

    'DSDD-002-A01': '''This task focuses on **Backward-Linked Financial Data Modeling** and **Django ORM Material Card Views**.

**1. Backward-Linked Data Models** Models Django financial ORM schemas (Revenue, COGS, OpEx) linked to financial ledger line items.
**2. Material Card List Views** Renders financial line items inside responsive Material Cards displaying account codes, audit status, and category tags.
**3. Income Statement Summaries** Calculates Gross Revenue, Operating Expenses, and Net Operating Income dynamically.''',

    'APIGW-040': '''This task focuses on **API Gateway Quota Enforcement** and **Rate-Limit Interception**.

**1. HTTP 429 Throttle Interception** Intercepts API rate limit exceptions and displays remaining quota token counters.
**2. Real-Time Token Bucket Visualizer** Visualizes token bucket consumption, refill rates, and throttle backoff timers.
**3. Poka-Yoke Retry Gate** Blocks manual retry requests until the HTTP 429 backoff timer expires.''',

    'APIGW-040-A01': '''This task focuses on **API Gateway Quota Enforcement** and **Rate-Limit Interception**.

**1. HTTP 429 Throttle Interception** Intercepts API rate limit exceptions and displays remaining quota token counters.
**2. Real-Time Token Bucket Visualizer** Visualizes token bucket consumption, refill rates, and throttle backoff timers.
**3. Poka-Yoke Retry Gate** Blocks manual retry requests until the HTTP 429 backoff timer expires.''',

    'GTBPU-001-A01': '''This task focuses on **Public Profile Review Timelines** and **Fluid Typography Scaling**.

**1. Chronological Timeline Events** Renders account audit, background check, and compliance review events in a vertical timeline with date markers.
**2. M3 Elastic Padding** Applies responsive elastic margins and padding (16dp mobile vs 32dp desktop).
**3. Fluid Typography** Dynamically scales font sizes based on viewport MediaQuery constraints.''',

    'ANSA-020-09-A01': '''This task focuses on **Navigation Rail Viewport Mapping**.

**1. Medium/Expanded Mapping (>=600dp)** Displays a vertical M3 NavigationRail for tablet and web layouts.
**2. Compact Mobile Mapping (<600dp)** Automatically switches to a bottom NavigationBar for mobile viewports.
**3. Traceable Independent Component** Provides an isolated, testable Navigation Rail workspace.''',

    'TTIAS-014-A03': '''This task focuses on **CSS Layout Architecture** and **Responsive UI Frameworks**. You are building a "Dynamic Font Resizing Engine" to ensure text remains perfectly readable on any device size.

When text wraps onto multiple lines unexpectedly or gets cut off on small phone screens, it ruins scannability and frustrates high-velocity users. Your goal is to make sure text adjusts smoothly without breaking the layout.

Here is what you need to build across the stack:

**1. Fluid Sizing & Defensive Clamping (Responsive Rules)**
The fonts must dynamically scale up or down depending on the screen size. However, you must establish strict "clamping limits" (0.8x - 1.2x). This prevents text from growing so large on a compact 360px mobile screen that it forces multi-row wrapping or breaks the container.

**2. The Text-Overflow Shield & Clean Rendering (UI/UX)**
If a string of text is simply too long for its container, it must not wrap to a second line. You must apply automated properties (`maxLines: 1`, `TextOverflow.ellipsis`, `softWrap: false`) to cleanly cut it off with "...". Additionally, you must purge all unmapped text-shadow configurations to maximize mobile rendering speed and keep the screen clean.

**3. The Token Enforcer (Mistake-Proofing / Poka-Yoke)**
To guarantee 100% adherence to Material Design 3 typography scales, the compiler must act as a bouncer. It must physically strip out any hardcoded pixel values from the code, forcing developers to use predefined tokens (like `Theme.of(context).textTheme.labelLarge`). Furthermore, if any text field pushes outside its bounding frame, automated testing scripts will immediately throw a warning.''',

    'TTMCS-003-A10-A01': '''This task focuses on **Cross-Platform Mobile Architecture** and **Component Design System Engineering**. You are establishing the root foundation—the "App Shell"—of the entire mobile application. While the original ticket specifies a React Native toolchain, the architectural goal translates directly to setting up your root app component and navigation router, injecting a strict Material Design 3 (MD3) theme, and locking down the layout grids so developers cannot build fragmented or messy screens.

Here is what you need to build across the stack:

**1. The Root Navigator & MD3 Theme Injection**
You must set up the primary navigation library (MaterialApp.router) and wrap the entire application in a root context provider that injects the Material 3 design tokens. The app must explicitly map its backgrounds and text to dynamic color pairings (e.g., md.sys.color.background and md.sys.color.on-background) to maintain contrast in fluctuating ambient light environments.

**2. The 4-to-8 Column Responsive Matrix**
Instead of letting screens float freely, you must build standard layout wrappers that map display dimensions directly to a structural grid.
- **Mobile (<=600px):** Narrow smartphone viewports MUST be locked into a strict 4-column layout matrix (16dp margin, 8dp gutter).
- **Tablet/Desktop (>600px):** The layout must smoothly adjust up to an 8-column configuration on tablet and wider form factors (24dp margin, 16dp gutter).

**3. The Hardcode Assassin (Pre-Commit Linter Poka-Yoke)**
To guarantee absolute design system parity, you must lock down the native dependency boundaries. You are required to build a linting rule and automated test gate that physically fails the workspace compilation routine if any developer attempts to bypass the design system by using unmapped, hardcoded color values or custom layout overrides.''',

    'TTMCS-003-A16-A01': '''This task focuses on **Cross-Platform Mobile Architecture** and **Quality Assurance Verification**. You are building a "Theme Verification Screen" and setting up automated testing gates to prove that the Material Design 3 (MD3) framework is correctly wired into the application.

Setting up a theme is only half the battle; if developers can bypass it, the UI fragments. This task ensures the theme is visibly working and mathematically locked down.

Here is what you need to build across the stack:

**1. The Visual Verification Screen (UI/UX)**
You must build a dedicated test screen that physically renders the MD3 design tokens. It must display elements using dynamic color pairings (e.g., md.sys.color.background vs md.sys.color.on-background) and visually prove that the responsive grid safely adapts from a 4-column layout on mobile to an 8-column layout on tablets.

**2. The 100% Automation Gate (Mistake-Proofing / Poka-Yoke)**
Manual QA is not enough. You must write automated widget tests that verify the theme is applied perfectly. If a developer forgets to apply the theme provider, the CI/CD pipeline must fail instantly.

**3. The Anti-Hardcoding Linter (Enforcement)**
Continuing the strict architecture rules: the workspace compilation routine and local pre-commit hooks MUST trigger a hard breaking error if any component tries to bypass the standard design tokens with unmapped, hardcoded color values (like #FF0000).''',

    'RCGLA-014-A02-A01': '''This task focuses on **Frontend Architecture** and **Component Standardization**. You are building a centralized "Material Design 3 (MD3) Component Library" and shared token set that will act as the single source of truth for the entire application's UI.

Instead of developers building their own buttons and text fields from scratch (which bloats the app size and causes visual inconsistencies), they must use your centralized package.

Here is what you need to build across the stack:

**1. The Shared M3 Token Engine**
You must define the core Material 3 design tokens (colors, typography, margins). This includes standardized ColorSchemes that map directly to the OS and seamlessly transition between Light and Dark modes using dynamic color properties.

**2. Universal Wrappers & Widgets**
You must build standard atomic widgets (like buttons and text fields) that rely strictly on these tokens. The entire application must be wrapped in a global MaterialTheme provider so that every screen inherits this uniform visual hierarchy instantly.

**3. The Local-Code Blocker (Mistake-Proofing / Poka-Yoke)**
To enforce 100% component reuse, you must configure the build system (using linters) to hard-block imports from local component folders. If a developer tries to create a custom, duplicate UI component in their local directory instead of importing from the Universal Library, the build will physically fail. This forces compliance and guarantees visual consistency.''',
  };

  static String getExplanation({
    required String globalRefId,
    required String atomicStepId,
    String? title,
    String? description,
  }) {
    if (_explanations.containsKey(atomicStepId)) {
      return _explanations[atomicStepId]!;
    }
    if (_explanations.containsKey(globalRefId)) {
      return _explanations[globalRefId]!;
    }
    for (final entry in _explanations.entries) {
      if (entry.key.startsWith(globalRefId) ||
          globalRefId.startsWith(entry.key) ||
          entry.key.startsWith(atomicStepId)) {
        return entry.value;
      }
    }
    return '### ${title ?? globalRefId}\n\n'
        '${description ?? "No detailed plain English explanation is currently registered for this component."}\n\n'
        '**Key Objectives:**\n'
        '- Ensure 100% Theme.of(context).colorScheme adherence\n'
        '- Enforce 48dp minimum touch target boundaries for mobile ergonomics\n'
        '- Implement mistake-proofing (Poka-Yoke) input validation';
  }
}

/// Modal Dialog for displaying Plain English Component Explanations
class ComponentExplanationModalDialog extends StatelessWidget {
  final String globalRefId;
  final String title;
  final String category;
  final String explanation;

  const ComponentExplanationModalDialog({
    super.key,
    required this.globalRefId,
    required this.title,
    required this.category,
    required this.explanation,
  });

  static void show({
    required BuildContext context,
    required String globalRefId,
    required String title,
    required String category,
    required String explanation,
  }) {
    showDialog(
      context: context,
      builder: (context) => ComponentExplanationModalDialog(
        globalRefId: globalRefId,
        title: title,
        category: category,
        explanation: explanation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 700;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      insetPadding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 750.0,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                    child: const Icon(Icons.menu_book),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PLAIN ENGLISH EXPLANATION',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        Text(
                          '[$globalRefId] $title',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Modal Body Content (Scrollable formatted text)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: SelectionArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildFormattedExplanation(context, explanation),
                  ),
                ),
              ),
            ),

            const Divider(height: 1),
            // Footer Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: explanation));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Explanation copied to clipboard!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 18.0),
                    label: const Text('Copy Explanation'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFormattedExplanation(BuildContext context, String text) {
    final theme = Theme.of(context);
    final paragraphs = text.split('\n\n');
    final widgets = <Widget>[];

    for (final p in paragraphs) {
      final trimmed = p.trim();
      if (trimmed.isEmpty) continue;

      if (trimmed.startsWith('**') && trimmed.endsWith('**')) {
        // Section Header
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 6.0),
            child: Text(
              trimmed.replaceAll('**', ''),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('**') && trimmed.contains('** ')) {
        // Numbered or bold lead line block
        widgets.add(
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                trimmed,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              trimmed,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ),
        );
      }
    }
    return widgets;
  }
}
