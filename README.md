# Is My Fit Cooked? 🔥

**Is My Fit Cooked** is an elite, AI-powered outfit analysis and wardrobe management application built with Flutter. Designed for fashion enthusiasts, it leverages state-of-the-art Generative AI to analyze your fits, provide style feedback, and generate curated looks straight from your digital closet.

---

## 🌟 Key Features

*   **AI Fit Check:** Snap a photo or upload an image and get instant, brutally honest (and helpful) feedback on your outfit from Gemini 2.5 Flash.
*   **Digital Closet:** Store and organize your clothing items locally. Add items via camera, gallery, or direct store link imports.
*   **Smart Outfit Generation:** Automatically curate fresh looks and outfit combinations based on the contents of your digital wardrobe.
*   **Curated Explore Feed:** Discover trending fashion deals and brand spotlights in a beautifully designed, glassmorphic UI.

---

## 🏗️ Technical Architecture & Engineering

This project is engineered to strict, senior-level industry standards.

### 1. Clean, Feature-Driven Architecture
The codebase abandons the legacy "god-class" monoliths and is structured around a scalable, feature-first paradigm.
*   **`lib/core/`**: Centralized themes, design tokens, configuration constants, and global services.
*   **`lib/features/`**: Domain-driven modules (`closet`, `explore`, `fit_check`), each encapsulating their own `presentation/`, `domain/`, and `providers/`.

### 2. Modern State Management
*   Driven entirely by **Riverpod 2.0+** using the modern `Notifier` and `NotifierProvider` patterns.
*   Business logic is strictly decoupled from the UI. Screens are pure, declarative `ConsumerWidget`s with zero mutable state.
*   Immutable domain models configured with full `@immutable` safety and strict equality overrides.

### 3. Advanced Performance & Threading
*   **Isolate Offloading:** Heavy synchronous tasks—such as JSON serialization and Base64 image encoding—are offloaded to background threads using `compute()` to prevent main-thread jank.
*   **Disk Caching:** Optimized image rendering and network usage via `CachedNetworkImage`.
*   **Compile-Time Optimizations:** Comprehensive enforcement of `const` widget constructors across the entire widget tree to minimize garbage collection overhead.
*   **Zero Static Analysis Issues:** Codebase strictly conforms to `very_good_analysis` with 0 warnings or infos.

### 4. Security & GDPR Compliance
*   **Encrypted Storage:** Total deprecation of insecure `shared_preferences`. All persistent data is encrypted at rest using `flutter_secure_storage`.
*   **Secrets Injection:** API keys are never hardcoded. Keys must be injected securely at build time.
*   **Data Erasure:** Includes GDPR-compliant APIs to instantly purge local encrypted databases.

### 5. Accessibility (WCAG 2.1)
*   **Semantic Trees:** Deep integration of Flutter's `Semantics` widget for robust screen-reader support.
*   **Touch Targets:** All interactive zones conform to the WCAG 48×48 logical pixel minimum.

---

## 🚀 Setup & Installation

### Prerequisites
*   Flutter SDK (>=3.3.0)
*   Dart SDK (>=3.3.0 <4.0.0)
*   A Gemini API Key from Google AI Studio.

### Build Instructions

1.  **Clone the repository**
    ```bash
    git clone https://github.com/yourusername/is-my-fit-cooked.git
    cd is-my-fit-cooked/mobile_app
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run the App (Injecting Build Variables)**
    You **must** provide your Gemini API key via the `--dart-define` flag at build time. The app will fail to authenticate otherwise.
    ```bash
    flutter run --dart-define=GEMINI_API_KEY="your_api_key_here"
    ```

### Running Tests
Unit tests comprehensively cover domain model serialization, edge cases, and value-equality.
```bash
flutter test
```

---

## 🎨 Design Language
The UI adopts a highly polished, premium minimalist aesthetic:
*   **Glassmorphism:** Heavy use of dynamic blur filters (`BackdropFilter`) and subtle gradient borders (`Color(0x1AFFFFFF)`).
*   **Typography:** Modern web fonts via `google_fonts` combined with clean, monospaced accents.
*   **Color Palette:** A deeply atmospheric dark mode (`#111111` root background) with highly accessible, high-contrast text tokens.

---
*Developed with Flutter & Riverpod.*
