	#!/system/bin/sh

# MagiskHide Props Config
# Copyright (c) 2018-2021 Didgeridoohan @ XDA Developers
# Licence: MIT

ADBPATH=/data/adb
MHPCPATH=$ADBPATH/mhpc
if [ "$INSTFN" ]; then
	LOGFILE=$MHPCPATH/propsconf_install.log
else
	LOGFILE=$MHPCPATH/propsconf.log
fi

# Checking Magisk Busybox
if [ -z "$INSTFN" ] && [ "$BOOTSTAGE" != "post" -a "$BOOTSTAGE" != "late" ]; then
	BBPATH=$ADBPATH/magisk/busybox
	if [ -f "$BBPATH" ]; then
		for ITEM in $($BBPATH --list | tail -n +3); do
			alias $ITEM="$BBPATH $ITEM"
		done
	fi
	if [ -f "$BBPATH" ]; then
		echo "" >> $LOGFILE 2>&1
		echo -e "$(date +"%Y-%m-%d %H:%M:%S.%3N") - Using $($BBPATH | head -1)." >> $LOGFILE 2>&1
		echo "$BBPATH" >> $LOGFILE 2>&1
	else
		echo "" >> $LOGFILE 2>&1
		echo -e "$(date +"%Y-%m-%d %H:%M:%S.%3N") - No Busybox found." >> $LOGFILE 2>&1
	fi
fi

# Finding file values, $1=file (with path), $2=string to look for
get_file_value() {
	if [ -f "$1" ]; then
		echo $(grep $2 $1) | sed "s|.*${2}||" | sed 's|\"||g'
	fi
}

# ======================== Variables ========================
MODULESPATH=$ADBPATH/modules
LATEFILE=$MHPCPATH/propsconf_late
if [ -z $SLOT ]; then
	CACHELOC=/cache
else
	CACHELOC=/data/cache
fi
if [ "$INSTFN" ]; then
	# Installation (config.sh)
	MODVERSION=$(echo $(get_file_value $TMPDIR/module.prop "version=") | sed 's|-.*||')
	POSTPATH=$ADBPATH/post-fs-data.d
	SERVICEPATH=$ADBPATH/service.d
	POSTFILE=$POSTPATH/propsconf_post
	POSTLATEFILE=$POSTPATH/propsconf_late
	UPDATELATEFILE=$MHPCPATH/propsconf_late_update
	ORIGLATEFILE=$MODPATH/common/propsconf_late
	CACHERM="
	$CACHELOC/propsconf_postfile.log
	$CACHELOC/propsconf.log
	$CACHELOC/propsconf_install.log
	$CACHELOC/propsconf_last.log
	"
	SETTINGSLIST="
	FINGERPRINTENB
	PRINTMODULE
	PRINTEDIT
	PRINTVEND
	PRINTCHK
	BASICATTEST
	BASICATTLIST
	BASICATTCUST
	DEVSIM
	PROPCOUNT
	PROPEDIT
	PROPBOOT
	REDEBUGGABLE
	RESECURE
	RETYPE
	RETAGS
	REBOOTMODE
	REMODE
	REVENDORMODE
	REHWC
	REHWCOUNTRY
	RESTATE
	REVERIFIEDBOOTSTATE
	REVENDORVERIFIEDBOOTSTATE
	RELOCKED
	REVERITYMODE
	REBOOTWARRANTY_BIT
	REBIT
	REVENDORBOOTWARRANTY_BIT
	REVENDORWARRANTY_BIT
	REVENDORDEVICE_STATE
	CUSTOMEDIT
	DELEDIT
	PRINTSTAGE
	PATCHSTAGE
	SIMSTAGE
	OPTIONSOFTBOOT
	PRINTSOFTBOOT
	PATCHSOFTBOOT
	SIMSOFTBOOT
	CUSTOMSOFTBOOT
	PROPSOFTBOOT
	OPTIONBOOT
	OPTIONCOLOUR
	OPTIONWEBP
	OPTIONWEBU
	OPTIONUPDATE
	OPTIONBACK
	BRANDSET
	NAMESET
	DEVICESET
	RELEASESET
	IDSET
	INCREMENTALSET
	DESCRIPTIONSET
	DISPLAYSET
	SDKSET
	MANUFACTURERSET
	MODELSET
	PARTPROPSSET
	REBOOTCHK
	"
	PROPSETTINGSLIST="
	MODULEFINGERPRINT
	SIMBRAND
	SIMNAME
	SIMDEVICE
	SIMRELEASE
	SIMID
	SIMINCREMENTAL
	SIMDESCRIPTION
	SIMDISPLAY
	SIMSDK
	SIMMANUFACTURER
	SIMMODEL
	CUSTOMPROPS
	CUSTOMPROPSPOST
	CUSTOMPROPSLATE
	CUSTOMPROPSDELAY
	DELETEPROPS
	"
else
	# Placeholder variables
	MODVERSIONPH=VER_PLACEHOLDER
	BINPH=BIN_PLACEHOLDER

	# Log variables
	LASTLOGFILE=$MHPCPATH/propsconf_last.log
	VLOGFILE=$MHPCPATH/propsconf_verbose.log
	VLASTLOGFILE=$MHPCPATH/propsconf_verbose_last.log
	TMPLOGLOC=$MHPCPATH/propslogs
	TMPLOGLIST="
	$MHPCPATH/defaultprops
	$CACHELOC/magisk.log
	$CACHELOC/magisk.log.bak
	$MHPCPATH/propsconf*
	$LATEFILE
	"
fi

TMPFSMOUNT=$(magisk --path)
MIRRORPATH=$TMPFSMOUNT/.magisk/mirror
SYSTEMFILE=$MODPATH/system.prop
RUNFILE=$MHPCPATH/script_check
UPDATECHECK=""
# Make sure that the terminal app used actually can see resetprop
if [ "$BOOTSTAGE" == "props" ]; then
	alias resetprop="$ADBPATH/magisk/magisk resetprop"
fi

# Fingerprint variables
PRINTSLOC=$MODPATH/common/prints.sh
PRINTSTMP=$MHPCPATH/prints.sh
PRINTSWWW="https://raw.githubusercontent.com/Magisk-Modules-Repo/MagiskHide-Props-Config/master/common/prints.sh"
PRINTSDEV="https://raw.githubusercontent.com/Didgeridoohan/Playground/master/prints.sh"
PRINTFILES=$MODPATH/printfiles
CSTMPRINTS=/data/media/0/printslist
CSTMFILE=$PRINTFILES/Custom.sh
EXPORTPATH=/data/media/0/mhpc
EXPORTFILE=$EXPORTPATH/propsconf_conf

# Known modules that edit device fingerprint
USNFLIST="
xiaomi-safetynet-fix
safetynet-fingerprint-fix
VendingVisa
DeviceSpoofingTool4Magisk
universal-safetynet-fix
samodx-safetyskipper
safetypatcher
petnoires-safetyspoofer
VR_Patch
PIXELARITY
"

# Configuration file locations
CONFFILELOC="
/data
$CACHELOC
/data/media/0
"

# Solo-run run options
SOLORUN="
d
f
h
l
r
s
u
"

# MagiskHide props
PROPSLIST="
ro.debuggable
ro.secure
ro.build.type
ro.build.tags
ro.boot.vbmeta.device_state
ro.boot.verifiedbootstate
ro.boot.flash.locked
ro.boot.veritymode
ro.boot.warranty_bit
ro.warranty_bit
ro.vendor.boot.warranty_bit
ro.vendor.warranty_bit
vendor.boot.vbmeta.device_state
"

# Trigger props
TRIGGERPROPS="
ro.bootmode
ro.boot.mode
vendor.boot.mode
ro.boot.hwc
ro.boot.hwcountry
"

# Triggering values
TRIGGERLIST="
ro.bootmode=recovery
ro.boot.mode=recovery
vendor.boot.mode=recovery
ro.boot.hwc=CN
ro.boot.hwcountry=China
"

# Late props
LATEPROPS="
vendor.boot.verifiedbootstate
"

# Partitions used for different props
PARTITIONS="
system
vendor
product
odm
system_ext
"

# Additional fingerprint prop parts
PRINTPROPSPARTS="
bootimage
"

# Print parts
PRINTPARTS="
ro.product.brand
ro.product.name
ro.product.device
ro.build.version.release
ro.build.id
ro.build.version.incremental
"

# Additional SafetyNet props
SNPROPS="
ro.build.version.security_patch
"

# Additional props
ADNPROPS="
ro.build.fingerprint
ro.vendor.build.fingerprint
ro.build.description
"

# Additional simulation props
ADNSIMPROPS1="
ro.build.display.id
ro.build.version.sdk
"
ADNSIMPROPS2="
ro.product.manufacturer
ro.product.model
"
ADNSIMPROPS=$ADNSIMPROPS1$ADNSIMPROPS2

# Android API level
APILVL="
4.2=17
4.3=18
4.4=19
5.0=21
5.1=22
6.0=23
7.0=24
7.1=25
8.0=26
8.1=27
9=28
10=29
11=30
12=31
"

# Values props list
VALPROPSLIST=$PROPSLIST$TRIGGERPROPS$LATEPROPS$PRINTPARTS$SNPROPS$ADNPROPS$ADNSIMPROPS

# Loading module settings
if [ -z "$INSTFN" ]; then
	. $LATEFILE
fi

# Add log divider
if [ "$BOOTSTAGE" != "post" ]; then
	echo "" >> $LOGFILE
	echo "==============================" >> $LOGFILE
fi

# ======================== General functions ========================
# Log functions, $1=Log text
# Print to log
log_handler() {
	if [ "$(id -u)" == 0 ] ; then
		echo "" >> $LOGFILE 2>&1
		echo -e "$(date +"%Y-%m-%d %H:%M:%S.%3N") - $1" >> $LOGFILE 2>&1
	fi
}

# Print to log and screen
log_print() {
	if [ "$INSTFN" ]; then
		ui_print "$1"
	else
		echo -e "$1"
	fi
	log_handler "$1"
}

# Print to controll file for boot scripts
log_script_chk() {
	log_handler "$1"
	echo -e "$(date +"%m-%d-%Y %H:%M:%S") - $1" >> $RUNFILE 2>&1
}

#Divider
DIVIDER="${Y}=====================================${N}"

# Header, $1=header text
menu_header() {
	# Don't clear screen if running from adb or if testing flag is active
	if [ -z "$ANDROID_SOCKET_adbd" ] && [ "$DEVTESTING" == "false" ]; then
		clear
	fi
	if [ "$MODVERSION" == "VER_PLACEHOLDER" ]; then
		VERSIONTXT=""
	else
		VERSIONTXT=$MODVERSION
	fi
	echo ""
	echo -e "${W}MagiskHide Props Config $VERSIONTXT${N}"
	echo -e "${W}by Didgeridoohan @ XDA Developers${N}"
	echo ""
	echo -e $DIVIDER
	echo -e " $1"
	echo -e $DIVIDER
}

# Get module version
module_v_ctrl() {
	VERSIONCMP=$(echo $MODVERSION | sed 's|v||g' | sed 's|\.||g')
	VERSIONTMP=$(echo $(get_file_value $MODPATH/module.prop "version="))
}

# Find prop type, $1=prop name
get_prop_type() {
	if [ "$1" == "ro.vendor.build.fingerprint" ]; then
		echo "vendprint"
	elif [ "$1" == "ro.build.display.id" ]; then
		echo "display"
	elif [ "$1" == "vendor.boot.mode" ]; then
		echo "vendormode"
	elif [ "$1" == "vendor.boot.vbmeta.device_state" ]; then
		echo "vendordevice_state"
	elif [ "$1" == "vendor.boot.verifiedbootstate" ]; then
		echo "vendorverifiedbootstate"
	elif [ "$1" == "ro.boot.warranty_bit" ]; then
		echo "bootwarranty_bit"
	elif [ "$1" == "ro.vendor.boot.warranty_bit" ]; then
		echo "vendorbootwarranty_bit"
	elif [ "$1" == "ro.vendor.warranty_bit" ]; then
		echo "vendorwarranty_bit"
	else
		echo $1 | sed 's|.*\.||' | sed 's|.*\_||'
	fi
}

# Get left side of =, $1=string to check
get_eq_left() {
	echo $1 | cut -f 1 -d '='
}

# Get right side of =, $1=string to check
get_eq_right() {
	echo $1 | cut -f 2- -d '='
}

# Get the list of print version, $1=Fingerprint device info with android versions
get_print_versions() {
	echo "$1" | sed 's|.*(||' | sed 's|).*||' | sed 's| \& | |g'
}

# Get Android version with 3 digits for input, $1=version string to convert to three digits
get_android_version() {
	VERTMP=$(echo $1 | sed 's|\.||g')
	if [ "${#VERTMP}" -lt 3 ]; then
		until [ "${#VERTMP}" == 3 ]; do
			VERTMP="$(echo ${VERTMP}0)"
		done
	fi
	echo $VERTMP
}

