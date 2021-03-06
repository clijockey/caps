#
# jq -n \
#   --argjson internet_connected false \
#   --arg pks_api_lb_name "tcp:pcf-poc1-pcf-pks-api" \
#   "$(cat resources.jq)"
#

{
  "pivotal-container-service": {
    # i.e. TCP load balancer for applications
    "internet_connected": $internet_connected,
    "elb_names": ($pks_api_lb_name | split(","))
  }
}
