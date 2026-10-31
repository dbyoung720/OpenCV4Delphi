unit cv4d;
{$WARN SYMBOL_PLATFORM OFF}

{
  功能： opencv5.0 for Delphi
  作者： dbyoung@sina.com
  时间： 2026-10-01
  注意： HBITMAP2Mat 会将图像修改为 32bit 位图类型；只支持 24bit、32bit 位图图像类型；
  注意：本模块仅处理 4 通道 BGRA 图像；输入限定为：CV_8UC4；
}

interface

uses Winapi.Windows;

type
  { Mat 矩阵类的接口 }
  OcvMat = class
  public
    function  GetWidth: Integer;         virtual; cdecl; abstract;
    function  GetHeight: Integer;        virtual; cdecl; abstract;
    function  GetChannels: Integer;      virtual; cdecl; abstract;
    function  GetDepth: Integer;         virtual; cdecl; abstract;
    function  IsEmpty: Boolean;          virtual; cdecl; abstract;
    function  GetData: PByte;            virtual; cdecl; abstract;
    function  GetTotalBytes: NativeUInt; virtual; cdecl; abstract;
    procedure Release;                   virtual; cdecl; abstract;
  end;

  { Contours 轮廓类的接口 }
  OcvContours = class
  public
    function Count: Integer;                                                         virtual; cdecl; abstract;
    function MaxAreaIndex: Integer;                                                  virtual; cdecl; abstract;
    function PointCount(idx: Integer): Integer;                                      virtual; cdecl; abstract;
    function GetPoints(idx: Integer; outPoints: PPoint; maxCount: Integer): Integer; virtual; cdecl; abstract;
    function ArcLength(idx: Integer; closed: Integer): Double;                       virtual; cdecl; abstract;
    function ContourArea(idx: Integer): Double;                                      virtual; cdecl; abstract;
  end;

  { ImgCodecs 编解码类的接口 }
  OcvImgCodecs = class
  public
    function Imread(const path: PWideChar; flags: Integer): OcvMat; virtual; cdecl; abstract;
    function Imwrite(const path: PWideChar; p: OcvMat): Boolean;    virtual; cdecl; abstract;
  end;

  { ImgProc  图像处理类的接口 }
  OcvImgProc = class
  public
    function GaussianBlur(src: OcvMat; ksize: Integer; sigmaX: Double): OcvMat;                virtual; cdecl; abstract;
    function Blur(src: OcvMat; ksize: Integer): OcvMat;                                        virtual; cdecl; abstract;
    function BoxFilter(src: OcvMat; ksize: Integer; normalize: Boolean): OcvMat;               virtual; cdecl; abstract;
    function MedianBlur(src: OcvMat; ksize: Integer): OcvMat;                                  virtual; cdecl; abstract;
    function BilateralFilter(src: OcvMat; d: Integer; sigmaColor, sigmaSpace: Double): OcvMat; virtual; cdecl; abstract;
    function CvtColor(src: OcvMat; code: Integer): OcvMat;                                     virtual; cdecl; abstract;
    function InRange(src: OcvMat; lbB, lbG, lbR, lbA, ubB, ubG, ubR, ubA: Byte): OcvMat;       virtual; cdecl; abstract;
    function Erode(src: OcvMat; ksize, iterations: Integer): OcvMat;                           virtual; cdecl; abstract;
    function Dilate(src: OcvMat; ksize, iterations: Integer): OcvMat;                          virtual; cdecl; abstract;
    function FindContours(binary: OcvMat; mode, method: Integer): OcvContours;                 virtual; cdecl; abstract;
  end;

  { Photo 图像摄影类的接口 }
  OcvPhoto = class
  public
    function FastNlMeansDenoisingColored(src: OcvMat; h, hColor: Double; templateWindowSize, searchWindowSize: Integer): OcvMat; virtual; cdecl; abstract;
    function FastNlMeansDenoising(src: OcvMat; h: Double; templateWindowSize, searchWindowSize: Integer): OcvMat;                virtual; cdecl; abstract;	
    function DenoiseTVL1(src: OcvMat; lambda: Double; niters: Integer): OcvMat;                                                  virtual; cdecl; abstract;
    function BM3DDenoising(src: OcvMat): OcvMat;                                                                                 virtual; cdecl; abstract;
  end;

  { c 语言风格导出的函数接口 }
  OcvCore = class
  public
    function GetBuildInformation(var Len: Integer): PByte; virtual; cdecl; abstract;
    function GetVersionString(var Len: Integer): PByte;    virtual; cdecl; abstract;
    function HBITMAP2Mat(hBmp: HBITMAP): OcvMat;           virtual; cdecl; abstract;
  end;

const c_strOpenCV4DelphiDllName = 'cv4d.dll';

{ Mat 接口类的创建和销毁函数 }
function CreateOcvMat(rows, cols, matType: Integer): OcvMat; cdecl; external c_strOpenCV4DelphiDllName name 'CreateOcvMat';
procedure DestroyOcvMat(p: OcvMat);                          cdecl; external c_strOpenCV4DelphiDllName name 'DestroyOcvMat';

{ Contours 接口类的创建和销毁函数 }
procedure DestroyOcvContours(p: OcvContours);   cdecl; external c_strOpenCV4DelphiDllName name 'DestroyOcvContours';

{ ImgCodecs 接口类的创建和销毁函数 }
function CreateOcvImgCodecs: OcvImgCodecs;      cdecl; external c_strOpenCV4DelphiDllName name 'CreateOcvImgCodecs';
procedure DestroyOcvImgCodecs(p: OcvImgCodecs); cdecl; external c_strOpenCV4DelphiDllName name 'DestroyOcvImgCodecs';

{ ImgProc 接口类的创建和销毁函数 }
function  CreateOcvImgProc: OcvImgProc;     cdecl; external c_strOpenCV4DelphiDllName name 'CreateOcvImgProc';
procedure DestroyOcvImgProc(p: OcvImgProc); cdecl; external c_strOpenCV4DelphiDllName name 'DestroyOcvImgProc';

{ Photo 接口类的创建和销毁函数 }
function  CreateOcvPhoto: OcvPhoto;     cdecl;  external c_strOpenCV4DelphiDllName name 'CreateOcvPhoto';
procedure DestroyOcvPhoto(p: OcvPhoto); cdecl;  external c_strOpenCV4DelphiDllName name 'DestroyOcvPhoto';
  
{ Core 接口类的创建和销毁函数 }
function CreateOcvCore: OcvCore;      cdecl; external c_strOpenCV4DelphiDllName name 'CreateOcvCore';
procedure DestroyOcvCore(p: OcvCore); cdecl; external c_strOpenCV4DelphiDllName name 'DestroyOcvCore';
procedure FreeOcvBuffer(buf: PByte);  cdecl; external c_strOpenCV4DelphiDllName name 'FreeOcvBuffer';

implementation

end.
