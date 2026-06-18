### 计算机图形学定义与核心问题
- **定义**：利用计算机生成和显示图像
- **核心研究问题**：
  - 建模（Modeling）
  - 渲染（Rendering）
  - 动画（Animation）
  - 感知（Perception）

---

### 图形学历史与发展
#### （1）显示硬件
- **矢量显示**：1963年改进示波器，1974年Evans & Sutherland Picture System
- **光栅显示**：1975年帧缓存，1980年代廉价帧缓存 → 位图个人电脑，1990年代液晶显示，2000年代微镜投影（数字影院），2010年代HDR显示
- **HDR显示标准**：VESA DisplayHDR 等级（400/500/600/1000/1400，True Black系列）
- **沉浸式显示**：立体头戴显示器、Reality Center、DOME、CAVE

#### （2）输入硬件
- **2D输入**：光笔、鼠标、摇杆、轨迹球、触摸板；1970-80年代CCD传感器+帧采集器；1990-2000年代CMOS数字传感器+HDR成像
- **3D输入**：1980年代3D追踪器，1990年代主动测距仪
- **4D及以上**：多相机（光场）、多臂龙门架
- **RGBD相机**：FaceID、Kinect DK、AR相机（TOF技术）

#### （3）渲染算法发展
- **1960年代**：可见性问题（Roberts, Appel → 隐藏线；Warnock, Witkins → 隐藏面；Sutherland → 可见性=排序）
- **1970年代（光栅图形）**：
  - Gouraud（漫反射光照）
  - Phong（高光光照）
  - Blinn（曲面、纹理）
  - Crow（抗锯齿）
- **1980年代（全局光照）**：
  - Whitted（光线追踪）
  - Goral, Torrance, Cohen（辐射度方法）
  - Kajiya（渲染方程）
- **1980年代末（写实渲染）**：
  - Cook（Shade Trees）
  - Perlin（着色语言）
  - Hanrahan & Lawson（RenderMan）
- **1990年代初（非真实感渲染）**：
  - 体渲染（Drebin, Levoy）
  - 印象派绘制（Haeberli）
  - 钢笔水墨插画（Salesin）
  - 绘画风格渲染（Meier）
- **1990年代中后期（基于图像的渲染）**：
  - Plenoptic Modeling（McMillan）
  - Light Field / Lumigraph（Levoy, Gortler）
  - Concentric Mosaics（Shum, Kang）
  - Plenoptic Stitching（Aliaga）
- **1990年代末（表面细节渲染）**：
  - 双向纹理函数（Dana）
  - BSSRDF（Jensen）
  - Shell Texture Function（Chen）
- **2000年代初（交互式全局光照）**：
  - PRT（预计算辐射度传输，Microsoft）
  - GPU加速全局光照（Microsoft, NVIDIA, AMD, ZJU）
  - 计算摄影、超分辨率立体媒体
- **2016年起（智能图形/深度学习）**：
  - 视频到视频合成（NeurIPS 2018）
  - AI加速降噪器（SIGGRAPH 2017）
  - 深度学习用于人脸建模、动画、重演、角色动画等

---

### 6. VR/AR发展
- **行业领导者**：
  - Facebook（Quest系列）
  - Microsoft（HoloLens）
  - Apple（Vision Pro, ARKit）
  - Google（Android XR, ARCore）
  - Valve（Lighthouse, Index, HTC Vive）
  - 国内：Rokid等

---

### 7. 图形学与深度学习结合的代表性工作（2016年起）
- **人脸建模与动画**：
  - Memoji（Apple）
  - 面部与语音动画
  - 面部重演（Facial Reenactment）
  - DreamFace（SIGGRAPH 2023，文本驱动3D人脸生成）
  - SketchFaceNeRF（SIGGRAPH 2023）
- **角色动画**：
  - DeepMimic（深度强化学习驱动物理角色技能）
  - Motion2Fusion（实时体积动作捕捉）
  - MEGATrack（VR手部追踪）
  - 眼-脸联合模型（Photorealistic Facial Animation）