# Get security patch date for current fingerprint, $1=fingerprint string, including appended security patch date
get_sec_patch() {
	echo $1 | sed 's|.*\_\_||'
}

# Get the fingerprint for displaying in the ui, $1=fingerprint
get_print_display() {
	echo $1 | sed 's|\_\_.*||'
}

# Get prop value for custom props, $1=full prop string with name and value
get_prop_value() {
	echo "$(get_eq_right "$1")" | sed 's|_sp_| |g' | sed 's|\;.*$||'
}

# Get delay for custom props, $1=full prop string with name, value and delay. If no delay is set, 0 is returned
get_prop_delay() {
	TMPVAL="$(echo "$(get_eq_right "$1")" | sed 's|^.*\;||' | sed 's|\_\_.*$||')"
	if [ "$TMPVAL" ]; then
		echo "$TMPVAL"
	else
		echo "0"
	fi
}

# Get execution point for custom prop delay, $1=full prop string with name, value and delay
get_prop_delay_exec() {
	echo "$(get_eq_right "$1")" | sed 's|^.*\_\_||'
}

# Replace file values, $1=Variable to update, $2=Original variable value, $3=New variable value, $4=File, $5=control option for placeholder replacement
replace_fn() {
	if [ "$5" == "placeholder" ]; then
		sed -i "s|${1}PH=${2}|${1}=${3}|" $4 >> $LOGFILE 2>&1
	else
		sed -i "s|${1}=${2}|${1}=${3}|" $4 >> $LOGFILE 2>&1
	fi
}

# Format user files to remove Windows file endings, $1=file to format
format_file() {
	log_handler "Formating file (${1})."
	# Remove Windows line endings
	sed -i 's/\r$//' $1
	# Check for newline at EOF
	if [ ! -z "$(tail -c 1 "$1")" ]; then
		echo "" >> $1
	fi
}

# Reboot the device
force_reboot() {
	RBREASON=""
	if [ "$(get_file_value "$TMPFSMOUNT/.magisk/config" "RECOVERYMODE=")" == "true" ]; then
		RBREASON="recovery"
	fi
	echo ""
	echo -e "${C}Rebooting...${N}"
	log_handler "Rebooting."
	[ $(getprop sys.boot_completed) == 1 ] && /system/bin/svc power reboot $RBREASON >> $LOGFILE 2>&1 || /system/bin/reboot $RBREASON >> $LOGFILE 2>&1 || setprop sys.powerctl reboot >> $LOGFILE 2>&1
	if [ "$BOOTSTAGE" != "post" -a "$BOOTSTAGE" != "late" ]; then
		sleep 15
		log_handler "Rebooting failed."
		echo ""
		echo "That doesn't seem like it worked..."
		echo "Please reboot manually."
		echo ""
		exit 0
	fi
}

# Updates placeholders, $1=file, $2=Variable name to replace to, $3=Placeholder name, $4=Value to assign updated variable
placeholder_update() {
	log_handler "Checking for ${3} in ${1}."
	if [ -f "$1" ]; then
		FILEVALUE=$(get_file_value "$1" "${2}PH=")
		if [ "$FILEVALUE" ]; then
			case $FILEVALUE in
				*PLACEHOLDER*)	replace_fn $2 $3 $4 $1 "placeholder"
								log_handler "Placeholder ${3} updated to ${4} in ${1}."
				;;
			esac
		else
			log_handler "No placeholder to update for ${2} in ${1}."
		fi
	else
		log_handler "$1 does not exist."
	fi
}

# Check if boot scripts ran during boot
script_ran_check() {
	POSTCHECK=0
	if [ -f "$RUNFILE" ] && [ "$(grep "post-fs-data.sh module script finished" $RUNFILE)" ]; then
		POSTCHECK=1
	fi
	LATECHECK=0
	if [ -f "$RUNFILE" ] && [ "$(grep "service.sh module script finished" $RUNFILE)" ]; then
		LATECHECK=1
	fi
}

#Save default file values in propsconf_late
default_save(){
	#Format the props file
	log_handler "Formatting prop file."
	sed -i -e "s|\]\:\ \[|=|g;s|^\[||g;s|\]$||g" $MHPCPATH/defaultprops
	#Save the props values to $LATEFILE
	for ITEM in $VALPROPSLIST; do
		TMPPROP=$(get_prop_type $ITEM | tr '[:lower:]' '[:upper:]')
		ORIGPROP="ORIG${TMPPROP}"
		ORIGTMP="$(get_file_value $LATEFILE "${ORIGPROP}=")"
		CURRPROP="CURR${TMPPROP}"
		CURRTMP="$(get_file_value $MHPCPATH/defaultprops "${ITEM}=")"
		replace_fn $ORIGPROP "\"$ORIGTMP\"" "\"$CURRTMP\"" $LATEFILE
	done
}

# Check for original prop values
orig_check() {
	PROPSTMPLIST=$VALPROPSLIST
	ORIGLOAD=0
	for PROPTYPE in $PROPSTMPLIST; do
		PROP=$(get_prop_type $PROPTYPE)
		ORIGPROP=$(echo "ORIG${PROP}" | tr '[:lower:]' '[:upper:]')
		ORIGVALUE="$(echo ${ORIGPROP})"
		if [ "$ORIGVALUE" ]; then
			ORIGLOAD=1
			break
		fi
	done
}

# Load currently set values
curr_values() {
	for ITEM in $VALPROPSLIST; do
		CURRTMP=$(getprop $ITEM)
		TMPPROP=$(get_prop_type $ITEM | tr '[:lower:]' '[:upper:]')
		eval "CURR${TMPPROP}='$CURRTMP'"
		echo "${ITEM}: ${CURRTMP}" >> $LOGFILE 2>&1
	done
	if [ -z "$CURRFINGERPRINT" ]; then
		CURRFINGERPRINT=$(getprop ro.bootimage.build.fingerprint)
		if [ -z "$CURRFINGERPRINT" ]; then
			CURRFINGERPRINT=$(getprop ro.vendor.build.fingerprint)
		fi
		echo "ro.build.fingerprint: ${CURRFINGERPRINT}" >> $LOGFILE 2>&1
	fi
}

# Run all value loading functions
all_values() {
	log_handler "Loading values."
	# Currently set values
	curr_values
	# Module saved values
	. $LATEFILE
}

# Run before updated props/settings
before_change() {
	if [ -z "$INSTFN" ]; then
		echo ""
		echo -e "${C}Working. Please wait...${N}"
	fi
}

# Run after updated props/settings, $1=header, $2=Run options, $3=Reboot or not
after_change() {
	if [ "$2" == "file" ]; then
		# Load module settings
		. $LATEFILE
	elif [ "$2" != "none" ]; then
		# Update the reboot variable
		replace_fn REBOOTCHK 0 1 $LATEFILE
		# Load all values
		all_values
		# Update the system.prop file
		system_prop
		if [ "$3" != "noreboot" ] && [ ! "$INSTFN" ]; then
			# Ask to reboot
			reboot_fn "$1" "$2"
		fi
	fi
}

# Reboot function, $1=header, $2=Run options
reboot_fn() {
	INPUT5=""
	while true
	do
		if [ -z "$INPUT5" ]; then
			if [ "$2" == "reboot" ] || [ "$2" == "reset-script" ] || [ "$2" == "update" ]; then
				REBOOTTXT=""
			else
				REBOOTTXT="Reboot - "
			fi
			menu_header "$REBOOTTXT${C}$1${N}"
			echo ""
			if  [ "$2" != "reset-script" ] && [ "$2" != "reboot" ]; then
				if [ "$2" == "update" ]; then
					echo "The device fingerprint has been updated."
					echo ""
				fi
				echo "Reboot for changes to take effect."
				echo ""
			fi
			echo -e "Do you want to reboot now (${G}y/n${N})?"
			echo ""
			if [ "$2" == "p" ] || [ "$2" == "r" ] || [ "$2" == "reset-script" ]; then
				echo -en "Enter ${G}y${N}(es) or ${G}n${N}(o): "
				INV1=2
			else
				echo -en "Enter ${G}y${N}(es), ${G}n${N}(o) or ${G}e${N}(xit): "
				INV1=3
			fi
			read -r INPUT5
		fi
		case "$INPUT5" in
			y|Y) force_reboot
			;;
			n|N)
				if [ "$2" == "p" ] || [ "$2" == "r" ] || [ "$2" == "reset-script" ]; then
					exit_fn
				else
					INPUT2=""
					INPUT3=""
					INPUT4=""
					INPUT5=""
					INPUT6=""
					break
				fi
			;;
			e|E)
				if [ "$2" == "p" ] || [ "$2" == "r" ] || [ "$2" == "reset-script" ]; then
					invalid_input $INV1 5
				else
					exit_fn
				fi
			;;
			*) invalid_input $INV1 5
			;;
		esac
	done
}

# Reset module, $1=header, $2=Run options, $3=Reboot or not
reset_fn() {
	before_change

	cp -af $MODPATH/common/propsconf_late $LATEFILE >> $LOGFILE 2>&1
	if [ "$FINGERPRINTENB" ] && [ "$FINGERPRINTENB" != 1 ]; then
		replace_fn FINGERPRINTENB 1 $FINGERPRINTENB $LATEFILE
	fi

	if [ "$2" == "mismatch" ]; then
		log_handler "Saving device default values."
		default_save
		log_handler "Default values saved to $LATEFILE."
	fi

	log_handler "Settings cleared."

	after_change "$1" "$2" "$3"
}

