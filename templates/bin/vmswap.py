#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import socket
import re
import glob
try:
    import collectd
except ImportError:
    pass
import logging

logging.basicConfig(level=logging.INFO)

PLUGIN_NAME = "processes_vmswap"
CFG = {
    "processes": [".*"]
}

def log(param):
    """
    Log messages to either collectd or stdout depending on how it was called.

    :param param: the message
    :return:  None
    """

    if __name__ != '__main__':
        collectd.info("Plugin %s: %s" % (PLUGIN_NAME, param))
    else:
        sys.stderr.write("Plugin %s: %s\n" % (PLUGIN_NAME, param))

def config(conf):
    for line in conf.children:
        log("config key='%s', values='%s'" % (line.key,line.values))
        global CFG
        CFG[line.key] = line.values

def init():
    log("initializing...")

def shutdown():
    log("shutting down...")

def read():
    for cmdlinePath in glob.iglob('/proc/*/cmdline'):
        procDir = None
        processBasename = None
        # /proc/<pid>/cmdline {{
        try:
            cmdlineFile = open(cmdlinePath)
        except Exception as e:
            log("failed open proc file='%s', error='%s'" % (cmdlinePath,e))

        cmdline = cmdlineFile.readline().strip().split('\0')[:-1]
        if not cmdline:
            continue
        for processeRegex in CFG['processes']:
            if re.search(r''+processeRegex, cmdline[0]):
                procDir = os.path.dirname(cmdlinePath)
                processBasename = os.path.basename(os.path.realpath(procDir+'/exe'))
        cmdlineFile.close()
        # }}
        if procDir:
            # /proc/<pid>/status {{
            filePath = "%s/status" % (procDir)
            try:
                fileStatus = open(filePath)
            except Exception as e:
                log("failed open proc file='%s', error='%s'" % (filePath,e))
            fields = {}
            for line in fileStatus.readlines():
                kv = line.split(":")
                if len(kv) != 2:
                    continue
                name = kv[0]
                value = kv[1].strip()
                try:
                    fields[name] = int(value)
                except:
                    fields[name] = value
            fileStatus.close()
            VmSwap = fields['VmSwap'].split(" ")[0] # in kB !!!
            plugin_instance = processBasename
            collectdValues = {
                "plugin": PLUGIN_NAME,
                "plugin_instance": re.sub(r'[#\.,:]',r'_',plugin_instance),
                "type_instance": "vmswap",
                "type": "count",
                "values": [VmSwap],
            }
            if __name__ != '__main__':
                collectd.Values(
                    plugin=collectdValues['plugin'],
                    plugin_instance=collectdValues['plugin_instance'],
                    type=collectdValues['type'],
                    values=collectdValues['values']
                ).dispatch()
            else:
                print(collectdValues)
            # }}
    return

if __name__ != "__main__":
    collectd.register_config(config)
    collectd.register_read(read)
    collectd.register_init(init)
    collectd.register_shutdown(shutdown)
else:
    read()
