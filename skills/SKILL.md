# Skill: job-autopilot

> Automated daily job applications powered by Claude in Chrome.
> Reads all configuration from `config.yaml` in the repo root.

---

## Overview

This skill runs on the schedule defined in `config.yaml` and applies to qualifying jobs
across all configured platforms (up to `applications_per_platform` per platform per day).
It selects the best-matching resume variant for each job by reading the full job
description, attaches a tailored cover letter, and logs every outcome.

---

## Prerequisites (verify before every run)

1. Read `config.yaml` from the repo root (at `../config.yaml` relative to this skill file).
2. Confirm the following files exist at the paths defined in `config.yaml → paths`:
   - `resume_template` — the base .docx resume
   - For each variant key in `resume_variants`: `{output_dir}/resumes/{filename}.pdf`
   - For each variant key in `resume_variants`: `{output_dir}/cover_letters/CoverLetter_{filename}.docx`
   - If any PDF is missing, stop and tell the user to run `python3 scripts/build_resumes.py`
3. Confirm `{output_dir}/application_log.txt` exists (create it if not).

---

## Holiday Check

- Read `config.yaml → holidays.dates_{current_year}`.
- If today's date is in that list, log `[SKIPPED — Holiday]` and stop.

---

## Daily Rotation

Determine today's weekday name (Monday … Friday).

Read from `config.yaml → platform_rotation → {Weekday}`:
```
platforms:  [P1, P2, ...]     ← process platforms in this order today
directions: [D1, D2, D3, ...]  ← search in this order within each platform
```

---

## Per-Platform Loop

Read the active platform list from `config.yaml → platforms`.
For each platform in today's rotation, skip any not present in the `platforms` list.

### Goal: `config.yaml → applications_per_platform` applications per platform per day.

Read the limit from `config.yaml → applications_per_platform` (default: 5).

1. Set `applied_this_platform = 0`
2. Iterate through today's `directions` list in order.
3. For each direction, get keywords from `config.yaml → search_directions → {direction} → keywords`.
4. Search all keywords on the current platform (sort by newest first).
5. For each result, run the **Job Filter**. If it passes, run the **Application Flow**.
6. Increment `applied_this_platform` after each successful application.
7. When `applied_this_platform == applications_per_platform`, move to the next platform.
8. If all directions are exhausted before reaching the limit: log the count and move on. Apply as many as possible — never skip early.

---

## Experience Level Rules

Read `config.yaml → experience_level` and apply the corresponding rules:

| Level | Max years exp required by JD | Title rule |
|---|---|---|
| `entry` | 1 year | Title **must** contain: Intern, Entry, Junior, Jr., Graduate, New Grad |
| `junior` | 2 years | Title contains one of the above **OR** contains no seniority word at all |
| `mid` | 5 years | Title must **not** contain: Senior, Sr., Lead, Staff, Principal, Manager, Director, VP |
| `senior` | unlimited | No title restriction |

If `config.yaml → job_search → filters` has explicit `max_years_experience` or `allowed_seniority` overrides, use those instead.

---

## Job Filter

A job passes **all** of the following:

| Check | Rule |
|---|---|
| Location | Job location matches `job_search.location` or any `location_alternatives` entry |
| Seniority & Experience | Apply the Experience Level Rules above |
| Company size | If `filters.company_size == "small_to_mid"`: skip companies with >1000 employees |
| Skip list | Company name not in `filters.skip_companies` |
| Already applied | Company + role combination not already in `application_log.txt` |
| Posted date | Prefer jobs posted within the last 7 days; go older only if needed to reach 5 |

---

## Resume Selection

Read the **full job description text**. Count how many keywords from each variant's
`jd_keywords` list (in `config.yaml → resume_variants`) appear in the JD.
Select the variant with the **highest match count**. On a tie, prefer the variant
whose `label` most closely matches the job title.

Build the selection table dynamically from `config.yaml → resume_variants`:

| Variant Key | Label | Keywords (from config) |
|---|---|---|
| (read from config) | (read from config) | (read from config) |

Resume PDF path: `{output_dir}/resumes/{resume_variants[key].filename}.pdf`
Cover letter path: `{output_dir}/cover_letters/CoverLetter_{resume_variants[key].filename}.docx`

---

## Application Flow

### A. LinkedIn Easy Apply

1. Open the job listing → click **Easy Apply**.
2. Fill all fields from `config.yaml → user`:
   - First name → `user.display_first_name` (legal fields → `user.legal_first_name`)
   - Last name → `user.legal_last_name`
   - Email → `user.email`
   - Phone → `user.phone`
   - City/Location → `user.city`
   - LinkedIn URL → auto-detected from logged-in session (or `user.linkedin_url`)
3. Upload the selected resume PDF.
4. Cover letter text box (if shown): paste the first 3 paragraphs of the cover letter.
5. Answer screening questions using `config.yaml` values:
   - Work authorization → `work_authorization.authorized_to_work`
   - Require sponsorship → `work_authorization.requires_sponsorship`
   - Years of experience → `education.years_of_experience` (paid only — exclude unpaid roles in `work_experience.unpaid_roles`)
   - Education level → `education.degree`
   - Visa/permit type → `work_authorization.visa_status`
