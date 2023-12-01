{
  description = "Instant, easy, predictable shells and containers.";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
  }:
    flake-utils.lib.eachDefaultSystem
    (system: let
      overlays = [];

      # pkgs is an alias for the nixpkgs at the system level. This will be used
      # for general utilities.
      pkgs = import nixpkgs {
        inherit system overlays;
      };
    in {
      defaultPackage = pkgs.buildGoModule rec {
        pname = "devbox";
        version = "0.8.2";

        src = pkgs.fetchFromGitHub {
          owner = "jetpack-io";
          repo = pname;
          rev = version;
          hash = "sha256-Hh4SfmdR7hujc6Ty+ay8uyl1vkjYuxwa5J5RacqHOAE=";
        };

        ldflags = [
          "-s"
          "-w"
          "-X go.jetpack.io/devbox/internal/build.Version=${version}"
        ];

        # integration tests want file system access
        doCheck = false;

        vendorHash = "sha256-SVChgkPgqhApWDNA1me41zS0hXd1G2oFrL/SsnFiIsg=";

        nativeBuildInputs = [pkgs.installShellFiles];

        postInstall = ''
          installShellCompletion --cmd devbox \
            --bash <($out/bin/devbox completion bash) \
            --fish <($out/bin/devbox completion fish) \
            --zsh <($out/bin/devbox completion zsh)
        '';

        meta = with pkgs.lib; {
          description = "Instant, easy, predictable shells and containers.";
          homepage = "https://www.jetpack.io/devbox";
          license = licenses.asl20;
          maintainers = with maintainers; [urandom lagoja];
        };
      };
    });
}
