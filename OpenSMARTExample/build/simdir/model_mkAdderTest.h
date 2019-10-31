/*
 * Generated by Bluespec Compiler, version 2015.09.beta2 (build 34689, 2015-09-07)
 * 
 * On Thu Oct 31 17:09:23 EDT 2019
 * 
 */

/* Generation options: */
#ifndef __model_mkAdderTest_h__
#define __model_mkAdderTest_h__

#include "bluesim_types.h"
#include "bs_module.h"
#include "bluesim_primitives.h"
#include "bs_vcd.h"

#include "bs_model.h"
#include "mkAdderTest.h"

/* Class declaration for a model of mkAdderTest */
class MODEL_mkAdderTest : public Model {
 
 /* Top-level module instance */
 private:
  MOD_mkAdderTest *mkAdderTest_instance;
 
 /* Handle to the simulation kernel */
 private:
  tSimStateHdl sim_hdl;
 
 /* Constructor */
 public:
  MODEL_mkAdderTest();
 
 /* Functions required by the kernel */
 public:
  void create_model(tSimStateHdl simHdl, bool master);
  void destroy_model();
  void reset_model(bool asserted);
  void get_version(unsigned int *year,
		   unsigned int *month,
		   char const **annotation,
		   char const **build);
  time_t get_creation_time();
  void * get_instance();
  void dump_state();
  void dump_VCD_defs();
  void dump_VCD(tVCDDumpType dt);
  tUInt64 skip_license_check();
};

/* Function for creating a new model */
extern "C" {
  void * new_MODEL_mkAdderTest();
}

#endif /* ifndef __model_mkAdderTest_h__ */
