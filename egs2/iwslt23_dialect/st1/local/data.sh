#!/usr/bin/env bash
# Set bash to 'debug' mode, it will exit on :
# -e 'error', -u 'undefined variable', -o ... 'error in pipeline', -x 'print commands',
set -e
set -u
set -o pipefail

. ./db.sh || exit 1;
. ./path.sh || exit 1;
. ./cmd.sh || exit 1;

log() {
    local fname=${BASH_SOURCE[1]##*/}
    echo -e "$(date '+%Y-%m-%dT%H:%M:%S') (${fname}:${BASH_LINENO[0]}:${FUNCNAME[1]}) $*"
}
SECONDS=0

src_dir=data_amir
stage=1
stop_stage=100000
splits_dir=data/iwslt22_splits

log "$0 $*"
. utils/parse_options.sh

if [ -z "${IWSLT22_DIALECT}" ]; then
    log "Fill the value of 'IWSLT22_DIALECT' of db.sh"
    exit 1
fi

if [ $# -ne 0 ]; then
    log "Error: No positional arguments are required."
    exit 2
fi

if [ ${stage} -le 1 ] && [ ${stop_stage} -ge 1 ] && [ ! -d "${splits_dir}" ]; then
    log "stage 1: Copy over the transcripts from the src directory"

    mkdir -p data/train
    mkdir -p data/dev
    mkdir -p data/test1

    for set in train dev test1
    do
        cp ${src_dir}/${set}/* data/${set}
        utils/validate_data_dir.sh --no-feats data/${set} || exit 1
        rm data/${set}/wav.scp
    done
fi

if [ ${stage} -le 2 ] && [ ${stop_stage} -ge 2 ]; then
    log "stage 2: Parse and regerenate the wav.scp files"
    
    for set in train dev test1
    do
        local/generate_wavscp.py \
            --src ${src_dir}/${set}/wav.scp \
            --out data/${set}/wav.scp \
            --data-dir "${IWSLT22_DIALECT}"
    done
fi

log "Successfully finished. [elapsed=${SECONDS}s]"
