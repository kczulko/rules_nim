<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="nimble_install"></a>

## nimble_install

<pre>
load("@rules_nim//nim:nimble.bzl", "nimble_install")

nimble_install(<a href="#nimble_install-name">name</a>, <a href="#nimble_install-nimble_attrs">nimble_attrs</a>, <a href="#nimble_install-nimble_file">nimble_file</a>, <a href="#nimble_install-pkgs_dir_prefix">pkgs_dir_prefix</a>, <a href="#nimble_install-quiet">quiet</a>, <a href="#nimble_install-repo_mapping">repo_mapping</a>)
</pre>

Runs `nimble install` on `nimble_file` attribute which brings dependencies into the scope.
CAUTION: This "action" is not cached in repository cache by Bazel therefore it is suggested
to generate `nimble.lock` file and then use `nimble_lock` rule which is also faster than `nimble_install`.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="nimble_install-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="nimble_install-nimble_attrs"></a>nimble_attrs |  -   | List of strings | optional |  `["--noLockFile"]`  |
| <a id="nimble_install-nimble_file"></a>nimble_file |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="nimble_install-pkgs_dir_prefix"></a>pkgs_dir_prefix |  -   | String | optional |  `"pkgs2"`  |
| <a id="nimble_install-quiet"></a>quiet |  -   | Boolean | optional |  `False`  |
| <a id="nimble_install-repo_mapping"></a>repo_mapping |  In `WORKSPACE` context only: a dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.<br><br>For example, an entry `"@foo": "@bar"` declares that, for any time this repository depends on `@foo` (such as a dependency on `@foo//some:target`, it should actually resolve that dependency within globally-declared `@bar` (`@bar//some:target`).<br><br>This attribute is _not_ supported in `MODULE.bazel` context (when invoking a repository rule inside a module extension's implementation function).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  |


<a id="nimble_lock"></a>

## nimble_lock

<pre>
load("@rules_nim//nim:nimble.bzl", "nimble_lock")

nimble_lock(<a href="#nimble_lock-name">name</a>, <a href="#nimble_lock-lock_file">lock_file</a>, <a href="#nimble_lock-repo_mapping">repo_mapping</a>)
</pre>

Downloads dependencies from the `nimble.lock` file. Downloaded blobs are cached by Bazel in the
repository cache which means this repository rule is preffered over the `nimble_install`.
Supports only download from the following URIs: ["https://github.com", "https://gitlab.com"]

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="nimble_lock-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="nimble_lock-lock_file"></a>lock_file |  The nimble lock file.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="nimble_lock-repo_mapping"></a>repo_mapping |  In `WORKSPACE` context only: a dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.<br><br>For example, an entry `"@foo": "@bar"` declares that, for any time this repository depends on `@foo` (such as a dependency on `@foo//some:target`, it should actually resolve that dependency within globally-declared `@bar` (`@bar//some:target`).<br><br>This attribute is _not_ supported in `MODULE.bazel` context (when invoking a repository rule inside a module extension's implementation function).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  |


