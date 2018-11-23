//+------------------------------------------------------------------+
//|                                                 clsTrendLine.mqh |
//|                                                      FutureRobot |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "FutureRobot"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#import "clsHelperFunction.ex4"
   void QuickSortArray2Dimension(double & arr[][], int StartPos, int EndPos, bool SmallestToLarges);
#import


class clsTrendLine
  {
private:
                    int nPeriod;
                    int nCurBar;
                    int Limit;
                    int AutoTimeframe;
                    int NumOfTrendLineForArr;
                    int NumOfTrendLine;
                    int order;
                    int MagicNumber;
                    int CandleNumber;
                    double PriceDeviation;
                    double StopLoss;
                    double StopLossLine;
                    
                    double arrLowS[];
                    double arrLowST[];
                    double arrHighR[];
                    double arrHighRT[];

                    datetime arrTimeFuncLine[];
                    double arrFuncLine[][2];
                    double arrTrendLineAbove[][5];
                    double arrTrendLineBelow[][5];
                    
                    void SetArrayFunctionLine();
                    void SetTrendLinePeriod();
                    
                    bool LoopTrendLine(double &arr[][],double price, int arrsize, int magicnumber);
public:
                    bool GetValueByShiftInFuncLine();
                    void SetNearestTrendLineArray();
                    bool CheckPriceIsInTrendLine(int magicnumber);
                    int GetOrder(){return(order);};
                    int GetMagicNumber(){return(MagicNumber);};
                    double GetStopLoss(){return(StopLoss);};
                     clsTrendLine(int _nPeriod, int _Limit, int _NumOfTrendLine, double _PriceDeviation, 
                     int _CandleNumber, double _StopLossLine);
                    ~clsTrendLine();
  };

bool clsTrendLine::LoopTrendLine(double &arr[][],double price, int arrsize, int magicnumber)
{
   double CurrentPriceTrendLine;
   
   for (int i =0; i<=arrsize-1; i++)
   {
      if(arrTrendLineAbove[i][4]==magicnumber)
      {
         CurrentPriceTrendLine = GetY(arr[i][1]
                                       ,iBarShift(_Symbol,0,(datetime)arr[i][2])
                                       ,arr[i][3]);
                                       
         if((price <= CurrentPriceTrendLine) && (price+(PriceDeviation*Point) >= CurrentPriceTrendLine))            
            return(true);
         
         break;
      }
   }
   return (false);
}
bool clsTrendLine::CheckPriceIsInTrendLine(int magicnumber)
{
   int magicorder = (int)StringSubstr((string)magicnumber,1,1);
   
   int arrsizeAbove = (ArraySize(arrTrendLineAbove))/5;
   int arrsizeBelow = (ArraySize(arrTrendLineBelow))/5;
   
   if (magicorder == 0)
      return(LoopTrendLine(arrTrendLineAbove,Bid,arrsizeAbove,magicnumber));
   else if (magicorder == 1)
      return (LoopTrendLine(arrTrendLineBelow,Ask,arrsizeBelow,magicnumber));
   
   return (false);
}

void clsTrendLine::SetNearestTrendLineArray()
{
   int BarStart;
   int j=0, k=0;
   double TrendLinePrice;
   double CloseBar = Close[CandleNumber];
   
   for(int i=0;i<=(NumOfTrendLine*2)-1;i++)
   {            
      BarStart = iBarShift(_Symbol,0,arrTimeFuncLine[i]);
      TrendLinePrice=GetY(arrFuncLine[i][0],BarStart-CandleNumber,arrFuncLine[i][1]);
      
      if (TrendLinePrice > CloseBar)
      {
         ArrayResize(arrTrendLineAbove,j+1);
         arrTrendLineAbove[j][0] = TrendLinePrice;                      //price
         arrTrendLineAbove[j][1] = arrFuncLine[i][0];                   //a
         arrTrendLineAbove[j][2] = (double)arrTimeFuncLine[i];          //x time def
         arrTrendLineAbove[j][3] = arrFuncLine[i][1];                   //b
         arrTrendLineAbove[j][4] = 0;                                   //magicnumber         
         j++;
         
      }      
      else if (TrendLinePrice < CloseBar)
      {
         ArrayResize(arrTrendLineBelow,k+1);
         arrTrendLineBelow[k][0] = TrendLinePrice;                      //price
         arrTrendLineBelow[k][1] = arrFuncLine[i][0];                   //a
         arrTrendLineBelow[k][2] = (double)arrTimeFuncLine[i];          //x time def
         arrTrendLineBelow[k][3] = arrFuncLine[i][1];                   //b
         arrTrendLineBelow[k][4] = 0;                                   //magicnumber         
         k++;
         
      }  
   }
}

