# Setup Guide

A detailed walkthrough for getting Claude Job Autopilot running from scratch.

---

## Step 1 — Clone the Repository

```bash
git clone https://github.com/einarInCanada/claude-job-autopilot.git
cd claude-job-autopilot
```

---

## Step 2 — Install Python Dependencies

```bash
pip install python-docx lxml pyyaml python-dateutil
```

Verify:

```bash
python3 -c "import docx, lxml, yaml; print('OK')"
```

---

## Step 3 — Install LibreOffice (for PDF export)

LibreOffice is used to convert `.docx` resumes to PDF.

**macOS:**
```bash
brew install --cask libreoffice
```

**Ubuntu / Debian:**
```bash
sudo apt-get install libreoffice
```

**Windows:** Download from https://www.libreoffice.org/download/

Verify:
```bash
soffice --version
```

---

## Step 4 — Create Your Configuration File

```bash
cp config.example.yaml config.yaml
```

Open `config.yaml` in any text editor and fill in every field:

| Section | What to fill in |
|---|---|
| `user` | Your name, email, phone, city, postal code, LinkedIn, portfolio URL |
| `work_authorization` | Whether you are legally allowed to work, visa type, sponsorship requirement |
| `education` | Your degree, field, school, and total years of **paid** work experience |
| `work_experience` | Note on paid experience; list any unpaid/volunteer roles |
| `paths` | Where your output files live; path to your base `.docx` resume template |
| `job_search` | Your target location, fallback locations, experience level, company size filter, skip list |
| `resume_variants` | Your resume categories with filenames and JD keywords (any industry) |
| `search_directions` | Your search keyword sets — one per role/industry direction |
| `platform_rotation` | Mon–Fri rotation table (defaults are ready to use) |
| `holidays` | Public holidays in your region |
| `ats_password_pattern` | Your preferred password template for external ATS portals |
| `schedule` | Time and days for the automated task |

> **Security:** `config.yaml` is listed in `.gitignore` and will never be committed. Never commit it manually.

---

## Step 5 — Set Up Your Resume Template

Place your base `.docx` resume at the path you specified in `config.yaml → paths.resume_template`.

Your template should contain:

- A summary/self-assessment paragraph (in the first cell of the first table)
- Project sections as header tables (two-column: title | date), each followed by list-style bullet paragraphs
- A Skills section with one paragraph per skill category (starting with a recognisable prefix like "Tools:", "Skills:", "Concepts:", etc.)

The build script matches projects by searching for a unique keyword in the header table text, so make sure each project title is distinct.

---

## Step 6 — Define Your Resume Variants

```bash
cp variants/resumes.example.yaml variants/resumes.yaml
```

Edit `variants/resumes.yaml` to describe each resume variant:

- `filename` — output `.docx` filename
- `summary` — the summary paragraph for this role focus
- `projects` — which existing template projects to keep/remove/replace
- `insert_projects` — new projects to insert (newest first)
- `skills` — the skills section lines for this variant

See `variants/resumes.example.yaml` for a fully worked example with two variants.

---

## Step 7 — Define Your Cover Letter Variants

```bash
cp variants/coverletters.example.yaml variants/coverletters.yaml
```

Edit `variants/coverletters.yaml`. Each variant needs:

- `filename` — matching the resume variant name (e.g. `CoverLetter_ML_AI_Engineer.docx`)
- `salutation` — e.g. `Dear Hiring Manager,`
- `body` — list of paragraphs (3 is a good length for one-page cover letters)
- `closing` — e.g. `Sincerely,`

Your name, email, phone, city, and portfolio URL are pulled automatically from `config.yaml`.

---

## Step 8 — Build Resumes and Cover Letters

```bash
python3 scripts/build_resumes.py
python3 scripts/build_coverletters.py
```

This generates `.docx` files in `{output_dir}/resumes/` and `{output_dir}/cover_letters/`.

---

## Step 9 — Export Resumes to PDF

```bash
soffice --headless --convert-to pdf ~/job_hunt/resumes/*.docx --outdir ~/job_hunt/resumes/
```

Replace `~/job_hunt/resumes/` with your configured `paths.output_dir/resumes_subdir`.

Verify page count (requires `pypdf`):
```bash
pip install pypdf
python3 - <<'EOF'
from pypdf import PdfReader
import pathlib
for p in pathlib.Path("~/job_hunt/resumes/").expanduser().glob("*.pdf"):
    pages = len(PdfReader(str(p)).pages)
    print(f"{p.name}: {pages} page(s)")
EOF
```

All resumes should be exactly 1 page.

---

## Step 10 — Install the Skill in Claude Cowork

1. Open **Claude Desktop** → Cowork mode
2. Go to **Settings → Plugins → Add skill from folder**
3. Select the `skills/` folder inside this repo
4. The skill `job-autopilot` will appear in your skill list

---

## Step 11 — Log In to All Four Job Platforms

Make sure you are logged in (and staying logged in) to:

- [LinkedIn](https://www.linkedin.com)
- [Indeed](https://ca.indeed.com)
- [Glassdoor](https://www.glassdoor.ca)
- [Monster](https://www.monster.ca)

Claude in Chrome will use your existing sessions — it does not handle login itself.

---

## Step 12 — Set Up the Scheduled Task

In Claude Cowork, run the `/schedule` skill or type your preferred schedule, e.g.:

> "Run the job-autopilot skill every weekday at 9 AM"

Use whatever time suits your timezone and routine. The schedule can be changed at any time
by editing the task in Cowork → Scheduled, or by running `/schedule` again.

Claude will create a scheduled task using your `config.yaml → schedule` settings.

---

## Step 13 — First Run

Click **Run now** in the Scheduled Tasks panel to do a dry run.
This also pre-approves the Claude in Chrome browser permissions so the task
does not pause mid-run on subsequent days waiting for your approval.

Watch the summary output — you should see platforms, directions, and applications logged.

---

## Troubleshooting

**"config.yaml not found"** — Make sure you copied `config.example.yaml` to `config.yaml` and the script is being run from the repo root, or that the script can find `../config.yaml` relative to its own location.

**"Resume template not found"** — Check `paths.resume_template` in `config.yaml`. Use an absolute path (e.g. `~/job_hunt/my_resume.docx`).

**Page count > 1** — Reduce bullet points in `variants/resumes.yaml` for the offending variant. Removing projects by setting `bullets: null` is the most effective way to save space.

**LibreOffice not found** — Make sure `soffice` is on your PATH. On macOS with Homebrew: `export PATH="/Applications/LibreOffice.app/Contents/MacOS:$PATH"`.

**CAPTCHA left open** — This is expected behaviour. Complete the CAPTCHA manually in the browser tab that Claude left open, then submit.
