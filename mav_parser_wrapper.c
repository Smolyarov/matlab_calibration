/*
  *
  *   --- THIS FILE GENERATED BY S-FUNCTION BUILDER: 3.0 ---
  *
  *   This file is a wrapper S-function produced by the S-Function
  *   Builder which only recognizes certain fields.  Changes made
  *   outside these fields will be lost the next time the block is
  *   used to load, edit, and resave this file. This file will be overwritten
  *   by the S-function Builder block. If you want to edit this file by hand, 
  *   you must change it only in the area defined as:  
  *
  *        %%%-SFUNWIZ_wrapper_XXXXX_Changes_BEGIN 
  *            Your Changes go here
  *        %%%-SFUNWIZ_wrapper_XXXXXX_Changes_END
  *
  *   For better compatibility with the Simulink Coder, the
  *   "wrapper" S-function technique is used.  This is discussed
  *   in the Simulink Coder User's Manual in the Chapter titled,
  *   "Wrapper S-functions".
  *
  *   Created: Mon Apr 11 19:11:27 2016
  */


/*
 * Include Files
 *
 */
#if defined(MATLAB_MEX_FILE)
#include "tmwtypes.h"
#include "simstruc_types.h"
#else
#include "rtwtypes.h"
#endif

/* %%%-SFUNWIZ_wrapper_includes_Changes_BEGIN --- EDIT HERE TO _END */
#include "mavlink.h"
/* %%%-SFUNWIZ_wrapper_includes_Changes_END --- EDIT HERE TO _BEGIN */
#define u_width 256
#define y_width 1
/*
 * Create external references here.  
 *
 */
/* %%%-SFUNWIZ_wrapper_externs_Changes_BEGIN --- EDIT HERE TO _END */
/* extern double func(double a); */
/* %%%-SFUNWIZ_wrapper_externs_Changes_END --- EDIT HERE TO _BEGIN */

/*
 * Output functions
 *
 */
void mav_parser_Outputs_wrapper(const uint8_T *uart_byte,
                          const real_T *uart_status,
                          int16_T *acc,
                          real_T *imu_en,
                          real_T *temp,
                          int16_T *gyro)
{
/* %%%-SFUNWIZ_wrapper_Outputs_Changes_BEGIN --- EDIT HERE TO _END */
static mavlink_message_t msg;
static mavlink_status_t mav_status;

imu_en[0] = 0;
if (uart_status[0] == 1) {
    int i;
    for (i = 0; i<256; i++)
    {
        if (mavlink_parse_char(0, uart_byte[i], &msg, &mav_status))
        {
            switch(msg.msgid)
            {
                case MAVLINK_MSG_ID_SCALED_IMU:
                {
                    acc[0] = mavlink_msg_scaled_imu_get_xacc(&msg);
                    acc[1] = mavlink_msg_scaled_imu_get_yacc(&msg);
                    acc[2] = mavlink_msg_scaled_imu_get_zacc(&msg);
                    gyro[0] = mavlink_msg_scaled_imu_get_xgyro(&msg);
                    gyro[1] = mavlink_msg_scaled_imu_get_ygyro(&msg);
                    gyro[2] = mavlink_msg_scaled_imu_get_zgyro(&msg);
                    imu_en[0] = 1;
                    break;
                }
                case MAVLINK_MSG_ID_DEBUG:
                    if (mavlink_msg_debug_get_ind(&msg)==1)
                    {
                        temp[0] = mavlink_msg_debug_get_value(&msg);
                        break;
                    }
            }
        }
    }
}
/* %%%-SFUNWIZ_wrapper_Outputs_Changes_END --- EDIT HERE TO _BEGIN */
}
