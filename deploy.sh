#!/bin/bash

usage="Usage: ./deploy.sh <tag name to release> <manifest file>"

#Push the modified manifest to the public manifest repo and tags boths repos with the tag
# provided in the first argument

#IMPORTANT
#expecting to be run on products *-master branch and the script determines the destination
#branch by dropping -master. See the README.md in the beacon-manifests-private master branch 
#for more information.

#Expected to be in a repo with both the private and public manifest repos as remotes
#git clone https://github.com/BeaconEmbeddedWorks/beacon-manifests-private.git
#git remote add public https://github.com/BeaconEmbeddedWorks/beacon-manifests.git

DEBUG=${DEBUG:-0}

dprint() {
        if [ $DEBUG -eq 1 ] ; then
                echo $*
        fi
}

#confirm remotes
originUrl=$(git config --get remote.origin.url)
publicUrl=$(git config --get remote.public.url)
if [ "$originUrl" != "https://github.com/BeaconEmbeddedWorks/beacon-manifests-private.git" ]
then
	echo Remote 'origin' did not match expectef
	exit 1
else
	git fetch public
fi
if [ "$publicUrl" != "https://github.com/BeaconEmbeddedWorks/beacon-manifests.git" ]
then
	echo Remote 'public' did not match expected
	exit 1
else
	git fetch public
fi

#Get input
if [ -z "$1" ]
then
	echo argument 1 must be the tag to use
	echo $usage
	exit 1
else
	tag=$1
fi
if [ -z "$2" ]
then
	echo argument 2 must be the manifest filename
	echo $usage
	exit 1
else
	manifest=$2
fi

srcBranch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
destBranch=$(git branch | sed -n -e 's/^\* \(.*\)-.*/\1/p')

dprint $srcBranch $destBranch $tag

#Tag the private repo
git tag -f -a $tag-private -m "Deploying manifest for $tag"
git push -f origin $tag-private

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

#Create/Overwrite the manifest 
git checkout origin/$srcBranch -- $manifest

#Edit manifest xml in place preserving formatting
#Delete any remotes named 'third'
#Delete any projects using the renote named 'third'
#Remove the '-private' suffix from project repo names
#Remove the '-RCx' suffix from project revisions
#File to modify

#COPYING TO OTHER PRODUCT
#review this part of the script and update as appropriate

xmlstarlet ed --inplace --pf \
	-d "/manifest/remote[@name='third']" \
	-d "/manifest/project[@remote='third']" \
	-u "/manifest/project[contains(@name,'-private')]/@name" -x "substring-before(., '-private')" \
	-u "/manifest/project[contains(@revision,'-RC')]/@revision" -x "substring-before(., '-RC')" \
	$manifest

git add $manifest

git commit -m "Deploying manifest for $tag"
git tag -f -a $tag -m "Deploying manifest for $tag"
git push -u public $destBranch
git push -f public $tag
git checkout -
