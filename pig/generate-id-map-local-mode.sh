#
# Copyright 2013 Internet Archive
#
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License. You
# may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied. See the License for the specific language governing
# permissions and limitations under the License.
#

#!/usr/bin/env sh
#if [ $# != 2 ] ; then
#    echo "usage: generate-ip-map-local-mode.sh <I_LINK_DATA_DIR> <O_ID_MAP_DIR>"
#    echo "I_LINK_DATA_DIR: Input directory containing the canonicalized link data (gzip compressed)"
#    echo "O_ID_MAP_DIR: Output directory where the ID-Map will be stored (gzip compressed)""
#fi

#command line args
I_LINK_DATA_DIR=congress109th-sample/canonicalized-link-data.gz/
O_ID_MAP_DIR=congress109th-sample/id.map.gz/

#create output dir
mkdir -p $O_ID_MAP_DIR

#set output file
OUTPUTFILE=$O_ID_MAP_DIR/part-m-00000.gz

# grab all src and dst URLs, sort-uniq, and then assign IDs
zcat $I_LINK_DATA_DIR/part* | cut -f1,3 | tr '\t' '\n' | sort | uniq | cat -n | sed "s/^ *//" | gzip > $OUTPUTFILE

