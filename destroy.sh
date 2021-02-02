#!/bin/bash

pushd terraform || exit 1
terraform destroy --auto-approve \
  -var cache_pwd=Redis2019! \
  -var system_password=admin \
  -var system_username=admin \
  -var rest_api_address=https://banzai-3006-1-1-10decb6-1.jivelandia.com/api/core/v3/analytics/influence/content/1009 \
  -var resource_prefix=xpto
popd || exit 1
