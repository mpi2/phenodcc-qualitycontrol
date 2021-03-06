#! /bin/bash
#
# Copyright 2013 Medical Research Council Harwell.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
# @author Gagarine Yaikhom <g.yaikhom@har.mrc.ac.uk>
#

current_dir=`pwd`;

# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
SOURCE="${BASH_SOURCE[0]}"
DIR="$( dirname "$SOURCE" )"
while [ -h "$SOURCE" ]
do 
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
  DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd )"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

if [ $DIR = $current_dir ]
then
    echo "Cannot run script from the same directory where the script resides.";
    echo "Please run script from a different directory, e.g.,";
    echo "";
    echo "mkdir ~/deploy_dir";
    echo "cd ~/deploy_dir";
    echo "~/path/to/project/how-to-deploy/package.sh ~/path/to/project localhost";
    exit;
fi

src_dir=$1;
project=`basename ${src_dir}`;

case $2 in
    localhost) type=1
        ;;
    prince_dev) type=2
        ;;
    sandbox) type=3
        ;;
    beta) type=4
        ;;
    live) type=5
        ;;
    dev) type=6
        ;;
    live_110) type=7
        ;;
    *)
        echo "Please specify the build target."
        echo ""
        echo "    USAGE: package.sh source_dir [localhost | prince_dev | sandbox | beta | live | live_110 | dev]"
        exit
        ;;
esac

echo "Project name: ${project}";
echo "Source directory: ${src_dir}";
echo "--------------------------------------------------------------------------------";

echo "Copying project source directory...";
cp -Rf $1 ./;
cd ${project};
version=`grep -oP -m 1 -e '<version>\d{1,}\.[0-9]{1,}(\.[0-9]{1,})?' pom.xml | cut -d\> -f2`;
echo "Package version from pom.xml: ${version}";
echo "Setting source files to version...";

case `uname -s` in
    Darwin)
        sed -i "" "s/DCC_QC_VERSION/${version}/g" src/main/webapp/deploy.sh;
        sed -i "" "s/DCC_QC_VERSION/${version}/g" src/main/webapp/index.jsp;
        sed -i "" "s/DCC_QC_VERSION/${version}/g" src/main/webapp/viz/visualise.js;
        ;;
    *)
        sed -i "s/DCC_QC_VERSION/${version}/g" src/main/webapp/deploy.sh;
        sed -i "s/DCC_QC_VERSION/${version}/g" src/main/webapp/index.jsp;
        sed -i "s/DCC_QC_VERSION/${version}/g" src/main/webapp/viz/visualise.js;
        ;;
esac

echo "Cleaning project and remove unnecessary files and directories...";
mvn -q clean;
rm -Rf .git;
rm -Rf how-to-deploy nbactions.xml nb-configuration.xml README;
rm -f src/main/resources/*.{sh,sql};

echo "Generate optimised web application...";
cd src/main/webapp;
./deploy.sh;

echo "Cleaning web app...";
rm -f all-classes.js app.jsb3 deploy.sh dev.jsp dev.html;
rm -Rf app resources/sass;
rm -f resources/css/viz.css viz/visualise.js viz/yuicompressor-2.4.7.jar;
find resources/images -type f -iname "*.svg" -delete;

echo "Build war...";
cd ${current_dir}/${project};
mvn -q -DskipTests -P $2 package;

echo "Extracting war file, and deleting source directory";
cd ${current_dir};
mv ${current_dir}/${project}/target/${project}-${version}.war ./;
rm -Rf ${current_dir}/${project};

echo "All done...";
