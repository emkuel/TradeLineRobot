//+------------------------------------------------------------------+
//|                                               TrendLineTrade.mq4 |
//|                                                      FutureRobot |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "FutureRobot"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//#import "clsTrendLine.ex4"
//   void initTrendLineClass(int _nPeriod, int _Limit, int _NumOfTrendLine, double _PriceDeviation,
//                           int _CandleNumber);
//   bool GetValueByShiftInFuncLine();
//   int GetOrder();
//#import "clsOrder.ex4"
//   double GetValueFromPercentage(double _Value,double _lotsize,int Mode);
//   int OpenOrder(int OpenedOrder, int maxOpenPosition, int order,double lotsize, 
//            double stoploss,double takeprofit, double MoneyRiskPrct, int magicnumber);
//   bool CheckMagicNumber(int _magicNumber);
//   bool CloseOrder();
#import "clsCandle.ex4"
   void initTimeCandle(int _CandleNumber);
   bool CheckCurrentCandle(int Candle);
#import

#include <clsTrendLine.mqh>
#include <clsOrder.mqh>

extern double MoneyRisk=2.0;
extern double StopLossLine = 100;

extern int MaxOpenPosition = 1;
extern int CandleNumber =1;

extern int TrendLinePeriod = 30;
extern int BarsLimit=350;
extern int TrendLinesNum=5;

extern double PriceDeviation=50;

int OpenedOrder=0;
clsTrendLine TrendLine(TrendLinePeriod,BarsLimit,TrendLinesNum,PriceDeviation,CandleNumber,StopLossLine);
clsOrder Order();

int OnInit()
  {
   //initTrendLineClass(TrendLinePeriod,BarsLimit,TrendLinesNum,PriceDeviation,CandleNumber);
   Comment("Account Balance: " + (string)NormalizeDouble(AccountBalance(),2));
   initTimeCandle(CandleNumber);
   
   CheckCurrentOrders();
   if(CheckCurrentCandle(CandleNumber))
      if (TrendLine.GetValueByShiftInFuncLine())
        OpenedOrder = Order.OpenOrder(OpenedOrder,MaxOpenPosition,TrendLine.GetOrder(),0,TrendLine.GetStopLoss(),
                              0,MoneyRisk,TrendLine.GetMagicNumber());
                              
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
  
   CheckCurrentOrders();
   if(CheckCurrentCandle(CandleNumber))
      if (TrendLine.GetValueByShiftInFuncLine())
        OpenedOrder = Order.OpenOrder(OpenedOrder,MaxOpenPosition,TrendLine.GetOrder(),0,TrendLine.GetStopLoss(),
                              0,MoneyRisk,TrendLine.GetMagicNumber());
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

void CheckCurrentOrders()
{  
   int magicnumber;
   for (int i=OrdersTotal()-1; i >= 0 ;i--)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         magicnumber = OrderMagicNumber();
         if(Order.CheckMagicNumber(magicnumber))
            if(TrendLine.CheckPriceIsInTrendLine(magicnumber))
               Order.CloseOrderByMagicNumber(magicnumber);
   }  
}