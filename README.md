# UDF — UX Design & Frontend Engineering

Welcome to the home of the **UDF team** at Habot.

UDF owns the user-facing surface of Habot's products — the web frontends, the Flutter mobile apps, and the design system that keeps them consistent. This folder is the **parent workspace** that holds every UDF codebase side by side.

## What lives here

Each codebase is a **sibling folder** under this directory (monorepo-style — one workspace, many projects). As projects come online, they'll appear here:

```
UDF/
├── README.md          ← you are here
├── habot-web/         Web frontend
├── habot-mobile/      Flutter mobile app
└── shared/            Design system, tokens, shared components
```

> More projects will be added over time. Each project keeps its own `README.md` with setup and run instructions.

## Who we are

| Discipline | Focus |
|------------|-------|
| **UX Design** | Product design, user flows, the Habot design system |
| **Frontend Engineering** | Web application development |
| **Mobile Engineering** | Cross-platform apps built with **Flutter** |

## Getting started

1. Clone this workspace (you likely already have it if you're reading this).
2. Open the specific project folder you're working on — **not** this parent folder — in your editor.
3. Follow that project's own `README.md` for install and run steps.

## Conventions

A few things that keep the workspace tidy as it grows:

- **One folder per project.** Keep each codebase self-contained; don't reach across sibling folders directly — share via a designated shared package.
- **Every project ships a README.** At minimum: what it is, how to install, how to run, how to build.
- **Consistent naming.** Use lowercase, hyphenated folder names (e.g. `habot-web`, `habot-mobile`).
- **Design tokens are the source of truth.** Colors, spacing, and typography come from the shared design system — don't hardcode them per project.

## Need help?

Reach out to the UDF team lead or drop a message in the team channel. When in doubt about where something belongs, ask before creating a new top-level folder.

---

_Maintained by the UDF team · Habot_
