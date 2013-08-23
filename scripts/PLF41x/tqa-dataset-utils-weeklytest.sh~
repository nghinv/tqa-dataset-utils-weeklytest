#!/bin/bash
pushd /mnt/nfs4/DATASETS/PLF/PLF4_WEEKLY/scripts/PLF40x/
backupname="backup__inject_resources_`basename \`pwd\``_`date +%Y%m%d_%H%M%S`.zip"
zip -r ../${backupname} *

if [ -f init/continue.continue.continue ]; then rm init/continue.continue.continue; fi

pushd init; ./tqa-dataset-utils-weeklytest-init.sh ; popd
pushd user; ./tqa-dataset-utils-weeklytest-inj_user.sh ; popd
pushd login; ./tqa-dataset-utils-weeklytest-login_n_backup.sh ; popd

pushd content; ./tqa-dataset-utils-weeklytest-inj_content.sh ; popd

pushd forum; ./tqa-dataset-utils-weeklytest-inj_forum.sh ; popd

pushd wiki; ./tqa-dataset-utils-weeklytest-inj_wiki.sh ; popd

pushd space; ./tqa-dataset-utils-weeklytest-inj_space.sh ; popd
pushd membership; ./tqa-dataset-utils-weeklytest-inj_membership.sh ; popd
pushd connection; ./tqa-dataset-utils-weeklytest-inj_connection.sh ; popd

pushd calendar; ./tqa-dataset-utils-weeklytest-inj_calendar.sh ; popd

popd
 
