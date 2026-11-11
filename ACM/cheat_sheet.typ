#set page(
  paper: "a4",
  margin: (x: 1.2cm, top: 1.8cm, bottom: 1.8cm),
  header: align(right)[#text(8pt, fill: gray)[Cheat Sheet]],
  footer: context align(center)[
    #text(9pt)[ #counter(page).display("1")  / #counter(page).final().first()]
  ]
)

#set text(font: ("Noto Sans CJK SC", "JetBrains Mono"), size: 9pt)
#show raw: set text(font: ("JetBrains Mono", "Noto Sans Mono CJK SC"), size: 8pt)
#set par(justify: true, leading: 0.5em)

#show raw.where(block: true): block.with(
  fill: rgb("#f8f9fa"),
  inset: 6pt,
  radius: 3pt,
  stroke: 0.5pt + rgb("#e1e4e8"),
  width: 100%,
)

#align(center)[#text(16pt, weight: "bold")[TOC]]
#v(1em)
#outline(
  title: none,
  depth: 3,
  indent: auto
)

#pagebreak()

= 缺省源
```cpp
#include <bits/stdc++.h>
#define all(x) (x).begin(), (x).end()
#define rall(x) (x).rbegin(), (x).rend()
#define sz(x) static_cast<i32>((x).size())
#define rep(i, a, b) for (i32 i = (a); i < (b); ++i)
#define rep1(i, a, b) for (i32 i = (a); i <= (b); ++i)
#define loop while(true)

using namespace std;
using i32 = int32_t;
using i64 = int64_t;
using i128 = __int128_t;
using u128 = __uint128_t;
using u32 = uint32_t;
using u64 = uint64_t;
using f32 = float;
using f64 = double;
using f128 = long double;
```

= 基础算法
== 二分
统一采用闭区间 `[l, r]`：
- `bs_first`: 查找满足 `check(x)` 的*首个（最小）*位置（性质为 `000...111`，无解返回 -1）
- `bs_last`: 查找满足 `check(x)` 的*最后一个（最大）*位置（性质为 `111...000`，无解返回 -1）

```cpp
bool check(i32 mid);

// 闭区间 [l, r] 查找首个满足 check(x) 的最小位置 (无解返回 -1)
i32 bs_first(i32 l, i32 r) {
    i32 ans = -1;
    while (l <= r) {
        i32 mid = l + (r - l) / 2;
        if (check(mid)) {
            ans = mid;
            r = mid - 1;
        } else {
            l = mid + 1;
        }
    }
    return ans;
}

// 闭区间 [l, r] 查找最后一个满足 check(x) 的最大位置 (无解返回 -1)
i32 bs_last(i32 l, i32 r) {
    i32 ans = -1;
    while (l <= r) {
        i32 mid = l + (r - l) / 2;
        if (check(mid)) {
            ans = mid;
            l = mid + 1;
        } else {
            r = mid - 1;
        }
    }
    return ans;
}
```

`lower_bound` 与 `upper_bound` 用法：
```cpp
void example_bound() {
    vector<i32> vec = {1, 2, 4, 4, 4, 6, 8, 10};
    i32 target = 4;

    // lower_bound 第一个 >= 的元素下标 [0, sz(vec))
    i32 lower = lower_bound(all(vec), target) - vec.begin();

    // upper_bound 第一个 > 的元素下标 [0, sz(vec))
    i32 upper = upper_bound(all(vec), target) - vec.begin();
}
```

#table(
  columns: (auto, 1.2fr, 1fr, 1fr, 1fr),
  fill: (col, row) => if row == 0 { rgb("f0f2f5") } else { none },
  stroke: 0.5pt + luma(180),
  [*函数*], [*返回*], [*若值存在*], [*若值不存在*], [*典型应用*],
  [`lower_bound`], [第一个 $gt.eq "target"$ 的迭代器], [目标值的第一个位置], [第一个比它大的元素], [查找元素、插入位置],
  [`upper_bound`], [第一个 $> "target"$ 的迭代器], [跳过所有相同值的元素], [第一个比它大的元素], [计算元素出现次数],
  [`lower_bound - 1`], [最后一个 $< "target"$ 的迭代器], [目标值前一个元素], [最大的小于 $"target"$ 的元素], [反向查找小于目标值],
  [`upper_bound - 1`], [最后一个 $lt.eq "target"$ 的迭代器], [目标值最后一个位置], [最大的小于等于 $"target"$ 的元素], [反向查找小于等于目标值],
)

== 三分
适用于严格单峰（求极大值）或严格单谷（求极小值）函数。每次取区间内两个三等分点 $m_1, m_2$，比较其函数值以舍弃 $1/3$ 的无效区间。
- *浮点数三分*：
  - 建议优先采用*固定循环次数*（如 100 次迭代），区间缩小至原长 $(2/3)^100 approx 2.46 times 10^(-18)$，可彻底避免由于浮点精度极限引发的死循环或震荡；
  - 亦可采用 `r - l > eps` 终止条件（如 $"eps" = 10^(-9)$）。
- *整数三分*：
  - 整数除法由于下取整极易产生边界死循环，标准策略为：当 $r - l >= 3$ 时进行三分收缩，退出循环后在剩余的小区间 $[l, r]$（至多 3 个点）内直接暴力比较求解。
- *极大值与极小值收缩规则速查*：
  - *求极大值（单峰）*：若 $f(m_1) < f(m_2)$，则 $l = m_1$；否则 $r = m_2$。
  - *求极小值（单谷）*：若 $f(m_1) > f(m_2)$，则 $l = m_1$；否则 $r = m_2$。

```cpp
// 1. 浮点数三分 (以求极大值为例，求极小值只需调换比较方向)
f64 f(f64 x);

// 固定迭代次数 (推荐，100 次迭代精度极高且防死循环)
f64 ts_float_max(f64 l, f64 r, i32 iters = 100) {
    rep(iter, 0, iters) {
        f64 m1 = l + (r - l) / 3.0;
        f64 m2 = r - (r - l) / 3.0;
        if (f(m1) < f(m2)) {
            l = m1;
        } else {
            r = m2;
        }
    }
    return l;
}

// 精度收敛判定 (eps 视题目精度要求调整，如 1e-9)
f64 ts_float_max_eps(f64 l, f64 r, f64 eps = 1e-9) {
    while (r - l > eps) {
        f64 m1 = l + (r - l) / 3.0;
        f64 m2 = r - (r - l) / 3.0;
        if (f(m1) < f(m2)) {
            l = m1;
        } else {
            r = m2;
        }
    }
    return l;
}

// 2. 整数三分 (以求极大值为例；小区间暴力判定防整除死循环)
i64 f_int(i64 x);

i64 ts_int_max(i64 l, i64 r) {
    while (r - l >= 3) {
        i64 m1 = l + (r - l) / 3;
        i64 m2 = r - (r - l) / 3;
        if (f_int(m1) < f_int(m2)) {
            l = m1;
        } else {
            r = m2;
        }
    }
    i64 best_x = l;
    i64 best_val = f_int(l);
    rep1(i, l + 1, r) {
        i64 cur = f_int(i);
        if (cur > best_val) {
            best_val = cur;
            best_x = i;
        }
    }
    return best_x;
}
```

== 高精度
```cpp
// 继承 vector<i32> 的十进制高精，好背好写，省去压位切片与格式化补零
struct BigInt : vector<i32> {
    BigInt(i64 v = 0) {
        if (!v) push_back(0);
        for (; v; v /= 10) push_back(v % 10);
    }
    BigInt(const string& s) {
        for (i32 i = sz(s) - 1; i >= 0; --i) push_back(s[i] - '0');
    }
    void trim() { while (sz(*this) > 1 && !back()) pop_back(); }

    bool operator==(const BigInt& b) const = default;
    bool operator<(const BigInt& b) const {
        if (sz(*this) != sz(b)) return sz(*this) < sz(b);
        for (i32 i = sz(*this) - 1; i >= 0; --i)
            if ((*this)[i] != b[i]) return (*this)[i] < b[i];
        return false;
    }
    BigInt operator+(const BigInt& b) const {
        BigInt c; c.clear(); i32 t = 0;
        for (i32 i = 0; i < sz(*this) || i < sz(b) || t; ++i) {
            if (i < sz(*this)) t += (*this)[i];
            if (i < sz(b)) t += b[i];
            c.push_back(t % 10); t /= 10;
        }
        return c;
    }
    BigInt operator-(const BigInt& b) const { // 默认 *this >= b
        BigInt c = *this;
        rep(i, 0, sz(c)) {
            if (i < sz(b)) c[i] -= b[i];
            if (c[i] < 0) { c[i] += 10; c[i + 1]--; }
        }
        c.trim(); return c;
    }
    BigInt operator*(const BigInt& b) const {
        BigInt c; c.assign(sz(*this) + sz(b), 0);
        rep(i, 0, sz(*this)) rep(j, 0, sz(b)) c[i + j] += (*this)[i] * b[j];
        rep(i, 0, sz(c) - 1) {
            c[i + 1] += c[i] / 10; c[i] %= 10;
        }
        c.trim(); return c;
    }
    pair<BigInt, i64> divmod(i64 v) const {
        BigInt c; c.clear(); i64 r = 0;
        for (i32 i = sz(*this) - 1; i >= 0; --i) {
            r = r * 10 + (*this)[i];
            c.push_back(r / v); r %= v;
        }
        reverse(all(c));
        c.trim(); return {c, r};
    }
    BigInt operator/(i64 v) const { return divmod(v).first; }
    i64 operator%(i64 v) const { return divmod(v).second; }

    friend istream& operator>>(istream& is, BigInt& a) { string s; if (is >> s) a = s; return is; }
    friend ostream& operator<<(ostream& os, const BigInt& a) {
        for (i32 i = sz(a) - 1; i >= 0; --i) os << a[i];
        return os;
    }
};
```

== 网络流
使用静态链式前向星数组，包含 Dinic 最大流与基于势能 Dijkstra 的最小费用最大流（MCMF），节点均为 0-based。
```cpp
constexpr i32 maxn = 5005, m = 100005;
constexpr i64 inf = numeric_limits<i64>::max() / 2;
i32 head[maxn], nxt[m * 2], to[m * 2], cur[maxn], dep[maxn], tot = 1, pre[maxn];
i64 cap[m * 2], cost[m * 2], dis[maxn], h[maxn];

void init_flow(i32 num_nodes) {
    fill(head, head + num_nodes, 0);
    tot = 1;
}

void add_edge(i32 u, i32 v, i64 c, i64 w = 0) {
    nxt[++tot] = head[u]; to[tot] = v; cap[tot] = c; cost[tot] = w; head[u] = tot;
    nxt[++tot] = head[v]; to[tot] = u; cap[tot] = 0; cost[tot] = -w; head[v] = tot;
}

// ----------------- Dinic 最大流 -----------------
bool dinic_bfs(i32 s, i32 t, i32 num_nodes) {
    fill(dep, dep + num_nodes, -1);
    queue<i32> q; dep[s] = 0; q.push(s);
    while (!q.empty()) {
        i32 u = q.front(); q.pop();
        for (i32 i = head[u]; i; i = nxt[i]) {
            i32 v = to[i];
            if (cap[i] > 0 && dep[v] == -1) {
                dep[v] = dep[u] + 1;
                q.push(v);
            }
        }
    }
    return dep[t] != -1;
}

i64 dinic_dfs(i32 u, i32 t, i64 flow) {
    if (u == t || !flow) return flow;
    i64 res = 0;
    for (i32& i = cur[u]; i; i = nxt[i]) {
        i32 v = to[i];
        if (cap[i] > 0 && dep[v] == dep[u] + 1) {
            i64 tr = dinic_dfs(v, t, min(flow, cap[i]));
            if (tr > 0) {
                cap[i] -= tr; cap[i ^ 1] += tr;
                res += tr; flow -= tr;
                if (!flow) break;
            }
        }
    }
    return res;
}

i64 dinic(i32 s, i32 t, i32 num_nodes) {
    i64 max_flow = 0;
    while (dinic_bfs(s, t, num_nodes)) {
        rep(i, 0, num_nodes) cur[i] = head[i];
        while (i64 f = dinic_dfs(s, t, inf)) max_flow += f;
    }
    return max_flow;
}

// ------------- Primal-Dual 最小费用最大流 -------------
bool mcmf_dijkstra(i32 s, i32 t, i32 num_nodes) {
    fill(dis, dis + num_nodes, inf);
    priority_queue<pair<i64, i32>, vector<pair<i64, i32>>, greater<>> pq;
    dis[s] = 0; pq.push({0, s});
    while (!pq.empty()) {
        auto [d, u] = pq.top(); pq.pop();
        if (d > dis[u]) continue;
        for (i32 i = head[u]; i; i = nxt[i]) {
            i32 v = to[i];
            if (cap[i] > 0 && dis[v] > d + h[u] - h[v] + cost[i]) {
                dis[v] = d + h[u] - h[v] + cost[i];
                pre[v] = i;
                pq.push({dis[v], v});
            }
        }
    }
    return dis[t] != inf;
}

pair<i64, i64> mcmf(i32 s, i32 t, i32 num_nodes) {
    i64 flow = 0, min_cost = 0;
    fill(h, h + num_nodes, 0);
    while (mcmf_dijkstra(s, t, num_nodes)) {
        rep(i, 0, num_nodes) h[i] += dis[i];
        i64 aug = inf;
        for (i32 v = t; v != s; v = to[pre[v] ^ 1]) aug = min(aug, cap[pre[v]]);
        for (i32 v = t; v != s; v = to[pre[v] ^ 1]) {
            cap[pre[v]] -= aug;
            cap[pre[v] ^ 1] += aug;
        }
        flow += aug;
        min_cost += aug * h[t];
    }
    return {flow, min_cost};
}
```

= 数据结构
== 树状数组
使用*群论 / 阿贝尔群（Abelian Group）代数架构*高度抽象，采用*结构体（struct）*紧凑风格封装，下标统一采用 *1-based*（$1 <= p <= n$），区间查询统一为闭区间 $[l, r]$。

=== 1. 代数接口说明
- *群元素类型 $S$*
- *可交换可结合二元运算 `op(const S&, const S&)`*：满足 $(a dot b) dot c = a dot (b dot c)$ 与 $a dot b = b dot a$。
- *单位元 `e()`*：满足 $a dot e = a$。
- *群逆元 `inv(const S&)`*：满足 $a dot a^(-1) = e$。当需要区间查询 $[l, r]$ 时，通过差分运算 $P(r) dot "inv"(P(l-1))$ 求解（如加法群的相反数 $-x$、异或群的自身 $x$）。若仅需前缀查询则无需逆元。

=== 2. 核心模板实现
```cpp
// 树状数组 (Fenwick Tree，阿贝尔群代数抽象，1-based)
template <typename S,
          S (*op)(const S&, const S&),
          S (*e)(),
          S (*inv)(const S&) = nullptr,
          i32 maxn = 200005>
struct Fenwick {
    i32 n = 0;
    S tr[maxn];

    void init(i32 _n, const S& val = e()) {
        n = _n;
        fill(tr, tr + n + 1, val);
    }

    Fenwick() = default;
    Fenwick(i32 _n) { init(_n); }

    // 1-based: 单点添加 v (tr[p] = tr[p] * v)
    void add(i32 p, const S& v) {
        for (i32 i = p; i <= n; i += i & -i) tr[i] = op(tr[i], v);
    }

    // 1-based: 查询前缀积/和 [1, p]
    S query(i32 p) const {
        S ans = e();
        for (i32 i = min(p, n); i > 0; i -= i & -i) ans = op(ans, tr[i]);
        return ans;
    }

    // 1-based: 查询区间积/和 [l, r] (需提供群逆元 inv)
    S range_query(i32 l, i32 r) const {
        if (l > r) return e();
        if constexpr (inv != nullptr) {
            return op(query(r), inv(query(l - 1)));
        }
        return e();
    }

    // O(N) 线性建树 (输入 vector 为 0-based，依次填入 1-based 树中)
    void build(const vector<S>& a) {
        n = sz(a);
        rep1(i, 1, n) tr[i] = a[i - 1];
        rep1(i, 1, n) {
            i32 j = i + (i & -i);
            if (j <= n) tr[j] = op(tr[j], tr[i]);
        }
    }

    // 倍增查找最大满足 query(p) <= k 的 1-based 位置 p (要求有序且单调非递减)
    i32 select(const S& k) const {
        if (n <= 0) return 0;
        i32 p = 0; S cur = e();
        for (i32 i = 1 << __lg(n); i; i >>= 1) {
            if (p + i <= n) {
                S nxt = op(cur, tr[p + i]);
                if (nxt <= k) { p += i; cur = nxt; }
            }
        }
        return p;
    }
};

// 预设场景一：标准整数加法群
namespace FenwickAdd {
    using S = i64;
    S op(const S& a, const S& b) { return a + b; }
    S e() { return 0; }
    S inv(const S& a) { return -a; }
    using Tree = Fenwick<S, op, e, inv>;
}

// 预设场景二：按位异或交换群 (逆元为自身)
namespace FenwickXor {
    using S = i64;
    S op(const S& a, const S& b) { return a ^ b; }
    S e() { return 0; }
    S inv(const S& a) { return a; }
    using Tree = Fenwick<S, op, e, inv>;
}
```

== 线段树
使用*群论 / Monoid Action 架构（幺半群及群作用）*高度抽象，改用*结构体（struct）*紧凑风格封装，代数接口与修改值统一采用*常引用传参（`const S&` / `const F&`）*避免拷贝，区间操作统一闭区间 `[l, r]`（静态线段树默认 1-based）。

