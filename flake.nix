{
  description = "Instant, easy, predictable shells and containers.";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    # golang 1.22.4 is not yet on unstable
    nixpkgs.url = "github:NixOS/nixpkgs/staging";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
  }:
    flake-utils.lib.eachDefaultSystem
    (system: let
      # pkgs is an alias for the nixpkgs at the system level. This will be used
      # for general utilities.
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      defaultPackage = pkgs.buildGoModule rec {
        pname = "devbox";
        version = "0.13.1";

        src = pkgs.fetchFromGitHub {
          owner = "jetpack-io";
          repo = pname;
          rev = version;
          hash = "sha256-dlZRxVUe9viHIuTK/E4zz2/iL0nxK4oT+Mhu6rIiKY0=";
        };

        ldflags = [
          "-s"
          "-w"
          "-X go.jetpack.io/devbox/internal/build.Version=${version}"
        ];

        # integration tests want file system access
        doCheck = false;

        vendorHash = "sha256-rwmNzYzmZqNcNVV4GgqCVLT6ofIkblVCMJHLGwlhcGw=";

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
