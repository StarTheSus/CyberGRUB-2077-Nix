{
  description = "CyberGRUB-2077 theme for GRUB on NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        rec {
          # Default package using the samurai logo, I could make it nix
          # Since it's a flake and all but, maybe someone likes the original
          default = mkTheme { logo = "samurai"; };

          # Custom builder function to pick any logo from img/logos/
          # Basically mimicing what the `install.sh` is doing
          mkTheme =
            {
              logo ? "samurai",
            }:
            pkgs.stdenv.mkDerivation {
              pname = "cybergrub-2077";
              version = "1.0";

              src = ./.;

              installPhase = ''
                mkdir -p $out
                # Copy base theme files
                cp -r CyberGRUB-2077/* $out/

                # --- ICON PATCHES ---
                # Map the NixOS icon to the configurations submenu
                cp $out/icons/nixos.png $out/icons/submenu.png

                # Map the memtest icon to all possible NixOS memtest classes
                cp $out/icons/memtest.png $out/icons/Memtest86.png
                cp $out/icons/memtest.png $out/icons/Memtest86+.png

                # Apply custom logo if specified
                if [ -f "img/logos/${logo}.png" ]; then
                  cp -f "img/logos/${logo}.png" "$out/logo.png"
                fi
              '';
            };
        }
      );
    };
}
