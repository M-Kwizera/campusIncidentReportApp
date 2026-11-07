# Campus Incident Reporting App

A Flutter-based mobile application that enables students to report campus issues and track their resolution status.

## Features

- **User Authentication**: Secure login/register with Firebase Authentication
- **Incident Reporting**: Submit reports with descriptions, categories, and optional photos
- **Incident Tracking**: View all incidents, filter by category, search functionality
- **Status Updates**: Staff can update incident status from pending to resolved
- **Image Upload**: Attach photos to incident reports using Firebase Storage
- **Responsive UI**: Material Design 3 with smooth animations

## Technology Stack

- **Frontend**: Flutter (Dart)
- **State Management**: Provider Pattern
- **Backend**: Firebase Services
  - Authentication: Firebase Auth
  - Database: Cloud Firestore
  - Storage: Firebase Storage

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd campus_incident_reporting_app
```

2. Get Firebase configuration:
```bash
flutterfire configure
```

3. Run the app:
```bash
flutter run
```

## Screenshots

### Splash Screen
[Image will be included in PDF report]

### Authentication Screen
- Login form with email and password
- Registration form with name, email, and password
- Toggle between login and register modes

### Home Screen
- Tab navigation for Incidents, Report, and Staff Dashboard
- Bottom navigation bar for easy access to main features

### Incident List Screen
- Filter incidents by category dropdown
- Search functionality
- Refresh capability with pull-to-refresh
- Card-based layout with status indicators

### Report Screen
- Form for entering incident details
- Category selection dropdown
- Image attachment option
- Validation for required fields

### Staff Dashboard
- Tabbed interface for managing incidents
- View all, pending, and in-progress incidents
- Update status functionality
- Detailed incident view

## Data Structure

### Firestore Collections

1. **incidents**
```javascript
{
  id: "string",
  title: "string",
  description: "string",
  category: "Broken Facilities" | "Water Shortage" | "Electricity Outage" | "Damaged Furniture" | "Sanitation Problem" | "Safety Concern",
  createdAt: timestamp,
  submittedBy: "user_id",
  submittedByEmail: "email",
  images: ["image_urls"],
  status: "pending" | "in_progress" | "resolved" | "closed",
  priority: number
}
```

2. **users** (from Firebase Auth)
```javascript
{
  id: "user_id",
  email: "string",
  displayName: "string",
  role: "student" | "staff"
}
```

## Architecture

### Directory Structure
```
campus_incident_reporting_app/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   └── app_provider.dart
│   ├── models/
│   │   └── incident_model.dart
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── auth_screen.dart
│   │   ├── home_screen.dart
│   │   ├── incidents_list_screen.dart
│   │   ├── report_screen.dart
│   │   ├── incident_detail_screen.dart
│   │   └── staff_dashboard_screen.dart
│   └── services/
│       ├── auth_service.dart
│       └── firebase_service.dart
├── pubspec.yaml
└── README.md
```

## State Management

The application uses the Provider pattern for state management:

- **AppProvider**: Central state holder managing user authentication, incidents list, and UI state
- **ChangeNotifier**: Implemented using Flutter's ChangeNotifier pattern
- **Listen Pattern**: Widgets subscribe to state changes automatically

## Security Considerations

1. Firebase Authentication protects all routes
2. Role-based access control (students vs staff)
3. Input validation on forms
4. Secure image uploads with signed URLs
5. Firestore security rules prevent unauthorized access

## Future Enhancements

- Push notifications for status updates
- Geolocation tagging for incidents
- Category-specific templates
- Analytics dashboard
- Multi-language support
- Offline mode with local storage

## License

This project is for educational purposes only.

---

*For the complete technical report including architecture diagrams, detailed testing strategy, and lessons learned, please refer to the PDF document.*