r# 🎨 QuizSnap Design System

The QuizSnap design system is built around **mild neo-brutalism** principles: bold borders, flat surfaces, high contrast, and functional aesthetics. Everything is driven by design tokens from `design.json`.

## 🎯 Design Philosophy

- **Bold & Direct**: Thick borders, high contrast, clear hierarchy
- **Functional First**: Every element serves a purpose
- **Consistent**: Unified spacing, typography, and color usage
- **Accessible**: High contrast ratios and clear touch targets

---

## 🎨 Colors & Theming

QuizSnap supports both light and dark themes with automatic switching. Colors are loaded from `design.json` and adapted for both modes.

### Theme Color Access
```dart
// Get colors from theme (recommended)
final theme = Theme.of(context);
final primaryColor = theme.colorScheme.primary;
final surfaceColor = theme.colorScheme.surface;
final textColor = theme.colorScheme.onSurface;
```

### Design Token Colors
From `design.json`:
```json
{
  "primary": "rgb(104, 85, 230)",        // Purple - main brand color
  "secondary": "rgb(187, 198, 239)",     // Light purple - secondary actions
  "accent": "rgb(169, 184, 157)",        // Sage green - highlights
  "background": "rgb(250, 250, 250)",    // Light gray - app background
  "card": "rgb(255, 255, 255)",          // White - content surfaces
  "destructive": "rgb(199, 83, 60)"      // Red - errors and warnings
}
```

### Dark Theme Colors
Dark mode uses carefully selected colors that maintain neo-brutal aesthetics:
```dart
// Dark theme color scheme
- Background: #121212 (dark charcoal)
- Surface: #1F1F1F (card backgrounds) 
- Cards: #2A2A2A (elevated surfaces)
- Text: #E5E5E5 (light gray)
- Borders: #404040 (muted borders)
- Primary: Same purple for consistency
```

### Theme Management
```dart
// Access current theme
final theme = Theme.of(context);
final isDark = theme.brightness == Brightness.dark;

// Using Riverpod theme provider
final isDarkMode = ref.watch(themeProvider);
ref.read(themeProvider.notifier).toggleTheme();

// Check theme persistence
final savedTheme = await ThemePersistence.loadThemeMode();
```

### Static Fallbacks (AppColors)
For rare cases when theme isn't available:
```dart
import 'package:quizsnap/core/constants/colors.dart';

AppColors.primary     // Purple fallback
AppColors.background  // Light gray fallback
AppColors.foreground  // Dark gray fallback
AppColors.card        // White fallback
```

---

## 📝 Typography

Typography uses **Montserrat** as the primary font via Google Fonts, with automatic theme integration.

### Text Styles Usage
```dart
final theme = Theme.of(context);

// Headlines (bold, prominent)
Text('QuizSnap', style: theme.textTheme.headlineLarge)   // 32sp, w800
Text('Welcome', style: theme.textTheme.headlineMedium)   // 28sp, w800

// Titles (section headers)
Text('Sign In', style: theme.textTheme.titleLarge)       // 22sp, w700

// Body text (readable content)
Text('Description', style: theme.textTheme.bodyLarge)    // 16sp, normal
Text('Helper text', style: theme.textTheme.bodyMedium)   // 14sp, normal
```

### Font Family Access
```dart
// Montserrat (default - already applied to textTheme)
GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600)

// Playfair Display (serif - for special occasions)
GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold)

// Source Code Pro (monospace - for code/data)
GoogleFonts.sourceCodePro(fontSize: 14)
```

---

## 🏗️ Layout & Spacing

### Responsive Foundation
QuizSnap uses `flutter_screenutil` for responsive design:
```dart
// In main.dart - already configured
ScreenUtilInit(
  designSize: const Size(390, 844), // iPhone 14 Pro baseline
  // Your widgets here
)

// Usage in widgets (when needed for precise responsive design)
Container(
  width: 100.w,     // 100 logical pixels
  height: 50.h,     // 50 logical pixels
  fontSize: 16.sp,  // 16 logical pixels font size
)
```

### Standard Spacing Scale
Use these consistent spacing values:
```dart
// Extra small
const EdgeInsets.all(4)

// Small
const EdgeInsets.all(8)

// Medium (default for most content)
const EdgeInsets.all(16)

// Large
const EdgeInsets.all(24)

// Extra large
const EdgeInsets.all(32)

// Page padding
const EdgeInsets.all(24)  // Standard screen margins
```

