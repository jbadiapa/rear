# This file is part of Relax-and-Recover, licensed under the GNU General
# Public License. Refer to the included COPYING for full text of license.

backup_tsm_log=/var/lib/rear/backup_tsm_log

if [[ ! -d "$backup_tsm_log" ]]; then
    mkdir -p $v $backup_tsm_log
fi

LogPrint ""
LogPrint "Starting Backup with TSM"

# If the TSM client is found, start an incremental backup
if has_binary dsmc ; then
    LC_ALL=${LANG_RECOVER} dsmc incremental\
    -verbose \
    -subdir=yes \
    -tapeprompt=no "${TSM_DSMC_BACKUP_OPTIONS[@]}" | tee "${TMP_DIR}/${BACKUP_PROG_ARCHIVE}.log"
    StopIfError "Error during TSM backup... Check your configuration."
else
    StopIfError "Can't find TSM client dsmc; Please check your configuration."
fi

### Copy progress log to backup media
if cp $v "${TMP_DIR}/${BACKUP_PROG_ARCHIVE}.log" "${backup_tsm_log}/${BACKUP_PROG_ARCHIVE}.log"; then
    if dsmc incremental ${backup_tsm_log}/${BACKUP_PROG_ARCHIVE}.log >/dev/null 2>&1; then
        LogPrint "${backup_tsm_log}/${BACKUP_PROG_ARCHIVE}.log added to the backup"
    else
        LogPrint "Failed to add ${backup_tsm_log}/${BACKUP_PROG_ARCHIVE}.log to the backup"
    fi
fi
