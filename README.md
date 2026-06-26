# Is My Fit Cooked?

**Is My Fit Cooked** is an AI-driven outfit analysis and wardrobe management platform. Developed using Flutter, the application employs state-of-the-art Generative AI models to perform real-time outfit analysis, offer objective stylistic feedback, and automatically curate looks utilizing digital wardrobe metadata.

## Table of Contents
- [Architecture & System Overview](#architecture--system-overview)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Testing](#testing)
- [Contributing & Code of Conduct](#contributing--code-of-conduct)
- [License](#license)

## Architecture & System Overview

The application is structured around a scalable, domain-driven design paradigm, ensuring high maintainability and performance.

### Core Modules
* **`lib/core/`**: Contains centralized design tokens, global configuration constants, cryptographic services, and foundational application utilities.
* **`lib/features/`**: Encapsulates specific functional domains (`closet`, `explore`, `fit_check`). Each module is isolated, implementing its own `presentation/`, `domain/`, and `providers/` directories.

### System Design and Data Flow
* **State Management**: The application state is strictly managed via Riverpod 2.0+ utilizing the `Notifier` and `NotifierProvider` architecture. The presentation layer exclusively consists of declarative `ConsumerWidget` instances, entirely decoupled from business logic and ensuring zero mutable state within the UI.
* **Storage and Asset Pipeline**: To mitigate token constraints and API latency, image payloads are locally compressed utilizing `flutter_image_compress` and asynchronously offloaded to Cloudflare R2 object storage. Analytical models receive lightweight public URLs rather than raw Base64 data.
* **Dynamic AI Routing**: Integration with OpenRouter facilitates automated fallback routing between large language models (e.g., `gpt-oss-120b:free` and `qwen3-coder:free`), ensuring fault tolerance during periods of rate limiting.
* **Thread Offloading**: Intensive tasks such as JSON serialization and asset compression are delegated to background isolates utilizing `compute()`, ensuring uninterrupted 60fps UI performance.
* **Security Subsystem**: Direct device persistence is handled via `flutter_secure_storage` to ensure all data is encrypted at rest. API credentials are injected strictly at build time and excluded from source control.

## Prerequisites

Ensure the following software dependencies are installed and properly configured within the execution environment:
* **Flutter SDK**: version `>=3.3.0`
* **Dart SDK**: version `>=3.3.0 <4.0.0`
* **Object Storage**: A configured Cloudflare R2 bucket (or S3-compatible alternative) for image offloading.
* **AI Provider Credentials**: An API key from an OpenAI-compatible interface provider (e.g., OpenRouter, Together AI, Groq).

## Installation

Execute the following commands to provision the local environment and acquire the necessary dependencies.

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/is-my-fit-cooked.git
   cd is-my-fit-cooked/mobile_app
   ```

2. **Acquire dependencies:**
   ```bash
   flutter pub get
   ```

## Usage

The application requires runtime configuration injection. Do not hardcode sensitive variables. Provide the requisite environment parameters using the `--dart-define` flag at compile/run time.

```bash
flutter run \
  --dart-define=AI_API_KEY="your_openrouter_key" \
  --dart-define=R2_ACCOUNT_ID="your_cloudflare_account_id" \
  --dart-define=R2_ACCESS_KEY="your_r2_access_key" \
  --dart-define=R2_SECRET_KEY="your_r2_secret_key" \
  --dart-define=R2_BUCKET_NAME="your_bucket_name" \
  --dart-define=R2_PUBLIC_URL="https://cdn.yourdomain.com"
```

## Testing

The project implements a comprehensive unit testing suite targeting domain model serialization, logic branches, and value-equality contracts. Execute the test suite utilizing the standard Flutter testing framework.

```bash
flutter test
```

## Contributing & Code of Conduct

Contributions to the codebase must adhere strictly to established architectural patterns and static analysis configurations (`very_good_analysis`).

### Pull Request Process
1. Fork the repository and create a feature branch (`git checkout -b feature/your-feature`).
2. Ensure the code compiles cleanly and introduces zero static analysis warnings.
3. Validate changes against existing tests and implement new tests for any added logic.
4. Submit a Pull Request detailing the scope, motivation, and technical implementation of the proposed changes.

### Code of Conduct
All contributors are expected to maintain professional discourse and participate constructively. Harassment or unprofessional conduct will not be tolerated. Review our full Code of Conduct before engaging in project discussions or contributions.

## License

This project is proprietary and confidential. All rights reserved.
