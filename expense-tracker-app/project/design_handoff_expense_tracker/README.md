# Handoff: Expense Tracker App

## Overview
A minimal, modern expense tracking mobile app for iOS and Android (Flutter target). Users can log daily expenses, browse transaction history by month, view analytics with category breakdowns, and manage settings. The design prioritizes speed of entry, clarity of financial data, and a clean aesthetic in both light and dark modes.

## About the Design Files
The files in this bundle are **high-fidelity design references built in HTML/React** — interactive prototypes showing intended look, layout, and behavior. They are **not production code to copy directly**. Your task is to recreate these designs in your target codebase (Flutter, React Native, or equivalent) using its established patterns, component libraries, and navigation system.

Open `Expense Tracker Prototype (Offline).html` in any browser — no internet required. All screens are interactive and clickable.

## Fidelity
**High-fidelity.** All colors, spacing, typography, border radii, shadows, and interactions are final. Recreate pixel-perfectly using your design system. If your existing codebase has a design system that conflicts on minor details (e.g. slightly different border radii), defer to the existing system for those tokens; use the spec here as the source of truth for everything else.

---

## Screens / Views

### 1. Onboarding (3 slides)
**Purpose:** First-launch introduction to core value props.

**Layout:** Full-screen column. Top ~65% is a full-bleed gradient hero; bottom ~35% is a white/dark panel with dots + buttons.

**Hero area:**
- Background: linear gradient per slide (see colors below)
- Large emoji: 80px, floating animation (translateY 0→-8px→0, 3s loop)
- Title: 26px, 800 weight, white, centered, line-height 1.25
- Description: 15px, 400 weight, rgba(255,255,255,0.8), centered, max-width 260px, line-height 1.6
- Two decorative circles: semi-transparent white (rgba(255,255,255,0.06)), absolutely positioned off-screen edges

