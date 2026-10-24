#include <opencv2/opencv.hpp>
#include <opencv2/core.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/geometry.hpp>
#include <windows.h>
#include <fstream>
#include <string>
#include <vector>
#include <cstring>

using PByte = unsigned char*;

static std::string WStringToUtf8(const wchar_t* wstr)
{
    if (!wstr) return std::string();
    int size_needed = ::WideCharToMultiByte(CP_UTF8, 0, wstr, -1, NULL, 0, NULL, NULL);
    if (size_needed <= 0) return std::string();
    std::string str(size_needed - 1, '\0');
    ::WideCharToMultiByte(CP_UTF8, 0, wstr, -1, &str[0], size_needed, NULL, NULL);
    return str;
}

// ==================== OcvMat ====================
class OcvMat
{
public:
    OcvMat(int rows, int cols, int type) : mat(rows, cols, type) {}

    virtual int    __cdecl GetWidth()      { return mat.cols; }
    virtual int    __cdecl GetHeight()     { return mat.rows; }
    virtual int    __cdecl GetChannels()   { return mat.channels(); }
    virtual int    __cdecl GetDepth()      { return mat.depth(); }
    virtual bool   __cdecl IsEmpty()       { return mat.empty(); }
    virtual PByte  __cdecl GetData()       { return mat.data; }
    virtual size_t __cdecl GetTotalBytes() { return mat.total() * mat.elemSize(); }
    virtual void   __cdecl Release()       { mat.release(); }

    cv::Mat& Native()          { return mat; }
    void __cdecl DestroySelf() { delete this; }

private:
    cv::Mat mat;
};

// ==================== OcvContours ====================
class OcvContours
{
public:
    OcvContours() {}

    // 由 OcvImgProc::FindContours 内部调用
    void SetContours(std::vector<std::vector<cv::Point>>&& contours) { contours_ = std::move(contours); }

    virtual int __cdecl Count() { return (int)contours_.size(); }

    // 返回面积最大的轮廓索引；空集合返回 -1
    virtual int __cdecl MaxAreaIndex()
    {
        if (contours_.empty()) return -1;
        int best = 0;
        double bestArea = cv::contourArea(contours_[0]);
        for (size_t i = 1; i < contours_.size(); ++i)
        {
            double a = cv::contourArea(contours_[i]);
            if (a > bestArea) { bestArea = a; best = (int)i; }
        }
        return best;
    }

    virtual int __cdecl PointCount(int idx)
    {
        if (idx < 0 || idx >= (int)contours_.size()) return 0;
        return (int)contours_[idx].size();
    }

    // outPoints 指向调用方提供的 TPoint 数组（cv::Point 与 TPoint 内存布局一致）
    // 返回实际写入的点数
    virtual int __cdecl GetPoints(int idx, void* outPoints, int maxCount)
    {
        if (idx < 0 || idx >= (int)contours_.size()) return 0;
        const auto& pts = contours_[idx];
        int n = (int)pts.size();
        if (n > maxCount) n = maxCount;
        if (outPoints && n > 0)
            std::memcpy(outPoints, pts.data(), (size_t)n * sizeof(cv::Point));
        return n;
    }

    virtual double __cdecl ArcLength(int idx, int closed)
    {
        if (idx < 0 || idx >= (int)contours_.size()) return 0.0;
        return cv::arcLength(contours_[idx], closed != 0);
    }

    virtual double __cdecl ContourArea(int idx)
    {
        if (idx < 0 || idx >= (int)contours_.size()) return 0.0;
        return cv::contourArea(contours_[idx]);
    }

    void __cdecl DestroySelf() { delete this; }

private:
    std::vector<std::vector<cv::Point>> contours_;
};

// ==================== OcvImgCodecs ====================
class OcvImgCodecs
{
public:
    OcvImgCodecs() {}

    virtual OcvMat* __cdecl Imread(const wchar_t* path, int flags)
    {
        if (!path) return nullptr;
        cv::Mat m = cv::imread(WStringToUtf8(path), flags);
        if (m.empty()) return nullptr;
		
		cv::Mat m_bgra;
        if (m.channels() == 3)      cv::cvtColor(m, m_bgra, cv::COLOR_BGR2BGRA);
        else if (m.channels() == 1) cv::cvtColor(m, m_bgra, cv::COLOR_GRAY2BGRA);
        else if (m.channels() == 4) m_bgra = m;
		else return nullptr; 
		
        OcvMat* p = new OcvMat(m_bgra.rows, m_bgra.cols, m_bgra.type());
        m_bgra.copyTo(p->Native());
        return p;
    }

