# fmix

FMix is a build tool that provides tasks for creating, compiling, and testing Forth projects, managing its dependencies, and more.

Format of project description, as example:

`fproject.fs`

```
forth-project
    key-value name fmix
    key-value version 0.1.0
    key-value license COPL
    key-value description Forth build tool
    key-value main fmix.fs
    / key-value deps_path ./deps
    key-list deps ftest git https://github.com/UA3MQJ/ftest.git branch main
    key-list deps ftest git https://github.com/UA3MQJ/ftest.git branch special_branch
    key-list deps ftest git https://github.com/UA3MQJ/ftest.git tag 0.1.0
end-forth-project
```

All dependencies of all projects stored to ~/fmix/deps/<dep_name>/<branch|tag>

This structure allows:

* to store all dependencies in one place
* to have the ability to work with different versions of one dependency.

Using dependencies in our projects

```
include ~/fmix/deps/ftest/main/ftest.fs
```

BUT if necessary, you can change the location of the dependencies, for example, place them in the current directory

```
forth-project
    ...
    key-value deps_path ./deps
    ...
end-forth-project
```

# Install

```
git clone https://github.com/UA3MQJ/fmix.git

    nano ~/.bashrc
    or
    nano ~/.zshrc

    alias fmix='gforth ~/fmix/fmix.fs -e'
```

# Use

create new project
```
  fmix new example
  cd example
```
get dependecies
```
  fmix deps.get 
```

# Depends

GForth 0.7.3, GIT.

# Status

- [x] Create project
- [x] Get dependecies
- [ ] Compiling
- [ ] Run project
- [ ] Test test
- [ ] And more..

