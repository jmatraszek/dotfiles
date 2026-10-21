"""Run: python3 -m unittest discover -s ~/.dotfiles/vkq"""
import importlib.machinery
import importlib.util
import json
import tempfile
import threading
import urllib.parse
import unittest
from datetime import datetime
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path

_path = str(Path(__file__).resolve().parent.parent / "bin" / "vkq")
_spec = importlib.util.spec_from_loader("vkq", importlib.machinery.SourceFileLoader("vkq", _path))
vkq = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(vkq)

NOW = datetime(2026, 10, 21, 10, 0).astimezone()  # a Wednesday
CFG = {**vkq.DEFAULTS, "base_url": "http://x", "times": {"eob": "17:00"}}


class ParseTests(unittest.TestCase):
    def p(self, line, **kw):
        """Parse with the mandatory project code prepended (unless bare=True)."""
        bare = kw.pop("bare", False)
        return vkq.parse(line if bare else "WRK " + line, CFG, now=NOW, **kw)

    def test_table(self):
        # line, title, code, labels, priority
        rows = [
            ("WRK buy milk", "buy milk", "WRK", [], 0),
            ("wrk buy milk", "buy milk", "WRK", [], 0),               # upper-cased
            ("Prs: fix thing", "fix thing", "PRS", [], 0),
            ("IBX:fix thing", "fix thing", "IBX", [], 0),
            ("wrk fix #a thing #b", "fix thing", "WRK", ["a", "b"], 0),
            ("wrk fix #a #A", "fix", "WRK", ["a"], 0),                # dedupe, case-insens
            ("  wrk   spaced   out   #x  ", "spaced out", "WRK", ["x"], 0),
            ("wrk #x leading label", "leading label", "WRK", ["x"], 0),
            ("wrk thing !4", "thing", "WRK", [], 4),
            ("wrk wow! !9", "wow! !9", "WRK", [], 0),
            ("wrk zażółć gęślą #pl", "zażółć gęślą", "WRK", ["pl"], 0),
            ("wrk", "", "WRK", [], 0),                                # empty title
            ("wrk #only", "", "WRK", ["only"], 0),
        ]
        for line, title, code, labels, prio in rows:
            with self.subTest(line=line):
                r = self.p(line, bare=True)
                self.assertEqual((r.title, r.code, r.labels, r.priority, r.errors),
                                 (title, code, labels, prio, []))

    def test_project_code_is_mandatory(self):
        for line in ("", "#only @fri", "!3 first", "@tomorrow thing", "desc: no code", "-- x"):
            with self.subTest(line=line):
                r = self.p(line, bare=True)
                self.assertEqual(r.code, "" if not line.startswith("desc") else "DESC")
                if r.code == "":
                    self.assertTrue(any("project code required" in e for e in r.errors))

    def test_quoted_title_after_code(self):
        r = self.p('"keep #this @today !3"')
        self.assertEqual((r.code, r.title, r.labels, r.due, r.priority),
                         ("WRK", "keep #this @today !3", [], None, 0))

    def test_urls(self):
        r = self.p("look https://ex.com/a#frag@x?q=1 #lbl")
        self.assertEqual(r.urls, ["https://ex.com/a#frag@x?q=1"])
        self.assertEqual((r.title, r.labels, r.due), ("look", ["lbl"], None))

    def test_url_from_clipboard(self):
        r = self.p("read this +u", clipboard=" https://c.example/x \n")
        self.assertEqual((r.title, r.urls, r.errors), ("read this", ["https://c.example/x"], []))
        r = self.p("read this +u", clipboard="see https://c.example/y, ok")
        self.assertEqual(r.urls, ["https://c.example/y"])
        for clip in ("not a url", ""):
            r = self.p("read this +u", clipboard=clip)
            self.assertEqual(r.urls, [])
            self.assertEqual(len(r.errors), 1)
        self.assertEqual(len(self.p("x +u", clipboard="")  .errors), 1)

    def test_url_from_selection(self):
        r = self.p("x +us", clipboard="x +u", selection="https://s.example/a")
        self.assertEqual((r.urls, r.errors), (["https://s.example/a"], []))
        r = self.p("x +us", selection="just text")
        self.assertEqual((r.urls, len(r.errors)), ([], 1))
        r = self.p("x +u +us", clipboard="https://c.example", selection="https://s.example")
        self.assertEqual(r.urls, ["https://c.example", "https://s.example"])
        r = self.p("x +us +c", clipboard="body", selection="https://s.example")
        self.assertEqual((r.urls, r.description), ([], "body"))
        self.assertIn("+us", self.p("x +u", clipboard="line").errors[0])

    def test_clipboard_content_wins(self):
        r = self.p("note +u +c desc: mine", clipboard="line1\nhttps://c.example/z")
        self.assertEqual(r.urls, [])
        self.assertEqual(r.description, "mine\nline1\nhttps://c.example/z")
        self.assertIn("mine<br>line1<br>", vkq.build_description(r))
        self.assertEqual(len(self.p("x +c", clipboard=" ").errors), 1)

    def test_flags(self):
        r = self.p("x +o -n")
        self.assertEqual((r.title, r.open, r.quiet), ("x", True, True))
        r = self.p("x")
        self.assertEqual((r.open, r.quiet), (False, False))

    def test_escape(self):
        r = self.p(r"fix \#123 and \@bob \!1 \+u \-n #real")
        self.assertEqual((r.title, r.labels, r.priority, r.errors, r.open, r.quiet),
                         ("fix #123 and @bob !1 +u -n", ["real"], 0, [], False, False))

    def test_reminder(self):
        r = self.p("call r@17:00")
        self.assertEqual((r.title, r.due, r.reminder.strftime("%H:%M")), ("call", None, "17:00"))
        r = self.p("call @fri r@thu 9:00")
        self.assertEqual((r.due.day, r.reminder.strftime("%d %H:%M"), r.errors), (23, "22 09:00", []))
        r = self.p("R@tomorrow x")
        self.assertEqual(r.reminder.day, 22)

    def test_date_typos_are_errors(self):
        for line in ("x @fri @17:00",          # forgot the r
                     "x r@fri r@17:00",
                     "x r @17:00",              # stray space
                     "x r@ 17:00", "x @",
                     "x @tomorow"):
            with self.subTest(line=line):
                self.assertTrue(self.p(line).errors)

    def test_desc_and_quote(self):
        r = self.p("title #a desc: more #notlabel @today")
        self.assertEqual((r.title, r.description, r.labels, r.due), ("title", "more #notlabel @today", ["a"], None))

    def test_dates(self):
        rows = [
            ("@today", "2026-10-21 12:00"),
            ("@tomorrow", "2026-10-22 12:00"),
            ("@fri", "2026-10-23 12:00"),
            ("@wed", "2026-10-28 12:00"),                # same weekday -> next week
            ("@monday", "2026-10-26 12:00"),
            ("@+3d", "2026-10-24 12:00"),
            ("@+1w", "2026-10-28 12:00"),
            ("@+3h", "2026-10-21 13:00"),
            ("@+30min", "2026-10-21 10:30"),
            ("@2026-12-24", "2026-12-24 12:00"),
            ("@2026-12-24T08:30", "2026-12-24 08:30"),
            ("@17:00", "2026-10-21 17:00"),
            ("@9:00", "2026-10-22 09:00"),                # already past -> tomorrow
            ("@eob", "2026-10-21 17:00"),
            ("@tomorrow 9:00", "2026-10-22 09:00"),
            ("@fri 5pm", "2026-10-23 17:00"),
            ("@5.11", "2026-11-05 12:00"),
            ("@1.10", "2027-10-01 12:00"),
        ]
        for spec, want in rows:
            with self.subTest(spec=spec):
                r = self.p(f"t {spec}")
                self.assertEqual(r.title, "t")
                self.assertEqual(r.due.strftime("%Y-%m-%d %H:%M"), want)

    def test_clock_not_consumed_without_date(self):
        r = self.p("meet @tomorrow at 9:00")
        self.assertEqual(r.title, "meet at 9:00")

    def test_past_and_bad_dates(self):
        r = self.p("t @2020-01-01")
        self.assertTrue(r.due.year == 2020 and r.warnings)
        r = self.p("ping @bob about it")
        self.assertEqual((r.due, len(r.errors)), (None, 1))
        self.assertEqual(self.p(r"ping \@bob").title, "ping @bob")
        r = self.p("t @2026-13-45")
        self.assertEqual((r.due, len(r.errors)), (None, 1))

    def test_description_html(self):
        r = self.p("a <b> https://e.com/?a=1&b=2 desc: x & y")
        d = vkq.build_description(r)
        self.assertIn("<p>x &amp; y</p>", d)
        self.assertIn('href="https://e.com/?a=1&amp;b=2"', d)
        self.assertIn("vkq: WRK a &lt;b&gt;", d)
        self.assertEqual(vkq.build_description(self.p("plain")), "<p><small>vkq: WRK plain</small></p>")
        self.assertEqual(vkq.build_description(self.p("plain"), include_raw=False), "")

    def test_raw_roundtrip(self):
        for line in ("wrk: a <b> & \"q\" #x @fri https://e.com/?a=1&b=2 desc: l1",
                     "wrk plain", "prs x +c </small> y"):
            with self.subTest(line=line):
                d = vkq.build_description(self.p(line, bare=True, clipboard="clip <i>"))
                self.assertEqual(vkq.extract_raw(d), line)
        self.assertIsNone(vkq.extract_raw("<p>made in the web ui</p>"))
        self.assertIsNone(vkq.extract_raw(None))