    virtual bool __cdecl Imwrite(const wchar_t* path, OcvMat* p)
    {
        if (!path || !p) return false;
        return cv::imwrite(WStringToUtf8(path), p->Native());
    }

    void __cdecl DestroySelf() { delete this; }
};

// ==================== OcvImgProc ====================
class OcvImgProc
{
public:
    OcvImgProc() {}

    // 高斯模糊；ksize 会被强制为奇数
    virtual OcvMat* __cdecl GaussianBlur(OcvMat* src, int ksize, double sigmaX)
    {
        if (!src || src->Native().empty() || ksize <= 0) return nullptr;
        int k = ksize | 1;
        cv::Mat dst;
        cv::GaussianBlur(src->Native(), dst, cv::Size(k, k), sigmaX);
        return Wrap(dst);
    }

    // 色彩空间转换；常用 code：COLOR_BGR2HSV=40、COLOR_BGR2GRAY=6
    virtual OcvMat* __cdecl CvtColor(OcvMat* src, int code)
    {
        if (!src || src->Native().empty()) return nullptr;
        cv::Mat dst;
        cv::cvtColor(src->Native(), dst, code);
        return Wrap(dst);
    }

    // 二值化；多通道范围判断，输出 CV_8UC1 掩码（0 或 255）
    // lb0~lb3 / ub0~ub3 对应图像各通道的下界/上界，多余分量被忽略
    // 例如 BGRA 图像：lb0=B下界, lb1=G下界, lb2=R下界, lb3=A下界
    virtual OcvMat* __cdecl InRange(OcvMat* src,
        uchar lb0, uchar lb1, uchar lb2, uchar lb3,
        uchar ub0, uchar ub1, uchar ub2, uchar ub3)
    {
        if (!src || src->Native().empty()) return nullptr;
        cv::Scalar lowerb(lb0, lb1, lb2, lb3);
        cv::Scalar upperb(ub0, ub1, ub2, ub3);
        cv::Mat dst;
        cv::inRange(src->Native(), lowerb, upperb, dst);
        return Wrap(dst);
    }

    // 腐蚀；ksize 为结构元边长（强制奇数），iterations 为迭代次数
    virtual OcvMat* __cdecl Erode(OcvMat* src, int ksize, int iterations)
    {
        if (!src || src->Native().empty() || ksize <= 0 || iterations <= 0) return nullptr;
        int k = ksize | 1;
        cv::Mat kernel = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(k, k));
        cv::Mat dst;
        cv::erode(src->Native(), dst, kernel, cv::Point(-1, -1), iterations);
        return Wrap(dst);
    }

    // 膨胀
    virtual OcvMat* __cdecl Dilate(OcvMat* src, int ksize, int iterations)
    {
        if (!src || src->Native().empty() || ksize <= 0 || iterations <= 0) return nullptr;
        int k = ksize | 1;
        cv::Mat kernel = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(k, k));
        cv::Mat dst;
        cv::dilate(src->Native(), dst, kernel, cv::Point(-1, -1), iterations);
        return Wrap(dst);
    }

    // 轮廓提取；binary 必须是 8 位单通道二值图
    // mode 常用：RETR_EXTERNAL=0、RETR_LIST=1、RETR_TREE=3
    // method 常用：CHAIN_APPROX_NONE=1、CHAIN_APPROX_SIMPLE=2
    virtual OcvContours* __cdecl FindContours(OcvMat* binary, int mode, int method)
    {
        if (!binary || binary->Native().empty()) return nullptr;
        if (binary->Native().type() != CV_8UC1) return nullptr;

        cv::Mat src = binary->Native().clone();
        std::vector<std::vector<cv::Point>> contours;
        cv::findContours(src, contours, mode, method);
        OcvContours* c = new OcvContours();
        c->SetContours(std::move(contours));
        return c;
    }

    void __cdecl DestroySelf() { delete this; }