bool clsTrendLine::GetValueByShiftInFuncLine()
 {
    double OpenBar;
    double CloseBar;
    double HighBar;
    double LowBar;
    double TrendLinePriceBelow=0;
    double TrendLinePriceAbove=0;
   
    Print("Set Nearest Trend Line");
    SetNearestTrendLineArray();
    
    if(ArraySize(arrTrendLineBelow)>0)
    {
      QuickSortArray2Dimension(arrTrendLineBelow,0,(ArraySize(arrTrendLineBelow)/5)-1,false);
      TrendLinePriceBelow=arrTrendLineBelow[0][0];
      Print("Nearest below:" + (string)TrendLinePriceBelow);
    }
    
    if (ArraySize(arrTrendLineAbove)>0)
    {
      QuickSortArray2Dimension(arrTrendLineAbove,0,(ArraySize(arrTrendLineAbove)/5)-1,true);
      TrendLinePriceAbove=arrTrendLineAbove[0][0];
      Print("Nearest above: " + (string)TrendLinePriceAbove);
    }
    
    Print("Set Candle prices");
    OpenBar = Open[CandleNumber];
    CloseBar = Close[CandleNumber];
    HighBar = High[CandleNumber];
    LowBar = Low[CandleNumber];
    
    if ((TrendLinePriceBelow >= LowBar && (TrendLinePriceBelow <= CloseBar || TrendLinePriceBelow <= OpenBar))
         || (TrendLinePriceBelow + (PriceDeviation * Point) >= LowBar 
            && (TrendLinePriceBelow + (PriceDeviation * Point) <= CloseBar || TrendLinePriceBelow + (PriceDeviation * Point) <= OpenBar))
         || (TrendLinePriceBelow - (PriceDeviation * Point) >= LowBar 
            && (TrendLinePriceBelow - (PriceDeviation * Point) <= CloseBar || TrendLinePriceBelow - (PriceDeviation * Point) <= OpenBar)
            ))         
    {
      Print("Long position match");//long
      order=0;      
      arrTrendLineBelow[0][4]=StringToDouble("6"+(string)order+(string)((int)Time[1]/40000000) + (string)MathRand());
      MagicNumber = NormalizeDouble(arrTrendLineBelow[0][4],0);
      StopLoss= MathAbs((((TrendLinePriceBelow+(StopLossLine*Point))-Ask)/Point));
      MathAbs((TrendLinePriceBelow+Ask)  - (StopLossLine*Point));
      return (true);    
    }
    else if ((TrendLinePriceAbove <= HighBar && (TrendLinePriceAbove >=CloseBar || TrendLinePriceAbove >= OpenBar))
            || (TrendLinePriceAbove  + (PriceDeviation * Point) <= HighBar 
               && (TrendLinePriceAbove + (PriceDeviation * Point) >=CloseBar || TrendLinePriceAbove + (PriceDeviation * Point) >= OpenBar))
            || (TrendLinePriceAbove  - (PriceDeviation * Point) <= HighBar 
               && (TrendLinePriceAbove - (PriceDeviation * Point) >=CloseBar || TrendLinePriceAbove - (PriceDeviation * Point) >= OpenBar))
            )
    {
      Print("Short position match");//short
      order=1;    
      arrTrendLineAbove[0][4]=StringToDouble("6"+(string)order+(string)((int)Time[1]/40000000) + (string)MathRand());
      MagicNumber=NormalizeDouble(arrTrendLineAbove[0][4],0);
      StopLoss= MathAbs((((TrendLinePriceAbove+(StopLossLine*Point))-Bid)/Point));
      return (true);
    }
    
  Print("Position not match");
  return (false);
}
double GetY(double a, double x, double b)
{
  double y = (a*x) + b;
  return (y);
}
double GetB(double a, double x, double y)
{   
  double b= -(a*x)+y;
  return (b);
}
double GetA(double Xa, double Ya, double Xb, double Yb)
{
  double a=0;  
  if((Xb-Xa)!=0)
      a = (Yb-Ya)/(Xb-Xa);
  
  return (a);
}

