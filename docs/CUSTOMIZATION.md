# Customization Guide

How to extend and adapt Claude Job Autopilot for your own use case.

---

## Add a New Resume / Role Category

1. **Add a variant entry** to `variants/resumes.yaml`:

```yaml
- filename: "Resume_DevOps_Engineer.docx"
  summary: >
    Your tailored summary here...
  projects:
    - find_keyword: "Some Project"
      bullets:
        - "Bullet point one"
        - "Bullet point two"
  insert_projects: []
  skills:
    - "Programming Languages: Python, Bash, Go"
    - "Tools: Docker, Kubernetes, Terraform, AWS"
    - "Concepts: CI/CD, Infrastructure as Code, SRE"
```

2. **Add a cover letter** entry to `variants/coverletters.yaml`:

```yaml
- filename: "CoverLetter_DevOps_Engineer.docx"
  salutation: "Dear Hiring Manager,"
  body:
    - "Opening paragraph..."
    - "Middle paragraph..."
    - "Closing paragraph..."
  closing: "Sincerely,"
```

3. **Add a variant key** to `config.yaml → resume_variants`:

```yaml
resume_variants:
  E:
    label: "DevOps / Cloud Engineer"
    filename: "Resume_DevOps_Engineer"
    jd_keywords:
      - "DevOps"
      - "Kubernetes"
      - "Docker"
      - "CI/CD"
      - "AWS"
      - "cloud"
      - "infrastructure"
      - "SRE"
```

4. **Add search keywords** to `config.yaml → search_directions` (or create a new direction):

```yaml
search_directions:
  DevOps:
    label: "DevOps / Cloud / SRE"
    keywords:
      - "junior DevOps engineer"
      - "entry level cloud engineer"
      - "junior SRE"
      - "junior infrastructure engineer"
```

5. **Update the platform rotation** in `config.yaml → platform_rotation` to include the new direction in each weekday's list.

6. **Rebuild** your resumes and cover letters:

```bash
python3 scripts/build_resumes.py
python3 scripts/build_coverletters.py
soffice --headless --convert-to pdf ~/job_hunt/resumes/*.docx --outdir ~/job_hunt/resumes/
```

7. **Update** the Resume Selection table in `skills/SKILL.md` to include the new variant key and its keywords.

---

## Change the Target Region

1. Update `config.yaml → job_search → location` to your primary city/region.
2. Update `config.yaml → job_search → location_alternatives` with nearby cities to use as fallbacks.
3. Update `config.yaml → user → city` and `user.postal_code` to reflect your actual location.
4. Update your cover letters and resume summaries to reference the new region.

---

## Add or Remove Job Platforms

The skill currently supports LinkedIn, Indeed, Glassdoor, and Monster.

To **add a platform** (e.g. Workopolis, HelloWork):

1. Add it to the `platforms` list in each weekday entry of `config.yaml → platform_rotation`.
2. Add a platform-specific notes section to `docs/PLATFORMS.md`.
3. Add the corresponding apply-flow logic to the `skills/SKILL.md` Application Flow section.

To **remove a platform**, delete it from the rotation lists in `config.yaml`.

---

## Change the Search Direction Rotation

Edit `config.yaml → platform_rotation`. Each weekday entry has two lists:

- `platforms` — order in which platforms are processed that day
- `directions` — order in which search directions are tried within each platform

Rotating both independently ensures every direction gets equal exposure across all
platforms over the course of a week.

---

## Change the Schedule

In Claude Cowork, open **Scheduled Tasks**, find the `daily-job-applications` task,
and click **Edit**. Or run `/schedule` again and describe the new time.

Alternatively, update `config.yaml → schedule → time` and re-run the skill setup.

---

## Add a Province / State Holiday

Edit `config.yaml → holidays → dates_{year}` and add the date in `YYYY-MM-DD` format.
For a new year, add a new `dates_20XX` key with the full list.

---

## Add Companies to the Skip List

Edit `config.yaml → job_search → filters → skip_companies`. Add the company name
exactly as it appears on the job boards (case-insensitive matching is used).

---

## Adjust the Experience Filter

`config.yaml → job_search → filters → max_years_experience` controls the maximum
years of experience a job may require before it is skipped. Default is 2 years.

---

## Customise the ATS Password Pattern

Edit `config.yaml → ats_password_pattern`. The placeholder `{CompanyName}` is replaced
with the actual company name when creating accounts. Example:

```yaml
ats_password_pattern: "FirstName@{CompanyName}{Year}!"
# → "FirstName@Shopify2025!"  ({Year} is replaced with the current calendar year at runtime)
```

Choose a pattern that is memorable and meets common password requirements (uppercase,
lowercase, number, special character).

---

## Use a Different Resume Template

Replace the file at `config.yaml → paths → resume_template` with your new `.docx`.

Make sure the new template follows the expected structure:
- **Summary**: First non-empty run in the first table cell
- **Project headers**: Two-column tables (title | date) with unique searchable titles
- **Project bullets**: ListParagraph-style paragraphs immediately after each project table
- **Skills**: Paragraphs starting with recognisable category prefixes (e.g. "Tools:", "Concepts:")

Adjust `find_keyword` values in `variants/resumes.yaml` to match the new template's project titles.