=== 1. 核心模板实现
```cpp
// 动态开点 Lazy 线段树 (Monoid Action, struct 紧凑风格, 闭区间 [l, r], 引用传参)
template <typename S, S (*op)(const S&, const S&), S (*e)(),
          typename F, S (*mapping)(const F&, const S&, i64), F (*composition)(const F&, const F&), F (*identity_f)(),
          S (*init_func)(i64, i64) = [](i64, i64) { return e(); }>
struct DynamicLazySegTree {
    struct Node {
        S val;
        F lz;
        i32 ls = -1, rs = -1;
    };
    i64 l_bound, r_bound;
    i32 root = -1;
    vector<Node> pool;

    i32 create(i64 l, i64 r) {
        pool.push_back({init_func(l, r), identity_f(), -1, -1});
        return sz(pool) - 1;
    }
    void apply_node(i32 u, const F& f, i64 len) {
        pool[u].val = mapping(f, pool[u].val, len);
        pool[u].lz = composition(f, pool[u].lz);
    }
    void push(i32 u, i64 l, i64 r) {
        if (pool[u].lz == identity_f()) return;
        i64 mid = l + (r - l) / 2;
        if (pool[u].ls == -1) pool[u].ls = create(l, mid);
        if (pool[u].rs == -1) pool[u].rs = create(mid + 1, r);
        apply_node(pool[u].ls, pool[u].lz, mid - l + 1);
        apply_node(pool[u].rs, pool[u].lz, r - mid);
        pool[u].lz = identity_f();
    }
    void pull(i32 u, i64 l, i64 r) {
        i64 mid = l + (r - l) / 2;
        S lv = (pool[u].ls != -1) ? pool[pool[u].ls].val : init_func(l, mid);
        S rv = (pool[u].rs != -1) ? pool[pool[u].rs].val : init_func(mid + 1, r);
        pool[u].val = op(lv, rv);
    }
    void apply(i32 u, i64 l, i64 r, i64 ql, i64 qr, const F& f) {
        if (ql <= l && r <= qr) { apply_node(u, f, r - l + 1); return; }
        push(u, l, r);
        i64 mid = l + (r - l) / 2;
        if (ql <= mid) {
            if (pool[u].ls == -1) pool[u].ls = create(l, mid);
            apply(pool[u].ls, l, mid, ql, qr, f);
        }
        if (qr > mid) {
            if (pool[u].rs == -1) pool[u].rs = create(mid + 1, r);
            apply(pool[u].rs, mid + 1, r, ql, qr, f);
        }
        pull(u, l, r);
    }
    S query(i32 u, i64 l, i64 r, i64 ql, i64 qr) {
        if (u == -1) return init_func(max(l, ql), min(r, qr));
        if (ql <= l && r <= qr) return pool[u].val;
        push(u, l, r);
        i64 mid = l + (r - l) / 2;
        S res = e();
        if (ql <= mid) res = op(res, query(pool[u].ls, l, mid, ql, qr));
        if (qr > mid) res = op(res, query(pool[u].rs, mid + 1, r, ql, qr));
        return res;
    }
    DynamicLazySegTree(i64 l, i64 r, i32 reserve_sz = 100000) : l_bound(l), r_bound(r) {
        pool.reserve(reserve_sz);
        root = create(l_bound, r_bound);
    }
    void range_apply(i64 l, i64 r, const F& f) { if (l <= r) apply(root, l_bound, r_bound, l, r, f); }
    S range_query(i64 l, i64 r) { return l <= r ? query(root, l_bound, r_bound, l, r) : e(); }
};

// 静态全局数组 Lazy 线段树 (Monoid Action, struct 紧凑风格, 闭区间 [l, r], 1-based, 引用传参)
template <typename S, S (*op)(const S&, const S&), S (*e)(),
          typename F, S (*mapping)(const F&, const S&, i64), F (*composition)(const F&, const F&), F (*identity_f)(),
          i32 maxn = 200005>
struct StaticLazySegTree {
    struct Node {
        S val;
        F lz;
    };
    i32 n = 0;
    Node tr[4 * maxn];

    void apply_node(i32 u, const F& f, i64 len) {
        tr[u].val = mapping(f, tr[u].val, len);
        tr[u].lz = composition(f, tr[u].lz);
    }
    void push(i32 u, i64 l, i64 r) {
        if (tr[u].lz == identity_f()) return;
        i64 mid = l + (r - l) / 2;
        apply_node(u << 1, tr[u].lz, mid - l + 1);
        apply_node(u << 1 | 1, tr[u].lz, r - mid);
        tr[u].lz = identity_f();
    }
    void pull(i32 u) {
        tr[u].val = op(tr[u << 1].val, tr[u << 1 | 1].val);
    }
    void build(const vector<S>& a, i32 u, i64 l, i64 r) {
        tr[u].lz = identity_f();
        if (l == r) { tr[u].val = (l <= sz(a) ? a[l - 1] : e()); return; }
        i64 mid = l + (r - l) / 2;
        build(a, u << 1, l, mid);
        build(a, u << 1 | 1, mid + 1, r);
        pull(u);
    }
    void init(i32 _n, const S& val = e()) {
        n = _n;
        fill(tr, tr + 4 * (n + 1), Node{val, identity_f()});
    }
    void init(const vector<S>& a) {
        n = sz(a);
        if (n > 0) build(a, 1, 1, n);
    }
    StaticLazySegTree() = default;
    StaticLazySegTree(i32 _n, const S& val = e()) { init(_n, val); }
    StaticLazySegTree(const vector<S>& a) { init(a); }

    void apply(i32 u, i64 l, i64 r, i64 ql, i64 qr, const F& f) {
        if (ql <= l && r <= qr) { apply_node(u, f, r - l + 1); return; }
        push(u, l, r);
        i64 mid = l + (r - l) / 2;
        if (ql <= mid) apply(u << 1, l, mid, ql, qr, f);
        if (qr > mid) apply(u << 1 | 1, mid + 1, r, ql, qr, f);
        pull(u);
    }
    void range_apply(i64 l, i64 r, const F& f) {
        if (l <= r && l >= 1 && r <= n) apply(1, 1, n, l, r, f);
    }
    S query(i32 u, i64 l, i64 r, i64 ql, i64 qr) {
        if (ql <= l && r <= qr) return tr[u].val;
        push(u, l, r);
        i64 mid = l + (r - l) / 2;
        S res = e();
        if (ql <= mid) res = op(res, query(u << 1, l, mid, ql, qr));
        if (qr > mid) res = op(res, query(u << 1 | 1, mid + 1, r, ql, qr));
        return res;
    }
    S range_query(i64 l, i64 r) {
        return (l <= r && l >= 1 && r <= n) ? query(1, 1, n, l, r) : e();
    }
    void set(i32 u, i64 l, i64 r, i64 p, const S& val) {
        if (l == r) { tr[u] = {val, identity_f()}; return; }
        push(u, l, r);
        i64 mid = l + (r - l) / 2;
        if (p <= mid) set(u << 1, l, mid, p, val);
        else set(u << 1 | 1, mid + 1, r, p, val);
        pull(u);
    }
    void set(i64 p, const S& val) {
        if (p >= 1 && p <= n) set(1, 1, n, p, val);
    }
    void debug() const {
        auto print_node = [&](auto& self, i32 u, i64 l, i64 r, string prefix, bool is_last) -> void {
            cout << prefix << (is_last ? "└── " : "├── ") << "[" << l << ", " << r << "]\n";
            if (l == r) return;
            i64 mid = l + (r - l) / 2;
            self(self, u << 1, l, mid, prefix + (is_last ? "    " : "│   "), false);
            self(self, u << 1 | 1, mid + 1, r, prefix + (is_last ? "    " : "│   "), true);
        };
        cout << "\n========== Segment Tree Debug ==========\n";
        print_node(print_node, 1, 1, n, "", true);
        cout << "========================================\n\n";
    }
};
```

=== 2. 代数接口定义说明

抽象线段树将业务逻辑全盘交给以下 *5 个代数接口* 决定（幺半群作用系统，统一使用常引用避免拷贝）：

#table(
  columns: (auto, auto, 1fr),
  fill: (col, row) => if row == 0 { rgb("f0f2f5") } else { none },
  stroke: 0.5pt + luma(180),
  [*接口名称*], [*函数签名*], [*群论含义与代数性质*],
  [`op`], [`S(const S& a, const S& b)`], [数据幺半群的二元运算，需满足*结合律*：`op(op(a, b), c) == op(a, op(b, c))`。],
  [`e`], [`S()`], [数据幺半群的*单位元*。需满足对任意 `x` 有 `op(x, e()) == op(e(), x) == x`。],
  [`mapping`], [`S(const F& tag, const S& val, i64 len)`], [群作用 $dot: F times S -> S$。将变换 `tag` 作用于区间长度为 `len` 的节点值 `val` 上。],
  [`composition`], [`F(const F& new_tag, const F& old_tag)`], [作用幺半群的复合运算，对应映射复合 $(f compose g)(x) = f(g(x))$。],
  [`identity_f`], [`F()`], [作用幺半群的*恒等变换（单位元）*。满足对任意 `f` 有 `composition(f, id) == composition(id, f) == f`。],
)

=== 3. 常见场景配置与示例

==== 场景一：区间加法 + 区间求和
- *映射规则*：区间和增加 `tag * len`
- *标记复合*：累加 `new_tag + old_tag`

```cpp
namespace RangeAddSum {
    using S = i64;
    using F = i64;

    S op(const S& a, const S& b) { return a + b; }
    S e() { return 0; }
    S mapping(const F& tag, const S& val, i64 len) { return val + tag * len; }
    F composition(const F& new_tag, const F& old_tag) { return new_tag + old_tag; }
    F identity_f() { return 0; }

    using DynamicSeg = DynamicLazySegTree<S, op, e, F, mapping, composition, identity_f>;
    using StaticSeg = StaticLazySegTree<S, op, e, F, mapping, composition, identity_f>;
    using Tree = DynamicSeg;
}

void test_range_add_sum() {
    // 维护闭区间坐标 [1, 1000000000]
    RangeAddSum::DynamicSeg seg(1, 1000000000);

    seg.range_apply(100, 199, 5); // [100, 199] 全 +5 (共 100 个元素) -> 500
    seg.range_apply(150, 249, 3); // [150, 249] 全 +3

    // [100, 149] 各 +5 (50 个点) -> 250
    // [150, 199] 各 +8 (50 个点) -> 400
    // 预期结果: 650
    cout << "Sum [100, 199]: " << seg.range_query(100, 199) << "\n";
}
```

==== 场景二：区间加法 + 区间最大值
- *映射规则*：区间最大值增加 `tag`（与区间长度无关）
- *单位元*：极小值作为幺半群零元

```cpp
namespace RangeAddMax {
    using S = i64;
    using F = i64;

    S op(const S& a, const S& b) { return max(a, b); }
    S e() { return numeric_limits<i64>::min() / 2; }
    S mapping(const F& tag, const S& val, i64 len) { return val + tag; }
    F composition(const F& new_tag, const F& old_tag) { return new_tag + old_tag; }
    F identity_f() { return 0; }

    using DynamicSeg = DynamicLazySegTree<S, op, e, F, mapping, composition, identity_f>;
    using StaticSeg = StaticLazySegTree<S, op, e, F, mapping, composition, identity_f>;
    using Tree = DynamicSeg;
}

void test_range_add_max() {
    RangeAddMax::DynamicSeg seg(1, 1000000000);

    seg.range_apply(10, 50, 100); // [10, 50] 全 +100
    seg.range_apply(30, 80, 50);  // [30, 80] 全 +50

    // [30, 50] 处的最大值为 150
    cout << "Max [1, 100]: " << seg.range_query(1, 100) << "\n"; // 输出 150
}
```

==== 场景三：区间赋值 + 区间最小值
- *映射规则*：覆盖为 `tag`
- *标记复合*：新标记直接覆盖旧标记

```cpp
namespace RangeSetMin {
    using S = i64;
    using F = i64;
    constexpr F nop = numeric_limits<i64>::max();

    S op(const S& a, const S& b) { return min(a, b); }
    S e() { return numeric_limits<i64>::max() / 2; }
    S mapping(const F& tag, const S& val, i64 len) { return (tag == nop) ? val : tag; }
    F composition(const F& new_tag, const F& old_tag) { return (new_tag == nop) ? old_tag : new_tag; }
    F identity_f() { return nop; }

    using DynamicSeg = DynamicLazySegTree<S, op, e, F, mapping, composition, identity_f>;
    using StaticSeg = StaticLazySegTree<S, op, e, F, mapping, composition, identity_f>;
    using Tree = DynamicSeg;
}

void test_range_set_min() {
    RangeSetMin::DynamicSeg seg(1, 1000000000);

    seg.range_apply(10, 100, 42); // [10, 100] 全部赋值为 42
    seg.range_apply(50, 70, 15);  // [50, 70] 全部赋值为 15

    cout << "Min [1, 100]: " << seg.range_query(1, 100) << "\n"; // 输出 15
    cout << "Min [10, 49]: " << seg.range_query(10, 49) << "\n"; // 输出 42
}
```

==== 场景四：复合操作（区间乘法 & 区间加法 + 区间求和）
需要同时维护乘法 $a$ 和加法 $b$（仿射变换群 $x |-> a dot x + b$），带取模。
- *标记结构*：结构体 `{mul, add}`
- *标记复合*：若先后作用 $(a_1, b_1)$ 和 $(a_2, b_2)$，新值为 $a_2(a_1 x + b_1) + b_2 = (a_2 a_1) x + (a_2 b_1 + b_2)$

```cpp
namespace RangeAffineSum {
    constexpr i64 mod = 1e9 + 7;

    struct Tag {
        i64 mul, add;
        bool operator==(const Tag& o) const { return mul == o.mul && add == o.add; }
    };

    using S = i64;
    using F = Tag;

    S op(const S& a, const S& b) { return (a + b) % mod; }
    S e() { return 0; }

    S mapping(const F& tag, const S& val, i64 len) {
        return (val * tag.mul % mod + tag.add * (len % mod) % mod) % mod;
    }

    F composition(const F& new_tag, const F& old_tag) {
        return Tag{
            (new_tag.mul * old_tag.mul) % mod,
            (new_tag.mul * old_tag.add + new_tag.add) % mod
        };
    }

    F identity_f() { return Tag{1, 0}; }

    using DynamicSeg = DynamicLazySegTree<S, op, e, F, mapping, composition, identity_f>;
    using StaticSeg = StaticLazySegTree<S, op, e, F, mapping, composition, identity_f>;
    using Tree = DynamicSeg;
}

void test_range_affine() {
    RangeAffineSum::DynamicSeg seg(1, 100000);

    // [1, 10] 全部先 +3
    seg.range_apply(1, 10, {1, 3});
    // [1, 10] 全部 *2
    seg.range_apply(1, 10, {2, 0});

    // 10 个元素和为 60
    cout << "Sum [1, 10]: " << seg.range_query(1, 10) << "\n"; // 输出 60
}
```

== 静态线段树
```cpp
struct {
    i64 sum=0,lz=0;
} tr[maxn*4];
void pull(i32 u) {
    tr[u].sum=tr[u<<1].sum+tr[u<<1|1].sum;
}
void apply(i32 u,i32 l,i32 r,i64 v) {
    tr[u].sum+=v*(r-l+1);
    tr[u].lz+=v;
}
void push(i32 u,i32 l,i32 r) {
    if (l==r||!tr[u].lz) return;
    i32 mid=l+(r-l)/2;
    apply(u<<1,l,mid,tr[u].lz);
    apply(u<<1|1,mid+1,r,tr[u].lz);
    tr[u].lz=0;
}
void build(i32 u,i32 l,i32 r,const i64 a[]) {
    if (l==r) {
        tr[u].sum=a[l];
        return;
    }
    i32 mid=l+(r-l)/2;
    build(u<<1,l,mid,a);
    build(u<<1|1,mid+1,r,a);
    pull(u);
}
void update(i32 u,i32 l,i32 r,i32 ql,i32 qr,i64 v) {
    if (ql<=l&&r<=qr) {
        apply(u,l,r,v);
        return;
    }
    push(u,l,r);
    i32 mid=l+(r-l)/2;
    if (ql<=mid) update(u<<1,l,mid,ql,qr,v);
    if (qr>mid) update(u<<1|1,mid+1,r,ql,qr,v);
    pull(u);
}
i64 query(i32 u,i32 l,i32 r,i32 ql,i32 qr) {
    if (ql<=l&&r<=qr) return tr[u].sum;
    push(u,l,r);
    i32 mid=l+(r-l)/2;
    i64 res=0;
    if (ql<=mid) res+=query(u<<1,l,mid,ql,qr);
    if (qr>mid) res+=query(u<<1|1,mid+1,r,ql,qr);
    return res;
}
```

== 动态开点线段树
```cpp
struct {
    i32 ls=0,rs=0;
    i64 sum=0;
} tr[maxn*64];
i64 lz[maxn*64];
i32 tot=0;
i32 create() {
    ++tot;
    tr[tot]={0,0,0};
    lz[tot]=0;
    return tot;
}
void pull(i32 u) {
    tr[u].sum=tr[tr[u].ls].sum+tr[tr[u].rs].sum;
}
void apply(i32 &u,i64 l,i64 r,i64 v) {
    if (!u) u=create();
    tr[u].sum+=v*(r-l+1);
    lz[u]+=v;
}
void push(i32 u,i64 l,i64 r) {
    if (!lz[u]||l==r) return;
    i64 mid=l+(r-l)/2;
    apply(tr[u].ls,l,mid,lz[u]);
    apply(tr[u].rs,mid+1,r,lz[u]);
    lz[u]=0;
}
void update(i32 &u,i64 l,i64 r,i64 ql,i64 qr,i64 v) {
    if (!u) u=create();
    if (ql<=l&&r<=qr) {
        apply(u,l,r,v);
        return;
    }
    push(u,l,r);
    i64 mid=l+(r-l)/2;
    if (ql<=mid) update(tr[u].ls,l,mid,ql,qr,v);
    if (qr>mid) update(tr[u].rs,mid+1,r,ql,qr,v);
    pull(u);
}
i64 query(i32 u,i64 l,i64 r,i64 ql,i64 qr) {
    if (!u) return u;
    if (ql<=l&&r<=qr) return tr[u].sum;
    push(u,l,r);
    i64 mid=l+(r-l)/2;
    i64 res=0;
    if (ql<=mid) res+=query(tr[u].ls,l,mid,ql,qr);
    if (qr>mid) res+=query(tr[u].rs,mid+1,r,ql,qr);
    return res;
}
```
=== 线段树合并
适用于单点修改，无懒标记
```cpp
i32 merge(i32 u,i32 v,i64 l,i64 r) {
    if (!u||!v) return u|v;
    if (l==r) {
        tr[u].sum=tr[u].sum+tr[v].sum;
        return u;
    }
    i64 mid=l+(r-l)/2;
    tr[u].ls=merge(tr[u].ls,tr[v].ls,l,mid);
    tr[u].rs=merge(tr[u].rs,tr[v].rs,mid+1,r);
    pull(u);
    return u;
}
```

=== 4. 调试函数
```cpp
// 静态线段树调试打印 (亦可直接调用 seg.debug())
template <typename S, S (*op)(const S&, const S&), S (*e)(), typename F, S (*mapping)(const F&, const S&, i64), F (*composition)(const F&, const F&), F (*identity_f)(), i32 maxn>
void debug_static_tree(const StaticLazySegTree<S, op, e, F, mapping, composition, identity_f, maxn>& seg, i64 n) {
    seg.debug();
}
```

== 并查集
静态全局数组，1-based（默认兼容 0 ~ n）：
```cpp
constexpr i32 maxn = 200005;
i32 fa[maxn], sz[maxn], cnt;

void init(i32 n = maxn - 1) {
    rep1(i, 0, n) fa[i] = i, sz[i] = 1;
    cnt = n;
}

i32 find(i32 x) {
    return fa[x] == x ? x : fa[x] = find(fa[x]);
}

bool same(i32 x, i32 y) {
    return find(x) == find(y);
}

bool merge(i32 x, i32 y) {
    x = find(x), y = find(y);
    if (x == y) return false;
    if (sz[x] < sz[y]) swap(x, y);
    fa[y] = x;
    sz[x] += sz[y];
    --cnt;
    return true;
}
```

== 主席树
```cpp
struct {
    i32 ls=0,rs=0;
    i64 cnt=0;
} tr[maxn*64];
i32 tot=0,rt[maxn];
i32 clone(i32 p) {
    tr[++tot]=tr[p];
    return tot;
}
void pull(i32 u) {
    tr[u].cnt=tr[tr[u].ls].cnt+tr[tr[u].rs].cnt;
}
i32 update(i32 prev,i64 l,i64 r,i64 p,i64 v) {
    i32 u=clone(prev);
    if (l==r) {
        tr[u].cnt+=v;
        return u;
    }
    i64 mid=l+(r-l)/2;
    if (p<=mid) tr[u].ls=update(tr[prev].ls,l,mid,p,v);
    else tr[u].rs=update(tr[prev].rs,mid+1,r,p,v);
    pull(u);
    return u;
}
i64 kth(i32 u,i32 v,i64 l,i64 r,i64 k) {
    if (l==r) return l;
    i64 left=tr[tr[v].ls].cnt-tr[tr[u].ls].cnt;
    i64 mid=l+(r-l)/2;
    if (k<=left) return kth(tr[u].ls,tr[v].ls,l,mid,k);
    return kth(tr[u].rs,tr[v].rs,mid+1,r,k-left);
}
```
== 树状数组套权值线段树
```cpp
#include <bits/stdc++.h>
using namespace std;
using i32=int;
using i64=long long;
constexpr i32 maxn=1e5+5;
constexpr i32 logn=40;
struct {
    i32 ls=0,rs=0;
    i64 cnt=0;
} tr[maxn*400];
i32 tot=0,n,rt[maxn];
void pull(i32 u) {
    tr[u].cnt=tr[tr[u].ls].cnt+tr[tr[u].rs].cnt;
}
void update(i32 &u,i64 l,i64 r,i64 p,i64 v) {
    if (!u) u=++tot;
    if (l==r) {
        tr[u].cnt+=v;
        return;
    }
    i64 mid=l+(r-l)/2;
    if (p<=mid) update(tr[u].ls,l,mid,p,v);
    else update(tr[u].rs,mid+1,r,p,v);
    pull(u);
}
void add(i32 u,i64 p,i64 v) {
    for (i32 i=u;i<=n;i+=i&-i) update(rt[i],1,n,p,v);
}
i32 uc[logn],vc[logn],usiz,vsiz;
void fill(i32 u,i32 v) {
    usiz=vsiz=0;
    for (i32 i=u;i>=1;i-=i&-i) uc[usiz++]=rt[i];
    for (i32 i=v;i>=1;i-=i&-i) vc[vsiz++]=rt[i];
}
i64 kth(i64 l,i64 r,i64 k) {
    if (l==r) return l;
    i64 mid=l+(r-l)/2;
    i64 left=0;
    for (i32 i=0;i<vsiz;i++) left+=tr[tr[vc[i]].ls].cnt;
    for (i32 i=0;i<usiz;i++) left-=tr[tr[uc[i]].ls].cnt;
    if (k<=left) {
        for (i32 i=0;i<usiz;i++) uc[i]=tr[uc[i]].ls;
        for (i32 i=0;i<vsiz;i++) vc[i]=tr[vc[i]].ls;
        return kth(l,mid,k);
    }
    for (i32 i=0;i<usiz;i++) uc[i]=tr[uc[i]].rs;
    for (i32 i=0;i<vsiz;i++) vc[i]=tr[vc[i]].rs;
    return kth(mid+1,r,k-left);
}
```