# Checks for configuration file
config_file() {
	log_handler "Checking for configuration file."
	CONFFILE=""
	for ITEM in $CONFFILELOC; do
		if [ -s "$ITEM/propsconf_conf" ]; then
			CONFFILE="$ITEM/propsconf_conf"
			break
		fi
		if [ "$ITEM" == "/data/media/0" ]; then
			until [ -e "$ITEM/testfbe" ]; do
			   sleep 1
			   touch $ITEM/testfbe
			done
			rm -f $ITEM/testfbe >> $LOGFILE 2>&1
			if [ -s "$ITEM/propsconf_conf" ]; then
				CONFFILE="$ITEM/propsconf_conf"
				break
			fi
		fi
	done

	if [ "$CONFFILE" ]; then
		log_handler "Configuration file detected (${CONFFILE})."
		format_file $CONFFILE
		# Loads custom variables
		. $CONFFILE
		module_v_ctrl

		if [ "$CONFTRANSF" ] && [ $CONFTRANSF -le $VERSIONCMP ]; then
			# Check if vendor fingerprint is set
			if [ "$CONFVENDPRINT" == "true" ]; then
				log_handler "Using vendor fingerprint"
				CONFFINGERPRINT=$(getprop ro.vendor.build.fingerprint)
				echo "ro.vendor.build.fingerprint: ${CONFFINGERPRINT}" >> $LOGFILE 2>&1
			fi
			# Device fingerprint
			if [ "$CONFFINGERPRINT" ]; then
				if "$CONFFINGERPRINT" != "preserve" ] && [ "$FINGERPRINTENB" == 1 ]; then
					change_print "$PROPTYPE" "$TMPPROP" "file"
				fi
			else
				reset_print "$PROPTYPE" "file"
			fi

			# Updates sensitive props
			PROPSTMPLIST="$PROPSLIST$TRIGGERPROPS$LATEPROPS"
			for PROPTYPE in $PROPSTMPLIST; do
				CONFPROP=$(echo "CONF$(get_prop_type $PROPTYPE)" | tr '[:lower:]' '[:upper:]')
				TMPPROP=$(eval "echo \$$CONFPROP")
				if [ "$TMPPROP" == "true" ]; then
					change_prop "$PROPTYPE" "file"
				else
					reset_prop "$PROPTYPE" "file"
				fi
			done

			# Updates device simulation options, only if fingerprint editing is enabled
			if [ "$PRINTEDIT" == 1 ]; then
				# Fingerprint parts
				if [ "$CONFDEVSIM" == "true" ]; then
					change_dev_sim "Device simulation" "file"
					TMPPARTS=$PRINTPARTS$ADNSIMPROPS
					for ITEM in $TMPPARTS; do
						TMPVAR="CONF$(get_prop_type $ITEM | tr '[:lower:]' '[:upper:]')"
						if [ $(eval "echo \$$TMPVAR") == "true" ]; then
							TMPVAL=1
						else
							TMPVAL=0
						fi
						change_sim_prop "Device simulation" "$ITEM" "$TMPVAL" "file"
					done
				fi
				# Device description
				if [ "$CONFDESCRIPTION" == "true" ]; then
					change_sim_descr "Device simulation" 1 "file"
				else
					change_sim_descr "Device simulation" 0 "file"
				fi
				# Partition specific props
				if [ "$CONFPARTPROPS" == "true" ]; then
					change_sim_partprops "Device simulation" 1 "file"
				else
					change_sim_partprops "Device simulation" 0 "file"
				fi
			fi

			# Updates boot options for fingerprint and simulation props
			if [ "$PRINTEDIT" == 1 ]; then
				if [ "$CONFPRINTBOOT" == "default" ]; then
					OPTLCHNG=0
					TMPTXT="default"
				elif [ "$CONFPRINTBOOT" == "post" ]; then
					OPTLCHNG=1
					TMPTXT="post-fs-data"
				elif [ "$CONFPRINTBOOT" == "late" ]; then
					OPTLCHNG=2
					TMPTXT="late_start service"
				fi
				replace_fn PRINTSTAGE $PRINTSTAGE $OPTLCHNG $LATEFILE
				log_handler "Fingerprint boot stage is ${TMPTXT}."
				if [ "$CONFPATCHBOOT" == "default" ]; then
					OPTLCHNG=0
					TMPTXT="default"
				elif [ "$CONFPATCHBOOT" == "post" ]; then
					OPTLCHNG=1
					TMPTXT="post-fs-data"
				elif [ "$CONFPATCHBOOT" == "late" ]; then
					OPTLCHNG=2
					TMPTXT="late_start service"
				fi
				replace_fn PATCHSTAGE $PATCHSTAGE $OPTLCHNG $LATEFILE
				log_handler "Security patch boot stage is ${TMPTXT}."
			fi
			if [ "$DEVSIM" == 1 ]; then
				if [ "$CONFSIMBOOT" == "default" ]; then
					OPTLCHNG=0
					TMPTXT="default"
				elif [ "$CONFSIMBOOT" == "post" ]; then
					OPTLCHNG=1
					TMPTXT="post-fs-data"
				elif [ "$CONFSIMBOOT" == "late" ]; then
					OPTLCHNG=2
					TMPTXT="late_start service"
				fi
				replace_fn SIMSTAGE $SIMSTAGE $OPTLCHNG $LATEFILE
				log_handler "Device simulation boot stage is ${TMPTXT}."
			fi

			# Updates custom props
			if [ "$PROPOPTION" != "preserve" ]; then
				if [ "$CONFPROPS" ] || [ "$CONFPROPSPOST" ] || [ "$CONFPROPSLATE" ]; then
					if [ "$PROPOPTION" == "add" ] || [ "$PROPOPTION" == "replace" ]; then
						if [ "$PROPOPTION" == "replace" ]; then
							reset_all_custprop "file"
						fi
						if [ "$CONFPROPS" ]; then
							for ITEM in $CONFPROPS; do
								set_custprop "$(get_eq_left "$ITEM")" "$(get_eq_right "$ITEM")" "default" "file"
							done
						fi
						if [ "$CONFPROPSPOST" ]; then
							for ITEM in $CONFPROPSPOST; do
								set_custprop "$(get_eq_left "$ITEM")" "$(get_eq_right "$ITEM")" "post" "file"
							done
						fi
						if [ "$CONFPROPSLATE" ]; then
							for ITEM in $CONFPROPSLATE; do
								set_custprop "$(get_eq_left "$ITEM")" "$(get_eq_right "$ITEM")" "late" "file"
							done
						fi
					fi
				else
					reset_all_custprop "file"
				fi
			fi

			# Updates props to delete
			if [ "$DELPROPOPTION" != "preserve" ]; then
				if [ "$CONFDELPROPS" ]; then
					if [ "$DELPROPOPTION" == "add" ] || [ "$DELPROPOPTION" == "replace" ]; then
						if [ "$DELPROPOPTION" == "replace" ]; then
							reset_all_delprop "file"
						fi
						for ITEM in $CONFDELPROPS; do
							set_delprop "$ITEM" "file"
						done
					fi
				else
					reset_all_delprop "file"
				fi
			fi

			# Updates soft boot options
			if [ "$CONFOPTIONSOFTBOOT" == true ]; then
				OPTLCHNG=1
				TMPTXT="enabled"
			else
				OPTLCHNG=0
				TMPTXT="disabled"
			fi
			replace_fn OPTIONSOFTBOOT $OPTIONSOFTBOOT $OPTLCHNG $LATEFILE
			log_handler "Soft reboot option for late_start service boot stage $TMPTXT."
			if [ "$CONFPRINTSOFTBOOT" == true ]; then
				OPTLCHNG=1
				TMPTXT="enabled"
			else
				OPTLCHNG=0
				TMPTXT="disabled"
			fi
			replace_fn PRINTSOFTBOOT $PRINTSOFTBOOT $OPTLCHNG $LATEFILE
			log_handler "Soft reboot option for device fingerprint $TMPTXT."
			if [ "$CONFPATCHSOFTBOOT" == true ]; then
				OPTLCHNG=1
				TMPTXT="enabled"
			else
				OPTLCHNG=0
				TMPTXT="disabled"
			fi
			replace_fn PATCHSOFTBOOT $PATCHSOFTBOOT $OPTLCHNG $LATEFILE
			log_handler "Soft reboot option for security patch date $TMPTXT."
			if [ "$CONFSIMSOFTBOOT" == true ]; then
				OPTLCHNG=1
				TMPTXT="enabled"
			else
				OPTLCHNG=0
				TMPTXT="disabled"
			fi
			replace_fn SIMSOFTBOOT $SIMSOFTBOOT $OPTLCHNG $LATEFILE
			log_handler "Soft reboot option for device simulation $TMPTXT."
			if [ "$CONFCUSTOMSOFTBOOT" == true ]; then
				OPTLCHNG=1
				TMPTXT="enabled"
			else
				OPTLCHNG=0
				TMPTXT="disabled"
			fi
			replace_fn CUSTOMSOFTBOOT $CUSTOMSOFTBOOT $OPTLCHNG $LATEFILE
			log_handler "Soft reboot option for custom props $TMPTXT."
			if [ "$CONFPROPSOFTBOOT" == true ]; then
				OPTLCHNG=1
				TMPTXT="enabled"
			else
				OPTLCHNG=0
				TMPTXT="disabled"
			fi
			replace_fn PROPSOFTBOOT $PROPSOFTBOOT $OPTLCHNG $LATEFILE
			log_handler "Soft reboot option for sensitive props $TMPTXT."

			# Updates options
			# Boot stage
			if [ "$CONFBOOT" == "default" ]; then
				OPTLCHNG=0
				TMPTXT="default"
			elif [ "$CONFBOOT" == "post" ]; then
				OPTLCHNG=1
				TMPTXT="post-fs-data"
			elif [ "$CONFBOOT" == "late" ]; then
				OPTLCHNG=2
				TMPTXT="late_start service"
			fi
			replace_fn OPTIONBOOT $OPTIONBOOT $OPTLCHNG $LATEFILE
			log_handler "General boot stage is ${TMPTXT}."
			# Script colours
			if [ "$CONFCOLOUR" == "true" ]; then
				OPTCCHNG=1
			else
				OPTCCHNG=0
			fi
			replace_fn OPTIONCOLOUR $OPTIONCOLOUR $OPTCCHNG $LATEFILE
			log_handler "Colour is set to $CONFCOLOUR."
			# Fingerprints list update
			if [ "$CONFWEBP" == "true" ]; then
				OPTWCHNG=1
			else
				OPTWCHNG=0
			fi
			replace_fn OPTIONWEBP $OPTIONWEBP $OPTWCHNG $LATEFILE
			log_handler "Automatic fingerprints list update is set to $CONFWEBP."
			# Module update check
			if [ "$CONFWEBU" == "true" ]; then
				OPTWCHNG=1
			else
				OPTWCHNG=0
			fi
			replace_fn OPTIONWEBU $OPTIONWEBU $OPTWCHNG $LATEFILE
			log_handler "Module update check at start is set to $CONFWEBU."
			# Automatic fingerprints update
			if [ "$CONFUPDATE" == "true" ]; then
				OPTFCHNG=1
			else
				OPTFCHNG=0
			fi
			replace_fn OPTIONUPDATE $OPTIONUPDATE $OPTFCHNG $LATEFILE
			log_handler "Automatic fingerprint update is set to $CONFUPDATE."
		else
			log_handler "The configuration file is not compatible with the current module version ($CONFTRANSF vs $VERSIONCMP)."
		fi

		# Update the system.prop file
		system_prop

		# Deletes the configuration file
		log_handler "Deleting configuration file."
		for ITEM in $CONFFILELOC; do
			rm -f $ITEM/propsconf_conf >> $LOGFILE 2>&1
		done
		log_handler "Configuration file import complete."
		if [ "$BOOTSTAGE" == "late" ]; then
			force_reboot
		fi
	else
		log_handler "No configuration file."
	fi
}

# Connection test
test_connection() {
	case $1 in
		*nw*) # Don't run if the -nw run option is used.
		;;
		*)
			log_handler "Checking connection."
			ping -c 1 -W 1 raw.githubusercontent.com >> $LOGFILE 2>&1 && CNTTEST="true" || CNTTEST="false"
		;;
	esac
}

# Module update check
update_check() {
	case $2 in
		*nw*) # Don't run if the -nw run option is used.
		;;
		*)
			if [ "$1" == "manual" ]; then
				# Testing connection
				test_connection
			fi
			if [ "$CNTTEST" == "true" ]; then
				echo ""
				log_print "Checking for module update."
				MODPROPTMP=$MHPCPATH/module.prop
				MODPROPWWW="https://raw.githubusercontent.com/Magisk-Modules-Repo/MagiskHidePropsConf/master/module.prop"
				module_v_ctrl
				wget -T 5 -q -O $MODPROPTMP $MODPROPWWW >> $LOGFILE 2>&1
				MODVERTMP="$(echo $(get_file_value $MODPROPTMP "version=") | sed 's|-.*||' | sed 's|v||' | sed 's|\.||g')"
				if [ -s "$MODPROPTMP" ]; then
					if [ "$VERSIONCMP" -lt "$MODVERTMP" ]; then
						UPDATECHECK="There is a newer version of the module\navailable. Please update."
						log_print "Module update available."
					else
						if [ "$1" == "manual" ]; then
							UPDATECHECK="No update available."
						else
							UPDATECHECK=""
						fi
						log_print "No update available."
					fi
				elif [ -f "$MODPROPTMP" ]; then
					rm -f $MODPROPTMP >> $LOGFILE 2>&1
					log_print "! File not downloaded!"
					log_handler "File is empty."
				else
					log_print "! File not downloaded!"
				fi
			else
				log_handler "No connection."
			fi
			sleep 0.5
		;;
	esac
	rm -f $MODPROPTMP >> $LOGFILE 2>&1
}

# system.prop creation
system_prop() {
	if [ "$1" == "install" ]; then
		log_print "- Creating system.prop file."
	else
		log_handler "Creating system.prop file."
	fi
	echo -e "# This file will be read by resetprop\n# MagiskHide Props Config\n# Copyright (c) 2018-2021 Didgeridoohan @ XDA Developers\n# Licence: MIT" > $MODPATH/system.prop
	if [ "$PROPEDIT" == 1 ] && [ "$PROPBOOT" == 0 ]; then
		sensitive_props "$PROPSLIST" "$MODPATH/system.prop"
	fi
	if [ "$OPTIONBOOT" == 0 ] && [ "$PRINTSTAGE" == 0 ]; then
		print_edit "$MODPATH/system.prop"
	fi
	if [ "$OPTIONBOOT" == 0 ] && [ "$PATCHSTAGE" == 0 ]; then
		patch_edit "$MODPATH/system.prop"
	fi
	if [ "$OPTIONBOOT" == 0 ] && [ "$BASICATTEST" == 1 ]; then
			forced_basic "$MODPATH/system.prop"
		fi
	if [ "$OPTIONBOOT" == 0 ] && [ "$SIMSTAGE" == 0 ]; then
		dev_sim_edit "$MODPATH/system.prop"
	fi
	if [ "$OPTIONBOOT" == 0 ] && [ "$CUSTOMPROPS" ]; then
		custom_edit "CUSTOMPROPS" "$MODPATH/system.prop"
	fi
	# Check system.prop content
	system_prop_cont
}

# system.prop content
system_prop_cont() {
	if [ -f "$MODPATH/system.prop" ]; then
		log_handler "system.prop contents:"
		echo "----------------------------------------" >> $LOGFILE 2>&1
		cat $MODPATH/system.prop >> $LOGFILE 2>&1
		echo "----------------------------------------" >> $LOGFILE 2>&1
	else
		log_handler "No system.prop file present."
	fi
}

