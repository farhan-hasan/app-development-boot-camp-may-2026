# Google Stitch UI/UX Design Prompt
## Expense Tracker Mobile App

---

### Project Overview
Design a clean, modern, and intuitive Expense Tracker mobile application for Android and iOS. The app should feel lightweight and fast, targeting users who want to track daily spending without complexity. The design language should be minimal, using a soft color palette with clear data visualization.

**Platform:** iOS & Android (Flutter)
**Design Style:** Minimal, Modern, Clean, Card-based
**Primary Color:** Deep Teal (#0D9488) / Emerald
**Secondary Color:** Soft Coral (#F97316) for expenses
**Background:** Off-white (#FAFAFA) for light mode, Dark Slate (#0F172A) for dark mode
**Typography:** Inter or SF Pro style, clean sans-serif

---

### Core Features to Design

#### 1. Home Dashboard Screen
- **Top Header:** 
  - Month/Year selector with left/right arrows to navigate between months
  - Settings icon (top right)
- **Summary Cards (Horizontal or Stacked):**
  - "This Month" card: Large bold amount (৳12,500), label below
  - "Today" card: Smaller amount (৳800), label below
  - Use subtle gradients or solid color backgrounds with white text
- **Recent Transactions Section:**
  - Section title "Recent Transactions" with "See All" option
  - List of last 10 transactions grouped by date
  - Each item: Category icon (circular colored background), Title, Category label, Amount in red/coral, Date
  - Date group headers: "Today", "Yesterday", "May 1, 2025"
- **Floating Action Button (FAB):** 
  - Circular, Primary color, Plus icon, bottom-right
- **Bottom Navigation Bar:**
  - Two items: Home (active), Analytics
  - Simple icons with labels
- **Empty State:**
  - Illustration of empty wallet/piggy bank
  - "No expenses yet" text
  - "Tap + to add your first expense" subtext
- **Pull-to-Refresh:** Visual indicator design

#### 2. Add Expense Screen
- **App Bar:** 
  - Back arrow, Title "Add Expense", "Save" text button (disabled until valid)
- **Form Fields (Vertical Stack):**
  - **Amount Field:** Large font input, Currency symbol (৳) prefix, Numeric keyboard, Centered or prominent placement at top
  - **Title Field:** Text input, placeholder "What did you spend on?"
  - **Category Selector:** Horizontal scrollable chips/cards
    - Categories: Food 🍔, Transport 🚗, Shopping 🛍️, Bills 💡, Entertainment 🎬, Health 🏥, Others 📦
    - Selected state: Filled background with white icon/text
    - Unselected: Outlined or light background
  - **Date Picker:** 
    - Field showing selected date, calendar icon
    - Tap opens native-style date picker modal
  - **Note Field:** Optional, multiline text input, placeholder "Add a note (optional)"
- **Validation States:**
  - Red error text below fields if invalid
  - Shake animation hint for required fields
- **Success Feedback:**
  - Brief bottom sheet or toast: "Expense added successfully"

#### 3. Analytics Screen
- **App Bar:** Title "Analytics", Month selector dropdown or arrows
- **Spending Overview Card:**
  - Total spent for selected month
  - Comparison to previous month (optional: "+12% from last month" with arrow)
- **Category Breakdown Chart:**
  - Donut/Pie chart showing spending distribution
  - Colors per category (consistent with category chips)
  - Center of donut: Total amount or "Spending" label
- **Category List Below Chart:**
  - Each row: Color dot, Category name, Total amount, Percentage bar
  - Sorted by highest amount
  - Tap to expand (optional: show transactions in that category)
- **Empty State:**
  - "No data for this month" with illustration

#### 4. Search / Filter (Bonus Feature)
- **Search Bar:** 
  - Collapsible search field in Home screen app bar
  - Search icon activates search mode
  - Real-time filtering of transaction list by title
  - Clear (X) button when text entered
- **Filter Chips:** Below search bar (optional enhancement)
  - Filter by category, date range

#### 5. Dark Mode
- **System:** Full dark mode variant for all screens
- **Adaptations:**
  - Background: Dark Slate (#0F172A)
  - Cards: Slightly lighter slate (#1E293B)
  - Text: White/Light gray hierarchy
  - Chart colors: Slightly brighter for visibility
  - Input fields: Dark backgrounds with light borders

---

### Design System Requirements

#### Color Palette
```
Primary:        #0D9488 (Teal)
Primary Light:  #14B8A6
Primary Dark:   #0F766E
Accent/Expense: #F97316 (Coral)
Success:        #22C55E
Danger:         #EF4444
Background:     #FAFAFA (Light) / #0F172A (Dark)
Card:           #FFFFFF (Light) / #1E293B (Dark)
Text Primary:   #111827 (Light) / #F8FAFC (Dark)
Text Secondary: #6B7280 (Light) / #94A3B8 (Dark)
Border:         #E5E7EB (Light) / #334155 (Dark)
```

#### Category Colors
```
Food:           #F59E0B (Amber)
Transport:      #3B82F6 (Blue)
Shopping:       #EC4899 (Pink)
Bills:          #8B5CF6 (Violet)
Entertainment:  #F97316 (Orange)
Health:         #EF4444 (Red)
Others:         #6B7280 (Gray)
```

#### Typography Scale
- H1 (Month Total): 32px / Bold
- H2 (Screen Titles): 24px / SemiBold
- H3 (Card Titles): 18px / SemiBold
- Body: 16px / Regular
- Caption: 14px / Regular
- Small: 12px / Medium (for labels, badges)

#### Spacing & Layout
- Screen padding: 16px horizontal
- Card padding: 16px
- Card border-radius: 16px
- Section gap: 24px
- List item height: 64px
- FAB size: 56px
- Bottom nav height: 64px

#### Icons (Lucide/Phosphor style)
- Home, Chart-Pie, Plus, ChevronLeft, Calendar, Search, Settings, Trash2, Edit3
- Category icons: Utensils, Car, ShoppingBag, Zap, Film, Heart, Package

---

### User Flows to Visualize

1. **First Launch → Empty Home → Add First Expense → Home with Data**
2. **Home → Scroll Recent List → Tap Month Selector → Change Month → View Past Data**
3. **Home → FAB → Add Expense Screen → Fill Form → Save → Success Toast → Back to Home**
4. **Home → Bottom Nav → Analytics → Change Month → View Chart → Scroll Category List**
5. **Home → Pull Down → Refresh Indicator → Updated List**
6. **Home → Tap Search → Type "Food" → Filtered List → Clear Search**
7. **Home → Swipe Transaction Left → Delete Button → Confirmation → Remove**
8. **Toggle Dark Mode → All Screens Adapt**

---

### Interaction & Animation Specifications

- **Screen Transitions:** Slide from right (iOS style) or Fade (Android)
- **FAB:** Scale up on press, subtle shadow
- **List Items:** Subtle fade-in on load, staggered
- **Chart:** Animated draw on screen entry (1s duration)
- **Category Chips:** Scale 0.95 on press, fill color transition 200ms
- **Delete Action:** Swipe reveals red delete button, item slides out on confirm
- **Toast/Snackbar:** Slide up from bottom, auto-dismiss 2s
- **Month Change:** Cross-fade between data sets
- **Empty States:** Gentle floating animation on illustration

---

### Assets to Generate
1. App Icon: Simple wallet or coin stack, teal background
2. Empty State Illustration: Minimal line-art style, wallet with moths or empty piggy bank
3. Splash Screen: Logo centered, teal background
4. Onboarding (Optional 1-2 screens): Simple feature highlights

---

### Deliverables Expected from Stitch
1. **High-Fidelity Screens:** All screens in Light & Dark mode
2. **Component Library:** Buttons, Inputs, Cards, Chips, Icons, Charts
3. **Interactive Prototype:** Clickable flow between screens
4. **Design Tokens:** Colors, Typography, Spacing, Shadows exported
5. **Responsive Considerations:** How layouts adapt to different screen sizes
6. **Accessibility Notes:** Color contrast ratios, touch target sizes (min 48dp)

---

### Notes for Designer
- Keep it SIMPLE. No over-designing. Every element must serve a purpose.
- Prioritize readability of amounts and dates.
- The app should feel trustworthy for financial data.
- Avoid clutter. White space is important.
- Ensure the chart is readable even with 7 categories.
- Test contrast in both light and dark modes.