== FHQ Treap
```cpp
#include <bits/stdc++.h>
using namespace std;
using i32=int;
using u32=unsigned int;
using i64=long long;
using u64=unsigned long long;
constexpr i32 maxn=1e5+5;
constexpr i32 logn=40;
mt19937 rnd(1096);
struct {
    u64 pri=0;
    i32 ls=0,rs=0,val=0,siz=0;
} tr[maxn];
i32 tot=0,rt=0;
i32 create(i32 v) {
    ++tot;
    tr[tot]={rnd(),0,0,v,1,};
    return tot;
}
void pull(i32 u) {
    tr[u].siz=tr[tr[u].ls].siz+tr[tr[u].rs].siz+1;
}
void split(i32 u,i32 k,i32 &x,i32 &y) {
    if (!u) { x=y=0; return; }
    if (tr[u].val<=k) {
        x=u;
        split(tr[u].rs,k,tr[x].rs,y);
    } else {
        y=u;
        split(tr[u].ls,k,x,tr[y].ls);
    }
    pull(u);
}
i32 merge(i32 x,i32 y) {
    if (!x||!y) return x|y;
    if (tr[x].pri<tr[y].pri) {
        tr[x].rs=merge(tr[x].rs,y);
        pull(x);
        return x;
    }
    tr[y].ls=merge(x,tr[y].ls);
    pull(y);
    return y;
}
void insert(i32 v) {
    i32 x=0,y=0;
    split(rt,v,x,y);
    rt=merge(merge(x,create(v)),y);
}
void erase(i32 v) {
    i32 x=0,y=0,z=0;
    split(rt,v-1,x,y);
    split(y,v,y,z);
    y=merge(tr[y].ls,tr[y].rs);
    rt=merge(merge(x,y),z);
}
i32 rnk(i32 v) {
    i32 x=0,y=0;
    split(rt,v-1,x,y);
    i32 res=tr[x].siz+1;
    rt=merge(x,y);
    return res;
}
i32 kth(i32 u,i32 k) {
    while (u) {
        if (tr[tr[u].ls].siz+1==k) return tr[u].val;
        if (tr[tr[u].ls].siz>=k) {
            u=tr[u].ls;
        } else {
            k-=tr[tr[u].ls].siz+1;
            u=tr[u].rs;
        }
    }
    return -1;
}
i32 kth(i32 k) {
    return kth(rt,k);
}
i32 pre(i32 v) {
    i32 x=0,y=0;
    split(rt,v-1,x,y);
    i32 res=kth(x,tr[x].siz);
    rt=merge(x,y);
    return res;
}
i32 nxt(i32 v) {
    i32 x=0,y=0;
    split(rt,v,x,y);
    i32 res=kth(y,1);
    rt=merge(x,y);
    return res;
}
```
== Splay
```cpp
constexpr i64 inf = numeric_limits<i64>::max() / 2;
struct {
    i32 ch[2]{};
    i32 fa=0;
    i64 val=0,cnt=0,siz=0;
} tr[maxn];
i32 tot=0,rt=0;
void pull(i32 u) {
    tr[u].siz=tr[tr[u].ch[0]].siz+tr[tr[u].ch[1]].siz+tr[u].cnt;
}
bool isr(i32 u) {
    return tr[tr[u].fa].ch[1]==u;
}
void rotate(i32 x) {
    i32 y=tr[x].fa,z=tr[y].fa,k=isr(x);
    tr[y].ch[k]=tr[x].ch[k^1];
    if (tr[x].ch[k^1]) tr[tr[x].ch[k^1]].fa=y;
    tr[x].ch[k^1]=y;
    tr[y].fa=x;
    tr[x].fa=z;
    if (z) tr[z].ch[tr[z].ch[1]==y]=x;
    pull(y);
    pull(x);
}
void splay(i32 x,i32 g=0) {
    while (tr[x].fa!=g) {
        i32 y=tr[x].fa,z=tr[y].fa;
        if (z!=g) rotate(isr(x)==isr(y)?y:x);
        rotate(x);
    }
    if (g==0) rt=x;
}
void insert(i64 v) {
    i32 u=rt,p=0;
    while (u&&tr[u].val!=v) {
        p=u;
        u=tr[u].ch[v>tr[u].val];
    }
    if (u) {
        tr[u].cnt++;
        pull(u);
    } else {
        u=++tot;
        if (p) tr[p].ch[v>tr[p].val]=u;
        tr[u]={{0,0},p,v,1,1};
    }
    splay(u);
}
void find(i64 v) {
    i32 u=rt;
    if (!u) return;
    while (tr[u].ch[v>tr[u].val]&&tr[u].val!=v) {
        u=tr[u].ch[v>tr[u].val];
    }
    splay(u);
}
i32 pre_node(i64 v) {
    find(v);
    if (tr[rt].val<v) return rt;
    i32 u=tr[rt].ch[0];
    while (tr[u].ch[1]) u=tr[u].ch[1];
    return u;
}
i32 nxt_node(i64 v) {
    find(v);
    if (tr[rt].val>v) return rt;
    i32 u=tr[rt].ch[1];
    while (tr[u].ch[0]) u=tr[u].ch[0];
    return u;
}
void erase(i64 v) {
    i32 p=pre_node(v),s=nxt_node(v);
    splay(p);
    splay(s,p);
    i32 u=tr[s].ch[0];
    if (tr[u].cnt>1) {
        tr[u].cnt--;
        splay(u);
    } else {
        tr[s].ch[0]=0;
        pull(s);
        pull(p);
    }
}
i32 rnk(i64 v) {
    find(v);
    if (tr[rt].val<v) return tr[tr[rt].ch[0]].siz+tr[rt].cnt;
    return tr[tr[rt].ch[0]].siz;
}
i64 kth(i64 k) {
    i32 u=rt;
    k++;
    while (true) {
        i32 ls=tr[u].ch[0];
        if (ls&&k<=tr[ls].siz) {
            u=ls;
        } else {
            k-=tr[ls].siz+tr[u].cnt;
            if (k<=0) {
                splay(u);
                return tr[u].val;
            }
            u=tr[u].ch[1];
        }
    }
}
i64 pre(i64 v) {
    return tr[pre_node(v)].val;
}
i64 nxt(i64 v) {
    return tr[nxt_node(v)].val;
}
void init() {
    insert(-inf);
    insert(inf);
}
```

== 分块
```cpp
i32 a[maxn];
i32 L[maxn],R[maxn],bid[maxn],B;
void build(i32 n){
    B=max(1,static_cast<i32>(sqrt(n)));
    rep1(i,1,(n+B-1)/B){
        L[i]=(i-1)*B+1;
        R[i]=min(n,i*B);
        rep1(j,L[i],R[i]) bid[j]=i;
    }
}
void block_upd(i32 bid,i32 v);
i32 block_qry(i32 bid);
void point_upd(i32 idx,i32 v);
i32 point_qry(i32 idx);
void update(i32 l,i32 r,i32 v){
    i32 p=bid[l],q=bid[r];
    if(p==q){
        rep1(i,l,r) point_upd(i,v);
        return;
    }
    rep1(i,l,R[p]) point_upd(i,v);
    rep1(b,p+1,q-1) block_upd(b,v);
    rep1(i,L[q],r) point_upd(i,v);
}
i32 query(i32 l,i32 r){
    i32 p=bid[l],q=bid[r];
    i32 res=0;
    if(p==q){
        rep1(i,l,r) res=res+point_qry(i);
        return res;
    }
    rep1(i,l,R[p]) res=res+point_qry(i);
    rep1(b,p+1,q-1) res=res+block_qry(b);
    rep1(i,L[q],r) res=res+point_qry(i);
    return res;
}
```

== 普通莫队
理论最优块长 $max(1, floor(frac(n, sqrt(q))))$
```cpp
struct Query{
    i32 l,r,id,b;
    bool operator<(const Query& o) const {
        if(b!=o.b) return b<o.b;
        return (b&1)?(r<o.r):(r>o.r);
    }
} qry[maxn];
i32 a[maxn],cnt[maxn],ans[maxn],cur=0,B;
void add(i32 v){
    cur+=(cnt[v]++==0);
}
void del(i32 v){
    cur-=(--cnt[v]==0);
}
signed main(){
    i32 n,m;
    cin>>n>>m;
    B=max(1,static_cast<i32>(n/max(1.0,sqrt(m*2.0/3.0))));
    // read data
    rep1(i,1,m) {
        cin>>qry[i].l>>qry[i].r;
        qry[i].id=i;
        qry[i].b=qry[i].l/B;
    }
    sort(qry+1,qry+1+m);
    i32 l=1,r=0;
    rep1(i,1,m){
        while(l>qry[i].l) add(a[--l]);
        while(r<qry[i].r) add(a[++r]);
        while(l<qry[i].l) del(a[l++]);
        while(r>qry[i].r) del(a[r--]);
        ans[qry[i].id]=cur;
    }
}
```

== 带修莫队
理论最优块长 $sqrt(frac(2n^2t, m))$

t 为修改次数，m 为查询次数

实践中推荐 $n^(2/3)$
```cpp
struct Query{
    i32 l,r,t,id;
    i32 bl,br;
    bool operator<(const Query& o) const {
        if(bl!=o.bl) return bl<o.bl;
        if(br!=o.br) return (bl&1)?(br<o.br):(br>o.br);
        return ((bl^br)&1)?(t<o.t):(t>o.t);
    }
} qry[maxn];
struct Modify{
    i32 pos,val;
} mod[maxn];
i32 a[maxn],cnt[maxn];
i32 ans[maxn],cur,B;
void add(i32 v){
    cur+=(cnt[v]++==0);
}
void del(i32 v){
    cur-=(--cnt[v]==0);
}
void apply_time(i32 tid,i32 l,i32 r){
    i32 p=mod[tid].pos;
    if(l<=p&&p<=r){
        del(a[p]);
        add(mod[tid].val);
    }
    swap(a[p],mod[tid].val);
}
signed main(){
    i32 n,m;
    cin>>n>>m;
    i32 qc=0,mc=0;
    rep1(i,1,m){
        char op;
        cin>>op;
        if(op=='Q'){
            qc++;
            cin>>qry[qc].l>>qry[qc].r;
            qry[qc].t=mc;
            qry[qc].id=qc;
        }else{
            mc++;
            cin>>mod[mc].pos>>mod[mc].val;
        }
    }
    //recommand
    B = max(1, static_cast<i32>(pow(n, 2.0 / 3.0)));
    // B = max(1, static_cast<i32>(pow(1.0 * n * n * max(1, mc) / max(1, qc), 1.0 / 3.0)));
    rep1(i,1,qc){
        qry[i].bl=qry[i].l/B;
        qry[i].br=qry[i].r/B;
    }
    sort(qry+1,qry+1+qc);
    i32 l=1,r=0,now=0;
    rep1(i,1,qc){
        while(l>qry[i].l) add(a[--l]);
        while(r<qry[i].r) add(a[++r]);
        while(l<qry[i].l) del(a[l++]);
        while(r>qry[i].r) del(a[r--]);

        while(now<qry[i].t) apply_time(++now,l,r);
        while(now>qry[i].t) apply_time(now--,l,r);

        ans[qry[i].id]=cur;
    }
}
```

== 分数类
极简手写分数类，利用 `i128` 构造化简与跨乘比较，省去繁冗重载并防止中间溢出：
```cpp
struct Frac {
    i64 num, den;
    Frac(i128 n = 0, i128 d = 1) {
        if (d < 0) n = -n, d = -d;
        i128 g = std::gcd(n, d);
        num = n / g; den = d / g;
    }
    Frac operator+(Frac o) const { return {(i128)num * o.den + (i128)o.num * den, (i128)den * o.den}; }
    Frac operator-(Frac o) const { return {(i128)num * o.den - (i128)o.num * den, (i128)den * o.den}; }
    Frac operator*(Frac o) const { return {(i128)num * o.num, (i128)den * o.den}; }
    Frac operator/(Frac o) const { return {(i128)num * o.den, (i128)den * o.num}; }
    Frac operator-() const { return {-num, den}; }
    bool operator<(Frac o) const { return (i128)num * o.den < (i128)o.num * den; }
    bool operator==(Frac o) const { return num == o.num && den == o.den; }
    friend ostream& operator<<(ostream& os, Frac f) {
        return f.den == 1 ? os << f.num : os << f.num << "/" << f.den;
    }
};
```

= DP
静态全局数组，0-based：

== 01背包
```cpp
constexpr i32 v = 100005;
i64 dp[v];

void knapsack01(i32 n, i32 cap, const i32 w[], const i64 val[]) {
    fill(dp, dp + cap + 1, 0);
    rep(i, 0, n) {
        for (i32 j = cap; j >= w[i]; --j)
            dp[j] = max(dp[j], dp[j - w[i]] + val[i]);
    }
}
```

== 完全背包
```cpp
constexpr i32 v = 100005;
i64 dp[v];

void knapsack_complete(i32 n, i32 cap, const i32 w[], const i64 val[]) {
    fill(dp, dp + cap + 1, 0);
    rep(i, 0, n) {
        rep1(j, w[i], cap)
            dp[j] = max(dp[j], dp[j - w[i]] + val[i]);
    }
}
```

== 多重背包
二进制拆分转化为 0-1 背包：
```cpp
constexpr i32 v = 100005;
i64 dp[v];

void knapsack_bounded(i32 n, i32 cap, const i32 w[], const i64 val[], const i32 c[]) {
    fill(dp, dp + cap + 1, 0);
    rep(i, 0, n) {
        i32 num = c[i];
        for (i32 k = 1; k <= num; k <<= 1) {
            i32 nw = k * w[i]; i64 nv = k * val[i];
            for (i32 j = cap; j >= nw; --j) dp[j] = max(dp[j], dp[j - nw] + nv);
            num -= k;
        }
        if (num > 0) {
            i32 nw = num * w[i]; i64 nv = num * val[i];
            for (i32 j = cap; j >= nw; --j) dp[j] = max(dp[j], dp[j - nw] + nv);
        }
    }
}
```

== 分组背包（每组物品最多选 1 个）
```cpp
constexpr i32 v = 100005;
i64 dp[v];
struct Item { i32 w; i64 v; };

void knapsack_group(i32 group_cnt, i32 cap, const vector<Item> groups[]) {
    fill(dp, dp + cap + 1, 0);
    rep(i, 0, group_cnt) {
        for (i32 j = cap; j >= 0; --j) {
            rep(k, 0, sz(groups[i])) {
                const auto& item = groups[i][k];
                if (j >= item.w) dp[j] = max(dp[j], dp[j - item.w] + item.v);
            }
        }
    }
}
```

== 二维费用背包
```cpp
constexpr i32 v1 = 1005, v2 = 1005;
i64 dp2d[v1][v2];

void knapsack2d(i32 n, i32 cap1, i32 cap2, const i32 w1[], const i32 w2[], const i64 val[]) {
    rep1(i, 0, cap1) fill(dp2d[i], dp2d[i] + cap2 + 1, 0);
    rep(i, 0, n) {
        for (i32 j = cap1; j >= w1[i]; --j) {
            for (i32 k = cap2; k >= w2[i]; --k) {
                dp2d[j][k] = max(dp2d[j][k], dp2d[j - w1[i]][k - w2[i]] + val[i]);
            }
        }
    }
}
```

== 树形/有依赖的背包
```cpp
constexpr i32 maxn = 1005, v = 1005;
i64 dp_tree[maxn][v];
vector<i32> g[maxn];

// 1-based，以 u 为根选择容量 j 的最大价值
void tree_knapsack_dfs(i32 u, i32 cap, const i32 w[], const i64 val[]) {
    fill(dp_tree[u], dp_tree[u] + cap + 1, 0);
    rep1(j, w[u], cap) dp_tree[u][j] = val[u];
    for (i32 child : g[u]) {
        tree_knapsack_dfs(child, cap, w, val);
        for (i32 j = cap; j >= w[u]; --j) {
            rep1(k, 0, j - w[u]) {
                dp_tree[u][j] = max(dp_tree[u][j], dp_tree[u][j - k] + dp_tree[child][k]);
            }
        }
    }
}
```

= 字符串
== KMP
前缀函数 `nxt` 静态数组，0-based：
```cpp
constexpr i32 maxn = 1000005;
i32 nxt[maxn];

void build_next(const string& p) {
    i32 m = sz(p);
    nxt[0] = 0;
    rep(i, 1, m) {
        i32 j = nxt[i - 1];
        while (j > 0 && p[i] != p[j]) j = nxt[j - 1];
        if (p[i] == p[j]) ++j;
        nxt[i] = j;
    }
}

// 返回匹配的左闭右开区间起始下标 [l, r) (0-based)
vector<i32> kmp(const string& s, const string& p) {
    build_next(p);
    vector<i32> matches;
    i32 m = sz(p), j = 0;
    rep(i, 0, sz(s)) {
        while (j > 0 && s[i] != p[j]) j = nxt[j - 1];
        if (s[i] == p[j]) ++j;
        if (j == m) {
            matches.push_back(i - m + 1);
            j = nxt[j - 1];
        }
    }
    return matches;
}
```

== KMP 自动机
将模式串 $p$ 构建为确定性有限状态自动机 (DFA)。状态 $u in [0, m]$ 表示当前已匹配的前缀长度。
- *核心优势*：消除暴力回跳的 `while` 循环，将单步字符转移复杂度由均摊 $O(1)$ 变为严格 $O(1)$。
- *常见应用*：数位 DP、矩阵快速幂 DP（如求解长度为 $L$ 且包含/不包含特定模式串的合法字符串数量）。

```cpp
constexpr i32 maxn = 1000005;
constexpr i32 alphabet_size = 26;
i32 nxt[maxn];
// trans[u][c] 表示在匹配长度为 u 时追加字符 ('a' + c) 后转移到的最长匹配前缀状态
i32 trans[maxn][alphabet_size];

void build_kmp_automaton(const string& p) {
    i32 m = sz(p);
    nxt[0] = 0;
    rep(i, 1, m) {
        i32 j = nxt[i - 1];
        while (j > 0 && p[i] != p[j]) j = nxt[j - 1];
        if (p[i] == p[j]) ++j;
        nxt[i] = j;
    }

    rep(c, 0, alphabet_size) {
        trans[0][c] = (p[0] - 'a' == c ? 1 : 0);
    }
    rep1(u, 1, m) {
        rep(c, 0, alphabet_size) {
            if (u < m && p[u] - 'a' == c) {
                trans[u][c] = u + 1;
            } else {
                trans[u][c] = trans[nxt[u - 1]][c];
            }
        }
    }
}
```

== Border Tree (失配树)
前缀 $i$（1-based，长度为 $i$）的最长真 border 长度为 $"nxt"[i]$。失配树以 0 为根，对每个 $1 <= i <= n$ 连边 $"nxt"[i] -> i$。
- *核心性质*：
  1. 前缀 $u$ 的所有 border 长度恰好对应失配树上 $u$ 到根节点 0 的路径祖先。
  2. 前缀 $u$ 和前缀 $v$ 的最长公共 border 对应失配树上的最近公共祖先 $"LCA"(u, v)$。
  3. 前缀 $v$ 是前缀 $u$ 的 border $<=> v$ 是 $u$ 的祖先（即 $u$ 在 $v$ 的子树中）。DFS 序将子树拍平后可用树状数组/线段树高效统计。
- *时间复杂度*：建树 $O(n)$，倍增求最长公共 border $O(log n)$。

```cpp
constexpr i32 maxn = 1000005;
constexpr i32 max_log = 21;

struct BorderTree {
    i32 n;
    i32 nxt[maxn];
    vector<i32> adj[maxn];
    i32 up[maxn][max_log];
    i32 depth[maxn];
    i32 tin[maxn], tout[maxn], timer;

    void clear(i32 len) {
        n = len;
        timer = 0;
        rep1(i, 0, n) {
            adj[i].clear();
            nxt[i] = depth[i] = 0;
            rep(k, 0, max_log) up[i][k] = 0;
        }
    }

    // 字符串采用 1-based，下标 1 ~ n
    void build(const string& s) {
        n = sz(s);
        clear(n);

        nxt[1] = 0;
        rep1(i, 2, n) {
            i32 j = nxt[i - 1];
            while (j > 0 && s[i - 1] != s[j]) j = nxt[j];
            if (s[i - 1] == s[j]) ++j;
            nxt[i] = j;
        }

        rep1(i, 1, n) {
            adj[nxt[i]].push_back(i);
        }

        auto dfs = [&](auto self, i32 u, i32 p) -> void {
            tin[u] = ++timer;
            up[u][0] = p;
            rep(k, 1, max_log) {
                up[u][k] = up[up[u][k - 1]][k - 1];
            }
            for (i32 v : adj[u]) {
                depth[v] = depth[u] + 1;
                self(self, v, u);
            }
            tout[u] = timer;
        };

        depth[0] = 0;
        dfs(dfs, 0, 0);
    }

    i32 lca(i32 u, i32 v) const {
        if (depth[u] < depth[v]) swap(u, v);
        for (i32 k = max_log - 1; k >= 0; --k) {
            if (depth[u] - (1 << k) >= depth[v]) {
                u = up[u][k];
            }
        }
        if (u == v) return u;
        for (i32 k = max_log - 1; k >= 0; --k) {
            if (up[u][k] != up[v][k]) {
                u = up[u][k];
                v = up[v][k];
            }
        }
        return up[u][0];
    }

    // 查询前缀 u 和前缀 v 的最长公共真 border (若 u == v，不能是其自身)
    i32 query_common_border(i32 u, i32 v) const {
        if (u == v) return nxt[u];
        return lca(u, v);
    }
};
```

== 扩展 KMP (Z 函数 / EXKMP)
求解字符串自身的各后缀与原串的最长公共前缀（Z 函数），以及模式串与文本串各后缀的最长公共前缀（EXKMP），下标统一 0-based。
- *数组定义*：
  - `z[i]`：$s[i dots n - 1]$ 与原串 $s$ 的 LCP 长度，即 $z[i] = "LCP"(s, s[i dots n - 1])$（通常规定 $z[0] = n$）。
  - `ext[i]`：文本串后缀 $s[i dots n - 1]$ 与模式串 $p$ 的 LCP 长度，即 $"ext"[i] = "LCP"(p, s[i dots n - 1])$。
- *核心思想*：
  维护已知匹配中右端点最靠右的匹配区间 $[l, r]$（满足 $s[l dots r] = s[0 dots r - l]$ 且 $r$ 最大）。
  - 若 $i <= r$，由对称性可知 $s[i dots r]$ 对应前缀子串 $s[i - l dots r - l]$，继承初始长度 $min(r - i + 1, z[i - l])$；若超出 $r$ 则继续向后暴力比对并更新 $[l, r]$。
  - 若 $i > r$，直接从 $i$ 开始向后比对并更新 $[l, r]$。
  - 模式匹配计算 $"ext"$ 数组逻辑完全一致，利用模式串预处理的 $z$ 数组跳跃比对。
