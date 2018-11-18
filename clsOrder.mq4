//+------------------------------------------------------------------+
//|                                                     clsOrder.mq4 |
//|                                                      FutureRobot |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "FutureRobot"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int arrOrderList[];

double GetLotFromMoneyRisk(double _MoneyRiskPrct, double StopLoss) export 
{
   double MoneyRiskValue = AccountBalance() * (_MoneyRiskPrct/100);   
   double LotSize =NormalizeDouble(MoneyRiskValue/ (StopLoss* MarketInfo(_Symbol, MODE_LOTSIZE)),2);
   if (LotSize == 0.0) LotSize = 0.01;
   return (LotSize);
}

double GetValueFromPercentage(double _Value,double _lotsize,int Mode) export
{  
    double stopLossPips=0;
    double balance   = AccountBalance();
    //double tickvalue = MarketInfo(_Symbol, MODE_TICKVALUE);
    double lotsize   = MarketInfo(_Symbol, MODE_LOTSIZE);
    double spread    = MarketInfo(_Symbol, MODE_SPREAD);
    //double point     = MarketInfo(_Symbol, MODE_POINT);
    double ticksize  = MarketInfo(_Symbol, MODE_TICKSIZE);
    
    // fix for extremely rare occasion when a change in ticksize leads to a change in tickvalue
    //double reliable_tickvalue = tickvalue * point / ticksize;           
    
    if (Mode == 1)
      stopLossPips = MathFloor((_Value/100) * (balance) / (_lotsize * lotsize * ticksize ) - spread);      
    else if (Mode == 0)
       stopLossPips = _Value;
      
    
    //double stopLossPips = _Prct * balance / (_lotsize * lotsize * reliable_tickvalue ) - spread;

   return (stopLossPips);
}

void SetArrayOrderList(int _magicnumber)
{
   int arrsize = ArraySize(arrOrderList);
   ArrayResize(arrOrderList,arrsize+1);
   
   arrOrderList[arrsize+1]= _magicnumber;
      
}
int OpenOrder(int OpenedOrder, int maxOpenPosition, int order, double lotsize, double stoploss,
               double takeprofit, double MoneyRiskPrct, int _magicnumber) export
{
   //magicnumber = order + OpenOrder + (int)Time + MathRand + _magicnumber
   int magicnumber=0;
   
   switch((int)lotsize)
   {
      case 0: lotsize = GetLotFromMoneyRisk(MoneyRiskPrct,stoploss);
   }
     
  if (OpenedOrder < maxOpenPosition)
   {  
      if (order == 1)
      {     
         if(OrderSend(Symbol(),order,lotsize,Bid,3,Bid+(stoploss*Point),Bid - (takeprofit* Point),NULL,magicnumber,0,clrGreen))         
            {
               SetArrayOrderList(magicnumber);
               return (OpenedOrder++);                        
               Print("Short transaction opened");
            }     
         else
            Print("Cannot open short transaction.");
      }
      else if (order == 0)
      {       
         if(OrderSend(Symbol(),order,lotsize,Ask,3,Ask - (stoploss * Point),Ask + (takeprofit * Point),NULL,magicnumber,0,clrGreen))
            {
               SetArrayOrderList(magicnumber);
               return (OpenedOrder++); 
               Print("Long transaction opened");
            }
         else
            Print("Cannot open long transaction.");      
      }
   }
   return (OpenedOrder);
}
bool CloseOrder() export
{
   
   return(true);
}
bool CheckMagicNumber(int _magicNumber) export
{
   int arrsize = ArraySize(arrOrderList);
   
   for (int i=0; i<=arrsize; i++)
   {
      if (arrOrderList[i]==_magicNumber)
         return(true);
   }   
   return(false);
}
