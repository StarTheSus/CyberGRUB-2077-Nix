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

              # for grub-mkfont
              nativeBuildInputs = [ pkgs.grub2 ];

              fontSrc = pkgs.fetchurl {
                url = "https://raw.githubusercontent.com/google/fonts/main/ofl/rajdhani/Rajdhani-Regular.ttf";
                hash = "sha256-bh/CKKgxglGm5WlQLsV7rB5GVsWC+S9ZzOzEaI4Dm5g=";
              };
              installPhase = ''
                mkdir -p $out
                cp -r CyberGRUB-2077/* $out/

                # --- FONT GENERATION ---
                # Generate smaller sizes and overwrite the original files in $out
                grub-mkfont -s 24 -o $out/Rajdhani_Regular_32.pf2 $fontSrc
                grub-mkfont -s 18 -o $out/Rajdhani_Regular_24.pf2 $fontSrc
                grub-mkfont -s 14 -o $out/Rajdhani_Regular_18.pf2 $fontSrc
                grub-mkfont -s 12 -o $out/Rajdhani_Regular_16.pf2 $fontSrc

                sed -i 's/Rajdhani Regular 32/Rajdhani Regular 24/g' $out/theme.txt
                sed -i 's/Rajdhani Regular 24/Rajdhani Regular 18/g' $out/theme.txt
                sed -i 's/Rajdhani Regular 18/Rajdhani Regular 14/g' $out/theme.txt
                sed -i 's/Rajdhani Regular 16/Rajdhani Regular 12/g' $out/theme.txt

                # --- ICON PATCHES ---
                cp $out/icons/nixos.png $out/icons/submenu.png

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
