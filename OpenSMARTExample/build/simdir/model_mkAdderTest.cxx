/*
 * Generated by Bluespec Compiler, version 2015.09.beta2 (build 34689, 2015-09-07)
 * 
 * On Thu Oct 31 17:09:23 EDT 2019
 * 
 */
#include "bluesim_primitives.h"
#include "model_mkAdderTest.h"

#include <cstdlib>
#include <time.h>
#include "bluesim_kernel_api.h"
#include "bs_vcd.h"
#include "bs_reset.h"


/* Constructor */
MODEL_mkAdderTest::MODEL_mkAdderTest()
{
  mkAdderTest_instance = NULL;
}

/* Function for creating a new model */
void * new_MODEL_mkAdderTest()
{
  MODEL_mkAdderTest *model = new MODEL_mkAdderTest();
  return (void *)(model);
}

/* Schedule functions */

static void schedule_posedge_CLK(tSimStateHdl simHdl, void *instance_ptr)
       {
	 MOD_mkAdderTest &INST_top = *((MOD_mkAdderTest *)(instance_ptr));
	 tUInt8 DEF_INST_top_INST_adder_DEF_n__read__h8793;
	 tUInt8 DEF_INST_top_INST_adder_DEF_cnt1__h3260;
	 tUInt8 DEF_INST_top_INST_adder_DEF_n__read__h9354;
	 tUInt8 DEF_INST_top_INST_adder_DEF_cnt1__h6494;
	 tUInt8 DEF_INST_top_INST_adder_DEF_n__read__h10080;
	 tUInt8 DEF_INST_top_INST_adder_DEF_CAN_FIRE_RL_aFifo_data_0_canon;
	 tUInt8 DEF_INST_top_INST_adder_DEF_WILL_FIRE_RL_aFifo_data_0_canon;
	 tUInt8 DEF_INST_top_INST_adder_DEF_CAN_FIRE_RL_aFifo_enqP_canon;
	 tUInt8 DEF_INST_top_INST_adder_DEF_WILL_FIRE_RL_aFifo_enqP_canon;
	 tUInt8 DEF_INST_top_INST_adder_DEF_CAN_FIRE_RL_aFifo_deqP_canon;
	 tUInt8 DEF_INST_top_INST_adder_DEF_WILL_FIRE_RL_aFifo_deqP_canon;
	 tUInt8 DEF_INST_top_INST_adder_DEF_CAN_FIRE_RL_bFifo_data_0_canon;
	 tUInt8 DEF_INST_top_INST_adder_DEF_WILL_FIRE_RL_bFifo_data_0_canon;
	 tUInt8 DEF_INST_top_INST_adder_DEF_CAN_FIRE_RL_bFifo_enqP_canon;
	 tUInt8 DEF_INST_top_INST_adder_DEF_WILL_FIRE_RL_bFifo_enqP_canon;
	 tUInt8 DEF_INST_top_INST_adder_DEF_CAN_FIRE_RL_bFifo_deqP_canon;
	 tUInt8 DEF_INST_top_INST_adder_DEF_WILL_FIRE_RL_bFifo_deqP_canon;
	 tUInt8 DEF_INST_top_INST_adder_DEF_CAN_FIRE_RL_resultFifo_enqP_canon;
	 tUInt8 DEF_INST_top_INST_adder_DEF_WILL_FIRE_RL_resultFifo_enqP_canon;
	 tUInt8 DEF_INST_top_INST_adder_DEF_CAN_FIRE_RL_resultFifo_deqP_canon;
	 tUInt8 DEF_INST_top_INST_adder_DEF_WILL_FIRE_RL_resultFifo_deqP_canon;
	 tUInt8 DEF_INST_top_INST_adder_DEF_CAN_FIRE_RL_doAddition;
	 tUInt8 DEF_INST_top_INST_adder_DEF_WILL_FIRE_RL_doAddition;
	 tUInt32 DEF_INST_top_DEF_x__h323;
	 tUInt8 DEF_INST_top_DEF_initialized__h180;
	 tUInt8 DEF_INST_top_DEF_CAN_FIRE_RL_incrementCycle;
	 tUInt8 DEF_INST_top_DEF_WILL_FIRE_RL_incrementCycle;
	 tUInt8 DEF_INST_top_DEF_CAN_FIRE_RL_finishSimulation;
	 tUInt8 DEF_INST_top_DEF_WILL_FIRE_RL_finishSimulation;
	 tUInt8 DEF_INST_top_DEF_CAN_FIRE_RL_initialize;
	 tUInt8 DEF_INST_top_DEF_WILL_FIRE_RL_initialize;
	 tUInt8 DEF_INST_top_DEF_CAN_FIRE_RL_insertValue;
	 tUInt8 DEF_INST_top_DEF_WILL_FIRE_RL_insertValue;
	 tUInt8 DEF_INST_top_DEF_CAN_FIRE_RL_checkResult;
	 tUInt8 DEF_INST_top_DEF_WILL_FIRE_RL_checkResult;
	 DEF_INST_top_DEF_initialized__h180 = INST_top.INST_initialized.METH_read();
	 DEF_INST_top_DEF_x__h323 = INST_top.INST_state.METH_read();
	 DEF_INST_top_DEF_CAN_FIRE_RL_checkResult = INST_top.INST_adder.METH_RDY_get() && (DEF_INST_top_DEF_initialized__h180 && DEF_INST_top_DEF_x__h323 == 1u);
	 DEF_INST_top_DEF_WILL_FIRE_RL_checkResult = DEF_INST_top_DEF_CAN_FIRE_RL_checkResult;
	 INST_top.DEF__read__h98 = INST_top.INST_cycle.METH_read();
	 DEF_INST_top_DEF_CAN_FIRE_RL_finishSimulation = DEF_INST_top_DEF_initialized__h180 && !((INST_top.DEF__read__h98) < 100u);
	 DEF_INST_top_DEF_WILL_FIRE_RL_finishSimulation = DEF_INST_top_DEF_CAN_FIRE_RL_finishSimulation;
	 DEF_INST_top_DEF_CAN_FIRE_RL_incrementCycle = DEF_INST_top_DEF_initialized__h180;
	 DEF_INST_top_DEF_WILL_FIRE_RL_incrementCycle = DEF_INST_top_DEF_CAN_FIRE_RL_incrementCycle;
	 DEF_INST_top_DEF_CAN_FIRE_RL_initialize = !DEF_INST_top_DEF_initialized__h180;
	 DEF_INST_top_DEF_WILL_FIRE_RL_initialize = DEF_INST_top_DEF_CAN_FIRE_RL_initialize;
	 DEF_INST_top_DEF_CAN_FIRE_RL_insertValue = (INST_top.INST_adder.METH_RDY_putB() && INST_top.INST_adder.METH_RDY_putA()) && (DEF_INST_top_DEF_initialized__h180 && DEF_INST_top_DEF_x__h323 == 0u);
	 DEF_INST_top_DEF_WILL_FIRE_RL_insertValue = DEF_INST_top_DEF_CAN_FIRE_RL_insertValue;
	 DEF_INST_top_INST_adder_DEF_CAN_FIRE_RL_aFifo_deqP_canon = (tUInt8)1u;
	 DEF_INST_top_INST_adder_DEF_WILL_FIRE_RL_aFifo_deqP_canon = DEF_INST_top_INST_adder_DEF_CAN_FIRE_RL_aFifo_deqP_canon;
	 DEF_INST_top_INST_adder_DEF_CAN_FIRE_RL_aFifo_data_0_canon = (tUInt8)1u;
	 DEF_INST_top_INST_adder_DEF_WILL_FIRE_RL_aFifo_data_0_canon = DEF_INST_top_INST_adder_DEF_CAN_FIRE_RL_aFifo_data_0_canon;
	 DEF_INST_top_INST_adder_DEF_CAN_FIRE_RL_aFifo_enqP_canon = (tUInt8)1u;
	 DEF_INST_top_INST_adder_DEF_WILL_FIRE_RL_aFifo_enqP_canon = DEF_INST_top_INST_adder_DEF_CAN_FIRE_RL_aFifo_enqP_canon;
	 DEF_INST_top_INST_adder_DEF_CAN_FIRE_RL_bFifo_data_0_canon = (tUInt8)1u;
	 DEF_INST_top_INST_adder_DEF_WILL_FIRE_RL_bFifo_data_0_canon = DEF_INST_top_INST_adder_DEF_CAN_FIRE_RL_bFifo_data_0_canon;
	 DEF_INST_top_INST_adder_DEF_CAN_FIRE_RL_bFifo_deqP_canon = (tUInt8)1u;
	 DEF_INST_top_INST_adder_DEF_WILL_FIRE_RL_bFifo_deqP_canon = DEF_INST_top_INST_adder_DEF_CAN_FIRE_RL_bFifo_deqP_canon;
	 DEF_INST_top_INST_adder_DEF_CAN_FIRE_RL_bFifo_enqP_canon = (tUInt8)1u;
	 DEF_INST_top_INST_adder_DEF_WILL_FIRE_RL_bFifo_enqP_canon = DEF_INST_top_INST_adder_DEF_CAN_FIRE_RL_bFifo_enqP_canon;
	 DEF_INST_top_INST_adder_DEF_CAN_FIRE_RL_resultFifo_deqP_canon = (tUInt8)1u;
	 DEF_INST_top_INST_adder_DEF_WILL_FIRE_RL_resultFifo_deqP_canon = DEF_INST_top_INST_adder_DEF_CAN_FIRE_RL_resultFifo_deqP_canon;
	 DEF_INST_top_INST_adder_DEF_CAN_FIRE_RL_resultFifo_enqP_canon = (tUInt8)1u;
	 DEF_INST_top_INST_adder_DEF_WILL_FIRE_RL_resultFifo_enqP_canon = DEF_INST_top_INST_adder_DEF_CAN_FIRE_RL_resultFifo_enqP_canon;
	 if (DEF_INST_top_DEF_WILL_FIRE_RL_finishSimulation)
	   INST_top.RL_finishSimulation();
	 if (DEF_INST_top_DEF_WILL_FIRE_RL_checkResult)
	   INST_top.RL_checkResult();
	 if (DEF_INST_top_DEF_WILL_FIRE_RL_incrementCycle)
	   INST_top.RL_incrementCycle();
	 if (DEF_INST_top_DEF_WILL_FIRE_RL_initialize)
	   INST_top.RL_initialize();
	 if (DEF_INST_top_DEF_WILL_FIRE_RL_insertValue)
	   INST_top.RL_insertValue();
	 INST_top.INST_adder.DEF_upd__h11877 = INST_top.INST_adder.INST_resultFifo_deqP_rl.METH_read();
	 INST_top.INST_adder.DEF_upd__h10208 = INST_top.INST_adder.INST_resultFifo_deqP_lat_0.METH_wget();
	 INST_top.INST_adder.DEF_upd__h9906 = INST_top.INST_adder.INST_resultFifo_enqP_rl.METH_read();
	 INST_top.INST_adder.DEF_upd__h9537 = INST_top.INST_adder.INST_bFifo_deqP_rl.METH_read();
	 INST_top.INST_adder.DEF_upd__h11450 = INST_top.INST_adder.INST_bFifo_enqP_rl.METH_read();
	 INST_top.INST_adder.DEF_upd__h9482 = INST_top.INST_adder.INST_bFifo_enqP_lat_0.METH_wget();
	 INST_top.INST_adder.DEF_upd__h11041 = INST_top.INST_adder.INST_aFifo_enqP_rl.METH_read();
	 INST_top.INST_adder.DEF_upd__h8976 = INST_top.INST_adder.INST_aFifo_deqP_rl.METH_read();
	 INST_top.INST_adder.DEF_upd__h8921 = INST_top.INST_adder.INST_aFifo_enqP_lat_0.METH_wget();
	 INST_top.INST_adder.DEF_IF_resultFifo_deqP_lat_0_whas__2_THEN_resultFi_ETC___d55 = INST_top.INST_adder.INST_resultFifo_deqP_lat_0.METH_whas() ? INST_top.INST_adder.DEF_upd__h10208 : INST_top.INST_adder.DEF_upd__h11877;
	 DEF_INST_top_INST_adder_DEF_n__read__h10080 = INST_top.INST_adder.DEF_IF_resultFifo_deqP_lat_0_whas__2_THEN_resultFi_ETC___d55;
	 INST_top.INST_adder.DEF_x__h10240 = INST_top.INST_adder.DEF_upd__h9906;
	 INST_top.INST_adder.DEF_y__h9690 = INST_top.INST_adder.DEF_upd__h9537;
	 INST_top.INST_adder.DEF_IF_bFifo_enqP_lat_0_whas__1_THEN_bFifo_enqP_la_ETC___d34 = INST_top.INST_adder.INST_bFifo_enqP_lat_0.METH_whas() ? INST_top.INST_adder.DEF_upd__h9482 : INST_top.INST_adder.DEF_upd__h11450;
	 DEF_INST_top_INST_adder_DEF_n__read__h9354 = INST_top.INST_adder.DEF_IF_bFifo_enqP_lat_0_whas__1_THEN_bFifo_enqP_la_ETC___d34;
	 DEF_INST_top_INST_adder_DEF_cnt1__h6494 = DEF_INST_top_INST_adder_DEF_n__read__h9354 < (INST_top.INST_adder.DEF_y__h9690) ? (tUInt8)1u : (tUInt8)3u & (DEF_INST_top_INST_adder_DEF_n__read__h9354 - (INST_top.INST_adder.DEF_y__h9690));
	 INST_top.INST_adder.DEF_y__h9129 = INST_top.INST_adder.DEF_upd__h8976;
	 INST_top.INST_adder.DEF_IF_aFifo_enqP_lat_0_whas__0_THEN_aFifo_enqP_la_ETC___d13 = INST_top.INST_adder.INST_aFifo_enqP_lat_0.METH_whas() ? INST_top.INST_adder.DEF_upd__h8921 : INST_top.INST_adder.DEF_upd__h11041;
	 DEF_INST_top_INST_adder_DEF_n__read__h8793 = INST_top.INST_adder.DEF_IF_aFifo_enqP_lat_0_whas__0_THEN_aFifo_enqP_la_ETC___d13;
	 DEF_INST_top_INST_adder_DEF_cnt1__h3260 = DEF_INST_top_INST_adder_DEF_n__read__h8793 < (INST_top.INST_adder.DEF_y__h9129) ? (tUInt8)1u : (tUInt8)3u & (DEF_INST_top_INST_adder_DEF_n__read__h8793 - (INST_top.INST_adder.DEF_y__h9129));
	 DEF_INST_top_INST_adder_DEF_CAN_FIRE_RL_doAddition = !(DEF_INST_top_INST_adder_DEF_cnt1__h3260 == (tUInt8)0u) && (!(DEF_INST_top_INST_adder_DEF_cnt1__h6494 == (tUInt8)0u) && ((INST_top.INST_adder.DEF_x__h10240) < DEF_INST_top_INST_adder_DEF_n__read__h10080 ? (tUInt8)1u : (tUInt8)3u & ((INST_top.INST_adder.DEF_x__h10240) - DEF_INST_top_INST_adder_DEF_n__read__h10080)) == (tUInt8)0u);
	 DEF_INST_top_INST_adder_DEF_WILL_FIRE_RL_doAddition = DEF_INST_top_INST_adder_DEF_CAN_FIRE_RL_doAddition;
	 if (DEF_INST_top_INST_adder_DEF_WILL_FIRE_RL_doAddition)
	   INST_top.INST_adder.RL_doAddition();
	 if (DEF_INST_top_INST_adder_DEF_WILL_FIRE_RL_aFifo_data_0_canon)
	   INST_top.INST_adder.RL_aFifo_data_0_canon();
	 if (DEF_INST_top_INST_adder_DEF_WILL_FIRE_RL_aFifo_deqP_canon)
	   INST_top.INST_adder.RL_aFifo_deqP_canon();
	 if (DEF_INST_top_INST_adder_DEF_WILL_FIRE_RL_aFifo_enqP_canon)
	   INST_top.INST_adder.RL_aFifo_enqP_canon();
	 if (DEF_INST_top_INST_adder_DEF_WILL_FIRE_RL_bFifo_data_0_canon)
	   INST_top.INST_adder.RL_bFifo_data_0_canon();
	 if (DEF_INST_top_INST_adder_DEF_WILL_FIRE_RL_bFifo_deqP_canon)
	   INST_top.INST_adder.RL_bFifo_deqP_canon();
	 if (DEF_INST_top_INST_adder_DEF_WILL_FIRE_RL_bFifo_enqP_canon)
	   INST_top.INST_adder.RL_bFifo_enqP_canon();
	 if (DEF_INST_top_INST_adder_DEF_WILL_FIRE_RL_resultFifo_deqP_canon)
	   INST_top.INST_adder.RL_resultFifo_deqP_canon();
	 if (DEF_INST_top_INST_adder_DEF_WILL_FIRE_RL_resultFifo_enqP_canon)
	   INST_top.INST_adder.RL_resultFifo_enqP_canon();
	 INST_top.INST_adder.INST_resultFifo_deqP_dummy_1_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_resultFifo_deqP_dummy_1_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_resultFifo_deqP_dummy_0_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_resultFifo_deqP_dummy_0_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_resultFifo_deqP_lat_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_resultFifo_deqP_lat_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_resultFifo_enqP_dummy_1_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_resultFifo_enqP_dummy_1_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_resultFifo_enqP_dummy_0_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_resultFifo_enqP_dummy_0_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_resultFifo_enqP_lat_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_resultFifo_enqP_lat_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_bFifo_deqP_dummy_1_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_bFifo_deqP_dummy_1_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_bFifo_deqP_dummy_0_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_bFifo_deqP_dummy_0_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_bFifo_deqP_lat_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_bFifo_deqP_lat_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_bFifo_enqP_dummy_1_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_bFifo_enqP_dummy_1_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_bFifo_enqP_dummy_0_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_bFifo_enqP_dummy_0_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_bFifo_enqP_lat_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_bFifo_enqP_lat_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_bFifo_data_0_dummy_1_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_bFifo_data_0_dummy_1_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_bFifo_data_0_dummy_0_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_bFifo_data_0_dummy_0_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_bFifo_data_0_lat_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_bFifo_data_0_lat_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_aFifo_deqP_dummy_1_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_aFifo_deqP_dummy_1_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_aFifo_deqP_dummy_0_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_aFifo_deqP_dummy_0_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_aFifo_deqP_lat_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_aFifo_deqP_lat_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_aFifo_enqP_dummy_1_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_aFifo_enqP_dummy_1_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_aFifo_enqP_dummy_0_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_aFifo_enqP_dummy_0_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_aFifo_enqP_lat_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_aFifo_enqP_lat_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_aFifo_data_0_dummy_1_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_aFifo_data_0_dummy_1_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_aFifo_data_0_dummy_0_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_aFifo_data_0_dummy_0_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_aFifo_data_0_lat_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_adder.INST_aFifo_data_0_lat_0.clk((tUInt8)1u, (tUInt8)1u);
	 if (do_reset_ticks(simHdl))
	 {
	   INST_top.INST_adder.INST_aFifo_data_0_dummy2_0.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_adder.INST_aFifo_data_0_dummy2_1.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_adder.INST_aFifo_data_0_rl.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_adder.INST_aFifo_enqP_dummy2_0.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_adder.INST_aFifo_enqP_dummy2_1.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_adder.INST_aFifo_enqP_rl.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_adder.INST_aFifo_deqP_dummy2_0.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_adder.INST_aFifo_deqP_dummy2_1.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_adder.INST_aFifo_deqP_rl.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_adder.INST_bFifo_data_0_dummy2_0.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_adder.INST_bFifo_data_0_dummy2_1.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_adder.INST_bFifo_data_0_rl.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_adder.INST_bFifo_enqP_dummy2_0.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_adder.INST_bFifo_enqP_dummy2_1.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_adder.INST_bFifo_enqP_rl.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_adder.INST_bFifo_deqP_dummy2_0.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_adder.INST_bFifo_deqP_dummy2_1.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_adder.INST_bFifo_deqP_rl.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_adder.INST_resultFifo_enqP_dummy2_0.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_adder.INST_resultFifo_enqP_dummy2_1.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_adder.INST_resultFifo_enqP_rl.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_adder.INST_resultFifo_deqP_dummy2_0.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_adder.INST_resultFifo_deqP_dummy2_1.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_adder.INST_resultFifo_deqP_rl.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_cycle.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_initialized.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_state.rst_tick__clk__1((tUInt8)1u);
	 }
       };

