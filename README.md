# nix-config

installation:
```sh
nix run --extra-experimental-features "nix-command flakes" 'nixpkgs#home-manager' -- --flake . switch
```

updating state:
```sh
nix-reload
```

upgrading packages:
```sh
nix flake update
nix-reload
```
