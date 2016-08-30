#!/usr/bin/env bash
# Yes, Olivier M. dared write this script! Feel free to use it.

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))

usage()
{
  cat << EOF
usage: ${PROGNAME} <remote dir> <local dir>


  <remote dir>		Path to the project's remote dir
  <local dir>		Path to the project's local dir

Options:
      --skip-remote	Skip creation of remote dir structure
			(00_Management, 08_Delivery) and versioned
			workspace (04_WorkspaceSVN)
  -h, --help		Display this help
  -v, --version		Display the script version

Examples:
  Generate "MyProject" repository structure
  ${PROGNAME} P:/MyProject C:/Project/MyProject
  
    This will create in "P:/MyProject":
      00_Management	// Management (contrat, proposition, ...) documents
      04_WorkspaceSVN	// Versioned workspace for document sharing, using SVN)
      08_Delivery	// Delivered documents
      
    And in "C:/Project/MyProject":
      00_Management
      00_Management/Contrat
      00_Management/Facture
      00_Management/Proposition
      00_Management/Proposition/Chiffrage
      00_Management/Proposition/Marketing
      00_Management/Suivi
      01_Requirement
      02_Specification
      03_Conception
      04_Workspace
      05_Test
      06_Integration
      07_Validation
      Inputs_Trialog
      Meetings
      synch.sh		// Script to synchronize  04_Workspace/00_Management
			   with remote 00_Management
EOF
}

version()
{
  cat << EOF
${PROGNAME} v0.0.2
Generate project's repository structure
EOF
}

logCritical()
{
  echo $1
  exit 100
}

REMOTE_DIR=
REMOTE_WORKSPACE=
SKIP_REMOTE=0
LOCAL_DIR=
LOCAL_WORKSPACE=
if [ "$#" -lt "1" ]; then
	echo "error: missing arguments"
	usage
	exit 2
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
	--skip-remote )
		SKIP_REMOTE=1
		shift
		;;
	*)
	if [ "$REMOTE_DIR" == ""  ]; then
		REMOTE_DIR=$1
		shift
		if [ ! -d "${REMOTE_DIR}" ]; then
		    echo "error: unexisting remote dir \"${REMOTE_DIR}\""
		    exit 3
		fi
	elif [ "$LOCAL_DIR" == ""  ]; then
		LOCAL_DIR=$1
		shift
		if [ ! -d "${LOCAL_DIR}" ]; then
		    mkdir -p ${LOCAL_DIR}
		fi
	else
		echo "error: unknwon argument $1"
		usage
		exit 1
	fi
	;;
esac
done
if [ "${LOCAL_DIR}" == "" ]; then
	echo "error: missing arguments"
	usage
	exit 2
fi
REMOTE_WORKSPACE=${REMOTE_DIR}/04_WorkspaceSVN
REMOTE_MANAGEMENT=${REMOTE_DIR}/00_Management
REMOTE_DELIVERY=${REMOTE_DIR}/08_Delivery
LOCAL_WORKSPACE=${LOCAL_DIR}/04_Workspace
LOCAL_MANAGEMENT=${LOCAL_WORKSPACE}/00_Management
LOCAL_DELIVERY=${LOCAL_DIR}/08_Delivery

# Remote dir
############
if [ "${SKIP_REMOTE}" == "0" ]; then
  echo ""
  echo "# Create management and delivery dir"
  if [ ! -d "${REMOTE_MANAGEMENT}" ]; then mkdir ${REMOTE_MANAGEMENT} ; fi
  if [ ! -d "${REMOTE_DELIVERY}" ]; then mkdir ${REMOTE_DELIVERY} ; fi
  
  echo ""
  echo "# Create versioned workspace"
  svnadmin create ${REMOTE_WORKSPACE} \
    || logCritical "error: cannot create the SVN repository"
fi

# Local dir
############
echo ""
echo "# First init the versioned workspace with SVN"
# because apparently "svnadmin create" does not really create the trunk...
# Strange, but that's the only workaround I found for now.
svn checkout file://${REMOTE_WORKSPACE} ${LOCAL_DIR}/XX_tmp \
  || logCritical "error: cannot checkout the SVN repository localy"
cd ${LOCAL_DIR}/XX_tmp || logCritical "error: cannot go to \"${LOCAL_DIR}/XX_tmp\""
touch test
svn add test
svn commit -m "Init the SVN repository"
cd ${PROGDIR} || logCritical "error: cannot go to \"${PROGDIR}\""
rm -rf ${LOCAL_DIR}/XX_tmp

