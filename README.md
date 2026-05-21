# Claude Job Autopilot

> Automated daily job applications powered by [Claude](https://claude.ai) + Claude in Chrome.

Claude Job Autopilot is a **Claude Cowork skill pack** that automatically searches and applies to jobs every weekday morning — across your chosen platforms — using your tailored resumes and cover letters.

**Works for any role, any level, any industry.** Whether you're a new grad hunting your first job or a senior engineer making a move, everything is driven by your `config.yaml` — no code changes needed.

---

## Features

- **Fully configurable experience level** — set `entry`, `junior`, `mid`, or `senior` in one line; the skill adjusts seniority filters and experience requirements automatically
- **Any role, any industry** — define your own resume variants and search directions; the four built-in examples (ML/AI, Software Dev, Data Analyst, PM) are just a starting point
- **Smart resume selection** — reads each full job description and picks the best-matching resume from your library based on keyword overlap, not just job title
- **Flexible platforms** — LinkedIn, Indeed, Glassdoor, and Monster are included by default; enable or disable any of them, or add custom platforms with a search URL template
- **Daily rotation** — platform order and search direction both rotate each weekday so every platform gets equal priority over the week
- **Freshness-first** — always targets the most recently posted qualifying jobs first
- **Company size filter** — optionally skip large corporations and focus on small-to-mid-size companies
- **Auto-registration** — uses Google Sign-In or creates accounts on external ATS portals automatically
- **CAPTCHA-safe** — attempts once; leaves the tab open for you to complete manually if it fails
- **Cover letter generation** — attaches role-tailored cover letters or fills in text boxes with a customised paragraph
- **Daily log** — every application is logged with company, role, resume used, post date, and outcome

---

## How It Works

```
Every weekday at your chosen time
        │
        ▼
  Claude Cowork wakes up
        │
        ├─ Checks for public holidays → skips if holiday
        ├─ Verifies resumes are up to date
        │
        └─ For each platform (in today's rotation order):
                │
                ├─ Searches all 5 directions (in today's rotation order)
                ├─ Filters: experience level · company size · your region · newest first
                ├─ Reads full JD → selects best resume
                ├─ Applies (Easy Apply / Indeed Apply / external ATS)
                └─ Logs result → repeats until 5 applied per platform
```

---

## Prerequisites

| Requirement | Notes |
|---|---|
| [Claude Desktop](https://claude.ai/download) | With Cowork mode enabled |
| Claude in Chrome extension | Install from the Chrome Web Store and connect it to Claude Cowork |
| Chrome — logged in to all 4 platforms | LinkedIn, Indeed, Glassdoor, Monster — Claude in Chrome uses your **existing browser session**. Log in manually before the first run and tick "Remember me". Claude will not handle logins. |
| Sessions stay alive | Job platform sessions can expire. If a platform logs you out overnight, Claude will skip it and log the failure. Check Chrome occasionally to keep sessions active. |
| Python 3.10+ | For running the resume/cover letter build scripts |
| `python-docx`, `lxml`, `pyyaml` | `pip install python-docx lxml pyyaml` |
| LibreOffice | For PDF export — `soffice --headless --convert-to pdf ...` |
| A base resume `.docx` template | Your own resume as the starting point for the build scripts |

---

## Quick Start

### 1. Clone the repo

```bash
git clone https://github.com/einarInCanada/claude-job-autopilot.git
cd claude-job-autopilot
```

### 2. Install Python dependencies

```bash
pip install python-docx python-dateutil
```

### 3. Fill in your config

```bash
cp config.example.yaml config.yaml
# Edit config.yaml with your personal info, job preferences, and file paths
```

### 4. Place your resume template

Put your base `.docx` resume at the path specified in `config.yaml` under `resume_template`.

### 5. Build your tailored resumes and cover letters

```bash
python3 scripts/build_resumes.py
python3 scripts/build_coverletters.py
```

This generates one resume and one cover letter per role category into your configured output directory.

### 6. Install the skill in Claude Cowork

1. Open Claude Desktop → Cowork mode
2. Go to **Settings → Skills → Add skill from folder**
3. Select the `skills/` folder in this repo
4. The skill `job-autopilot` will appear in your skill list

### 7. Set up the scheduled task

In Claude Cowork, run:
```
/schedule
```
Then describe your preferred time, e.g.: *"Run the job-autopilot skill every weekday at 9 AM"*

Claude will create the scheduled task automatically using the `schedule` settings in your `config.yaml`.
You can change the time, timezone, and days at any point by editing the scheduled task in Cowork → Scheduled.

### 8. First run — approve browser permissions

Click **Run now** in the Scheduled section to pre-approve Claude in Chrome tool permissions. This prevents the task from pausing mid-run for approvals.

---

## Directory Structure

```
claude-job-autopilot/
├── README.md
├── LICENSE
├── .gitignore
├── config.example.yaml          ← Copy to config.yaml and fill in your info
├── skills/
│   └── SKILL.md                 ← The Claude Cowork skill definition
├── scripts/
│   ├── build_resumes.py         ← Generates tailored resumes from your template
│   └── build_coverletters.py   ← Generates role-specific cover letters
└── docs/
    ├── SETUP.md                 ← Detailed setup walkthrough
    ├── PLATFORMS.md             ← Notes on each job platform's apply flow
    └── CUSTOMIZATION.md         ← How to add roles, regions, and search terms
```

---

## Customisation

### Change your experience level

Set `experience_level` in `config.yaml` to one of: `entry` · `junior` · `mid` · `senior`.
The skill automatically adjusts which job titles and experience requirements it filters for.

### Add a new role category

1. Add a new entry to `config.yaml` under `resume_variants` with your keywords
2. Add a variant entry to `variants/resumes.yaml` with your tailored bullets and skills
3. Add a cover letter entry to `variants/coverletters.yaml`
4. Add corresponding search keywords under `search_directions` in `config.yaml`
5. Re-run `python3 scripts/build_resumes.py && python3 scripts/build_coverletters.py`

The built-in examples (ML/AI Engineer, Software Developer, Data Analyst, Product Manager) are just defaults — replace them entirely if they don't fit your field.

### Add or remove platforms

Edit the `platforms:` list in `config.yaml`. Add any platform with a `search_url` template and an `apply_type`. See `config.example.yaml` for the format and commented-out examples.

### Change the target region

Edit `job_search.location` in `config.yaml`. Update `job_search.location_alternatives` for fallback searches.

### Change the schedule

Edit the scheduled task in Claude Cowork → Scheduled, or re-run `/schedule` with a new time.

---

## Privacy & Safety

- Your `config.yaml` contains personal information — it is listed in `.gitignore` and will **never** be committed to git
- The skill never enters payment information or Social Insurance Numbers
- CAPTCHA attempts are limited to one try; failed attempts are left for manual completion
- All application activity is logged locally to `application_log.txt`

---

## Contributing

PRs welcome. Ideas for improvement:
- Support for more job platforms (Workopolis, HelloWork, etc.)
- Multi-region support
- Slack/email notifications for daily summary
- Auto-tracking of interview callbacks

---

## License

**Personal Use Only** — see [LICENSE](LICENSE)

Free for personal, non-commercial use. You may use, copy, and modify this project
for your own job search. Commercial use, resale, or incorporation into any paid
product or service is not permitted without the author's explicit written consent.

---

## Sponsor

**Proudly sponsored by [Manyoffer](https://manyoffer.com)**

Landing interviews is only half the battle. Practice your answers, get AI-powered feedback, and walk into every interview confident — with Manyoffer's interview prep platform.

[![Manyoffer](https://img.shields.io/badge/Practice%20Interviews-manyoffer.com-blue?style=for-the-badge)](https://manyoffer.com)
