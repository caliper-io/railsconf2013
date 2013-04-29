#!/bin/sh

git checkout master
git branch -D gh-pages
git checkout --orphan gh-pages
rm .gitignore
rm Gem*
rm Rakefile
rm Readme.md
rm deploy.sh
rm -r cached-download
rm -r lib
mv public/* .
rm -r public
git add .
git add -u .
git commit -m "Deploy version of the app"
git push -f origin gh-pages
