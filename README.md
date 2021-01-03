# Shell Scripts

This is a useful collection of shell scripts and libraries I've created
and assembled of the past couple of years.  In particular note the
library files `*.sh` which should be used wherever possible.

## Use

Typically you just need to add the relevant script directory to your
path.  If you need to copy them, be aware that the library scripts
sometimes refer to each other, and the command scripts typically
expect the `include.sh` to live in the same directory as the command.

## Standards

* All scripts in this repository should pass a shellcheck and shfmt check
  before being committed.
* Scripts should be organized in folders according to their variant, if
  they are not specific to a given shell variant, then put them in the
  `bash` folder
* All command scripts should use options.sh to parse arguments and document
  their usage.
* Prefer dashes to underscores in script names
* functions in include files (`*.sh`) should have a namespace qualification
  such as `funcion foo::bar`  rather than just `function bar`