**Bottom panel:**
- Background: matches app bg (light: #FAFAFA, dark: #0F172A)
- Padding: 28px 24px 40px
- Progress dots: 8×8px circles, active dot expands to 24px wide, radius 4px. Active color = slide accent. Inactive = border color. Gap 8px. Tap to jump to slide.
- Buttons row: gap 12px
  - Skip (if not last slide): flex 1, height 50px, bg cardAlt, textSec color, radius 14px, 14px/600
  - Next / Get Started: flex 2 (flex 1 on last slide), height 50px, gradient bg matching slide, white, radius 14px, 15px/700, shadow: `0 8px 24px {color}44`

**Slide data:**
| # | Emoji | Title | Gradient | Accent |
|---|---|---|---|---|
| 1 | 💰 | Track Every Penny | `#0D9488 → #0F766E` | `#0D9488` |
| 2 | 📊 | Visualize Your Spending | `#8B5CF6 → #7C3AED` | `#8B5CF6` |
| 3 | 🎯 | Spend Smarter | `#F97316 → #EA580C` | `#F97316` |

**Interactions:**
- Skip → go to Home
- Next → advance slide
- Get Started (last slide) → go to Home
- Dot tap → jump to that slide
- Hero transitions: `background` CSS transition 0.5s ease between slides

---

### 2. Home Dashboard
**Purpose:** Main screen — month overview, summary cards, transaction list.

**Layout:** Column: header (fixed) → scrollable transaction list → bottom nav (absolute).

**Header (padding 12px 16px 0):**
- Row 1: Month navigator + action icons
  - Left: chevron button (32×32px, radius 50%, bg cardAlt) → prev month
  - Center: month/year text (15px/700, min-width 120px, centered)
  - Right: chevron button → next month
  - Far right: search icon (36×36px, radius 10px, bg cardAlt) + settings icon (same)
- Row 2 (two summary cards, gap 12px, margin-bottom 20px):
  - **This Month card** (flex 1): radius 16px, padding 16px, gradient `primary → primaryDark`, shadow `0 8px 24px {primary}44`. Label: 11px/500, rgba(255,255,255,0.75), uppercase, letter-spacing 0.05em. Amount: 26px/800, white, letter-spacing -0.5px. Subtext: 11px, rgba(255,255,255,0.6). **Tap → go to Analytics tab.**
  - **Today card** (flex 0.65): radius 16px, padding 16px, gradient `#F97316 → #EA580C`, shadow `0 8px 24px rgba(249,115,22,0.35)`. Same label/amount/subtext pattern. Amount: 22px/800. **Tap → filter to today's transactions.**

**Transaction list (overflowY auto, padding 0 16px 80px):**
- Pull-to-refresh: drag down >60px shows spinner, triggers refresh
- Section header: "Recent Transactions" (15px/700, text color) + "See All" / "Show Less" toggle (13px/500, primary color)
- Date group headers: date label (12px/600, textSec, letter-spacing 0.04em) + daily total (12px, textSec). Margin-bottom 8px.
- See All: shows all; default shows max 10 transactions

**Transaction item (height ~64px):**
- Container: radius 12px, margin-bottom 2px, overflow hidden
- Swipe-to-delete: on touch drag left >30px, item slides left 80px to reveal red delete zone (80px wide, bg `danger`, trash icon + "Delete" label)
- Item row: flex row, gap 12px, padding 10px 12px, bg card, radius 12px, cursor pointer
  - Category icon: 44×44px, radius 12px, bg `{catColor}22`, emoji 20px
  - Title: 14px/600, text color, truncate with ellipsis. Category: 12px, textSec
  - Amount: 15px/700, expense color, right-aligned. Date: 11px, textSec
- **Tap item → open Expense Detail Sheet**
- Animation: fadeInUp staggered (delay = index × 0.06s)

**FAB (Floating Action Button):**
- Position: absolute, bottom 76px, right 20px
- Size: 56×56px, radius 50%
- Background: gradient `primaryLight → primary`
- Shadow: `0 8px 24px {primary}55`
- Plus icon: 24px, white
- Hover: scale(1.1), shadow intensifies
- **Tap → Add Expense screen**

**Search mode** (replaces top row):
- Full-width input with search icon, placeholder "Search expenses..."
- Real-time filter by title, category, or date
- X button clears query; "Cancel" exits search mode

---

### 3. Add Expense
**Purpose:** Form to log a new expense.

**Layout:** Column: app bar → scrollable form.

**App bar (padding 12px 16px):**
- Back button: 36×36px, radius 10px, bg cardAlt
- Title: "Add Expense" 17px/700
- Save button: 14px/700, primary color (gray if form invalid)

**Form fields (gap 8–12px):**

**Amount card** (bg card, radius 20px, padding 24px 20px, shadow):
- Label: "Amount" 13px/500, textSec, centered
- Currency symbol: 40px/800, textSec
- Input: 48px/800, text color, transparent bg, centered, numeric keyboard

**Title field** (bg card, radius 16px, padding 14px 16px):
- Label: "TITLE" 11px/600, textSec, uppercase, letter-spacing 0.05em
- Input: 15px, text color, placeholder "What did you spend on?"

**Category selector** (bg card, radius 16px, padding 14px 16px):
- Label: "CATEGORY" (same style)
- Chips: flex wrap, gap 8px
- Each chip: padding 8px 12px, radius 12px, 13px font
  - Unselected: bg cardAlt, border `1.5px solid border`, text color
  - Selected: bg = category color, border = category color, white text, scale(1.02)
  - Transition: all 0.15s ease

**Date field** (bg card, radius 16px, padding 14px 16px, tappable):
- Label: "DATE"
- Shows formatted date (e.g. "Sat, May 3, 2026") + calendar icon
- **Tap → opens Date Picker Modal**

**Note field** (bg card, radius 16px, padding 14px 16px):
- Label: "Note (optional)"
- Textarea: 3 rows, resize none, 14px

**Save button** (padding 16px, radius 16px):
- Active: gradient `primaryLight → primary`, white text, shadow `0 8px 24px {primary}44`
- Disabled: bg cardAlt, textSec color
- Validation: requires amount > 0, title non-empty, category selected
- On invalid submit: shake animation (translateX ±4-6px, 0.4s), show red error text below fields

**Date Picker Modal** (bottom sheet):
- Backdrop: rgba(0,0,0,0.5), tap to dismiss
- Sheet: bg card, radius 24px 24px 0 0, padding 24px, slideInUp 0.3s
- Month navigation (prev/next), 7-column day grid
- Selected day: bg primary, white text, radius 10px
- Buttons: Cancel (border) + Confirm (bg primary)

**On save:**
- Add expense to data store for the correct month
- Navigate back to Home
- Show toast: "Expense added successfully ✓" (slides up from bottom, auto-dismiss 2.5s)

---

### 4. Expense Detail Sheet
**Purpose:** View full details of a transaction; launch edit or delete.

**Trigger:** Tap any transaction card on Home.

**Layout:** Bottom sheet overlay.
- Backdrop: rgba(0,0,0,0.55), tap to dismiss
- Sheet: bg card, radius 28px 28px 0 0, slideInUp animation `cubic-bezier(0.34,1.2,0.64,1) 0.32s`
- Drag handle: 36×4px, radius 2px, border color, centered

**Content:**
- Category icon bubble: 72×72px, radius 22px, bg `{catColor}22`, border `2px solid {catColor}33`, emoji 34px
- Amount: 28px/800, expense color, letter-spacing -1px
- Title: 18px/700, text color, centered
- Category badge: pill with colored dot + category name (13px/600, category color), bg `{catColor}18`, border `{catColor}33`

**Detail rows** (padding 14px 0 each, border-bottom between):
- Date row: calendar icon + "Date" label | formatted date value
- Amount row: currency symbol icon + "Amount" | amount value
- Note row (if present): info icon + "Note" | note text

**Action buttons** (padding 20px 24px 32px, gap 12px):
- Delete (flex 1): 14px/700. Default: bg cardAlt, danger color text, border `danger33`. After first tap: bg danger, white text (tap-to-confirm pattern — resets after 3s if not confirmed)
- Edit Expense (flex 2): gradient primary, white, pencil icon, shadow `0 6px 20px {primary}44`

---

### 5. Edit Expense
**Purpose:** Modify an existing expense.

**Layout:** Identical to Add Expense but pre-filled with existing values.
- App bar title: "Edit Expense"
- Save button label: "Save Changes"
- On save: updates existing record in data store, navigates back, shows "Expense updated ✓" toast

---

### 6. Analytics
**Purpose:** Visual breakdown of spending for the selected month.

**Layout:** Column: header → scrollable content.

**Header:** "Analytics" title (22px/800) + month navigator (same pattern as Home).

**Overview card** (gradient primary → primaryDark, radius 20px, padding 20px, shadow):
- "Total Spent" label: 13px/500, rgba(255,255,255,0.7)
- Amount: 32px/800, white, letter-spacing -1px
- Month comparison badge (if previous month has data): inline-flex, bg rgba(255,255,255,0.15), radius 8px, padding 6px 10px. Shows "↑ +N% from last month" or "↓ -N%". Trend icon + text 12px/600 white.

**Donut chart card** (bg card, radius 20px, padding 20px):
- Title: "Spending by Category" 15px/700
- SVG donut: R=70, strokeWidth=22, circumference=440
- Center text: "Total" (11px, textSec) + amount (16px/800, text color)
- Segments animate in with stroke-dasharray transition (0.8s ease, staggered by 0.08s per segment)
- Track ring: border color

**Breakdown list card** (bg card, radius 20px, padding 16px):
- Title: "Breakdown" 15px/700
- Per category row (sorted descending by amount):
  - Color dot (10×10px) + category name (14px/500) + emoji
  - Amount (13px/600) + percentage (11px, textSec)
  - Progress bar: height 6px, bg border, radius 3px. Fill: category color, width = pct%. Animated: `width 0.8s cubic-bezier(0.34,1.56,0.64,1)` staggered

**Empty state:** floating 📊 emoji + "No data for this month"

---

### 7. Settings
**Purpose:** App preferences — appearance, currency, notifications, data management.

**Layout:** Column: app bar → scrollable sections.

**Profile card** (margin 8px 16px, bg `primary22`, border `primary22`, radius 16px, padding 16px):
- 52×52px icon bubble (gradient primary), emoji 💳
- "My Wallet" 16px/700 + "Personal expense tracker" 13px, textSec

**Section headers:** 11px/700, textSec, uppercase, letter-spacing 0.08em, padding 20px 16px 8px

**Setting rows** (inside card, radius 16px, overflow hidden):
- Row: flex, gap 14px, padding 14px 16px, cursor pointer
- Hover: bg transitions to cardAlt (0.15s)
- Icon bubble: 38×38px, radius 10px, bg cardAlt (or `EF444422` for danger)
- Label: 14px/600, text color (or EF4444 for danger)
- Sublabel: 12px, textSec

**Toggle component:**
- 46×26px pill, radius 13px
- On: bg primary. Off: bg border
- Thumb: 20×20px circle, white, absolute positioned. On: left 23px. Off: left 3px. Transition: left 0.2s ease
- bg transition: 0.2s ease

**Sections:**
1. **Appearance**: Dark Mode toggle
2. **Preferences**: Currency (→ opens currency picker sheet) | Reminders toggle
3. **About**: Privacy Policy (→ external link) | App Version (static "1.0.0")
4. **Data**: Clear All Data (danger, tap-to-confirm: first tap shows "Tap again to confirm", second tap clears all data + toast + navigate home)

**Currency Picker Sheet** (bottom sheet, same pattern as Date Picker):
- List of currencies: ৳ Bangladeshi Taka, $ US Dollar, € Euro, £ British Pound, ₹ Indian Rupee
- Selected item: check icon (primary color), bg `primary22` icon bubble
- Tap → update currency across app

---

## Interactions & Behavior

### Navigation
- Onboarding → Home (Skip or Get Started)
- Home → Add Expense (FAB tap)
- Home → Analytics (bottom nav OR tap "This Month" card)
- Home → Settings (⚙️ icon)
- Any screen → back (back button)
- Expense detail → Edit Expense
- Bottom nav: Home ↔ Analytics

### Animations & Transitions
| Trigger | Animation | Duration/Easing |
|---|---|---|
| Screen push (right) | slideInRight: translateX(100%→0), opacity 0→1 | 0.25s ease |
| Bottom sheet open | slideInUp: translateY(100%→0) | 0.32s cubic-bezier(0.34,1.2,0.64,1) |
| Bottom sheet backdrop | fadeIn: opacity 0→1 | 0.2s ease |
| Transaction list items | fadeInUp: translateY(16px→0), opacity | 0.4s ease, stagger index×0.06s |
| Transaction delete | height→0, opacity→0 | 0.35s ease |
| FAB hover | scale(1.1) | 0.15s ease |
| Category chip select | background/border color change + scale(1.02) | 0.15s ease |
| Toast notification | translateY(80px→0), opacity | 0.3s ease, auto-dismiss 2.5s |
| Donut chart segments | stroke-dasharray | 0.8s ease, stagger 0.08s |
| Progress bars | width % | 0.8s cubic-bezier(0.34,1.56,0.64,1), stagger 0.05s |
| Summary cards | fadeInUp, second card delayed 0.1s | 0.4s ease |
| Floating illustration | translateY 0→-8px→0 | 3s ease-in-out, infinite |
| Onboarding dots | width 8→24px | 0.3s ease |
| Toggle thumb | left position | 0.2s ease |
| Month change (data) | cross-fade | — |
| Settings row hover | background color | 0.15s ease |

### Swipe-to-Delete (touch)
- Touch start: record startX
- Touch move: if dx > 30px left → slide item left 80px (translateX -80px), reveal red delete zone
- Touch move: if dx > 10px right → collapse back
- Tap delete button → animate item out (height→0) then remove from state

### Form Validation (Add/Edit Expense)
- Save button disabled until: amount > 0, title non-empty, category selected
- On invalid submit attempt: shake animation on amount card + red error text below each invalid field
- Errors clear as user types

---

## State Management

### Global state (App level)
```
data: { [monthKey: string]: Transaction[] }
  // monthKey format: "YYYY-M" (e.g. "2026-5")

Transaction: {
  id: string         // unique random ID
  title: string
  category: Category
  amount: number     // in local currency units
  date: string       // "YYYY-MM-DD"
  note: string       // optional
}

Category: 'Food' | 'Transport' | 'Shopping' | 'Bills' | 'Entertainment' | 'Health' | 'Others'

currentYear: number
currentMonth: number  // 1-indexed
screen: 'onboarding' | 'home' | 'add' | 'edit' | 'settings'
tab: 'home' | 'analytics'
selectedTxn: Transaction | null   // for detail sheet
editingTxn: Transaction | null    // for edit screen
searchMode: boolean
darkMode: boolean
currency: string    // '৳' | '$' | '€' | '£' | '₹'
accentColor: string // hex
```

### Key state transitions
- Add expense → insert into `data[monthKey]`, show toast, navigate home
- Edit expense → remove from old month bucket, insert into new month bucket (date may change), show toast, navigate home
- Delete expense → remove from `data[monthKey]`
- Clear all data → reset `data` to `{}`, show toast, navigate home
- Month navigation → update currentYear/currentMonth, analytics re-derives from data

### Persistence
Store `data`, `darkMode`, `currency` in AsyncStorage (Flutter: SharedPreferences or Hive).

---

## Design Tokens

### Colors
```
primary:         #0D9488   (Teal)
primaryLight:    #14B8A6
primaryDark:     #0F766E
expense:         #F97316   (Coral/Orange — used for amounts)
success:         #22C55E
danger:          #EF4444

// Light mode
bg:              #FAFAFA
card:            #FFFFFF
cardAlt:         #F1F5F9
text:            #111827
textSec:         #6B7280
border:          #E5E7EB
navBg:           #FFFFFF
inputBg:         #F9FAFB

// Dark mode
bg:              #0F172A
card:            #1E293B
cardAlt:         #162032
text:            #F8FAFC
textSec:         #94A3B8
border:          #334155
navBg:           #1E293B
inputBg:         #0F172A
```

### Category Colors
```
Food:            #F59E0B   (Amber)
Transport:       #3B82F6   (Blue)
Shopping:        #EC4899   (Pink)
Bills:           #8B5CF6   (Violet)
Entertainment:   #F97316   (Orange)
Health:          #EF4444   (Red)
Others:          #6B7280   (Gray)
```

### Typography — Inter (or SF Pro on iOS)
```
H1 month total:  32px / 800 / letter-spacing -1px
H2 screen title: 22–24px / 800 / letter-spacing -2px
H3 card title:   17–18px / 700
Amount large:    48px / 800 (Add Expense input)
Amount display:  26–28px / 800
Body:            15–16px / 400–500
Caption:         13–14px / 500–600
Small / Label:   11–12px / 600 / uppercase / letter-spacing 0.05–0.08em
```

### Spacing
```
Screen padding:  16px horizontal
Card padding:    16–20px
Section gap:     24px
List item gap:   2px (margin-bottom)
Card gap:        8–12px
```

### Radii
```
Card:            16px
Large card:      20px
Sheet:           24–28px (top corners only)
Chip:            12px
Button:          14–16px
FAB:             50% (circle)
Icon bubble:     10–14px
Dot:             50%
```

### Shadows
```
Light card:      0 4px 24px rgba(0,0,0,0.08)
Dark card:       0 4px 24px rgba(0,0,0,0.4)
Primary card:    0 8px 24px {primary}44
FAB:             0 8px 24px {primary}55
```

---

## Assets

### Icons (Lucide / Phosphor style, 2px stroke)
- Home, ChartPie (analytics), Plus, ChevronLeft, ChevronRight, Calendar, Search, Settings, X, Trash2, Check, RefreshCw, TrendingUp, TrendingDown, Edit3, Moon, Sun, Globe, Bell, Shield, Info

### Category Emojis
- Food 🍔 / Transport 🚗 / Shopping 🛍️ / Bills 💡 / Entertainment 🎬 / Health 🏥 / Others 📦

No external image assets required.

---

## Files in This Package

| File | Description |
|---|---|
| `Expense Tracker Prototype.html` | Full interactive prototype (requires internet for fonts/React CDN) |
| `Expense Tracker Prototype (Offline).html` | Fully self-contained, works without internet — **use this for reference** |
| `README.md` | This document |

Open the offline HTML file in Chrome or Safari for the best experience. All screens are navigable — start from the onboarding screen and click through the full flow.