- *经典应用*：
  1. *模式串匹配*：$"ext"[i] == m <=> s[i dots i + m - 1] == p$（模式串 $p$ 长度为 $m$）。
  2. *Border 判定*：$s$ 存在长度为 $k$ 的 border $<=> z[n - k] == k$。
  3. *周期与循环节*：若 $k divides n$ 且 $z[k] == n - k$，则 $k$ 为 $s$ 的周期；最小周期为满足条件的最小 $k$。
  4. *串拼接技巧*：构造 $p + \# + s$（$\#$ 不属于字符集），直接对其求 Z 函数，后半部分即对应各位置匹配长度。
- *时间与空间复杂度*：右端点 $r$ 严格单调不减，均摊时间复杂度为严格 $O(n + m)$，空间复杂度 $O(n + m)$。

```cpp
// 1. 静态数组版本 (经典 EXKMP，适用于海量数据与多组匹配)
constexpr i32 maxn = 1000005;
i32 z[maxn];
i32 ext[maxn];

// 计算自身 Z 函数: z[i] = LCP(s, s[i...n-1])，其中 z[0] = n
void build_z(const string& s) {
    i32 n = sz(s);
    if (n == 0) return;
    z[0] = n;
    i32 l = 0, r = -1;
    rep(i, 1, n) {
        if (i <= r) z[i] = min(r - i + 1, z[i - l]);
        else z[i] = 0;
        while (i + z[i] < n && s[z[i]] == s[i + z[i]]) ++z[i];
        if (i + z[i] - 1 > r) {
            l = i;
            r = i + z[i] - 1;
        }
    }
}

// 扩展 KMP: 计算 ext[i] = LCP(p, s[i...n-1])，返回完全匹配的起始下标 (0-based)
vector<i32> exkmp(const string& s, const string& p) {
    build_z(p);
    i32 n = sz(s), m = sz(p);
    vector<i32> matches;
    if (n == 0 || m == 0) return matches;
    i32 l = 0, r = -1;
    rep(i, 0, n) {
        if (i <= r) ext[i] = min(r - i + 1, z[i - l]);
        else ext[i] = 0;
        while (i + ext[i] < n && ext[i] < m && s[i + ext[i]] == p[ext[i]]) ++ext[i];
        if (i + ext[i] - 1 > r) {
            l = i;
            r = i + ext[i] - 1;
        }
        if (ext[i] == m) matches.push_back(i);
    }
    return matches;
}

// 2. 动态 vector 紧凑写法 (单串 Z 函数开箱即用)
vector<i32> z_func(const string& s) {
    i32 n = sz(s);
    vector<i32> zf(n);
    if (n == 0) return zf;
    zf[0] = n;
    i32 l = 0, r = -1;
    rep(i, 1, n) {
        if (i <= r) zf[i] = min(r - i + 1, zf[i - l]);
        while (i + zf[i] < n && s[zf[i]] == s[i + zf[i]]) ++zf[i];
        if (i + zf[i] - 1 > r) {
            l = i;
            r = i + zf[i] - 1;
        }
    }
    return zf;
}
```

== Manacher
最长回文子串，返回左闭右开区间 `[start, end)`：
```cpp
constexpr i32 maxn = 2000005;
i32 p[maxn];
char t[maxn];

pair<i32, i32> manacher(const string& s) {
    i32 m = 0;
    t[m++] = '$'; t[m++] = '#';
    rep(i, 0, sz(s)) { t[m++] = s[i]; t[m++] = '#'; }
    t[m++] = '^'; t[m] = '\0';

    i32 c = 0, r = 0, max_len = 0, start = 0;
    rep(i, 1, m - 1) {
        p[i] = (r > i) ? min(r - i, p[2 * c - i]) : 1;
        while (t[i + p[i]] == t[i - p[i]]) ++p[i];
        if (i + p[i] > r) { c = i; r = i + p[i]; }
        if (p[i] - 1 > max_len) {
            max_len = p[i] - 1;
            start = (i - p[i]) / 2;
        }
    }
    return {start, start + max_len};
}
```

== 字典树 (Trie & 01-Trie)
包含两种核心变体：
- *字符串 Trie*：用于前缀检索，统计完整串出现次数 `count` 与前缀出现次数 `count_prefix`。
- *01-Trie*：按二进制位（高位到低位）存储整数，贪心走相反位实现 $O(log V)$ 求解全局/区间最大异或对，支持动态插入与删除。

```cpp
// 1. 字符串字典树 (String Trie)
constexpr i32 trie_max_nodes = 500005;
struct Trie {
    i32 ch[trie_max_nodes][26];
    i32 cnt[trie_max_nodes];  // 以此节点结尾的字符串数
    i32 pass[trie_max_nodes]; // 经过此节点的前缀数
    i32 tot = 0;

    void clear() {
        rep1(i, 0, tot) {
            memset(ch[i], 0, sizeof(ch[i]));
            cnt[i] = pass[i] = 0;
        }
        tot = 0;
    }

    void insert(const string& s) {
        i32 u = 0;
        for (char c : s) {
            i32 idx = c - 'a';
            if (!ch[u][idx]) ch[u][idx] = ++tot;
            u = ch[u][idx];
            ++pass[u];
        }
        ++cnt[u];
    }

    i32 count(const string& s) const {
        i32 u = 0;
        for (char c : s) {
            i32 idx = c - 'a';
            if (!ch[u][idx]) return 0;
            u = ch[u][idx];
        }
        return cnt[u];
    }

    i32 count_prefix(const string& s) const {
        i32 u = 0;
        for (char c : s) {
            i32 idx = c - 'a';
            if (!ch[u][idx]) return 0;
            u = ch[u][idx];
        }
        return pass[u];
    }
};

// 2. 01 字典树 (01-Trie，异或最值 / 贪心匹配)
constexpr i32 trie01_max_nodes = 32 * 200005;
struct Trie01 {
    i32 ch[trie01_max_nodes][2];
    i32 cnt[trie01_max_nodes]; // 经过该节点的数字个数 (支持动态删除)
    i32 tot = 0;

    void clear() {
        rep1(i, 0, tot) {
            ch[i][0] = ch[i][1] = cnt[i] = 0;
        }
        tot = 0;
    }

    void insert(u32 x) {
        i32 u = 0;
        for (i32 i = 30; i >= 0; --i) {
            i32 bit = (x >> i) & 1;
            if (!ch[u][bit]) ch[u][bit] = ++tot;
            u = ch[u][bit];
            ++cnt[u];
        }
    }

    void erase(u32 x) {
        i32 u = 0;
        for (i32 i = 30; i >= 0; --i) {
            i32 bit = (x >> i) & 1;
            u = ch[u][bit];
            --cnt[u];
        }
    }

    // 查询与 x 异或能获得的最大值
    u32 query_max_xor(u32 x) const {
        i32 u = 0;
        u32 res = 0;
        for (i32 i = 30; i >= 0; --i) {
            i32 bit = (x >> i) & 1;
            i32 want = bit ^ 1;
            if (ch[u][want] && cnt[ch[u][want]] > 0) {
                res |= (1U << i);
                u = ch[u][want];
            } else {
                u = ch[u][bit];
            }
        }
        return res;
    }
};
```

== AC 自动机 (Aho-Corasick Automaton)
多模式串精确匹配自动机（Trie + Fail 指针 + Trie 图路径压缩）。
- *Trie 图优化*：BFS 构建失配指针时将空转移直接指向失配节点的转移，实现单字符 $O(1)$ 状态转移。
- *拓扑排序优化*：统计文本串中各模式串出现次数时，匹配过程仅标记经过的状态计数 `val[u]++`，扫描完毕后按 fail 树反向拓扑排序自底向上传递贡献，避免最坏 $O(|T| times max|P|)$ 的暴力跳 fail 退化，总时间严格 $O(|T| + sum |P|)$。

```cpp
constexpr i32 ac_max_nodes = 500005;
constexpr i32 alphabet_size = 26;

struct ACAutomaton {
    i32 ch[ac_max_nodes][alphabet_size];
    i32 fail[ac_max_nodes];
    i32 in_deg[ac_max_nodes]; // fail 树入度，用于拓扑排序
    i32 val[ac_max_nodes];    // 文本匹配时各状态触发次数
    i32 pos[ac_max_nodes];    // 第 i 个模式串对应的 Trie 节点编号
    i32 tot = 0;

    void clear() {
        rep1(i, 0, tot) {
            memset(ch[i], 0, sizeof(ch[i]));
            fail[i] = in_deg[i] = val[i] = pos[i] = 0;
        }
        tot = 0;
    }

    void insert(const string& s, i32 id) {
        i32 u = 0;
        for (char c : s) {
            i32 idx = c - 'a';
            if (!ch[u][idx]) ch[u][idx] = ++tot;
            u = ch[u][idx];
        }
        pos[id] = u;
    }

    void build() {
        queue<i32> q;
        rep(c, 0, alphabet_size) {
            if (ch[0][c]) {
                q.push(ch[0][c]);
            }
        }
        while (!q.empty()) {
            i32 u = q.front();
            q.pop();
            rep(c, 0, alphabet_size) {
                if (ch[u][c]) {
                    fail[ch[u][c]] = ch[fail[u]][c];
                    q.push(ch[u][c]);
                } else {
                    ch[u][c] = ch[fail[u]][c];
                }
            }
        }
        // 统计 fail 树入度
        rep1(i, 1, tot) {
            ++in_deg[fail[i]];
        }
    }

    // 查询所有模式串在 text 中的出现次数，返回每个模式串匹配次数 vector (1-based, 长度 num_patterns + 1)
    vector<i32> query_counts(const string& text, i32 num_patterns) {
        i32 u = 0;
        for (char c : text) {
            u = ch[u][c - 'a'];
            ++val[u];
        }

        // 拓扑排序自底向上累加贡献
        queue<i32> q;
        rep1(i, 1, tot) {
            if (!in_deg[i]) q.push(i);
        }
        while (!q.empty()) {
            i32 cur = q.front();
            q.pop();
            i32 fa = fail[cur];
            val[fa] += val[cur];
            if (--in_deg[fa] == 0 && fa != 0) {
                q.push(fa);
            }
        }

        vector<i32> ans(num_patterns + 1);
        rep1(i, 1, num_patterns) {
            ans[i] = val[pos[i]];
        }
        return ans;
    }
};
```

== 后缀数组 (Suffix Array / SA)
倍增法基数排序构造后缀数组，包含 `height` 数组与 ST 表 $O(1)$ LCP 查询。
- *数组定义*（下标统一 1-based，范围 $1 tilde n$）：
  - `sa[i]`：排名为 $i$ 的后缀起始位置。
  - `rk[i]`：从位置 $i$ 开始的后缀的字典序排名（满足 `sa[rk[i]] == i`）。
  - `height[i]`：排名为 $i$ 与 $i - 1$ 的两后缀的最长公共前缀（$"LCP"("sa"[i], "sa"[i - 1])$）。
- *关键性质*：
  1. $"LCP"("sa"[i], "sa"[j]) = min_(k = i + 1)^j "height"[k]$（假设 $i < j$），利用 ST 表预处理实现 $O(1)$ 范围最小值查询。
  2. *本质不同子串个数*：$frac(n(n + 1), 2) - sum_(i = 1)^n "height"[i]$。
  3. *最长重复子串 / 出现至少 $k$ 次的最长子串*：二分答案 $"len"$，利用 $"height"[i] >= "len"$ 将后缀连续分组检验。
- *复杂度*：倍增排序 $O(n log n)$，求 `height` $O(n)$，ST 表预处理 $O(n log n)$，单次 LCP 查询 $O(1)$。

```cpp
constexpr i32 maxn = 1000005;
constexpr i32 max_log = 21;

struct SuffixArray {
    i32 n;
    i32 sa[maxn], rk[maxn], oldrk[maxn << 1], id[maxn], cnt[maxn];
    i32 height[maxn];
    i32 st[maxn][max_log];
    i32 lg[maxn];

    void clear(i32 len) {
        n = len;
        rep1(i, 0, n) {
            sa[i] = rk[i] = id[i] = cnt[i] = height[i] = 0;
            rep(k, 0, max_log) st[i][k] = 0;
        }
        rep1(i, 0, (n << 1)) oldrk[i] = 0;
    }

    // 字符串采用 1-based，s 长度为 n
    void build(const string& s) {
        n = sz(s);
        clear(n);
        i32 m = 127; // 字符集大小初始为 ASCII 范围

        // 第一轮基数排序 (单字符)
        rep1(i, 1, n) ++cnt[rk[i] = s[i - 1]];
        rep1(i, 1, m) cnt[i] += cnt[i - 1];
        for (i32 i = n; i >= 1; --i) sa[cnt[rk[i]]--] = i;

        // 倍增双关键字基数排序
        for (i32 w = 1; w < n; w <<= 1) {
            i32 p = 0;
            // 第二关键字排序: [n - w + 1, n] 没有第二关键字，排在最前面
            rep1(i, n - w + 1, n) id[++p] = i;
            rep1(i, 1, n) {
                if (sa[i] > w) id[++p] = sa[i] - w;
            }

            // 第一关键字基数排序
            rep1(i, 1, m) cnt[i] = 0;
            rep1(i, 1, n) ++cnt[rk[id[i]]];
            rep1(i, 1, m) cnt[i] += cnt[i - 1];
            for (i32 i = n; i >= 1; --i) sa[cnt[rk[id[i]]]--] = id[i];

            // 离散化重编 rk
            memcpy(oldrk + 1, rk + 1, n * sizeof(i32));
            p = 0;
            rep1(i, 1, n) {
                auto is_same = [&](i32 x, i32 y) {
                    return oldrk[x] == oldrk[y] && oldrk[x + w] == oldrk[y + w];
                };
                rk[sa[i]] = (i == 1 || is_same(sa[i], sa[i - 1])) ? p : ++p;
            }
            m = p;
            if (m == n) break; // 排名已完全互异
        }

        // 求 height 数组: height[i] = LCP(sa[i], sa[i - 1])
        i32 k = 0;
        rep1(i, 1, n) {
            if (rk[i] == 1) {
                k = 0;
                continue;
            }
            if (k) --k;
            i32 j = sa[rk[i] - 1];
            while (i + k <= n && j + k <= n && s[i + k - 1] == s[j + k - 1]) ++k;
            height[rk[i]] = k;
        }

        // 构建 ST 表以支持 O(1) 查询区间最小值 (LCP)
        lg[1] = 0;
        rep1(i, 2, n) lg[i] = lg[i >> 1] + 1;

        rep1(i, 1, n) st[i][0] = height[i];
        for (i32 j = 1; (1 << j) <= n; ++j) {
            for (i32 i = 1; i + (1 << j) - 1 <= n; ++i) {
                st[i][j] = min(st[i][j - 1], st[i + (1 << (j - 1))][j - 1]);
            }
        }
    }

    // 查询排名为 r1 和 r2 的两后缀的 LCP (1-based 排名)
    i32 query_lcp_by_rank(i32 r1, i32 r2) const {
        if (r1 == r2) return n - sa[r1] + 1;
        if (r1 > r2) swap(r1, r2);
        i32 l = r1 + 1, r = r2;
        i32 k = lg[r - l + 1];
        return min(st[l][k], st[r - (1 << k) + 1][k]);
    }

    // 查询原串中后缀 i 和后缀 j 的 LCP (1-based 位置)
    i32 query_lcp(i32 i, i32 j) const {
        if (i == j) return n - i + 1;
        return query_lcp_by_rank(rk[i], rk[j]);
    }

    // 本质不同子串个数 = n * (n + 1) / 2 - \sum height[i]
    i64 count_distinct_substrings() const {
        i64 ans = 1LL * n * (n + 1) / 2;
        rep1(i, 1, n) ans -= height[i];
        return ans;
    }
};
```

== 后缀自动机 (Suffix Automaton / SAM)
识别给定字符串所有子串的最简确定性有限状态自动机 (DFA)。
- *空间特征*：对于长度为 $n$ 的字符串，SAM 状态节点数最多为 $2n - 1$，DAG 转移边数最多为 $3n - 4$。
- *状态性质*：
  - 每个状态 $u$ 代表一个 `endpos` 等价类，包含原串中若干出现位置集合完全相同的子串。
  - $u$ 包含的子串长度连续分布在 $("len"["link"[u]], "len"[u]]$ 区间内。
  - `link[u]`（Parent 树指针）指向包含 $u$ 中子串最长真后缀的状态。
- *经典应用*：
  1. *本质不同子串数*：$sum_(u = 2)^("tot") ("len"[u] - "len"["link"[u]])$。
  2. *子串出现次数*：按 `len` 逆序（即 Parent 树拓扑序）自底向上传递累加 `cnt[u]`。
  3. *最长公共子串 (LCS)*：多串在 DAG 上滑动匹配。
- *时间与空间复杂度*：在线构造时间 $O(n)$，空间复杂度严格 $O(n)$。

```cpp
constexpr i32 sam_max_nodes = 2000005; // 状态数最多为 2 * n - 1
constexpr i32 alphabet_size = 26;

struct SAM {
    i32 ch[sam_max_nodes][alphabet_size];
    i32 link[sam_max_nodes];
    i32 len[sam_max_nodes];
    i32 cnt[sam_max_nodes]; // 该状态对应的子串在原串中的出现次数
    i32 last = 1, tot = 1;

    void clear() {
        rep1(i, 1, tot) {
            memset(ch[i], 0, sizeof(ch[i]));
            link[i] = len[i] = cnt[i] = 0;
        }
        last = tot = 1;
    }

    void extend(char c) {
        i32 cur = ++tot;
        len[cur] = len[last] + 1;
        cnt[cur] = 1;
        i32 p = last;
        i32 idx = c - 'a';

        while (p && !ch[p][idx]) {
            ch[p][idx] = cur;
            p = link[p];
        }

        if (!p) {
            link[cur] = 1;
        } else {
            i32 q = ch[p][idx];
            if (len[p] + 1 == len[q]) {
                link[cur] = q;
            } else {
                i32 clone = ++tot;
                len[clone] = len[p] + 1;
                memcpy(ch[clone], ch[q], sizeof(ch[q]));
                link[clone] = link[q];
                cnt[clone] = 0;

                while (p && ch[p][idx] == q) {
                    ch[p][idx] = clone;
                    p = link[p];
                }
                link[q] = link[cur] = clone;
            }
        }
        last = cur;
    }

    void build(const string& s) {
        clear();
        for (char c : s) extend(c);
    }

    // 本质不同子串总数 = \sum (len[u] - len[link[u]])
    i64 count_distinct_substrings() const {
        i64 ans = 0;
        rep1(i, 2, tot) {
            ans += (len[i] - len[link[i]]);
        }
        return ans;
    }

    // 拓扑排序计算每个状态子串在原串中的出现次数 cnt[u]
    // 辅助数组: c[i] 为长度等于 i 的节点数，a[i] 为拓扑序
    void compute_frequencies(i32 n, vector<i32>& a, vector<i32>& c) {
        c.assign(n + 1, 0);
        a.assign(tot + 1, 0);
        rep1(i, 1, tot) ++c[len[i]];
        rep1(i, 1, n) c[i] += c[i - 1];
        for (i32 i = tot; i >= 1; --i) a[c[len[i]]--] = i;

        // 沿 Parent 树自底向上累加
        for (i32 i = tot; i >= 1; --i) {
            i32 u = a[i];
            if (link[u]) cnt[link[u]] += cnt[u];
        }
    }
};
```

= 图论
节点编号统一 1-based：

== Dijkstra
```cpp
constexpr i32 maxn = 200005;
constexpr i64 inf = numeric_limits<i64>::max() / 2;
struct Edge { i32 to; i64 w; };
vector<Edge> g[maxn];
i64 dis[maxn];

void dijkstra(i32 st, i32 n) {
    rep1(i, 1, n) dis[i] = inf;
    priority_queue<pair<i64, i32>, vector<pair<i64, i32>>, greater<>> pq;
    dis[st] = 0;
    pq.push({0, st});
    while (!pq.empty()) {
        auto [d, u] = pq.top(); pq.pop();
        if (d > dis[u]) continue;
        for (auto& [v, w] : g[u]) {
            if (dis[u] + w < dis[v]) {
                dis[v] = dis[u] + w;
                pq.push({dis[v], v});
            }
        }
    }
}
```

== SPFA
```cpp
constexpr i32 maxn = 200005;
constexpr i64 inf = numeric_limits<i64>::max() / 2;
struct Edge { i32 to; i64 w; };
vector<Edge> g[maxn];
i64 dis[maxn];
i32 cnt[maxn];
bool in_q[maxn];

// 返回 true 表示存在负环 (节点 1 ~ n)
bool spfa(i32 st, i32 n) {
    rep1(i, 1, n) { dis[i] = inf; cnt[i] = 0; in_q[i] = false; }
    queue<i32> q;
    dis[st] = 0; q.push(st); in_q[st] = true;
    while (!q.empty()) {
        i32 u = q.front(); q.pop(); in_q[u] = false;
        for (auto& [v, w] : g[u]) {
            if (dis[u] + w < dis[v]) {
                dis[v] = dis[u] + w;
                cnt[v] = cnt[u] + 1;
                if (cnt[v] >= n) return true;
                if (!in_q[v]) { q.push(v); in_q[v] = true; }
            }
        }
    }
    return false;
}
```

