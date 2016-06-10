#!/bin/bash

reponame=$1
repotype=$2
email=$3

if [[ $repotype = 'svn' ]]
then
  cd $reponame
  curver=`svn up | grep revision | sed -e 's/.*revision //' -e 's/\.//'`
  svn log -l 1 > ../$reponame.commit
  cd ..
fi

oldver=`cat $reponame/repo2email.ver`
if [[ $oldver == $curver ]]
then
  rm $reponame.commit
  exit
fi

echo $curver > $reponame/repo2email.ver

if [[ -x $reponame/repo2email.prepare.sh ]]
then
  cd $reponame
  ./repo2email.prepare.sh
  cd ..
fi

tar czf ${reponame}_$curver.tar.gz $reponame

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
  echo '--'$boundary
  echo 'Content-Type: application/x-gtar; name="'$reponame'_'$curver'.tar.gz"'
  echo 'Content-Transfer-Encoding: base64'
  echo ''
  base64 ${reponame}_$curver.tar.gz
  echo ''
) | /usr/sbin/sendmail -t

rm $reponame.commit ${reponame}_$curver.tar.gz
