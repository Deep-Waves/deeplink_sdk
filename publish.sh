#!/bin/bash

echo "🚀 DeepLink SDK Publishing Script"
echo "================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if all tests pass
echo "🧪 Running tests..."
if flutter test; then
    echo -e "${GREEN}✅ All tests passed${NC}"
else
    echo -e "${RED}❌ Tests failed. Please fix before publishing.${NC}"
    exit 1
fi

# Check for analysis issues
echo ""
echo "🔍 Analyzing code..."
if flutter analyze; then
    echo -e "${GREEN}✅ No analysis issues${NC}"
else
    echo -e "${RED}❌ Analysis issues found. Please fix before publishing.${NC}"
    exit 1
fi

# Run dry-run
echo ""
echo "📦 Running publish dry-run..."
if dart pub publish --dry-run; then
    echo -e "${GREEN}✅ Dry-run successful${NC}"
else
    echo -e "${RED}❌ Dry-run failed. Please fix issues before publishing.${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}⚠️  IMPORTANT: Before publishing, ensure you have:${NC}"
echo "   1. Authenticated with pub.dev (run: dart pub login)"
echo "   2. Verified the package name 'deeplink_sdk' is available"
echo "   3. Reviewed all files that will be published"
echo ""
echo -e "${YELLOW}The package will be published as:${NC}"
echo "   Name: deeplink_sdk"
echo "   Version: 1.0.0"
echo "   Size: ~20 KB"
echo ""

read -p "Do you want to proceed with publishing? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🚀 Publishing package..."
    dart pub publish
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}🎉 Package published successfully!${NC}"
        echo "View your package at: https://pub.dev/packages/deeplink_sdk"
        echo ""
        echo "Next steps:"
        echo "1. Create GitHub repository: https://github.com/sanketJariwala9464/deeplink_sdk.git"
        echo "2. Push code to GitHub"
        echo "3. Create a release tag (v1.0.0)"
        echo "4. Monitor package score on pub.dev"
    else
        echo -e "${RED}❌ Publishing failed. Please check the error messages above.${NC}"
    fi
else
    echo "Publishing cancelled."
fi
