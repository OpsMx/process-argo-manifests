#/bin/bash

validate_clone() {
if [ $? == 0 ]
then
  echo "INFO: Cloning done $SOURCE_REPO"
else
  echo "ERROR: Cloning failed with repo $SOURCE_REPO, Please check credentials and repo access...."
  exit 5
fi
}
tokenclone() {
    echo git clone https://$git_user:${gitoken}@$SOURCE_API/$SOURCE_ORG/$SOURCE_REPO_PATH.git /tmp/$SOURCE_REPO_PATH -b "$SOURCE_BRANCH" 
    clone_result=$(git clone https://$git_user:${gitoken}@$SOURCE_API/$SOURCE_ORG/$SOURCE_REPO_PATH.git /tmp/$SOURCE_REPO_PATH -b "$SOURCE_BRANCH"  2> /dev/null)
    validate_clone
}

sshclone() {
    apk add openssh > /dev/null
    mkdir -p ~/.ssh/
    echo "$GIT_SSH_KEY" | tr -d '\r' > ~/.ssh/id_rsa
    chmod 600 ~/.ssh/id_rsa
    ssh-keyscan github.com >> ~/.ssh/known_hosts
    clone_result=$(git clone git@$SOURCE_API:$SOURCE_ORG/$SOURCE_REPO_PATH.git /tmp/$SOURCE_REPO_PATH -b "$SOURCE_BRANCH"  2> /dev/null)
    validate_clone
}

repochanges() {
  cd "$SOURCE_REPO_PATH"
  IFS="|"
  for i in $VALUES
  do
   echo value is $i
   yq e -i "$VALUES" "$MANIFEST_PATH"
   if [ $? != 0 ]; then
   echo "Error occured in YAML processing, please check the logs"
   exit 1
   fi
  done
}

gitcommitpush() {
  git config --global user.email "noreply@opsmx.io"
  git config --global user.name "$git_user"
  git add -A
  git commit -am "Autocommit to add ${VALUES[*]}"
  # Logic for multiple pushed as the same time
  MINWAIT=1
  MAXWAIT=10
  for i in {1..10}
  do
    echo "Trying $i times"
    git push 
    if [ $? == 0 ]
    then
      return 0
    else 
      sleep $((MINWAIT+RANDOM % (MAXWAIT-MINWAIT)))
      git config pull.rebase true
      git pull
      cp /tmp/environment.yml /tmp/$SOURCE_REPO_PATH/$SOURCE_PATH
    fi
  done
  echo 'Failed to push changes'
  return 1
}

set -x
DIR=multi-tenent/base
yq e  -i .spec.template.spec.containers[0].name=\"$param1\" $DIR/fix-deploy.yaml
#yq e  -i .spec.template.spec.containers[0].ports[0].containerPort=\"$param2\" $DIR/fix-deploy.yaml
yq e  -i '.spec.template.spec.containers[0].ports[0].containerPort= '"$param2"'' $DIR/fix-deploy.yaml
yq e  -i .spec.template.spec.containers[0].image=\"$param3\" $DIR/fix-deploy.yaml
yq e -i '.namePrefix= "'$param1'"' $DIR/kustomization.yaml
kustomize build $DIR  > /tmp/environment.yml
## git checkin the file
SOURCE_API=github.com
tokenclone
mkdir -p /tmp/$SOURCE_REPO_PATH/$SOURCE_PATH
cp /tmp/environment.yml /tmp/$SOURCE_REPO_PATH/$SOURCE_PATH
ls -ltr

cd $SOURCE_REPO_PATH
gitcommitpush