---

## 🧩 Components

### BrutCard
The foundation component for content containers.

```dart
import 'package:quizsnap/core/widgets/brut_card.dart';

// Basic usage
BrutCard(
  child: Text('Card content'),
)

// With custom spacing
BrutCard(
  padding: EdgeInsets.all(20),
  margin: EdgeInsets.symmetric(horizontal: 16),
  child: Column(children: [...]),
)
```

**Features:**
- 2px border with theme divider color
- 8px border radius
- Subtle drop shadow
- Surface color background

### PrimaryButton
Main action button with neo-brutal styling.

```dart
import 'package:quizsnap/core/widgets/primary_button.dart';

// Basic usage
PrimaryButton(
  label: 'Sign In',
  onPressed: () => handleSignIn(),
)

// Disabled state
PrimaryButton(
  label: 'Loading...',
  onPressed: null, // Disables the button
)
```

**Features:**
- Primary color background
- White text
- 2px border, no elevation
- 20px horizontal, 14px vertical padding

### AppTextField
Consistent text input field.

```dart
import 'package:quizsnap/core/widgets/app_text_field.dart';

// Basic usage
AppTextField(
  hint: 'Enter your email',
  controller: _emailController,
)

// Password field
AppTextField(
  hint: 'Password',
  controller: _passwordController,
  obscureText: true,
  keyboardType: TextInputType.visiblePassword,
)

// With validation
AppTextField(
  hint: 'Email',
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value?.isEmpty ?? true) return 'Email required';
    return null;
  },
)
```

**Features:**
- Theme-driven styling (borders, colors, padding)
- Built-in form validation support
- Keyboard type optimization
- Accessibility support

### BrutBottomNav
Neo-brutal bottom navigation bar for main app navigation.

```dart
import 'package:quizsnap/core/widgets/brut_bottom_nav.dart';

// Direct usage (manual integration)
BrutBottomNav(
  currentRoute: '/home',
  onTap: (route) => Navigator.pushNamed(context, route),
)
```

**Features:**
- 5 navigation items: Home, Upload, Solo, Multiplayer, Profile
- Bold top border (2px)
- Active/inactive state styling
- Route-aware highlighting
- Icon + label layout

### ScaffoldWithNav
Scaffold wrapper that automatically includes bottom navigation and optional sidebar.

```dart
import 'package:quizsnap/core/widgets/scaffold_with_nav.dart';

// Basic usage for main app screens
ScaffoldWithNav(
  currentRoute: AppRoutes.home,
  appBar: AppBar(title: Text('Home')),
  body: YourContent(),
)

// With sidebar drawer (recommended for home screen)
ScaffoldWithNav(
  currentRoute: AppRoutes.home,
  hasDrawer: true,
  appBar: AppBar(title: Text('QuizSnap')),
  body: YourContent(),
)
```

**Features:**
- Automatic bottom navigation integration
- Optional sidebar drawer for enhanced navigation
- Route-aware navigation highlighting
- Smooth page transitions
- Prevents navigation to current route
- Consistent scaffold structure

### AppDrawer
Sidebar navigation drawer with comprehensive app features.

```dart
import 'package:quizsnap/core/widgets/app_drawer.dart';

// Usually used automatically via ScaffoldWithNav
Drawer(
  child: AppDrawer(currentRoute: currentRoute),
)
```

**Features:**
- User profile header with avatar
- Main navigation shortcuts
- Future features preview (History, Saved, Stats)
- Settings and help links
- Sign out functionality
- Route-aware highlighting

### ThemeToggle
Animated toggle button for switching between light and dark themes.

```dart
import 'package:quizsnap/core/widgets/theme_toggle.dart';

// Usually placed in app bar actions
AppBar(
  title: Text('QuizSnap'),
  actions: [
    Padding(
      padding: EdgeInsets.only(right: 8),
      child: ThemeToggle(),
    ),
  ],
)
```

**Features:**
- Smooth icon transition animation
- Persistent theme preference storage
- Neo-brutal border styling
- Riverpod state management
- Automatic app-wide theme switching

---

---

## 🎯 Navigation System

QuizSnap uses a dual navigation approach for optimal user experience:

### Bottom Navigation
- **Primary navigation** for main app sections
- Always visible for quick access
- 5 core areas: Home, Upload, Solo, Multiplayer, Profile
- Neo-brutal styling with route highlighting

