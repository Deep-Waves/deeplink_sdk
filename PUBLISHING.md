# Publishing DeepLink SDK to pub.dev

## Prerequisites

Before publishing, ensure you have:

1. A pub.dev account
2. Verified your email on pub.dev
3. Authenticated with pub.dev using `dart pub login`

## Pre-Publishing Checklist

✅ Package passes all tests (`flutter test`)
✅ No analysis issues (`flutter analyze`)
✅ Dry-run successful (`dart pub publish --dry-run`)
✅ README.md is comprehensive
✅ CHANGELOG.md documents the release
✅ LICENSE file is present
✅ Example app is functional
✅ Documentation is complete

## Publishing Steps

### 1. Authenticate with pub.dev (if not already done)

```bash
dart pub login
```

This will open a browser window for authentication.

### 2. Publish the Package

```bash
dart pub publish
```

When prompted, type 'y' to confirm publishing.

### 3. Verify Publication

After publishing, your package will be available at:
https://pub.dev/packages/deeplink_sdk

## Post-Publishing

### Create GitHub Repository

1. Create a new repository at https://github.com/sanketjariwala/deeplink_sdk
2. Push the code:

```bash
git init
git add .
git commit -m "Initial release of DeepLink SDK v1.0.0"
git branch -M main
git remote add origin https://github.com/sanketjariwala/deeplink_sdk.git
git push -u origin main
```

3. Create a release tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

### Update Package Score

To improve your pub.dev score:

1. Add CI/CD with GitHub Actions
2. Ensure 100% platform support
3. Add more comprehensive examples
4. Maintain good documentation
5. Respond to issues promptly

## Important Notes

⚠️ **Package Name**: The package name `deeplink_sdk` must be unique on pub.dev. If it's already taken, you'll need to choose a different name.

⚠️ **Version**: Once published, you cannot unpublish or overwrite a version. Always increment the version for updates.

⚠️ **Ownership**: The first person to publish becomes the package owner. You can add additional uploaders later.

## Troubleshooting

If you encounter issues:

1. **Name already taken**: Choose a different package name in pubspec.yaml
2. **Authentication failed**: Run `dart pub logout` then `dart pub login`
3. **Validation errors**: Fix any issues shown in the dry-run output

## Future Updates

To publish updates:

1. Update version in `pubspec.yaml`
2. Update `CHANGELOG.md`
3. Run tests and analysis
4. Publish with `dart pub publish`

## Support

For package-specific issues, users can report them at:
https://github.com/sanketjariwala/deeplink_sdk/issues
