//+------------------------------------------------------------------+
//|                                                    clsCandle.mq4 |
//|                                                      FutureRobot |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "FutureRobot"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

datetime arrCurrentTimeCandle[1];  

bool CheckCurrentCandle(int Candle) export
{
   if (Time[Candle] != arrCurrentTimeCandle[0])
   {  
      arrCurrentTimeCandle[0] = Time[1];
      return(true);
   }   
   return(false);      
}
