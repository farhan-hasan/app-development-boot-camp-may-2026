# Hisabi Expense Tracker - Claude Code Project Plan
## Flutter Mobile App | One-Week Build

---

## 1. Project Overview

Build a simple, production-ready Expense Tracker mobile application using Flutter. The app demonstrates Clean Architecture, Riverpod state management, Firebase Firestore integration, and modern Flutter development practices.

**Deadline:** 7 days
**Complexity:** Simple but structured. No over-engineering.

---

## 2. Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x |
| Language | Dart |
| State Management | Riverpod (with code generation) |
| Navigation | GoRouter |
| Backend/Database | Firebase Firestore |
| Local Storage | Shared Preferences |
| Charts | fl_chart |
| Dependency Injection | Riverpod (built-in) |
| Architecture | MVVM + Clean Architecture (3 layers) |

---

## 3. Project Structure

```
expense_tracker/
├── android/
├── ios/
├── lib/
│   ├── main.dart
│   ├── config/
│   │   ├── router.dart                 # GoRouter configuration
│   │   ├── theme.dart                  # Light & Dark theme data
│   │   └── constants.dart              # App constants, category config
│   ├── domain/
│   │   ├── entities/
│   │   │   └── expense.dart            # Core Expense entity
│   │   └── repositories/
│   │       └── expense_repository.dart # Abstract repository interface
│   ├── data/
│   │   ├── models/
│   │   │   └── expense_model.dart      # Firestore data model
│   │   └── repositories/
│   │       └── expense_repository_impl.dart # Firestore implementation
│   ├── presentation/
│   │   ├── providers/
│   │   │   └── expense_provider.dart   # Riverpod AsyncNotifier
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   ├── add_expense_screen.dart
│   │   │   └── analytics_screen.dart
│   │   └── widgets/
│   │       ├── expense_list_item.dart
│   │       ├── category_chip.dart
│   │       ├── summary_card.dart
│   │       ├── category_pie_chart.dart
│   │       ├── empty_state.dart
│   │       └── month_selector.dart
│   └── utils/
│       ├── date_formatter.dart
│       └── category_utils.dart
├── test/
├── pubspec.yaml
└── firebase.json (if using Firebase CLI)
```

---

## 4. Architecture Rules

### Clean Architecture Principles
1. **Domain Layer** has ZERO dependencies on Flutter, Firebase, or external packages.
2. **Data Layer** depends only on Domain. Handles all Firebase logic.
3. **Presentation Layer** depends on Domain. Uses Riverpod for state management.
4. Data flows: Presentation → Repository Interface (Domain) → Repository Implementation (Data) → Firebase

### State Management Pattern
- Use `AsyncNotifier` for all business logic that involves async operations (Firestore).
- Use `FutureProvider` for derived/computed state.
- Use `StateProvider` for simple UI state (search query, selected month).
- All providers live in `presentation/providers/`.

---

## 5. Core Implementation Details

### 5.1 Domain Layer

**File:** `lib/domain/entities/expense.dart`
```dart
class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  });
}
```

**File:** `lib/domain/repositories/expense_repository.dart`
```dart
abstract class ExpenseRepository {
  Future<List<Expense>> getExpensesForMonth(DateTime month);
  Future<void> addExpense(Expense expense);
  Future<void> deleteExpense(String id);
  Future<double> getTotalForMonth(DateTime month);
}
```

### 5.2 Data Layer

**File:** `lib/data/models/expense_model.dart`
- Must have `toJson()` and `fromJson()` methods.
- Must have `toEntity()` and `fromEntity()` mapper methods.
- Firestore document ID maps to `Expense.id`.
- Date stored as Timestamp in Firestore, converted to DateTime in model.

**File:** `lib/data/repositories/expense_repository_impl.dart`
- Implements `ExpenseRepository`.
- Uses Firebase Firestore instance.
- Collection name: `expenses`.
- Queries use `where('date', isGreaterThanOrEqualTo: startOfMonth)` and `where('date', isLessThan: startOfNextMonth)`.
- Order by `date` descending.

### 5.3 Presentation Layer

**File:** `lib/presentation/providers/expense_provider.dart`
```dart
// Selected month provider
final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Expense list provider (AsyncNotifier)
@riverpod
class ExpenseList extends _$ExpenseList {
  @override
  Future<List<Expense>> build() async {
    final month = ref.watch(selectedMonthProvider);
    final repo = ref.watch(expenseRepositoryProvider);
    return repo.getExpensesForMonth(month);
  }

  Future<void> addExpense(Expense expense) async {
    final repo = ref.read(expenseRepositoryProvider);
    await repo.addExpense(expense);
    ref.invalidateSelf();
  }

  Future<void> deleteExpense(String id) async {
    final repo = ref.read(expenseRepositoryProvider);
    await repo.deleteExpense(id);
    ref.invalidateSelf();
  }
}

// Monthly total provider
@riverpod
Future<double> monthlyTotal(MonthlyTotalRef ref) async {
  final month = ref.watch(selectedMonthProvider);
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.getTotalForMonth(month);
}
```

