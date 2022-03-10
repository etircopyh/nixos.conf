{
    description = "etircopyh's NixOS dumpster";

    inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    inputs.nur.url = "github:nix-community/NUR";

    #inputs.overlays = {
        #url = "path:overlays";
        #flake = false;
    #};

    inputs.nur-shlyupa = {
        url = "github:ilya-fedin/nur-repository";
        flake = false;
    };

    inputs.hardware-configuration = {
        url = "path:hardware-configuration.nix";
        flake = false;
    };

    inputs.secrets = {
        url = "path:secrets.nix";
        flake = false;
    };

    inputs.sway = {
        url = "path:setup/sway.nix";
        flake = false;
    };

    inputs.zsh = {
        url = "path:setup/zsh.nix";
        flake = false;
    };

    outputs = { self, nixpkgs, nur, nur-shlyupa, hardware-configuration, secrets }@inputs: {
        nixosConfigurations.nixsys = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
                ./configuration.nix
                {
                    config.nixpkgs = {
                        overlays = [
                            inputs.self.overlay
                        ];
                        config = { allowUnfree = true; };
                    };
                }
            ];
            specialArgs = { inherit inputs; };
        };
    };
}
