# flux2 plugin for the asdf version manager

## Dependencies

- `bash`, `curl`, `tar`.

## Install
### Plugin

```shell
asdf plugin add bat https://github.com/juli3nk/asdf-flux2.git
```

### flux

```shell
# Show all installable versions
asdf list-all flux2

# Install specific version
asdf install flux2 latest

# Set a version globally (on your ~/.tool-versions file)
asdf global flux2 latest

# Now flux commands are available
flux --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to install & manage versions.
