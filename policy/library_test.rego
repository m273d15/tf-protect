package terraform.library

import future.keywords.in

# Creates null_resource.test2 
# Deletes local_file.my_file
plan_1 := parse_config_file("./test_resources/test_plan_1.json")

# Creates local_file.other_file 
# Deletes local_file.my_file
# Deletes local_file.my_file2
plan_2 := parse_config_file("./test_resources/test_plan_2.json")

test_resources {
	rs := resources with input as plan_1
	count(rs) == 2
	rs[_].type == "null_resource"
	rs[_].type == "local_file"
}

test_resource_types {
	rt := resource_types with input as plan_1
	rt == {"null_resource", "local_file"}
}

test_resources_of_type_with_one_resource {
	rs := resources_by_type.null_resource with input as plan_1
	count(rs) == 1
	some s in rs
	s.address == "null_resource.test2"
}

test_resources_of_type_with_multiple_resources {
	rs := resources_by_type.local_file with input as plan_2
	count(rs) == 3
	rs[_].address == "local_file.my_file"
	rs[_].address == "local_file.my_file2"
	rs[_].address == "local_file.other_file"
}

test_num_of_type_action_with_single_resource_type {
	at := num_of_type_action with input as plan_2
	at == {"create": {"local_file": 1}, "delete": {"local_file": 2}, "update": {"local_file": 0}}
}

test_num_of_type_action_with_multiple_resource_types {
	at := num_of_type_action with input as plan_1
	at == {"create": {"local_file": 0, "null_resource": 1}, "delete": {"local_file": 1, "null_resource": 0}, "update": {"local_file": 0, "null_resource": 0}}
}
