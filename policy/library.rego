# Based on OPA terraform docs https://www.openpolicyagent.org/docs/latest/terraform/
package terraform.library

import input as tfplan

import future.keywords.in

resources_by_type[resource_type] := all {
	some resource_type
	resource_types[resource_type]
	all := [name |
		name := tfplan.resource_changes[_]
		name.type == resource_type
	]
}

# number of creations of resources of a given type
num_creates[resource_type] := num {
	some resource_type
	resource_types[resource_type]
	all := resources_by_type[resource_type]
	creates := [res | res := all[_]; res.change.actions[_] == "create"]
	num := count(creates)
}

# number of deletions of resources of a given type
num_deletes[resource_type] := num {
	some resource_type
	resource_types[resource_type]
	all := resources_by_type[resource_type]
	deletions := [res | res := all[_]; res.change.actions[_] == "delete"]
	num := count(deletions)
}

# number of modifications to resources of a given type
num_modifies[resource_type] := num {
	some resource_type
	resource_types[resource_type]
	all := resources_by_type[resource_type]
	modifies := [res | res := all[_]; res.change.actions[_] == "update"]
	num := count(modifies)
}

num_of_type_action := {
	"create": num_creates,
	"delete": num_deletes,
	"update": num_modifies,
}

resource_types := {t |
	t := resources[_].type
}

resources := {r |
	some path, value
	walk(tfplan, [path, value])
	rs := module_resources(path, value)
	r := rs[_]
}

# Variant to match root_module resources
module_resources(path, value) := rs {
	reverse_index(path, 1) == "resources"
	reverse_index(path, 2) == "root_module"
	rs := value
}

# Variant to match child_modules resources
module_resources(path, value) := rs {
	reverse_index(path, 1) == "resources"
	reverse_index(path, 3) == "child_modules"
	rs := value
}

reverse_index(path, idx) := value {
	value := path[count(path) - idx]
}
