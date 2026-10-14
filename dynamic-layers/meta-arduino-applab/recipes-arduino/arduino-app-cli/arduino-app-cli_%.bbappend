FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Stopgap for the LLM brick (Qualcomm Genie) on the mainline fastrpc driver:
# Arduino's models map their weights at once ("mmap-budget": 0) and do not fit
# the NPU address window. Drop once Arduino's Genie model configs set it.
SRC_URI:append:ventuno-q = " file://genie-mmap-budget.yaml file://genie-command.expected"

# Replace the Genie service command with one that sets the models'
# mmap-budget before starting the same server. Fail the build if Arduino
# changes the original command, so it is never overridden silently.
do_install:append:ventuno-q() {
    for f in ${D}${datadir}/arduino-app-cli/assets/*/services/arduino/genie/service_compose.yaml; do
        grep -qxFf ${UNPACKDIR}/genie-command.expected "$f" || \
            bbfatal "unexpected Genie service command in $f"
        sed -i -e '/^    command: \["hypercorn"/{r ${UNPACKDIR}/genie-mmap-budget.yaml' -e 'd}' "$f"
    done
}
