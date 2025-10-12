{
  description = "project_name";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = {
    self,
    nixpkgs,
    systems,
    ...
  }: let
    forEachSystem = nixpkgs.lib.genAttrs (import systems);
    pkgsFor = forEachSystem (system: import nixpkgs {inherit system;  config.allowUnfree = true;});
  in {
    formatter = forEachSystem (system: pkgsFor.${system}.alejandra);

    devShells = forEachSystem (system: {
      default = pkgsFor.${system}.mkShell {
         packages = with pkgsFor.${system}; [
                     # DevOps tools
            packer
            ansible
            terraform
            docker
            python3
            vagrant
            # LSPs
            terraform-ls
            ansible-language-server
            bash-language-server
            yaml-language-server
            dockerfile-language-server-nodejs
            vscode-langservers-extracted # includes html, css, json, eslint
            sshpass # ansible
            # Optional: Go, Node.js, etc.
            go
            nodejs
            nodePackages.npm
            nodePackages.typescript-language-server
        ];
      };
    });

    packages = forEachSystem (system: {
      default = pkgsFor.${system}.hello;
    });

    apps = forEachSystem (system: {
      default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/hello";
      };
    });
  };
}