### Sidebar Drawer
- **Secondary navigation** for additional features
- Accessed via hamburger menu (currently only on Home)
- User profile, settings, and future features
- Coming soon: History, Saved Questions, Statistics

### Smooth Transitions
- **Custom page routes** for main app screens
- Subtle slide + fade animations (300ms)
- Maintains navigation state
- Prevents jarring transitions

### Implementation Example:
```dart
// Home screen with full navigation
ScaffoldWithNav(
  currentRoute: AppRoutes.home,
  hasDrawer: true, // Enables sidebar
  appBar: AppBar(title: Text('QuizSnap')),
  body: YourContent(),
)

// Other main screens
ScaffoldWithNav(
  currentRoute: AppRoutes.upload,
  appBar: AppBar(title: Text('Upload')),
  body: YourContent(),
)
```

---

## 📦 Component Import Patterns

### Option 1: Barrel Import (Recommended)
```dart
import 'package:quizsnap/core/widgets/index.dart';

// All widgets available
BrutCard(child: ...)
PrimaryButton(label: '...', onPressed: ...)
AppTextField(hint: '...')
```

### Option 2: Individual Imports
```dart
import 'package:quizsnap/core/widgets/brut_card.dart';
import 'package:quizsnap/core/widgets/primary_button.dart';

// Only imported widgets available
BrutCard(child: ...)
PrimaryButton(label: '...', onPressed: ...)
```

### Option 3: Legacy Import (Backward Compatibility)
```dart
import 'package:quizsnap/core/widgets/brut_widgets.dart';

// Works but deprecated - use barrel import instead
```

---

## 🎨 Design Token System

### How It Works
1. **Source**: `design.json` contains all design tokens
2. **Loading**: `ThemeLoader` parses tokens at app startup
3. **Application**: Tokens become Flutter `ThemeData`
4. **Usage**: Access via `Theme.of(context)`

### Token Categories
```json
{
  "color": { ... },      // Color palette
  "font": { ... },       // Font families
  "radius": { ... },     // Border radius values
  "shadow": { ... }      // Box shadow definitions
}
```

### Adding New Tokens
1. Add to `design.json`
2. Update `ThemeLoader.buildTheme()` if needed
3. Restart app to reload tokens

---

## 🔧 Development Guidelines

### Component Creation
When creating new components:

1. **Follow naming**: `AppComponentName` or `BrutComponentName`
2. **Document thoroughly**: Include usage examples
3. **Use theme colors**: Never hardcode colors
4. **Responsive by default**: Consider different screen sizes
5. **Accessible**: Include semantic labels and proper contrast

### Example Component Template
```dart
import 'package:flutter/material.dart';

/// Brief description of what this component does.
/// 
/// **Usage:**
/// ```dart
/// MyComponent(
///   title: 'Example',
///   onTap: () => print('tapped'),
/// )
/// ```
/// 
/// **Styling:**
/// - Describe visual appearance
/// - List key style properties
/// 
/// **Behavior:**
/// - Describe interactions
/// - List accessibility features
class MyComponent extends StatelessWidget {
  /// Description of this property
  final String title;
  
  /// Description of this callback
  final VoidCallback? onTap;

  const MyComponent({
    super.key,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      // Implementation using theme colors and consistent spacing
      child: Text(title, style: theme.textTheme.titleMedium),
    );
  }
}
```

### Testing Design System
```dart
// Test that components respond to theme changes
// Test accessibility features
// Test responsive behavior
// Test keyboard navigation
```

---

## 📱 Platform Considerations

### iOS
- Maintains neo-brutal aesthetic
- Respects iOS accessibility settings
- Safe area handling automatic

### Android
- Material 3 base with custom theming
- Respects Android accessibility settings
- Navigation bar handling automatic

### Web
- Keyboard navigation support
- Responsive breakpoints
- Touch and mouse interaction support

---

## 🚀 Quick Start Checklist

- [ ] Import design system: `import 'package:quizsnap/core/widgets/index.dart';`
- [ ] Use theme colors: `Theme.of(context).colorScheme.primary`
- [ ] Apply consistent spacing: `EdgeInsets.all(16)`
- [ ] Use standard text styles: `theme.textTheme.headlineMedium`
- [ ] Build with BrutCard containers
- [ ] Use PrimaryButton for actions
- [ ] Use AppTextField for inputs
- [ ] Test on different screen sizes
- [ ] Verify accessibility with screen readers

---
