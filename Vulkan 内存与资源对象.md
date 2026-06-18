# 📦 Vulkan 内存与资源对象全览

![image-20260618191730723](C:\MyNotes\CG\Vulkan Pipeline Diagram.png)

## 一、Buffer（线性缓冲区）
> **本质**：一段连续的、无格式的显存（类似 `malloc`）。存放“二进制数组”。

| 名称                     | 存储内容                                | 着色器访问方式     | 典型用途                         | 对应用法                  |
| :----------------------- | :-------------------------------------- | :----------------- | :------------------------------- | :------------------------ |
| **Vertex Buffer**        | 顶点属性数组（位置/法线/UV）            | 无（由IA读取）     | 定义几何体模板                   | `vkCmdBindVertexBuffers`  |
| **Index Buffer**         | 顶点索引数组                            | 无（由IA读取）     | 定义图元装配顺序                 | `vkCmdBindIndexBuffer`    |
| **Uniform Buffer**       | 小量结构化数据（MVP、光源参数）         | `uniform` 块       | 每帧/每组物体的常量数据          | `vkCmdBindDescriptorSets` |
| **Storage Buffer**       | 大量结构化数据（粒子、骨骼矩阵）        | `buffer` 块        | 可读写的海量数据                 | 同上                      |
| **Uniform Texel Buffer** | 格式化的一维纹素数组（只读）            | `samplerBuffer`    | 调色板、LUT、大量光照数据        | 同上                      |
| **Storage Texel Buffer** | 格式化的一维纹素数组（可读写）          | `imageBuffer`      | 计算着色器中的临时纹理数据       | 同上                      |
| **Indirect Buffer**      | 绘制命令参数（`VkDrawIndirectCommand`） | 无（由GPU读取）    | GPU驱动的绘制调用（无需CPU参与） | `vkCmdDrawIndirect`       |
| **Push Constant**        | 小量CPU实时参数（指令流中）             | `push_constant` 块 | 矩阵、时间、开关等极速更新数据   | `vkCmdPushConstants`      |

---

## 二、Image（图像缓冲区）
> **本质**：带格式的、支持多维寻址（2D/3D/Cube）的显存。存放“像素/纹素”。

| 名称                         | 存储内容                     | 着色器访问方式                         | 读写权限                | 硬件特性             | 典型用途                            |
| :--------------------------- | :--------------------------- | :------------------------------------- | :---------------------- | :------------------- | :---------------------------------- |
| **Sampled Image**            | 只读纹理贴图                 | `sampler2D` + `texture()`              | 只读                    | 支持滤波、Mipmap     | 漫反射贴图、法线贴图、环境贴图      |
| **Storage Image**            | 可读写纹理                   | `image2D` + `imageLoad()/imageStore()` | 可读写                  | 无滤波（精确访问）   | 后处理特效、计算着色器中间结果      |
| **Color Attachment**         | 渲染目标颜色缓冲             | `vkCmdBeginRenderPass` 时绑定          | 可读写（FS输出）        | 支持混合（Blending） | 最终帧缓冲、MRT（延迟渲染G-Buffer） |
| **Depth/Stencil Attachment** | 深度值和模板值               | 固定功能硬件控制                       | 可读写（硬件控制）      | 深度/模板测试        | Z-Buffer、Shadow Map、模板遮罩      |
| **Input Attachment**         | 前一个Subpass输出的颜色/深度 | `subpassInput`                         | 只读（同Render Pass内） | 无滤波（精确访问）   | 延迟渲染中G-Buffer的读取            |

---

## 三、Descriptor Set（描述符集）
> **本质**：GPU 的“虚拟地址表”，告诉硬件“这块显存是什么、怎么用”。它本身不存数据，只存指针和访问规则。

| 描述符类型                                | 绑定的资源           | 着色器可见性 |
| :---------------------------------------- | :------------------- | :----------- |
| `VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER`       | Uniform Buffer       | VS / FS / CS |
| `VK_DESCRIPTOR_TYPE_STORAGE_BUFFER`       | Storage Buffer       | VS / FS / CS |
| `VK_DESCRIPTOR_TYPE_UNIFORM_TEXEL_BUFFER` | Uniform Texel Buffer | VS / FS / CS |
| `VK_DESCRIPTOR_TYPE_STORAGE_TEXEL_BUFFER` | Storage Texel Buffer | VS / FS / CS |
| `VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE`        | Sampled Image        | FS / CS      |
| `VK_DESCRIPTOR_TYPE_STORAGE_IMAGE`        | Storage Image        | FS / CS      |
| `VK_DESCRIPTOR_TYPE_INPUT_ATTACHMENT`     | Input Attachment     | FS           |
| `VK_DESCRIPTOR_TYPE_SAMPLER`              | Sampler（采样器）    | FS           |

---

## 四、CUDA 类比速查表（快速上手指南）

| Vulkan 概念                  | CUDA 等价物                                    | 说明                                     |
| :--------------------------- | :--------------------------------------------- | :--------------------------------------- |
| **Vertex/Index Buffer**      | `cudaMalloc` 存储几何数据                      | IA通过固定功能读取，着色器不直接访问     |
| **Indirect Buffer**          | 存储 `cudaLaunchParams` 的显存                 | GPU自己决定画什么，CPU只发一个启动命令   |
| **Uniform Buffer**           | `cudaMalloc` + 只读指针                        | 小数据，绑定到 `__constant__` 内存更准确 |
| **Storage Buffer**           | `cudaMalloc` + 裸指针                          | 任意大小，可读写                         |
| **Sampled Image**            | `cudaTextureObject_t`                          | 只读纹理，带硬件滤波                     |
| **Storage Image**            | `cudaSurfaceObject_t` 或指针                   | 可读写纹理，无滤波                       |
| **Push Constants**           | Kernel 的直接参数                              | 极快，极小，内嵌指令流                   |
| **Color Attachment**         | `cudaMalloc` 存储渲染输出                      | 固定功能管线的最终输出目标               |
| **Depth/Stencil Attachment** | `cudaMalloc` 存储深度/模板值                   | 由固定功能硬件控制读写                   |
| **Input Attachment**         | 同Render Pass内的只读共享内存                  | Subpass间的零拷贝数据传输                |
| **Descriptor Sets**          | `cudaMalloc` 返回的指针集合                    | 其实就是GPU内存地址表                    |
| **Dynamic Offset**           | `cudaMalloc` 后通过 `基地址 + i * stride` 访问 | 连续存放N个结构体，用偏移量访问第i个     |

---

## 五、一句话总纲

> **Vertex/Index/Indirect Buffer** = CPU传过来的“原始二进制文件”（几何数据、绘制指令）。  
> **Uniform/Storage/Texel Buffer** = CPU传过来的“结构化数据表”（参数、粒子、LUT）。  
> **Sampled/Storage Image** = 纹理图片（只读/可读写）。  
> **Attachments** = 帧缓冲的组成部分（颜色、深度、模板、子通道数据）。  
> **Descriptor Sets** = 把这些所有资源绑定给着色器的“指针数组”。  
> **Push Constants** = 直接嵌入命令流的“临时便签”。
