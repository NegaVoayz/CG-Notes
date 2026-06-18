# Lecture 11 重点补遗（排除三份笔记后）

> 已排除：  
> - 《PBR学习笔记》（渲染方程/BRDF/微表面）  
> - 《Whitted论文笔记》（递归光线追踪/反射折射方向/Snell定律）  
> - 《全局光照.md》（Radiosity/Lightmap/Probes/SSGI/Lumen等工程分类）  
>
> 以下仅保留 **PPT + PDF 中未被上述笔记覆盖** 的核心内容，并展开数学推导。

---

## 一、渲染方程的完整数学结构（补充 PDF 未展开的细节）

渲染方程（Kajiya 1986）：

$$
L_o(p,\omega_o)=L_e(p,\omega_o)+\int_{\Omega^+} L_i(p,\omega_i)\, f_r(p,\omega_i,\omega_o)\, (n\cdot \omega_i)\, d\omega_i
$$

**PDF 中未强调的关键点**：

| 要点             | 说明                                                         |
| ---------------- | ------------------------------------------------------------ |
| **定义域**       | $\Omega^+$ 表示以法线 $n$ 为中心的**上半球**，不是整个球面   |
| **隐含约束**     | $L_i(p,\omega_i)$ 来自场景中其他点的出射辐射率，即 $L_i(p,\omega_i)=L_o(q,-\omega_i)$，其中 $q=\text{raycast}(p,\omega_i)$ |
| **积分算子形式** | 可写成 $\mathcal{L} = L_e + \mathcal{T}\mathcal{L}$，其中 $\mathcal{T}$ 是光传输算子，这是**Fredholm 积分方程第二类**，解为 Neumann 级数：$\mathcal{L} = \sum_{k=0}^{\infty} \mathcal{T}^k L_e$，每一项对应一条路径长度 $k$ |

> 这个级数展开就是**路径空间分解**的理论依据，PPT 中的路径类型 $L(S|D)^*E$ 正是对应不同 $k$ 和材质组合。

---

## 二、Monte Carlo 积分的严格数学定义（PDF 未展开）

PDF 给出了基本形式，但未强调以下数学要点。

### 2.1 无偏性与一致性

给定 $X_i \sim p(x)$，估计量：

$$
F_N = \frac{1}{N}\sum_{i=1}^{N} \frac{f(X_i)}{p(X_i)}
$$

- **无偏性**：$\mathbb{E}[F_N] = \int f(x) dx$（证明只需线性期望）
- **一致性**：$\lim_{N\to\infty} F_N = \int f(x) dx$（大数定律）
- **方差**：$\text{Var}(F_N) = \frac{1}{N}\text{Var}\left(\frac{f(X)}{p(X)}\right)$，**方差与 $p(x)$ 成反比** → 最优 $p \propto |f|$（重要性采样）

### 2.2 PDF 的归一化条件

PPT 中均匀采样半球时 $p(\omega_i)=1/2\pi$，其满足：

$$
\int_{\Omega^+} p(\omega_i)\, d\omega_i = \int_0^{2\pi}\int_0^{\pi/2} \frac{1}{2\pi} \sin\theta\, d\theta\, d\phi = 1
$$

PDF 中未明确写出 Jacobian $\sin\theta$ 的来源，此处补上。

---

## 三、光源采样（Sampling the Light）的完整数学推导

PDF p37-39 给出了公式，但推导过程略去，现补全。

### 3.1 立体角与面积微元的关系

从点 $x$ 看向光源面元 $dA$ 所张的立体角：

$$
d\omega_i = \frac{\cos\theta'}{\|x'-x\|^2} dA
$$

