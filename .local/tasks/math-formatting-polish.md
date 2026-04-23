# Math Output Formatting Polish

## What & Why
The AI Tutor's math responses currently look rough compared to polished tools like Solvely. The root cause is a hand-rolled custom markdown+LaTeX parser that misses many edge cases: inconsistent spacing, no table support, poor step-by-step visual hierarchy, and no nested list support. Replacing it with the industry-standard `react-markdown` + `remark-math` + `rehype-katex` stack, plus updated CSS and AI prompt guidance, will produce smooth, visually clear responses.

## Done looks like
- Math equations (inline `$x^2$` and display `$$...$$`) render cleanly and consistently using KaTeX.
- Step-by-step solutions are visually distinct — numbered steps with clear separation, styled headings, and well-spaced equations.
- Bold, italic, code, lists, tables, and blockquotes all render correctly in AI responses.
- The output matches the clean, readable style of Solvely: proper line height, generous spacing between steps, equations centered with surrounding whitespace.
- Dark mode is fully supported with appropriate text/background contrast.
- No regression in existing features (the old `SolutionStep` component still works if used).

## Out of scope
- Voice or speech rendering
- Replacing the quiz or essay output rendering (those don't use `renderMathText`)
- Custom math editor or input

## Tasks
1. **Install dependencies** — Install `react-markdown`, `remark-math`, `rehype-katex`, and `rehype-raw` packages.

2. **Rewrite `math-display.tsx`** — Replace `processTextWithMath` and the custom `renderLine`/`applyInline` parser with a `ReactMarkdown` component configured with `remark-math` and `rehype-katex`. Export a new `renderMathText(text)` that returns a `<ReactMarkdown>` element with polished component overrides (heading sizes, list spacing, code blocks, tables). Keep the existing `MathDisplay` and `SolutionStep` exports intact.

3. **Polish the CSS and component styles** — In the solver chat bubble renderer, apply Solvely-inspired typography: clear step cards for numbered headings, display-math blocks with generous vertical margin, consistent `line-height`, and a subtle separator between user/AI turns. Add a `.math-content` CSS class with these rules to `index.css`.

4. **Update AI system prompt** — In the solve-text-stream backend handler, update the system message to instruct the AI to structure math responses with a brief intro sentence, numbered steps using `##` headers, and a final "Answer" summary line. This ensures the improved renderer always has well-structured input to display.

## Relevant files
- `client/src/components/math-display.tsx`
- `client/src/components/dashboard/solver-content.tsx`
- `client/src/index.css`
- `server/routes.ts`
