unit cv4d;
{$WARN SYMBOL_PLATFORM OFF}

{
  功能： opencv5.0 for Delphi
  作者： dbyoung@sina.com
  时间： 2026-10-01
  注意： HBITMAP2Mat 会将图像修改为 32bit 位图类型；只支持 24bit、32bit 位图图像类型；
}

interface

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
    function GaussianBlur(src: OcvMat; ksize: Integer; sigmaX: Double): OcvMat;          virtual; cdecl; abstract;
    function CvtColor(src: OcvMat; code: Integer): OcvMat;                               virtual; cdecl; abstract;
    function InRange(src: OcvMat; lbB, lbG, lbR, lbA, ubB, ubG, ubR, ubA: Byte): OcvMat; virtual; cdecl; abstract;
    function Erode(src: OcvMat; ksize, iterations: Integer): OcvMat;                     virtual; cdecl; abstract;
    function Dilate(src: OcvMat; ksize, iterations: Integer): OcvMat;                    virtual; cdecl; abstract;
    function FindContours(binary: OcvMat; mode, method: Integer): OcvContours;           virtual; cdecl; abstract;
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
procedure DestroyOcvMat(p: OcvMat); cdecl;                          external c_strOpenCV4DelphiDllName name 'DestroyOcvMat';

{ Contours 接口类的创建和销毁函数 }
procedure DestroyOcvContours(p: OcvContours); cdecl;   external c_strOpenCV4DelphiDllName name 'DestroyOcvContours';

{ ImgCodecs 接口类的创建和销毁函数 }
function CreateOcvImgCodecs: OcvImgCodecs; cdecl;      external c_strOpenCV4DelphiDllName name 'CreateOcvImgCodecs';
procedure DestroyOcvImgCodecs(p: OcvImgCodecs); cdecl; external c_strOpenCV4DelphiDllName name 'DestroyOcvImgCodecs';

{ ImgProc 接口类的创建和销毁函数 }
function  CreateOcvImgProc: OcvImgProc; cdecl;      external c_strOpenCV4DelphiDllName name 'CreateOcvImgProc';
procedure DestroyOcvImgProc(p: OcvImgProc); cdecl;  external c_strOpenCV4DelphiDllName name 'DestroyOcvImgProc';

{ Core 接口类的创建和销毁函数 }
function CreateOcvCore: OcvCore; cdecl;      external c_strOpenCV4DelphiDllName name 'CreateOcvCore';
procedure DestroyOcvCore(p: OcvCore); cdecl; external c_strOpenCV4DelphiDllName name 'DestroyOcvCore';
procedure FreeOcvBuffer(buf: PByte); cdecl;  external c_strOpenCV4DelphiDllName name 'FreeOcvBuffer';
  