其中：
- $\theta'$ 是光源面元法线 $n'$ 与连线方向 $(x'-x)$ 的夹角（**注意不是 $x$ 处的法线夹角**）
- 推导：球面投影面积 = 投影面积 / 距离平方

### 3.2 重写渲染方程

原方程：

$$
L_o(x,\omega_o) = \int_{\Omega^+} L_i(x,\omega_i) f_r \cos\theta \, d\omega_i
$$

代入 $d\omega$ 得**面积积分形式**：

$$
L_o(x,\omega_o) = \int_A L_i(x,\omega_i) f_r \frac{\cos\theta \cos\theta'}{\|x'-x\|^2} dA
$$

其中 $\cos\theta = n\cdot \omega_i$（$x$ 处法线与入射方向夹角的余弦），$\cos\theta' = n'\cdot \frac{x-x'}{\|x-x'\|}$（光源法线与出射方向夹角的余弦）。

### 3.3 面积采样的 Monte Carlo 估计

若在光源表面上**均匀采样**，$p(x') = 1/A$，则：

$$
L_o(x,\omega_o) \approx \frac{A}{N}\sum_{k=1}^{N} L_i(x,\omega_i^k) f_r \frac{\cos\theta \cos\theta'}{\|x'-x\|^2}
$$

**PDF 中未明确的地方**：
- 这个形式**不需要除以 $p(\omega_i)$**，因为已经改变了积分变量
- 采样光源后，**仍需发射阴影光线**（shadow ray）检测 $x$ 与 $x'$ 之间是否被遮挡，否则 $L_i$ 应置为 0

---

## 四、Russian Roulette 的数学期望证明（PDF 略讲）

PDF p33 给出结论 $\mathbb{E}=Lo$，现补充完整推导。

设原始着色结果为 $Lo$，选择存活概率 $P\in(0,1)$，构造随机变量：

$$
Y = \begin{cases} Lo/P & \text{概率 } P \\ 0 & \text{概率 } 1-P \end{cases}
$$

其期望：

$$
\mathbb{E}[Y] = P \cdot \frac{Lo}{P} + (1-P)\cdot 0 = Lo
$$

**关键推论**：$Y$ 的方差为：

$$
\text{Var}(Y) = \mathbb{E}[Y^2] - (\mathbb{E}[Y])^2 = P\cdot \frac{Lo^2}{P^2} - Lo^2 = Lo^2\left(\frac{1}{P}-1\right)
$$

当 $P$ 越小（更容易终止），方差越大 → **RR 引入额外噪声**，但保证了路径有限终止且无偏。

---

## 五、路径积分形式（Path Integral Formulation）— PPT 隐含但未展开

PDF 中 shade 函数的递归形式可展开为**路径空间上的积分**：

对于一条长度为 $k$ 的路径 $\bar{x} = x_0 x_1 \cdots x_k$（$x_0$ 为相机，$x_k$ 为光源），其贡献为：

$$
I(\bar{x}) = L_e(x_k\to x_{k-1}) \prod_{i=1}^{k-1} f_r(x_{i+1}\to x_i \to x_{i-1}) \prod_{i=1}^{k-1} G(x_i \leftrightarrow x_{i+1})
$$

其中几何项 $G$ 定义为：

$$
G(x \leftrightarrow y) = \frac{\cos\theta_x \cos\theta_y}{\|x-y\|^2} V(x,y)
$$

$V(x,y)\in\{0,1\}$ 为可见性函数（阴影检测）。整个像素颜色为所有路径贡献的积分：

$$
\text{Pixel} = \sum_{k=1}^{\infty} \int_{\mathcal{P}_k} I(\bar{x}) \, d\mu(\bar{x})
$$

其中 $\mathcal{P}_k$ 是长度为 $k$ 的所有路径空间。这个形式是**双向路径追踪**和**Metropolis 光传输**的理论基础。

---

## 六、PDF 提到但未展开的数学工具

| 概念                                       | 数学含义                                                     | 在 Path Tracing 中的作用                                |
| ------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------- |
| **重要性采样（Importance Sampling）**      | 选择 $p(x) \propto |f(x)|$ 使方差最小                        | 不采样半球而是采样光源，就是重要性采样的一个特例        |
| **低差异序列（Low Discrepancy Sequence）** | 用确定性序列代替随机数，收敛速度 $O(\log N/N)$ 优于随机 $O(1/\sqrt{N})$ | 实际渲染器中用 Halton / Sobol 序列代替 rand()           |
| **多重重要性采样（MIS）**                  | 组合多个采样策略，权重 $w_i(x) \propto n_i p_i(x)$           | 同时采样半球和光源时，用 MIS 平衡两者贡献，避免极端权重 |

---

## 七、PDF 中未强调的效率量化分析

### 7.1 路径追踪的收敛率

- 误差（MSE）与样本数 $N$ 的关系：$\text{MSE} \propto 1/N$
- 要减半噪声，需要 **4 倍** 样本数
- 维度无关性：收敛率不随积分维度增加而恶化 → **Monte Carlo 在高维积分上优于数值积分**

### 7.2 光源采样 vs 半球采样的效率对比

设光源面积为 $A_s$，场景总表面积为 $A$，半球均匀采样击中光源的概率为：

$$
P_{\text{hit}} = \frac{1}{2\pi}\int_{\Omega_{\text{light}}} d\omega \approx \frac{A_s \cos\theta'}{2\pi r^2}
$$

当光源小或距离远时，$P_{\text{hit}}$ 极小，几乎所有光线都“浪费”了。光源采样将有效采样概率提升至 $1$（仅遮挡会失效），效率提高 $O(r^2/A_s)$ 倍。

---

## 八、课程中未涵盖但逻辑上延伸的重要结论

1. **Path Tracing 是“无偏的”**（无系统误差），但**不是“一致的”**（需要无限样本才能得到精确值）
2. **RR 使路径几乎肯定终止**：若每步存活概率 $P \in (0,1)$，路径长度 $K$ 服从几何分布，$\mathbb{P}(K>k)=P^k \to 0$，几乎必然有限
3. **直接光照 + 间接光照分离**是降低方差的通用技巧（PDF p40），即 **“直接照明显式采样，间接照明递归采样”**，称为 **“next event estimation”**

---

**一句话补遗**：  
本讲未被三份笔记覆盖的核心是 **Path Tracing 的完整数学框架** —— 包括渲染方程的积分算子和 Neumann 级数展开、Monte Carlo 积分的无偏性/方差分析、光源采样的面积变量替换与几何项推导、Russian Roulette 的期望和方差证明，以及收敛率与重要性采样的量化分析。这些构成了路径追踪的“理论基础层”，而三份笔记覆盖的是“工程实现层”和“历史发展层”。