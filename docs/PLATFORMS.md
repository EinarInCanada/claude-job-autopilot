# Platform Notes

Per-platform behaviour and quirks observed during testing.

---

## LinkedIn

**Apply method:** LinkedIn Easy Apply (preferred) or external redirect.

**Flow:**
1. Search with keywords + location filter set to your configured city.
2. Filter by "Easy Apply" when possible — it keeps applications in one tab.
3. The Easy Apply drawer asks for: contact info, resume upload, screening questions, and sometimes a cover letter text box.
4. For cover letter text boxes: paste the first 3 paragraphs from your `.docx` cover letter.
5. Some multi-step Easy Apply flows have 3–5 pages. Click through each page.

**Screening questions common on LinkedIn:**
- "Are you legally authorized to work in [Country]?" → `work_authorization.authorized_to_work`
- "Will you now or in the future require sponsorship?" → `work_authorization.requires_sponsorship`
- "How many years of [technology] experience do you have?" → Answer based on actual experience; do not over-inflate.
- "What is your expected salary?" → Leave blank or enter "Open to discussion" if the field is optional.

**CAPTCHA:** LinkedIn rarely shows CAPTCHAs during Easy Apply. If one appears, attempt once. If it fails, leave the tab open.

**Known quirks:**
- LinkedIn sometimes asks you to confirm your phone number via SMS. If this happens, leave the tab open for the user.
- Some job posts redirect to an external ATS instead of using Easy Apply — follow the External ATS flow in that case.

---

## Indeed

**Apply method:** Indeed Apply (in-app) or external redirect.

**Flow:**
1. Search with keywords + location. Sort by "Date posted" → "Last 7 days".
2. Click "Apply now". If it says "Indeed Apply", continue in-app. If it redirects to a company site, follow the External ATS flow.
3. Indeed Apply asks for: resume upload (or use Indeed's stored resume — do not use this; always upload the tailored PDF), cover letter (optional upload or text), and screening questions.

**Screening questions common on Indeed:**
- Background check consent → agree.
- Work authorization → `work_authorization.authorized_to_work`.
- Driver's licence required? → Answer based on job requirements.

**CAPTCHA:** Indeed occasionally shows image-based CAPTCHAs. Attempt once; leave tab open if failed.

**Known quirks:**
- Indeed sometimes pre-fills your profile from a stored "Indeed Resume". Always verify the uploaded file is your tailored PDF, not the Indeed profile.
- "Quick Apply" (one-click) populates from your Indeed profile — skip these; they don't let you attach a tailored resume.

---

## Glassdoor

**Apply method:** Usually redirects to the company's own careers page (external ATS).

**Flow:**
1. Search with keywords + location. Filter by "Date posted: Last 7 days".
2. Click "Apply" — most Glassdoor listings redirect to an external ATS.
3. Follow the External ATS flow (below).
4. A small number of jobs have a Glassdoor Easy Apply option — treat these the same as LinkedIn Easy Apply.

**Known quirks:**
- Glassdoor's search may show results from outside the configured location — verify location on each listing before applying.
- Company size information is usually visible on Glassdoor company pages; use it to enforce the small/mid-size filter.

---

## Monster

**Apply method:** Mix of Monster Apply and external redirects.

**Flow:**
1. Search with keywords + location. Sort by "Most recent".
2. Click "Apply". Monster Apply stays in-app; external jobs redirect.
3. Monster Apply asks for resume (upload tailored PDF), contact info, and optional cover letter.

**Known quirks:**
- Monster's Canadian site (monster.ca) has fewer listings than indeed.ca — expect it to exhaust directions faster. Log how many were applied and move on.
- Monster sometimes shows US jobs even with a Canadian location filter — check the "Location" field on each listing.

---

## External ATS (Greenhouse, Lever, Workday, iCIMS, BambooHR, etc.)

**Account creation:**
- Check `application_log.txt` first — if you've applied to this company before, the account is already created.
- Prefer Google Sign-In if available (faster, no new password required).
- If creating a new account: use `user.email` and generate the password from `ats_password_pattern` by substituting `{CompanyName}`.
- Log the new account in `application_log.txt` so future runs can reuse it.

**Form filling:**
- Use only values from `config.yaml`. Never guess or invent answers.
- Legal name fields → `user.legal_first_name` + `user.legal_last_name`.
- "Preferred name" or "Display name" fields → `user.display_first_name`.
- Work authorization dropdowns: choose the option that matches `work_authorization.status`.
- Demographic/EEO questions: these are optional — select "Prefer not to say" unless the user has specified preferences.

**Resume upload:**
- Always upload the tailored PDF for the selected variant. Do not use an ATS's "parse your LinkedIn" or "auto-fill from resume" features.

**Cover letter:**
- If a file upload is offered, upload the `.docx`.
- If only a text box is provided, paste the 3 body paragraphs as plain text.
- If cover letter is optional and no field is visible, skip it.

**CAPTCHA:**
- Attempt exactly once.
- If the CAPTCHA is not solved on the first try, leave the browser tab open and log `[CAPTCHA — manual required]`.
- Never retry or reload the page — this may invalidate the form state.
