#!/bin/bash
pushd /mnt/nfs4/DATASETS/PLF/PLF4_WEEKLY/scripts/PLF41x

if [ -f init/continue.continue.continue ]; then rm init/continue.continue.continue; fi
pushd init; ./init.sh ; popd
pushd user; ./inj_user.sh ; popd
pushd login; ./login_n_backup.sh ; popd

pushd content; ./inj_content.sh ; popd

pushd forum; ./inj_forum.sh ; popd

pushd wiki; ./inj_wiki.sh ; popd

pushd space; ./inj_space.sh ; popd
pushd membership; ./inj_membership.sh ; popd
pushd connection; ./inj_connection.sh ; popd

pushd calendar; ./inj_calendar.sh ; popd

popd
 
