# repo2email

This script checks a code repository, and sends changes via email.

## USAGE

1. clone a repo to `reponame/`
2. execute once: `echo 0 > reponame/repo2email.ver`
3. if needed, create `reponame/repo2email.prepare.sh` script which will be called before packaging
4. if attachment is unwanted, create `reponame/repo2email.noattach` tag file
5. set up crontab to execute: `./repo2email.sh 'reponame' 'svn' 'someone@example.com;another@example.com'`
