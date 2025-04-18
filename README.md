# QrSnapr

Turn QR code images into urls _On your computer!_

## Code

Its a simple swift ui menu app that uses the following dependencies: - [Keyboard Shortcuts](https://github.com/sindresorhus/KeyboardShortcuts)

## Building with GitHub Actions

This project includes a GitHub Actions workflow that automatically builds the app without requiring an Apple Developer account:

1. The workflow builds on every push to the main branch and pull requests
2. It can also be manually triggered using the workflow_dispatch event
3. The workflow produces two artifacts:
   - QrSnapr-App: The .app bundle
   - QrSnapr-DMG: A disk image containing the app

### Creating a Release

To create a GitHub release with the app:

1. Tag your commit: `git tag v1.0.1`
2. Push the tag: `git push origin v1.0.1`
3. The workflow will automatically create a release with the DMG file attached

### Downloading the Latest Build

1. Go to your repository on GitHub
2. Click on the "Actions" tab
3. Select the latest workflow run
4. Scroll down to "Artifacts" to download the app or DMG

## License

Please follow the AGPLv3 license.
