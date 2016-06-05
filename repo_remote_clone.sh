#!/bin/bash     
#title           :repo_remote_clone.sh
#description     :This script will make copies of repos from a remote account to your github account
#author		 :Jan Hodermarsky
#date            :December 2015
#==============================================================================

Username="GithubUsername"
Password="GithubPassword"
NewBranch="NewBranchName"
NewCommitMessage="Initial commit (Cloned)"

Account="GithubAccountToCloneFrom";
Url="https://api.github.com/users/$Account/repos?per_page=999";
Dir="localDirName";
RepoVar="";
rm -rf $Dir;
mkdir $Dir;
cd $Dir;

i=0;

wget $Url -O - 2> /dev/null | grep -Po "$Account/[^/]+(?=/forks)" | while read x;
do 
	#echo "$x";
	for w in $(echo "$x" | tr "/" " " | cut -d " " -f 2);
		do
			echo $w;
			RepoVar=$(echo $w);
	done

	####### Omit some repos? #######
	if [ $i -lt 73 ] ;then
		echo "Less than 73, and thus $i"
		let "i=i+1"
	else
		echo "BIGGER than 73"
	################################
	
	#echo $RepoVar;
	git clone https://github.com/$x;

	###### Delete history and make new branch ######
	cd $RepoVar;
	###### Create new repo ######
	curl -u "$Username:$Password" https://api.github.com/user/repos -d "{\"name\":\"`echo $RepoVar;`\"}" >/dev/null
	#echo "{\"name\":\"`echo $RepoVar;`\"}";
	######
	git checkout --orphan latest_branch
	git add --all
	git commit -am "$NewCommitMessage"
	git branch -D cm-11.0
	git branch -m "$NewBranch"
	git remote set-url origin "ssh://git@github.com/$Username/$RepoVar.git"
	git push -f origin "$NewBranch"
	cd ../
	echo "DONE $RepoVar";
	echo '\n\n'
	#break;
	fi
done;