private:
    static OcvMat* Wrap(const cv::Mat& m)
    {
        OcvMat* p = new OcvMat(m.rows, m.cols, m.type());
        m.copyTo(p->Native());
        return p;
    }
};

// ==================== OcvCore ====================
class OcvCore
{
public:
    OcvCore() {}

    virtual PByte __cdecl GetBuildInformation(int* outLen)
    {
        std::string info = cv::getBuildInformation();
        if (outLen) *outLen = (int)info.size();
        PByte buf = new unsigned char[info.size() + 1];
        std::memcpy(buf, info.c_str(), info.size() + 1);
        return buf;
    }

    virtual PByte __cdecl GetVersionString(int* outLen)
    {
        std::string ver = cv::getVersionString();
        if (outLen) *outLen = (int)ver.size();
        PByte buf = new unsigned char[ver.size() + 1];
        std::memcpy(buf, ver.c_str(), ver.size() + 1);
        return buf;
    }

    virtual OcvMat* __cdecl HBITMAP2Mat(HBITMAP hBmp)
    {
        if (!hBmp) return nullptr;

        DIBSECTION ds = {};
        if (GetObject(hBmp, sizeof(DIBSECTION), &ds) != sizeof(DIBSECTION)) return nullptr;
        if (!ds.dsBm.bmBits) return nullptr;   

        int w      = ds.dsBm.bmWidth;
        int h      = ds.dsBm.bmHeight;
        int bpp    = ds.dsBm.bmBitsPixel;
        int stride = ds.dsBm.bmWidthBytes;
        if (w <= 0 || h <= 0 || stride <= 0) return nullptr;

        bool topDown = (ds.dsBmih.biHeight < 0);
        cv::Mat m;
        switch (bpp)
        {
            case 32:
            {
                cv::Mat src(h, w, CV_8UC4, ds.dsBm.bmBits, stride);
                if (topDown) src.copyTo(m);
                else         cv::flip(src, m, 0);
                break;
            }
            case 24:
            {
                cv::Mat src(h, w, CV_8UC3, ds.dsBm.bmBits, stride);
                cv::Mat tmp;
                if (topDown) tmp = src;
                else         cv::flip(src, tmp, 0);
                cv::cvtColor(tmp, m, cv::COLOR_BGR2BGRA);
                break;
            }
            default:
                return nullptr;
        }

        OcvMat* p = new OcvMat(m.rows, m.cols, m.type());
        m.copyTo(p->Native());
        return p;
    }

    void __cdecl DestroySelf() { delete this; }
};

// ==================== export function ====================
extern "C"
{
    // ==================== OcvMat ====================
    __declspec(dllexport) OcvMat* __cdecl CreateOcvMat(int rows, int cols, int type)
    {
        return new OcvMat(rows, cols, type);
    }
    __declspec(dllexport) void __cdecl DestroyOcvMat(OcvMat* p)
    {
        if (p) p->DestroySelf();
    }

    // ==================== OcvContours  ====================
    __declspec(dllexport) void __cdecl DestroyOcvContours(OcvContours* p)
    {
        if (p) p->DestroySelf();
    }

    // ==================== OcvImgCodecs ====================
    __declspec(dllexport) OcvImgCodecs* __cdecl CreateOcvImgCodecs()
    {
        return new OcvImgCodecs();
    }
    __declspec(dllexport) void __cdecl DestroyOcvImgCodecs(OcvImgCodecs* p)
    {
        if (p) p->DestroySelf();
    }
	
    // ==================== OcvImgProc ====================
    __declspec(dllexport) OcvImgProc* __cdecl CreateOcvImgProc()
    {
        return new OcvImgProc();
    }
    __declspec(dllexport) void __cdecl DestroyOcvImgProc(OcvImgProc* p)
    {
        if (p) p->DestroySelf();
    }
    
    // ==================== OcvCore ====================
    __declspec(dllexport) OcvCore* __cdecl CreateOcvCore()
    {
        return new OcvCore();
    }
    __declspec(dllexport) void __cdecl DestroyOcvCore(OcvCore* p)
    {
        if (p) p->DestroySelf();
    }
    __declspec(dllexport) void __cdecl FreeOcvBuffer(PByte buf)
    {
        delete[] buf;
    }
}