echo ""
echo "# Create delivery dir and syncronisation script"
if [ ! -d "${LOCAL_DELIVERY}" ]; then mkdir ${LOCAL_DELIVERY} ; fi
cat << EOF > ${LOCAL_DIR}/sync.sh
#!/usr/bin/env bash

echo `date` \
  > ${LOCAL_DIR}/cron.log

echo ""
echo "Synchronise 'Management'"
rsync -avrltD --stats --human-readable \
  ${LOCAL_MANAGEMENT}/* \
  ${REMOTE_MANAGEMENT} \
  | pv -lep -s 42 \
  >> ${LOCAL_DIR}/cron.log

echo ""
echo "Synchronise 'Delivery'"
rsync -avrltD --stats --human-readable \
  ${LOCAL_DELIVERY}/* \
  ${REMOTE_DELIVERY} \
  | pv -lep -s 42 \
  >> ${LOCAL_DIR}/cron.log
EOF

echo ""
echo "# Clone versioned workspace"
git svn clone file://${REMOTE_WORKSPACE} ${LOCAL_WORKSPACE} \
  || logCritical "error: cannot clone the SVN repository localy"
cat << EOF > ${LOCAL_WORKSPACE}/.gitignore
.project
.tmp
~*
.~lock.*
*.ldb
*.un~
EOF

echo ""
echo "# Create the folder structure into the versioned workspace"
mkdir ${LOCAL_MANAGEMENT}
mkdir ${LOCAL_MANAGEMENT}/Contrat
touch ${LOCAL_MANAGEMENT}/Contrat/.gitkeep
mkdir ${LOCAL_MANAGEMENT}/Facture
touch ${LOCAL_MANAGEMENT}/Facture/.gitkeep
mkdir ${LOCAL_MANAGEMENT}/Proposition
mkdir ${LOCAL_MANAGEMENT}/Proposition/Chiffrage
touch ${LOCAL_MANAGEMENT}/Proposition/Chiffrage/.gitkeep
mkdir ${LOCAL_MANAGEMENT}/Proposition/Marketing
touch ${LOCAL_MANAGEMENT}/Proposition/Marketing/.gitkeep
mkdir ${LOCAL_MANAGEMENT}/Suivi
touch ${LOCAL_MANAGEMENT}/Suivi/.gitkeep
echo 'Ce dossier est régulièrement copié dans le dossier du projet sur P grâce au script "../sync.sh".' > ${LOCAL_MANAGEMENT}/README
mkdir ${LOCAL_WORKSPACE}/01_Requirement
mkdir ${LOCAL_WORKSPACE}/01_Requirement/.gitkeep
mkdir ${LOCAL_WORKSPACE}/02_Specification
mkdir ${LOCAL_WORKSPACE}/02_Specification/.gitkeep
mkdir ${LOCAL_WORKSPACE}/03_Conception
mkdir ${LOCAL_WORKSPACE}/03_Conception/.gitkeep
mkdir ${LOCAL_WORKSPACE}/04_Workspace
mkdir ${LOCAL_WORKSPACE}/04_Workspace/.gitkeep
mkdir ${LOCAL_WORKSPACE}/05_Test
mkdir ${LOCAL_WORKSPACE}/05_Test/.gitkeep
mkdir ${LOCAL_WORKSPACE}/06_Integration
mkdir ${LOCAL_WORKSPACE}/06_Integration/.gitkeep
mkdir ${LOCAL_WORKSPACE}/07_Validation
mkdir ${LOCAL_WORKSPACE}/07_Validation/.gitkeep
mkdir ${LOCAL_WORKSPACE}/Inputs_Trialog
mkdir ${LOCAL_WORKSPACE}/Inputs_Trialog/.gitkeep
mkdir ${LOCAL_WORKSPACE}/Meetings
mkdir ${LOCAL_WORKSPACE}/Meetings/.gitkeep

echo ""
echo "# Commit and push"
cd ${LOCAL_WORKSPACE} || logCritical "error: cannot go to \"${LOCAL_WORKSPACE}\""
git rm test
git add .gitignore *
git commit -m "First commit"
git svn dcommit \
  || logCritical "error: cannot commit change to the SVN repository"
cd ${PROGDIR} || logCritical "error: cannot go to \"${PROGDIR}\""

echo ""
echo -e "\e[1;32mdone\e[0m"
exit 0