6. CAPTCHA: attempt once. If unsolved, leave tab open, log `[CAPTCHA — manual required]`, move on.
7. Submit. Log result.

### B. Indeed Apply

1. Open listing → click **Apply now** / **Indeed Apply**.
2. If redirected to an external site, follow **Section C**.
3. Fill fields from `config.yaml → user` (same mapping as LinkedIn above).
4. Upload resume PDF.
5. Answer screening questions as above.
6. CAPTCHA: attempt once; leave tab open if failed.
7. Submit. Log result.

### C. External ATS (Greenhouse, Lever, Workday, iCIMS, BambooHR, etc.)

1. Look for **Sign in with Google** or an existing account option — use it if available.
2. If no SSO: check `application_log.txt` for a previous account at this company.
   - Found: use stored credentials (`user.email` + `ats_password_pattern` with company name substituted).
   - Not found: create account with `user.email` and the generated password. Log it.
3. Fill all form fields from `config.yaml → user`.
4. Upload resume PDF. Attach cover letter .docx if a file field is provided; otherwise paste first 3 paragraphs as plain text.
5. Work authorization questions → use `work_authorization` values from config.
6. CAPTCHA: attempt once; leave tab open if failed.
7. Submit. Log result.

### D. Glassdoor / Monster

Follow the same flow as Indeed (B) / External ATS (C) as applicable.

### E. Custom Platforms

For any platform in `config.yaml → platforms` beyond the four built-ins:

1. If `search_url` is provided: navigate to it with `{keywords}` and `{location}` substituted.
2. If `apply_type == "in_app"`: use the native apply flow and fill fields from `config.yaml → user`.
3. If `apply_type == "external_ats"`: follow Section C.
4. If no `search_url`: navigate to the platform's home page and use its search bar.
5. Apply the same Job Filter, resume selection, and logging rules as all other platforms.

---

## Personal Information Reference

Use **only** values from `config.yaml`. Never guess, invent, or interpolate.

| Form Field | Config Key |
|---|---|
| Legal first name | `user.legal_first_name` |
| Legal last name | `user.legal_last_name` |
| Preferred / display name | `user.display_first_name` |
| Email | `user.email` |
| Phone | `user.phone` |
| City | `user.city` |
| Postal / ZIP code | `user.postal_code` |
| State / Province / Region | `user.region` |
| Country | `user.country` |
| Portfolio / website | `user.portfolio_url` |
| LinkedIn | `user.linkedin_url` (or auto-detect) |
| Work authorized | `work_authorization.authorized_to_work` |
| Needs sponsorship | `work_authorization.requires_sponsorship` |
| Visa / permit type | `work_authorization.visa_status` |
| Visa expiry | `work_authorization.visa_expiry` |
| Degree | `education.degree` |
| Field of study | `education.field` |
| School | `education.school` |
| Years of experience | `education.years_of_experience` |
| Current employer | `work_experience.current_employer` |

> **Important:** Any role listed in `work_experience.unpaid_roles` is volunteer/unpaid.
> Do NOT count it as paid work experience when answering experience questions.
> Use `work_experience.paid_experience_note` for free-text clarification fields.

---

## Logging Format

Append one line to `{output_dir}/{log_file}` per application attempt:

```
[YYYY-MM-DD] [Platform] [Company] | [Job Title] | Resume: [variant_key] - [variant_label] | Posted: [post_date] | Outcome: [Applied / CAPTCHA — manual required / Skipped — already applied / Skipped — filter]
```

Example:
```
[2026-05-19] [LinkedIn] Acme Corp | Marketing Coordinator | Resume: A - Marketing / Communications | Posted: 2026-05-18 | Outcome: Applied
[2026-05-19] [Indeed] Globex Ltd | Finance Analyst | Resume: B - Finance / Accounting | Posted: 2026-05-17 | Outcome: CAPTCHA — manual required
```

---

## Safety Rules (non-negotiable)

- **Never** enter payment information, national ID numbers, or banking details.
- **Never** accept terms or agreements without showing the user first — exception: standard cookie consent banners (decline all non-essential cookies automatically).
- **Never** apply to the same company + role twice (check log before applying).
- **CAPTCHA**: attempt exactly once. If unsolved, leave tab open, log the outcome, move on. Never retry.
- If a required config value is blank, auto-detect from the session (e.g., LinkedIn URL) or skip that field.
- Stop and ask the user if an unexpected form field appears that cannot be answered from `config.yaml`.

---

## End of Run Summary

Output to chat after all platforms are processed:

```
── Daily Job Application Summary ────────────────────────
Date:            YYYY-MM-DD
Limit:           {applications_per_platform} per platform
Platforms:       [today's order]
Directions:      [today's order]

[Platform 1]:    X / {limit} applied  (Y skipped)
[Platform 2]:    X / {limit} applied  (Y skipped)
...
─────────────────────────────────────────────────────────
Total:           X applied
Log file:        {output_dir}/application_log.txt
```

List any tabs left open for manual CAPTCHA completion at the end.
