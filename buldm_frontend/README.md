# buldm_frontend

This project is a Flutter application designed for building a social media platform. It includes features for displaying posts, user profiles, and interactions.

## Project Structure

- **lib/**: Contains the main application code.
  - **features/**: Contains different features of the application.
    - **home/**: The home feature of the application.
      - **presentation/**: Contains the presentation layer of the home feature.
        - **view/**: Contains the view components.
          - **screens/**: Contains the screen widgets, including `PostWidget.dart`.

- **.github/workflows/**: Contains GitHub Actions workflows for CI/CD.
  - **ios-build.yml**: Workflow configuration for building the iOS IPA file.

- **pubspec.yaml**: The configuration file for the Flutter project, specifying dependencies and metadata.

## Getting Started

To get started with this project, ensure you have Flutter installed on your machine. Clone the repository and run the following commands:

```bash
flutter pub get
```

This will install the necessary dependencies.

## Building the iOS App

To build the iOS app, you can use the GitHub Actions workflow defined in `.github/workflows/ios-build.yml`. This workflow will automate the process of building the IPA file.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or features you would like to add.

## License

This project is licensed under the MIT License. See the LICENSE file for details.