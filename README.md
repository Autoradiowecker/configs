# NixOS configs für Hard und Software Laptop

configuration files for my Laptop environment.

This Repo contains every config i achieved with NixOS.
I am always open for suggestions.

## Docker cheat-sheet

see https://nix.dev/tutorials/nixos/building-and-running-docker-images.html for details.

### commands
  - nix-build *file.nix*
    - is for building docker Images in the nix language
    - the last row in output shows the Name of the Image
  - docker load < result 
    - is for adding in nix created docker Images to docker registry
  - docker load < $(nix-build *file.nix*)
    - combination of the first two commands