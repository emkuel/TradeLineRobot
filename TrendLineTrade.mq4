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

#include <clsStruct.mqh>
#include <hCandle.mqh>
#include <clsTrendLine.mqh>
#include <clsOrder.mqh>
#include <clsFile.mqh>

extern double MoneyRisk=2.0;
extern double StopLossLine = 100;
extern double MinTakeProfit=100;

extern int CandleNumber =1;

extern int TrendLinePeriod = 30;
extern int BarsLimit=350;
extern int TrendLinesNum=5;

extern double PriceDeviation=80;

int OpenedOrders=0;
int MaxOpenPosition = 1;

clsTrendLine TrendLine(TrendLinePeriod,BarsLimit,TrendLinesNum,PriceDeviation,CandleNumber,StopLossLine,MinTakeProfit);
clsOrder Order(MoneyRisk,MaxOpenPosition);
clsFile FilesOrders((string)AccountNumber() + "_"+Symbol()+"_"+(string)Period()+"_Orders.txt");

int OnInit()
  {
   strTrend arr[];
   int CheckOpenPosition=0;
   //initTrendLineClass(TrendLinePeriod,BarsLimit,TrendLinesNum,PriceDeviation,CandleNumber);
   Comment("Account Balance: " + (string)NormalizeDouble(AccountBalance(),2));
   
   initTimeCandle(CandleNumber);
   FilesOrders.InitMagicNumber();
   //get open position
   CheckOpenPosition=FilesOrders.GetOpenOrder();
   
   if(CheckOpenPosition > OpenedOrders)
      OpenedOrders=CheckOpenPosition;
   
   //set trendline
   TrendLine.initTrendLine(OpenedOrders);
   ResetLastError();
   //copy magic number array
   FilesOrders.GetOrderArrayFromFile(arr);
   Order.SetOrderArrayFromFile(arr);
                              
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
   if(OpenedOrders==0 && CheckCurrentCandle(CandleNumber))
   {     
      
      TrendLine.initTrendLine(OpenedOrders);
      if(TrendLine.GetValueByShiftInFuncLine()) 
        {
         if(Order.OpenOrder(OpenedOrders,TrendLine.GetOrder(),0,TrendLine.GetStopLoss(),0,TrendLine.GetMagicNumber()))
            {
               OpenedOrders++;
            }
        }
  }   
   else if (OpenedOrders>0)
      CheckCurrentOrders();
}
  
void CheckCurrentOrders()
{  
   int magicnumber=0;
   int b=false;
   
   for (int i=OrdersTotal()-1; i >= 0 ;i--)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         magicnumber = OrderMagicNumber();
         if(Order.CheckMagicNumber(magicnumber))
         {
            b=true;
            if(TrendLine.CheckPriceIsInTrendLine(magicnumber,OrderType(),OrderOpenPrice()))
               if(Order.CloseOrderByMagicNumber(magicnumber))
               {
                  OpenedOrders--;
                  FilesOrders.InitMagicNumber();
               }
         } 
      }
   }
   
   //if order was opened but not exist in server
   if (!b)
      OpenedOrders=0;
}