# ======================== Installation functions ========================
# Places and updates the settings file
settings_placement() {
	cp -af $ORIGLATEFILE $UPDATELATEFILE >> $LOGFILE 2>&1
	UPDATEV=$(get_file_value $UPDATELATEFILE "SCRIPTV=")
	UPDATETRANSF=$(get_file_value $UPDATELATEFILE "SETTRANSF=")
	NOTTRANSF=$(get_file_value $UPDATELATEFILE "NOTTRANSF=")
	if [ -f "$LATEFILE" ] && [ -d "$MODULESPATH/MagiskHidePropsConf" ]; then
		FILEV=$(get_file_value $LATEFILE "SCRIPTV=")
		FILETRANSF=$(get_file_value $LATEFILE "SETTRANSF=")
		LATEFILETMP="$LATEFILE"
	elif [ -f "$SERVICEPATH/propsconf_late" ]; then
		FILEV=$(get_file_value $SERVICEPATH/propsconf_late "SCRIPTV=")
		FILETRANSF=$(get_file_value $SERVICEPATH/propsconf_late "SETTRANSF=")
		LATEFILETMP="$SERVICEPATH/propsconf_late"
	else
		rm -f $LATEFILE >> $LOGFILE 2>&1
		FILEV=0
		FILETRANSF=$UPDATETRANSF
		LATEFILETMP="$LATEFILE"
	fi
	log_print "- Installing settings file"
	if [ "$FILEV" ]; then
		# New file
		if [ "$UPDATEV" -gt "$FILEV" ]; then
			# Fresh install
			if [ "$FILEV" == 0 ]; then
				log_print "- Placing settings file"
			# Updated file with a required clearing of settings
		elif [ "$UPDATETRANSF" -gt "$FILETRANSF" ] && [ -z "$NOTTRANSF" ]; then
				log_handler "Current transfer version - ${FILETRANSF}"
				log_handler "Update transfer version - ${UPDATETRANSF}"
				log_handler "No settings set to not transfer"
				log_print "- File updated and settings cleared"
			# Updated file
			else
				log_print "- File updated"
				log_print "- Transferring settings from old file"
				# Prop settings
				for ITEM in $SETTINGSLIST; do
					# Checking if a file update requires some options not to transfer
					case "$NOTTRANSF" in
						*$ITEM*)
							if [ "$UPDATETRANSF" -gt "$FILETRANSF" ]; then
								TRANSFOPT=1
							else
								TRANSFOPT=0
							fi
						;;
						*)
							TRANSFOPT=0
						;;
					esac
					if [ "$TRANSFOPT" == 1 ]; then
						log_handler "Not transfering settings for ${ITEM}."
					else
						SOLD=$(get_file_value $LATEFILETMP "${ITEM}=")
						SNEW=$(get_file_value $UPDATELATEFILE "${ITEM}=")
						if [ "$SOLD" ] && [ "$SOLD" != "$SNEW" ]; then
							log_handler "Setting ${ITEM} from ${SNEW} to ${SOLD}."
							sed -i "s|${ITEM}=${SNEW}|${ITEM}=${SOLD}|" $UPDATELATEFILE
							# Change post-fs-data execution between regular and background
							if [ "$ITEM" == "OPTIONBACK" -a "$SNEW" == 1 ]; then
								sed -i -e "s|^{|\#anch0}|;s|^\#anch1|{|;s|regular|background|" $MODPATH/post-fs-data.sh
							fi
						fi
					fi
				done
				# Prop values
				for ITEM in $PROPSETTINGSLIST; do
					SOLD=$(get_file_value $LATEFILETMP "${ITEM}=")
					if [ "$SOLD" ]; then
						log_handler "Setting ${ITEM} to ${SOLD}."
						sed -i "s|${ITEM}=\"\"|${ITEM}=\"${SOLD}\"|" $UPDATELATEFILE
					fi
				done
				# Prop and file edits
				for ITEM in $PROPSLIST; do
					ITEM="$(get_prop_type $ITEM)"
					REPROP=$(echo "RE${ITEM}" | tr '[:lower:]' '[:upper:]')
					SETPROP=$(echo "SET${ITEM}" | tr '[:lower:]' '[:upper:]')
					REOLD=$(get_file_value $LATEFILETMP "${REPROP}=")
					SETOLD=$(get_file_value $LATEFILETMP "${SETPROP}=")
					if [ "$REOLD" ] && [ "$REOLD" != "false" ]; then
						log_handler "Setting sensitive prop ${ITEM} to ${REOLD}."
						sed -i "s/${REPROP}=false/${REPROP}=${REOLD}/" $UPDATELATEFILE
					fi
					if [ "$SETOLD" ] && [ "$SETOLD" != "false" ]; then
						log_handler "Setting file edit ${ITEM} to ${SETOLD}."
						sed -i "s/${SETPROP}=false/${SETPROP}=${SETOLD}/" $UPDATELATEFILE
					fi
				done
			fi
			log_handler "Setting up settings file."
			if [ ! -d "$MHPCPATH" ]; then
				mkdir -pv $MHPCPATH >> $LOGFILE 2>&1
			fi
			mv -f $UPDATELATEFILE $LATEFILE >> $LOGFILE 2>&1
		# Downgraded file (flashed old module version)
		elif [ "$UPDATEV" -lt "$FILEV" ]; then
			log_print "- Settings cleared (file downgraded)"
			if [ ! -d "$MHPCPATH" ]; then
				mkdir -pv $MHPCPATH >> $LOGFILE 2>&1
			fi
			mv -f $UPDATELATEFILE $LATEFILE >> $LOGFILE 2>&1
		# No update of file
		else
			log_print "- Module settings preserved"
		fi
	else
		log_print "- Placing settings file"
		if [ ! -d "$MHPCPATH" ]; then
			mkdir -pv $MHPCPATH >> $LOGFILE 2>&1
		fi
		mv -f $UPDATELATEFILE $LATEFILE >> $LOGFILE 2>&1
	fi
	if [ -f "$SERVICEPATH/propsconf_late" ]; then
		log_handler "Old settings file found in $SERVICEPATH."
		rm -f $SERVICEPATH/propsconf_late >> $LOGFILE 2>&1
	fi
	rm -f $UPDATELATEFILE >> $LOGFILE 2>&1
}

# Checks for the Universal SafetyNet Fix module and similar modules editing device fingerprint
usnf_check() {
	log_print "- Checking for fingerprint conflicts"
	for USNF in $USNFLIST; do
		if [ -d "$MODULESPATH/$USNF" ]; then
			if [ ! -f "$MODULESPATH/$USNF/disable" ]; then
				NAME=$(get_file_value $MODULESPATH/$USNF/module.prop "name=")
				ui_print "!"
				log_print "! Module editing fingerprint detected!"
				log_print "! Module - '$NAME'!"
				log_print "! Fingerprint modification disabled!"
				ui_print "!"
				sed -i 's/FINGERPRINTENB=1/FINGERPRINTENB=0/' $LATEFILE
			fi
		fi
	done
}

# Check for the new Universal SafetyNet Fix
SNF_ctrl() {
	if [ -d "$MODULESPATH/safetynet-fix" ]; then
		TMPVER=$(echo $(get_file_value $MODULESPATH/safetynet-fix/module.prop "version=") | sed 's|v||g' | sed 's|\.||g')
		if [ "$TMPVER" -ge "210" ]; then
			log_handler "Found incompatible SafetyNet Fix. Disabling MagiskHide props."
			reset_prop_all "Disabling MagiskHide props" "install"
		fi
	fi
}

# Check for bin/xbin
bin_check() {
	$BOOTMODE && BINCHECK=$MIRRORPATH/system/xbin || BINCHECK=/system/xbin
	if [ -d "$BINCHECK" ]; then
		BIN=xbin
	else
		BIN=bin
	fi
	log_handler "Using /system/$BIN."
	mv -f $MODPATH/system/binpath $MODPATH/system/$BIN >> $LOGFILE 2>&1
}

# Function for removing screwed up and old files.
files_check() {
	if [ -f "$POSTLATEFILE" ]; then
		log_handler "Removing late_start service boot script from post-fs-data.d."
		rm -f $POSTLATEFILE >> $LOGFILE 2>&1
	fi
	if [ -f "$POSTFILE" ]; then
		log_handler "Removing old post-fs-data boot script from post-fs-data.d"
		rm -f $POSTFILE >> $LOGFILE 2>&1
	fi
	for ITEM in $CACHERM; do
		if [ -f "$ITEM" ]; then
			log_handler "Removing old log files ($ITEM)."
			rm -f $ITEM >> $LOGFILE 2>&1
		fi
	done
	if [ -f "$PRINTFILES/custom.sh" ]; then
		log_handler "Removing broken custom.sh file."
		rm -f $PRINTFILES/custom.sh >> $LOGFILE 2>&1
	fi
}

# Load module settings and reapply the MODPATH variable
load_settings() {
	log_handler "Loading/reloading module settings."
	if [ -f "$LATEFILE" ]; then
		. $LATEFILE
	fi
}

# Installs everything
script_install() {
	load_settings
	usnf_check
	SNF_ctrl
	bin_check
	files_check
	settings_placement

	log_print "- Updating placeholders"
	placeholder_update $MODPATH/post-fs-data.sh MODVERSION VER_PLACEHOLDER "$MODVERSION"
	placeholder_update $MODPATH/post-fs-data.sh LATEFILE LATE_PLACEHOLDER "$LATEFILE"
	placeholder_update $MODPATH/common/util_functions.sh MODVERSION VER_PLACEHOLDER "$MODVERSION"
	placeholder_update $MODPATH/common/util_functions.sh BIN BIN_PLACEHOLDER "$BIN"
	placeholder_update $MODPATH/system/$BIN/props ADBPATH ADB_PLACEHOLDER "$ADBPATH"
	placeholder_update $MODPATH/system/$BIN/props LATEFILE LATE_PLACEHOLDER "$LATEFILE"

	# Retrieving default values from props file
	log_print "- Saving device default values."
	default_save
	log_handler "Default values saved to $LATEFILE."

	load_settings
	print_files

	# Checks for configuration file
	CONFFILE=""
	for ITEM in $CONFFILELOC; do
		if [ -s "$ITEM/propsconf_conf" ]; then
			CONFFILE="$ITEM/propsconf_conf"
			break
		fi
	done
	if [ "$CONFFILE" ]; then
		load_settings
		ui_print "- Configuration file found."
		ui_print "- Installing..."
		ui_print ""
		config_file
	else
		load_settings
		# Create system.prop in case of no configuration file
		system_prop "install"
	fi

	log_handler "Script install function finished."
}

# ======================== Fingerprint functions ========================
# Get full device info from fingerprint string, $1=full fingerprint string, including device info
get_device() {
	echo $1 | cut -f 1 -d '=' | sed "s|\:.*$||"
}

# Get first word in fingerprint string, $1=full fingerprint string, including device info
get_first() {
	case $1 in
		*\ *) echo $1 | sed 's|\ .*||'
		;;
		*=*) get_device "$1"
		;;
	esac
}

