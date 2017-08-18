/*
   Copyright (c) 2016, The Linux Foundation. All rights reserved.
   Copyright (C) 2016, The CyanogenMod Project
   Copyright (C) 2016-2017, Nikolai Petrenko
   Copyright (C) 2017, The LineageOS Project

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are
   met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of The Linux Foundation nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
   WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
   ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
   BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
   BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
   WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
   OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
   IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <stdio.h>
#include <stdlib.h>
#include <sys/sysinfo.h>

#include <android-base/properties.h>

#include "property_service.h"
#include "vendor_init.h"

using android::base::SetProperty;

void property_override(char const prop[], char const value[])
{
    prop_info *pi;

    pi = (prop_info*) __system_property_find(prop);
    if (pi)
        __system_property_update(pi, value, strlen(value));
    else
        __system_property_add(prop, strlen(prop), value, strlen(value));
}

int is4GB()
{
    struct sysinfo sys;
    sysinfo(&sys);
    return sys.totalram > 3072ull * 1024 * 1024;
}

void vendor_load_properties()
{
    if (is4GB()) {
      // dalvik stuff
        SetProperty("dalvik.vm.heapstartsize", "8m");
        SetProperty("dalvik.vm.heapgrowthlimit", "384m");
        SetProperty("dalvik.vm.heapsize", "1024m");
        SetProperty("dalvik.vm.heaptargetutilization", "0.75");
        SetProperty("dalvik.vm.heapminfree", "4m");
        SetProperty("dalvik.vm.heapmaxfree", "16m");
    } else {
    // dalvik stuff
        SetProperty("dalvik.vm.heapstartsize", "8m");
        SetProperty("dalvik.vm.heapgrowthlimit", "288m");
        SetProperty("dalvik.vm.heapsize", "768m");
        SetProperty("dalvik.vm.heaptargetutilization", "0.75");
        SetProperty("dalvik.vm.heapminfree", "512k");
        SetProperty("dalvik.vm.heapmaxfree", "8m");
    } 
    SetProperty("ro.build.product", "kuntao");
    SetProperty("ro.product.device", "kuntao");
    SetProperty("ro.build.description", "kuntao_row-user 7.0 NRD90N P2a42_S244_170725_ROW release-keys");
    SetProperty("ro.build.fingerprint", "Lenovo/kuntao_row/P2a42:7.0/NRD90N/P2a42_S244_170725_ROW:user/release-keys");
}
