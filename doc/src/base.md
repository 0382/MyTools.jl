# Base

基础工具。

## 向量

```@docs
Vec
```

- 定义了基本的向量加减法、数乘（除）
- 实现了`AbstractVector`的接口，引入`LinearAlgebra`即可进行内外积操作
- 对于维度小于等于4的向量，可以使用`.x, .y, .z, .w`索引取值（不可更改）

## 泡利矩阵代数

定义了常数`σ0, σx, σy, σz, σv`，分别表示单位矩阵、三个泡利矩阵、泡利矩阵向量。

```@docs
⊗(::AbstractVector, ::AbstractVector)
⊗(::AbstractMatrix, ::AbstractMatrix)
```

## 矩阵算法

实现了稠密对称矩阵的LDLT分解。