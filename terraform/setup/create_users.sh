# Create a user with FullIAMAccess directly in the AWS console
# Use the profile of the user to create this user
aws iam create-user --profile iam-admin \
                    --user-name admin \
                    --tags Key=project,Value=aws-fin-demo 

aws iam create-access-key --profile iam-admin \
                          --user-name admin 
                          
aws iam create-policy --profile iam-admin \
    --policy-name admin-policy \
    --policy-document file://.policy.json

#no space before and after equal near the variable
policy_arn=`aws iam list-policies --query "Policies[?PolicyName=='admin-policy'].Arn" --output text --profile iam-admin`

aws iam attach-user-policy --policy-arn $policy_arn \
                        --user-name admin \
                        --profile iam-admin
