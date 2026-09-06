_: {
  perSystem =
    { pkgs, ... }:
    let
      sources = pkgs.callPackage _sources/generated.nix { };
    in
    {
      kernelsu = {
        google-coral = {
          anyKernelVariant = "osm0sis";
          clangVersion = "latest";
          kernelSU = {
            enable = true;
            variant = "resukisu-susfs";
          };
          susfs = {
            enable = true;
            inherit (sources.susfs-kernel-4_14) src;
            kernelsuPatch = null;
          };
          kernelConfig = ''
            CONFIG_KSU_MANUAL_HOOK=y
            CONFIG_LTO_CLANG_THIN=y
          '';
          kernelDefconfigs = [ "floral_defconfig" ];
          kernelImageName = "Image.lz4";
          kernelMakeFlags = [
            "KCFLAGS=\"-w\""
            "KCPPFLAGS=\"-w\""
            "LDFLAGS=--thinlto-jobs=1"
          ];
          kernelPatches = [
            ./resources/resukisu-manual-hooks-coral.patch
            ./resources/disable-floral-dtbo.patch
          ];
          kernelSrc = sources.linux-google-coral.src;
          oemBootImg = ./resources/coral-boot.img;
        };
      };
    };
}
