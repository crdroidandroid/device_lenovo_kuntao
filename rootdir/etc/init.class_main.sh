#!/system/bin/sh
# Copyright (c) 2013-2014, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of The Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

#
# start ril-daemon only for targets on which radio is present
#
baseband=`getprop ro.baseband`
datamode=`getprop persist.data.mode`
netmgr=`getprop ro.use_data_netmgrd`

case "$baseband" in
    "apq")
    setprop ro.radio.noril yes
    stop ril-daemon
esac

case "$baseband" in
    "msm" | "unknown")
    start ipacm-diag
    start ipacm

    multisim=`getprop persist.radio.multisim.config`

    if [ "$multisim" = "dsds" ] || [ "$multisim" = "dsda" ]; then
        start ril-daemon2
    fi

    case "$datamode" in
        "tethered")
            start qti
            start port-bridge
            ;;
        "concurrent")
            start qti
            if [ "$netmgr" = "true" ]; then
                start netmgrd
            fi
            ;;
        *)
            if [ "$netmgr" = "true" ]; then
                start netmgrd
            fi
            ;;
    esac
esac

start_copying_prebuilt_qcril_db()
{
    if [ -f /system/vendor/qcril.db -a ! -f /data/misc/radio/qcril.db ]; then
        cp /system/vendor/qcril.db /data/misc/radio/qcril.db
        chown -h radio.radio /data/misc/radio/qcril.db
    fi
}

#
# Copy qcril.db if needed for RIL
#
start_copying_prebuilt_qcril_db
echo 1 > /data/misc/radio/db_check_done

#
# Make modem config folder and copy firmware config to that folder for RIL
#
if [ -f /data/misc/radio/ver_info.txt ]; then
    prev_version_info=`cat /data/misc/radio/ver_info.txt`
else
    prev_version_info=""
fi

# modify by linzb2,2016-05-06 begin
# cur_version_info=`cat /firmware/verinfo/ver_info.txt`
cur_version_info=`getprop ro.product.sw.internal.version`
# modify by linzb2,2016-05-06 end
if [ ! -f /firmware/verinfo/ver_info.txt -o "$prev_version_info" != "$cur_version_info" ]; then
    rm -rf /data/misc/radio/modem_config
    mkdir /data/misc/radio/modem_config
    chmod 770 /data/misc/radio/modem_config
# modify by linzb2,2016-05-06 begin
    # cp -r /firmware/image/modem_pr/mcfg/configs/* /data/misc/radio/modem_config
    cp  /firmware/image/modem_pr/mcfg/configs/mbn_ota.txt /data/misc/radio/modem_config/mbn_ota.txt
    cp  /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/kuntaopr/cmcc/commerci/volte_op/mcfg_sw.mbn /data/misc/radio/modem_config/mcfg_sw_cmcc.mbn
    cp  /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/kuntaopr/ct/commerci/openmkt/mcfg_sw.mbn /data/misc/radio/modem_config/mcfg_sw_ct.mbn
    cp  /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/kuntaopr/cu/commerci/openmkt/mcfg_sw.mbn /data/misc/radio/modem_config/mcfg_sw_cu.mbn
    cp  /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/kuntaopr/row/gen_3gpp/mcfg_sw.mbn /data/misc/radio/modem_config/mcfg_sw_row.mbn
# modify by linzb2,2016-05-06 end
    chown -hR radio.radio /data/misc/radio/modem_config
    cp /firmware/verinfo/ver_info.txt /data/misc/radio/ver_info.txt
    chown radio.radio /data/misc/radio/ver_info.txt
# modify by linzb2,2016-05-06 begin
    echo $cur_version_info > /data/misc/radio/ver_info.txt
# modify by linzb2,2016-05-06 end
fi
cp /firmware/image/modem_pr/mbn_ota.txt /data/misc/radio/modem_config
chown radio.radio /data/misc/radio/modem_config/mbn_ota.txt
echo 1 > /data/misc/radio/copy_complete
