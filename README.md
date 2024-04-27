# fmix
[![License](https://img.shields.io/badge/License-COPL-red.svg)](https://raw.githubusercontent.com/UA3MQJ/fmix/master/LICENSE)
[![Ver](https://img.shields.io/badge/Ver-0.2.0-green.svg)](https://github.com/UA3MQJ/fmix/tree/0.2.0)

FMix is a build tool that provides tasks for creating, compiling, and testing Forth packages, managing its dependencies, and more.

Format of package description, as example:

`package.4th`

```
forth-package
    key-value name fmix
    key-value version 0.1.0
    key-value license COPL
    key-value description Forth build tool
    key-value main fmix.4th
    / key-value dependencies_path ./forth-packages
    / packages from git
    key-list dependencies ftest git https://github.com/UA3MQJ/ftest.git branch main
    key-list dependencies ftest git https://github.com/UA3MQJ/ftest.git branch special_branch
    key-list dependencies ftest git https://github.com/UA3MQJ/ftest.git tag 0.1.0
    / packages from theforth.net
    key-list dependencies f 0.2.4
end-forth-package
```

All dependencies of all packages stored to ~/fmix/forth-packages/<dep_name>/<branch|tag>

This structure allows:

* to store all dependencies in one place
* to have the ability to work with different versions of one dependency.

Using dependencies in our packages

```
include ~/fmix/forth-packages/ftest/main/ftest.4th
```

BUT if necessary, you can change the location of the dependencies, for example, place them in the current directory

```
forth-package
    ...
    key-value dependencies_path ./forth-packages
    ...
end-forth-package
```

# Install

```
git clone https://github.com/UA3MQJ/fmix.git

    nano ~/.bashrc
    or
    nano ~/.zshrc

    alias fmix='gforth ~/fmix/fmix.4th -e'
```

# Use

create new package
```
  fmix new example
  cd example
```
get dependecies
```
  fmix packages.get 
```

# Depends

GForth 0.7.3, git, sed, cp.

# Status

- [x] Create package
- [x] Get dependecies
- [ ] Compiling
- [ ] Run package
- [ ] Test test
- [ ] And more..


fget base64 1.0.0

include ~/fmix/forth-packages/f/0.2.4/compat-gforth.4th
include ~/fmix/forth-packages/f/0.2.4/f.4th

fget base64 1.0.0 /api/packages/content/forth/base64/1.0.0