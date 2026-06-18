# OptiX -  A General Purpose Ray Tracing Engine

这篇文章是NVIDIA在SIGGRAPH 2010上发表的关于**OptiX通用光线追踪引擎**的经典论文。OptiX是首个广泛应用于GPU的、可编程的、生产级光线追踪系统。以下是对文章**重点内容**和**核心数学/算法原理**的系统整理。

---

## 一、文章核心重点

### 1. 设计目标
- **通用性**：不仅用于图形渲染（路径追踪、光子映射），还用于非图形领域（碰撞检测、声传播、AI查询）。
- **可编程性**：通过7种用户可定义的程序类型，实现多种光线追踪算法。
- **高性能**：针对GPU等并行架构优化，采用JIT编译、动态调度、SIMT友好控制流。
- **易用性**：提供单光线递归编程模型，隐藏底层并行和加速结构细节。

### 2. 可编程光线追踪管线（7种程序）
| 程序类型       | 功能                             |
| -------------- | -------------------------------- |
| Ray Generation | 入口，生成光线，启动追踪         |
| Intersection   | 计算光线与几何体的交点           |
| Bounding Box   | 为加速结构提供几何包围盒         |
| Closest Hit    | 最近交点处的着色                 |
| Any Hit        | 每个交点调用（用于阴影、透明等） |
| Miss           | 光线未命中时调用                 |
| Exception      | 异常处理（栈溢出、越界等）       |
| Selector Visit | 控制节点图遍历（LOD等）          |

### 3. 场景表示
- 使用**有向图（节点图）** 表示场景，支持：
  - **Group**：分组与加速结构
  - **Geometry Group**：几何体集合
  - **Transform**：变换矩阵
  - **Selector**：动态选择子节点
- 支持**实例化（Instancing）**，共享几何与加速结构，节省内存。

### 4. 对象与数据模型
- 采用**动态继承**的变量作用域（类似嵌套作用域）。
- 变量可附加到上下文、几何、材质、实例等对象，支持**覆盖（override）**。
- **attribute**变量用于从Intersection程序向Hit程序传递数据（类似OpenGL varying）。

### 5. 领域专用JIT编译
- 输入为**PTX（并行线程执行）** 代码（来自CUDA C++）。
- 执行**PTX→PTX转换**，实现：
  - 变量作用域解析
  - 内联内置操作（rtTrace、rtTerminateRay等）
  - **Continuation（延续）** 支持递归和函数调用
  - 控制流图简化（避免SIMD发散）
- 优化策略：
  - 删除未使用变量/代码
  - 将只读数据移至常量内存/纹理
  - 针对树结构特化遍历

### 6. 执行模型
- **Megakernel**：单一大内核，包含所有程序，减少启动开销。
- **细粒度调度**：显式控制SIMT单元执行同一状态，减少发散。
- **三级负载均衡**：CPU→多GPU→GPU内多执行单元。

### 7. 加速结构
- 支持多种BVH变体（SBVH、LBVH等）。
- 支持**重建（rebuild）** 与**重拟合（refit）**。
- 加速结构可附加到Group或Geometry Group，支持混合静态/动态几何。

### 8. 应用案例
- **Whitted风格光线追踪**（反射、折射、阴影）
- **Design Garage**（交互式路径追踪）
- **图像空间光子映射（ISPM）**
- **碰撞检测与视线分析**

### 9. 性能
- 相比手动优化的GPU光线追踪器，OptiX性能损失约**25–35%**（可接受）。
- Design Garage在GTX 480上达到交互帧率（>30fps）。
- ISPM相比四核CPU加速**2.5–3倍**。

---

## 二、数学原理与算法基础

