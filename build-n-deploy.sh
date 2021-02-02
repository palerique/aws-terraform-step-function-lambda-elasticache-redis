#!/bin/bash
pushd lambda/influence-analysis || exit 1
set -e
#./gradlew clean build packageLibs packageSkinny packageFat -i
#./gradlew clean build packageLibs packageSkinny -i
./gradlew clean build packageFat -i
popd || exit 1

#pushd terraform || exit 1
#terraform apply --auto-approve \
#  -var cache_pwd=Redis2019! \
#  -var system_password=admin \
#  -var system_username=admin \
#  -var rest_api_address=https://banzai-3006-1-1-10decb6-1.jivelandia.com/api/core/v3/analytics/influence/content/1009 \
#  -var resource_prefix=xpto
#popd || exit 1

pushd terraform-2 || exit 1
terraform apply --auto-approve \
  -var cache_pwd=Redis2019! \
  -var system_password=admin \
  -var system_username=admin \
  -var rest_api_address=https://banzai-3006-1-1-10decb6-1.jivelandia.com/api/core/v3/analytics/influence/content/1009 \
  -var resource_prefix=xpto
popd || exit 1