# Get the device for current fingerprint, $1=fingerprint
get_device_used() {
	PRINTTMP=$(cat $MODPATH/common/prints.sh | grep "$1")
	if [ "$PRINTTMP" ]; then
		echo -e "${C}$(get_device "$PRINTTMP" | sed "s| (.*||")${N}"
		echo ""
	elif [ -s "$CSTMPRINTS" ]; then
		PRINTTMP=$(cat $CSTMPRINTS | grep "$1")
		if [ "$PRINTTMP" ]; then
			echo -e "${C}$(get_device "$PRINTTMP" | sed "s| (.*||")${N} (from custom list)"
			echo ""
		fi
	fi
}

# Set new fingerprint, $1=file to add prop info to
print_edit() {
	if [ "$1" != "none" ]; then
		before_change
	fi
	if [ "$FINGERPRINTENB" == 1 -o "$PRINTMODULE" == 0 ] && [ "$PRINTEDIT" == 1 ]; then
		log_handler "Changing fingerprint."
		if [ "$PRINTVEND" == 1 ]; then
			log_handler "Using vendor fingerprint (for Treble GSI ROMs)."
			PRINTCHNG="$(getprop ro.vendor.build.fingerprint)"
			# Set device simulation variables
			print_parts "$PRINTCHNG"
		else
			PRINTCHNG="$(echo $MODULEFINGERPRINT | sed 's|\_\_.*||')"
		fi
		# Changing props
		if [ "$(getprop "ro.build.fingerprint")" ]; then
			log_handler "Changing/writing ro.build.fingerprint."
			if [ "$1" != "none" ]; then
				echo "ro.build.fingerprint=${PRINTCHNG}" >> $1
			else
				resetprop -nv ro.build.fingerprint "$PRINTCHNG" >> $LOGFILE 2>&1
				if [ "$BOOTSTAGE" == "late" ] && [ "$PRINTSOFTBOOT" = 1 ]; then
					PROPLATE=true
				fi
			fi
		else
			log_handler "ro.build.fingerprint not currently set on device. Skipping."
		fi
		set_partition_props $1 "ro.build.fingerprint" $PRINTCHNG
		# Edit device description
		if [ "$DESCRIPTIONSET" == 1 ]; then
			if [ "$SIMDESCRIPTION" ]; then
				log_handler "Changing/writing ro.build.description."
				if [ "$1" != "none" ]; then
					echo "ro.build.description=${SIMDESCRIPTION}" >> $1
				else
					resetprop -nv ro.build.description "$SIMDESCRIPTION" >> $LOGFILE 2>&1
					if [ "$BOOTSTAGE" == "late" ] && [ "$PRINTSOFTBOOT" = 1 ]; then
						PROPLATE=true
					fi
				fi
			fi
		else
			log_handler "Changing/writing ro.build.description is disabled."
		fi
	fi
}

# Edit security patch date if included, $1=file to add prop info to
patch_edit() {
	if [ "$1" != "none" ]; then
		before_change
	fi
	if [ "$PRINTVEND" != 1 ]; then
		case "$MODULEFINGERPRINT" in
			*__*)
				SECPATCH="$(get_sec_patch $MODULEFINGERPRINT)"
				if [ "$SECPATCH" ]; then
					log_handler "Updating security patch date to match fingerprint used."
					if [ "$1" != "none" ]; then
						echo "ro.build.version.security_patch=${SECPATCH}" >> $1
					else
						resetprop -nv ro.build.version.security_patch "$SECPATCH" >> $LOGFILE 2>&1
						if [ "$BOOTSTAGE" == "late" ] && [ "$PATCHSOFTBOOT" = 1 ]; then
							PROPLATE=true
						fi
					fi
				fi
			;;
		esac
	fi
}

# Create fingerprint files
print_files() {
	if [ "$INSTFN" ]; then
		log_print "- Creating fingerprint files."
	else
		log_print "Creating fingerprint files."
	fi
	rm -rf $MODPATH/printfiles >> $LOGFILE 2>&1
	mkdir -pv $MODPATH/printfiles >> $LOGFILE 2>&1
	# Loading prints
	. $MODPATH/common/prints.sh
	# Saving manufacturers
	log_handler "Saving manufacturers."
	SAVEIFS=$IFS
	IFS=$(echo -en "\n\b")
	for ITEM in $PRINTSLIST; do
		TMPOEMLIST=$(echo "$OEMLIST $(get_first $ITEM)" | sed 's|^[ \t]*||')
		OEMLIST="$TMPOEMLIST"
	done
	IFS=$SAVEIFS
	TMPOEMLIST=$(echo $(printf '%s\n' $OEMLIST | sort -u))
	OEMLIST="$TMPOEMLIST"
	log_handler "Creating files."
	for OEM in $OEMLIST; do
		TMPFILE=$MODPATH/printfiles/${OEM}\.sh
		echo -e "PRINTSLIST=\"" >> $TMPFILE
		awk "/^$OEM/" $MODPATH/common/prints.sh >> $TMPFILE
		echo -e "\"" >> $TMPFILE
		TMPI=6
		while [ "$TMPI" -ge 4 ]; do
			TMPLINE=$(grep -m 1 "(${TMPI}" $TMPFILE)
			if [ "$TMPLINE" ]; then
				break
			else
				TMPI=$(($TMPI - 1))
			fi
		done
    echo -e "BASICATTMODEL=\"$(get_eq_left "$TMPLINE" | sed "s|^.*\:||")\"" >> $TMPFILE
	done
	# Check for updated fingerprint
	device_print_update "Updating module fingerprint."
}

# Check for and update used fingerprint, $1=header
device_print_update() {
	log_handler "$1"
	if [ "$OPTIONUPDATE" == 1 ]; then
		if [ "$FINGERPRINTENB" == 1 -o "$PRINTMODULE" == 0 ] && [ "$PRINTEDIT" == 1 ] && [ "$MODULEFINGERPRINT" ]; then
			TMPDEV="${SIMBRAND}/${SIMNAME}/${SIMDEVICE}"
			SAVEIFS=$IFS
			IFS=$(echo -en "\n\b")
			for ITEM in $PRINTSLIST; do
				case $ITEM in
					*$TMPDEV*)
						IFS=$SAVEIFS
						case $ITEM in
							*\;*)
								ITEMCOUNT=1
								ITEMFOUND=0
								TMPVPRINT="$(get_print_versions "$(get_eq_left "$ITEM")")"
								TMPVCURR="$(get_android_version $SIMRELEASE)"
								for V in $TMPVPRINT; do
									if [ "$(get_android_version $V)" == "$TMPVCURR" ]; then
										ITEMFOUND=1
										break
									fi
									ITEMCOUNT=$(($ITEMCOUNT+1))
								done
								if [ "$ITEMFOUND" == 1 ]; then
									TMPPRINT="$(get_eq_right "$ITEM" | cut -f $ITEMCOUNT -d ';')"
								else
									TMPPRINT=""
								fi
							;;
							*) TMPPRINT="$(get_eq_right "$ITEM")"
							;;
						esac
						break
					;;
				esac
			done
			IFS=$SAVEIFS
			if [ "$TMPDEV" ] && [ "$TMPPRINT" ]; then
				log_handler "Checking for updated fingerprint ($TMPDEV).\nCurrent - $MODULEFINGERPRINT\nUpdate - $TMPPRINT"
				if [ "$MODULEFINGERPRINT" != "$TMPPRINT" ]; then
					change_print "$1" "$TMPPRINT" "update"
					replace_fn PRINTCHK 0 1 $LATEFILE
					# Load module values
					. $LATEFILE
				else
					log_handler "No update available."
				fi
			else
				log_handler "Can't check for update."
			fi
		fi
	fi
}

# Checks and updates the prints list, $1=run option
download_prints() {
	case $2 in
		*nw*) # Don't run if the -nw run option is used.
		;;
		*)
			if [ "$1" == "Dev" ]; then
				PRINTSWWW=$PRINTSDEV
			fi
			menu_header "Updating fingerprints list"
			echo ""
			if [ "$1" == "manual" ]; then
				# Testing connection
				test_connection
			fi
			# Checking and downloading fingerprints list
			if [ "$CNTTEST" == "true" ]; then
				echo ""
				log_print "Checking list version."
				wget -T 5 -q -O $PRINTSTMP $PRINTSWWW >> $LOGFILE 2>&1
				if [ -s "$PRINTSTMP" ]; then
					LISTVERSION=$(get_file_value $PRINTSTMP "PRINTSV=")
					if [ "$LISTVERSION" ]; then
						if [ "$LISTVERSION" == "Dev" ] || [ "$1" == "f" -a "$(get_file_value $PRINTSLOC "PRINTSV=")" == "Dev" ] || [ "$LISTVERSION" -gt "$(get_file_value $PRINTSLOC "PRINTSV=")" ]; then
							module_v_ctrl
							if [ "$(get_file_value $PRINTSTMP "PRINTSTRANSF=")" -le $VERSIONCMP ]; then
								mv -f $PRINTSTMP $PRINTSLOC >> $LOGFILE 2>&1
								# Updates list version in module.prop
								replace_fn version $VERSIONTMP "${MODVERSION}-v${LISTVERSION}" $MODPATH/module.prop
								log_print "Updated list to v${LISTVERSION}."
								print_files
							else
								rm -f $PRINTSTMP >> $LOGFILE 2>&1
								log_print "New fingerprints list requires module update."
							fi
						else
							rm -f $PRINTSTMP >> $LOGFILE 2>&1
							log_print "Fingerprints list up-to-date."
						fi
					else
						rm -f $PRINTSTMP >> $LOGFILE 2>&1
						log_print "! File not downloaded!"
						log_handler "Couldn't extract list version."
					fi
				elif [ -f "$PRINTSTMP" ]; then
					rm -f $PRINTSTMP >> $LOGFILE 2>&1
					log_print "! File not downloaded!"
					log_handler "File is empty."
				else
					log_print "! File not downloaded!"
				fi
			else
				log_print "No connection."
			fi
			if [ "$1" == "manual" ]; then
				sleep 2
			else
				sleep 0.5
			fi
		;;
	esac
}

# Reset the module fingerprint change, $1=prop name, $2=run option
reset_print() {
	before_change

	log_handler "Resetting device fingerprint to default system value."

	# Saves new module valueS
	replace_fn MODULEFINGERPRINT "\"$MODULEFINGERPRINT\"" "\"\"" $LATEFILE
	# Updates vendor print setting
	replace_fn PRINTVEND 1 0 $LATEFILE
	# Updates prop change variables in propsconf_late
	replace_fn PRINTEDIT 1 0 $LATEFILE
	# Updates simulation setting
	replace_fn DEVSIM 1 0 $LATEFILE

	# Clear out device simulation variables
	print_parts "none"

	after_change "$1" "$2"
}

# Use fingerprint, $1=header, $2=fingerprint
change_print() {
	before_change

	log_handler "Changing device fingerprint to $2."

	# Saves new module values
	replace_fn MODULEFINGERPRINT "\"$MODULEFINGERPRINT\"" "\"$2\"" $LATEFILE

	# Updates prop change variables in propsconf_late
	replace_fn PRINTEDIT 0 1 $LATEFILE

	# Set device simulation variables
	print_parts "$2"

	NEWFINGERPRINT=""

	REBOOTCHK=""
	# Check if fingerprints testing is active
	if [ "$(get_file_value $PRINTSLOC "PRINTSV=")" == "Dev" ]; then
		REBOOTCHK="noreboot"
	fi

	after_change "$1" "$3" "$REBOOTCHK"
}

# Use vendor fingerprint, $1=header, $2=Current state of option (enabled or disabled)
change_print_vendor() {
	before_change

	if [ $2 == 1 ]; then
		STATETXT="Enabling"
		TMPVAL=0
		BUILD1="false"
		BUILD2="true"
	else
		STATETXT="Disabling"
		TMPVAL=1
		BUILD1="true"
		BUILD2="false"
	fi

	log_handler "$STATETXT using the stock vendor fingerprint (for Treble GSI ROMs)."

	# Enables or disables the setting
	replace_fn PRINTVEND $TMPVAL $2 $LATEFILE
	# Updates prop change variables in propsconf_late
	replace_fn PRINTEDIT $TMPVAL $2 $LATEFILE
	# Clearing out module value
	replace_fn MODULEFINGERPRINT "\"$MODULEFINGERPRINT\"" "\"\"" $LATEFILE
	# Updates simulation setting
	replace_fn DEVSIM $TMPVAL $2 $LATEFILE

	# Set device simulation variables
	print_parts "$ORIGVENDPRINT"

	after_change "$1" "$3"
}

# Save props values from fingerprint parts, $1=fingerprint
print_parts() {
	DLIM1=1
	DLIM2=1
	for ITEM in $PRINTPARTS; do
		TMPVALUE=""
		TMPPROP=$(get_prop_type $ITEM | tr '[:lower:]' '[:upper:]')
		if [ $1 != "none" ]; then
			TMPVALUE=$(echo $1 | sed 's|\:user\/release-keys.*||' | cut -f $DLIM1 -d ':' | cut -f $DLIM2 -d '/')
			eval "VAR${TMPPROP}='$TMPVALUE'"
		fi
		DLIM2=$(($DLIM2 + 1))
		if [ "$DLIM2" == 4 ]; then
			DLIM1=2
			DLIM2=1
		fi
		SUBA=$(get_file_value $LATEFILE "SIM${TMPPROP}=")
		replace_fn "SIM${TMPPROP}" "\"$SUBA\"" "\"$TMPVALUE\"" $LATEFILE
	done

	VARDESCRIPTION=""
	VARSDK=""
	if [ $1 != "none" ]; then
		VARDESCRIPTION="${VARNAME}-user $VARRELEASE $VARID $VARINCREMENTAL release-keys"
		for ITEM in $APILVL; do
			case $VARRELEASE in
				*$(get_eq_left $ITEM)*)
					VARSDK="$(get_eq_right $ITEM)"
					break
				;;
			esac
		done
	fi
	replace_fn SIMDESCRIPTION "\"$SIMDESCRIPTION\"" "\"$VARDESCRIPTION\"" $LATEFILE
	replace_fn SIMDISPLAY "\"$SIMDISPLAY\"" "\"$VARDESCRIPTION\"" $LATEFILE
	replace_fn SIMSDK "\"$SIMSDK\"" "\"$VARSDK\"" $LATEFILE
	TMPPARTS=$(get_eq_left "$(grep $1 $PRINTSLOC)" | sed 's|.*)\:||')
	if [ -z "$TMPPARTS" -a -s "$CSTMPRINTS" ]; then
		TMPPARTS=$(get_eq_left "$(grep $1 $CSTMPRINTS)" | sed 's|.*)\:||')
	fi
	if [ "$TMPPARTS" -a $(echo $TMPPARTS | grep -o "\:" | wc -l) == 1 ]; then
		replace_fn SIMMANUFACTURER "\"$SIMMANUFACTURER\"" "\"$(echo $TMPPARTS | cut -f 1 -d ':')\"" $LATEFILE
		replace_fn SIMMODEL "\"$SIMMODEL\"" "\"$(echo $TMPPARTS | cut -f 2 -d ':')\"" $LATEFILE
	else
		replace_fn SIMMANUFACTURER "\"$SIMMANUFACTURER\"" "\"\"" $LATEFILE
		replace_fn SIMMODEL "\"$SIMMODEL\"" "\"\"" $LATEFILE
	fi
	# Load module values
	. $LATEFILE
}

