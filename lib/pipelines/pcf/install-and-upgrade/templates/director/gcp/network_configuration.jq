#
# jq -n \
#   --argjson icmp_checks_enabled false \
#   --arg infra_network_name "infrastructure" \
#   --arg infra_iaas_network "${GCP_RESOURCE_PREFIX}-virt-net/${GCP_RESOURCE_PREFIX}-subnet-infrastructure-${GCP_REGION}/${GCP_REGION}" \
#   --arg infra_network_cidr "192.168.101.0/26" \
#   --arg infra_reserved_ip_ranges "192.168.101.1-192.168.101.9" \
#   --arg infra_dns "192.168.101.1,8.8.8.8" \
#   --arg infra_gateway "192.168.101.1" \
#   --arg infra_availability_zones "$AVAILABILITY_ZONES" \
#   --arg deployment_network_name "ert" \
#   --arg deployment_iaas_network "${GCP_RESOURCE_PREFIX}-virt-net/${GCP_RESOURCE_PREFIX}-subnet-ert-${GCP_REGION}/${GCP_REGION}" \
#   --arg deployment_network_cidr "192.168.16.0/22" \
#   --arg deployment_reserved_ip_ranges "192.168.16.1-192.168.16.9" \
#   --arg deployment_dns "192.168.16.1,8.8.8.8" \
#   --arg deployment_gateway "192.168.16.1" \
#   --arg deployment_availability_zones "$AVAILABILITY_ZONES" \
#   --arg services_network_name "services-1" \
#   --arg services_iaas_network "${GCP_RESOURCE_PREFIX}-virt-net/${GCP_RESOURCE_PREFIX}-subnet-services-1-${GCP_REGION}/${GCP_REGION}" \
#   --arg services_network_cidr "192.168.20.0/22" \
#   --arg services_reserved_ip_ranges "192.168.20.1-192.168.20.9" \
#   --arg services_dns "192.168.20.1,8.8.8.8" \
#   --arg services_gateway "192.168.20.1" \
#   --arg services_availability_zones "$AVAILABILITY_ZONES" \
#   --arg dynamic_services_network_name "dynamic-services-1" \
#   --arg dynamic_services_iaas_network "${GCP_RESOURCE_PREFIX}-virt-net/${GCP_RESOURCE_PREFIX}-subnet-dynamic-services-1-${GCP_REGION}/${GCP_REGION}" \
#   --arg dynamic_services_network_cidr "192.168.24.0/22" \
#   --arg dynamic_services_reserved_ip_ranges "192.168.24.1-192.168.24.9" \
#   --arg dynamic_services_dns "192.168.24.1,8.8.8.8" \
#   --arg dynamic_services_gateway "192.168.24.1" \
#   --arg dynamic_services_availability_zones "$AVAILABILITY_ZONES" \
#   --argjson curr_network_configuration {"networks":[]} \
#   "$(cat network_configuration.jq)"
#

{
  "icmp_checks_enabled": $icmp_checks_enabled,
  "networks": [
    {
      "guid": (
        (
          $curr_network_configuration 
            | .networks[] 
            | select(.name == $infra_network_name) 
            | .guid
        ) // null
      ),
      "name": $infra_network_name,
      "service_network": false,
      "subnets": [
        {
          "guid": (
            (
              $curr_network_configuration 
                | .networks[] 
                | select(.name == $infra_network_name) 
                | .subnets[] 
                | select(.iaas_identifier == $infra_iaas_network) 
                | .guid
            ) // null
          ),
          "iaas_identifier": $infra_iaas_network,
          "cidr": $infra_network_cidr,
          "reserved_ip_ranges": $infra_reserved_ip_ranges,
          "dns": $infra_dns,
          "gateway": $infra_gateway,
          "availability_zone_names": ($infra_availability_zones | split(","))
        }
      ]
    },
    {
      "guid": (
        (
          $curr_network_configuration 
            | .networks[] 
            | select(.name == $deployment_network_name) 
            | .guid
        ) // null
      ),
      "name": $deployment_network_name,
      "service_network": false,
      "subnets": [
        {
          "guid": (
            (
              $curr_network_configuration 
                | .networks[] 
                | select(.name == $deployment_network_name) 
                | .subnets[] 
                | select(.iaas_identifier == $deployment_iaas_network) 
                | .guid
            ) // null
          ),
          "iaas_identifier": $deployment_iaas_network,
          "cidr": $deployment_network_cidr,
          "reserved_ip_ranges": $deployment_reserved_ip_ranges,
          "dns": $deployment_dns,
          "gateway": $deployment_gateway,
          "availability_zone_names": ($deployment_availability_zones | split(","))
        }
      ]
    },
    {
      "guid": (
        (
          $curr_network_configuration 
            | .networks[] 
            | select(.name == $services_network_name) 
            | .guid
        ) // null
      ),
      "name": $services_network_name,
      "service_network": false,
      "subnets": [
        {
          "guid": (
            (
              $curr_network_configuration 
                | .networks[] 
                | select(.name == $services_network_name) 
                | .subnets[] 
                | select(.iaas_identifier == $services_iaas_network) 
                | .guid
            ) // null
          ),
          "iaas_identifier": $services_iaas_network,
          "cidr": $services_network_cidr,
          "reserved_ip_ranges": $services_reserved_ip_ranges,
          "dns": $services_dns,
          "gateway": $services_gateway,
          "availability_zone_names": ($services_availability_zones | split(","))
        }
      ]
    },
    {
      "guid": (
        (
          $curr_network_configuration 
            | .networks[] 
            | select(.name == $dynamic_services_network_name) 
            | .guid
        ) // null
      ),
      "name": $dynamic_services_network_name,
      "service_network": true,
      "subnets": [
        {
          "guid": (
            (
              $curr_network_configuration 
                | .networks[] 
                | select(.name == $dynamic_services_network_name) 
                | .subnets[] 
                | select(.iaas_identifier == $dynamic_services_iaas_network) 
                | .guid
            ) // null
          ),
          "iaas_identifier": $dynamic_services_iaas_network,
          "cidr": $dynamic_services_network_cidr,
          "reserved_ip_ranges": $dynamic_services_reserved_ip_ranges,
          "dns": $dynamic_services_dns,
          "gateway": $dynamic_services_gateway,
          "availability_zone_names": ($dynamic_services_availability_zones | split(","))
        }
      ]
    }
  ]
}