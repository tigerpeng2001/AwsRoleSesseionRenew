#!/usr/local/bin/bash
profile=$1
read -r account arn userid <<< $(aws --profile $profile sts get-caller-identity  --query "[Account,Arn]" --output text |sed 's|sts|iam|; s|assumed-||; s|/\([^/]*\)$| \1|')
while true
do
  new_credential=$(aws --profile $profile sts assume-role --role-arn $arn --role-session-name $userid --duration-seconds 3600 --query "Credentials.{aws_access_key_id:AccessKeyId,aws_secret_access_key:SecretAccessKey,aws_session_token:SessionToken}" --output json | grep aws_ |sed 's/^ *"//; s/": "/ = /; s/",*$//')
  # the initial credential return from another tool contains entry aws_session_token which is a duplicat of aws_session_token
  sed -i.bak "/aws_security_token/d" ~/.aws/credentials
  sed -i.bak "/\[$profile\]/,+4d"  ~/.aws/credentials
  echo "[$profile]" >> ~/.aws/credentials
  echo "$new_credential" >> ~/.aws/credentials
  echo "" >> ~/.aws/credentials
  sleep $(( 61 * 57 ))
done
