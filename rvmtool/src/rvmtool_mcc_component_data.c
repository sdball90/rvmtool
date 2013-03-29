/*
 * MATLAB Compiler: 4.13 (R2010a)
 * Date: Thu Mar 28 19:26:48 2013
 * Arguments: "-B" "macro_default" "-o" "rvmtool" "-W" "WinMain:rvmtool" "-T"
 * "link:exe" "-d" "C:\Users\Phil\Documents\ECE419 420\rvmtool\rvmtool\src"
 * "-w" "enable:specified_file_mismatch" "-w" "enable:repeated_file" "-w"
 * "enable:switch_ignored" "-w" "enable:missing_lib_sentinel" "-w"
 * "enable:demo_license" "-v" "C:\Users\Phil\Documents\ECE419
 * 420\rvmtool\rvmtool.m" "-a" "C:\Users\Phil\Documents\ECE419
 * 420\rvmtool\rvmtool.fig" 
 */

#include "mclmcrrt.h"

#ifdef __cplusplus
extern "C" {
#endif
const unsigned char __MCC_rvmtool_session_key[] = {
    '4', '0', '2', '6', '4', 'D', '8', '4', '9', '8', 'B', '3', '9', 'C', 'C',
    '8', 'A', 'A', '2', 'E', 'E', '7', '7', '8', '1', '2', 'A', 'E', '6', 'D',
    '1', '1', '4', '4', '8', 'B', '3', '3', '8', 'C', '1', 'E', 'C', '3', '7',
    'D', '2', '1', '1', '0', '6', '8', 'D', '6', 'A', 'C', '1', 'E', '2', '5',
    '8', '1', '5', 'B', '7', '2', 'A', 'A', 'A', '3', '5', '5', '8', 'C', '1',
    '2', '9', '2', '0', '9', '5', '6', '0', 'F', '9', 'F', '9', '0', '2', 'F',
    '5', 'D', '4', '4', 'C', '8', 'C', 'D', 'D', '4', '8', '0', '5', '2', 'B',
    'E', '4', '0', 'C', '5', '0', '0', '2', 'F', 'A', '9', '2', '9', '5', '9',
    'E', '1', '2', '8', '5', 'E', '0', 'F', '5', 'B', 'B', 'D', '9', '9', 'F',
    '0', 'C', '8', 'F', '2', '5', 'D', 'E', 'E', '3', '4', 'E', '0', '2', '5',
    '8', '3', 'A', 'D', '8', '8', '7', 'C', '6', '3', 'C', '9', 'E', 'A', 'D',
    '5', '2', 'C', 'B', '0', '5', '4', '2', '2', '0', '9', 'C', '3', '4', '0',
    '3', 'C', '4', '7', '5', '8', 'D', 'B', 'A', '3', '0', '1', 'D', 'C', '6',
    'A', 'B', '1', '9', '5', '6', '4', '8', 'A', '5', 'A', '7', '4', 'A', '4',
    '0', 'C', '2', 'E', '1', '4', '6', 'A', 'A', '0', '3', 'E', '2', '4', 'B',
    '9', '2', '8', '5', '4', '7', '7', '4', 'F', '8', 'C', 'E', 'A', '9', '9',
    '3', '3', 'E', 'F', 'A', '4', '1', '2', '7', 'A', '0', '3', 'E', '5', 'D',
    '8', '\0'};

const unsigned char __MCC_rvmtool_public_key[] = {
    '3', '0', '8', '1', '9', 'D', '3', '0', '0', 'D', '0', '6', '0', '9', '2',
    'A', '8', '6', '4', '8', '8', '6', 'F', '7', '0', 'D', '0', '1', '0', '1',
    '0', '1', '0', '5', '0', '0', '0', '3', '8', '1', '8', 'B', '0', '0', '3',
    '0', '8', '1', '8', '7', '0', '2', '8', '1', '8', '1', '0', '0', 'C', '4',
    '9', 'C', 'A', 'C', '3', '4', 'E', 'D', '1', '3', 'A', '5', '2', '0', '6',
    '5', '8', 'F', '6', 'F', '8', 'E', '0', '1', '3', '8', 'C', '4', '3', '1',
    '5', 'B', '4', '3', '1', '5', '2', '7', '7', 'E', 'D', '3', 'F', '7', 'D',
    'A', 'E', '5', '3', '0', '9', '9', 'D', 'B', '0', '8', 'E', 'E', '5', '8',
    '9', 'F', '8', '0', '4', 'D', '4', 'B', '9', '8', '1', '3', '2', '6', 'A',
    '5', '2', 'C', 'C', 'E', '4', '3', '8', '2', 'E', '9', 'F', '2', 'B', '4',
    'D', '0', '8', '5', 'E', 'B', '9', '5', '0', 'C', '7', 'A', 'B', '1', '2',
    'E', 'D', 'E', '2', 'D', '4', '1', '2', '9', '7', '8', '2', '0', 'E', '6',
    '3', '7', '7', 'A', '5', 'F', 'E', 'B', '5', '6', '8', '9', 'D', '4', 'E',
    '6', '0', '3', '2', 'F', '6', '0', 'C', '4', '3', '0', '7', '4', 'A', '0',
    '4', 'C', '2', '6', 'A', 'B', '7', '2', 'F', '5', '4', 'B', '5', '1', 'B',
    'B', '4', '6', '0', '5', '7', '8', '7', '8', '5', 'B', '1', '9', '9', '0',
    '1', '4', '3', '1', '4', 'A', '6', '5', 'F', '0', '9', '0', 'B', '6', '1',
    'F', 'C', '2', '0', '1', '6', '9', '4', '5', '3', 'B', '5', '8', 'F', 'C',
    '8', 'B', 'A', '4', '3', 'E', '6', '7', '7', '6', 'E', 'B', '7', 'E', 'C',
    'D', '3', '1', '7', '8', 'B', '5', '6', 'A', 'B', '0', 'F', 'A', '0', '6',
    'D', 'D', '6', '4', '9', '6', '7', 'C', 'B', '1', '4', '9', 'E', '5', '0',
    '2', '0', '1', '1', '1', '\0'};

static const char * MCC_rvmtool_matlabpath_data[] = 
  { "rvmtool/", "$TOOLBOXDEPLOYDIR/", "$TOOLBOXMATLABDIR/general/",
    "$TOOLBOXMATLABDIR/ops/", "$TOOLBOXMATLABDIR/lang/",
    "$TOOLBOXMATLABDIR/elmat/", "$TOOLBOXMATLABDIR/randfun/",
    "$TOOLBOXMATLABDIR/elfun/", "$TOOLBOXMATLABDIR/specfun/",
    "$TOOLBOXMATLABDIR/matfun/", "$TOOLBOXMATLABDIR/datafun/",
    "$TOOLBOXMATLABDIR/polyfun/", "$TOOLBOXMATLABDIR/funfun/",
    "$TOOLBOXMATLABDIR/sparfun/", "$TOOLBOXMATLABDIR/scribe/",
    "$TOOLBOXMATLABDIR/graph2d/", "$TOOLBOXMATLABDIR/graph3d/",
    "$TOOLBOXMATLABDIR/specgraph/", "$TOOLBOXMATLABDIR/graphics/",
    "$TOOLBOXMATLABDIR/uitools/", "$TOOLBOXMATLABDIR/strfun/",
    "$TOOLBOXMATLABDIR/imagesci/", "$TOOLBOXMATLABDIR/iofun/",
    "$TOOLBOXMATLABDIR/audiovideo/", "$TOOLBOXMATLABDIR/timefun/",
    "$TOOLBOXMATLABDIR/datatypes/", "$TOOLBOXMATLABDIR/verctrl/",
    "$TOOLBOXMATLABDIR/codetools/", "$TOOLBOXMATLABDIR/helptools/",
    "$TOOLBOXMATLABDIR/winfun/", "$TOOLBOXMATLABDIR/winfun/NET/",
    "$TOOLBOXMATLABDIR/demos/", "$TOOLBOXMATLABDIR/timeseries/",
    "$TOOLBOXMATLABDIR/hds/", "$TOOLBOXMATLABDIR/guide/",
    "$TOOLBOXMATLABDIR/plottools/", "toolbox/local/",
    "$TOOLBOXMATLABDIR/datamanager/", "toolbox/compiler/" };

static const char * MCC_rvmtool_classpath_data[] = 
  { "" };

static const char * MCC_rvmtool_libpath_data[] = 
  { "" };

static const char * MCC_rvmtool_app_opts_data[] = 
  { "" };

static const char * MCC_rvmtool_run_opts_data[] = 
  { "" };

static const char * MCC_rvmtool_warning_state_data[] = 
  { "off:MATLAB:dispatcher:nameConflict" };


mclComponentData __MCC_rvmtool_component_data = { 

  /* Public key data */
  __MCC_rvmtool_public_key,

  /* Component name */
  "rvmtool",

  /* Component Root */
  "",

  /* Application key data */
  __MCC_rvmtool_session_key,

  /* Component's MATLAB Path */
  MCC_rvmtool_matlabpath_data,

  /* Number of directories in the MATLAB Path */
  39,

  /* Component's Java class path */
  MCC_rvmtool_classpath_data,
  /* Number of directories in the Java class path */
  0,

  /* Component's load library path (for extra shared libraries) */
  MCC_rvmtool_libpath_data,
  /* Number of directories in the load library path */
  0,

  /* MCR instance-specific runtime options */
  MCC_rvmtool_app_opts_data,
  /* Number of MCR instance-specific runtime options */
  0,

  /* MCR global runtime options */
  MCC_rvmtool_run_opts_data,
  /* Number of MCR global runtime options */
  0,
  
  /* Component preferences directory */
  "rvmtool_17E38A4204377B6671A3F8B728ACCA38",

  /* MCR warning status data */
  MCC_rvmtool_warning_state_data,
  /* Number of MCR warning status modifiers */
  1,

  /* Path to component - evaluated at runtime */
  NULL

};

#ifdef __cplusplus
}
#endif


