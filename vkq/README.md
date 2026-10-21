# vkq: Vikunja quick capture

Hotkey -> rofi prompt -> one line -> task in Vikunja, dunst notification.

Python 3.11+, stdlib only (`tomllib`, `urllib`). Needs `rofi`, `xclip`, `notify-send`.
Tested against Vikunja **v2.7.0** (`/api/v1`).

## Setup

```sh
ln -sf ~/.dotfiles/bin/vkq ~/.local/bin/vkq            # install.sh does this
mkdir -p ~/.config/vkq
cp ~/.dotfiles/vkq/config.example.toml ~/.config/vkq/config.toml   # or symlink; no secrets in it
install -m 600 /dev/null ~/.config/vkq/token && $EDITOR ~/.config/vkq/token
vkq parse 'wrk hello #test @tomorrow'                   # dry run, no network
vkq add 'ibx hello'                                     # real task in the project with identifier IBX
```

### Project codes

Every line starts with a project code: the project's **Identifier** in Vikunja (project settings
-> Edit -> Identifier, e.g. `WRK`, `PRS`, `IBX`). Case does not matter (`wrk` works), a trailing
colon is optional (`WRK: fix`). The code is mandatory so nothing lands in the wrong project by
accident; projects without an identifier cannot be used. There is no mapping in the config.

### API token

Vikunja -> Settings -> API Tokens -> Create. Token lookup order:

1. env `VKQ_TOKEN`
2. `token_cmd` in config, e.g. `token_cmd = "pass show vikunja/token"`
3. `token_file` (default `~/.config/vkq/token`; refused unless mode is 0600)

Default is the token file: it never prompts, so the hotkey stays instant.

