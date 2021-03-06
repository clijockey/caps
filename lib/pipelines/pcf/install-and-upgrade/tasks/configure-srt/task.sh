#!/bin/bash

source automation/lib/scripts/utility/template-utils.sh

[[ -n "$TRACE" ]] && set -x
set -eo pipefail

# Source terraform output variables if available
source_variables 'terraform-output/pcf-env-*.sh'

PRODUCT_NAME=cf
TEMPLATE_PATH=automation/lib/pipelines/pcf/install-and-upgrade/templates/srt
TEMPLATE_OVERRIDE_PATH=automation-extensions/$TEMPLATE_OVERRIDE_PATH

INSTALLED_VERSION=$(om \
  --skip-ssl-validation \
  --target "https://${OPSMAN_HOST}" \
  --client-id "${OPSMAN_CLIENT_ID}" \
  --client-secret "${OPSMAN_CLIENT_SECRET}" \
  --username "${OPSMAN_USERNAME}" \
  --password "${OPSMAN_PASSWORD}" \
  curl -path /api/v0/deployed/products \
  | jq -r --arg product_name $PRODUCT_NAME '.[] | select(.type==$product_name) | .product_version')

if [[ -n "$INSTALLED_VERSION" ]]; then
  NEW_VERSION=$(cat pivnet-product/version | cut -d'#' -f1)
  echo "The product tile '$PRODUCT_NAME' version '$INSTALLED_VERSION' has already been configured."
  echo "No further changes required to install version '$NEW_VERSION'."
  exit 0
fi

if [[ "$TRACE" == "render-templates-only" ]]; then
  network=$(eval_jq_templates "network" "$TEMPLATE_PATH" "$TEMPLATE_OVERRIDE_PATH")
  resources=$(eval_jq_templates "resources" "$TEMPLATE_PATH" "$TEMPLATE_OVERRIDE_PATH")
  properties=$(eval_jq_templates "properties" "$TEMPLATE_PATH" "$TEMPLATE_OVERRIDE_PATH")

  set +x

  echo -e "\n**** Network Request Body ****\n$network"
  echo -e "\n**** Resources Request Body ****\n$resources"
  echo -e "\n**** Properties Request Body ****\n$properties"
else

  om \
    --skip-ssl-validation \
    --target "https://${OPSMAN_HOST}" \
    --client-id "${OPSMAN_CLIENT_ID}" \
    --client-secret "${OPSMAN_CLIENT_SECRET}" \
    --username "${OPSMAN_USERNAME}" \
    --password "${OPSMAN_PASSWORD}" \
    configure-product \
    --product-name $PRODUCT_NAME \
    --product-network "$(eval_jq_templates "network" "$TEMPLATE_PATH" "$TEMPLATE_OVERRIDE_PATH")" \
    --product-resources "$(eval_jq_templates "resources" "$TEMPLATE_PATH" "$TEMPLATE_OVERRIDE_PATH")" \
    --product-properties "$(eval_jq_templates "properties" "$TEMPLATE_PATH" "$TEMPLATE_OVERRIDE_PATH")"
fi
