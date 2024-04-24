# fmix

FMix is a build tool that provides tasks for creating, compiling, and testing Forth projects, managing its dependencies, and more.

# Install

```
git clone https://github.com/UA3MQJ/fmix.git

    nano ~/.bashrc
    or
    nano ~/.zshrc

    alias fmix='gforth ~/fmix/fmix.fs -e'
```

# Use

```
    gforth ~/fmix/fmix.fs -e new example 

    or

    fmix new example 
```

create new project
```
  fmix new example 
```
get dependecies
```
  fmix deps.get 
```


# Depends

GForth 0.7.3, GIT.

# заметки

git clone -b main https://github.com/UA3MQJ/ftest.git ./deps/ftest/main