//+------------------------------------------------------------------+
//|                                               TrendLineTrade.mq4 |
//|                                                      FutureRobot |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "FutureRobot"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <clsOrder.mqh>
#include <clsTrendLine.mqh>

enum Profit
{   
   Pips=0,
   Percentage=1
};

extern Profit StopLossMode;
extern double StopLoss = 150;
extern Profit TakeProfitMode;
extern double TakeProfit = 200;
extern double LotSize = 1.0;

extern bool OpenPositionOnNewPinBar=false;
extern int MaxOpenPosition = 2;

clsOrder Order();
clsTrendLine TrendLine(5);

int OpenedOrder=0;
int order=-1;

int OnInit()
  {
   StopLoss = Order.GetValueFromPercentage(StopLoss,LotSize,StopLossMode);
   TakeProfit = Order.GetValueFromPercentage(TakeProfit,LotSize,TakeProfitMode);    
  
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if (TrendLine.GetValueByShiftInFuncLine(order))
      OpenedOrder =Order.OpenOrder(OpenedOrder,MaxOpenPosition,order,LotSize,StopLoss,TakeProfit,0);
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   
   
         
   
  }
//+------------------------------------------------------------------+