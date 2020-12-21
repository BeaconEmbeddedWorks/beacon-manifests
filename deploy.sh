#!/bin/bash

#Push the modified manifest to the public manifest repo
#Expected to be in a repo with both the private and public manifest repos as remotes
#git clone https://github.com/BeaconEmbeddedWorks/beacon-manifests-private.git
#git remote add public https://github.com/BeaconEmbeddedWorks/beacon-manifests.git

srcBranch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
destBranch=$(git branch | sed -n -e 's/^\* \(.*\)-.*/\1/p')
tag=$(git tag --points-at HEAD | grep -v '\-RC')
#debug 
echo $srcBranch $destBranch $tag

#check if branch exists, or start from main
git ls-remote --heads public $destBranch | wc -l
if [ $? == "1" ]
then
	echo branch exists
	git checkout --track public/$destBranch
else
	echo branch does not exist - starting from main
	git checkout -B $destBranch public/main
fi

git checkout origin/$srcBranch -- imx8mm-4.19.xml

#Edit manifest xml in place preserving formatting
#Delete any remotes named 'third'
#Delete any projects using the renote named 'third'
#Remove the '-private' suffix from project repo names
#Remove the '-RCx' suffix from project revisions
#File to modify - could be parameterized

xmlstarlet ed --inplace --pf \
	-d "/manifest/remote[@name='third']" \
	-d "/manifest/project[@remote='third']" \
	-u "/manifest/project[contains(@name,'-private')]/@name" -x "substring-before(., '-private')" \
	-u "/manifest/project[contains(@revision,'-RC')]/@revision" -x "substring-before(., '-RC')" \
	imx8mm-4.19.xml

git add imx8mm-4.19.xml

git commit -m "Deploying manifest for $tag"
git tag -f -a $tag -m "Deploying manifest for $tag"
git push -u public HEAD
git push -f public $tag
git checkout -
