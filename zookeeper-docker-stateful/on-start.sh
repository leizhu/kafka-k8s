#! /bin/bash

# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script configures zookeeper cluster member ship for version of zookeeper
# >= 3.5.0. It should not be used with the on-change.sh script in this example.
# As of April-2016 is 3.4.8 is the latest stable.

# Both /opt and /tmp/zookeeper are assumed to be volumes shared with the parent.
CFG=/opt/zookeeper/conf/zoo.cfg.dynamic
CFG_BAK=/opt/zookeeper/conf/zoo.cfg.bak
MY_ID_FILE=/tmp/zookeeper/myid
HOSTNAME=$(hostname)

while read -ra LINE; do
    PEERS=("${PEERS[@]}" $LINE)
done

# Don't add the first member as an observer
if [ ${#PEERS[@]} -eq 1 ]; then
    # We need to write our index in this list of servers into MY_ID_FILE.
    # Note that this may not always coincide with the hostname id.
    echo 1 > "${MY_ID_FILE}"
    echo "server.1=${PEERS[0]}:2888:3888;2181" > "${CFG}"
    # TODO: zkServer-initialize is the safe way to handle changes to datadir
    # because simply starting will create a new datadir, BUT if the user changed
    # pod template they might end up with 2 datadirs and brief split brain.
    exit
fi

# Every subsequent member is added as an observer and promoted to a participant
echo "" > "${CFG_BAK}"
i=0
for peer in "${PEERS[@]}"; do
    let i=i+1
    if [[ "${peer}" == *"${HOSTNAME}"* ]]; then
      MY_ID=$i
      MY_NAME=${peer}
      echo $i > "${MY_ID_FILE}"
      echo "server.${i}=${peer}:2888:3888:observer;2181" >> "${CFG_BAK}"
    else
      echo "server.${i}=${peer}:2888:3888:participant;2181" >> "${CFG_BAK}"
    fi
done

# Once the dynamic config file is written it shouldn't be modified, so the final
# reconfigure needs to happen through the "reconfig" command.
cp ${CFG_BAK} ${CFG}

sed -i "s/tickTime=2000/tickTime=4000/g" ${CFG}
sed -i "s/initLimit=10/initLimit=20/g" ${CFG}
sed -i "s/syncLimit=5/syncLimit=10/g" ${CFG}

# TODO: zkServer-initialize is the safe way to handle changes to datadir
# because simply starting will create a new datadir, BUT if the user changed
# pod template they might end up with 2 datadirs and brief split brain.
/opt/zookeeper/bin/zkServer.sh start

# TODO: We shouldn't need to specify the address of the master as long as
# there's quorum. According to the docs the new server is just not allowed to
# vote, it's still allowed to propose config changes, and it knows the
# existing members of the ensemble from *its* config. This works as expected,
# but we should correlate with more satisfying empirical evidence.
/opt/zookeeper/bin/zkCli.sh reconfig -add "server.$MY_ID=$MY_NAME:2888:3888:participant;2181"
/opt/zookeeper/bin/zkServer.sh stop
