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
├── Signing.xcconfig          ← shared signing defaults (see §7)
├── Local.xcconfig.example    ← copy → Local.xcconfig for personal device builds
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

Apple won't let two free Apple IDs use the same bundle identifier, so each teammate needs their own. We solve this with a **per-developer `Local.xcconfig`** that's gitignored — set it once, never worry again, no merge conflicts.

**One-time setup:**

1. Copy the template:
   ```bash
   cp Local.xcconfig.example Local.xcconfig
   ```
2. Open `Local.xcconfig` and edit two values:
   - `PRODUCT_BUNDLE_IDENTIFIER` — pick something unique, e.g. `com.lenny.MeowNotes`
   - `DEVELOPMENT_TEAM` — find it in Xcode: *Settings ▸ Accounts ▸ Manage Certificates* → the 10-character string next to "Personal Team"
3. In Xcode: project → target **MeowNotes** → **Signing & Capabilities** → **Team:** *Add an Account…* and log in with your personal Apple ID.
4. Plug in your iPhone, trust the computer, select it as the run target.
5. ⌘R → on the phone: **Settings ▸ General ▸ VPN & Device Management** → trust your Apple ID.
6. App runs for **7 days**; re-run from Xcode to extend.

**Important:** `Local.xcconfig` is in `.gitignore` and will never be committed. Your personal bundle ID / team ID stay on your machine only. **Do NOT edit `Signing.xcconfig` for your personal setup** — it's the shared default for everyone.

How it works: `Signing.xcconfig` (committed) holds safe defaults. Its last line is `#include? "Local.xcconfig"` — the `?` means "include if it exists, otherwise skip silently." If your `Local.xcconfig` exists, its values override the defaults. No pbxproj edits, no conflicts, ever.

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

---

## 10. Who owns which view

Every view is a separate file under `MeowNotes/Views/` so two people can never edit the same file at the same time. Pick one, write your name on the `Owner:` comment at the top of the file, and you own it.

**Navigation is already wired** — you don't need to touch `ContentView.swift` or `HomeView.swift`. Just open the file with your name on it, replace the placeholder body, and your view will be reachable from the home screen.

### Top-level screens

| View | File | Owner |
|---|---|---|
| Home dashboard | [MeowNotes/Views/HomeView.swift](MeowNotes/Views/HomeView.swift) | TBD |
| Login | [MeowNotes/Views/LoginView.swift](MeowNotes/Views/LoginView.swift) | TBD |
| Account / profile | [MeowNotes/Views/AccountView.swift](MeowNotes/Views/AccountView.swift) | TBD |
| Sitter Guide (public) | [MeowNotes/Views/GuideView.swift](MeowNotes/Views/GuideView.swift) | TBD |

### Modal edit sheets (opened from Home)

| Sheet | File | Owner |
|---|---|---|
| Personality | [MeowNotes/Views/Sheets/EditPersonalityView.swift](MeowNotes/Views/Sheets/EditPersonalityView.swift) | TBD |
| Routine | [MeowNotes/Views/Sheets/EditRoutineView.swift](MeowNotes/Views/Sheets/EditRoutineView.swift) | TBD |
| Basic Care | [MeowNotes/Views/Sheets/EditBasicCareView.swift](MeowNotes/Views/Sheets/EditBasicCareView.swift) | TBD |
| Preferences | [MeowNotes/Views/Sheets/EditPreferencesView.swift](MeowNotes/Views/Sheets/EditPreferencesView.swift) | TBD |
| Caution | [MeowNotes/Views/Sheets/EditCautionView.swift](MeowNotes/Views/Sheets/EditCautionView.swift) | TBD |
| Medical | [MeowNotes/Views/Sheets/EditMedicalView.swift](MeowNotes/Views/Sheets/EditMedicalView.swift) | TBD |
| Notes | [MeowNotes/Views/Sheets/EditNotesView.swift](MeowNotes/Views/Sheets/EditNotesView.swift) | TBD |
| New Cat | [MeowNotes/Views/Sheets/NewCatView.swift](MeowNotes/Views/Sheets/NewCatView.swift) | TBD |
| Share | [MeowNotes/Views/Sheets/ShareView.swift](MeowNotes/Views/Sheets/ShareView.swift) | TBD |

### Rules

- **Do not edit `ContentView.swift` or `HomeView.swift`** unless you're adding/removing a whole screen — wiring is centralized there for a reason.
- **Do not delete the `onSignIn` / `onSignOut` callbacks** in `LoginView` and `HomeView` — `ContentView` depends on them.
- **Each sheet already has a working "Done" button** that dismisses it. Don't remove it.
- **Use SwiftUI preview** (`#Preview { … }` at the bottom of each file) to iterate fast without running the full app.
- When you claim a view: edit the `// Owner: TBD` line at the top of your file, commit on a branch named `feat/<yourname>-<view>`, open a PR.