class FakeVikunja(BaseHTTPRequestHandler):
    state = None

    def log_message(self, *a):
        pass

    def _reply(self, code, obj):
        body = json.dumps(obj).encode()
        self.send_response(code)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _handle(self, method):
        st = self.state
        n = int(self.headers.get("Content-Length") or 0)
        body = json.loads(self.rfile.read(n)) if n else None
        st["calls"].append((method, self.path.split("?")[0], body))
        st.setdefault("queries", []).append(self.path.partition("?")[2])
        if self.headers.get("Authorization") != "Bearer good":
            return self._reply(401, {"message": "invalid token"})
        if st.get("fail"):
            return self._reply(st["fail"], {"message": "boom"})
        path = self.path.split("?")[0]
        if method == "GET" and path == "/api/v1/tasks":
            return self._reply(200, st.get("tasks", []))
        if method == "DELETE" and path.startswith("/api/v1/tasks/"):
            return self._reply(200, {"message": "deleted"})
        if method == "GET" and path == "/api/v1/projects":
            return self._reply(200, [{"id": 1, "title": "Inbox", "identifier": "ibx"},
                                     {"id": 2, "title": "Work", "identifier": "WRK"},
                                     {"id": 3, "title": "NoCode", "identifier": ""}])
        if method == "GET" and path == "/api/v1/labels":
            return self._reply(200, st["labels"])
        if method == "PUT" and path == "/api/v1/labels":
            lab = {"id": 100 + len(st["labels"]), "title": body["title"]}
            st["labels"].append(lab)
            return self._reply(201, lab)
        if method == "PUT" and path.startswith("/api/v1/projects/") and path.endswith("/tasks"):
            return self._reply(201, {"id": 42, **body})
        if method == "POST" and path == "/api/v1/tasks/42/labels/bulk":
            return self._reply(200, body)
        self._reply(404, {"message": "nope"})

    do_GET = lambda s: s._handle("GET")
    do_PUT = lambda s: s._handle("PUT")
    do_POST = lambda s: s._handle("POST")
    do_DELETE = lambda s: s._handle("DELETE")


