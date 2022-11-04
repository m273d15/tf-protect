package main

import data.resource_types
import data.terraform.library


validate_action(action, resource_type, resource_config) = {msg |
    print("action", action, "resource_type", resource_type, "config", resource_config)
	num_of_action := library.num_of_type_action[action][resource_type]
	num_of_action_limit := resource_config[action]
	num_of_action > num_of_action_limit
	msg := sprintf("%v %d resources of type %v than allowed %d", [action, num_of_action, resource_type, num_of_action_limit])
}

find_protected_resources_with_violations(tfprotect_types_config) = {msg |
	print("config", tfprotect_types_config)
	some resource_type
	tfprotect_types_config[resource_type]
	print("resource_type", resource_type)
	msgs := (validate_action("create", resource_type, tfprotect_types_config[resource_type]) |
	         validate_action("update", resource_type, tfprotect_types_config[resource_type]) |
			 validate_action("delete", resource_type, tfprotect_types_config[resource_type]))
	msg := msgs[_]
}

deny[msg] {
	msg := find_protected_resources_with_violations(resource_types)[_]
}

deny[msg] {
	not resource_types
	msg := "No tfprotect config provided"
}