== Floyd
```cpp
constexpr i32 maxn = 505;
constexpr i64 inf = numeric_limits<i64>::max() / 2;
i64 d[maxn][maxn];

void floyd(i32 n) {
    rep1(k, 1, n) rep1(i, 1, n) rep1(j, 1, n)
        if (d[i][k] < inf && d[k][j] < inf)
            d[i][j] = min(d[i][j], d[i][k] + d[k][j]);
}
```

== LCA
倍增 LCA，1-based（0 号节点作为虚空哨兵，`dep[0] = 0`）：
```cpp
constexpr i32 maxn = 200005;
vector<i32> g[maxn];
i32 up[maxn][20], dep[maxn];

// 根节点调用 dfs_lca(root, 0, 1)
void dfs_lca(i32 u, i32 p, i32 d = 1) {
    dep[u] = d;
    up[u][0] = p;
    rep(i, 1, 20) up[u][i] = up[up[u][i - 1]][i - 1];
    for (i32 v : g[u]) {
        if (v != p) dfs_lca(v, u, d + 1);
    }
}

i32 lca(i32 u, i32 v) {
    if (dep[u] < dep[v]) swap(u, v);
    for (i32 i = 19; i >= 0; --i)
        if (dep[u] - (1 << i) >= dep[v]) u = up[u][i];
    if (u == v) return u;
    for (i32 i = 19; i >= 0; --i)
        if (up[u][i] != up[v][i]) { u = up[u][i]; v = up[v][i]; }
    return up[u][0];
}
```
== SCC
```cpp
vector<i32> adj[maxn],dag[maxn];
i32 dfn[maxn],dc,low[maxn],siz[maxn],sc,scc[maxn],stk[maxn],top;
bool in_stk[maxn];
void init(i32 n){
    dc=sc=1;
    top=0;
    rep1(i,1,n) adj[i].clear();
    rep1(i,1,n) dag[i].clear();
    rep1(i,1,n) dfn[i]=low[i]=scc[i]=-1;
    rep1(i,1,n) siz[i]=0;
    rep1(i,1,n) in_stk[i]=false;
}
void tarjan(i32 u){
    dfn[u]=low[u]=dc++;
    stk[top++]=u;
    in_stk[u]=true;
    for(i32 v:adj[u]){
        if(dfn[v]==-1){
            tarjan(v);
            low[u]=min(low[u],low[v]);
        } else if(in_stk[v]){
            low[u]=min(low[u],dfn[v]);
        }
    }
    if(low[u]==dfn[u]){
        while(true){
            i32 v=stk[--top];
            in_stk[v]=false;
            scc[v]=sc;
            siz[sc]++;
            if(u==v) break;
        }
        sc++;
    }
}
void build(i32 n){
    rep1(u,1,n){
        for(i32 v:adj[u]){
            if(scc[u]==scc[v]) continue;
            dag[scc[u]].push_back(scc[v]);
        }
    }
    rep(i,1,sc){
        sort(dag[i].begin(),dag[i].end());
        dag[i].erase(unique(dag[i].begin(),dag[i].end()),dag[i].end());
    }
}
signed main(){
    i32 n;
    cin>>n;
    init(n);
    // read adj
    rep1(i,1,n) {
        if (dfn[i]==-1) tarjan(i);
    }
    build(n);
}
```

== 虚树 (Virtual Tree)
对于多次询问 $k$ 个关键点且 $sum k <= 5 times 10^5$ 的树上问题，利用单调栈在 $O(k log k)$ 时间内浓缩关键点及其两两 LCA，构建规模不超过 $2k$ 个节点的虚树：
- 依赖原树的 DFS 序 `dfn`、深度 `dep` 以及倍增 `LCA`。
- 构建完成后返回虚树根节点；单次询问结束后需 $O(k)$ 清理虚树邻接表，切忌使用全局 `memset`。

```cpp
constexpr i32 maxn = 200005;
vector<i32> g[maxn];          // 原树
vector<i32> vt[maxn];         // 虚树邻接表 (带权时存 pair<i32, i64> {to, dep[to] - dep[u]})
i32 up[maxn][20], dep[maxn], dfn[maxn], dfn_cnt;
i32 stk[maxn], top;

// 根节点调用 dfs_tree(root, 0, 1)
void dfs_tree(i32 u, i32 p, i32 d = 1) {
    dep[u] = d;
    up[u][0] = p;
    dfn[u] = ++dfn_cnt;
    rep(i, 1, 20) up[u][i] = up[up[u][i - 1]][i - 1];
    for (i32 v : g[u]) {
        if (v != p) dfs_tree(v, u, d + 1);
    }
}

i32 lca(i32 u, i32 v) {
    if (dep[u] < dep[v]) swap(u, v);
    for (i32 i = 19; i >= 0; --i)
        if (dep[u] - (1 << i) >= dep[v]) u = up[u][i];
    if (u == v) return u;
    for (i32 i = 19; i >= 0; --i)
        if (up[u][i] != up[v][i]) { u = up[u][i]; v = up[v][i]; }
    return up[u][0];
}

// 建立虚树，传入关键点列表 nodes，返回虚树根节点
i32 build_virtual_tree(vector<i32>& nodes) {
    if (nodes.empty()) return -1;
    sort(all(nodes), [](i32 u, i32 v) { return dfn[u] < dfn[v]; });
    nodes.erase(unique(all(nodes)), nodes.end());

    top = 0;
    stk[++top] = nodes[0];
    vt[nodes[0]].clear();

    rep(i, 1, sz(nodes)) {
        i32 u = nodes[i];
        i32 p = lca(u, stk[top]);
        if (p != stk[top]) {
            while (top > 1 && dep[stk[top - 1]] >= dep[p]) {
                vt[stk[top - 1]].push_back(stk[top]);
                --top;
            }
            if (stk[top] != p) {
                vt[p].clear();
                vt[p].push_back(stk[top]);
                stk[top] = p;
            }
        }
        vt[u].clear();
        stk[++top] = u;
    }
    while (top > 1) {
        vt[stk[top - 1]].push_back(stk[top]);
        --top;
    }
    return stk[1];
}
```

== 树哈希 (Tree Hash / 树同构)
用于高效判定两棵树是否同构、统计本质不同子树数量等问题：
- *原理与抗碰撞设计*：
  - 定义有根子树哈希为子节点哈希的多重集累加：$h(u) = 1 + sum_(v in "ch"(u)) f(h(v))$，求和操作天然具有对称性（与子树遍历顺序无关）。
  - 混淆函数 $f(x)$ 采用 Xor-Shift 结合随机掩码 `mask`（`u64` 自然溢出），有效避免简单加法碰撞（如 $1+4 = 2+3$），且杜绝了异或哈希中相同子树互相抵消为 $0$ 的缺陷。
- *无根树同构判定*：树的重心在同构变换下保持不变（至多 $2$ 个重心）。计算以重心为根的树哈希值，当存在两个重心时取 $min$ 即可作为无根树的唯一标准哈希。
- *换根 DP*：由于哈希累加操作可逆（减法即为逆元），可用换根 DP 在 $O(n)$ 时间内求得以整棵树每个节点为根时的全树哈希值。

```cpp
constexpr i32 maxn = 200005;
vector<i32> g[maxn];
u64 h[maxn];
i32 sz_tree[maxn];
vector<i32> centroids;

// 64 位防 hack 非线性混淆映射 (比赛时可改用随机种子 mt19937_64(chrono::steady_clock::now().time_since_epoch().count())())
const u64 mask = mt19937_64(114514)();
u64 shift(u64 x) {
    x ^= mask;
    x ^= x << 13;
    x ^= x >> 7;
    x ^= x << 17;
    x ^= mask;
    return x;
}

// 1. 有根树子树哈希 (以 u 为根自底向上计算)
void dfs_hash(i32 u, i32 p) {
    h[u] = 1;
    for (i32 v : g[u]) {
        if (v == p) continue;
        dfs_hash(v, u);
        h[u] += shift(h[v]);
    }
}

// 2. 换根 DP (前置依赖 dfs_hash(root, 0)；遍历结束后 h[i] 为以 i 为根的全树哈希)
void reroot(i32 u, i32 p) {
    for (i32 v : g[u]) {
        if (v == p) continue;
        u64 hu = h[u] - shift(h[v]); // 剔除子树 v 的贡献
        h[v] += shift(hu);           // 加入上方整棵树的贡献
        reroot(v, u);
    }
}

// 3. 求树的重心 (至多 2 个)
void get_centroids(i32 u, i32 p, i32 total) {
    sz_tree[u] = 1;
    i32 max_part = 0;
    for (i32 v : g[u]) {
        if (v == p) continue;
        get_centroids(v, u, total);
        sz_tree[u] += sz_tree[v];
        max_part = max(max_part, sz_tree[v]);
    }
    max_part = max(max_part, total - sz_tree[u]);
    if (max_part <= total / 2) centroids.push_back(u);
}

// 4. 获取无根树同构唯一标准哈希 (1-based 节点 1 ~ total，单次仅需 1~2 遍 DFS)
u64 get_tree_hash(i32 total, i32 start = 1) {
    centroids.clear();
    get_centroids(start, 0, total);
    if (sz(centroids) == 1) {
        dfs_hash(centroids[0], 0);
        return h[centroids[0]];
    } else {
        dfs_hash(centroids[0], 0);
        u64 h1 = h[centroids[0]];
        dfs_hash(centroids[1], 0);
        u64 h2 = h[centroids[1]];
        return min(h1, h2);
    }
}
```

== 最小生成树 (Kruskal + 并查集)
```cpp
constexpr i32 maxn = 200005, m = 500005;
struct Edge { i32 u, v; i64 w; } e[m];
i32 fa[maxn];

i32 find(i32 x) { return fa[x] == x ? x : fa[x] = find(fa[x]); }

// 返回边权和；若不连通返回 -1 (节点 1 ~ n)
i64 kruskal(i32 n, i32 num_edges) {
    rep1(i, 1, n) fa[i] = i;
    sort(e, e + num_edges, [](const Edge& a, const Edge& b) { return a.w < b.w; });
    i64 sum = 0; i32 cnt = 0;
    rep(i, 0, num_edges) {
        i32 u = find(e[i].u), v = find(e[i].v);
        if (u != v) {
            fa[u] = v;
            sum += e[i].w;
            if (++cnt == n - 1) return sum;
        }
    }
    return n == 1 ? 0 : -1;
}
```

== 树上随机游走
示例:
$E_u=Sigma_(v in "son"_u) frac(E_v, "deg"_v) + frac(E_f, "deg"_f) + [u=s]$，

$E_v=A_v E_u+B_v, v in "son"_u$,

$E_u=Sigma_(v in "son"_u) frac(A_v E_u+B_v, "deg"_v) + frac(E_f, "deg"_f) + [u=s]$，

$E_u=frac(1, "deg"_f(1-Sigma_(v in "son"_u) frac(A_v, "deg"_v)))E_f+frac(Sigma_(v in "son"_u) frac(B_v, "deg"_v) + [u=s], (1-Sigma_(v in "son"_u) frac(A_v, "deg"_v)))$，

$A_u=frac(1, "deg"_f(1-Sigma_(v in "son"_u) frac(A_v, "deg"_v))), B_u=frac(Sigma_(v in "son"_u) frac(B_v, "deg"_v) + [u=s], (1-Sigma_(v in "son"_u) frac(A_v, "deg"_v)))$。

= 数学

== 数论函数与核心定理简述

=== 1. 常见数论函数及性质
数论函数指定义域为正整数 $ZZ^+$ 的函数。若对任意互质的 $a, b$ 满足 $f(a b) = f(a)f(b)$，称 $f$ 为*积性函数*；若对任意正整数 $a, b$ 均满足，称 $f$ 为*完全积性函数*。设 $n$ 的标准质因子分解为 $n = product_(i=1)^k p_i^(c_i)$：

#table(
  columns: (auto, auto, auto, 1fr),
  fill: (col, row) => if row == 0 { rgb("f0f2f5") } else { none },
  stroke: 0.5pt + luma(180),
  [*函数名称*], [*符号与定义*], [*积性*], [*计算式与关键性质*],
  [*元函数 / 单位元*], [$epsilon(n) = [n = 1]$], [完全积性], [狄利克雷卷积的单位元：$f * epsilon = f$。],
  [*常数函数*], [$bold(1)(n) = 1$], [完全积性], [恒等于 1 的函数。],
  [*恒等函数*], [$"id"(n) = n$（或 $"id"_k(n) = n^k$）], [完全积性], [满足 $"id" * mu = phi.alt$。],
  [*欧拉函数*], [$phi.alt(n) = sum_(i=1)^n [gcd(i, n) = 1]$], [积性], [$phi.alt(n) = n product_(p | n) (1 - frac(1, p)) = product p_i^(c_i - 1)(p_i - 1)$。 \ 性质：$sum_(d | n) phi.alt(d) = n$（即 $phi.alt * bold(1) = "id"$）。 \ 欧拉反演：$[gcd(i, j) = 1] = sum_(d | gcd(i, j)) mu(d)$。],
  [*莫比乌斯函数*], [$mu(n) = cases(1, & n = 1, (-1)^k, & n = product_(i=1)^k p_i ("""无平方因子"""), 0, & """其它""")$], [积性], [核心反演性质：$sum_(d | n) mu(d) = [n = 1]$（即 $mu * bold(1) = epsilon$）。 \ 莫比乌斯反演定理：$f = g * bold(1) <=> g = f * mu$。],
  [*约数个数函数*], [$d(n) = tau(n) = sum_(d | n) 1$], [积性], [$d(n) = product_(i=1)^k (c_i + 1)$。 \ 卷积关系：$d = bold(1) * bold(1)$。],
  [*约数和函数*], [$sigma(n) = sigma_1(n) = sum_(d | n) d$], [积性], [$sigma(n) = product_(i=1)^k frac(p_i^(c_i + 1) - 1, p_i - 1)$。 \ 卷积关系：$sigma = "id" * bold(1)$。],
)

=== 2. 狄利克雷卷积体系 (Dirichlet Convolution)
定义两个数论函数 $f, g$ 的卷积运算 $*$：
$ (f * g)(n) = sum_(d | n) f(d) g(frac(n, d)) = sum_(a b = n) f(a) g(b) $

*代数性质*：
1. *交换律*：$f * g = g * f$
2. *结合律*：$(f * g) * h = f * (g * h)$
3. *分配律*：$f * (g + h) = f * g + f * h$
4. *单位元*：$epsilon * f = f$
5. *积性保持*：若 $f, g$ 均为积性函数，则 $f * g$ 亦为积性函数。

*经典卷积恒等式关系*：
- $mu * bold(1) = epsilon$（莫比乌斯反演基石）
- $phi.alt * bold(1) = "id" <=> "id" * mu = phi.alt$
- $bold(1) * bold(1) = d$
- $"id" * bold(1) = sigma$
- $d * mu = bold(1)$
- $sigma * mu = "id"$

=== 3. 常见数论定理汇总

1. *算术基本定理（唯一分解定理）*：
   任意大于 1 的整数 $n$ 都能被唯一分解为有限个质数的乘积：$n = product_(i=1)^k p_i^(c_i)$。

2. *裴蜀定理（Bézout's identity）*：
   设 $a, b in ZZ$，方程 $a x + b y = m$ 有整数解 $(x, y)$ 当且仅当 $gcd(a, b) | m$。特别地，$a x + b y = gcd(a, b)$ 恒有整数解，可通过扩展欧几里得算法（`exgcd`）在 $O(log min(a, b))$ 内构造一组特解。

3. *费马小定理（Fermat's Little Theorem）*：
   若 $p$ 为质数且 $gcd(a, p) = 1$，则：
   $ a^(p-1) equiv 1 mod p $
   推论：模 $p$ 意义下 $a$ 的乘法逆元为 $a^(-1) equiv a^(p-2) mod p$。

4. *欧拉定理（Euler's Totient Theorem）*：
   若 $gcd(a, m) = 1$，则：
   $ a^(phi.alt(m)) equiv 1 mod m $

5. *扩展欧拉定理（降幂公式）*：
   对任意底数 $a$ 与模数 $m$（*不要求互质*）：
   $ a^b equiv cases(a^b, & b < phi.alt(m), a^(b mod phi.alt(m) + phi.alt(m)), & b >= phi.alt(m)) mod m $
   主要用于处理指数极大（以高精度字符串给出或幂塔结构）时的同余运算。

6. *中国剩余定理 (CRT) 与扩展中国剩余定理 (EXCRT)*：
   - *CRT*：求解线性同余方程组 $x equiv r_i mod{m_i}$。当模数 $m_i$ 两两互质时，方程组在模 $M = product m_i$ 下有唯一解：$x equiv sum r_i M_i M_i^(-1) mod M$（其中 $M_i = M / m_i$）。
   - *EXCRT*：当模数不保证互质时，利用 `exgcd` 依次两两合并方程：设当前解为 $x equiv "ans" mod L$，新方程为 $x equiv r mod m$，则等价于解 $L dot t equiv r - "ans" mod m$。若无解则方程组无解，否则更新 $"ans"$ 与 $L <- "lcm"(L, m)$。

7. *威尔逊定理（Wilson's Theorem）*：
   整数 $p > 1$ 是质数当且仅当 $(p - 1)! equiv -1 mod p$。

8. *卢卡斯定理（Lucas' Theorem）*：
   若 $p$ 为质数，$n, m$ 为非负整数，则：
   $ binom(n, m) equiv binom(floor(n/p), floor(m/p)) binom(n mod p, m mod p) mod p $
   用于在小质数模数 $p$（通常 $p <= 10^5$）下计算极大组合数 $binom(n, m)$（$n, m <= 10^(18)$）。

== 线性筛预处理积性函数 (primes, μ, φ, d)
一次线性筛同时求质数、莫比乌斯函数 $mu$、欧拉函数 $phi.alt$、约数个数 $d$：
```cpp
constexpr i32 max_v = 1000005;
i32 primes[max_v], minp[max_v], mu[max_v], phi[max_v], d[max_v], num[max_v], pr_cnt;
bool isp[max_v];

void init_multiplicative(i32 m = max_v - 1) {
    fill(isp + 2, isp + m + 1, true);
    mu[1] = 1; phi[1] = 1; d[1] = 1;
    pr_cnt = 0;
    rep1(i, 2, m) {
        if (isp[i]) {
            primes[pr_cnt++] = i;
            minp[i] = i;
            mu[i] = -1;
            phi[i] = i - 1;
            d[i] = 2;
            num[i] = 1; // 最小质因子幂次
        }
        rep(j, 0, pr_cnt) {
            if (primes[j] * i > m) break;
            i32 p = primes[j], comp = p * i;
            isp[comp] = false;
            minp[comp] = p;
            if (i % p == 0) {
                mu[comp] = 0;
                phi[comp] = phi[i] * p;
                num[comp] = num[i] + 1;
                d[comp] = d[i] / (num[i] + 1) * (num[comp] + 1);
                break;
            }
            mu[comp] = -mu[i];
            phi[comp] = phi[i] * (p - 1);
            num[comp] = 1;
            d[comp] = d[i] * 2;
        }
    }
}
```

== 杜教筛 (求积性函数前缀和)
用于在 $O(n^(2/3))$ 时间复杂度内计算积性函数的前缀和 $S(n) = sum_(i=1)^n f(i)$（例如 $n <= 10^9 tilde 10^(11)$）。

=== 核心推导公式
寻找积性函数 $g$，使得 $g$ 与 $h = f * g$ 的前缀和均易于快速计算。根据狄利克雷卷积展开：
$ sum_(i=1)^n (f * g)(i) = sum_(i=1)^n sum_(d | i) g(d) f(frac(i, d)) = sum_(d=1)^n g(d) S(floor(frac(n, d))) $
移项分离出 $d = 1$ 的项：
$ g(1) S(n) = sum_(i=1)^n (f * g)(i) - sum_(d=2)^n g(d) S(floor(frac(n, d))) $

=== 经典构造
1. *求 $mu$ 的前缀和*：取 $g = bold(1)$，则 $mu * bold(1) = epsilon$，得：
   $ M(n) = 1 - sum_(d=2)^n M(floor(frac(n, d))) $
2. *求 $phi.alt$ 的前缀和*：取 $g = bold(1)$，则 $phi.alt * bold(1) = "id"$，得：
   $ Phi(n) = frac(n(n+1), 2) - sum_(d=2)^n Phi(floor(frac(n, d))) $