void clsTrendLine::SetArrayFunctionLine()
{  
   int j=0;
   for (int i=0; i<=NumOfTrendLine-1; i++)
   {      
      //Low
      arrTimeFuncLine[j]=Time[MathAbs((int)arrLowST[i])];
      arrFuncLine[j][0]=GetA(0,arrLowS[i],arrLowST[i+1]-arrLowST[i],arrLowS[i+1]);
      arrFuncLine[j][1]=GetB(arrFuncLine[j][0],0,arrLowS[i]);
      
      //High
      arrTimeFuncLine[j+1]=Time[MathAbs((int)arrHighRT[i])];
      arrFuncLine[j+1][0]=GetA(0,arrHighR[i],arrHighRT[i+1]-arrHighRT[i],arrHighR[i+1]);
      arrFuncLine[j+1][1]=GetB(arrFuncLine[j+1][0],0,arrHighR[i]);
      
      j+=2;            
   }
}

void LoopArray(double & arr1[], double & arr2[],int number)
{

  for (int i=number-1; i>0; i--)
  {
    arr1[i]=arr1[i-1];
    arr2[i]=arr2[i-1];
  }
}

void clsTrendLine::SetTrendLinePeriod()
{
    if(Bars<Limit) Limit=Bars-nPeriod;
    
    for(nCurBar=Limit; nCurBar>0; nCurBar--)
    {
      if(Low[nCurBar+(nPeriod-1)/2] == Low[iLowest(NULL,0,MODE_LOW,nPeriod,nCurBar)])
      {                
        LoopArray(arrLowS,arrLowST,NumOfTrendLineForArr);
        arrLowS[0]=Low[nCurBar+(nPeriod-1)/2];
        arrLowST[0]=-(nCurBar+(nPeriod-1)/2);
        
        //s6=s5; s5=s4; s4=s3; s3=s2; s2=s1; s1=Low[nCurBar+(nPeriod-1)/2];
        //st6=st5; st5=st4; st4=st3; st3=st2; st2=st1; st1=nCurBar+(nPeriod-1)/2;
      }
      if(High[nCurBar+(nPeriod-1)/2] == High[iHighest(NULL,0,MODE_HIGH,nPeriod,nCurBar)])
      {        
        LoopArray(arrHighR,arrHighRT,NumOfTrendLineForArr);
        arrHighR[0]=High[nCurBar+(nPeriod-1)/2];
        arrHighRT[0]=-(nCurBar+(nPeriod-1)/2);
        
        //r6=r5; r5=r4; r4=r3; r3=r2; r2=r1; r1=High[nCurBar+(nPeriod-1)/2];
        //rt6=rt5; rt5=rt4; rt4=rt3; rt3=rt2; rt2=rt1; rt1=nCurBar+(nPeriod-1)/2;
      }
    }
}

clsTrendLine::clsTrendLine(int _nPeriod, int _Limit, int _NumOfTrendLine, double _PriceDeviation, 
                        int _CandleNumber, double _StopLossLine)
  {
    Print("Init Trend Line Class");
    nPeriod=_nPeriod;   
    nCurBar=0;
    Limit=_Limit;
    AutoTimeframe=60;
    NumOfTrendLineForArr=_NumOfTrendLine+1;
    NumOfTrendLine=_NumOfTrendLine;
    PriceDeviation=_PriceDeviation;
    CandleNumber=_CandleNumber;
    StopLossLine=_StopLossLine;
    
    Print("Resize arrays");
    ArrayResize(arrLowS,NumOfTrendLineForArr);
    ArrayResize(arrLowST,NumOfTrendLineForArr);
    ArrayResize(arrHighR,NumOfTrendLineForArr);
    ArrayResize(arrHighRT,NumOfTrendLineForArr);
    ArrayResize(arrFuncLine,NumOfTrendLine*2);
    ArrayResize(arrTimeFuncLine,NumOfTrendLine*2);
    
    Print("Check and correct current period");
    if (Period()<AutoTimeframe)
    {
        int AutoFactor = AutoTimeframe/Period();
        nPeriod=nPeriod*AutoFactor;
        Limit=Limit*AutoFactor;
    }
    else
      Limit = (int)ChartGetInteger(0,CHART_VISIBLE_BARS);
   
    Print("Set Trend Line");
    SetTrendLinePeriod();
    Print("Set Array Function Line");
    SetArrayFunctionLine();
    
    Print("All set");
  }
clsTrendLine::~clsTrendLine()
  {
  }
