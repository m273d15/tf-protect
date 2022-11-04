package main

import data.terraform.library

# Creates local_file.other_file 
# Deletes local_file.my_file
# Deletes local_file.my_file2
plan_2 := parse_config_file("./test_resources/test_plan_2.json")

test_validate_action_delete_above_limit {
	msg := validate_action("delete", "local_file", {"delete": 1}) with input as plan_2
	print("msg", msg)
	count(msg) == 1
}

test_validate_action_delete_below_limit {
	msg := validate_action("delete", "local_file", {"delete": 2}) with input as plan_2
	print("msg", msg)
	count(msg) == 0
}

test_deny_with_delete_above_limit {
	msgs := deny with input as plan_2
		with data.resource_types as {"local_file": {"delete": 0, "create": 2, "update": 0}}

	print("msgs", msgs)
	count(msgs) == 1
}

test_not_deny_with_delete_below_limit {
	msgs := deny with input as plan_2
		with data.resource_types as {"local_file": {"delete": 2, "create": 2, "update": 0}}

	print("msgs", msgs)
	count(msgs) == 0
}

test_deny_with_create_above_limit {
	msgs := deny with input as plan_2
		with data.resource_types as {"local_file": {"delete": 2, "create": 0, "update": 0}}

	print("msgs", msgs)
	count(msgs) == 1
}

test_deny_with_create_and_delete_above_limit {
	msgs := deny with input as plan_2
		with data.resource_types as {"local_file": {"delete": 1, "create": 0, "update": 0}}

	print("msgs", msgs)
	count(msgs) == 2
}

test_deny_with_not_defining_create_and_update_limit {
	msgs := deny with input as plan_2
		with data.resource_types as {"local_file": {"delete": 1}}

	print("msgs", msgs)
	count(msgs) == 1
}
