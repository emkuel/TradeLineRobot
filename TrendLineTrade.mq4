//+------------------------------------------------------------------+
//|                                               TrendLineTrade.mq4 |
//|                                                      FutureRobot |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "FutureRobot"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#import "clsTrendLine.ex4"
   void initTrendLineClass(int _nPeriod, int _Limit, int _NumOfTrendLine);
   bool GetValueByShiftInFuncLine(int BarNum=1);
   int GetOrder();
#import "clsOrder.ex4"
   double GetValueFromPercentage(double _Value,double _lotsize,int Mode);
   int OpenOrder(int OpenedOrder, int maxOpenPosition, int order,double lotsize, 
            double stoploss,double takeprofit, int magicnumber);
#import "clsCandle.ex4"
   bool CheckCurrentCandle();
#import

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

extern int TrendLinePeriod = 30;
extern int BarsLimit=350;
extern int TrendLinesNum=5;

int OpenedOrder=0;

int OnInit()
  {
   initTrendLineClass(TrendLinePeriod,BarsLimit,TrendLinesNum);
   Comment("Account Balance: " + (string)AccountBalance());
   StopLoss = GetValueFromPercentage(StopLoss,LotSize,StopLossMode);
   TakeProfit = GetValueFromPercentage(TakeProfit,LotSize,TakeProfitMode);    
  
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
   if(CheckCurrentCandle())
      if (GetValueByShiftInFuncLine())
        OpenedOrder =OpenOrder(OpenedOrder,MaxOpenPosition,GetOrder(),LotSize,StopLoss,TakeProfit,0);
   
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
