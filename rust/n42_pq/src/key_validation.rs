// Validate a Falcon-512 secret's NTRU relation before handing it to PQClean.
// This prevents malformed imports from entering the signing sampler.
const N: usize = 512;
const Q: i64 = 12289;
fn pow(mut x: i64, mut n: i64) -> i64 {
    let mut r = 1;
    while n > 0 {
        if n & 1 != 0 {
            r = r * x % Q;
        }
        x = x * x % Q;
        n >>= 1;
    }
    r
}
pub fn valid(raw: &[u8]) -> bool {
    if raw.len() != 1281 || raw[0] != 0x59 {
        return false;
    }
    let mut polys = [[0i64; N]; 2];
    for k in 0..2 {
        let (mut acc, mut bits, mut pos) = (0u32, 0usize, 1 + k * 384);
        for j in 0..N {
            while bits < 6 {
                acc = acc.wrapping_shl(8) | raw[pos] as u32;
                pos += 1;
                bits += 8;
            }
            bits -= 6;
            let mut v = ((acc >> bits) & 63) as i64;
            if v >= 32 {
                v -= 64;
            }
            if v == -32 {
                return false;
            }
            polys[k][j] = v;
        }
    }
    let mut big_f = [0i64; N];
    for j in 0..N {
        big_f[j] = (raw[769 + j] as i8) as i64;
        if big_f[j] == -128 {
            return false;
        }
    }
    let Some(root) = (2..Q).map(|x| pow(x, 12)).find(|r| pow(*r, 512) == Q - 1) else {
        return false;
    };
    let mut vals = [0i64; N];
    let mut points = [0i64; N];
    for i in 0..N {
        let x = pow(root, (2 * i + 1) as i64);
        points[i] = x;
        let (mut f, mut g, mut p) = (0, 0, 1);
        for j in 0..N {
            f = (f + polys[0][j] * p).rem_euclid(Q);
            g = (g + polys[1][j] * p).rem_euclid(Q);
            p = p * x % Q;
        }
        if f == 0 {
            return false;
        }
        vals[i] = g * pow(f, Q - 2) % Q;
    }
    let mut h = [0i64; N];
    let inv_n = pow(512, Q - 2);
    for i in 0..N {
        let (mut p, x) = (1, pow(points[i], Q - 2));
        for j in 0..N {
            h[j] = (h[j] + vals[i] * p) % Q;
            p = p * x % Q;
        }
    }
    for v in &mut h {
        *v = *v * inv_n % Q;
    }
    let mut big_g = [0i64; N];
    for i in 0..N {
        let mut sum = 0;
        for j in 0..N {
            let (k, sgn) = if j > i { (i + N - j, -1) } else { (i - j, 1) };
            sum = (sum + sgn * h[j] * big_f[k]).rem_euclid(Q);
        }
        if sum > Q / 2 {
            sum -= Q;
        }
        if !(-127..=127).contains(&sum) {
            return false;
        }
        big_g[i] = sum;
    }
    for i in 0..N {
        let mut sum = 0;
        for j in 0..N {
            let (k, sgn) = if j > i { (i + N - j, -1) } else { (i - j, 1) };
            sum += sgn * (polys[0][j] * big_g[k] - polys[1][j] * big_f[k]);
        }
        if sum != if i == 0 { Q } else { 0 } {
            return false;
        }
    }
    true
}
