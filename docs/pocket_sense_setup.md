# Pocket Sense Setup

Developer: Abu Nabil Md. Masrur  
Institution: Bangladesh Army University of Science and Technology (BAUST)  
ID: 0802410405101077

## Directory Structure

```text
lib/
  core/
    budget_engine.dart
    health_score.dart
    prediction_engine.dart
  models/
    debt_entry.dart
    expense.dart
    goal.dart
    nlp_expense_result.dart
  providers/
    expense_provider.dart
  screens/
    login_screen.dart
    signup_screen.dart
    main_screen.dart
    stats_screen.dart
    voice_entry_screen.dart
    loans_screen.dart
    settings_screen.dart
  services/
    auth_service.dart
    firestore_service.dart
    gemini_service.dart
    notification_service.dart
  widgets/
    auth_widgets.dart
```

## Firebase Schema

```text
users/{uid}
  uid: string
  email: string
  displayName: string
  currency: "BDT"
  createdAt: timestamp

users/{uid}/expenses/{expenseId}
  title: string
  amount: number
  category: "Food & Drink" | "Transport" | "Shopping" | "Bills" | "Others"
  date: timestamp

users/{uid}/debts/{debtId}
  person: string
  amount: number
  note: string
  theyOweMe: boolean
  settled: boolean
  date: timestamp

users/{uid}/goals/{goalId}
  name: string
  targetAmount: number
  savedAmount: number
```

## Core Logic

Dynamic daily limit:

```text
remainingBudget = monthlyBudget - spentThisMonth
remainingDays = daysInMonth - today + 1
dynamicDailyLimit = remainingBudget / remainingDays
```

Health score:

```text
dailyScore = 100 - ((todaySpent / dynamicDailyLimit) * 42)
monthlyScore = 100 - ((monthSpent / monthlyBudget) * 48)
score = dailyScore * 0.50 + monthlyScore * 0.42 + consistencyBonus
```

Predictive spending:

```text
predictedMonthlyBill = average(lastThreeMonthTotals) * 1.06
```

## Gemini API

Run with a Gemini key:

```powershell
flutter run --dart-define=GEMINI_API_KEY=YOUR_KEY
```

Without a key, the app uses an offline Bangla parser fallback.

## Android Firebase Config

Place Firebase config here:

```text
android/app/google-services.json
```

The app is safe without this file and runs in local fallback mode.

## Verification

```text
flutter analyze
flutter build apk --debug
```