set_partition_props() {
	if [ "$2" == "ro.build.fingerprint" ]; then
		TMPLST=$PRINTPROPSPARTS$PARTITIONS
	else
		TMPLST=$PARTITIONS
	fi
	for PART in $TMPLST; do
		CNTP=1
		while [ $CNTP != 0 ]; do
			TMPPART="$(echo $2 | cut -f $CNTP -d ".")"
			if [ "$CNTP" == 1 ]; then
				TMPPROP="${TMPPART}.${PART}.$(echo "$2" | sed "s|${TMPPART}\.||")"
			else
				TMPPROP="$(echo "$2" | sed "s|\.${TMPPART}||").${PART}.${TMPPART}"
			fi
			if [ "$(getprop $TMPPROP)" ]; then
				log_handler "Changing/writing $TMPPROP."
				if [ "$1" != "none" ]; then
					echo "${TMPPROP}=${3}" >> $1
				else
					resetprop -nv $TMPPROP "$3" >> $LOGFILE 2>&1
				fi
			else
				log_handler "$TMPPROP not currently set on device. Skipping."
			fi
			if [ "$CNTP" == 1 ]; then
				CNTP=$(echo $2 | grep -o "\." | wc -l)
				CNTP=$(($CNTP + 1))
			else
				CNTP=0
			fi
		done
	done
}

# ======================== Force BASIC attestation ========================
# Find OEM print file
fn_oem_file() {
	# Find what brand is being used
	if [ "$FINGERPRINTENB" == 1 -o "$PRINTMODULE" == 0 ] && [ "$PRINTEDIT" == 1 ] && [ "$MODULEFINGERPRINT" ]; then
		BASICATTDEV="$SIMBRAND"
	else
		BASICATTDEV="$(getprop ro.product.brand)"
	fi
	# Find the OEM print file
	TMPFILE="$(ls $MODPATH/printfiles | grep -i $BASICATTDEV)"
	BASICATTMODEL="$(get_file_value "$MODPATH/printfiles/$TMPFILE" "BASICATTMODEL=")"
}

# Switch/set forced basic attestation, $1=header/file to change (system.prop), $2=model prop value from fingerprint, $3=custom model prop value, $4=reset flag
forced_basic() {
	if [ "$BASICATTCUST" ]; then
		BASICATTMODEL=$BASICATTCUST
	elif [ "$BASICATTLIST" ]; then
		BASICATTMODEL=$BASICATTLIST
	else
		fn_oem_file
	fi
	# Write or load values
	if [ "$1" != "none" ]; then
		if [ "$1" == "$MODPATH/system.prop" ]; then
			if [ "$BASICATTMODEL" ]; then
				TMPVAL="$BASICATTMODEL"
			else
				TMPVAL="$(getprop ro.product.device)"
			fi
			echo "ro.product.model=$TMPVAL" >> "$1"
			set_partition_props "$1" "ro.product.model" "$TMPVAL"
		else
			TMPVAL=1
			if [ "$BASICATTEST" == 0 ]; then
				log_handler "Enabling forced basic attestation."
				# Disabling ro.product.model simulation
				replace_fn "MODELSET" $MODELSET 0 $LATEFILE
			elif [ "$BASICATTEST" == 1 ] && [ -z "$2" ] && [ -z "$3" ] && [ "$4" != "reset" ]; then
				TMPVAL=0
				log_handler "Disabling forced basic attestation."
			fi

			# Enables or disables the settings
			replace_fn "BASICATTEST" $BASICATTEST $TMPVAL $LATEFILE
			replace_fn "BASICATTLIST" "\"$BASICATTLIST\"" "\"$2\"" $LATEFILE
			replace_fn "BASICATTCUST" "\"$BASICATTCUST\"" "\"$3\"" $LATEFILE

			after_change "$1"
		fi
	else
		if [ "$BASICATTMODEL" ]; then
			TMPVAL="$BASICATTMODEL"
		else
			TMPVAL="$(getprop ro.product.device)"
		fi
		resetprop -nv ro.product.model "$TMPVAL" >> $LOGFILE 2>&1
		set_partition_props "none" "ro.product.model" "$TMPVAL"
		if [ "$BOOTSTAGE" == "late" ] && [ "$OPTIONSOFTBOOT" = 1 ]; then
			PROPLATE=true
		fi
	fi
}

# Set a list value for forced basic attestation, $1=header, $2=model prop value
forced_list_confirm() {
	log_handler "Setting value for forced basic attestation to \"$2\" (from fingerprints list)."

	forced_basic "$1" "$2"
}

# Set a custom value for forced basic attestation, $1=header, $2=custom model prop value
forced_custom_confirm() {
	log_handler "Setting custom value for forced basic attestation to \"$2\"."

	forced_basic "$1" "" "$2"
}

# Reset the values for forced basic attestation, $1=header, $2=reset type
forced_reset() {
	LISTVAL="$BASICATTLIST"
	CUSTVAL="$BASICATTCUST"
	if [ "$2" == 1 ] || [ "$2" == 3 ]; then
		LISTVAL=""
		TMPTXT="list value"
	fi

	if [ "$2" == 2 ] || [ "$2" == 3 ]; then
		CUSTVAL=""
		TMPTXT="custom value"
	fi

	if [ "$2" == 3 ]; then
		TMPTXT="custom/list values"
	fi

	log_handler "Resetting $TMPTXT for forced basic attestation."

	forced_basic "$1" "$LISTVAL" "$CUSTVAL" "reset"
}

# ======================== Device simulation functions ========================
# Edit the simulation props, $1=file to edit (system.prop)
dev_sim_edit() {
	if [ "$1" != "none" ]; then
		before_change
	fi
	if [ "$FINGERPRINTENB" == 1 -o "$PRINTMODULE" == 0 ] && [ "$PRINTEDIT" == 1 ]; then
		if [ "$DEVSIM" == 1 ]; then
			log_handler "Editing device simulation props."
			TMPPARTS=$PRINTPARTS$ADNSIMPROPS
			for ITEM in $TMPPARTS; do
				TMPPROP=$(get_prop_type $ITEM | tr '[:lower:]' '[:upper:]')
				TMPENB=$(get_file_value $LATEFILE "${TMPPROP}SET=")
				TMPVALUE=$(get_file_value $LATEFILE "SIM${TMPPROP}=")
				if [ "TMPVALUE" ]; then
					if [ "$TMPENB" == 1 ] && [ "$TMPVALUE" ]; then
						if [ "$(getprop $ITEM)" ]; then
							log_handler "Changing/writing $ITEM."
							if [ "$1" != "none" ]; then
								echo "${ITEM}=${TMPVALUE}" >> $1
							else
								resetprop -nv $ITEM "$TMPVALUE" >> $LOGFILE 2>&1
								if [ "$BOOTSTAGE" == "late" ] && [ "$SIMSOFTBOOT" = 1 ]; then
									PROPLATE=true
								fi
							fi
						else
							log_handler "$ITEM not currently set on device. Skipping."
						fi
						if [ "$PARTPROPSSET" == 1 ]; then
							set_partition_props "$1" $ITEM "$TMPVALUE"
						fi
					else
						log_handler "Changing/writing $ITEM is disabled."
					fi
				else
					log_handler "No simulation value set for $ITEM."
				fi
			done
		fi
	fi
}

# Enable/disable the option, $1=header, $2=run option
change_dev_sim() {
	before_change

	if [ $DEVSIM == 0 ]; then
		STATETXT="Enabling"
		TMPVAL=1
	else
		STATETXT="Disabling"
		TMPVAL=0
	fi

	log_handler "$STATETXT basic device simulation."

	# Enables or disables the setting
	replace_fn "DEVSIM" $DEVSIM $TMPVAL $LATEFILE

	# Disables all simulation props
	if [ $TMPVAL == 0 ]; then
		TMPPARTS=$PRINTPARTS$ADNSIMPROPS
		for ITEM in $TMPPARTS; do
			change_sim_prop "Device simulation" "$ITEM" 0 "none"
		done
		system_prop
	fi

	after_change "$1" "$2"
}

# Change if prop should be simulated or not, $1=header, $2=prop name, $3=prop value, $4=run option
change_sim_prop() {
	before_change

	if [ $3 == 1 ]; then
		STATETXT="enabled"
	else
		STATETXT="disabled"
	fi
	log_handler "Changing device simulation prop $2 to $STATETXT."

	TMPPROP=$(get_prop_type $2 | tr '[:lower:]' '[:upper:]')
	SUBA=$(get_file_value $LATEFILE "${TMPPROP}SET=")

	# Saves new value
	replace_fn "${TMPPROP}SET" $SUBA $3 $LATEFILE

	after_change "$1" "$4"
}

# Change if description should be simulated or not, $1=header, $2=Check if option is enabled or disabled, $3=run option
change_sim_descr() {
	before_change

	if [ $2 == 1 ]; then
		STATETXT="enabled"
	else
		STATETXT="disabled"
	fi
	log_handler "Changing device description editing to $STATETXT."

	# Saves new value
	replace_fn DESCRIPTIONSET $DESCRIPTIONSET $2 $LATEFILE

	after_change "$1" "$3"
}

# Change if partition specific props should be simulated or not, $1=header, $2=Check if option is enabled or disabled, $3=run option
change_sim_partprops() {
	before_change

	if [ $2 == 1 ]; then
		STATETXT="enabled"
	else
		STATETXT="disabled"
	fi
	log_handler "Changing partition specific prop editing to $STATETXT."

	# Saves new value
	replace_fn PARTPROPSSET $PARTPROPSSET $2 $LATEFILE

	after_change "$1" "$3"
}

# ======================== MagiskHide Props functions ========================
# Populate menu, $1=List of props to go through, $2=type of list, $3=check if menu items should be printed or only counted
magiskhide_props_menu() {
	CHKCOUNT=true
	if [ "$3" == "count" ] && [ "$PROPEDIT" == 0 ]; then
		CHKCOUNT=false
	fi
	if [ "$CHKCOUNT" == "true" ]; then
		ACTIVETXT="${G} (active)${N}"
		ENABLEDTXT="${G} (enabled, not active)${N}"
		for ITEM in $1; do
			PROP=$(get_prop_type $ITEM)
			REVALUE=$(eval "echo \$$(echo "RE${PROP}" | tr '[:lower:]' '[:upper:]')")
			CURRVALUE=$(eval "echo \$$(echo "CURR${PROP}" | tr '[:lower:]' '[:upper:]')")
			ORIGVALUE=$(eval "echo \$$(echo "ORIG${PROP}" | tr '[:lower:]' '[:upper:]')")
			MODULEVALUE=$(eval "echo \$$(echo "MODULE${PROP}" | tr '[:lower:]' '[:upper:]')")
			if [ "$ORIGVALUE" ] && [ "$MODULEVALUE" != "$ORIGVALUE" ]; then
				CTRLTRIGG=true;
				if [ "$2" == "trigger" ]; then
					magiskhide_trigger "$ITEM"
				fi
				if [ "$CTRLTRIGG" == "true" ]; then
					if [ "$ITEMCOUNT" == 0 ]; then
						ITEMCOUNT=1
					fi
					if [ "$3" != "count" ]; then
						TMPTXT=""
						if [ "$2" == "late" ]; then
							TMPTXT=" ${C}(Late prop)${N}"
						elif [ "$2" == "trigger" ]; then
							TMPTXT=" ${C}(Trigger prop)${N}"
						fi
						if [ "$REVALUE" == 1 ] && [ "$CURRVALUE" != "$ORIGVALUE" ] && [ "$CURRVALUE" == "$MODULEVALUE" ]; then
							if [ "$TMPTXT" ]; then
								TMPTXT=$TMPTXT$ACTIVETXT
							else
								TMPTXT=$ACTIVETXT
							fi
						elif [ "$REVALUE" == 1 ]; then
							if [ "$TMPTXT" ]; then
								TMPTXT=$TMPTXT$ENABLEDTXT
							else
								TMPTXT=$ENABLEDTXT
							fi
							ENABLEDCOUNT=$(($ENABLEDCOUNT+1))
						fi
						echo -e "${G}$ITEMCOUNT${N} - ${ITEM}${TMPTXT}"
					fi
					ITEMCOUNT=$(($ITEMCOUNT+1))
				fi
			fi
		done
	fi
}

