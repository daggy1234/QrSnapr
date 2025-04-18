# QrSnapr

Turn QR code images into urls _On your computer!_

## Code

Its a simple swift ui menu app that uses the following dependencies: - [Keyboard Shortcuts](https://github.com/sindresorhus/KeyboardShortcuts)

## Building with GitHub Actions

This project includes GitHub Actions workflows that automatically build the app without requiring an Apple Developer account:

### Simple Unsigned Build (`macos-build-unsigned.yml`)

This workflow creates a simple unsigned build of the app:

1. Creates a copy of the Xcode project with code signing disabled
2. Builds the app with code signing explicitly disabled
3. Packages the app as both a zip archive and DMG file
4. Uploads both artifacts to GitHub Actions
5. Creates a GitHub Release when tags are pushed

### Running the Workflow

The workflow runs on:
- Every push to the main branch
- Pull requests to main
- Manual triggering through the GitHub UI

### Creating a Release

To create a GitHub release with the app:

1. Tag your commit: `git tag v1.0.1`
2. Push the tag: `git push origin v1.0.1`
3. The workflow will automatically create a release with both zip and DMG files attached

### Downloading the Latest Build

1. Go to your repository on GitHub
2. Click on the "Actions" tab
3. Select the latest workflow run
4. Scroll down to "Artifacts" to download the app or DMG

### Using the Unsigned App

Since the app is not signed or notarized, macOS Gatekeeper will block it by default. To open it:

1. Right-click (or Control-click) on the app
2. Select "Open" from the context menu
3. Click "Open" in the security dialog that appears

You only need to do this the first time you open the app.

## License

Please follow the AGPLv3 license.
