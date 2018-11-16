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
   void QucikSortArray(double & arr[], int StartPos, int EndPos, bool SmallestToLarges);
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
                    int CandleNumber;
                    double PriceDeviation;

                    double arrLowS[];
                    double arrLowST[];
                    double arrHighR[];
                    double arrHighRT[];

                    datetime arrTimeFuncLine[];
                    double arrFuncLine[][2];
                    double arrTrendLineAbove[];
                    double arrTrendLineBelow[];

                    //double r1,r2,r3,r4,r5,r6;
                    //int rt1,rt2,rt3,rt4,rt5,rt6;
                    //double s1,s2,s3,s4,s5,s6;
                    //int st1,st2,st3,st4,st5,st6;
                    
                    void SetArrayFunctionLine();
                    void SetTrendLinePeriod();
public:
                    bool GetValueByShiftInFuncLine();
                    void SetNearestTrendLineArray();
                    int GetOrder(){return(order);};
                     clsTrendLine(int _nPeriod, int _Limit, int _NumOfTrendLine, double _PriceDeviation, int _CandleNumber);
                    ~clsTrendLine();
  };


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
         arrTrendLineAbove[j] = TrendLinePrice; 
         j++;
      }      
      else if (TrendLinePrice < CloseBar)
      {
         ArrayResize(arrTrendLineBelow,k+1);
         arrTrendLineBelow[k] = TrendLinePrice;
         k++;
      }  
   }
}

bool clsTrendLine::GetValueByShiftInFuncLine()
 {
    double OpenBar, CloseBar, HighBar, LowBar;
    
    SetNearestTrendLineArray();
    QucikSortArray(arrTrendLineAbove,0,ArraySize(arrTrendLineAbove)-1,true);
    QucikSortArray(arrTrendLineBelow,0,ArraySize(arrTrendLineBelow)-1,false);
    
    OpenBar = Open[CandleNumber];
    CloseBar = Close[CandleNumber];
    HighBar = High[CandleNumber];
    LowBar = Low[CandleNumber];
    
    
    if ((arrTrendLineBelow[0] >= LowBar && (arrTrendLineBelow[0] <= CloseBar || arrTrendLineBelow[0] <= OpenBar))
         || (arrTrendLineBelow[0] + (PriceDeviation * Point) >= LowBar 
            && (arrTrendLineBelow[0] + (PriceDeviation * Point) <= CloseBar || arrTrendLineBelow[0] + (PriceDeviation * Point) <= OpenBar))
         || (arrTrendLineBelow[0] - (PriceDeviation * Point) >= LowBar 
            && (arrTrendLineBelow[0] - (PriceDeviation * Point) <= CloseBar || arrTrendLineBelow[0] - (PriceDeviation * Point) <= OpenBar)
            ))         
    {
      //long
      order=0;
      return (true);    
    }
    else if ((arrTrendLineAbove[0] <= HighBar && (arrTrendLineAbove[0] >=CloseBar || arrTrendLineAbove[0] >= OpenBar))
            || (arrTrendLineAbove[0]  + (PriceDeviation * Point) <= HighBar 
               && (arrTrendLineAbove[0] + (PriceDeviation * Point) >=CloseBar || arrTrendLineAbove[0] + (PriceDeviation * Point) >= OpenBar))
            || (arrTrendLineAbove[0]  - (PriceDeviation * Point) <= HighBar 
               && (arrTrendLineAbove[0] - (PriceDeviation * Point) >=CloseBar || arrTrendLineAbove[0] - (PriceDeviation * Point) >= OpenBar))
            )
    {
      //short
      order=1;
      return (true);
    }
      
  return (false);
}
double GetY(double a, double x, double b)
{
  //y=a(x-)+b   - shift right
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
  //a=(Yb-Ya)/(Xb-Xa)

  double a = (Yb-Ya)/(Xb-Xa);
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
  //for (int i=1; i<=number-1; i++)
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

clsTrendLine::clsTrendLine(int _nPeriod, int _Limit, int _NumOfTrendLine, double _PriceDeviation, int _CandleNumber)
  {
    nPeriod=_nPeriod;   
    nCurBar=0;
    Limit=_Limit;
    AutoTimeframe=60;
    NumOfTrendLineForArr=_NumOfTrendLine+1;
    NumOfTrendLine=_NumOfTrendLine;
    PriceDeviation=_PriceDeviation;
    CandleNumber=_CandleNumber;
   
    ArrayResize(arrLowS,NumOfTrendLineForArr);
    ArrayResize(arrLowST,NumOfTrendLineForArr);
    ArrayResize(arrHighR,NumOfTrendLineForArr);
    ArrayResize(arrHighRT,NumOfTrendLineForArr);
    ArrayResize(arrFuncLine,NumOfTrendLine*2);
    ArrayResize(arrTimeFuncLine,NumOfTrendLine*2);
    
    //check current period and change to correct period
    if (Period()<AutoTimeframe)
    {
        int AutoFactor = AutoTimeframe/Period();
        nPeriod=nPeriod*AutoFactor;
        Limit=Limit*AutoFactor;
    }
    else
      Limit = (int)ChartGetInteger(0,CHART_VISIBLE_BARS);
   
    //Set Trend Line
    SetTrendLinePeriod();
    SetArrayFunctionLine();
  }

clsTrendLine::~clsTrendLine()
  {
  }
