# Terraform Plan Validation

Conftest based policy to validate terraform plan and
fail if a protected resources (type) has changed.

## Usage

You can either use the policies defined in [`./policy`](./policy/) in your own conftest setup or
use the simple wrapper script (that also requires conftest to be installed).

Wrapper script usage:
```
Terraform plan validation

  Usage:
    tfprotect --config tfprotect.yaml --plan tfplan.json

  Options:
    -h, --help            Print this message
    -c, --config string   Config file that specifies protected resources
    -p, --plan            Terraform plan in json format

```

## Try it

If you clone this repository you will find a minimal [`tfprotect.yaml`](./tfprotect.yaml) in it. Use it and play around with it using the test plans.

### Example 1

The first plan would `delete` one `local_file` and `create` one `null_resource`.
Since the `tfprotect.yaml` has a deletion limit of 1. The validation will succeed.

```
> ./tfprotect --config tfprotect.yaml --plan ./policy/test_resources/test_plan_1.json
+---------+------------------------------------------+-----------+---------+
| RESULT  |                   FILE                   | NAMESPACE | MESSAGE |
+---------+------------------------------------------+-----------+---------+
| success | ./policy/test_resources/test_plan_1.json | main      | SUCCESS |
| success | ./policy/test_resources/test_plan_1.json | main      | SUCCESS |
+---------+------------------------------------------+-----------+---------+
```

### Example 2

The first plan would `delete` two `local_file` and `create` one `null_resource`.
Since the `tfprotect.yaml` has a deletion limit of 1. The validation will fail.

```
> ./tfprotect --config tfprotect.yaml --plan ./policy/test_resources/test_plan_2.json
+---------+------------------------------------------+-----------+--------------------------------+
| RESULT  |                   FILE                   | NAMESPACE |            MESSAGE             |
+---------+------------------------------------------+-----------+--------------------------------+
| success | ./policy/test_resources/test_plan_2.json | main      | SUCCESS                        |
| failure | ./policy/test_resources/test_plan_2.json | main      | delete 2 resources of type     |
|         |                                          |           | local_file than allowed 1      |
+---------+------------------------------------------+-----------+--------------------------------+
```
