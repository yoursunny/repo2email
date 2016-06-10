#!/bin/bash

reponame=$1
repotype=$2
email=$3

oldver=`cat $reponame/repo2email.ver`

if [[ $repotype = 'svn' ]]; then
  cd $reponame
  curver=`svn up | grep revision | sed -e 's/.*revision //' -e 's/\.//'`
  svn log -l 1 > ../$reponame.commit
  echo >> ../$reponame.commit
  svn diff -r $oldver:$curver --summarize >> ../$reponame.commit
  cd ..
fi

if [[ $oldver == $curver ]]; then
  rm $reponame.commit
  exit
fi

echo $curver > $reponame/repo2email.ver

if ! [[ -f $reponame/repo2email.noattach ]]; then
  if [[ -x $reponame/repo2email.prepare.sh ]]; then
    cd $reponame
    ./repo2email.prepare.sh
    cd ..
  fi

  tar czf ${reponame}_$curver.tar.gz $reponame
fi

boundary=`echo $RANDOM | openssl md5`
(
  for to in `echo $email | tr ';' '\n'`
  do
    echo 'To: '$to
  done
  echo 'From: repo2email@'`hostname -f`
  echo 'MIME-Version: 1.0'
  echo 'Content-Type: multipart/mixed; boundary="'$boundary'"'
  echo 'Subject: repo '$reponame' commit '$curver
  echo ''
  echo '--'$boundary
  echo 'Content-Type: text/plain; charset="us-ascii"'
  echo ''
  cat $reponame.commit
  echo ''
  if ! [[ -f $reponame/repo2email.noattach ]]; then
    echo '--'$boundary
    echo 'Content-Type: application/x-gtar; name="'$reponame'_'$curver'.tar.gz"'
    echo 'Content-Transfer-Encoding: base64'
    echo ''
    base64 ${reponame}_$curver.tar.gz
    echo ''
  fi
) | /usr/sbin/sendmail -t

rm -f $reponame.commit ${reponame}_$curver.tar.gz
