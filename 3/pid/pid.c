#include "pid.h"
 
void PID_Init(PIDController* pid,  float Kp, float Ki, float Kd,float output_min, float output_max,float integral_max) 
{
    pid->Kp = Kp;
    pid->Ki = Ki;
    pid->Kd = Kd;
    pid->output_min = output_min;
    pid->output_max = output_max;
    pid->integral_max = integral_max;
    pid->integral = 0.0f;
    pid->prev_measurement = 0.0f;
}
 
float PID_Compute(PIDController* pid, float setpoint, float measurement,float dt) 
{
    // 1. 计算当前误差
    float error = setpoint - measurement;
    
    // 2. 积分项更新（带限幅抗饱和）
    pid->integral += error * dt;
    if (pid->integral > pid->integral_max) 
        pid->integral = pid->integral_max;
    else if (pid->integral < -pid->integral_max) 
        pid->integral = -pid->integral_max;
    
    // 3. 微分项优化：用测量值微分而非误差微分
    float derivative = (measurement - pid->prev_measurement) / dt;
    
    // 4. PID输出计算
    float output = pid->Kp * error 
                 + pid->Ki * pid->integral 
                 - pid->Kd * derivative;  // 注意符号：测量值微分取负
    
    // 5. 输出限幅
    if (output > pid->output_max) output = pid->output_max;
    if (output < pid->output_min) output = pid->output_min;
    
    // 6. 更新历史状态
    pid->prev_measurement = measurement;
    
    return output;
}