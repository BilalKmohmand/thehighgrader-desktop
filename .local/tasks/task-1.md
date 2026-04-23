---
title: Teacher account setup & class management
---
# Teacher Account Setup

## What & Why
Complete the teacher account experience so teachers have a proper identity and classroom infrastructure on the platform. Currently, teachers land on the same shell as students with no class context. This task adds a teacher profile, class creation and management, a class-code join flow for students, and a teacher home overview screen.

## Done looks like
- When a teacher logs in for the first time, they see a setup prompt to enter their school name, subjects they teach, and grade levels.
- Teachers can create one or more named classes, each with an auto-generated 6-character class code.
- Students can enter a class code from their dashboard to join the class; the teacher then sees those students in their roster.
- The teacher dashboard has a home overview screen showing each class with student count, average grade, and a link to the grade book.
- The sidebar shows the teacher's name, school, and role badge.
- All teacher tools (AI Evaluator, Assignments, Class Grader, Grade Book, Report Cards) are scoped to a selected class.

## Out of scope
- Payment or subscription tiers for teachers
- Parent/guardian portal
- Push notifications or email alerts
- Student-facing grade view (students see their own grades separately)

## Tasks
1. **Schema — teacher profile, classes, and class memberships** — Add `teacherProfiles` table (school, subjects, gradeLevel), `classes` table (teacherId, name, subject, gradeLevel, classCode), and `classMemberships` table (classId, studentId, joinedAt). Write insert schemas and types.

2. **Backend routes** — Add CRUD endpoints for teacher profiles (`GET/PATCH /api/teacher/profile`), classes (`GET/POST/DELETE /api/teacher/classes`), class memberships (`POST /api/classes/join` for students, `GET /api/teacher/classes/:id/students`). Use `requireTeacher` middleware where appropriate.

3. **Teacher profile onboarding modal** — When a teacher logs in and has no profile yet, show a one-time setup modal asking for school name, subjects, and grade level. Save via the profile endpoint.

4. **Class management page** — Add a new "My Classes" section in the teacher sidebar. Show a list of the teacher's classes with name, class code, student count, and subject. Allow creating new classes (name, subject, grade level) and deleting existing ones. Display the class code prominently with a copy button.

5. **Student join flow** — Add a "Join a Class" option in the student sidebar or settings. Student enters the 6-character code; on success, show a confirmation and the class name. Student is added to the class roster.

6. **Teacher home overview screen** — Replace the blank teacher landing with a dashboard grid showing each class as a card (student count, subject, average grade from grade book, quick links). Add teacher name, school and a "Teacher" role badge to the sidebar footer.

## Relevant files
- `shared/schema.ts`
- `server/storage.ts`
- `server/routes.ts`
- `client/src/pages/dashboard.tsx`
- `client/src/components/dashboard/gradebook-content.tsx`
- `client/src/components/dashboard/assignments-content.tsx`
- `client/src/components/dashboard/class-grader-content.tsx`