Least-privilege scopes (from the instance's `/api/v1/routes`):

| group | permissions |
|---|---|
| projects | `read_all` |
| labels | `read_all`, `create` |
| tasks | `create` |
| tasks_labels | `update_bulk` |

Note: verified only with a full-access token. Create a token with just these and run `vkq add`
once to confirm; if something returns 403 the notification says so.

## Notation

```
wrk create url inventory in conflu @today #workproject https://example.com/ticket
```

| Part | Meaning |
|---|---|
| `wrk` first word | **mandatory** project code (see above) |
| `#label` | label, case-insensitive match, created if missing (`create_labels`). Repeatable. One word; use `-` (`#work-project`) |
| `@date` | due date, see below |
| `r@date` | reminder (same date syntax). Reminder only, without a due date, is fine |
| `!1`..`!5` | priority |
| `desc: text` | everything after goes to description (not parsed) |
| `+u` | adds the (first) URL from the clipboard as a link |
| `+us` | like `+u` but from the primary selection (highlighted text, middle-click buffer). Use it when the clipboard holds the pasted task line: select the URL, change `+u` to `+us` |
| `+c` | puts the clipboard text into the description (wins over `+u` and `+us`) |
| `+o` | `xdg-open` the created task in the browser |
| `-n` | no success notification (warnings and errors still show) |
| `\#123` `\@bob` `\!1` `\+u` `\-n` | backslash keeps the token literal in the title |
| `https://...` | removed from title, added to description as a link (anywhere in line; `#`/`@` inside are safe) |
| `wrk "text"` | text in double quotes after the code: no parsing at all, literal title |

Everything left over is the title. Order and extra spaces do not matter. Vikunja has no URL
field on tasks, so links live in the (HTML) description, followed by the original input line
(`include_raw`).

### Dates (`@...`)

| Spec | Result |
|---|---|
| `@today` `@tomorrow` | that day at `default_time` (12:00) |
| `@mon`..`@sun`, `@friday` | next occurrence, strictly after today |
| `@+3d` `@+2w` | N days/weeks from now at `default_time` |
| `@+3h` `@+30min` | exactly now + N |
| `@2026-11-02` `@2026-11-02T08:30` | ISO |
| `@5.11` `@5.11.2026` | D.M[.Y]; without year, next occurrence |
| `@17:00` `@5pm` `@eob` | clock time today, tomorrow if already passed. `eob` etc. from `[times]` |
| `@tomorrow 9:00`, `@fri 5pm` | a clock token right after a day spec sets its time |

Past dates are accepted with a warning.

## Listing (`ls`)

Type `ls <filter>` in the rofi prompt (or `vkq ls <filter>`) to get a rofi list of open tasks,
soonest due first, tasks without a due date last. Enter opens the selected task in the browser;
Escape cancels. The filter uses the capture notation, every part is optional and they combine
with AND:

| Filter part | Matches |
|---|---|
| `wrk` | **mandatory** project code, first word, same as in capture |
| `#label` | has that label (repeat for "has all"). Unknown label: error |
| `@date` | due up to and including that moment, overdue included. Date-only (`@today`, `@fri`) means until the end of that day; `@+2h` / `@17:00` mean until that time |
| `!3` | priority 3 or higher |
| other words | text search in title/description |

```
ls wrk                      all open Work tasks
ls wrk #example @+2h !3     Work, labelled example, due within 2 hours (or overdue), priority >= 3
ls prs @today               Personal tasks due today or overdue
```

Bad filters (no or unknown code, unknown label) follow the same error path as capture: critical
notification and the `ls ...` line is copied to the clipboard.

Needs `tasks: read_all`, same as undo.

## Undo

Type `undo` in rofi (or run `vkq undo`). It takes the newest task in Vikunja, reads the original
input line from the `vkq: ...` footer of its description, copies that line to the clipboard,
then deletes the task. Paste into rofi to redo with a fix.

Guards, because it deletes: it refuses (task kept, critical notification) if the newest task has
no stored vkq line (made in the web UI, or `include_raw = false`) or is older than `undo_window`
(default 3600 s). Every undo removes one task, so repeating it walks back through older vkq tasks
until the window runs out. To create a task literally titled "undo", write `"undo"` with quotes.
Needs the extra scopes `tasks: read_all, delete`. (Once Vikunja has custom fields
[#120](https://github.com/go-vikunja/vikunja/issues/120), the line can move there from the description.)

## Failure behaviour

Whenever there is something to fix, the **raw input line is copied to the clipboard**: rerun the
hotkey, paste, fix.

- **Nothing created** (critical notification): API unreachable, timeout, 5xx, bad token, empty
  title, missing or unknown project code (the notification lists the known codes), and
  typo-prone input: unparseable `@word` (write `\@word` for a literal), two `@` dates
  or two `r@` dates (usually a forgotten `r`), a stray `r @17:00` (extra space), `+u` when the
  clipboard has no URL (the notification says whether it was empty or had other text), `+c` with
  empty clipboard.
- **Created with a warning** (and line copied): label missing with `create_labels = false`,
  labels could not be applied. Retrying creates a
  duplicate, so fix the existing task or delete it after retrying.

(Phase 2: on-disk queue + `vkq flush`.)

## Cache

Projects and labels cached in `~/.cache/vkq/cache.json` for `cache_ttl` (600 s), keyed by
`base_url`. A miss triggers one refresh before anything is created, so a label added in the web UI
is never duplicated. `vkq --refresh add ...` or `vkq refresh` force it.

## Test instance

```sh
VKQ_BASE_URL=http://localhost:3456 VKQ_TOKEN=tk_... vkq add 'x'
VKQ_CONFIG=/tmp/other.toml vkq ...
python3 -m unittest discover -s ~/.dotfiles/vkq      # parser + mocked-server API tests
```

## awesome WM

`awesome/rc.lua`, next to the other rofi bindings (`modkey+a` etc.; `modkey+i` for "inbox", already added):

```lua
awful.key({ modkey }, "i", function () awful.spawn("vkq") end),
```

rofi: the script passes `-theme-str 'listview { enabled: false; }'` so only the input line shows.
Extra args or a custom theme: `[rofi] args = ["-theme", "~/.config/rofi/quick.rasi"]`.

## Layout / future

`parse()` is pure (line + config -> `Parsed`) and `create_task()` takes a parsed capture, so a
Slack reaction handler can reuse both unchanged.
