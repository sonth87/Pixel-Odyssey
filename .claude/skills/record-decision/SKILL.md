---
name: record-decision
description: Record a design or technical decision in the project's decision log and propagate it to every affected doc. Use whenever the owner confirms, changes, or rejects a rule, number, or direction, or when an open question (MỞ) gets answered.
---

# Record a decision

Docs are the source of truth; a decision that is only in chat is lost.

1. Read `docs/00-overview/04-decision-log.md`; find the next `D-xxx` number and any existing entry on the same topic.
2. Write the entry (Vietnamese) using the template in that file: date (absolute, YYYY-MM-DD), status (`CHỐT` if the owner confirmed, `ĐỀ XUẤT` if proposed), context, decision, why (including alternatives considered), consequences (which docs/code are affected).
3. If it replaces an earlier decision, mark the old entry `THAY BỞI D-xxx` — never delete it.
4. If it answers an open question `Q-xx`, remove it from the open-questions table and reference the Q id in the new entry.
5. Update every affected doc so it describes the **current** state (no "changed from..." wording inside the docs). Each fact has one source file — update that file and only link from others.
6. If code is affected, list the follow-up changes for the owner (or make them if asked) and keep the code comments history-free.
7. Tell the owner in one or two sentences what was recorded and which files changed.