### 1. 光线-几何求交（Intersection）
- 核心数学：求解射线方程 $ \mathbf{R}(t) = \mathbf{O} + t\mathbf{D} $ 与几何体（三角形、球体、平面等）的交点。
- 三角形求交常用**Möller–Trumbore算法**：
  $$
  \mathbf{O} + t\mathbf{D} = (1-u-v)\mathbf{V}_0 + u\mathbf{V}_1 + v\mathbf{V}_2
  $$
  解出 $ t, u, v $，判断是否在三角形内且 $ t > 0 $。

### 2. 包围盒（Bounding Box）
- 轴对齐包围盒（AABB）由最小/最大点定义。
- 光线与AABB相交测试使用** slabs测试**：
  $$
  t_{\min} = \max\left(\frac{x_{\min} - O_x}{D_x}, \frac{y_{\min} - O_y}{D_y}, \frac{z_{\min} - O_z}{D_z}\right)
  $$
  $$
  t_{\max} = \min\left(\frac{x_{\max} - O_x}{D_x}, \frac{y_{\max} - O_y}{D_y}, \frac{z_{\max} - O_z}{D_z}\right)
  $$
  有效交点条件：$ t_{\min} < t_{\max} $ 且 $ t_{\max} > 0 $。

### 3. 加速结构（BVH）
- **BVH** 构建：自底向上或自顶向下，将几何体按空间邻近性分组。
- **遍历**：递归检查光线是否与节点AABB相交，若相交则检查子节点。
- **SBVH（Spatial Splits BVH）** 引入空间切分，提高质量。
- **LBVH（Linear BVH）** 基于Morton码快速构建，适合动态场景。

### 4. 路径追踪（Design Garage）
- 渲染方程（Kajiya）：
  $$
  L_o(\mathbf{x}, \omega_o) = L_e(\mathbf{x}, \omega_o) + \int_{\Omega} f_r(\mathbf{x}, \omega_i, \omega_o) L_i(\mathbf{x}, \omega_i) (\omega_i \cdot \mathbf{n}) \, d\omega_i
  $$
- 蒙特卡洛估计：通过重要性采样近似积分。
- 迭代实现（非递归）以避免栈溢出：
  ```cpp
  for each bounce:
      sample BSDF → new ray
      throughput *= BSDF * cos / pdf
      if Russian Roulette: break
  ```

### 5. 光子映射（ISPM）
- 光子从光源发射，在场景中散射，存储光子图。
- 最终聚集：在图像空间对光子进行体积渲染。
- 数学上是对辐射照度的近似：
  $$
  E(\mathbf{x}) \approx \sum_{p=1}^{N} \Phi_p \, f_r(\mathbf{x}, \omega_p, \omega_o) / (\pi r^2)
  $$

### 6. 连续体（Continuation）与状态机
- 递归调用（如rtTrace）在GPU上不直接支持。
- OptiX将递归转换为**状态机**，保存活跃寄存器（live registers）作为**continuation**。
- 状态机通过**虚拟程序计数器（VPC）** 控制执行流，支持函数调用/返回。

### 7. SIMD/SIMT效率优化
- 使用**细粒度调度**：同一SIMT单元内尽量执行相同状态。
- 减少**控制流发散**（如将if-else拆分为多个状态）。
- 通过**静态优先级调度**减少状态切换次数。

---

## 三、总结

| 方面     | 技术/原理                                      |
| -------- | ---------------------------------------------- |
| 编程模型 | 单光线递归 + 7种可编程程序                     |
| 场景组织 | 有向图 + 动态继承变量                          |
| 编译策略 | PTX JIT + 领域专用优化 + 状态机转换            |
| 执行模型 | Megakernel + 细粒度调度 + 负载均衡             |
| 加速结构 | BVH（SBVH/LBVH）+ 重建/重拟合                  |
| 核心数学 | 光线求交、AABB测试、蒙特卡洛积分、光子密度估计 |
| 性能代价 | 灵活性损失25–35%峰值性能，但应用广泛           |

OptiX的设计思想深刻影响了后续光线追踪API（如DXR、Vulkan RT），是现代实时光线追踪系统的基石之一。