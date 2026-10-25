---
name: intent
description: Shape a problem the user want to solve, especially when the want is fuzzy: find the possible approaches, write problem and approach (chosen and considered).
disable-model-invocation: true
---

# Intent

The user has either a problem, a business requirement or some fuzzy want.
You must find out what exactly they try to solve and what stands behind it.

## Effort
Settle the effort name as `pivo:flow` skill says


## Interview
Ask user relentlessly until you have clear picture of what they try to solve -
in prose.
The user may change their mind midway, thus previous answers may drift from newer ones -
reask.

Stop when you have clear understanding of the problem the user tries to solve or the goal they want to achieve.
Do not dive into implementation details - they will be covered in further steps or sessions.

## Draft intent

Write `<effort>/intent.md`:

```markdown
# <name> — intent

## Problem
What is wrong or missing today, for whom. Who asked; the ticket, if any.

## Outcome
What is different once this ships, in the user's words.

## Open
What is still unknown, and who would know.

## Additional
Any other info you think worth noted
```


## Approval

Run the approval gate from `pivo:flow`

## Next

End with "Next - your call" from `pivo:flow`

