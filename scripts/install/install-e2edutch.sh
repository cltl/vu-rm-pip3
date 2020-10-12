set -e

usage() {
  echo "Usage: $0 github_sfx commit_nb targetdir" 1>&2
  exit 1
}

if [ $# -ne 3 ]; then
  usage
fi

#------------------------------------------------
scriptdir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

github_sfx=$1
commit_nb=$2
targetdir=$3
module=$(basename ${github_sfx})

$scriptdir/get-from-git.sh $github_sfx $commit_nb $targetdir
cd $targetdir/$module
pip install -r requirements.txt
./scripts/setup_all.sh
python setup.py install