预处理前 $O(n^(2/3))$ 项（通常 $N approx 2 times 10^6$），超出部分使用哈希表（`gp_hash_table`）记忆化与数论分块加速：
```cpp
#include <ext/pb_ds/assoc_container.hpp>
using namespace __gnu_pbds;

constexpr i32 lim = 2000005;
i32 primes[lim], pr_cnt;
bool isp[lim];
i32 mu[lim];
i64 sum_mu[lim], sum_phi[lim];
gp_hash_table<i64, i64> mem_mu, mem_phi;

void init_du_sieve(i32 m = lim - 1) {
    fill(isp + 2, isp + m + 1, true);
    mu[1] = 1; sum_phi[1] = 1;
    pr_cnt = 0;
    rep1(i, 2, m) {
        if (isp[i]) {
            primes[pr_cnt++] = i;
            mu[i] = -1;
            sum_phi[i] = i - 1;
        }
        rep(j, 0, pr_cnt) {
            if (primes[j] * i > m) break;
            i32 p = primes[j], comp = p * i;
            isp[comp] = false;
            if (i % p == 0) {
                mu[comp] = 0;
                sum_phi[comp] = sum_phi[i] * p;
                break;
            }
            mu[comp] = -mu[i];
            sum_phi[comp] = sum_phi[i] * (p - 1);
        }
    }
    rep1(i, 1, m) {
        sum_mu[i] = sum_mu[i - 1] + mu[i];
        sum_phi[i] += sum_phi[i - 1];
    }
}

// 计算 sum_{i=1}^n mu(i)
i64 get_sum_mu(i64 n) {
    if (n < lim) return sum_mu[n];
    if (mem_mu.find(n) != mem_mu.end()) return mem_mu[n];
    i64 ans = 1;
    for (i64 l = 2, r; l <= n; l = r + 1) {
        r = n / (n / l);
        ans -= (r - l + 1) * get_sum_mu(n / l);
    }
    return mem_mu[n] = ans;
}

// 计算 sum_{i=1}^n phi(i)
i64 get_sum_phi(i64 n) {
    if (n < lim) return sum_phi[n];
    if (mem_phi.find(n) != mem_phi.end()) return mem_phi[n];
    i64 ans = (i64)((u128)n * (n + 1) / 2);
    for (i64 l = 2, r; l <= n; l = r + 1) {
        r = n / (n / l);
        ans -= (r - l + 1) * get_sum_phi(n / l);
    }
    return mem_phi[n] = ans;
}
```

== 快速幂
```cpp
i64 binpow(i64 a, i64 b, i64 p) {
    i64 res = 1 % p;
    a = (a % p + p) % p;
    while (b > 0) {
        if (b & 1) res = (i64)((i128)res * a % p);
        a = (i64)((i128)a * a % p);
        b >>= 1;
    }
    return res;
}
```

== exgcd 与 模逆元
```cpp
i64 exgcd(i64 a, i64 b, i64 &x, i64 &y) {
    if (!b) { x = 1; y = 0; return a; }
    i64 d = exgcd(b, a % b, y, x);
    y -= a / b * x;
    return d;
}

i64 inv(i64 a, i64 m) {
    i64 x, y;
    i64 g = exgcd(a, m, x, y);
    return g == 1 ? (x % m + m) % m : -1;
}
```

== 扩展中国剩余定理 (EXCRT)
求解线性同余方程组 $x equiv r_i mod{m_i}$（模数无需两两互质）：
```cpp
// 返回 {ans, lcm}; 若无解返回 {-1, -1}
pair<i64, i64> excrt(const vector<i64>& r, const vector<i64>& m) {
    i64 ans = 0, lcm = 1;
    rep(i, 0, sz(r)) {
        i64 a = lcm, b = m[i], c = (r[i] - ans % b + b) % b;
        i64 x, y;
        i64 g = exgcd(a, b, x, y);
        if (c % g != 0) return {-1, -1};
        x = (i64)((i128)x * (c / g) % (b / g));
        if (x < 0) x += b / g;
        ans += (i64)((i128)x * lcm);
        lcm = (i64)((i128)lcm / g * b);
        ans = (ans % lcm + lcm) % lcm;
    }
    return {ans, lcm};
}
```

== 扩展欧拉定理 (降幂取模)
计算 $a^b mod m$，其中指数 $b$ 以十进制字符串形式给出：
```cpp
i64 get_phi(i64 n) {
    i64 res = n;
    for (i64 i = 2; i * i <= n; ++i) {
        if (n % i == 0) {
            while (n % i == 0) n /= i;
            res -= res / i;
        }
    }
    if (n > 1) res -= res / n;
    return res;
}

i64 ex_euler_pow(i64 a, const string& b_str, i64 m) {
    i64 phi_m = get_phi(m);
    i64 exp = 0;
    bool ge = false;
    rep(i, 0, sz(b_str)) {
        exp = exp * 10 + (b_str[i] - '0');
        if (exp >= phi_m) { ge = true; exp %= phi_m; }
    }
    if (ge) exp += phi_m;
    return binpow(a, exp, m);
}
```

== 欧拉筛
```cpp
constexpr i32 maxn = 10000005;
i32 primes[maxn], minp[maxn], pr_cnt;
bool isp[maxn];

void init_sieve(i32 m = maxn - 1) {
    fill(isp + 2, isp + m + 1, true);
    pr_cnt = 0;
    rep1(i, 2, m) {
        if (isp[i]) { primes[pr_cnt++] = i; minp[i] = i; }
        rep(j, 0, pr_cnt) {
            if (primes[j] * i > m) break;
            isp[primes[j] * i] = false;
            minp[primes[j] * i] = primes[j];
            if (i % primes[j] == 0) break;
        }
    }
}

// 快速质因数分解 O(log N)
vector<pair<i32, i32>> factorize_sieve(i32 val) {
    vector<pair<i32, i32>> res;
    while (val > 1) {
        i32 p = minp[val], count = 0;
        while (val % p == 0) { ++count; val /= p; }
        res.push_back({p, count});
    }
    return res;
}
```

== 质因数分解 (Miller – Rabin 素数测试与 Pollard – Rho 因式分解)
复杂度 $O(N^(1/4))$：
```cpp
inline i64 mul(i64 a, i64 b, i64 m) {
    return (i64)((u128)a * b % m);
}

i64 power(i64 a, i64 b, i64 m) {
    i64 res = 1 % m; a %= m;
    for (; b; b >>= 1, a = mul(a, a, m)) if (b & 1) res = mul(res, a, m);
    return res;
}

bool isprime(i64 n) {
    if (n < 2) return false;
    if (n == 2 || n == 3 || n == 5 || n == 7) return true;
    if (n % 2 == 0 || n % 3 == 0 || n % 5 == 0 || n % 7 == 0) return false;
    static constexpr i64 a[] = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37};
    i32 s = __builtin_ctzll(n - 1);
    i64 d = (n - 1) >> s;
    rep(k, 0, 12) {
        i64 v = a[k];
        if (n <= v) break;
        i64 x = power(v, d, n);
        if (x == 1 || x == n - 1) continue;
        bool ok = false;
        rep(i, 0, s - 1) {
            x = mul(x, x, n);
            if (x == n - 1) { ok = true; break; }
        }
        if (!ok) return false;
    }
    return true;
}

vector<i64> factorize(i64 n) {
    vector<i64> p;
    auto f = [&](auto& self, i64 n) -> void {
        if (n <= 1) return;
        if (n <= 10000) {
            for (i64 i = 2; i * i <= n; ++i) {
                while (n % i == 0) { p.push_back(i); n /= i; }
            }
            if (n > 1) p.push_back(n);
            return;
        }
        if (isprime(n)) { p.push_back(n); return; }
        auto g = [&](i64 x, i64 c) { return (mul(x, x, n) + c) % n; };
        i64 x0 = 2, c = 1;
        loop {
            i64 x = x0, y = x0, d = 1, power_limit = 1, lam = 0, v = 1;
            while (d == 1) {
                y = g(y, c); ++lam;
                v = mul(v, abs(x - y), n);
                if (lam % 127 == 0) { d = std::gcd(v, n); v = 1; }
                if (power_limit == lam) {
                    x = y; power_limit *= 2; lam = 0;
                    d = std::gcd(v, n); v = 1;
                }
            }
            if (d != n) { self(self, d); self(self, n / d); return; }
            ++x0; c = (c + 1) % n;
        }
    };
    f(f, n);
    sort(all(p));
    return p;
}
```

== Cipolla
二次剩余解方程 $x^2 equiv n mod p$：
```cpp
inline i64 power_mod(i64 a, i64 b, i64 m) {
    i64 res = 1 % m; a %= m;
    for (; b; b >>= 1, a = (i64)((i128)a * a % m))
        if (b & 1) res = (i64)((i128)res * a % m);
    return res;
}

i64 cipolla(i64 n, i64 p) {
    n = (n % p + p) % p;
    if (!n) return 0;
    if (power_mod(n, (p - 1) / 2, p) != 1) return -1;
    static mt19937_64 rng(1337);
    i64 a, w2;
    loop {
        a = rng() % p;
        w2 = (a * a % p - n + p) % p;
        if (power_mod(w2, (p - 1) / 2, p) == p - 1) break;
    }
    struct Comp { i64 x, y; };
    auto mul_c = [&](Comp u, Comp v) -> Comp {
        return {
            (u.x * v.x % p + u.y * v.y % p * w2) % p,
            (u.x * v.y + u.y * v.x) % p
        };
    };
    Comp res = {1, 0}, base = {a, 1};
    i64 exp = (p + 1) / 2;
    while (exp > 0) {
        if (exp & 1) res = mul_c(res, base);
        base = mul_c(base, base);
        exp >>= 1;
    }
    return res.x;
}
```

== 组合数
静态全局数组预处理阶乘与逆元：
```cpp
constexpr i32 mod = 1e9 + 7;
constexpr i32 maxn = 200005;
i64 fac[maxn], invfac[maxn], inv[maxn];

void init_comb(i32 m = maxn - 1) {
    fac[0] = invfac[0] = inv[0] = 1;
    fac[1] = invfac[1] = inv[1] = 1;
    rep1(i, 2, m) {
        inv[i] = 1LL * (mod - mod / i) * inv[mod % i] % mod;
        fac[i] = 1LL * fac[i - 1] * i % mod;
        invfac[i] = 1LL * invfac[i - 1] * inv[i] % mod;
    }
}

i64 binom(i32 n, i32 m) {
    if (n < m || m < 0) return 0;
    return fac[n] * invfac[m] % mod * invfac[n - m] % mod;
}

i64 perm(i32 n, i32 m) {
    if (n < m || m < 0) return 0;
    return fac[n] * invfac[n - m] % mod;
}
```

== 卢卡斯定理 (Lucas)
适用于小质数模数 $p$（如 $p <= 10^5$），大 $n, m$（如 $10^(18)$）求 $binom(n, m) mod p$：
```cpp
i64 binom_small(i64 n, i64 m, i64 p) {
    if (n < m || m < 0) return 0;
    if (m == 0 || n == m) return 1;
    if (m > n - m) m = n - m;
    i64 num = 1, den = 1;
    rep(i, 0, m) {
        num = (i64)((i128)num * (n - i) % p);
        den = (i64)((i128)den * (i + 1) % p);
    }
    return (i64)((i128)num * binpow(den, p - 2, p) % p);
}

i64 lucas(i64 n, i64 m, i64 p) {
    if (m == 0) return 1;
    return (i64)((i128)binom_small(n % p, m % p, p) * lucas(n / p, m / p, p) % p);
}
```

== 卡特兰数 (Catalan)

=== 1. 核心公式与性质
- *通项公式*：
  $ C_n = frac(1, n+1) binom(2n, n) = binom(2n, n) - binom(2n, n-1) $
- *递推关系*：
  - 线性递推：$C_0 = 1,   C_n = frac(4n - 2, n + 1) C_(n-1)$
  - 卷积递推：$C_0 = 1,   C_n = sum_(i=0)^(n-1) C_i C_(n-1-i)   (n >= 1)$
- *前若干项*：$1, 1, 2, 5, 14, 42, 132, 429, 1430, 4862, 16796, dots$

=== 2. 常见组合模型速查
#table(
  columns: (auto, 1fr, auto),
  fill: (col, row) => if row == 0 { rgb("f0f2f5") } else { none },
  stroke: 0.5pt + luma(180),
  [模型名称], [问题描述], [对应结果],
  [*括号序列*], [$n$ 对左括号 `(` 和右括号 `)` 组成合法序列的方案数], [$C_n$],
  [*栈序列*], [$n$ 个不同元素按已知顺序依次入栈，出栈序列的排列数], [$C_n$],
  [*二叉树形态*], [$n$ 个节点构成的不同形态二叉树总数（或 $n+1$ 个叶子的满二叉树）], [$C_n$],
  [*多边形剖分*], [凸 $n+2$ 边形用不相交的对角线分割为三角形的方案数], [$C_n$],
  [*Dyck 路径*], [从 $(0, 0)$ 到 $(n, n)$，每步右移或上移，不穿过直线 $y = x$ 的路径数], [$C_n$],
  [*圆周不相交弦*], [圆周上 $2n$ 个互异点两两连线，线段互不相交的配对方案数], [$C_n$],
  [*广义反射容斥*], [从 $(0, 0)$ 到 $(n, m)$（$n >= m$），不越过直线 $y = x$ 的非降路径数], [$binom(n+m, m) - binom(n+m, m-1)$],
)

```cpp
// 依赖组合数 init_comb()
// 1. O(1) 单项查询 (需 2 * n < maxn)
i64 catalan(i32 n) {
    if (n < 0) return 0;
    return (binom(2 * n, n) - binom(2 * n, n - 1) + mod) % mod;
}

// 2. O(N) 线性递推预处理前 m 项 (只需 m < maxn，不依赖 2*m 阶乘)
i64 cat[maxn];
void init_catalan(i32 m = maxn - 1) {
    cat[0] = 1;
    rep1(i, 1, m) {
        cat[i] = cat[i - 1] * (4 * i - 2) % mod * inv[i + 1] % mod;
    }
}
```

== 斯特林数 (Stirling)

=== 1. 第一类斯特林数 (Stirling Numbers of the First Kind)
- *记号与组合意义*：记作 $mat(delim: "[", n; k)$ 或 $s(n, k)$，表示将 $n$ 个不同元素分成 $k$ 个非空*圆排列（环）*的方案数。
- *递推关系*：
  $ mat(delim: "[", n; k) = mat(delim: "[", n - 1; k - 1) + (n - 1) mat(delim: "[", n - 1; k) $
  *解释：新元素单独成环，或插入已有某个元素的左侧（共 $n-1$ 种插法）。*
  *边界：$mat(delim: "[", 0; 0) = 1$，$mat(delim: "[", n; 0) = 0   (n > 0)$。*
- *上升幂 / 下降幂代数性质*：
  $ x^(overline(n)) = x(x+1)dots(x+n-1) = sum_(k=0)^n mat(delim: "[", n; k) x^k $
  $ x^(underline(n)) = x(x-1)dots(x-n+1) = sum_(k=0)^n (-1)^(n-k) mat(delim: "[", n; k) x^k $
- *性质求和*：$sum_(k=0)^n mat(delim: "[", n; k) = n!$

=== 2. 第二类斯特林数 (Stirling Numbers of the Second Kind)
- *记号与组合意义*：记作 $mat(delim: "{", n; k)$ 或 $S(n, k)$，表示将 $n$ 个不同元素放入 $k$ 个*无标号（相同）非空集合*的方案数。
- *递推关系*：
  $ mat(delim: "{", n; k) = mat(delim: "{", n - 1; k - 1) + k mat(delim: "{", n - 1; k) $
  *解释：新元素自成一子集，或加入已有 $k$ 个非空子集之一。*
  *边界：$mat(delim: "{", 0; 0) = 1$，$mat(delim: "{", n; 0) = 0   (n > 0)$。*
- *通项公式（容斥原理）*：
  $ mat(delim: "{", n; k) = frac(1, k!) sum_(j=0)^k (-1)^(k-j) binom(k, j) j^n $
  *复杂度 $O(k log n)$，适合 $n$ 极大、$k$ 较小的单项快速求值。*
- *普通幂转下降幂（树/图高次幂求和核心转换）*：
  $ x^n = sum_(k=0)^n mat(delim: "{", n; k) x^(underline(k)) = sum_(k=0)^n mat(delim: "{", n; k) k! binom(x, k) $
- *贝尔数 (Bell)*：$B_n = sum_(k=0)^n mat(delim: "{", n; k)$ 表示 $n$ 个元素划分为任意个非空子集的总方案数。

=== 3. 球盒模型对应速查 (Twelvefold Way 核心部分)
#table(
  columns: (auto, auto, auto, 1fr),
  fill: (col, row) => if row == 0 { rgb("f0f2f5") } else { none },
  stroke: 0.5pt + luma(180),
  [$n$ 个球], [$k$ 个盒], [是否可空], [对应方案数 / 公式],
  [不同], [相同], [非空], [$mat(delim: "{", n; k)$],
  [不同], [不同], [非空], [$k! mat(delim: "{", n; k)$],
  [不同], [不同], [可空], [$k^n = sum_(j=0)^k binom(k, j) j! mat(delim: "{", n; j)$],
  [不同], [相同], [可空], [$sum_(j=0)^k mat(delim: "{", n; j)$（若 $k >= n$ 则为 $B_n$）],
  [相同], [不同], [非空], [$binom(n-1, k-1)$（隔板法）],
  [相同], [不同], [可空], [$binom(n+k-1, k-1)$（插板法 / 隔板法）],
)

```cpp
constexpr i32 maxs = 2005;
i64 s1[maxs][maxs]; // 第一类斯特林数 (无符号)
i64 s2[maxs][maxs]; // 第二类斯特林数

// 1. O(N^2) 递推预处理 (适用于 N <= 2000)
void init_stirling(i32 m = maxs - 1) {
    s1[0][0] = s2[0][0] = 1;
    rep1(i, 1, m) {
        s1[i][0] = s2[i][0] = 0;
        rep1(j, 1, i) {
            s1[i][j] = (s1[i - 1][j - 1] + 1LL * (i - 1) * s1[i - 1][j]) % mod;
            s2[i][j] = (s2[i - 1][j - 1] + 1LL * j * s2[i - 1][j]) % mod;
        }
    }
}

// 2. O(k log n) 容斥单项求第二类斯特林数 S(n, k) (依赖 init_comb() 与 binpow())
i64 stirling2_single(i64 n, i32 k) {
    if (k < 0 || k > n) return 0;
    if (n == 0 && k == 0) return 1;
    i64 res = 0;
    rep1(j, 0, k) {
        i64 term = binom(k, j) * binpow(j, n, mod) % mod;
        if ((k - j) & 1) res = (res - term + mod) % mod;
        else res = (res + term) % mod;
    }
    return res * invfac[k] % mod;
}
```

== 康托展开 (Cantor Expansion)
实现全排列与字典序排名（1-based，范围 $1 tilde n!$）之间的双向映射。
- *康托展开公式*：
  $ X = sum_(i=1)^n A_i times (n - i)! $
  其中 $A_i$ 表示排列中未出现过的元素中，严格小于当前元素 $a_i$ 的个数（即 $a_i$ 之后比它小的元素个数）。
  - 0-based 排名为 $X$；1-based 排名为 $X + 1$。
- *算法优化与复杂度*：
  - *康托展开*：使用树状数组动态维护可用元素，将单次查询与更新优化至 $O(log n)$，整体时间复杂度 $O(n log n)$，适用于 $n <= 10^6$ 及大模数场景。
  - *逆康托展开*：给定排名 $k$ 反推排列，依次除以 $(n - i)!$ 取商得对应排名后更新余数。因 $20! approx 2.43 times 10^(18)$，通常 $n <= 20$ 采用 64 位整数精确求解，时间复杂度 $O(n^2)$。

```cpp
// 1. 康托展开 (O(n log n)，树状数组优化，支持 n <= 1e6，模 mod)
constexpr i32 mod = 998244353;
constexpr i32 maxn = 1000005;
i32 tr[maxn];
i64 fac[maxn];

void add(i32 p, i32 v, i32 n) {
    for (i32 i = p; i <= n; i += i & -i) tr[i] += v;
}

i32 query(i32 p) {
    i32 ans = 0;
    for (i32 i = p; i > 0; i -= i & -i) ans += tr[i];
    return ans;
}

// 输入: 1 ~ n 的全排列 p (0-based 数组，值域 [1, n])
// 输出: 该排列在所有全排列中的字典序排名 (1-based，结果取模 m)
i64 cantor(const vector<i32>& p, i32 m = mod) {
    i32 n = sz(p);
    fac[0] = 1;
    rep1(i, 1, n) fac[i] = fac[i - 1] * i % m;
    rep1(i, 1, n) tr[i] = i & -i;

    i64 rank = 0;
    rep(i, 0, n) {
        i32 smaller = query(p[i] - 1);
        rank = (rank + 1LL * smaller * fac[n - 1 - i]) % m;
        add(p[i], -1, n);
    }
    return (rank + 1) % m;
}

// 2. 逆康托展开 (适用于 n <= 20，k 为 1-based 排名)
// 输入: 排列长度 n，1-based 字典序排名 k (1 <= k <= n!)
// 输出: 对应的 1 ~ n 全排列
vector<i32> decantor(i32 n, i64 k) {
    --k; // 转化为 0-based 排名
    vector<i64> f(n + 1, 1);
    rep1(i, 1, n) f[i] = f[i - 1] * i;

    vector<i32> available(n);
    iota(all(available), 1);

    vector<i32> p(n);
    rep(i, 0, n) {
        i64 cnt = f[n - 1 - i];
        i32 idx = static_cast<i32>(k / cnt);
        k %= cnt;
        p[i] = available[idx];
        available.erase(available.begin() + idx);
    }
    return p;
}
```

== 容斥原理与反演

=== 1. 核心理论与反演模型速查

==== (1) 基础容斥原理
- *并集大小（至少满足一个性质）*：
  $ abs(union_(i=1)^n A_i) = sum_(k=1)^n (-1)^(k-1) sum_(1 <= i_1 < dots < i_k <= n) abs(inter_(j=1)^k A_(i_j)) $