/* Model creation/destruction functions */

void MODEL_mkAdderTest::create_model(tSimStateHdl simHdl, bool master)
{
  sim_hdl = simHdl;
  init_reset_request_counters(sim_hdl);
  mkAdderTest_instance = new MOD_mkAdderTest(sim_hdl, "top", NULL);
  bk_get_or_define_clock(sim_hdl, "CLK");
  if (master)
  {
    bk_alter_clock(sim_hdl, bk_get_clock_by_name(sim_hdl, "CLK"), CLK_LOW, false, 0llu, 5llu, 5llu);
    bk_use_default_reset(sim_hdl);
  }
  bk_set_clock_event_fn(sim_hdl,
			bk_get_clock_by_name(sim_hdl, "CLK"),
			schedule_posedge_CLK,
			NULL,
			(tEdgeDirection)(POSEDGE));
  (mkAdderTest_instance->INST_adder.INST_aFifo_data_0_lat_0.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_aFifo_data_0_lat_1.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_aFifo_data_0_dummy_0_0.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_aFifo_data_0_dummy_0_1.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_aFifo_data_0_dummy_1_0.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_aFifo_data_0_dummy_1_1.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_aFifo_enqP_lat_0.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_aFifo_enqP_lat_1.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_aFifo_enqP_dummy_0_0.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_aFifo_enqP_dummy_0_1.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_aFifo_enqP_dummy_1_0.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_aFifo_enqP_dummy_1_1.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_aFifo_deqP_lat_0.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_aFifo_deqP_lat_1.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_aFifo_deqP_dummy_0_0.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_aFifo_deqP_dummy_0_1.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_aFifo_deqP_dummy_1_0.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_aFifo_deqP_dummy_1_1.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_bFifo_data_0_lat_0.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_bFifo_data_0_lat_1.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_bFifo_data_0_dummy_0_0.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_bFifo_data_0_dummy_0_1.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_bFifo_data_0_dummy_1_0.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_bFifo_data_0_dummy_1_1.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_bFifo_enqP_lat_0.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_bFifo_enqP_lat_1.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_bFifo_enqP_dummy_0_0.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_bFifo_enqP_dummy_0_1.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_bFifo_enqP_dummy_1_0.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_bFifo_enqP_dummy_1_1.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_bFifo_deqP_lat_0.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_bFifo_deqP_lat_1.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_bFifo_deqP_dummy_0_0.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_bFifo_deqP_dummy_0_1.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_bFifo_deqP_dummy_1_0.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_bFifo_deqP_dummy_1_1.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_resultFifo_enqP_lat_0.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_resultFifo_enqP_lat_1.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_resultFifo_enqP_dummy_0_0.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_resultFifo_enqP_dummy_0_1.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_resultFifo_enqP_dummy_1_0.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_resultFifo_enqP_dummy_1_1.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_resultFifo_deqP_lat_0.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_resultFifo_deqP_lat_1.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_resultFifo_deqP_dummy_0_0.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_resultFifo_deqP_dummy_0_1.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_resultFifo_deqP_dummy_1_0.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.INST_resultFifo_deqP_dummy_1_1.set_clk_0)("CLK");
  (mkAdderTest_instance->INST_adder.set_clk_0)("CLK");
  (mkAdderTest_instance->set_clk_0)("CLK");
}
void MODEL_mkAdderTest::destroy_model()
{
  delete mkAdderTest_instance;
  mkAdderTest_instance = NULL;
}
void MODEL_mkAdderTest::reset_model(bool asserted)
{
  (mkAdderTest_instance->reset_RST_N)(asserted ? (tUInt8)0u : (tUInt8)1u);
}
void * MODEL_mkAdderTest::get_instance()
{
  return mkAdderTest_instance;
}