**File:** `lib/presentation/screens/home_screen.dart`
- ConsumerStatefulWidget or ConsumerWidget.
- Layout: Scaffold with CustomScrollView or Column.
- Components: MonthSelector, SummaryCard (This Month), SummaryCard (Today), RecentTransactionsList.
- FAB navigates to AddExpenseScreen.
- BottomNavigationBar with Home and Analytics tabs.
- Pull-to-refresh using RefreshIndicator.
- Search activation in AppBar.

**File:** `lib/presentation/screens/add_expense_screen.dart`
- Form with GlobalKey<FormState>.
- Fields: Amount (TextFormField, numeric), Title (TextFormField), Category (horizontal ListView of CategoryChip), Date (InkWell + showDatePicker), Note (TextFormField).
- Validation: Amount > 0, Title not empty, Category selected.
- Save button calls provider.addExpense() then pops with success.
- Show SnackBar on success.

**File:** `lib/presentation/screens/analytics_screen.dart`
- Month selector at top.
- fl_chart PieChart showing category breakdown.
- ListView below chart with category rows (color dot, name, amount, percentage).
- Calculate percentages from total.
- Empty state if no data.

### 5.4 Widgets

**expense_list_item.dart**
- Leading: CircleAvatar with category icon and category color.
- Title: Expense title.
- Subtitle: Category name + formatted date.
- Trailing: Amount in coral/red color.
- Dismissible for swipe-to-delete with confirm dialog.

**category_chip.dart**
- ChoiceChip or custom container.
- Selected: filled with category color, white text.
- Unselected: outlined, gray text.
- Icon + label.

**summary_card.dart**
- Card with rounded corners (16px).
- Gradient background or solid primary color.
- Label text (small, white 70% opacity).
- Amount text (large, bold, white).

**category_pie_chart.dart**
- Uses fl_chart PieChart.
- Sections created from category totals.
- Colors from CategoryUtils.
- Center text: total amount.
- Tooltip on touch.

**empty_state.dart**
- Centered Column.
- Icon or illustration (Icons.account_balance_wallet_outlined, size 80, grey).
- Title: "No expenses yet".
- Subtitle: "Tap + to add your first expense".

**month_selector.dart**
- Row with IconButton (chevron_left), Text (formatted month year), IconButton (chevron_right).
- Tap text to open MonthPicker (optional).

---

## 6. Firebase Configuration

### Firestore Database
- Collection: `expenses`
- Document ID: Auto-generated by Firestore
- Fields:
  - `title`: string
  - `amount`: number (double)
  - `category`: string
  - `date`: timestamp
  - `note`: string (optional)
  - `createdAt`: timestamp (server timestamp)

### Firestore Security Rules (Development)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /expenses/{expenseId} {
      allow read, write: if true; // Open for demo/assignment
    }
  }
}
```
*Note: Replace with auth-based rules if adding authentication.*

### Firebase Setup Steps
1. Create Firebase project.
2. Add Android & iOS apps.
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).
4. Add Firebase Core and Cloud Firestore dependencies.
5. Initialize Firebase in `main.dart` before runApp.

---

## 7. Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^2.24.0
  cloud_firestore: ^4.14.0

  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0

  # Navigation
  go_router: ^13.0.0

  # Local Storage
  shared_preferences: ^2.2.0

  # Charts
  fl_chart: ^0.66.0

  # Utils
  intl: ^0.19.0
  uuid: ^4.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  riverpod_generator: ^2.3.0
  build_runner: ^2.4.0
  custom_lint: ^0.5.0
  riverpod_lint: ^2.3.0
```

---

## 8. Routing Configuration

**File:** `lib/config/router.dart`
```dart
final router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => ScaffoldWithNavBar(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/analytics', builder: (_, __) => const AnalyticsScreen()),
      ],
    ),
    GoRoute(
      path: '/add-expense',
      builder: (_, __) => const AddExpenseScreen(),
    ),
  ],
);
```

---

## 9. Theme Configuration

**File:** `lib/config/theme.dart`
- Define `lightTheme` and `darkTheme`.
- Use ColorScheme.fromSeed or manual color assignment.
- CardTheme: elevation 2, rounded 16px.
- InputDecorationTheme: rounded borders, focused border primary color.
- BottomNavTheme: selected primary, unselected grey.
- FABTheme: circular, primary color.

---

## 10. Constants & Configuration

