#!/bin/bash -eux
# ./docs/release.sh [patch|minor|major|x.y.z]

[[ $(basename "$PWD") == docs ]] && cd ..

OLD=$(sed -n '/version = /s/[^0-9.]//gp' pyproject.toml)
NEW="$1"
DATE=$(date +%Y-%m-%d)

sed -i "/version = /s/$OLD/$NEW/" pyproject.toml
sed -i "/^## \[Unreleased\]/a \\\n## [v$NEW] - $DATE" CHANGELOG.md
sed -i "/^\[Unreleased\]/s/$OLD/$NEW/" CHANGELOG.md
sed -i "/^\[Unreleased\]/a [v$NEW]: https://github.com/cmake-wheel/cmeel-example/compare/v$OLD...v$NEW" CHANGELOG.md

git add pyproject.toml CHANGELOG.md
git commit -m "Release v$NEW"
git tag -s "v$NEW" -m "Release v$NEW"
git push
git push --tags
