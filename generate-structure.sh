#!/usr/bin/env bash
# Yes, Olivier M. dared write this script! Feel free to use it.

usage()
{
  echo "usage: $0 <remote dir> <local dir> [--help]"
  echo ""
  echo "<remote dir>	Path to the project's remote dir"
  echo "<local dir>	Path to the project's local dir"
  echo ""
  echo " -h, --help	Display this help"
  echo " -v, --version	Display the script version"
  echo ""
  echo "Example: $0 P:/PlateformeVehiculeElectrique ."
}

version()
{
  echo "$0 v0.0.1"
  echo "Generate project's repository structure."
}

remote_dir=
local_dir=
if [ "$#" -lt "1" ]; then
	echo "error: missing arguments"
	usage
	exit -1
fi
while [ "$1" != "" ]; do
case $1 in
	-v | --version )
		version
		exit 0
		;;
	-h | --help )
		version
		echo ''
		usage
		exit 0
		;;
	*)
	if [ "$remote_dir" == ""  ]; then
		remote_dir=$1
		shift
	elif [ "$local_dir" == ""  ]; then
		local_dir=$1
		shift
	else
		echo "error: unknwon argument $1"
		usage
		exit -1
	fi
	;;
esac
done
if [ "$local_dir" == "" ]; then
	echo "error: missing arguments"
	usage
	exit -1
fi

if [ ! -d "${remote_dir}" ]; then
    mkdir -p ${remote_dir}
    mkdir ${remote_dir}/00-Management
    mkdir ${remote_dir}/08-Delivery
fi

mkdir 00-Management
cd 00-Management
mkdir Contrat
mkdir Facture
mkdir Proposition
mkdir Proposition/Chiffrage
mkdir Proposition/Marketing
mkdir Suivi
echo 'Ce dossier est régulièrement copié dans le dossier du projet sur P grâce au script "../sync.sh".' > README
cd ..

mkdir 01-Requirement
mkdir 02-Specification
mkdir 03-Conception
mkdir 04-Workspace
mkdir 05-Test
mkdir 06-Integration
mkdir 07-Validation
mkdir Meetings
echo '#!/usr/bin/env bash' > sync.sh
echo '' >> sync.sh
echo 'rsync --verbose -r '${local_dir}'/00-Management/* '${remote_dir}'/00-Management' >> sync.sh
echo 'rsync --verbose -r '${local_dir}'/../08-Delivery/* '${remote_dir}'/08-Delivery' >> sync.sh