const
  // imread flags
  IMREAD_UNCHANGED            = -1; //!< If set; return the loaded image as is (with alpha channel; otherwise it gets cropped). Ignore EXIF orientation.
  IMREAD_GRAYSCALE            = 0;  //!< If set; always convert image to the single channel grayscale image (codec internal conversion).
  IMREAD_COLOR_BGR            = 1;  //!< If set; always convert image to the 3 channel BGR color image.
  IMREAD_COLOR                = 1;  //!< Same as IMREAD_COLOR_BGR.
  IMREAD_ANYDEPTH             = 2;  //!< If set; return 16-bit/32-bit image when the input has the corresponding depth; otherwise convert it to 8-bit.
  IMREAD_ANYCOLOR             = 4;  //!< If set; the image is read in any possible color format.
  IMREAD_LOAD_GDAL            = 8;  //!< If set; use the gdal driver for loading the image.
  IMREAD_REDUCED_GRAYSCALE_2  = 16; //!< If set; always convert image to the single channel grayscale image and the image size reduced 1/2.
  IMREAD_REDUCED_COLOR_2      = 17; //!< If set; always convert image to the 3 channel BGR color image and the image size reduced 1/2.
  IMREAD_REDUCED_GRAYSCALE_4  = 32; //!< If set; always convert image to the single channel grayscale image and the image size reduced 1/4.
  IMREAD_REDUCED_COLOR_4      = 33; //!< If set; always convert image to the 3 channel BGR color image and the image size reduced 1/4.
  IMREAD_REDUCED_GRAYSCALE_8  = 64; //!< If set; always convert image to the single channel grayscale image and the image size reduced 1/8.
  IMREAD_REDUCED_COLOR_8      = 65; //!< If set; always convert image to the 3 channel BGR color image and the image size reduced 1/8.
  IMREAD_IGNORE_ORIENTATION   = 128; //!< If set; do not rotate the image according to EXIF's orientation flag.
  IMREAD_COLOR_RGB            = 256; //!< If set; always convert image to the 3 channel RGB color image.

  // 色彩空间转换码
  COLOR_BGR2BGRA     = 0; //!< [8U/16U/32F] add alpha channel to RGB or BGR image
  COLOR_RGB2RGBA     = COLOR_BGR2BGRA; //!< [8U/16U/32F]
  COLOR_BGRA2BGR     = 1; //!< [8U/16U/32F] remove alpha channel from RGB or BGR image
  COLOR_RGBA2RGB     = COLOR_BGRA2BGR; //!< [8U/16U/32F]
  COLOR_BGR2RGBA     = 2; //!< [8U/16U/32F] convert between RGB and BGR color spaces (with or without alpha channel)
  COLOR_RGB2BGRA     = COLOR_BGR2RGBA; //!< [8U/16U/32F]
  COLOR_RGBA2BGR     = 3; //!< [8U/16U/32F]
  COLOR_BGRA2RGB     = COLOR_RGBA2BGR; //!< [8U/16U/32F]
  COLOR_BGR2RGB      = 4; //!< [8U/16U/32F]
  COLOR_RGB2BGR      = COLOR_BGR2RGB; //!< [8U/16U/32F]
  COLOR_BGRA2RGBA    = 5; //!< [8U/16U/32F]
  COLOR_RGBA2BGRA    = COLOR_BGRA2RGBA; //!< [8U/16U/32F]
  COLOR_BGR2GRAY     = 6; //!< [8U/16U/32F] convert between RGB/BGR and grayscale; @ref color_convert_rgb_gray "color conversions"
  COLOR_RGB2GRAY     = 7; //!< [8U/16U/32F]
  COLOR_GRAY2BGR     = 8; //!< [8U/16U/32F]
  COLOR_GRAY2RGB     = COLOR_GRAY2BGR; //!< [8U/16U/32F]
  COLOR_GRAY2BGRA    = 9; //!< [8U/16U/32F]
  COLOR_GRAY2RGBA    = COLOR_GRAY2BGRA; //!< [8U/16U/32F]
  COLOR_BGRA2GRAY    = 10; //!< [8U/16U/32F]
  COLOR_RGBA2GRAY    = 11; //!< [8U/16U/32F]
  COLOR_BGR2BGR565   = 12; //!< [8U] convert between RGB/BGR and BGR565 (16-bit images)
  COLOR_RGB2BGR565   = 13; //!< [8U]
  COLOR_BGR5652BGR   = 14; //!< [8U]
  COLOR_BGR5652RGB   = 15; //!< [8U]
  COLOR_BGRA2BGR565  = 16; //!< [8U]
  COLOR_RGBA2BGR565  = 17; //!< [8U]
  COLOR_BGR5652BGRA  = 18; //!< [8U]
  COLOR_BGR5652RGBA  = 19; //!< [8U]
  COLOR_GRAY2BGR565  = 20; //!< [8U] convert between grayscale to BGR565 (16-bit images)
  COLOR_BGR5652GRAY  = 21; //!< [8U]
  COLOR_BGR2BGR555   = 22;  //!< [8U] convert between RGB/BGR and BGR555 (16-bit images)
  COLOR_RGB2BGR555   = 23;  //!< [8U]
  COLOR_BGR5552BGR   = 24;  //!< [8U]
  COLOR_BGR5552RGB   = 25;  //!< [8U]
  COLOR_BGRA2BGR555  = 26;  //!< [8U]
  COLOR_RGBA2BGR555  = 27;  //!< [8U]
  COLOR_BGR5552BGRA  = 28;  //!< [8U]
  COLOR_BGR5552RGBA  = 29;  //!< [8U]
  COLOR_GRAY2BGR555  = 30; //!< [8U] convert between grayscale and BGR555 (16-bit images)
  COLOR_BGR5552GRAY  = 31; //!< [8U]
  COLOR_BGR2XYZ      = 32; //!< [8U/16U/32F] convert RGB/BGR to CIE XYZ; @ref color_convert_rgb_xyz "color conversions"
  COLOR_RGB2XYZ      = 33; //!< [8U/16U/32F]
  COLOR_XYZ2BGR      = 34; //!< [8U/16U/32F]
  COLOR_XYZ2RGB      = 35; //!< [8U/16U/32F]
  COLOR_BGR2YCrCb    = 36; //!< [8U/16U/32F] convert RGB/BGR to luma-chroma (aka YCC); @ref color_convert_rgb_ycrcb "color conversions"
  COLOR_RGB2YCrCb    = 37; //!< [8U/16U/32F]
  COLOR_YCrCb2BGR    = 38; //!< [8U/16U/32F]
  COLOR_YCrCb2RGB    = 39; //!< [8U/16U/32F]
  COLOR_BGR2HSV      = 40; //!< [8U/32F] convert RGB/BGR to HSV (hue saturation value) with H range 0..180 if 8 bit image; @ref color_convert_rgb_hsv "color conversions"
  COLOR_RGB2HSV      = 41; //!< [8U/32F]
  COLOR_BGR2Lab      = 44; //!< [8U/32F] convert RGB/BGR to CIE Lab; @ref color_convert_rgb_lab "color conversions"
  COLOR_RGB2Lab      = 45; //!< [8U/32F]
  COLOR_BGR2Luv      = 50; //!< [8U/32F] convert RGB/BGR to CIE Luv; @ref color_convert_rgb_luv "color conversions"
  COLOR_RGB2Luv      = 51; //!< [8U/32F]
  COLOR_BGR2HLS      = 52; //!< [8U/32F] convert RGB/BGR to HLS (hue lightness saturation) with H range 0..180 if 8 bit image; @ref color_convert_rgb_hls "color conversions"
  COLOR_RGB2HLS      = 53; //!< [8U/32F]
  COLOR_HSV2BGR      = 54; //!< [8U/32F] backward conversions HSV to RGB/BGR with H range 0..180 if 8 bit image
  COLOR_HSV2RGB      = 55; //!< [8U/32F]
  COLOR_Lab2BGR      = 56; //!< [8U/32F]
  COLOR_Lab2RGB      = 57; //!< [8U/32F]
  COLOR_Luv2BGR      = 58; //!< [8U/32F]
  COLOR_Luv2RGB      = 59; //!< [8U/32F]
  COLOR_HLS2BGR      = 60; //!< [8U/32F] backward conversions HLS to RGB/BGR with H range 0..180 if 8 bit image
  COLOR_HLS2RGB      = 61; //!< [8U/32F]
  COLOR_BGR2HSV_FULL = 66; //!< [8U/32F] convert RGB/BGR to HSV (hue saturation value) with H range 0..255 if 8 bit image; @ref color_convert_rgb_hsv "color conversions"
  COLOR_RGB2HSV_FULL = 67; //!< [8U/32F]
  COLOR_BGR2HLS_FULL = 68; //!< [8U/32F] convert RGB/BGR to HLS (hue lightness saturation) with H range 0..255 if 8 bit image; @ref color_convert_rgb_hls "color conversions"
  COLOR_RGB2HLS_FULL = 69; //!< [8U/32F]
  COLOR_HSV2BGR_FULL = 70; //!< [8U/32F] backward conversions HSV to RGB/BGR with H range 0..255 if 8 bit image
  COLOR_HSV2RGB_FULL = 71; //!< [8U/32F]
  COLOR_HLS2BGR_FULL = 72; //!< [8U/32F] backward conversions HLS to RGB/BGR with H range 0..255 if 8 bit image
  COLOR_HLS2RGB_FULL = 73; //!< [8U/32F]
  COLOR_LBGR2Lab     = 74; //!< [8U/32F]
  COLOR_LRGB2Lab     = 75; //!< [8U/32F]
  COLOR_LBGR2Luv     = 76; //!< [8U/32F]
  COLOR_LRGB2Luv     = 77; //!< [8U/32F]
  COLOR_Lab2LBGR     = 78; //!< [8U/32F]
  COLOR_Lab2LRGB     = 79; //!< [8U/32F]
  COLOR_Luv2LBGR     = 80; //!< [8U/32F]
  COLOR_Luv2LRGB     = 81; //!< [8U/32F]
  COLOR_BGR2YUV      = 82; //!< [8U/16U/32F] convert between RGB/BGR and YUV
  COLOR_RGB2YUV      = 83; //!< [8U/16U/32F]
  COLOR_YUV2BGR      = 84; //!< [8U/16U/32F]
  COLOR_YUV2RGB      = 85; //!< [8U/16U/32F]
  COLOR_YUV2RGB_NV12  = 90; //!< [8U] convert between 4:2:0-subsampled YUV NV12 and RGB; two planes (in one or separate arrays): Y and U/V interleaved; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV2BGR_NV12  = 91; //!< [8U] convert between 4:2:0-subsampled YUV NV12 and BGR; two planes (in one or separate arrays): Y and U/V interleaved; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV2RGB_NV21  = 92; //!< [8U] convert between 4:2:0-subsampled YUV NV21 and RGB; two planes (in one or separate arrays): Y and V/U interleaved; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV2BGR_NV21  = 93; //!< [8U] convert between 4:2:0-subsampled YUV NV21 and BGR; two planes (in one or separate arrays): Y and V/U interleaved; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV420sp2RGB  = COLOR_YUV2RGB_NV21; //!< synonym to NV21
  COLOR_YUV420sp2BGR  = COLOR_YUV2BGR_NV21; //!< synonym to NV21
  COLOR_YUV2RGBA_NV12 = 94; //!< [8U] convert between 4:2:0-subsampled YUV NV12 and RGBA; two planes (in one or separate arrays): Y and U/V interleaved; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV2BGRA_NV12 = 95; //!< [8U] convert between 4:2:0-subsampled YUV NV12 and BGRA; two planes (in one or separate arrays): Y and U/V interleaved; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV2RGBA_NV21 = 96; //!< [8U] convert between 4:2:0-subsampled YUV NV21 and RGBA; two planes (in one or separate arrays): Y and V/U interleaved; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV2BGRA_NV21 = 97; //!< [8U] convert between 4:2:0-subsampled YUV NV21 and BGRA; two planes (in one or separate arrays): Y and V/U interleaved; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV420sp2RGBA = COLOR_YUV2RGBA_NV21; //!< synonym to NV21
  COLOR_YUV420sp2BGRA = COLOR_YUV2BGRA_NV21; //!< synonym to NV21
  COLOR_YUV2RGB_YV12  =  98; //!< [8U] convert between 4:2:0-subsampled YUV YV12 and RGB; three planes in one array: Y; V and U; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV2BGR_YV12  =  99; //!< [8U] convert between 4:2:0-subsampled YUV YV12 and BGR; three planes in one array: Y; V and U; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV2RGB_IYUV  = 100; //!< [8U] convert between 4:2:0-subsampled YUV IYUV and RGB; three planes in one array: Y; U and V; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV2BGR_IYUV  = 101; //!< [8U] convert between 4:2:0-subsampled YUV IYUV and BGR; three planes in one array: Y; U and V; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV2RGB_I420  = COLOR_YUV2RGB_IYUV; //!< synonym to IYUV
  COLOR_YUV2BGR_I420  = COLOR_YUV2BGR_IYUV; //!< synonym to IYUV
  COLOR_YUV420p2RGB   = COLOR_YUV2RGB_YV12; //!< synonym to YV12
  COLOR_YUV420p2BGR   = COLOR_YUV2BGR_YV12; //!< synonym to YV12
  COLOR_YUV2RGBA_YV12 = 102; //!< [8U] convert between 4:2:0-subsampled YUV YV12 and RGBA; three planes in one array: Y; V and U; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV2BGRA_YV12 = 103; //!< [8U] convert between 4:2:0-subsampled YUV YV12 and BGRA; three planes in one array: Y; V and U; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV2RGBA_IYUV = 104; //!< [8U] convert between 4:2:0-subsampled YUV YV12 and RGBA; three planes in one array: Y; U and V; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV2BGRA_IYUV = 105; //!< [8U] convert between 4:2:0-subsampled YUV YV12 and BGRA; three planes in one array: Y; U and V; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV2RGBA_I420 = COLOR_YUV2RGBA_IYUV; //!< synonym to IYUV
  COLOR_YUV2BGRA_I420 = COLOR_YUV2BGRA_IYUV; //!< synonym to IYUV
  COLOR_YUV420p2RGBA  = COLOR_YUV2RGBA_YV12; //!< synonym to YV12
  COLOR_YUV420p2BGRA  = COLOR_YUV2BGRA_YV12; //!< synonym to YV12
  COLOR_YUV2GRAY_420  = 106; //!< [8U] extract Y channel from YUV 4:2:0 image
  COLOR_YUV2GRAY_NV21 = COLOR_YUV2GRAY_420; //!< synonym to COLOR_YUV2GRAY_420
  COLOR_YUV2GRAY_NV12 = COLOR_YUV2GRAY_420; //!< synonym to COLOR_YUV2GRAY_420
  COLOR_YUV2GRAY_YV12 = COLOR_YUV2GRAY_420; //!< synonym to COLOR_YUV2GRAY_420
  COLOR_YUV2GRAY_IYUV = COLOR_YUV2GRAY_420; //!< synonym to COLOR_YUV2GRAY_420
  COLOR_YUV2GRAY_I420 = COLOR_YUV2GRAY_420; //!< synonym to COLOR_YUV2GRAY_420
  COLOR_YUV420sp2GRAY = COLOR_YUV2GRAY_420; //!< synonym to COLOR_YUV2GRAY_420
  COLOR_YUV420p2GRAY  = COLOR_YUV2GRAY_420; //!< synonym to COLOR_YUV2GRAY_420
  COLOR_YUV2RGB_UYVY = 107; //!< [8U] convert between YUV UYVY and RGB; YUV is 4:2:2-subsampled and interleaved as U/Y1/V/Y2; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV2BGR_UYVY = 108; //!< [8U] convert between YUV UYVY and BGR; YUV is 4:2:2-subsampled and interleaved as U/Y1/V/Y2; see @ref color_convert_rgb_yuv_42x
  //COLOR_YUV2RGB_VYUY = 109; //!< convert between YUV VYUY and RGB; YUV is 4:2:2-subsampled and interleaved as V/Y1/U/Y2; see @ref color_convert_rgb_yuv_42x
  //COLOR_YUV2BGR_VYUY = 110; //!< convert between YUV VYUY and BGR; YUV is 4:2:2-subsampled and interleaved as V/Y1/U/Y2; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV2RGB_Y422 = COLOR_YUV2RGB_UYVY; //!< synonym to UYVY
  COLOR_YUV2BGR_Y422 = COLOR_YUV2BGR_UYVY; //!< synonym to UYVY
  COLOR_YUV2RGB_UYNV = COLOR_YUV2RGB_UYVY; //!< synonym to UYVY
  COLOR_YUV2BGR_UYNV = COLOR_YUV2BGR_UYVY; //!< synonym to UYVY
  COLOR_YUV2RGBA_UYVY = 111; //!< [8U] convert between YUV UYVY and RGBA; YUV is 4:2:2-subsampled and interleaved as U/Y1/V/Y2; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV2BGRA_UYVY = 112; //!< [8U] convert between YUV UYVY and BGRA; YUV is 4:2:2-subsampled and interleaved as U/Y1/V/Y2; see @ref color_convert_rgb_yuv_42x
  //COLOR_YUV2RGBA_VYUY = 113; //!< [8U] convert between YUV VYUY and RGBA; YUV is 4:2:2-subsampled and interleaved as V/Y1/U/Y2; see @ref color_convert_rgb_yuv_42x
  //COLOR_YUV2BGRA_VYUY = 114; //!< [8U] convert between YUV VYUY and BGRA; YUV is 4:2:2-subsampled and interleaved as V/Y1/U/Y2; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV2RGBA_Y422 = COLOR_YUV2RGBA_UYVY; //!< synonym to UYVY
  COLOR_YUV2BGRA_Y422 = COLOR_YUV2BGRA_UYVY; //!< synonym to UYVY
  COLOR_YUV2RGBA_UYNV = COLOR_YUV2RGBA_UYVY; //!< synonym to UYVY
  COLOR_YUV2BGRA_UYNV = COLOR_YUV2BGRA_UYVY; //!< synonym to UYVY
  COLOR_YUV2RGB_YUY2 = 115; //!< [8U] convert between YUV YUY2 and RGB; YUV is 4:2:2-subsampled and interleaved as Y1/U/Y2/V; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV2BGR_YUY2 = 116; //!< [8U] convert between YUV YUY2 and BGR; YUV is 4:2:2-subsampled and interleaved as Y1/U/Y2/V; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV2RGB_YVYU = 117; //!< [8U] convert between YUV YVYU and RGB; YUV is 4:2:2-subsampled and interleaved as Y1/V/Y2/U; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV2BGR_YVYU = 118; //!< [8U] convert between YUV YVYU and BGR; YUV is 4:2:2-subsampled and interleaved as Y1/V/Y2/U; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV2RGB_YUYV = COLOR_YUV2RGB_YUY2; //!< synonym to YUY2
  COLOR_YUV2BGR_YUYV = COLOR_YUV2BGR_YUY2; //!< synonym to YUY2
  COLOR_YUV2RGB_YUNV = COLOR_YUV2RGB_YUY2; //!< synonym to YUY2
  COLOR_YUV2BGR_YUNV = COLOR_YUV2BGR_YUY2; //!< synonym to YUY2
  COLOR_YUV2RGBA_YUY2 = 119; //!< [8U] convert between YUV YUY2 and RGBA; YUV is 4:2:2-subsampled and interleaved as Y1/U/Y2/V; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV2BGRA_YUY2 = 120; //!< [8U] convert between YUV YUY2 and BGRA; YUV is 4:2:2-subsampled and interleaved as Y1/U/Y2/V; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV2RGBA_YVYU = 121; //!< [8U] convert between YUV YVYU and RGBA; YUV is 4:2:2-subsampled and interleaved as Y1/V/Y2/U; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV2BGRA_YVYU = 122; //!< [8U] convert between YUV YVYU and BGRA; YUV is 4:2:2-subsampled and interleaved as Y1/V/Y2/U; see @ref color_convert_rgb_yuv_42x
  COLOR_YUV2RGBA_YUYV = COLOR_YUV2RGBA_YUY2; //!< synonym to YUY2
  COLOR_YUV2BGRA_YUYV = COLOR_YUV2BGRA_YUY2; //!< synonym to YUY2
  COLOR_YUV2RGBA_YUNV = COLOR_YUV2RGBA_YUY2; //!< synonym to YUY2
  COLOR_YUV2BGRA_YUNV = COLOR_YUV2BGRA_YUY2; //!< synonym to YUY2
  COLOR_YUV2GRAY_UYVY = 123; //!< [8U] extract Y channel from YUV 4:2:2 image
  COLOR_YUV2GRAY_YUY2 = 124; //!< [8U] extract Y channel from YUV 4:2:2 image
  //CV_YUV2GRAY_VYUY  = CV_YUV2GRAY_UYVY; //!< synonym to COLOR_YUV2GRAY_UYVY
  COLOR_YUV2GRAY_Y422 = COLOR_YUV2GRAY_UYVY; //!< synonym to COLOR_YUV2GRAY_UYVY
  COLOR_YUV2GRAY_UYNV = COLOR_YUV2GRAY_UYVY; //!< synonym to COLOR_YUV2GRAY_UYVY
  COLOR_YUV2GRAY_YVYU = COLOR_YUV2GRAY_YUY2; //!< synonym to COLOR_YUV2GRAY_YUY2
  COLOR_YUV2GRAY_YUYV = COLOR_YUV2GRAY_YUY2; //!< synonym to COLOR_YUV2GRAY_YUY2
  COLOR_YUV2GRAY_YUNV = COLOR_YUV2GRAY_YUY2; //!< synonym to COLOR_YUV2GRAY_YUY2
  //! alpha premultiplication
  COLOR_RGBA2mRGBA    = 125; //!< [8U]
  COLOR_mRGBA2RGBA    = 126; //!< [8U]
  COLOR_RGB2YUV_I420  = 127; //!< [8U] convert between RGB and 4:2:0-subsampled YUV I420; three planes in one array: Y; U and V; see @ref color_convert_rgb_yuv_42x
  COLOR_BGR2YUV_I420  = 128; //!< [8U] convert between BGR and 4:2:0-subsampled YUV I420; three planes in one array: Y; U and V; see @ref color_convert_rgb_yuv_42x
  COLOR_RGB2YUV_IYUV  = COLOR_RGB2YUV_I420; //!< synonym to I420
  COLOR_BGR2YUV_IYUV  = COLOR_BGR2YUV_I420; //!< synonym to I420
  COLOR_RGBA2YUV_I420 = 129; //!< [8U] convert between RGBA and 4:2:0-subsampled YUV I420; three planes in one array: Y; U and V; see @ref color_convert_rgb_yuv_42x
  COLOR_BGRA2YUV_I420 = 130; //!< [8U] convert between BGRA and 4:2:0-subsampled YUV I420; three planes in one array: Y; U and V; see @ref color_convert_rgb_yuv_42x
  COLOR_RGBA2YUV_IYUV = COLOR_RGBA2YUV_I420; //!< synonym to I420
  COLOR_BGRA2YUV_IYUV = COLOR_BGRA2YUV_I420; //!< synonym to I420
  COLOR_RGB2YUV_YV12  = 131; //!< [8U] convert between RGB and 4:2:0-subsampled YUV YV12; three planes in one array: Y; V and U; see @ref color_convert_rgb_yuv_42x
  COLOR_BGR2YUV_YV12  = 132; //!< [8U] convert between BGR and 4:2:0-subsampled YUV YV12; three planes in one array: Y; V and U; see @ref color_convert_rgb_yuv_42x
  COLOR_RGBA2YUV_YV12 = 133; //!< [8U] convert between RGBA and 4:2:0-subsampled YUV YV12; three planes in one array: Y; V and U; see @ref color_convert_rgb_yuv_42x
  COLOR_BGRA2YUV_YV12 = 134; //!< [8U] convert between BGRA and 4:2:0-subsampled YUV YV12; three planes in one array: Y; V and U; see @ref color_convert_rgb_yuv_42x
  //! Demosaicing; see @ref color_convert_bayer "color conversions" for additional information
  COLOR_BayerBG2BGR = 46; //!< [8U/16U] equivalent to RGGB Bayer pattern
  COLOR_BayerGB2BGR = 47; //!< [8U/16U] equivalent to GRBG Bayer pattern
  COLOR_BayerRG2BGR = 48; //!< [8U/16U] equivalent to BGGR Bayer pattern
  COLOR_BayerGR2BGR = 49; //!< [8U/16U] equivalent to GBRG Bayer pattern
  COLOR_BayerRGGB2BGR = COLOR_BayerBG2BGR; //!< [8U/16U]
  COLOR_BayerGRBG2BGR = COLOR_BayerGB2BGR; //!< [8U/16U]
  COLOR_BayerBGGR2BGR = COLOR_BayerRG2BGR; //!< [8U/16U]
  COLOR_BayerGBRG2BGR = COLOR_BayerGR2BGR; //!< [8U/16U]
  COLOR_BayerRGGB2RGB = COLOR_BayerBGGR2BGR; //!< [8U/16U]
  COLOR_BayerGRBG2RGB = COLOR_BayerGBRG2BGR; //!< [8U/16U]
  COLOR_BayerBGGR2RGB = COLOR_BayerRGGB2BGR; //!< [8U/16U]
  COLOR_BayerGBRG2RGB = COLOR_BayerGRBG2BGR; //!< [8U/16U]
  COLOR_BayerBG2RGB = COLOR_BayerRG2BGR; //!< [8U/16U] equivalent to RGGB Bayer pattern
  COLOR_BayerGB2RGB = COLOR_BayerGR2BGR; //!< [8U/16U] equivalent to GRBG Bayer pattern
  COLOR_BayerRG2RGB = COLOR_BayerBG2BGR; //!< [8U/16U] equivalent to BGGR Bayer pattern
  COLOR_BayerGR2RGB = COLOR_BayerGB2BGR; //!< [8U/16U] equivalent to GBRG Bayer pattern
  COLOR_BayerBG2GRAY = 86; //!< [8U/16U] equivalent to RGGB Bayer pattern
  COLOR_BayerGB2GRAY = 87; //!< [8U/16U] equivalent to GRBG Bayer pattern
  COLOR_BayerRG2GRAY = 88; //!< [8U/16U] equivalent to BGGR Bayer pattern
  COLOR_BayerGR2GRAY = 89; //!< [8U/16U] equivalent to GBRG Bayer pattern
  COLOR_BayerRGGB2GRAY = COLOR_BayerBG2GRAY; //!< [8U/16U]
  COLOR_BayerGRBG2GRAY = COLOR_BayerGB2GRAY; //!< [8U/16U]
  COLOR_BayerBGGR2GRAY = COLOR_BayerRG2GRAY; //!< [8U/16U]
  COLOR_BayerGBRG2GRAY = COLOR_BayerGR2GRAY; //!< [8U/16U]
  //! Demosaicing using Variable Number of Gradients
  COLOR_BayerBG2BGR_VNG = 62; //!< [8U] equivalent to RGGB Bayer pattern
  COLOR_BayerGB2BGR_VNG = 63; //!< [8U] equivalent to GRBG Bayer pattern
  COLOR_BayerRG2BGR_VNG = 64; //!< [8U] equivalent to BGGR Bayer pattern
  COLOR_BayerGR2BGR_VNG = 65; //!< [8U] equivalent to GBRG Bayer pattern
  COLOR_BayerRGGB2BGR_VNG = COLOR_BayerBG2BGR_VNG; //!< [8U]
  COLOR_BayerGRBG2BGR_VNG = COLOR_BayerGB2BGR_VNG; //!< [8U]
  COLOR_BayerBGGR2BGR_VNG = COLOR_BayerRG2BGR_VNG; //!< [8U]
  COLOR_BayerGBRG2BGR_VNG = COLOR_BayerGR2BGR_VNG; //!< [8U]
  COLOR_BayerRGGB2RGB_VNG = COLOR_BayerBGGR2BGR_VNG; //!< [8U]
  COLOR_BayerGRBG2RGB_VNG = COLOR_BayerGBRG2BGR_VNG; //!< [8U]
  COLOR_BayerBGGR2RGB_VNG = COLOR_BayerRGGB2BGR_VNG; //!< [8U]
  COLOR_BayerGBRG2RGB_VNG = COLOR_BayerGRBG2BGR_VNG; //!< [8U]
  COLOR_BayerBG2RGB_VNG = COLOR_BayerRG2BGR_VNG; //!< [8U] equivalent to RGGB Bayer pattern
  COLOR_BayerGB2RGB_VNG = COLOR_BayerGR2BGR_VNG; //!< [8U] equivalent to GRBG Bayer pattern
  COLOR_BayerRG2RGB_VNG = COLOR_BayerBG2BGR_VNG; //!< [8U] equivalent to BGGR Bayer pattern
  COLOR_BayerGR2RGB_VNG = COLOR_BayerGB2BGR_VNG; //!< [8U] equivalent to GBRG Bayer pattern
  //! Edge-Aware Demosaicing
  COLOR_BayerBG2BGR_EA  = 135; //!< [8U/16U] equivalent to RGGB Bayer pattern
  COLOR_BayerGB2BGR_EA  = 136; //!< [8U/16U] equivalent to GRBG Bayer pattern
  COLOR_BayerRG2BGR_EA  = 137; //!< [8U/16U] equivalent to BGGR Bayer pattern
  COLOR_BayerGR2BGR_EA  = 138; //!< [8U/16U] equivalent to GBRG Bayer pattern
  COLOR_BayerRGGB2BGR_EA  = COLOR_BayerBG2BGR_EA; //!< [8U/16U]
  COLOR_BayerGRBG2BGR_EA  = COLOR_BayerGB2BGR_EA; //!< [8U/16U]
  COLOR_BayerBGGR2BGR_EA  = COLOR_BayerRG2BGR_EA; //!< [8U/16U]
  COLOR_BayerGBRG2BGR_EA  = COLOR_BayerGR2BGR_EA; //!< [8U/16U]
  COLOR_BayerRGGB2RGB_EA  = COLOR_BayerBGGR2BGR_EA; //!< [8U/16U]
  COLOR_BayerGRBG2RGB_EA  = COLOR_BayerGBRG2BGR_EA; //!< [8U/16U]
  COLOR_BayerBGGR2RGB_EA  = COLOR_BayerRGGB2BGR_EA; //!< [8U/16U]
  COLOR_BayerGBRG2RGB_EA  = COLOR_BayerGRBG2BGR_EA; //!< [8U/16U]
  COLOR_BayerBG2RGB_EA  = COLOR_BayerRG2BGR_EA; //!< [8U/16U] equivalent to RGGB Bayer pattern
  COLOR_BayerGB2RGB_EA  = COLOR_BayerGR2BGR_EA; //!< [8U/16U] equivalent to GRBG Bayer pattern
  COLOR_BayerRG2RGB_EA  = COLOR_BayerBG2BGR_EA; //!< [8U/16U] equivalent to BGGR Bayer pattern
  COLOR_BayerGR2RGB_EA  = COLOR_BayerGB2BGR_EA; //!< [8U/16U] equivalent to GBRG Bayer pattern
  //! Demosaicing with alpha channel
  COLOR_BayerBG2BGRA = 139; //!< [8U/16U] equivalent to RGGB Bayer pattern
  COLOR_BayerGB2BGRA = 140; //!< [8U/16U] equivalent to GRBG Bayer pattern
  COLOR_BayerRG2BGRA = 141; //!< [8U/16U] equivalent to BGGR Bayer pattern
  COLOR_BayerGR2BGRA = 142; //!< [8U/16U] equivalent to GBRG Bayer pattern
  COLOR_BayerRGGB2BGRA = COLOR_BayerBG2BGRA; //!< [8U/16U]
  COLOR_BayerGRBG2BGRA = COLOR_BayerGB2BGRA; //!< [8U/16U]
  COLOR_BayerBGGR2BGRA = COLOR_BayerRG2BGRA; //!< [8U/16U]
  COLOR_BayerGBRG2BGRA = COLOR_BayerGR2BGRA; //!< [8U/16U]
  COLOR_BayerRGGB2RGBA = COLOR_BayerBGGR2BGRA; //!< [8U/16U]
  COLOR_BayerGRBG2RGBA = COLOR_BayerGBRG2BGRA; //!< [8U/16U]
  COLOR_BayerBGGR2RGBA = COLOR_BayerRGGB2BGRA; //!< [8U/16U]
  COLOR_BayerGBRG2RGBA = COLOR_BayerGRBG2BGRA; //!< [8U/16U]
  COLOR_BayerBG2RGBA = COLOR_BayerRG2BGRA; //!< [8U/16U] equivalent to RGGB Bayer pattern
  COLOR_BayerGB2RGBA = COLOR_BayerGR2BGRA; //!< [8U/16U] equivalent to GRBG Bayer pattern
  COLOR_BayerRG2RGBA = COLOR_BayerBG2BGRA; //!< [8U/16U] equivalent to BGGR Bayer pattern
  COLOR_BayerGR2RGBA = COLOR_BayerGB2BGRA; //!< [8U/16U] equivalent to GBRG Bayer pattern
  COLOR_RGB2YUV_UYVY = 143; //!< [8U] convert between RGB and YUV UYVU; YUV is 4:2:2 and interleaved as U/Y1/V/Y2; see @ref color_convert_rgb_yuv_42x
  COLOR_BGR2YUV_UYVY = 144; //!< [8U] convert between BGR and YUV UYVU; YUV is 4:2:2 and interleaved as U/Y1/V/Y2; see @ref color_convert_rgb_yuv_42x
  COLOR_RGB2YUV_Y422 = COLOR_RGB2YUV_UYVY; //!< synonym to UYVY
  COLOR_BGR2YUV_Y422 = COLOR_BGR2YUV_UYVY; //!< synonym to UYVY
  COLOR_RGB2YUV_UYNV = COLOR_RGB2YUV_UYVY; //!< synonym to UYVY
  COLOR_BGR2YUV_UYNV = COLOR_BGR2YUV_UYVY; //!< synonym to UYVY
  COLOR_RGBA2YUV_UYVY = 145; //!< [8U] convert between RGBA and YUV UYVU; YUV is 4:2:2 and interleaved as U/Y1/V/Y2; see @ref color_convert_rgb_yuv_42x
  COLOR_BGRA2YUV_UYVY = 146; //!< [8U] convert between BGRA and YUV UYVU; YUV is 4:2:2 and interleaved as U/Y1/V/Y2; see @ref color_convert_rgb_yuv_42x
  COLOR_RGBA2YUV_Y422 = COLOR_RGBA2YUV_UYVY; //!< synonym to UYVY
  COLOR_BGRA2YUV_Y422 = COLOR_BGRA2YUV_UYVY; //!< synonym to UYVY
  COLOR_RGBA2YUV_UYNV = COLOR_RGBA2YUV_UYVY; //!< synonym to UYVY
  COLOR_BGRA2YUV_UYNV = COLOR_BGRA2YUV_UYVY; //!< synonym to UYVY
  COLOR_RGB2YUV_YUY2 = 147; //!< [8U] convert between RGB and YUV YUY2; YUV is 4:2:2 and interleaved as Y1/U/Y2/V; see @ref color_convert_rgb_yuv_42x
  COLOR_BGR2YUV_YUY2 = 148; //!< [8U] convert between BGR and YUV YUY2; YUV is 4:2:2 and interleaved as Y1/U/Y2/V; see @ref color_convert_rgb_yuv_42x
  COLOR_RGB2YUV_YVYU = 149; //!< [8U] convert between RGB and YUV YVYU; YUV is 4:2:2 and interleaved as Y1/V/Y2/U; see @ref color_convert_rgb_yuv_42x
  COLOR_BGR2YUV_YVYU = 150; //!< [8U] convert between BGR and YUV YVYU; YUV is 4:2:2 and interleaved as Y1/V/Y2/U; see @ref color_convert_rgb_yuv_42x
  COLOR_RGB2YUV_YUYV = COLOR_RGB2YUV_YUY2; //!< synonym to YUY2
  COLOR_BGR2YUV_YUYV = COLOR_BGR2YUV_YUY2; //!< synonym to YUY2
  COLOR_RGB2YUV_YUNV = COLOR_RGB2YUV_YUY2; //!< synonym to YUY2
  COLOR_BGR2YUV_YUNV = COLOR_BGR2YUV_YUY2; //!< synonym to YUY2
  COLOR_RGBA2YUV_YUY2 = 151; //!< [8U] convert between RGBA and YUV YUY2; YUV is 4:2:2 and interleaved as Y1/U/Y2/V; see @ref color_convert_rgb_yuv_42x
  COLOR_BGRA2YUV_YUY2 = 152; //!< [8U] convert between BGRA and YUV YUY2; YUV is 4:2:2 and interleaved as Y1/U/Y2/V; see @ref color_convert_rgb_yuv_42x
  COLOR_RGBA2YUV_YVYU = 153; //!< [8U] convert between RGBA and YUV YVYU; YUV is 4:2:2 and interleaved as Y1/V/Y2/U; see @ref color_convert_rgb_yuv_42x
  COLOR_BGRA2YUV_YVYU = 154; //!< [8U] convert between BGRA and YUV YVYU; YUV is 4:2:2 and interleaved as Y1/V/Y2/U; see @ref color_convert_rgb_yuv_42x
  COLOR_RGBA2YUV_YUYV = COLOR_RGBA2YUV_YUY2; //!< synonym to YUY2
  COLOR_BGRA2YUV_YUYV = COLOR_BGRA2YUV_YUY2; //!< synonym to YUY2
  COLOR_RGBA2YUV_YUNV = COLOR_RGBA2YUV_YUY2; //!< synonym to YUY2
  COLOR_BGRA2YUV_YUNV = COLOR_BGRA2YUV_YUY2; //!< synonym to YUY2
  COLOR_BGR2Oklab     = 155; //!< [8U/32F] convert RGB/BGR to perceptual Oklab; @ref color_convert_rgb_oklab "color conversions"
  COLOR_RGB2Oklab     = 156; //!< [8U/32F]
  COLOR_Oklab2BGR     = 157; //!< [8U/32F]
  COLOR_Oklab2RGB     = 158; //!< [8U/32F]
  COLOR_COLORCVT_MAX  = 159;

  // 二值化类型
  THRESH_BINARY     = 0; //!< \f[\texttt{dst} (x;y) =  \fork{\texttt{maxval}}{if \(\texttt{src}(x;y) > \texttt{thresh}\)}{0}{otherwise}\f]
  THRESH_BINARY_INV = 1; //!< \f[\texttt{dst} (x;y) =  \fork{0}{if \(\texttt{src}(x;y) > \texttt{thresh}\)}{\texttt{maxval}}{otherwise}\f]
  THRESH_TRUNC      = 2; //!< \f[\texttt{dst} (x;y) =  \fork{\texttt{threshold}}{if \(\texttt{src}(x;y) > \texttt{thresh}\)}{\texttt{src}(x;y)}{otherwise}\f]
  THRESH_TOZERO     = 3; //!< \f[\texttt{dst} (x;y) =  \fork{\texttt{src}(x;y)}{if \(\texttt{src}(x;y) > \texttt{thresh}\)}{0}{otherwise}\f]
  THRESH_TOZERO_INV = 4; //!< \f[\texttt{dst} (x;y) =  \fork{0}{if \(\texttt{src}(x;y) > \texttt{thresh}\)}{\texttt{src}(x;y)}{otherwise}\f]
  THRESH_MASK       = 7;
  THRESH_OTSU       = 8; //!< flag; use Otsu algorithm to choose the optimal threshold value
  THRESH_TRIANGLE   = 16; //!< flag; use Triangle algorithm to choose the optimal threshold value
  THRESH_DRYRUN     = 128; //!< flag; compute threshold only (useful for OTSU/TRIANGLE) but does not actually run thresholding

  // 轮廓检索模式
  RETR_EXTERNAL  = 0; // retrieves only the extreme outer contours. It sets `hierarchy[i][2]=hierarchy[i][3]=-1` for all the contours.
  RETR_LIST      = 1; // retrieves all of the contours without establishing any hierarchical relationships. 
  // retrieves all of the contours and organizes them into a two-level hierarchy. At the top
  // level, there are external boundaries of the components. At the second level, there are
  // boundaries of the holes. If there is another contour inside a hole of a connected component, it
  // is still put at the top level. 
  RETR_CCOMP     = 2;
  RETR_TREE      = 3; // retrieves all of the contours and reconstructs a full hierarchy of nested contours.
  RETR_FLOODFILL = 4; //!<

  // 轮廓近似方法
  CHAIN_CODE             = 0; // TBD 
  CHAIN_APPROX_NONE      = 1; // stores absolutely all the contour points. That is, any 2 subsequent points (x1,y1) and (x2,y2) of the contour will be either horizontal, vertical or diagonal neighbors, that is, max(abs(x1-x2),abs(y2-y1))==1. 
  CHAIN_APPROX_SIMPLE    = 2; // compresses horizontal, vertical, and diagonal segments and leaves only their end points. For example, an up-right rectangular contour is encoded with 4 points.
  CHAIN_APPROX_TC89_L1   = 3; // applies one of the flavors of the Teh-Chin chain approximation algorithm @cite TehChin89 
  CHAIN_APPROX_TC89_KCOS = 4; // applies one of the flavors of the Teh-Chin chain approximation algorithm @cite TehChin89 
  LINK_RUNS              = 5; // TBD 

implementation

end.
