# beacon-manifests-private
**PRIVATE** repository holding XML manifest files for use with the repo tool

This file shall be updated before creating a new working branch, then create the branch from the resulting commit.

## Working Branches 
The following branches contain manifest that may reference repo branches and can be used for project development.
The suggested branch schema is \<vendor>-\<chipset>-\<meta e.g. yocto release>-master.

To update a *-master branch, create a *-dev branch to develop with, then use a PR to fast-forward the master branch. At this point both branches will reference the same commit, and the dev branch can be safely deleted, or resused for the next development.

| Branch                    | Purpose                 |
|---------------------------|-------------------------|
|branch link|description of purpose|
|[\<vendor>-\<chipset>-\<meta>-master](https://github.com/BeaconEmbeddedWorks/beacon-manifests-private/tree/vendor-chipset-thud-master)|description, maybe a link to a project page?|
|[nxp-imx8mm-warrior-master](https://github.com/BeaconEmbeddedWorks/beacon-manifests-private/tree/nxp-imx8mm-warrior-master)|Phoenix Master|
|[nxp-imx8mm-warrior-dev](https://github.com/BeaconEmbeddedWorks/beacon-manifests-private/tree/nxp-imx8mm-warrior-dev)|Phoenix Development|
|[renasas-rzg2-rocko-master](https://github.com/BeaconEmbeddedWorks/beacon-manifests-private/tree/renasas-rzg2-rocko-master)|ReneSOM Master|
|[renasas-rzg2-rocko-dev](https://github.com/BeaconEmbeddedWorks/beacon-manifests-private/tree/renasas-rzg2-rocko-dev)|ReneSOM Development|


## Releases
The following tags contain manifests describing specific project releases.

Use tags to annotate versions for testing and/or release. The name should match the master branch, replacing 'master' with a version number. You can then use the GitHub releases feature to mark a tag a release and add any additional files there.

| Branch                    | Purpose                 |
|---------------------------|-------------------------|
|tag-link|release description|description, maybe a link to the GitHub Release?|

## Deployment to the Public Repo
When it's time to release a version to the [public repo](https://github.com/BeaconEmbeddedWorks/beacon-manifests), a script (deploy.sh) will run that edits the manifest file and removes the layers/projects that reside on internal servers. The script then pushes and tags the edited file to the public repo. It also tags the private repos and updates the public versions of those repos using the current head of master. Branching schema for the public repo simply maintain the initial three data of the master and dev branches.

### Prerequisites
Before you run the script, there should be a tag on the -master branch of the product that will be replicated to the public repo.
You must have 'xmlstarlet' installed (apt install xmlstarlet)
