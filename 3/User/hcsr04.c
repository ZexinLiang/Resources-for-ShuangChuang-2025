/*
 * hc_sr04.c
 *
 */

#include "hcsr04.h"

void Delay_us(uint32_t udelay)
{
	uint32_t startval, tickn, delays, wait;
	
	startval 	= SysTick->VAL;
	tickn 		= HAL_GetTick();
	delays 		= udelay * ClockFreq;
	
	if (delays > startval)
	{
		while (HAL_GetTick() == tickn){}
		wait = ClockFreq*1000 + startval - delays;
		while (wait < SysTick->VAL){}
	}
	else
	{
		wait = startval - delays;
		while (wait < SysTick->VAL && HAL_GetTick() == tickn){}
	}
}

void HC_SR04Init(void)
{
	/*Turn on the timer to count*/
	
	HAL_TIM_Base_Start(HC_SR04TIMPort);
	
	/*Turn on turn on input capture mode to get the tim count when detect Rising Edge*/
	
	HAL_TIM_IC_Start(HC_SR04TIMPort, HC_SR04ICRisingChannel);
	
	/*Turn on turn on input capture mode to get the tim count when detect Rising
	 *When detected Falling Edge, trigger an interrupt to calculate the distance*/
	
	HAL_TIM_IC_Start_IT(HC_SR04TIMPort, HC_SR04ICFallingChannel);
	
	/*Reset the Trig pin*/
	
	HAL_GPIO_WritePin(TrigPort, TrigPin, GPIO_PIN_RESET);
}

void HC_SR04Trig(void)
{
	/*Send a pulse to Trig pin to trigger the measurement*/
	
	HAL_GPIO_WritePin(TrigPort, TrigPin, GPIO_PIN_SET);
	Delay_us(40);//40us-50us can be the best
	HAL_GPIO_WritePin(TrigPort, TrigPin, GPIO_PIN_RESET);
	
	/*Prevent timer overflow updates
		Reset the initial counet value*/
	
	__HAL_TIM_SET_COUNTER(HC_SR04TIMPort, 0);
}

/*Please Place it in "HAL_TIM_IC_CaptureCallback(htim)"
 *If you haven't redefine this function, copy it at the end of teh file to tim.c*/

float HC_SR04GetDistance(void)
{
	/*Get the counter int TIM when detect rising edge and falling edge*/
	
	int risingEdge 	= HAL_TIM_ReadCapturedValue(HC_SR04TIMPort, HC_SR04ICRisingChannel);
	int fallingEdge = HAL_TIM_ReadCapturedValue(HC_SR04TIMPort, HC_SR04ICFallingChannel);
	
	/*calculate the distance*/
	
	float distance = ((fallingEdge - risingEdge)* CountToDis)/ 2;
	return distance;
}