- *对偶形式（都不满足 / 全集补集的交集）*：
  $ abs(inter_(i=1)^n overline(A_i)) = sum_(S subset.eq \{1, dots, n\)} (-1)^(|S|) abs(inter_(j in S) A_j) $
  *口诀：奇加偶减（求并集） / 奇减偶加（求全不满足）。*

==== (2) 错排问题 (Derangement)
$n$ 个元素的全排列中，每个元素都不在原位置上的排列数 $D_n$：
- *递推式*：$D_0 = 1,   D_1 = 0,   D_n = (n - 1)(D_(n-1) + D_(n-2))   (n >= 2)$
- *通项式*：$D_n = n! sum_(k=0)^n frac((-1)^k, k!)$
- *恰好 $k$ 个在原位*：$binom(n, k) D_(n-k)$

==== (3) 二项式反演 (Binomial Inversion)
- *形式一（至多 vs 恰好）*：
  $ f(n) = sum_(i=0)^n binom(n, i) g(i) <=> g(n) = sum_(i=0)^n (-1)^(n-i) binom(n, i) f(i) $
- *形式二（至少/钦定 vs 恰好，竞赛最高频！）*：
  $ f(k) = sum_(i=k)^n binom(i, k) g(i) <=> g(k) = sum_(i=k)^n (-1)^(i-k) binom(i, k) f(i) $
  *思维模型：$f(k)$ 表示*钦定（至少）*选择 $k$ 个条件成立、其余随意搭配的方案数（极易计算）；反演后 $g(k)$ 为*恰好*有 $k$ 个条件成立的精确方案数。特别地，$g(0) = sum_(i=0)^n (-1)^i f(i)$。*

==== (4) Min-Max 容斥与期望扩展
- *集合形式*：
  $ max(S) = sum_(T subset.eq S, T != emptyset) (-1)^(|T|-1) min(T),   min(S) = sum_(T subset.eq S, T != emptyset) (-1)^(|T|-1) max(T) $
- *期望形式（全收集/全到达模型）*：
  $ bb(E)[max(S)] = sum_(T subset.eq S, T != emptyset) (-1)^(|T|-1) bb(E)[min(T)] $
  *核心优势：求解所有事件都发生的期望时间 $bb(E)[max(S)]$ 很难，但集合 $T$ 中*首个事件发生*的期望时间 $bb(E)[min(T)]$ 往往极其简单（如几何分布的 $frac(1, sum_(i in T) p_i)$）。*
- *扩展 $k$-th Min-Max 容斥（第 $k$ 大值）*：
  $ "kth-max"(S) = sum_(T subset.eq S, T != emptyset) (-1)^(|T|-k) binom(|T|-1, k-1) min(T) $

==== (5) 高维前缀和与子集反演 (SOS DP / FMT)
- *子集和与子集反演*：
  $ f(S) = sum_(T subset.eq S) g(T) <=> g(S) = sum_(T subset.eq S) (-1)^(|S| - |T|) f(T) $
- 可在 $O(n 2^n)$ 时间内用高维前缀和（SOS DP）实现快速正逆变换。

=== 2. 常见竞赛场景速查
#table(
  columns: (auto, 1fr),
  fill: (col, row) => if row == 0 { rgb("f0f2f5") } else { none },
  stroke: 0.5pt + luma(180),
  [场景模型], [核心解法思路],
  [*小集合属性限制 ($n <= 20$)*], [状压枚举子集 $"mask" in [1, 2^n-1]$，按 `__builtin_parity(mask)` 分配正负符号。],
  [*区间与 $k$ 个数互质的数的个数*], [质因数分解后，容斥求能被某些质因子整除的数的个数。],
  [*网格走步避开障碍点*], [障碍点按坐标排序后 DP，容斥掉途径至少一个障碍点的方案数。],
  [*“至少/恰好”类计数题*], [构造钦定模型求 $f(k) = binom(n, k) times dots$，再通过二项式反演得到恰好解 $g(k)$。],
  [*按位与/或卷积 (AND/OR Convolution)*], [利用 FMT（高维前缀和/后缀和）在 $O(n 2^n)$ 内快速求解。],
)

```cpp
// ----------------- 1. 错排预处理 O(N) -----------------
constexpr i32 maxn = 200005;
i64 derange[maxn];

void init_derangement(i32 m = maxn - 1) {
    derange[0] = 1; derange[1] = 0;
    rep1(i, 2, m) {
        derange[i] = 1LL * (i - 1) * (derange[i - 1] + derange[i - 2]) % mod;
    }
}

// ----------------- 2. 二项式反演 (钦定转恰好) -----------------
// 输入 f[0..n] 为 "钦定/至少 k 个" 的方案数，返回 g[0..n] 为 "恰好 k 个" 的方案数
// g[k] = sum_{i=k}^n (-1)^{i-k} * binom(i, k) * f[i]  (需提前调用 init_comb())
vector<i64> binomial_inversion_at_least(const vector<i64>& f) {
    i32 n = sz(f) - 1;
    vector<i64> g(n + 1, 0);
    rep1(k, 0, n) {
        i64 sum = 0;
        rep1(i, k, n) {
            i64 term = binom(i, k) * f[i] % mod;
            if ((i - k) & 1) sum = (sum - term + mod) % mod;
            else sum = (sum + term) % mod;
        }
        g[k] = sum;
    }
    return g;
}

// ----------------- 3. 基础状压容斥范式 -----------------
// 示例：求 1 ~ M 中与 n 个质数集合 primes 全互质的数的个数
i64 count_coprime(i64 m, const vector<i64>& primes) {
    i32 k = sz(primes);
    i64 bad = 0;
    // 枚举非空子集
    rep(mask, 1, 1 << k) {
        i64 prod = 1;
        i32 bits = 0;
        rep(i, 0, k) {
            if (mask & (1 << i)) {
                ++bits;
                if ((f128)prod * primes[i] > m) { prod = m + 1; break; }
                prod *= primes[i];
            }
        }
        if (prod > m) continue;
        i64 cnt = m / prod;
        if (bits & 1) bad += cnt;
        else bad -= cnt;
    }
    return m - bad;
}

// ----------------- 4. 高维前缀和与子集反演 (SOS DP / FMT) -----------------
// 集合大小为 n (状态数 2^n)，O(n * 2^n) 复杂度

// 正变换 (子集和): a[mask] = sum_{sub \subseteq mask} f[sub]
void sos_prefix_sum(vector<i64>& a, i32 n) {
    rep(i, 0, n) {
        rep(mask, 0, 1 << n) {
            if (mask & (1 << i)) {
                a[mask] = (a[mask] + a[mask ^ (1 << i)]) % mod;
            }
        }
    }
}

// 逆变换 (子集容斥反演): 从子集和还原出原值 f[mask]
void sos_subset_diff(vector<i64>& a, i32 n) {
    rep(i, 0, n) {
        rep(mask, 0, 1 << n) {
            if (mask & (1 << i)) {
                a[mask] = (a[mask] - a[mask ^ (1 << i)] + mod) % mod;
            }
        }
    }
}
```

== 线性基
静态全局数组，无类封装：
```cpp
constexpr i32 b = 62;
i64 p[b + 1], d[b + 1];
i32 cnt;
bool flag;

void reset() {
    fill(p, p + b + 1, 0);
    fill(d, d + b + 1, 0);
    cnt = 0; flag = false;
}

bool insert(i64 val) {
    for (i32 i = b; i >= 0; --i) {
        if (!(val >> i & 1)) continue;
        if (!p[i]) { p[i] = val; ++cnt; return true; }
        val ^= p[i];
    }
    flag = true;
    return false;
}

bool check(i64 val) {
    for (i32 i = b; i >= 0; --i) {
        if (val >> i & 1) {
            if (!p[i]) return false;
            val ^= p[i];
        }
    }
    return true;
}

i64 query_max(i64 res = 0) {
    for (i32 i = b; i >= 0; --i) res = max(res, res ^ p[i]);
    return res;
}

i64 query_min() {
    if (flag) return 0;
    rep1(i, 0, b) if (p[i]) return p[i];
    return 0;
}

void rebuild() {
    cnt = 0;
    rep1(i, 0, b) d[i] = p[i];
    for (i32 i = b; i >= 0; --i) {
        if (!d[i]) continue;
        for (i32 j = i - 1; j >= 0; --j)
            if (d[i] >> j & 1) d[i] ^= d[j];
    }
    rep1(i, 0, b) if (d[i]) d[cnt++] = d[i];
}

i64 query_kth(i64 k) {
    if (flag) --k;
    if (k == 0) return 0;
    if (k >= (1LL << cnt)) return -1;
    i64 ans = 0;
    rep(i, 0, cnt) if (k >> i & 1) ans ^= d[i];
    return ans;
}
```

= 计算几何

== 二维几何基础 (点、向量、线与线段)
浮点精度误差和退化边界（三点共线、向量重合、直线平行）是计算几何的核心难点。
- *浮点比较*：引入阈值 $"eps" = 10^(-9)$，统一使用 `sign` 与 `cmp` 进行大小和符号判定。
- *叉积意义*：二维叉积 $bold(a) times bold(b) = x_a y_b - x_b y_a$。若 $> 0$ 则 $bold(b)$ 在 $bold(a)$ 逆时针方向（左侧）；若 $< 0$ 在顺时针方向（右侧）；若 $= 0$ 则两向量共线。
- *线段相交*：必须同时通过*快速排斥实验*（两线段坐标投影构成的轴对齐外包矩形相交）和*跨立实验*（相互跨立判定，双向叉积异号或为 0）。

```cpp
constexpr f64 eps = 1e-9;
constexpr f64 pi = acos(-1.0);

inline i32 sign(f64 x) {
    if (fabs(x) < eps) return 0;
    return x < 0 ? -1 : 1;
}

inline i32 cmp(f64 x, f64 y) {
    return sign(x - y);
}

struct Point {
    f64 x, y;
    Point(f64 x = 0, f64 y = 0) : x(x), y(y) {}

    Point operator+(const Point& p) const { return Point(x + p.x, y + p.y); }
    Point operator-(const Point& p) const { return Point(x - p.x, y - p.y); }
    Point operator*(f64 k) const { return Point(x * k, y * k); }
    Point operator/(f64 k) const { return Point(x / k, y / k); }

    bool operator==(const Point& p) const {
        return cmp(x, p.x) == 0 && cmp(y, p.y) == 0;
    }
    bool operator<(const Point& p) const {
        i32 c = cmp(x, p.x);
        return c != 0 ? c < 0 : cmp(y, p.y) < 0;
    }

    f64 dot(const Point& p) const { return x * p.x + y * p.y; }
    f64 cross(const Point& p) const { return x * p.y - y * p.x; }
    f64 abs2() const { return dot(*this); }
    f64 abs() const { return std::sqrt(abs2()); }
    f64 arg() const { return std::atan2(y, x); }

    // 逆时针旋转 rad 弧度
    Point rotate(f64 rad) const {
        return Point(x * cos(rad) - y * sin(rad), x * sin(rad) + y * cos(rad));
    }
    // 逆时针旋转 90 度
    Point rot90() const { return Point(-y, x); }
    // 单位向量 (确保非零)
    Point unit() const { return *this / abs(); }
};
using Vector = Point;

// 点在有向直线 ab 的位置: > 0 在左侧, < 0 在右侧, = 0 共线
inline i32 to_left(const Point& a, const Point& b, const Point& p) {
    return sign((b - a).cross(p - a));
}

// 点 p 到直线 ab 的投影点 (垂足)
inline Point project(const Point& p, const Point& a, const Point& b) {
    Vector v = b - a;
    return a + v * (v.dot(p - a) / v.abs2());
}

// 点 p 关于直线 ab 的轴对称点
inline Point reflect(const Point& p, const Point& a, const Point& b) {
    return project(p, a, b) * 2.0 - p;
}

// 判断点 p 是否在线段 ab 上 (含端点)
inline bool on_segment(const Point& p, const Point& a, const Point& b) {
    return sign((p - a).cross(b - a)) == 0 && sign((p - a).dot(p - b)) <= 0;
}

// 点 p 到直线 ab 的距离
inline f64 dist_to_line(const Point& p, const Point& a, const Point& b) {
    return fabs((b - a).cross(p - a)) / (b - a).abs();
}

// 点 p 到线段 ab 的最短距离
inline f64 dist_to_segment(const Point& p, const Point& a, const Point& b) {
    if (sign((p - a).dot(b - a)) < 0) return (p - a).abs();
    if (sign((p - b).dot(a - b)) < 0) return (p - b).abs();
    return dist_to_line(p, a, b);
}

// 直线定义: 点向式 p + t * v
struct Line {
    Point p;
    Vector v;
    Line() {}
    Line(Point p, Vector v) : p(p), v(v) {}
    Line(Point a, Point b, bool is_two_pts) : p(a), v(b - a) { (void)is_two_pts; }

    Point eval(f64 t) const { return p + v * t; }
};

// 两直线交点 (需满足两直线不平行，即 sign(a.v.cross(b.v)) != 0)
inline Point line_intersection(const Line& a, const Line& b) {
    f64 t = (b.p - a.p).cross(b.v) / a.v.cross(b.v);
    return a.eval(t);
}

// 两线段 a-b 与 c-d 是否相交 (包含端点重合或相交)
inline bool segment_intersection(const Point& a, const Point& b, const Point& c, const Point& d) {
    // 快速排斥实验 (Bounding Box 快速剔除)
    if (max(a.x, b.x) < min(c.x, d.x) || max(c.x, d.x) < min(a.x, b.x) ||
        max(a.y, b.y) < min(c.y, d.y) || max(c.y, d.y) < min(a.y, b.y)) {
        return false;
    }
    // 跨立实验
    return sign((b - a).cross(c - a)) * sign((b - a).cross(d - a)) <= 0 &&
           sign((d - c).cross(a - c)) * sign((d - c).cross(b - c)) <= 0;
}

// 两线段 a-b 与 c-d 的最短空间距离
inline f64 segment_dist(const Point& a, const Point& b, const Point& c, const Point& d) {
    if (segment_intersection(a, b, c, d)) return 0.0;
    return min({dist_to_segment(a, c, d), dist_to_segment(b, c, d),
                dist_to_segment(c, a, b), dist_to_segment(d, a, b)});
}
```

== 多边形与凸包 (Polygon & Convex Hull)
- *多边形面积与重心*：任意简单多边形均可剖分为若干以原点为顶点的有向三角形，利用叉积代数和求解面积与重心。
- *点与多边形关系 (射线法)*：从待查点引向水平向右的射线，统计与各边的交点次数；奇数在内、偶数在外。需注意点在边上及射线穿过多边形顶点的边界处理。
- *二维凸包 (Andrew 算法)*：Graham 扫描法的排序改进版，按坐标 $(x, y)$ 排序后分别利用单调栈扫描下凸壳与上凸壳，时间复杂度稳定 $O(n log n)$。
- *点在凸多边形内判定 (二分法)*：以 $P[0]$ 为极点，二分待查点落在哪两个相邻顶点张成的角内，仅需一次叉积判断，将单次查询复杂度优化至 $O(log n)$。

```cpp
using Polygon = vector<Point>;

// 多边形有向面积 (逆时针排列为正，顺时针排列为负)
inline f64 polygon_area(const Polygon& poly) {
    f64 res = 0;
    i32 n = sz(poly);
    rep(i, 0, n) {
        res += poly[i].cross(poly[(i + 1) % n]);
    }
    return res / 2.0;
}

// 多边形重心
inline Point polygon_centroid(const Polygon& poly) {
    Point c(0, 0);
    f64 total_area = 0;
    i32 n = sz(poly);
    rep(i, 0, n) {
        f64 a = poly[i].cross(poly[(i + 1) % n]);
        total_area += a;
        c = c + (poly[i] + poly[(i + 1) % n]) * a;
    }
    return c / (total_area * 3.0);
}

// 射线法判定点与简单多边形位置: 2 严格内部, 1 边界上, 0 外部
inline i32 point_in_polygon(const Point& p, const Polygon& poly) {
    i32 n = sz(poly);
    bool inside = false;
    rep(i, 0, n) {
        Point a = poly[i], b = poly[(i + 1) % n];
        if (on_segment(p, a, b)) return 1;
        if (a.y > b.y) swap(a, b);
        if (p.y > a.y && p.y <= b.y && sign((b - a).cross(p - a)) > 0) {
            inside = !inside;
        }
    }
    return inside ? 2 : 0;
}

// Andrew 算法求凸包: 逆时针输出顶点序列
// strict = true: 严格凸包 (边上不含共线点); strict = false: 允许包含边上的共线点
inline Polygon convex_hull(Polygon pts, bool strict = true) {
    i32 n = sz(pts);
    if (n <= 1) return pts;
    sort(all(pts));
    pts.erase(unique(all(pts)), pts.end());
    n = sz(pts);
    if (n <= 2) return pts;

    Polygon hull(2 * n);
    i32 k = 0;
    // 构建下凸壳
    rep(i, 0, n) {
        while (k >= 2) {
            f64 cp = (hull[k - 1] - hull[k - 2]).cross(pts[i] - hull[k - 1]);
            if (strict ? cp <= eps : cp < -eps) --k;
            else break;
        }
        hull[k++] = pts[i];
    }
    // 构建上凸壳
    i32 t = k + 1;
    for (i32 i = n - 2; i >= 0; --i) {
        while (k >= t) {
            f64 cp = (hull[k - 1] - hull[k - 2]).cross(pts[i] - hull[k - 1]);
            if (strict ? cp <= eps : cp < -eps) --k;
            else break;
        }
        hull[k++] = pts[i];
    }
    hull.resize(k - 1); // 弹出末尾与起点重复的闭合点
    return hull;
}

// 二分法在 O(log n) 内判定点是否在严格凸多边形内 (需按逆时针排列)
// 返回: 2 严格内部, 1 边界上, 0 外部
inline i32 point_in_convex(const Point& p, const Polygon& poly) {
    i32 n = sz(poly);
    if (n < 3) return 0;
    f64 c1 = (poly[1] - poly[0]).cross(p - poly[0]);
    f64 c2 = (poly[n - 1] - poly[0]).cross(p - poly[0]);
    if (sign(c1) < 0 || sign(c2) > 0) return 0;
    if (sign(c1) == 0 && on_segment(p, poly[0], poly[1])) return 1;
    if (sign(c2) == 0 && on_segment(p, poly[0], poly[n - 1])) return 1;

    i32 l = 1, r = n - 2, idx = 1;
    while (l <= r) {
        i32 mid = l + (r - l) / 2;
        if (sign((poly[mid] - poly[0]).cross(p - poly[0])) >= 0) {
            idx = mid;
            l = mid + 1;
        } else {
            r = mid - 1;
        }
    }
    f64 cp = (poly[idx + 1] - poly[idx]).cross(p - poly[idx]);
    i32 s = sign(cp);
    if (s > 0) return 2;
    if (s == 0) return on_segment(p, poly[idx], poly[idx + 1]) ? 1 : 0;
    return 0;
}
```

== 旋转卡壳与 Minkowski 和 (Rotating Calipers & Minkowski Sum)
- *旋转卡壳 (Rotating Calipers)*：利用凸多边形的对踵点对（Antipodal Pairs）单调移动性质。当一条底边在凸包上按逆时针逆行时，对踵顶点的距离/面积呈现单峰性质，可在 $O(n)$ 时间内完成凸包直径、最小外接矩形求解。
- *凸包直径*：求凸包上点对的最大距离平方，避免开方误差。
- *最小外接矩形*：卡壳同时维护顶端点（高度最大）、右端点（沿边投影最远）、左端点（投影最近），四条切线锁定外包矩形。
- *Minkowski 和*：两个凸多边形 $A, B$ 的点集和 $A + B = \{a + b \mid a in A, b in B\}$。几何上可将 $A$ 与 $B$ 的所有边向量按极角排序归并得到新的凸包，复杂度 $O(|A| + |B|)$。常用于判定两多边形碰撞：$A, B$ 相交等价于 $A - B$ 包含原点。