# Set sensitive props, $1=List to get props from, $2=Set to "late" if set in late stage, or file name if saving values to a prop file
sensitive_props() {
	if [ "$2" == "late" ]; then
		log_handler "Changing sensitive props, late"
	else
		log_handler "Changing sensitive props"
	fi
	for ITEM in $1; do
		PROP=$(get_prop_type $ITEM)
		REVALUE=$(eval "echo \$$(echo "RE${PROP}" | tr '[:lower:]' '[:upper:]')")
		ORIGVALUE=$(eval "echo \$$(echo "ORIG${PROP}" | tr '[:lower:]' '[:upper:]')")
		MODULEVALUE=$(eval "echo \$$(echo "MODULE${PROP}" | tr '[:lower:]' '[:upper:]')")
		if [ "$REVALUE" == 1 ] && [ "$ORIGVALUE" ]; then
			CTRLTRIGG=true;
			magiskhide_trigger "$ITEM"
			if [ "$CTRLTRIGG" == "true" ]; then
				if [ "$MODULEVALUE" == "$ORIGVALUE" ]; then
					log_handler "Skipping $ITEM, already set to the safe value ($MODULEVALUE)."
				else
					log_handler "Changing/writing $ITEM."
					if [ "$2" ] && [ "$2" != "late" ]; then
						echo "${ITEM}=$MODULEVALUE" >> $2
					else
						resetprop -nv $ITEM "$MODULEVALUE" >> $LOGFILE 2>&1
						if [ "$BOOTSTAGE" == "late" ] && [ "$PROPSOFTBOOT" = 1 ]; then
							PROPLATE=true
						fi
					fi
				fi
			else
				log_handler "Skipping $ITEM, it is not set to a triggering value (set to $ORIGVALUE)."
			fi
		elif [ "$REVALUE" == 1 ] && [ -z "$ORIGVALUE" ]; then
			log_handler "Skipping $ITEM, does not exist on device."
		else
			log_handler "Skipping $ITEM, not set to change."
		fi
	done
}

# Check if trigger prop, $1=prop to check
magiskhide_trigger() {
	for TRIGG in $TRIGGERLIST; do
		if [ "$(get_eq_left "$TRIGG")" == "$1" ]; then
			TRIGGVALUE=$(get_eq_right "$TRIGG")
			if [ "$TRIGGVALUE" != "$ORIGVALUE" ]; then
				CTRLTRIGG=false;
			fi
			break
		fi
	done
}

# Check safe values, $1=header, $2=Currently set prop value
safe_props() {
	SAFE=""
	if [ "$2" ]; then
		for P in $PROPSLIST$TRIGGERPROPS$LATEPROPS; do
			MODULEVALUE=$(eval "echo \$$(echo "MODULE$(get_prop_type $ITEM)" | tr '[:lower:]' '[:upper:]')")
			if [ "$P" == "$1" ]; then
				if [ "$2" == "$MODULEVALUE" ]; then
					SAFE=1
				else
					SAFE=0
				fi
				break
			fi
		done
	fi
}

# Find what prop value to change to, $1=header, $2=Currently set prop value
change_to() {
	for CHPROP in $PROPSLIST$TRIGGERPROPS$LATEPROPS; do
		MODULEVALUE=$(eval "echo \$$(echo "MODULE$(get_prop_type $CHPROP)" | tr '[:lower:]' '[:upper:]')")
		if [ "$CHPROP" == "$1" ]; then
			if [ "$2" != "$MODULEVALUE" ]; then
				CHANGE=$MODULEVALUE
			else
				CHANGE=$(eval "echo \$$(echo "ORIG$(get_prop_type $CHPROP)" | tr '[:lower:]' '[:upper:]')")
			fi
			break
		fi
	done
}

# Reset the module prop change, $1=prop name, $2=run option
reset_prop() {
	before_change

	# Sets variables
	REPROP=$(echo "RE$(get_prop_type $1)" | tr '[:lower:]' '[:upper:]')

	log_handler "Resetting $1 to default system value."

	# Changes prop
	replace_fn $REPROP 1 0 $LATEFILE

	# Updates prop change variables in propsconf_late
	if [ "$PROPCOUNT" -gt 0 ]; then
		PROPCOUNTP=$(($PROPCOUNT-1))
		replace_fn PROPCOUNT $PROPCOUNT $PROPCOUNTP $LATEFILE
	fi
	if [ "$PROPCOUNTP" == 0 ]; then
		replace_fn PROPEDIT 1 0 $LATEFILE
	fi

	if [ "$2" != "none" ]; then
		after_change "$1" "$2"
	fi
}

# Use prop value, $1=prop name, $3=run option
change_prop() {
	before_change

	# Sets variables
	REPROP=$(echo "RE$(get_prop_type $1)" | tr '[:lower:]' '[:upper:]')

	log_handler "Changing $1 to safe value."

	# Changes prop
	replace_fn $REPROP 0 1 $LATEFILE

	# Updates prop change variables in propsconf_late
	PROPCOUNTP=$(($PROPCOUNT+1))
	replace_fn PROPCOUNT $PROPCOUNT $PROPCOUNTP $LATEFILE
	replace_fn PROPEDIT 0 1 $LATEFILE

	if [ "$2" != "none" ]; then
		after_change "$1" "$2"
	fi
}

# Reset all module prop changes, $1=header, $2=Run option
reset_prop_all() {
	before_change

	log_handler "Resetting all props to default values."

	for PROPTYPE in $PROPSLIST$TRIGGERPROPS$LATEPROPS; do
		REPROP=$(echo "RE$(get_prop_type $PROPTYPE)" | tr '[:lower:]' '[:upper:]')

		# Changes prop
		replace_fn $REPROP 1 0 $LATEFILE
	done

	# Updates prop change variables in propsconf_late
	replace_fn PROPCOUNT $PROPCOUNT 0 $LATEFILE
	replace_fn PROPEDIT 1 0 $LATEFILE

	if [ "$2" != "install" ]; then
		after_change "$1"
	fi
}

# ======================== Custom Props functions ========================
# Set custom props, $1=custom type (default, post, late, delay) , $2=file to edit
custom_edit() {
	if [ "$2" ]; then
		before_change
	fi
	if [ "$1" ] && [ "$CUSTOMEDIT" == 1 ]; then
		TMPLST="$(get_file_value $LATEFILE "${1}=")"
		if [ "$TMPLST" ]; then
			log_handler "Writing custom props."
			for ITEM in $TMPLST; do
				TMPITEM=$(get_prop_value "$ITEM")
				if [ "$1" == "CUSTOMPROPSDELAY" ]; then
					{
						TMPBOOTTXT=""
						TMPDELAY=$(get_prop_delay "$ITEM")
						# Wait for "Boot completed", if enabled
						if [ "$(get_prop_delay_exec "$ITEM")" == "boot" ]; then
							TMPBOOTTXT=" after \"Boot completed\""
							until [ $(getprop sys.boot_completed) == 1 ]; do
								sleep 1
							done
						fi
						TMPI=1
						until [ "$TMPI" -gt "$TMPDELAY" ]; do
							sleep 1
							TMPI=$(($TMPI + 1))
						done
						log_handler "Changing/writing $(get_eq_left "$ITEM") with a delay of $TMPDELAY seconds${TMPBOOTTXT}."
						resetprop -nv $(get_eq_left "$ITEM") "${TMPITEM}" >> $LOGFILE 2>&1
					} &
				else
					log_handler "Changing/writing $(get_eq_left "$ITEM")."
					if [ "$2" ]; then
						echo "$(get_eq_left "$ITEM")=${TMPITEM}" >> $2
					else
						resetprop -nv $(get_eq_left "$ITEM") "${TMPITEM}" >> $LOGFILE 2>&1
						if [ "$BOOTSTAGE" == "late" ] && [ "$1" = "CUSTOMPROPSLATE" ]; then
							PROPLATE=true
						fi
					fi
				fi
			done
		fi
	fi
}

# Find custom props module set value, $1=prop name
custprop_value() {
	TMPLST="$CUSTOMPROPSLIST"
	if [ "$TMPLST" ]; then
		for ITEM in $TMPLST; do
			case "$ITEM" in
				*$1*)
					get_prop_value "$ITEM"
				;;
			esac
		done
	fi
}

# Set custom prop value, $1=prop name, $2=prop value , $3=boot stage , $4=original value, $5=delay, $6=exectuion timing ("boot completed" or now)
set_custprop() {
	before_change

	if [ "$2" ]; then
		# Reset the prop
		reset_custprop "$1" "$2" "bootstage"
		# Set the prop
		PROPSBOOTSTAGE="CUSTOMPROPS"
		PROPSTXT="default"
		if [ "$3" == "post" ]; then
			PROPSBOOTSTAGE="CUSTOMPROPSPOST"
			PROPSTXT="post-fs-data"
		elif [ "$3" == "late" ]; then
			PROPSBOOTSTAGE="CUSTOMPROPSLATE"
			PROPSTXT="late_start service"
		elif [ "$3" == "both" ]; then
			PROPSBOOTSTAGE="CUSTOMPROPSPOST CUSTOMPROPSLATE"
			PROPSTXT="post-fs-data/late_start service"
		elif [ "$3" == "delay" ]; then
			PROPSBOOTSTAGE="CUSTOMPROPSDELAY"
			PROPSTXT="late_start service"
		fi
		DELAYVAL=""
		DELAYLOG=""
		DELAYBOOT=""
		if [ "$3" == "delay" ] && [ "$5" ]; then
			DELAYVAL=";$5"
			DELAYLOG=", with a delay of $5 seconds"
		elif [ "$3" == "delay" ] && [ -z "$5" ]; then
			DELAYVAL=";0"
		fi
		if [ "$3" == "delay" ] && [ "$6" == "boot" ]; then
			DELAYBOOT="__boot"
		fi
		TMPVALUE=$(echo "$2" | sed 's| |_sp_|g')
		TMPORIG=$(echo "$4" | sed 's| |_sp_|g')
		DLIMTMP=1
		for ITEM in $PROPSBOOTSTAGE; do
			CURRCUSTPROPS=$(get_file_value $LATEFILE "${ITEM}=")
			TMPCUSTPROPS=$(echo "$CURRCUSTPROPS ${1}=${TMPVALUE}${DELAYVAL}${DELAYBOOT}" | sed 's|^[ \t]*||')
			SORTCUSTPROPS=$(echo $(printf '%s\n' $TMPCUSTPROPS | sort -u))

			log_handler "Setting custom prop $1 in $(echo $PROPSTXT | cut -f $DLIMTMP -d '/') stage${DELAYLOG}."
			replace_fn $ITEM "\"$CURRCUSTPROPS\"" "\"$SORTCUSTPROPS\"" $LATEFILE
			replace_fn CUSTOMEDIT 0 1 $LATEFILE
			DLIMTMP=$(($DLIMTMP + 1))
		done

		after_change "$1" "$4"
	fi
}

# Reset all custom prop values, $1=after_change option (run from configuration file or not)
reset_all_custprop() {
	before_change

	log_handler "Resetting all custom props."
	# Removing all custom props
	replace_fn CUSTOMPROPS "\"$CUSTOMPROPS\"" "\"\"" $LATEFILE
	replace_fn CUSTOMPROPSPOST "\"$CUSTOMPROPSPOST\"" "\"\"" $LATEFILE
	replace_fn CUSTOMPROPSLATE "\"$CUSTOMPROPSLATE\"" "\"\"" $LATEFILE
	replace_fn CUSTOMPROPSDELAY "\"$CUSTOMPROPSDELAY\"" "\"\"" $LATEFILE
	replace_fn CUSTOMEDIT 1 0 $LATEFILE

	after_change "Resetting all custom props" "$1"
}

# Reset custom prop value, $1=prop name, $2=prop value, $3=run after_change or not
reset_custprop() {
	before_change

	log_handler "Resetting custom prop $1."
	PROPSBOOTSTAGE="CUSTOMPROPS CUSTOMPROPSPOST CUSTOMPROPSLATE CUSTOMPROPSDELAY"
	TMPVALUE=$(echo "$2" | sed 's| |_sp_|g')

	for ITEM in $PROPSBOOTSTAGE; do
		CURRCUSTPROPS=$(get_file_value $LATEFILE "${ITEM}=")
		if [ "$CURRCUSTPROPS" ]; then
			TMPDELAY=""
			TMPBOOTEXEC=""
			if [ "$ITEM" == "CUSTOMPROPSDELAY" ]; then
				for PROP in $CURRCUSTPROPS; do
					case $PROP in
						*$TMPVALUE*)
							TMPDELAY=";$(get_prop_delay "$PROP")"
							case $PROP in
								*\_\_*)
									TMPBOOTEXEC="$(get_prop_delay_exec "$PROP")"
									if [ "$TMPBOOTEXEC" ]; then
										TMPBOOTEXEC="__$TMPBOOTEXEC"
									fi
								;;
							esac
							break
						;;
					esac
				done
			fi
			TMPCUSTPROPS=$(echo $CURRCUSTPROPS | sed "s|${1}=${TMPVALUE}${TMPDELAY}${TMPBOOTEXEC}||" | tr -s " " | sed 's|^[ \t]*||;s|[ \t]*$||')
			# Updating custom props string
			replace_fn $ITEM "\"$CURRCUSTPROPS\"" "\"$TMPCUSTPROPS\"" $LATEFILE
		fi
	done

	if [ -z "$CUSTOMPROPS" ] && [ -z "$CUSTOMPROPSPOST" ] && [ -z "$CUSTOMPROPSLATE" ] && [ -z "$CUSTOMPROPSDELAY" ]; then
		replace_fn CUSTOMEDIT 1 0 $LATEFILE
	fi

	if [ "$3" != "bootstage" ]; then
		after_change "$1"
	fi
}

