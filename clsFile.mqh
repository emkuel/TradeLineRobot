//+------------------------------------------------------------------+
//|                                                      clsFile.mqh |
//|                                                      FutureRobot |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "FutureRobot"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <clsStruct.mqh>

class clsFile
  {
private:           
                     int fileOpenStatus;
                     string FileName;
                     strTrend arrMagicNumberFromFile[];
                     int OpenOrder;                     
                     
                     bool OpenFileArray();
                     void CloseFileArray();
                     bool AddMagicNumberToArray(int _magicnumber);
                     bool CompareCurrentOrderToFile();
                     bool AddMagicNumberToFile(int _magicnumber);                     
public:              
                     
                     bool Read1DimensionArrayFromFile(strTrend &arr[]);
                     bool Write1DimensionArrayToFile(strTrend &arr[]);
                     bool Read2DimensionArrayFromFile(double &arr[][],int Size2Dimension);
                     bool Write2DimensionArrayToFile(double &arr[][]);
                     
                     bool AddMagicNumber(int _magicnumber);
                     void InitMagicNumber();
                     void Copy1DimensionArrayToArray(strTrend &arrSource[], strTrend &arrDestine[]);
                     void Copy2DimensionArrayToArray(double &arrSource[][], double &arrDestine[][]);
                     void GetOrderArrayFromFile(strTrend &arrFile[]){Copy1DimensionArrayToArray(arrMagicNumberFromFile,arrFile);};
                     int GetOpenOrder(){return (OpenOrder);}; 
                     clsFile(string _filename);
                    ~clsFile();                    
  };
  
 void clsFile::InitMagicNumber()
 {
 
   if(Read1DimensionArrayFromFile(arrMagicNumberFromFile))
      if(!CompareCurrentOrderToFile())
         FileDelete(FileName);
         
 }
 bool clsFile::AddMagicNumber(int _magicnumber)
 {
   if(Read1DimensionArrayFromFile(arrMagicNumberFromFile))
      if(AddMagicNumberToArray(_magicnumber))   
      {
         if(AddMagicNumberToFile(_magicnumber))
            return(true);
      }
   
   return(false);
 }
 bool clsFile::AddMagicNumberToFile(int _magicnumber)
 {
   bool b= false;
   if(Write1DimensionArrayToFile(arrMagicNumberFromFile))
      b=true;
   
   return (b);
 }
 
 bool clsFile::AddMagicNumberToArray(int _magicnumber)
 {
   int arrsize = ArraySize(arrMagicNumberFromFile);
   
   for (int i=0; i<=arrsize-1;i++)
   {
      if(arrMagicNumberFromFile[i].magicnumber==_magicnumber)
         return(false);
   }
   
   ArrayResize(arrMagicNumberFromFile,arrsize+1);
   arrMagicNumberFromFile[arrsize].magicnumber=_magicnumber;
   
   return(true);
 }
 
 bool clsFile::CompareCurrentOrderToFile()
 {
   strTrend arr[];
   int j=0;
   int arrsize;
   int arrsizeMN = ArraySize(arrMagicNumberFromFile);
   bool b =false;
   
   for (int h=0; h<=arrsizeMN-1; h++)
   {
      for (int i=OrdersTotal()-1; i>=0; i--)
      {
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
            if(arrMagicNumberFromFile[h].magicnumber == OrderMagicNumber())
            {
               arrsize = ArraySize(arr);
               ArrayResize(arr,arrsize+1);
               arr[j].magicnumber=arrMagicNumberFromFile[h].magicnumber;
               j++;
               break;
            }
      }
   }
   
   //check if is empty
   if (ArraySize(arr)<=0)      
      return(b);
   else
   {  
      if(Write1DimensionArrayToFile(arr))
      {
         Copy1DimensionArrayToArray(arr,arrMagicNumberFromFile);
         OpenOrder=ArraySize(arrMagicNumberFromFile);
         b=true;
      }         
      return(b);
   }
   
 }

 void clsFile::CloseFileArray()
 {
    FileClose(fileOpenStatus);
 }
 bool clsFile::OpenFileArray()
 { 
   fileOpenStatus = FileOpen(FileName,FILE_BIN|FILE_READ|FILE_WRITE);
   
   if (fileOpenStatus < 0)
     return(false);
      
   return (true);
 }
 void clsFile::Copy1DimensionArrayToArray(strTrend &arrSource[], strTrend &arrDestine[])
 {
   ArrayFree(arrDestine);
   ArrayCopy(arrDestine,arrSource);
 } 
 void clsFile::Copy2DimensionArrayToArray(double &arrSource[][], double &arrDestine[][])
 {
   ArrayFree(arrDestine);
   ArrayCopy(arrDestine,arrSource);
 } 
 
 bool clsFile::Read1DimensionArrayFromFile(strTrend &arr[])
 {
   bool b=false;
   if(OpenFileArray())
   {
      FileReadArray(fileOpenStatus,arr);   
      b=true;
   }      
   CloseFileArray();  
   
   return (b);
 }
 bool clsFile::Read2DimensionArrayFromFile(double &arr[][5],int Size2Dimension)
 {
   bool b=false;
   int ErrorArrSize;
   
   if(OpenFileArray())
   {
      FileReadArray(fileOpenStatus,arr); 
      ErrorArrSize =(ArraySize(arr)/Size2Dimension)-1;
      ArrayResize(arr,ErrorArrSize+1);
      FileReadArray(fileOpenStatus,arr);
      
      b=true;
   }      
   CloseFileArray();  
   
   return (b);
}

bool clsFile::Write1DimensionArrayToFile(strTrend &arr[])
{
   bool b=false;
   FileDelete(FileName);
   if(OpenFileArray())
   {      
      FileWriteArray(fileOpenStatus,arr);   
      b=true;
   }
   
   CloseFileArray(); 
   
   return (b);
}       
bool clsFile::Write2DimensionArrayToFile(double &arr[][])
{
   bool b=false;
   FileDelete(FileName);
   if(OpenFileArray())
   {      
      FileWriteArray(fileOpenStatus,arr);   
      b=true;
   }
   
   CloseFileArray(); 
   
   return (b);
} 
clsFile::clsFile(string _filename)
  {
      FileName =_filename;
  }
clsFile::~clsFile()
  {
      FileClose(fileOpenStatus);
  }