```cpp
// 旋转卡壳求凸包直径 (最远点对距离的平方)，要求凸包逆时针严格排列且 n >= 2
inline f64 rotating_calipers_diameter(const Polygon& hull) {
    i32 n = sz(hull);
    if (n == 2) return (hull[0] - hull[1]).abs2();
    f64 max_d2 = 0;
    i32 j = 2;
    rep(i, 0, n) {
        Point a = hull[i], b = hull[(i + 1) % n];
        while ((b - a).cross(hull[(j + 1) % n] - a) > (b - a).cross(hull[j] - a)) {
            j = (j + 1) % n;
        }
        max_d2 = max({max_d2, (hull[j] - a).abs2(), (hull[j] - b).abs2()});
    }
    return max_d2;
}

// 旋转卡壳求凸多边形最小外接矩形 (返回 {最小面积, 最小周长})
inline pair<f64, f64> min_enclosing_rectangle(const Polygon& hull) {
    i32 n = sz(hull);
    if (n <= 2) return {0, 0};
    f64 min_area = numeric_limits<f64>::max();
    f64 min_peri = numeric_limits<f64>::max();
    i32 t = 1, r = 1, l = 1;

    rep(i, 0, n) {
        Point a = hull[i], b = hull[(i + 1) % n];
        Vector edge = b - a;
        f64 edge_len = edge.abs();

        // 顶端点: 叉积最大 (高度最高)
        while ((b - a).cross(hull[(t + 1) % n] - a) >= (b - a).cross(hull[t] - a) - eps) {
            t = (t + 1) % n;
            if (t == (i + 1) % n) break;
        }
        // 右端点: 点积最大 (沿底边投影最远)
        while (edge.dot(hull[(r + 1) % n] - a) >= edge.dot(hull[r] - a) - eps) {
            r = (r + 1) % n;
            if (r == (i + 1) % n) break;
        }
        // 左端点: 反向点积最大 (沿底边投影最近)
        while ((a - b).dot(hull[(l + 1) % n] - a) >= (a - b).dot(hull[l] - a) - eps) {
            l = (l + 1) % n;
            if (l == (i + 1) % n) break;
        }

        f64 h = fabs((b - a).cross(hull[t] - a)) / edge_len;
        f64 w = (edge.dot(hull[r] - a) - edge.dot(hull[l] - a)) / edge_len;
        if (w > eps && h > eps) {
            min_area = min(min_area, w * h);
            min_peri = min(min_peri, 2.0 * (w + h));
        }
    }
    return {min_area, min_peri};
}

// 凸多边形 Minkowski 和: 归并边向量 O(|A| + |B|)
// 输入: 两个逆时针严格凸包 (sz >= 3)
// 输出: Minkowski 和生成的凸包顶点 (逆时针排列)
inline Polygon minkowski_sum(Polygon A, Polygon B) {
    i32 n = sz(A), m = sz(B);
    if (n < 3 || m < 3) return {};

    // 旋转至以最左下角为起点
    auto reorder = [](Polygon& poly) {
        i32 p = 0;
        rep(i, 1, sz(poly)) {
            if (poly[i].y < poly[p].y || (poly[i].y == poly[p].y && poly[i].x < poly[p].x)) {
                p = i;
            }
        }
        rotate(poly.begin(), poly.begin() + p, poly.end());
    };
    reorder(A);
    reorder(B);

    vector<Vector> e1(n), e2(m);
    rep(i, 0, n) e1[i] = A[(i + 1) % n] - A[i];
    rep(i, 0, m) e2[i] = B[(i + 1) % m] - B[i];

    Polygon res;
    res.push_back(A[0] + B[0]);
    i32 i = 0, j = 0;
    while (i < n && j < m) {
        f64 cp = e1[i].cross(e2[j]);
        if (cp > eps) {
            res.push_back(res.back() + e1[i++]);
        } else if (cp < -eps) {
            res.push_back(res.back() + e2[j++]);
        } else {
            res.push_back(res.back() + e1[i++] + e2[j++]);
        }
    }
    while (i < n) res.push_back(res.back() + e1[i++]);
    while (j < m) res.push_back(res.back() + e2[j++]);
    res.pop_back(); // 移除首尾重合点
    return res;
}
```



= Tricks
== 对拍
```bash
cnt=0
g++ -O2 -std=c++20  -g gen.cpp -o gen || exit 1
g++ -O2 -std=c++20  -g std.cpp -o std || exit 1
g++ -O2 -std=c++20 -fsanitize=address,undefined -fno-sanitize-recover=all -g sol.cpp -o sol || exit 1
while true; do
	cnt=$((cnt+1))
	./gen > in.txt
	./std < in.txt > std.out
	timeout 1.0s ./sol < in.txt > sol.out
	exit_code=$?
	if [ $exit_code -eq 124 ]; then
		printf "TLE on Test #%d \n" "$cnt"
		break
	fi
	if [ $exit_code -ne 0 ]; then
		printf "RE on Test #%d \n" "$cnt"
		break
	fi
	if ! diff -w -B std.out sol.out > diff.log; then
		printf "WA on Test #%d \n" "$cnt"
		break
	fi
	printf "Test #%d AC \n" "$cnt"
done
```

== 二进制操作与位运算技巧 (C++20 `<bit>` & GCC Builtins)
*`__builtin_clz(0)` 和 `__builtin_ctz(0)` 是未定义行为*。

=== 常用位运算函数速查表
#table(
  columns: (auto, auto, auto, 1fr),
  fill: (col, row) => if row == 0 { rgb("f0f2f5") } else { none },
  stroke: 0.5pt + luma(180),
  [操作功能], [C++20 `<bit>`], [GCC Builtin], [说明与边界行为],
  [计算 1 的个数], [`popcount(x)`], [`__builtin_popcount(x)` / `ll`], [统计二进制中置 1 的位数],
  [前导 0 个数 (clz)], [`countl_zero(x)`], [`__builtin_clz(x)` / `ll`], [`<bit>` 在 $x=0$ 时返回位数 (32/64)；GCC 在 $x=0$ 为 *UB*],
  [末尾 0 个数 (ctz)], [`countr_zero(x)`], [`__builtin_ctz(x)` / `ll`], [`<bit>` 在 $x=0$ 时返回位数 (32/64)；GCC 在 $x=0$ 为 *UB*],
  [前导 1 个数], [`countl_one(x)`], [-], [从最高位开始连续 1 的个数],
  [末尾 1 个数], [`countr_one(x)`], [-], [从最低位开始连续 1 的个数],
  [最小所需二进制位数], [`bit_width(x)`], [-], [即 $floor(log_2 x) + 1$，$x=0$ 时安全返回 0],
  [判断是否为 2 的幂], [`has_single_bit(x)`], [-], [等价于 `x > 0 && (x & (x - 1)) == 0`],
  [向上取最近 2 的幂], [`bit_ceil(x)`], [-], [满足 $>= x$ 的最小 2 的幂（注意避免越界）],
  [向下取最近 2 的幂], [`bit_floor(x)`], [-], [满足 $<= x$ 的最大 2 的幂],
  [循环左移 / 循环右移], [`rotl(x, s)` / `rotr(x, s)`], [-], [将无符号整数 $x$ 循环移位 $s$ 位],
  [奇偶校验 (Parity)], [-], [`__builtin_parity(x)` / `ll`], [1 的个数模 2 的值（奇数返回 1，偶数返回 0）],
  [首个 1 的位置], [-], [`__builtin_ffs(x)` / `ll`], [1-based 返回最低位 1 的序号；$x=0$ 时返回 0],
)

=== 高频位运算技巧与集合遍历
```cpp
// 1. 基础位操作宏/函数
template <typename T> constexpr T lowbit(T x) { return x & -x; }
template <typename T> constexpr T clear_lowbit(T x) { return x & (x - 1); }
template <typename T> constexpr T highbit(T x) { return x ? (T(1) << (bit_width(x) - 1)) : 0; }

// 2. 枚举子掩码：高效遍历集合 mask 的所有非空子集 (遍历所有集合子集总复杂度为 O(3^n))
void iterate_submasks(i32 mask) {
    for (i32 sub = mask; sub; sub = (sub - 1) & mask) {
        // 处理子集 sub
    }
}

// 3. 枚举超掩码：高效遍历包含 mask 的所有超集 (至多到全集 (1 << n) - 1)
void iterate_supermasks(i32 mask, i32 n) {
    for (i32 sup = mask; sup < (1 << n); sup = (sup + 1) | mask) {
        // 处理超集 sup
    }
}

// 4. Gosper's Hack: 按字典序枚举所有大小恰为 k 的 n 位子集 (复杂度 O(C(n, k)))
void gospers_hack(i32 n, i32 k) {
    if (k <= 0 || k > n) return;
    i32 cur = (1 << k) - 1;
    while (cur < (1 << n)) {
        // 处理当前大小为 k 的子集 cur
        i32 lb = cur & -cur;
        i32 r = cur + lb;
        cur = (((r ^ cur) >> 2) / lb) | r;
    }
}
```

== 标准库与 GCC 常用函数 (STL Utilities & Pragmas)

- *GCC 指令 (Pragmas)*：
  ```cpp
  #pragma GCC optimize("O3,unroll-loops")
  #pragma GCC target("avx2,bmi,bmi2,lzcnt,popcnt")
  ```
- *GCC 内置安全溢出检测*：
  `__builtin_add_overflow(a, b, &res)` 与 `__builtin_mul_overflow(a, b, &res)`：返回布尔值指示是否发生有符号/无符号整数溢出。
- *`<algorithm>` & `<numeric>` 核心函数*：
  - `nth_element(first, nth, last)`：$O(n)$ 线性时间将第 $k$ 小的元素置于 `nth` 位置，求中位数/快速划分神器。
  - `lower_bound` / `upper_bound`：二分查找首个 $>=$ 或 $>$ 目标值的迭代器位置。
  - `next_permutation` / `prev_permutation`：按字典序生成全排列。
  - `std::iota(first, last, val)`：顺序递增填充，常用于并查集 `iota(fa, fa + n, 0)` 或排列下标初始化。
  - `std::gcd` / `std::lcm`：C++17 引入，编译期 `constexpr` 求最大公约数与最小公倍数。
  - `std::clamp(val, lo, hi)`：C++17，数值区间限幅截断（等价于 `max(lo, min(val, hi))`）。
  - `std::rotate(first, middle, last)`：区间循环移位，将 `[middle, last)` 整体旋转至最前。
  - `std::shuffle(all(v), rng)`：真随机打乱序列（替代弃用的 `random_shuffle`）。

```cpp
void stl_and_builtins_demo() {
    // 1. 快速防溢出乘法检测
    i64 x = 1e12, y = 1e12, prod = 0;
    if (__builtin_mul_overflow(x, y, &prod)) {
        // 乘法溢出分支处理
    }

    // 2. 离散化与二分排名
    vector<i32> raw = {40, 10, 20, 10, 30};
    sort(all(raw));
    raw.erase(unique(all(raw)), raw.end());             // [10, 20, 30, 40]
    i32 rnk = lower_bound(all(raw), 20) - raw.begin();  // 1 (0-based)

    // 3. O(n) 中位数 / 第 k 小快速划分
    vector<i32> a = {9, 1, 8, 2, 7, 3, 6, 4, 5};
    nth_element(a.begin(), a.begin() + 4, a.end());     // a[4] 即为第 5 小元素 (5)

    // 4. 并查集 / 序列快速递增填充
    vector<i32> p(10);
    iota(all(p), 0); // p = [0, 1, 2, ..., 9]

    // 5. 范围限幅截断 clamp 与数论 gcd/lcm
    i32 val = clamp(15, 0, 10);   // 10
    i64 g = std::gcd(24LL, 36LL); // 12
    i64 l = std::lcm(24LL, 36LL); // 72
}
```

== DFS 栈模拟
```cpp
constexpr i32 maxn = 100005;
vector<i32> adj[maxn];
i32 sz_arr[maxn];

#define BEGIN_STACK_DFS(FrameType) \
    vector<FrameType> _st; \
    auto _push = [&](auto&&... args) { _st.push_back({args..., 0}); }; \
    _push

#define RUN_STACK_DFS() \
    while (!_st.empty()) { \
        auto& _frame = _st.back(); \
        switch (_frame.stage) { \
            case 0:

#define CALL_DFS(...) \
                _frame.stage = __LINE__; \
                _push(__VA_ARGS__); \
                break; \
            case __LINE__:;

#define END_STACK_DFS() \
        } \
        _st.pop_back(); \
    }

void dfs_stack(i32 root) {
    struct Frame {
        i32 u, p;
        i32 i;
        i32 stage;
    };
    i32 v;
    BEGIN_STACK_DFS(Frame)(root, -1, 0);
    RUN_STACK_DFS() {
        sz_arr[_frame.u] = 1;
        for (_frame.i = 0; _frame.i < sz(adj[_frame.u]); ++_frame.i) {
            v = adj[_frame.u][_frame.i];
            if (v != _frame.p) {
                CALL_DFS(v, _frame.u, 0);
                sz_arr[_frame.u] += sz_arr[v];
            }
        }
    } END_STACK_DFS();
}
```

== pb_ds
引自 [https://www.cnblogs.com/ofnoname/p/18958700](https://www.cnblogs.com/ofnoname/p/18958700)

=== 关联容器
```cpp
#include <ext/pb_ds/assoc_container.hpp>
using namespace __gnu_pbds;

void demo_hash() {
    // 探测式哈希表 (缓存友好)
    gp_hash_table<string, i32> gp_map;
    gp_map["algorithm"] = 97;
    auto it = gp_map.find("algorithm");

    // 链式哈希表 (高冲突稳定)
    cc_hash_table<i32, string> cc_map;
    cc_map[42] = "answer";
    cout << cc_map[42];
}
```

=== 有序容器 (平衡树)
```cpp
#include <ext/pb_ds/assoc_container.hpp>
#include <ext/pb_ds/tree_policy.hpp>
using namespace __gnu_pbds;

// 支持名次查询的红黑树
using indexed_set = tree<i32, null_type, less<i32>, rb_tree_tag, tree_order_statistics_node_update>;

void demo_tree() {
    indexed_set rb_tree;
    rb_tree.insert(10);
    rb_tree.insert(20);
    rb_tree.insert(30);

    // 查询名次 (小于 15 的元素数量)
    cout << rb_tree.order_of_key(15);  // 输出 1

    // 查询第 k 小元素 (0-based)
    auto it = rb_tree.find_by_order(2); 
    cout << *it;  // 输出 30
}
```

=== 优先队列 (可并堆)
```cpp
#include <ext/pb_ds/priority_queue.hpp>
using namespace __gnu_pbds;

// 配对堆
using heap = __gnu_pbds::priority_queue<i32, less<i32>, pairing_heap_tag>;

void demo_heap() {
    heap pq;
    auto it = pq.push(10);
    pq.push(20);
    pq.push(5);

    // 修改元素值
    pq.modify(it, 25);

    // O(1) 合并两个堆
    heap pq2;
    pq2.push(30);
    pq.join(pq2);
}
```

=== 字典树
```cpp
#include <ext/pb_ds/assoc_container.hpp>
#include <ext/pb_ds/trie_policy.hpp>
using namespace __gnu_pbds;

using string_trie = trie<string, null_type, trie_string_access_traits<>, pat_trie_tag, trie_prefix_search_node_update>;

void demo_trie() {
    string_trie t;
    t.insert("hello");
    t.insert("world");
    t.insert("hell");

    // 前缀查询：返回匹配前缀的范围迭代器 [first, second)
    auto range = t.prefix_range("he");
    for (auto it = range.first; it != range.second; ++it)
        cout << *it << " ";
}
```

=== 自定义哈希与节点策略
```cpp
#include <ext/pb_ds/assoc_container.hpp>
#include <ext/pb_ds/tree_policy.hpp>
using namespace __gnu_pbds;

struct custom_hash {
    u64 operator()(const string& s) const {
        u64 h = 0;
        rep(i, 0, sz(s)) h = h * 131 + s[i];
        return h;
    }
};

// 节点更新策略：记录子树大小
template<class Node_CItr, class Node_Itr, class Cmp_Fn, class _Alloc>
struct node_statistics {
    typedef u64 metadata_type;
    void operator()(Node_Itr it, Node_CItr end_it) {
        auto l = it.get_l_child();
        auto r = it.get_r_child();
        u64 sz = 1;
        if (l != end_it) sz += l.get_metadata();
        if (r != end_it) sz += r.get_metadata();
        const_cast<u64&>(it.get_metadata()) = sz;
    }
};

using size_aware_tree = tree<i32, null_type, less<i32>, rb_tree_tag, node_statistics>;

void demo_custom() {
    gp_hash_table<string, i32, custom_hash> custom_map;
    custom_map["test"] = 1;

    size_aware_tree tr;
    tr.insert(10);
}
```

== 程序计时 (Timer & Time Limiting)
- *高精度计时器*：基于现代 C++ `std::chrono::steady_clock`（单调递增，纳秒精度，不受系统改表影响）。提供 RAII 风格作用域计时器，析构时自动输出耗时（ms）。
- *算法卡时 (Time Limiting)*：在模拟退火、随机化算法或暴搜中，设定时间阈值（如 $0.95$ 秒）尽可能多地执行迭代。相比 `clock()`，`chrono::steady_clock` 在各大评测机与跨平台环境下具有更稳定的行为。

```cpp
// 1. RAII 高精度计时器 (可测量局部函数/代码块运行时间)
struct Timer {
    string name;
    chrono::steady_clock::time_point start;
    Timer(string_view s = "") : name(s), start(chrono::steady_clock::now()) {}
    f64 elapsed_ms() const {
        auto now = chrono::steady_clock::now();
        return chrono::duration<f64, milli>(now - start).count();
    }
    ~Timer() {
        if (!name.empty()) {
            cerr << "[" << name << "] " << elapsed_ms() << " ms\n";
        }
    }
};

// 2. 模拟退火 / 随机化卡时范式 (以 0.95s 为阈值)
void time_limit_demo() {
    auto start_time = chrono::steady_clock::now();
    auto time_left = [&]() {
        auto now = chrono::steady_clock::now();
        return chrono::duration<f64>(now - start_time).count() < 0.95;
    };

    while (time_left()) {
        // 执行模拟退火的一轮降温或随机爬山迭代
    }
}
```

== 随机数据生成与对拍框架 (Data Generator & Stress Testing)
提供基于 `mt19937_64` 的完整随机数据生成器与跨平台对拍脚本。

```cpp
// 1. 随机数据生成封装类
struct Random {
    mt19937_64 rng;
    Random() : rng(chrono::steady_clock::now().time_since_epoch().count()) {}

    // 随机整数 [l, r]
    i64 next_int(i64 l, i64 r) {
        return uniform_int_distribution<i64>(l, r)(rng);
    }

    // 随机浮点数 [l, r]
    f64 next_real(f64 l, f64 r) {
        return uniform_real_distribution<f64>(l, r)(rng);
    }

    // 随机排列 [1, n]
    vector<i32> next_permutation(i32 n) {
        vector<i32> p(n);
        iota(all(p), 1);
        shuffle(all(p), rng);
        return p;
    }

    // 随机区间 [l, r] 满足 bound_l <= l <= r <= bound_r
    pair<i64, i64> next_interval(i64 bound_l, i64 bound_r) {
        i64 x = next_int(bound_l, bound_r);
        i64 y = next_int(bound_l, bound_r);
        return {min(x, y), max(x, y)};
    }

    // 随机生成一棵树 (返回 1-based 边集，节点标号全随机打乱)
    // k_chain 用于控制树形态：k_chain = 1 为纯链，k_chain >= n 为随机均匀树
    vector<pair<i32, i32>> next_tree(i32 n, i32 k_chain = 1000000) {
        vector<pair<i32, i32>> edges;
        auto perm = next_permutation(n);
        rep1(i, 2, n) {
            i32 l = max(1, i - k_chain);
            i32 p = next_int(l, i - 1);
            i32 u = perm[i - 1], v = perm[p - 1];
            if (next_int(0, 1)) swap(u, v);
            edges.push_back({u, v});
        }
        shuffle(all(edges), rng);
        return edges;
    }

    // 随机连通无向简单图 (n 个点, m 条边, 边权范围 [w_l, w_r], 无重边自环)
    vector<tuple<i32, i32, i64>> next_graph(i32 n, i32 m, i64 w_l = 1, i64 w_r = 100) {
        if (m < n - 1 || m > 1LL * n * (n - 1) / 2) return {};
        auto tree_edges = next_tree(n);
        set<pair<i32, i32>> exist;
        vector<tuple<i32, i32, i64>> res;
        for (auto& [u, v] : tree_edges) {
            if (u > v) swap(u, v);
            exist.insert({u, v});
            res.push_back({u, v, next_int(w_l, w_r)});
        }
        while (sz(res) < m) {
            i32 u = next_int(1, n), v = next_int(1, n);
            if (u == v) continue;
            if (u > v) swap(u, v);
            if (exist.insert({u, v}).second) {
                res.push_back({u, v, next_int(w_l, w_r)});
            }
        }
        shuffle(all(res), rng);
        return res;
    }
} rnd;
```

=== 对拍框架 (C++ 内置对拍 / 跨平台 Shell)
- *C++ 内置对拍循环*：
```cpp
// duipai.cpp: 将 gen, sol, std 编译为可执行文件后直接运行
int main() {
    for (i32 test = 1; test <= 1000; ++test) {
        system("gen.exe > in.txt");
        system("sol.exe < in.txt > out.txt");
        system("std.exe < in.txt > ans.txt");
        // Windows 使用 fc，Linux/macOS 改为 diff -b out.txt ans.txt
        if (system("fc out.txt ans.txt > nul")) {
            cout << "Wrong Answer on test " << test << "!\n";
            break;
        }
        cout << "Accepted on test " << test << "\n";
    }
    return 0;
}
```
- *PowerShell / Bash 对拍单行命令*：
  - Windows PowerShell:
    ```powershell
    for ($i=1; $i -le 1000; $i++) { .\gen > in.txt; .\sol < in.txt > out.txt; .\std < in.txt > ans.txt; if (Compare-Object (Get-Content out.txt) (Get-Content ans.txt)) { Write-Host "WA on $i"; break } else { Write-Host "AC on $i" } }
    ```
  - Linux / macOS Bash:
    ```bash
    for ((i=1;i<=1000;i++)); do ./gen > in.txt; ./sol < in.txt > out.txt; ./std < in.txt > ans.txt; diff -b out.txt ans.txt || { echo "WA on $i"; break; }; echo "AC on $i"; done
    ```
