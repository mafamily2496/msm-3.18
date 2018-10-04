#!/bin/bash
kernel_dir=$PWD
CCACHE=$(command -v ccache)
HOME=/home/ajaivasudeve
anykernel=$HOME/Moxie/anykernel-eas
ZIMAGE=$kernel_dir/out/arch/arm64/boot/Image.gz-dtb
CONFIG_FILE="z2_plus_defconfig"
kernel_name="Moxie"
kernel_version="EAS"
zip_name="$kernel_name-$kernel_version-$(date +"%Y%m%d").zip"
export ARCH=arm64
export SUBARCH=arm64
NC='\033[0m'
RED='\033[0;31m'
LGR='\033[1;32m'

export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=$HOME/Moxie/linaro/bin/aarch64-linux-gnu-
export CLANG_TCHAIN=$HOME/Moxie/dtc/bin/clang
export KBUILD_COMPILER_STRING="$(${CLANG_TCHAIN} --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"
export KBUILD_BUILD_USER="Ajai-Vasudeve"
export KBUILD_BUILD_HOST="Trash-Can"

cd $kernel_dir
    START=$(date +"%s")
    echo -e ${LGR} "############### Cleaning ################${NC}"
    make O=out clean 
    make O=out mrproper
    rm $anykernel/Image.gz-dtb
    rm -rf $ZIMAGE

    echo -e ${LGR} "############# Generating Defconfig ##############${NC}"
	make ARCH="arm64" O=out $CONFIG_FILE -j$(nproc --all)

	echo -e ${LGR} "############### Compiling kernel ################${NC}"
	make CC="${CCACHE} ${CLANG_TCHAIN}" O=out -j$(nproc --all)

	if [[ -f $ZIMAGE ]]; then
		mv -f $ZIMAGE $anykernel
        cd $anykernel
        find . -name "*.zip" -type f
        find . -name "*.zip" -type f -delete
        zip -r9 UPDATE-AnyKernel2.zip * -x README UPDATE-AnyKernel2.zip
        mv UPDATE-AnyKernel2.zip $zip_name
        mv $anykernel/$zip_name $HOME/Desktop/Moxie-Builds/$zip_name
        END=$(date +"%s")
        DIFF=$(($END - $START))
		echo -e ${LGR} "#################################################"
		echo -e ${LGR} "############### Build competed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds! #################"
		echo -e ${LGR} "#################################################${NC}"
	else
		echo -e ${RED} "#################################################"
		echo -e ${RED} "# Build failed, check warnings/errors! #"
		echo -e ${RED} "#################################################${NC}"
	fi
cd ${kernel_dir}