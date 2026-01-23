---
description: Review and improve Linear Feedback issues
---

# Process Feedback Command

Review issues in the **Feedback** project that have not yet been reviewed, and improve their titles and descriptions.

## Procedure

1. **Fetch Feedback Issues**
   - Use Linear MCP tools to list all issues in the "Feedback" project
   - Include non-archived issues only

2. **Filter to Unreviewed Issues Only**
   - **ONLY process issues where the title starts with "Feedback from"**
   - These are auto-generated titles that indicate unreviewed feedback
   - Skip all other issues - they have already been processed

3. **For Each Unreviewed Issue**

   ### Create a Descriptive Title
   - Read the user's feedback message in the description
   - Create a clear, actionable title that describes the request/issue
   - Use formats like:
     - "Add [feature] to [area]" for feature requests
     - "Fix: [problem description]" for bugs
     - "[Action verb] [what] for [context]" for improvements

   ### Enhance the Description
   Structure the description with these sections:
   ```markdown
   ## [Type: Feature Request / Improvement / Bug Report]

   [1-2 sentence summary]

   ### User Feedback
   > "[Original feedback message quoted]"

   ### Context
   [Explain the current behavior and why this matters]

   ---

   **Submitted by:** [User Name] ([email])
   **Device:** [Device info]
   **App Version:** [Version]
   **Date:** [Date]
   ```

4. **Update Each Issue**
   - Use `mcp__linear-server__update_issue` to update title and description
   - **Do NOT change the project** - keep issues in Feedback project
   - Only update `title` and `description` fields

5. **Report Summary**
   - Show table with: Issue identifier, Old title, New title

## Title Writing Guidelines

- Start with action verb (Add, Enable, Fix, Implement, Allow)
- Be specific about affected area
- Keep under 80 characters

### Good Examples
- "Add visual indicator to distinguish host accounts on connections page"
- "Fix: Followers list not loading on profile view"
- "Enable spell check and auto-correct in text input fields"

### Bad Examples
- "Feedback from User" (too generic)
- "Fix bug" (not specific)
