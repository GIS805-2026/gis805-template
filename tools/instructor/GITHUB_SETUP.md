# GitHub Push + Classroom Setup Checklist

## Step 1: Push template repo to GitHub

Run from the template repo root:

```bash
git init
git add -A
git commit -m "GIS805 template repo v3.0 -- NexaMart boardroom simulation"
gh repo create GIS805-2026/gis805-template --private --source=. --push
```

Then mark it as a template repo:

```bash
gh repo edit GIS805-2026/gis805-template --template
```

Verify on GitHub: Settings > General > "Template repository" should be checked.

## Step 2: Create GitHub Classroom

1. Go to https://classroom.github.com/
2. Click "New classroom"
3. Select org: **GIS805-2026**
4. Name: **GIS805-2026-E2026** (or your semester code)

## Step 3: Create the assignment

1. In your classroom, click "New assignment"
2. Configure:
   - **Title**: `gis805-2026`
   - **Type**: Individual
   - **Visibility**: Private
   - **Template repository**: `GIS805-2026/gis805-template`
   - **Grant admin access**: No (keep students as collaborators)
   - **Enable feedback pull requests**: Yes
   - **Deadline**: Last session date (optional)
3. Copy the **invitation link**

## Step 4: Distribute to students

Share the invitation link via Moodle. Each student who accepts gets:
- A private repo: `GIS805-2026/gis805-2026-<username>`
- Full template contents (Makefile, devcontainer, SQL templates, etc.)
- You as an automatic collaborator
- A unique dataset seed derived automatically from their git username (no tokens needed)

## Step 5: Populate the roster

```bash
cd tools/instructor
python roster.py init
python roster.py add "Jean Tremblay" jtremblay 12345678
python roster.py add "Marie Lavoie" mlavoie 23456789
# ... repeat for each student
python roster.py list
```

Seeds are computed automatically from git usernames via `MD5(username)[:8]`.
No salt or token distribution required.

## Post-setup verification

After students have accepted and generated data:

```bash
python tools/instructor/batch_pull.py --org GIS805-2026 --dest ./student-repos
python tools/instructor/batch_validate.py --repos ./student-repos
```

This produces `grading_summary.csv` with pass/fail for each student's setup.