**File:** `lib/config/constants.dart`
```dart
class AppConstants {
  static const List<Map<String, dynamic>> categories = [
    {'name': 'Food', 'icon': Icons.restaurant, 'color': Color(0xFFF59E0B)},
    {'name': 'Transport', 'icon': Icons.directions_car, 'color': Color(0xFF3B82F6)},
    {'name': 'Shopping', 'icon': Icons.shopping_bag, 'color': Color(0xFFEC4899)},
    {'name': 'Bills', 'icon': Icons.electric_bolt, 'color': Color(0xFF8B5CF6)},
    {'name': 'Entertainment', 'icon': Icons.movie, 'color': Color(0xFFF97316)},
    {'name': 'Health', 'icon': Icons.favorite, 'color': Color(0xFFEF4444)},
    {'name': 'Others', 'icon': Icons.category, 'color': Color(0xFF6B7280)},
  ];
}
```

---

## 11. Utilities

**File:** `lib/utils/date_formatter.dart`
- `formatMonthYear(DateTime date)` → "May 2025"
- `formatDate(DateTime date)` → "May 3, 2025"
- `isSameDay(DateTime a, DateTime b)` → bool
- `getMonthStart(DateTime date)` → DateTime
- `getMonthEnd(DateTime date)` → DateTime

**File:** `lib/utils/category_utils.dart`
- `getCategoryColor(String category)` → Color
- `getCategoryIcon(String category)` → IconData
- `getCategoryEmoji(String category)` → String (optional)

---

## 12. Bonus Features Implementation

### Pull-to-Refresh
Wrap the transaction list with `RefreshIndicator` and call `ref.invalidate(expenseListProvider)` on refresh.

### Search/Filter
- Add `searchQueryProvider` (StateProvider<String>).
- In HomeScreen, filter the expense list where title contains query (case-insensitive).
- Show search TextField in AppBar when search icon tapped.

### Dark Mode
- Add `themeModeProvider` reading from SharedPreferences.
- Toggle in settings (optional simple switch in AppBar popup menu).
- MaterialApp uses `themeMode: ref.watch(themeModeProvider)`.

---

## 13. Implementation Order (Day by Day)

| Day | Tasks |
|-----|-------|
| **Day 1** | `flutter create`, add dependencies, Firebase setup, folder structure, constants, theme, router config |
| **Day 2** | Domain layer (Entity, Repository interface), Data layer (Model, RepositoryImpl), Firebase connection test |
| **Day 3** | Riverpod providers, HomeScreen UI (summary cards, recent list, empty state), MonthSelector widget |
| **Day 4** | AddExpenseScreen (form, validation, date picker, category chips), Add expense flow end-to-end |
| **Day 5** | AnalyticsScreen (fl_chart pie chart, category list, month filter), chart animations |
| **Day 6** | Polish: swipe-to-delete, pull-to-refresh, search/filter, dark mode, error states, loading states |
| **Day 7** | Testing (Android + iOS), bug fixes, code review, performance check, prepare demo |

---

## 14. Coding Conventions

- Use `const` constructors everywhere possible.
- Prefer `StatelessWidget` / `ConsumerWidget` unless local state needed.
- Separate business logic from UI. No Firebase calls in widgets.
- Use `AsyncValue` pattern for all Riverpod async states (`.when(data, loading, error)`).
- Format amounts with `NumberFormat.currency(symbol: '৳')`.
- All strings in widgets (no hardcoding in multiple places).
- File naming: snake_case. Class naming: PascalCase.
- One widget per file in `widgets/` and `screens/`.

---

## 15. Testing Checklist

- [ ] Add expense appears immediately in list
- [ ] Month navigation shows correct data
- [ ] Delete expense removes from list and updates totals
- [ ] Chart updates when month changes
- [ ] Empty state shows when no data
- [ ] Form validation prevents empty/invalid submission
- [ ] Date picker selects correct date
- [ ] Pull-to-refresh works
- [ ] Search filters correctly
- [ ] Dark mode toggles properly
- [ ] No overflow on small screens (test with smallest device)
- [ ] App runs on both Android and iOS

---

## 16. Submission Notes

This is a job assignment. Code quality matters more than feature count.

**What evaluators will look for:**
- Clean, readable code structure
- Proper separation of concerns
- Error handling (Firestore failures, empty states)
- UI polish and attention to detail
- Modern Flutter patterns (Riverpod, GoRouter)
- Working Firebase integration

**Git Commit Strategy:**
- `feat: project setup and firebase config`
- `feat: domain and data layer implementation`
- `feat: home screen with expense list`
- `feat: add expense screen and form`
- `feat: analytics screen with charts`
- `feat: search, dark mode, and polish`
- `fix: bug fixes and final testing`
