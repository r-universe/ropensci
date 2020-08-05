#!/bin/bash
set -e

# What are we deploying
case "${TARGET}" in
"source") 
	PKGTYPE="src"
	MD5SUM=$(openssl dgst -md5 $FILE | awk '{print $2}')
	;;
"win"*) 
	PKGTYPE="win"
	MD5SUM=$(Rscript -e "cat(tools::md5sum('$FILE'))")
	;;
"mac"*) 
	PKGTYPE="mac"
	MD5SUM=$(Rscript -e "cat(tools::md5sum('$FILE'))")
	;;
*)
	echo "Unexpected target: $TARGET"
	exit 1
	;;
esac
if [ -f "$FILE" ]; then
	echo "Deploying: $FILE with md5: $MD5SUM"
else
	echo "ERROR: file $FILE not found!"
	exit 1
fi

curl -vL --upload-file "${FILE}" --fail -u "${CRANLIKEPWD}" \
	-H "Builder-Upstream: ${REPO_URL}" \
	-H "Builder-Date: $(date +'%s')" \
	-H "Builder-Commit: ${REPO_COMMIT}" \
	-H "Builder-Timestamp: ${COMMIT_TIMESTAMP}" \
	-H "Builder-Distro: ${DISTRO}" \
	-H "Builder-Host: GitHub-Actions" \
	-H "Builder-Status: ${JOB_STATUS}" \
	-H "Builder-Sysdeps: ${SYSDEPS}" \
	-H "Builder-Url: https://github.com/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}" \
	"https://dev.ropensci.org/packages/${PACKAGE}/${VERSION}/${PKGTYPE}/${MD5SUM}" \
	--output out.txt 2>&1 | grep '^[<>]'
echo " === Success! === "
cat out.txt
rm -f out.txt
