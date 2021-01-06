#!/bin/bash

#Push a squash of the current commits to the public repo and add corellating tags to both
#Expected to be in a repo with both the private and public repos as remotes using https

#intended to be called only by the deploy manifest

#Arguments
#1: tag to use
#2: https url of origin repo
#3: https url of the public repo

tempDir="tempCloneRepo"

mkdir $tempDir && cd $tempDir

#Checkout source into current directory
git clone --depth 1 $2 .

#Tag the private repo
git tag -f -a $1-private -m "Deploying $1"
git push -f origin $1-private

#Checkout dest
git remote add public $3
git fetch public
git reset --hard public/master

#replace everything with files from origin/master
git ls-files | xargs rm
rm -rf *
git checkout origin/master -- .
git add .
git commit -m "Deploying $1"

#Push to public
git push public

#Add correlative tag to public
git tag -f -a $1 -m "Deploying $1"
git push -f public $1

#Cleanup
cd ..
rm -rf $tempDir
