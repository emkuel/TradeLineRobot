//+------------------------------------------------------------------+
//|                                                      clsFile.mqh |
//|                                                      FutureRobot |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "FutureRobot"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class clsFile
  {
private:
                     int fileOpenStatus;
                     string FileName;
                     string arrMagicNumberFromFile[];
                     
                     bool OpenFileArray();
                     bool ReadMagicNumberFromFile();
                     bool AddMagicNumberToArray(int _magicnumber);
                     bool CompareCurrentOrderToFile();
public:                     
                     bool AddMagicNumber(int _magicnumber);
                     bool InitMagicNumber();
                     clsFile();
                    ~clsFile();                    
  };
 bool clsFile::InitMagicNumber()
 {
   if(OpenFileArray())
      if(ReadMagicNumberFromFile())
      {  
         if(CompareCurrentOrderToFile())
         {
            FileClose(fileOpenStatus);   
            return (true);
         }
      }
      else
         FileClose(fileOpenStatus);   
   
   return (false);
 }
 bool clsFile::AddMagicNumber(int _magicnumber)
 {
   if(OpenFileArray())
      if(ReadMagicNumberFromFile())
      {
         if(AddMagicNumberToArray(_magicnumber))   
         {
            FileClose(fileOpenStatus);      
            return (true); 
         }
      }
      else
         FileClose(fileOpenStatus);
   
             
   return (false);
 }
 bool clsFile::AddMagicNumberToArray(int _magicnumber)
 {
   int arrsize = ArraySize(arrMagicNumberFromFile);
   string sMagicNumber = IntegerToString(_magicnumber);
   
   for (int i=0; i<=arrsize-1;i++)
   {
      if(arrMagicNumberFromFile[i]==sMagicNumber)
         return(false);
   }
   
   ArrayResize(arrMagicNumberFromFile,arrsize+1);
   arrMagicNumberFromFile[arrsize]=sMagicNumber;
   
   return(true);
 }
 
 bool clsFile::CompareCurrentOrderToFile()
 {
   string arr[];
   int j=0;
   int arrsize;
   int arrsizeMN = ArraySize(arrMagicNumberFromFile);
   
   for (int h=0; h<=arrsizeMN-1;h++)
   {
      for (int i=OrdersTotal()-1; i >= 0; i--)
      {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            if(arrMagicNumberFromFile[h]== IntegerToString(OrderMagicNumber()));
            {
               arrsize = ArraySize(arr);
               ArrayResize(arr,arrsize+1);
               arr[j]=arrMagicNumberFromFile[h];
               j++;
            }
      }
   }
   
   FileReadArray(fileOpenStatus,arr);
   return(true);
 }
 bool clsFile::ReadMagicNumberFromFile()
 {
   uint read = FileReadArray(fileOpenStatus,arrMagicNumberFromFile);
   
   if(read<=0)
      return(false);
   
   return(true);
 }
 bool clsFile::OpenFileArray()
 { 
   fileOpenStatus = FileOpen(FileName,FILE_BIN|FILE_READ|FILE_WRITE);
   
   if (fileOpenStatus < 0)
     return(false);
      
   return (true);
 }
   
clsFile::clsFile()
  {
      FileName = (string)AccountNumber() + ".txt";
  }
clsFile::~clsFile()
  {
      FileClose(fileOpenStatus);
  }