class ApiTests(unittest.TestCase):
    def setUp(self):
        self.state = {"calls": [], "labels": [{"id": 7, "title": "Existing"}]}
        handler = type("H", (FakeVikunja,), {"state": self.state})
        self.srv = HTTPServer(("127.0.0.1", 0), handler)
        threading.Thread(target=self.srv.serve_forever, daemon=True).start()
        self.base = f"http://127.0.0.1:{self.srv.server_port}"
        self.cfg = {**CFG, "base_url": self.base}
        self.api = vkq.Api(self.base, "good", 2)
        self.tmp = tempfile.TemporaryDirectory()
        self.cache = vkq.Cache(self.api, self.cfg, Path(self.tmp.name) / "c.json")

    def tearDown(self):
        self.srv.shutdown()
        self.srv.server_close()
        self.tmp.cleanup()

    def test_create_full(self):
        p = vkq.parse("wrk ship it #existing #newone !2 @tomorrow r@+2h https://e.com", self.cfg, now=NOW)
        task, proj = vkq.create_task(self.api, self.cache, self.cfg, p)
        self.assertEqual((task["id"], proj), (42, "Work"))
        calls = {(m, u): b for m, u, b in self.state["calls"]}
        body = calls[("PUT", "/api/v1/projects/2/tasks")]
        self.assertEqual((body["title"], body["priority"]), ("ship it", 2))
        self.assertTrue(body["due_date"].startswith("2026-10-22T12:00"))
        self.assertIn("https://e.com", body["description"])
        self.assertTrue(body["reminders"][0]["reminder"].startswith("2026-10-21T12:00"))
        self.assertFalse(p.retry)
        self.assertEqual(calls[("POST", "/api/v1/tasks/42/labels/bulk")],
                         {"labels": [{"id": 7}, {"id": 101}]})   # existing reused, new created
        self.assertEqual([c for c in self.state["calls"] if c[0] == "PUT" and c[1].endswith("/labels")]
                         .__len__(), 1)

    def test_cache_used_second_time(self):
        for _ in range(2):
            vkq.create_task(self.api, self.cache, self.cfg, vkq.parse("ibx x #existing", self.cfg, now=NOW))
        gets = [c for c in self.state["calls"] if c[0] == "GET" and c[1] == "/api/v1/projects"]
        self.assertEqual(len(gets), 1)

    def test_unknown_project_code_creates_nothing(self):
        for line in ("prs x #newlabel", "nocode x"):    # unknown / project without identifier
            p = vkq.parse(line, self.cfg, now=NOW)
            with self.assertRaisesRegex(vkq.InputError, "unknown project code .* \\(known: IBX WRK\\)"):
                vkq.create_task(self.api, self.cache, self.cfg, p)
        self.assertFalse([c for c in self.state["calls"] if c[0] in ("PUT", "POST")])  # no label either
        with self.assertRaisesRegex(vkq.InputError, "code required"):
            vkq.create_task(self.api, self.cache, self.cfg, vkq.parse("#a x", self.cfg, now=NOW))

    def test_no_label_creation(self):
        cfg = {**self.cfg, "create_labels": False}
        p = vkq.parse("wrk x #nope", cfg, now=NOW)
        vkq.create_task(self.api, self.cache, cfg, p)
        self.assertTrue(p.warnings and p.retry)
        self.assertFalse([c for c in self.state["calls"] if c[0] == "POST"])

    def test_empty_title(self):
        with self.assertRaises(vkq.InputError):
            vkq.create_task(self.api, self.cache, self.cfg, vkq.parse("wrk #a", self.cfg, now=NOW))

    def test_ls_filter_and_sort(self):
        self.state["labels"].append({"id": 8, "title": "example"})
        self.state["tasks"] = [
            {"id": 1, "title": "no due", "due_date": "0001-01-01T00:00:00Z", "priority": 5},
            {"id": 2, "title": "late", "due_date": "2026-10-22T10:00:00+02:00", "priority": 1},
            {"id": 3, "title": "soon", "due_date": "2026-10-21T11:00:00+02:00", "priority": 3},
        ]
        p = vkq.parse("wrk #example @+2h !3 server logs", self.cfg, now=NOW)
        tasks = vkq.list_tasks(self.api, self.cache, self.cfg, p)
        self.assertEqual([t["id"] for t in tasks], [3, 2, 1])
        q = urllib.parse.parse_qs(self.state["queries"][-1])
        self.assertEqual(q["filter"], ["done = false && project = 2 && labels = 8 && priority >= 3 "
                                       "&& due_date <= '2026-10-21T12:00:00" + NOW.strftime("%z")[:3]
                                       + ":" + NOW.strftime("%z")[3:] + "'"])
        self.assertEqual(q["s"], ["server logs"])
        with self.assertRaisesRegex(vkq.InputError, "#nope does not exist"):
            vkq.list_tasks(self.api, self.cache, self.cfg, vkq.parse("wrk #nope", self.cfg, now=NOW))
        with self.assertRaisesRegex(vkq.InputError, "'PRS'"):
            vkq.list_tasks(self.api, self.cache, self.cfg, vkq.parse("prs", self.cfg, now=NOW))
        with self.assertRaisesRegex(vkq.InputError, "code required"):
            vkq.list_tasks(self.api, self.cache, self.cfg, vkq.parse("@today", self.cfg, now=NOW))

    def test_build_filter(self):
        f = lambda line, pid=None, ids=(): vkq.build_filter(vkq.parse("wrk " + line, self.cfg, now=NOW), pid, ids)
        self.assertEqual(f(""), "done = false")
        self.assertEqual(f("", 2, (6, 7)), "done = false && project = 2 && labels = 6 && labels = 7")
        self.assertIn("due_date <= '2026-10-21T23:59:59", f("@today"))   # date only: whole day
        self.assertIn("due_date <= '2026-10-21T17:00:00", f("@eob"))
        self.assertEqual(f("!4"), "done = false && priority >= 4")

    def test_format_task(self):
        t = {"id": 1, "title": "a  b", "project_id": 2, "priority": 3,
             "due_date": "2026-10-22T10:00:00+02:00", "labels": [{"title": "x"}, {"title": "y"}]}
        row = vkq.format_task(t, {2: "Work"})
        self.assertTrue(row.endswith("!3 Work      a b  #x #y"), row)
        self.assertEqual(vkq.format_task({**t, "due_date": "0001-01-01T00:00:00Z", "labels": None,
                                          "priority": 0}, {}).strip(), "?         a b")

    def test_undo_lookup(self):
        line = "wrk oops #a @fri"
        desc = vkq.build_description(vkq.parse(line, self.cfg, now=NOW))
        made = NOW.isoformat()
        self.state["tasks"] = [{"id": 9, "title": "oops", "description": desc, "created": made}]
        task, got = vkq.last_task_input(self.api, self.cfg, now=NOW)
        self.assertEqual((task["id"], got), (9, line))
        q = [c for c in self.state["calls"] if c[1] == "/api/v1/tasks"]
        self.assertEqual(len(q), 1)
        # too old
        later = datetime(2026, 10, 21, 12, 0).astimezone()
        with self.assertRaisesRegex(vkq.VkqError, "min old"):
            vkq.last_task_input(self.api, self.cfg, now=later)
        # not made by vkq / no tasks
        self.state["tasks"] = [{"id": 10, "title": "web", "description": "<p>hi</p>", "created": made}]
        with self.assertRaisesRegex(vkq.VkqError, "not deleted"):
            vkq.last_task_input(self.api, self.cfg, now=NOW)
        self.state["tasks"] = []
        with self.assertRaisesRegex(vkq.VkqError, "no tasks"):
            vkq.last_task_input(self.api, self.cfg, now=NOW)

    def test_errors(self):
        with self.assertRaisesRegex(vkq.VkqError, "401.*expired"):
            vkq.Api(self.base, "bad").call("GET", "/projects")
        self.state["fail"] = 503
        with self.assertRaises(vkq.ApiDown):
            self.api.call("GET", "/projects")
        with self.assertRaises(vkq.ApiDown):
            vkq.Api("http://127.0.0.1:1", "good", 1).call("GET", "/projects")


if __name__ == "__main__":
    unittest.main()
