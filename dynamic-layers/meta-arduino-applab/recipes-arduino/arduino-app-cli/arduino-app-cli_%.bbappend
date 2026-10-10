FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://genie-mmap-budget.yaml"

# LLM brick (Qualcomm Genie): set the models' mmap-budget when the runner starts
do_install:append() {
    for f in ${D}${datadir}/arduino-app-cli/assets/*/services/arduino/genie/service_compose.yaml; do
        grep -q '^    command: \["hypercorn"' "$f" || bbfatal "unexpected Genie service in $f"
        sed -i -e '/^    command: \["hypercorn"/{r ${UNPACKDIR}/genie-mmap-budget.yaml' -e 'd}' "$f"
    done
}
