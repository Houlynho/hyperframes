---
name: design-toolkit
description: "The user's saved toolkit of five third-party design tools for AI coding agents, so generated apps and sites stop looking generic: Taste Skill (anti-slop frontend taste), Web Design Guidelines (UI audit against Vercel's rules), Awesome Design / getdesign.md (brand DESIGN.md references), Image to Code (screenshot → code) and Playwright CLI (open the browser, screenshot and verify what was built). Load when building or reviewing any UI, landing page, site or app front end, when the user says the result looks ugly, generic, 'feito em 2006' or 'cara de IA', or when they ask for 'as 5 ferramentas de design'. Lists what each tool is for, when to reach for it, and its install command. [design, ui, frontend, taste, anti-slop, audit, design-md, screenshot-to-code, playwright, visual-qa]"
metadata:
  internal: true
---

# Design Toolkit: the five tools

These are the five tools recommended in a reel the user saved (by @viniciusguimaraes.ia).
They are third-party. **Install them only with the user's go-ahead.** Read each skill's
files before first use, since installed skills run with full agent permissions.

## The loop

Use them in this order on any UI job:

1. **Before building:** pick a reference look (3, Awesome Design) and load taste
   rules (1, Taste Skill).
2. **When the user has a visual they like:** rebuild it from a screenshot (4, Image
   to Code).
3. **After building:** open it in a real browser and screenshot it (5, Playwright
   CLI), then audit it (2, Web Design Guidelines). Fix the issues and repeat until
   the audit is clean.

## 1. Taste Skill

- **What it does:** "The anti-slop frontend framework for AI agents." These are
  open-source skill files that stop Cursor / Claude Code / Codex from shipping
  generic frontends: no default purple gradient, no three identical rounded cards.
- **Site:** tasteskill.dev
- **Install:** `npx skills add Leonxlnx/taste-skill`
- **Use it** whenever you generate a new UI from scratch.

## 2. Web Design Guidelines

- **What it does:** audits UI code against Vercel's Web Interface Guidelines for
  design and accessibility. It fetches the latest rules on each run, accepts files
  or patterns, and reports findings as `file:line`.
- **Source:** skills.sh, repo `vercel-labs/agent-skills`
- **Install:** `npx skills add https://github.com/vercel-labs/agent-skills --skill web-design-guidelines`
- **Use it** after any UI change, before calling it done. Check contrast, spacing,
  hierarchy, alignment, and buttons and focus states.

## 3. Awesome Design (getdesign.md)

- **What it does:** a collection of `DESIGN.md` files analysed from popular brands'
  design systems. Drop one into the project and the agent generates a matching UI
  (typography, colour, spacing, components, layout).
- **Site:** getdesign.md. Repo: `VoltAgent/awesome-design-md`.
- **Use it:** copy the chosen brand's `DESIGN.md` into the project root and tell the
  agent to follow it. It is reference material, not an executable skill.

## 4. Image to Code

- **What it does:** take a screenshot of a design you like (Pinterest, Dribbble, a
  real site) and the agent rebuilds it as code.
- **Source:** a GitHub project shown as "Image To Code" in the reel. **Exact repo not
  yet confirmed.** Ask the user, or check the reel creator's list (comment
  "DESIGN" on the reel), before installing anything under this name.
- **Until confirmed:** Claude can already read an attached screenshot and rebuild it.
  Pair that with tool 5 to compare the result against the original.

## 5. Playwright CLI

- **What it does:** "CLI for common Playwright actions." It can record and generate
  Playwright code, inspect selectors and take screenshots. With it the agent opens
  the browser, uses the site, screenshots it and checks what it built.
- **Site:** playwright.dev. Repo: `microsoft/playwright-cli`.
- **Install:** follow the repo README. Confirm the current package name there before
  installing.
- **In this environment:** a Chromium + Playwright is often pre-installed
  (`require('playwright')`). Use it for screenshots without installing anything.
