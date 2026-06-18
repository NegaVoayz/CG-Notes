# 《计算机图形学》第6讲“Hidden Surface Removal（HSR）”

---

## 📘 一、Hidden Surface Removal（HSR）核心问题

HSR 要解决的核心问题是：**哪些物体/表面是可见的，哪些被遮挡？**  
常见情况包括：
- 背面朝向摄像机
- 被其他物体遮挡
- 在图像平面上重叠
- 表面之间相互交叉

---

## 🧩 二、HSR 算法分类

### 1. 物体空间算法（Object Space）
- **Back-face Culling**（背面剔除）
- **Depth Sort（Painter’s Algorithm）**

### 2. 图像空间算法（Image Space）
- **Ray Casting**
- **Z-buffer**
- **Scan-line**
- **Area Subdivision（Warnock算法）**
- **BSP Tree**

---

## 🔍 三、重点算法详解

### ✅ Back-face Culling（背面剔除）
- 判断条件：法向量与视线方向的点积 $ V \cdot N < 0 $ 则为背面
- 适用于**单个凸物体**，可完全解决遮挡问题
- 对凹物体或多物体场景仅作为预处理

### ✅ Depth Sort（Painter’s Algorithm）
- 按深度排序多边形，从远到近绘制
- 问题：多边形相交或循环遮挡（需拆分）

### ✅ Ray Casting（光线投射）
- 对每个像素发射光线，找第一个交点
- 时间复杂度高：$ O(p \log n) $，p为像素数
- 简单但一般不用于实时渲染

### ✅ Z-buffer（深度缓冲）
- 存储每个像素的深度值，只绘制更近的像素
- 支持任意绘制顺序
- 缺点：内存占用大、不支持透明、有锯齿问题
- 硬件支持广泛，是现代GPU主流方法

### ✅ A-buffer（累积缓冲）
- 扩展Z-buffer，存储多个片段列表
- 支持透明度处理和抗锯齿

### ✅ Scan-line Algorithm（扫描线算法）
- 按扫描线处理，维护活跃边列表，判断可见性
- 利用扫描线连贯性，适合软件渲染

### ✅ Area Subdivision（Warnock算法）
- 递归划分屏幕区域
- 若区域内无复杂遮挡，则直接填充；否则继续细分

### ✅ BSP Tree（二叉空间分割树）
- 将空间递归划分为前后两部分
- 可见性遍历：根据视点位置决定遍历子树的顺序
- 适用于静态场景、实时漫游

---

## 🧰 四、OpenGL 中的 HSR 支持

1. **视锥裁剪（View Frustum Clipping）**
2. **背面剔除（Back-face Culling）**
3. **深度缓冲（Depth Buffering）**

> 注意：glClipPlane 可额外指定裁剪平面，但会降低性能。

---

## ⚠️ 五、未详细提及但重要的技术关键词

- **Occlusion Culling（遮挡剔除）** —— 针对被完全遮挡的物体提前剔除
- **Portal Rendering（门户渲染）** —— 用于室内场景的可见性优化
- **Hierarchical Z-buffer（层级Z缓冲）** —— 加速遮挡检测
- **Tiled Rendering（分块渲染）** —— 提高缓存利用率
- **Deferred Shading（延迟着色）** —— 与Z-buffer结合使用
- **Stencil Buffer（模板缓冲）** —— 辅助可见性判断（如阴影）
- **Z-fighting（深度冲突）** —— 精度问题及解决方案（如Polygon Offset）
