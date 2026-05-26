# MeowNotes

A simple iOS notes app built by a learning team.

- **Platform:** iOS 26 (Xcode 26)
- **Language:** Swift 6 / SwiftUI
- **Source control:** GitHub
- **No Apple Developer Account needed** — we run on Simulator and on personal devices via a free Apple ID (7-day signing).

---

## 1. Get the app running (everyone)

```bash
git clone <repo-url>
cd MeowNotes_CH3
open MeowNotes.xcodeproj
```

In Xcode: pick an iPhone simulator (e.g. **iPhone 17**) from the device selector at the top, press **⌘R**. You should see a notes list with two seed entries.

That's it. No `pod install`, no extra setup.

---

## 2. Folder layout

```
MeowNotes_CH3/
├── .gitignore
├── .gitattributes
├── .swift-version
├── README.md                 ← this file
├── MeowNotes.xcodeproj/      ← Xcode project, committed
└── MeowNotes/                ← Synchronized Folder — all source code lives here
    ├── MeowNotesApp.swift    ← app entry point (@main)
    ├── ContentView.swift     ← root view
    ├── Assets.xcassets/      ← images, colors, app icon
    └── Preview Content/      ← SwiftUI preview-only assets
```

Add new `.swift` files under `MeowNotes/` and they appear in Xcode automatically (see §3).

---

## 3. Why we use Synchronized Folders (avoiding `.pbxproj` conflicts)

The classic Xcode team pain: two people add a file at the same time → `project.pbxproj` conflicts → nobody can build.

**Xcode 16+ fixed this with Synchronized Folders.** The `MeowNotes` group is configured as a synchronized root group — Xcode reads its contents from disk automatically. Adding/removing files doesn't edit `project.pbxproj`, so no merge conflicts.

**How to add new code:**

- Just create new `.swift` files inside `MeowNotes/` (or any subfolder) from Finder, your terminal, or Xcode's *File ▸ New ▸ File…* dialog. They show up in the navigator immediately.
- New subfolders also appear automatically.
- **You do NOT need to drag files into the project** like in old Xcode tutorials.

---

## 4. Team workflow on GitHub

```
main ──●──────●──────●──────●──── (always working, never broken)
        \    /  \    /
         feat/X  feat/Y
```

**Rules:**

- **Never push directly to `main`.** Always work on a branch.
- Branch name = `feat/<your-name>-<short-thing>` (e.g. `feat/aziz-note-editor`).
- Open a Pull Request when ready. Get **one teammate to review** before merging.
- Use **Squash and merge** in GitHub — keeps `main` history clean.
- Pull `main` daily before starting work.

### Day-to-day commands

```bash
git checkout main
git pull                         # get latest
git checkout -b feat/me-thing    # new branch

# …code, build (⌘B), test in Xcode…

git add .
git commit -m "Add note editor view"
git push -u origin feat/me-thing

# Then open a PR on github.com
```

---

## 5. What NOT to commit

The `.gitignore` blocks these automatically:

- `xcuserdata/` — your personal Xcode window layout, breakpoints, schemes
- `DerivedData/` — build cache (can be 1+ GB)
- `*.xcuserstate` — your editor state
- `.build/`, `.swiftpm/` — Swift Package Manager caches

If you ever see one of these in `git status`, double-check your `.gitignore`.

---

## 6. If you DO hit a merge conflict in `.pbxproj`

1. Don't panic. `.gitattributes` is set with `merge=union` so most conflicts auto-resolve.
2. If you still see one:
   ```bash
   git checkout --theirs MeowNotes.xcodeproj/project.pbxproj
   ```
3. Build (⌘B). If it builds, commit. If not, ask the team.

---

## 7. Running on a real iPhone (no paid account)

1. Plug in your iPhone via USB. Trust the computer.
2. In Xcode top bar, select your iPhone as the run target.
3. Click the project in the navigator → target **MeowNotes** → **Signing & Capabilities** → **Team:** *Add an Account…* and log in with your personal Apple ID.
4. Change the **Bundle Identifier** to something unique to you, e.g. `com.aziz.MeowNotes` (Apple won't let two people use the same bundle ID with free accounts).
5. ⌘R → on the phone, go to **Settings ▸ General ▸ VPN & Device Management** → trust your Apple ID.
6. App runs for **7 days**, then re-run from Xcode to extend.

> Don't commit your personal bundle ID change to `main`. Either keep it as a local-only edit, or we'll add per-developer signing config later.

---

## 8. Commit message style

Short, imperative, no emojis:

- ✅ `Add note list view`
- ✅ `Fix crash when saving empty note`
- ❌ `updated stuff`
- ❌ `🎉 final version!!!`

---

## 9. Build from the command line (optional)

To check the project builds without opening Xcode:

```bash
xcodebuild -project MeowNotes.xcodeproj \
  -scheme MeowNotes \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -configuration Debug build
```

You should see `** BUILD SUCCEEDED **` at the end.
