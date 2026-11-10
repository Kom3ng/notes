#include <bits/stdc++.h>
#define rep(i,a,b) for(i32 i=(a);i<(b);i++)
#define rep1(i,a,b) rep(i,a,b+1)
using  namespace std;
using i32=int;
constexpr i32 maxn=1e5+5;
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
signed main(){
}