/* Fill in version numbers */
void MODEL_mkAdderTest::get_version(unsigned int *year,
				    unsigned int *month,
				    char const **annotation,
				    char const **build)
{
  *year = 2015u;
  *month = 9u;
  *annotation = "beta2";
  *build = "34689";
}

/* Get the model creation time */
time_t MODEL_mkAdderTest::get_creation_time()
{
  
  /* Thu Oct 31 21:09:23 UTC 2019 */
  return 1572556163llu;
}

/* Control run-time licensing */
tUInt64 MODEL_mkAdderTest::skip_license_check()
{
  return 0llu;
}

/* State dumping function */
void MODEL_mkAdderTest::dump_state()
{
  (mkAdderTest_instance->dump_state)(0u);
}

/* VCD dumping functions */
MOD_mkAdderTest & mkAdderTest_backing(tSimStateHdl simHdl)
{
  static MOD_mkAdderTest *instance = NULL;
  if (instance == NULL)
  {
    vcd_set_backing_instance(simHdl, true);
    instance = new MOD_mkAdderTest(simHdl, "top", NULL);
    vcd_set_backing_instance(simHdl, false);
  }
  return *instance;
}
void MODEL_mkAdderTest::dump_VCD_defs()
{
  (mkAdderTest_instance->dump_VCD_defs)(vcd_depth(sim_hdl));
}
void MODEL_mkAdderTest::dump_VCD(tVCDDumpType dt)
{
  (mkAdderTest_instance->dump_VCD)(dt, vcd_depth(sim_hdl), mkAdderTest_backing(sim_hdl));
}
