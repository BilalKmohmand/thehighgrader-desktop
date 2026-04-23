# End-to-End Assignment Workflow

## What & Why
Close the loop on the teacher→student assignment lifecycle. Currently teachers can generate assignments (rubrics) but students never see them and can't submit answers. This task wires up the full flow: teacher publishes → students submit → AI evaluates → teacher reviews → teacher pushes results → student sees score and feedback.

## Done looks like
- Teacher can click "Publish to Class" on any assignment; published assignments are marked with a badge
- Students see a new "Assignments" tab on their dashboard listing all published assignments for their class(es)
- Students can open an assignment, read the instructions, write/paste their answer, and submit
- On student submission, AI automatically evaluates the work against the rubric criteria and saves the result
- Teacher sees a "Submissions" panel per assignment listing each student's submission with the AI-generated score, criteria breakdown, strengths and weaknesses
- Teacher has "Push to Student" button (approves and publishes the result) and "Re-evaluate" button (re-runs AI on that submission)
- After teacher pushes, the student's assignment card shows their score, grade, and full feedback breakdown
- Student assignments that are submitted but not yet pushed show a "Awaiting teacher review" status

## Out of scope
- File upload for student submissions (text answer only for now)
- Notifications / email alerts when assignments are published or evaluated
- Student ability to re-submit after teacher pushes

## Tasks

1. **Schema additions** — Add `status` column (`draft | published`) to `rubrics` table and `publishedAt` timestamp. Add `studentId` foreign key to `rubricSubmissions` so a student can own a submission. Extend `rubricSubmissions.status` to cover the full lifecycle: `submitted | ai_evaluated | pushed`. Add `pushedAt` timestamp to `rubricEvaluations`. Apply schema changes via `npm run db:push --force`. Add corresponding storage interface methods and update types in shared/schema.ts.

2. **Teacher backend routes** — Add `PATCH /api/rubrics/:id/publish` to publish an assignment. Add `GET /api/teacher/rubric-submissions` (filtered by rubricId) so teacher can see all student submissions for an assignment with their evaluation. Add `PATCH /api/teacher/rubric-submissions/:id/push` to mark a submission as pushed (sets pushedAt and status=pushed). Add `POST /api/teacher/rubric-submissions/:id/reevaluate` to re-run AI evaluation and overwrite the existing rubricEvaluation for that submission.

3. **Student backend routes** — Add `GET /api/student/assignments` to return published rubrics for all classes the student has joined, each with the student's own submission status if any. Add `POST /api/student/assignments/:rubricId/submit` to create a rubricSubmission (with studentId from session), then immediately trigger AI evaluation using the rubric criteria (same logic as existing `/api/rubric-evaluate/:submissionId` route). Add `GET /api/student/assignments/:rubricId/result` to return the pushed evaluation for a submitted assignment.

4. **Teacher assignments UI updates** — In `assignments-content.tsx`, add a "Publish" toggle/button for each assignment that calls the publish route and shows a "Published" badge on published ones. Add a collapsible "Submissions" section below each published assignment that lists student name, submission date, AI score, and per-criteria breakdown. Include "Push to Student" and "Re-evaluate" action buttons on each submission row. Show a loading state while re-evaluation is running.

5. **Student assignments page** — Create a new `student-assignments-content.tsx` component with two tabs: "To Do" (published assignments the student hasn't submitted yet, each with an expandable form showing instructions and a textarea for their answer + Submit button) and "Submitted" (submitted assignments showing status — pending review with a clock icon, or pushed with score badge, grade, and full criteria feedback breakdown). Register this as an "Assignments" tab in the student dashboard navigation.

## Relevant files
- `shared/schema.ts`
- `server/storage.ts`
- `server/routes.ts:3090-3620`
- `client/src/components/dashboard/assignments-content.tsx`
- `client/src/App.tsx`
- `client/src/components/dashboard/class-selector.tsx`
