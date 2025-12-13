/*
 * hc_sr04.h
 *
 */

#ifndef __HC_SR04_H__
#define __HC_SR04_H__

#include "main.h"
#include "tim.h"
#include "gpio.h"

#define ClockFreq					72			//MHz
#define SoundVelocity 		34029.0 //cm/s
#define CountFreq 				1000000
#define CountToDis 				SoundVelocity/CountFreq

#define TrigPort 					GPIOB
#define TrigPin						GPIO_PIN_9

#define HC_SR04TIMPort 		&htim3
#define HC_SR04ICRisingChannel 	TIM_CHANNEL_1
#define HC_SR04ICFallingChannel TIM_CHANNEL_2
#define HC_SR04ICActiveChannel 	HAL_TIM_ACTIVE_CHANNEL_2

void HC_SR04Init(void);

void HC_SR04Trig(void);

float HC_SR04GetDistance(void);

#endif  /*__HC_SR04_H__*/
