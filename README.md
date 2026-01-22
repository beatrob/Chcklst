# Checklist

A Swift app for creating, scheduling, and tracking checklists with rich templates, repeat schedules, and widget support. The app persists data with Core Data, initializes appearance and data on first launch, and uses PromiseKit for clear, composable async flows.

## Features
- Create and manage checklists based on reusable templates
- Schedule reminders with flexible repeat options (daily/weekly/custom days)
- Home Screen Widgets powered by WidgetKit
- Purchase support

## Architecture
- Swift + SwiftUI for the UI layer
- Core Data for persistence (NSManagedObject subclasses like `ScheduleMO`, `TemplateMO`, `RepeatFrequencyMO`)
- PromiseKit for async orchestration across initialization and data operations
- Combine for observable state and bindings
- WidgetKit integration for glanceable content

Key components:
- `InitializeAppViewModel`: Orchestrates app startup (appearance, data loads, schedule/template/checklist fetches, purchase restore). Publishes loading and error state.
- `ScheduleMO` (+ helpers): Core Data entity helpers for converting between managed objects and data models, fetching by ID, and building entities from data models.
- `ContentView`: Demonstrates various SwiftUI activity indicators for loading states using `ActivityIndicatorView`.

## Tech Stack
- Swift, SwiftUI, UIKit (select integrations)
- Core Data
- PromiseKit
- Combine
- WidgetKit

## Requirements
- Xcode 15+ (recommended Xcode 16/26 toolchain)
- iOS 15+ target (adjust as needed)

## Getting Started
1. Clone the repository:
   ```bash
   git clone https://github.com/your-org/checklist.git
   cd checklist