# ======================== Delete Props functions ========================
# Delete props
prop_del() {
	if [ "$DELEDIT" == 1 ]; then
		log_handler "Deleting props."
		for ITEM in $DELETEPROPS; do
			log_handler "Deleting $ITEM."
			case "$ITEM" in
				persist*)
					resetprop -pv --delete $ITEM >> $LOGFILE 2>&1
				;;
				*)
					resetprop -v --delete $ITEM >> $LOGFILE 2>&1
				;;
			esac
		done
	fi
}

# Set prop to delete, $1=prop name, $2=run option
set_delprop() {
	if [ "$1" ]; then
		before_change

		TMPDELPROPS=$(echo "$DELETEPROPS  ${1}" | sed 's|^[ \t]*||')
		SORTDELPROPS=$(echo $(printf '%s\n' $TMPDELPROPS | sort -u))

		log_handler "Setting prop to delete, $1."
		replace_fn DELETEPROPS "\"$DELETEPROPS\"" "\"$SORTDELPROPS\"" $LATEFILE
		replace_fn DELEDIT 0 1 $LATEFILE

		after_change "Delete $1" "$2"
	fi
}

# Reset all props to delete, $1=run option
reset_all_delprop() {
	before_change

	log_handler "Resetting list of props to delete."
	# Removing all props to delete
	replace_fn DELETEPROPS "\"$DELETEPROPS\"" "\"\"" $LATEFILE
	replace_fn DELEDIT 1 0 $LATEFILE

	after_change "Reset all props to delete." "$1"
}

# Reset prop to delete, $1=prop name
reset_delprop() {
	before_change

	log_handler "Resetting prop to delete, $1."
	TMPDELPROPS=$(echo $DELETEPROPS | sed "s|${1}||" | tr -s " " | sed 's|^[ \t]*||')

	# Resetting prop to delete
	replace_fn DELETEPROPS "\"$DELETEPROPS\"" "\"$TMPDELPROPS\"" $LATEFILE
	# Loading new value
	. $LATEFILE
	if [ -z "$DELETEPROPS" ]; then
		replace_fn DELEDIT 1 0 $LATEFILE
	fi

	after_change "Reset prop to delete - $1"
}

# ======================== Options functions ========================
# Find value for export function, $1=Settings variable, $2=Type
export_value() {
	if [ "$2" == "stage" ]; then
		if [ "$(eval "echo \$$1")" == 0 ]; then
			TMP=default
		elif [ "$(eval "echo \$$1")" == 1 ]; then
			TMP=post
		else
			TMP=late
		fi
	elif [ "$2" == "binary" ]; then
		if [ "$(eval "echo \$$1")" == 0 ]; then
			TMP=false
		else
			TMP=true
		fi
	fi

	echo "$TMP"
}

# Export all settings to a module configuration file, $1=header
export_settings() {
	before_change
	log_handler "Exporting module settings to $EXPORTFILE."

	# Load settings
	. $LATEFILE

	# Create export directory
	rm -rf $EXPORTPATH >> $LOGFILE 2>&1
	mkdir -pv $EXPORTPATH >> $LOGFILE 2>&1

	# Create file and Delete instructions
	head -n 87 $MODPATH/common/propsconf_conf > $EXPORTFILE

	# Export settings
	# Fingerprint
	replace_fn CONFFINGERPRINT "\"\"" "\"$MODULEFINGERPRINT\"" $EXPORTFILE
	replace_fn CONFVENDPRINT false $(export_value PRINTVEND binary) $EXPORTFILE
	replace_fn CONFPRINTBOOT default $(export_value PRINTSTAGE stage) $EXPORTFILE
	replace_fn CONFPATCHBOOT late $(export_value PATCHSTAGE stage) $EXPORTFILE

	# Force BASIC attestation
	replace_fn CONFBASICATTEST false $(export_value BASICATTEST binary) $EXPORTFILE
	replace_fn CONFBASICATTCUST "\"\"" "\"$BASICATTCUST\"" $EXPORTFILE

	# Device Simulation
	replace_fn CONFDEVSIM false $(export_value DEVSIM binary) $EXPORTFILE
	replace_fn CONFBRAND false $(export_value BRANDSET binary) $EXPORTFILE
	replace_fn CONFNAME false $(export_value NAMESET binary) $EXPORTFILE
	replace_fn CONFDEVICE false $(export_value DEVICESET binary) $EXPORTFILE
	replace_fn CONFRELEASE false $(export_value RELEASESET binary) $EXPORTFILE
	replace_fn CONFID false $(export_value IDSET binary) $EXPORTFILE
	replace_fn CONFINCREMENTAL false $(export_value INCREMENTALSET binary) $EXPORTFILE
	replace_fn CONFDISPLAY false $(export_value DISPLAYSET binary) $EXPORTFILE
	replace_fn CONFSDK false $(export_value SDKSET binary) $EXPORTFILE
	replace_fn CONFMANUFACTURER false $(export_value MANUFACTURERSET binary) $EXPORTFILE
	replace_fn CONFMODEL false $(export_value MODELSET binary) $EXPORTFILE
	replace_fn CONFDESCRIPTION true $(export_value DESCRIPTIONSET binary) $EXPORTFILE
	replace_fn CONFPARTPROPS true $(export_value PARTPROPSSET binary) $EXPORTFILE
	replace_fn CONFSIMBOOT default $(export_value SIMSTAGE stage) $EXPORTFILE

	# MagiskHide sensitive props
	replace_fn CONFDEBUGGABLE true $(export_value REDEBUGGABLE binary) $EXPORTFILE
	replace_fn CONFSECURE true $(export_value RESECURE binary) $EXPORTFILE
	replace_fn CONFTYPE true $(export_value RETYPE binary) $EXPORTFILE
	replace_fn CONFTAGS true $(export_value RETAGS binary) $EXPORTFILE
	replace_fn CONFBOOTMODE true $(export_value REBOOTMODE binary) $EXPORTFILE
	replace_fn CONFMODE true $(export_value REMODE binary) $EXPORTFILE
	replace_fn CONFVENDORMODE true $(export_value REVENDORMODE binary) $EXPORTFILE
	replace_fn CONFHWC true $(export_value REHWC binary) $EXPORTFILE
	replace_fn CONFHWCOUNTRY true $(export_value REHWCOUNTRY binary) $EXPORTFILE
	replace_fn CONFSTATE true $(export_value RESTATE binary) $EXPORTFILE
	replace_fn CONFVERIFIEDBOOTSTATE true $(export_value REVERIFIEDBOOTSTATE binary) $EXPORTFILE
	replace_fn CONFVENDORVERIFIEDBOOTSTATE true $(export_value REVENDORVERIFIEDBOOTSTATE binary) $EXPORTFILE
	replace_fn CONFLOCKED true $(export_value RELOCKED binary) $EXPORTFILE
	replace_fn CONFVERITYMODE true $(export_value REVERITYMODE binary) $EXPORTFILE
	replace_fn CONFBOOTWARRANTY_BIT true $(export_value REBOOTWARRANTY_BIT binary) $EXPORTFILE
	replace_fn CONFBIT true $(export_value REBIT binary) $EXPORTFILE
	replace_fn CONFVENDORBOOTWARRANTY_BIT true $(export_value REVENDORBOOTWARRANTY_BIT binary) $EXPORTFILE
	replace_fn CONFVENDORWARRANTY_BIT true $(export_value REVENDORWARRANTY_BIT binary) $EXPORTFILE
	replace_fn CONFVENDORDEVICE_STATE true $(export_value REVENDORDEVICE_STATE binary) $EXPORTFILE

	# Custom props
	replace_fn CONFPROPS "\"\"" "\"$CUSTOMPROPS\"" $EXPORTFILE
	replace_fn CONFPROPSPOST "\"\"" "\"$CUSTOMPROPSPOST\"" $EXPORTFILE
	replace_fn CONFPROPSLATE "\"\"" "\"$CUSTOMPROPSLATE\"" $EXPORTFILE
	replace_fn CONFPROPSDELAY "\"\"" "\"$CUSTOMPROPSDELAY\"" $EXPORTFILE

	# Delete props
	replace_fn CONFDELPROPS "\"\"" "\"$DELETEPROPS\"" $EXPORTFILE

	# Soft reboot
	replace_fn CONFOPTIONSOFTBOOT false $(export_value OPTIONSOFTBOOT binary) $EXPORTFILE
	replace_fn CONFPRINTSOFTBOOT false $(export_value PRINTSOFTBOOT binary) $EXPORTFILE
	replace_fn CONFPATCHSOFTBOOT false $(export_value PATCHSOFTBOOT binary) $EXPORTFILE
	replace_fn CONFSIMSOFTBOOT false $(export_value SIMSOFTBOOT binary) $EXPORTFILE
	replace_fn CONFCUSTOMSOFTBOOT false $(export_value CUSTOMSOFTBOOT binary) $EXPORTFILE
	replace_fn CONFPROPSOFTBOOT false $(export_value PROPSOFTBOOT binary) $EXPORTFILE

	# Module settings
	replace_fn CONFBOOT default $(export_value OPTIONBOOT stage) $EXPORTFILE
	replace_fn CONFCOLOUR true $(export_value OPTIONCOLOUR binary) $EXPORTFILE
	replace_fn CONFWEBP true $(export_value OPTIONWEBP binary) $EXPORTFILE
	replace_fn CONFWEBU true $(export_value OPTIONWEBU binary) $EXPORTFILE
	replace_fn CONFUPDATE true $(export_value OPTIONUPDATE binary) $EXPORTFILE
	replace_fn CONFBACK false $(export_value OPTIONBACK binary) $EXPORTFILE

	log_handler "Export done."

	# Print info
	menu_header "${C}$1${N}"
	echo ""
	echo "A module configuration file with"
	echo "your current settings has been"
	echo "saved to your internal storage,"
	echo -e "in the ${C}/mhpc${N} directory."
	echo ""
	echo -n "Press enter to continue..."
	read -r INPUTTMP
}

# ======================== Log collecting functions ========================
# Collects useful logs and info for troubleshooting, $1=header, $2=Run as a command flag or not
collect_logs() {
	log_handler "Collecting logs and information."
	# Create temporary directory
	mkdir -pv $TMPLOGLOC >> $LOGFILE 2>&1

	# Saving Magisk and module log files and device original build.prop
	for ITEM in $TMPLOGLIST; do
		if [ -f "$ITEM" ]; then
			if [ "$ITEM" != "$MHPCPATH/propsconf.log" ]; then
				cp -af $ITEM ${TMPLOGLOC} >> $LOGFILE 2>&1
			fi
		else
			log_handler "$ITEM not available."
		fi
	done

	# Saving the current prop values
	getprop > $TMPLOGLOC/currentprops
	sed -i -e "s|\]\:\ \[|=|g;s|^\[||g;s|\]$||g" $TMPLOGLOC/currentprops

	# Saving the log file
	cp -af $MHPCPATH/propsconf.log $TMPLOGLOC >> $LOGFILE 2>&1

	# Package the files
	cd $MHPCPATH
	tar -zcvf propslogs.tar.gz propslogs >> $LOGFILE 2>&1

	# Copy package to internal storage
	cp -f $MHPCPATH/propslogs.tar.gz /storage/emulated/0 >> $LOGFILE 2>&1
	rm -f $MHPCPATH/propslogs.tar.gz >> $LOGFILE 2>&1

	# Remove temporary directory
	rm -rf $TMPLOGLOC >> $LOGFILE 2>&1

	log_handler "Logs and information collected."

	if [ "$1" != "issue" ]; then
		INPUTTMP=""
		menu_header "${C}$1${N}"
		echo ""
		echo "Logs and information collected."
		echo ""
		echo -e "The packaged file (${C}propslogs.tar.gz${N})"
		echo "has been saved to the root of your device's"
		echo "internal storage."
		echo "If it did not, please see the documentation"
		echo "for details on how to collect the logs"
		echo "manually."
		echo ""
		echo "Attach the file(s) to a post in the support"
		echo "thread @ XDA, with a detailed description"
		echo "of your issue."
		echo ""
		echo -n "Press enter to continue..."
		read -r INPUTTMP
		case "$INPUTTMP" in
			*)
				if [ "$2" == "l" ]; then
					exit_fn
				fi
			;;
		esac
	fi
}

# Log print
if [ "$BOOTSTAGE" != "post" ]; then
	log_handler "Functions loaded."
fi
