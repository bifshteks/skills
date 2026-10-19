---
name: mr-description
description: Use whenever writing or rewriting an MR description in any repository.
---

# MR description

The reader is a reviewer juggling several contexts, opening this MR between two
others. The description is a **briefing**: it re-orients them in seconds, then
points their attention. The diff already says which files changed; the
description says what the reviewer cannot read off the diff.

Always in Russian. Blocks in this order, each under a `####` heading:

| Block | Present | Cap |
|---|---|---|
| `#### Контекст` | always | 1–2 sentences |
| `#### Что меняется` | always | ≤5 bullets, one sentence each |
| `#### Откат` | always | 1 sentence |
| `#### Смотреть внимательнее` | when something stands out | ≤3 bullets |
| `#### Зависит от` | when something must land first | one bullet per dependency |

An omitted block means "nothing here", so leave it out instead of writing "нет".

## The blocks

**Контекст** — which task this is, in the words the reviewer last heard it in.
Enough for "ah, *that* one", nothing more: the problem, never the solution.

**Что меняется** — observable **behaviour**: what the service, API or user now
does differently. "Создание файла в несуществующей папке больше не кидает
панику — создаём папку, затем файл." A change with no behavioural effect is named
by what it is: "Рефакторинг пакета `worker`, поведение не меняется." Needing a
sixth bullet means the MR carries more than one change: tell the author it may
want splitting, and keep the five.

**Откат** — how to undo it if prod breaks: redeploy the previous tag; switch off
flag `X`; or a **one-way door** — a migration, schema or storage-layout change the previous
version cannot read — named as such.

**Смотреть внимательнее** — the riskiest spots, each named so the reviewer can
find it in the diff: "новая дедупликация сигналов", "новый `if` в блокировке
файла на уровне ОС". Concurrency, data loss, contracts and security outrank
style.

**Зависит от** — MRs, tasks or features that must be merged or done first, as
links.

## Example

```markdown
#### Контекст
CLI падала с паникой, если в конфиге указан некорректный путь до файла (QWE-123).

#### Что меняется
- Валидируем существование файла в начале
- в случае отсутствия - предлагаем создать файл

#### Откат
Деплой предыдущего тега, миграций нет.

#### Смотреть внимательнее
- Проверка существования файла

#### Зависит от
- some-repository!281
```

Done when every always-block is present, every cap holds, and each sentence
tells the reviewer something the diff does not.
