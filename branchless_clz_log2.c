#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

/* ---- RISC-V friendly CLZ / LOG2 --------------------------------------- */
/* 若是 RISC-V（含 Zbb），使用單指令 clz；否則退回到 __builtin_clz。 */
static inline unsigned clz32(uint32_t x) {
#if defined(__riscv)
    unsigned r;
    /* 對應 RISC-V Zbb: clz rd, rs */
    __asm__ volatile ("clz %0, %1" : "=r"(r) : "r"(x));
    return r;
#else
    /* 在 GCC/Clang 上會對應為目標架構的 clz 指令或最佳實作 */
    return (unsigned)__builtin_clz(x);
#endif
}

/* floor(log2(x))，假設 x > 0。對 RISC-V 會編成: clz + 常數相減。 */
static inline unsigned flog2_u32(uint32_t x) {
    return 31u - clz32(x);
}

/* ---- uf8: 4-bit exponent + 4-bit mantissa ------------------------------ */
/*
   編碼/解碼規格（不變）：
   decoded(value) = (mantissa << exponent) + 16 * ((1 << exponent) - 1)
   其中 exponent ∈ [0, 15], mantissa ∈ [0, 15]
*/

/* Decode uf8 -> uint32_t：以更直接的 offset 公式 */
static inline uint32_t uf8_decode(uint8_t fl)
{
    uint32_t m = fl & 0x0Fu;
    uint32_t e = fl >> 4;
    uint32_t offset = ((1u << e) - 1u) << 4;  /* 16*((1<<e)-1) */
    return (m << e) + offset;
}

/* Encode uint32_t -> uf8（優化版）
   關鍵：對所有 v >= 16，有 e = floor_log2(v + 16) - 4
   再做 e = min(e, 15)。mantissa 以公式直接求得。 */
static inline uint8_t uf8_encode(uint32_t v)
{
    if (v < 16u)            /* 小值直接回傳（e=0, m=v） */
        return (uint8_t)v;

    /* floor_log2(v+16) - 4；避免 overflow，v 為 32-bit，v+16 仍安全 */
    uint32_t t = v + 16u;
    unsigned l2 = flog2_u32(t);               /* >= 4 */
    unsigned e = l2 - 4u;
    if (e > 15u) e = 15u;                     /* clamp */

    uint32_t offset = ((1u << e) - 1u) << 4;  /* 16*((1<<e)-1) */
    uint32_t m = (v - offset) >> e;           /* 0..15 */

    return (uint8_t)((e << 4) | (m & 0x0Fu));
}

/* ---- 小型 use case: 用 CLZ 做 branchless log2 ------------------------- */
/* 回傳 floor(log2(x))；x>0。示範如何把 CLZ 直接轉成 log2。 */
static inline unsigned log2_branchless(uint32_t x) {
    /* RISC-V: 通常編成一條 clz + 一條加/減法 */
    return flog2_u32(x);
}

/* ---- 測試 -------------------------------------------------------------- */
static bool test_roundtrip(void)
{
    int32_t prev = -1;
    bool ok = true;

    for (int i = 0; i < 256; i++) {
        uint8_t  fl = (uint8_t)i;
        uint32_t v  = uf8_decode(fl);
        uint8_t  fl2 = uf8_encode(v);

        if (fl != fl2) {
            printf("%02x: decode=%u re-encode=%02x\n", fl, v, fl2);
            ok = false;
        }
        if (v <= (uint32_t)prev) {
            printf("%02x: value %u <= previous %d\n", fl, v, prev);
            ok = false;
        }
        prev = (int32_t)v;
    }
    return ok;
}

static bool test_log2_demo(void)
{
    /* 驗證 log2_branchless 對於 1,2,3,4,... 的合理性 */
    bool ok = true;
    for (uint32_t x = 1; x < (1u << 20); x <<= 1) {
        unsigned l2 = log2_branchless(x);
        if (l2 != flog2_u32(x)) {
            printf("log2 mismatch at %u: %u vs %u\n", x, l2, flog2_u32(x));
            ok = false;
        }
        /* 也測幾個非 2 的冪次 */
        if (x + 7 < (1u << 20)) {
            unsigned a = log2_branchless(x + 7);
            unsigned b = flog2_u32(x + 7);
            if (a != b) {
                printf("log2 mismatch at %u: %u vs %u\n", x + 7, a, b);
                ok = false;
            }
        }
    }
    return ok;
}

int main(void)
{
    bool ok = true;
    ok &= test_roundtrip();
    ok &= test_log2_demo();

    if (ok) {
        printf("All tests passed.\n");
        return 0;
    }
    return 1;
}
