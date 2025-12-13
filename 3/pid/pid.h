#pragma once
#include <stdint.h>
 
typedef struct {
    // 可调参数
    float Kp, Ki, Kd;          // PID系数
    float output_min;          // 输出下限
    float output_max;          // 输出上限
    float integral_max;        // 积分限幅（抗饱和）
 
    // 内部状态
    float integral;            // 积分累积
    float prev_measurement;    // 上一次测量值（用于微分平滑）
} PIDController;
 
// 初始化PID控制器
void PID_Init(PIDController* pid, float Kp, float Ki, float Kd, float output_min, float output_max,float integral_max);
 
// 执行PID计算（需提供时间增量dt）
float PID_Compute(PIDController* pid, float setpoint, float measurement, float dt);