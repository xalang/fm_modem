# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "")
  file(REMOVE_RECURSE
  "/home/andylang/fpga/fm_modem/fm_modem_app_platform/zynq_fsbl/zynq_fsbl_bsp/include/diskio.h"
  "/home/andylang/fpga/fm_modem/fm_modem_app_platform/zynq_fsbl/zynq_fsbl_bsp/include/ff.h"
  "/home/andylang/fpga/fm_modem/fm_modem_app_platform/zynq_fsbl/zynq_fsbl_bsp/include/ffconf.h"
  "/home/andylang/fpga/fm_modem/fm_modem_app_platform/zynq_fsbl/zynq_fsbl_bsp/include/sleep.h"
  "/home/andylang/fpga/fm_modem/fm_modem_app_platform/zynq_fsbl/zynq_fsbl_bsp/include/xilffs.h"
  "/home/andylang/fpga/fm_modem/fm_modem_app_platform/zynq_fsbl/zynq_fsbl_bsp/include/xilffs_config.h"
  "/home/andylang/fpga/fm_modem/fm_modem_app_platform/zynq_fsbl/zynq_fsbl_bsp/include/xilrsa.h"
  "/home/andylang/fpga/fm_modem/fm_modem_app_platform/zynq_fsbl/zynq_fsbl_bsp/include/xiltimer.h"
  "/home/andylang/fpga/fm_modem/fm_modem_app_platform/zynq_fsbl/zynq_fsbl_bsp/include/xtimer_config.h"
  "/home/andylang/fpga/fm_modem/fm_modem_app_platform/zynq_fsbl/zynq_fsbl_bsp/lib/libxilffs.a"
  "/home/andylang/fpga/fm_modem/fm_modem_app_platform/zynq_fsbl/zynq_fsbl_bsp/lib/libxilrsa.a"
  "/home/andylang/fpga/fm_modem/fm_modem_app_platform/zynq_fsbl/zynq_fsbl_bsp/lib/libxiltimer.a"
  )
endif()
