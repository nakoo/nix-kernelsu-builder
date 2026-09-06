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
            ./resources/kbuild-use-modern-lz4-flags.patch
          ];
          postPatch = ''
            substituteInPlace include/linux/susfs_def.h \
              --replace-fail "#define CMD_SUSFS_SUS_SU 0x60000" \
                "#define CMD_SUSFS_SUS_SU 0x60000
#define SUSFS_MAGIC 0xFAFA
#define CMD_SUSFS_ADD_SUS_PATH_LOOP 0x55553
#define CMD_SUSFS_HIDE_SUS_MNTS_FOR_NON_SU_PROCS 0x55561
#define CMD_SUSFS_ENABLE_AVC_LOG_SPOOFING 0x60010
#define CMD_SUSFS_ADD_SUS_MAP 0x60020

#include <linux/compiler.h>
static inline int susfs_add_sus_path_loop(void __user **arg) { return 0; }
static inline int susfs_set_hide_sus_mnts_for_non_su_procs(void __user **arg) { return 0; }
static inline int susfs_add_sus_map(void __user **arg) { return 0; }
static inline int susfs_set_avc_log_spoofing(void __user **arg) { return 0; }"
          '';
          kernelSrc = sources.linux-google-coral.src;
          oemBootImg = ./resources/coral-boot.img;
        };
      };
    };
}
