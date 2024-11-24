<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="nimble_install"></a>

## nimble_install

<pre>
load("@rules_nim//nim:nimble.bzl", "nimble_install")

nimble_install(<a href="#nimble_install-name">name</a>, <a href="#nimble_install-nimble_attrs">nimble_attrs</a>, <a href="#nimble_install-nimble_file">nimble_file</a>, <a href="#nimble_install-pkgs_dir_prefix">pkgs_dir_prefix</a>, <a href="#nimble_install-quiet">quiet</a>, <a href="#nimble_install-repo_mapping">repo_mapping</a>)
</pre>

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="nimble_install-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="nimble_install-nimble_attrs"></a>nimble_attrs |  -   | List of strings | optional |  `[]`  |
| <a id="nimble_install-nimble_file"></a>nimble_file |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="nimble_install-pkgs_dir_prefix"></a>pkgs_dir_prefix |  -   | String | optional |  `"pkgs2"`  |
| <a id="nimble_install-quiet"></a>quiet |  -   | Boolean | optional |  `False`  |
| <a id="nimble_install-repo_mapping"></a>repo_mapping |  In `WORKSPACE` context only: a dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.<br><br>For example, an entry `"@foo": "@bar"` declares that, for any time this repository depends on `@foo` (such as a dependency on `@foo//some:target`, it should actually resolve that dependency within globally-declared `@bar` (`@bar//some:target`).<br><br>This attribute is _not_ supported in `MODULE.bazel` context (when invoking a repository rule inside a module extension's implementation function).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  |


