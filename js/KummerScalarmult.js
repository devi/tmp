/**
 * kummer scalar multiplication - ref5
 *
 * ported from SUPERCOP 20140529
 *
 * see for details: http://bench.cr.yp.to/supercop.html
 */
var KummerScalarmult = (function() {

	 /* bitwise dance helper*/
	function bits(high, low) {
		this.high = (high + Math.floor(Math.ceil(low) / 4294967296)) >> 0;
		this.low = low >>> 0;
	};

	function mulBits(x, y) {
		var high = 0, low = 0, i;
		if ((y.low & 1) !== 0) {
			high = x.high;
			low = x.low;
		}
		for (i = 1; i < 32; i++) {
			if ((y.low & 1<<i) !== 0) {
				high += x.high << i | x.low >>> (32 - i);
				low += (x.low << i) >>> 0;
			}
		}
		for (i = 0; i < 32; i++) {
			if ((y.high & 1<<i) !== 0) {
				high += x.low << i;
			}
		}
		return new bits(high, low);
	};

	function shr(x, y) {
		if (y === 0) return x;
		if (y < 32) {
			return new bits(x.high >> y, (x.low >>> y | x.high << (32 - y)) >>> 0);
		}
		if (y < 64) {
			return new bits(x.high >> 31, (x.high >> (y - 32)) >>> 0);
		}
		if (x.high < 0) {
			return new bits(-1, 4294967295);
		}
		return new bits(0, 0);
	};

	function shl(x, y) {
		if (y === 0) return x;
		if (y < 32) {
			return new bits(x.high << y | x.low >>> (32 - y), (x.low << y) >>> 0);
		}
		if (y < 64) {
			return new bits(x.low << (y - 32), 0);
		}
		return new bits(0, 0);
	};

	function sub(x, y) {
		return new bits(x.high - y.high, x.low - y.low);
	};

	function flatten(bits) {
		return bits.high * 4294967296 + bits.low;
	};

	function mul(x, y) {
		return mulBits(new bits(0, x), new bits(0, y));
	};

	function add(x, y) {
		return new bits(x.high + y.high, x.low + y.low);
	};

	/* end bitwise helper */

	function fieldElement() {
		this.v = new Array(5);
	};

	function gfe_add(r, x, y) {
		for (var i = 0; i < 5; i++) {
			r.v[i] = (x.v[i] + y.v[i]);// >> 0;
		}
	};

	function gfe_sub(r, x, y) {
		for (var i = 0; i < 5; i++) {
			r.v[i] = (x.v[i] - y.v[i]);// >> 0;
		}
	};

	function carry(t) {
		var c = shr(t[0], 26);
		t[1] = add(t[1], c);
		t[0] = sub(t[0], shl(c, 26));

		c = shr(t[1], 25);
		t[2] = add(t[2], c);
		t[1] = sub(t[1], shl(c, 25));

		c = shr(t[2], 26);
		t[3] = add(t[3], c);
		t[2] = sub(t[2], shl(c, 26));

		c = shr(t[3], 25);
		t[4] = add(t[4], c);
		t[3] = sub(t[3], shl(c, 25));

		c = shr(t[4], 25);
		t[0] = add(t[0], c);
		t[4] = sub(t[4], shl(c, 25));

		c = shr(t[0], 26);
		t[1] = add(t[1], c);
		t[0] = sub(t[0], shl(c, 26));
	};

	function gfe_mul(r, a, b) {
		var t = [], xyz = [], t0 = [], t1 = [], t2 = [], t3 = [], t4 = [];

		xyz[1] = a.v[1] << 1 >> 0;
		xyz[2] = a.v[2] << 1 >> 0;
		xyz[3] = a.v[3] << 1 >> 0;
		xyz[4] = a.v[4] << 1 >> 0;

		t0[0] = mul(a.v[0], b.v[0]);
		t0[1] = mul(xyz[1], b.v[4]);
		t0[2] = mul(xyz[2], b.v[3]);
		t0[3] = mul(xyz[3], b.v[2]);
		t0[4] = mul(xyz[4], b.v[1]);

		t0[5] = add(t0[0], t0[1]);
		t0[6] = add(t0[5], t0[2]);
		t0[7] = add(t0[6], t0[3]);

		t[0]  = add(t0[7], t0[4]);

		t1[0] = mul(a.v[0], b.v[1]);
		t1[1] = mul(a.v[1], b.v[0]);
		t1[2] = mul(a.v[2], b.v[4]);
		t1[3] = mul(xyz[3], b.v[3]);
		t1[4] = mul(a.v[4], b.v[2]);

		t1[5] = add(t1[0], t1[1]);
		t1[6] = add(t1[5], t1[2]);
		t1[7] = add(t1[6], t1[3]);

		t[1]  = add(t1[7], t1[4]);

		t2[0] = mul(a.v[0], b.v[2]);
		t2[1] = mul(xyz[1], b.v[1]);
		t2[2] = mul(a.v[2], b.v[0]);
		t2[3] = mul(xyz[3], b.v[4]);
		t2[4] = mul(xyz[4], b.v[3]);

		t2[5] = add(t2[0], t2[1]);
		t2[6] = add(t2[5], t2[2]);
		t2[7] = add(t2[6], t2[3]);

		t[2]  = add(t2[7], t2[4]);

		t3[0] = mul(a.v[0], b.v[3]);
		t3[1] = mul(a.v[1], b.v[2]);
		t3[2] = mul(a.v[2], b.v[1]);
		t3[3] = mul(a.v[3], b.v[0]);
		t3[4] = mul(a.v[4], b.v[4]);

		t3[5] = add(t3[0], t3[1]);
		t3[6] = add(t3[5], t3[2]);
		t3[7] = add(t3[6], t3[3]);

		t[3]  = add(t3[7], t3[4]);

		t4[0] = mul(a.v[0], b.v[4]);
		t4[1] = mul(xyz[1], b.v[3]);
		t4[2] = mul(a.v[2], b.v[2]);
		t4[3] = mul(xyz[3], b.v[1]);
		t4[4] = mul(a.v[4], b.v[0]);

		t4[5] = add(t4[0], t4[1]);
		t4[6] = add(t4[5], t4[2]);
		t4[7] = add(t4[6], t4[3]);

		t[4]  = add(t4[7], t4[4]);

		carry(t);

		r.v[0] = flatten(t[0]) >> 0;
		r.v[1] = flatten(t[1]) >> 0;
		r.v[2] = flatten(t[2]) >> 0;
		r.v[3] = flatten(t[3]) >> 0;
		r.v[4] = flatten(t[4]) >> 0;
	};

	function gfe_square(r, x) {
		gfe_mul(r, x ,x);
	};

	function gfe_mulConst(r, a, cst) {
		var t = [];

		t[0] = mul(a.v[0], cst);
		t[1] = mul(a.v[1], cst);
		t[2] = mul(a.v[2], cst);
		t[3] = mul(a.v[3], cst);
		t[4] = mul(a.v[4], cst);

		carry(t);

		r.v[0] = flatten(t[0]) >> 0;
		r.v[1] = flatten(t[1]) >> 0;
		r.v[2] = flatten(t[2]) >> 0;
		r.v[3] = flatten(t[3]) >> 0;
		r.v[4] = flatten(t[4]) >> 0;
	};

	function gfe_invert(r, x) {
		var x2 = new fieldElement(), x3 = new fieldElement(), x6 = new fieldElement(),
			x12 = new fieldElement(), x15 = new fieldElement(), x30 = new fieldElement(),
			x_5_0 = new fieldElement(), x_10_0 = new fieldElement(), x_20_0 = new fieldElement(),
			x_40_0 = new fieldElement(), x_80_0 = new fieldElement(), x_120_0 = new fieldElement(),
			x_125_0 = new fieldElement(), t = new fieldElement(), i = 0;

		gfe_square(x2, x);                     /*  2 */
		gfe_mul(x3,x2,x);                     /*  3 mult */
		gfe_square(x6,x3);                    /*  6 */
		gfe_square(x12,x6);                   /*  12 */
		gfe_mul(x15,x12,x3);                 /*  15 mult */
		gfe_square(x30, x15);                 /*  30 */
		gfe_mul(x_5_0, x30, x);               /*  31 = 2^5-1 mult */

		gfe_square(t, x_5_0);
		for(i=6;i<10;i++) gfe_square(t, t);   /*  2^10-2^5 */
		gfe_mul(x_10_0,t,x_5_0);             /*  2^10-1 mult */

		gfe_square(t, x_10_0);
		for(i=11;i<20;i++) gfe_square(t, t);  /*  2^20-2^10 */
		gfe_mul(x_20_0,t,x_10_0);            /*  2^20-1 mult */

		gfe_square(t, x_20_0);
		for(i=21;i<40;i++) gfe_square(t, t);  /*  2^40-2^20 */
		gfe_mul(x_40_0,t,x_20_0);            /*  2^40-1 mult */

		gfe_square(t, x_40_0);
		for(i=41;i<80;i++) gfe_square(t, t);  /*  2^80-2^40 */
		gfe_mul(x_80_0,t,x_40_0);            /*  2^80-1 mult */

		gfe_square(t, x_80_0);
		for(i=81;i<120;i++) gfe_square(t, t); /*  2^120-2^40 */
		gfe_mul(x_120_0,t,x_40_0);           /*  2^80-1 mult */

		gfe_square(t, x_120_0);
		for(i=121;i<125;i++) gfe_square(t, t);/*  2^120-2^40 */
		gfe_mul(x_125_0, t, x_5_0);

		gfe_square(t, x_125_0);               /* 2^126-2^1 */
		gfe_square(t, t);                     /* 2^127-2^2 */
		gfe_mul(r,t,x);                        /* 2^127-3 */
	};

	function gfe_hadamard(r0, r1, r2, r3) {
		var a = new fieldElement(), b = new fieldElement(),
			c = new fieldElement(), d = new fieldElement();

		gfe_add(a, r0, r1);
		gfe_add(b, r2, r3);
		gfe_sub(c, r0, r1);
		gfe_sub(d, r2, r3);

		gfe_add(r0, a, b);
		gfe_sub(r1, a, b);
		gfe_add(r2, c, d);
		gfe_sub(r3, c, d);
	};

	function ladderStep(work) {
		gfe_hadamard(work[7], work[8], work[9], work[10]);
		gfe_hadamard(work[3], work[4], work[5], work[ 6]);

		gfe_mul(work[ 7], work[ 7], work[3]);
		gfe_mul(work[ 8], work[ 8], work[4]);
		gfe_mul(work[ 9], work[ 9], work[5]);
		gfe_mul(work[10], work[10], work[6]);

		gfe_square(work[3], work[3]);
		gfe_square(work[4], work[4]);
		gfe_square(work[5], work[5]);
		gfe_square(work[6], work[6]);

		gfe_mulConst(work[ 7], work[ 7], 9163);
		gfe_mulConst(work[ 8], work[ 8], -27489);
		gfe_mulConst(work[ 9], work[ 9], -17787);
		gfe_mulConst(work[10], work[10], -6171);

		gfe_mulConst(work[3], work[3], 9163);
		gfe_mulConst(work[4], work[4], -27489);
		gfe_mulConst(work[5], work[5], -17787);
		gfe_mulConst(work[6], work[6], -6171);

		gfe_hadamard(work[7], work[8], work[9], work[10]);
		gfe_hadamard(work[3], work[4], work[5], work[ 6]);

		gfe_square(work[ 7], work[ 7]);
		gfe_square(work[ 8], work[ 8]);
		gfe_square(work[ 9], work[ 9]);
		gfe_square(work[10], work[10]);

		gfe_square(work[3], work[3]);
		gfe_square(work[4], work[4]);
		gfe_square(work[5], work[5]);
		gfe_square(work[6], work[6]);

		gfe_mul(work[ 8], work[ 8], work[0]);
		gfe_mul(work[ 9], work[ 9], work[1]);
		gfe_mul(work[10], work[10], work[2]);

		gfe_mulConst(work[3], work[3], -1254);
		gfe_mulConst(work[4], work[4], 627);
		gfe_mulConst(work[5], work[5], 726);
		gfe_mulConst(work[6], work[6], 4598);
	};

	function cswap4x(x, xpos, y, ypos, b) {
		var db = -b, t, xp, yp;
		for(var i=0;i<4;++i) {
			xp = i+xpos;
			yp = i+ypos;
			for (var j=0;j<5;j++) {
				t = (x[xp].v[j] ^ y[yp].v[j]) >> 0;
				t &= db;
				x[xp].v[j] = (x[xp].v[j] ^ t) >> 0;
				y[yp].v[j] = (y[yp].v[j] ^ t) >> 0;
			}
		}
	};

	function ladder(work, scalar) {
		var j = 2, bit;
		for (var i = 31; i >= 0; --i) {
			for (j = j; j >= 0; --j) {
				bit = (scalar[i]>>j) & 1;
				cswap4x(work, 3, work, 7, bit);
				ladderStep(work);
				cswap4x(work, 3, work, 7, bit);
			}
			j = 7;
		}
	};

	function gfe_unpack(r, b) {
		r.v[0] = (b[0] & 0xff);
		r.v[0] |= (b[1] & 0xff) << 8;
		r.v[0] |= (b[2] & 0xff) << 16;
		r.v[0] |= ((b[3]&3) & 0xff) << 24;

		r.v[1] = (b[3] & 0xff) >> 2;
		r.v[1] |= (b[4] & 0xff) << 6;
		r.v[1] |= (b[5] & 0xff) << 14;
		r.v[1] |= ((b[6]&7) & 0xff) << 22;

		r.v[2] = (b[6] & 0xff) >> 3;
		r.v[2] |= (b[7] & 0xff) << 5;
		r.v[2] |= (b[8] & 0xff) << 13;
		r.v[2] |= ((b[9]&31) & 0xff) << 21;

		r.v[3] = (b[9] & 0xff) >> 5;
		r.v[3] |= (b[10] & 0xff) << 3;
		r.v[3] |= (b[11] & 0xff) << 11;
		r.v[3] |= ((b[12]&63) & 0xff) << 19;

		r.v[4] = (b[12] & 0xff) >> 6;
		r.v[4] |= (b[13] & 0xff) << 2;
		r.v[4] |= (b[14] & 0xff) << 10;
		r.v[4] |= ((b[15]&127) & 0xff) << 18;
	};

	function gfe_pack(r, x) {
		var c, t = x;
		// i think x is small enough to do the bitwise dance
		t.v[0] += ((1<<28)-4);
		c = t.v[0] >> 26;
		t.v[1] = t.v[1] + c;
		c <<= 26;
		t.v[0]  = t.v[0] - c;
		
		t.v[1] += ((1<<27)-4);
		c = t.v[1] >> 25;
		t.v[2] = t.v[2] + c;
		c <<= 25;
		t.v[1]  = t.v[1] - c;

		t.v[2] += ((1<<28)-4);
		c = t.v[2] >> 26;
		t.v[3] = t.v[3] + c;
		c <<= 26;
		t.v[2]  = t.v[2] - c;

		t.v[3] += ((1<<27)-4);
		c = t.v[3] >> 25;
		t.v[4] = t.v[4] + c;
		c <<= 25;
		t.v[3]  = t.v[3] - c;
		
		t.v[4] += ((1<<27)-4);
		c = t.v[4] >> 25;
		t.v[0] += c;
		c <<= 25;
		t.v[4] -= c;

		c = t.v[0] >> 26;
		t.v[1] += c;
		c <<= 26;
		t.v[0] -= c;

		c = t.v[1] >> 25;
		t.v[2] += c;
		c <<= 25;
		t.v[1] -= c;

		c = t.v[2] >> 26;
		t.v[3] += c;
		c <<= 26;
		t.v[2] -= c;

		c = t.v[3] >> 25;
		t.v[4] += c;
		c <<= 25;
		t.v[3] -= c;

		c = t.v[4] >> 25;
		t.v[0] += c;
		c <<= 25;
		t.v[4] -= c;

		c = t.v[0] >> 26;
		t.v[1] += c;
		c <<= 26;
		t.v[0] -= c;

		r.push(t.v[0]     & 0xff);
		r.push((t.v[0]>>8) & 0xff);
		r.push((t.v[0]>>16)& 0xff);
		r.push((t.v[0]>>24) | ((t.v[1] & 0x3f) << 2));
		r.push((t.v[1]>>6) & 0xff);
		r.push((t.v[1]>>14)& 0xff);
		r.push((t.v[1]>>22) | ((t.v[2] & 0x1f) << 3));
		r.push((t.v[2]>>5) & 0xff);
		r.push((t.v[2]>>13) & 0xff);
		r.push((t.v[2]>>21) | ((t.v[3] & 0x7) << 5));
		r.push((t.v[3]>>3) & 0xff);
		r.push((t.v[3]>>11) & 0xff);
		r.push((t.v[3]>>19) | ((t.v[4] & 0x3) << 6));
		r.push((t.v[4]>>2) & 0xff);
		r.push((t.v[4]>>10) & 0xff);
		r.push((t.v[4]>>18) & 0x7f);
	};

	return function(input, scalar) {
		if (typeof scalar === "undefined") {
			// 48 byte
			var basepoint = [6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x68,0x30,0x1e,0x6b,0x4d,0xaf,0xc7,0x56,0x9d,0x1f,0xa7,0xf8,0x71,0x39,0x37,0x6b,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
			return new KummerScalarmult(input, basepoint);
		}
		// simple check
		if ((typeof input !== "object") || (typeof scalar !== "object")) {
			throw new Error('input/scalar must be an (array) object');
		}
		if ((input.length < 32) || (scalar.length < 48)) {
			throw new Error('input must be 32 byte, scalar must be 48 byte');
		}

		var work = [], out = [];
		var yz = new fieldElement(), yzt = new fieldElement(), 
			r = new fieldElement(), tr = new fieldElement();

		for (var i =0;i < 11;++i) work[i] = new fieldElement();

		gfe_unpack(work[0], scalar);
		gfe_unpack(work[1], scalar.slice(16));
		gfe_unpack(work[2], scalar.slice(32));

		work[3].v[0] =  11;
		work[4].v[0] = -22;
		work[5].v[0] = -19;
		work[6].v[0] =  -3;

		gfe_mul(work[10], work[ 0], work[1]);
		gfe_mul(work[ 9], work[ 0], work[2]);
		gfe_mul(work[ 8], work[ 1], work[2]);
		gfe_mul(work[ 7], work[10], work[2]);

		ladder(work, input);

		gfe_mul(yz, work[4], work[5]);
		gfe_mul(yzt, yz, work[6]);
		gfe_invert(r,yzt);
		gfe_mul(r, r, work[3]);
		gfe_mul(tr, r, work[6]);
		gfe_mul(work[5], work[5], tr);
		gfe_pack(out, work[5]);
		gfe_mul(work[4], work[4], tr);
		gfe_pack(out, work[4]);
		gfe_mul(yz, yz ,r);
		gfe_pack(out, yz);

		return out;
	};

})();

//---------- test ----------------------------------------------------//

function randombytes(n) {
	var out = [], values;
	if (typeof window !== 'undefined' && window.crypto) {
		values = new Uint8Array(n);
		window.crypto.getRandomValues(values);
	} else if (typeof require !== 'undefined') {
		var prng = require('crypto');
		values = prng ? prng.randomBytes(n) : null;
	} else {
		throw new Error('no PRNG');
	}
	if (!values || values.length !== n) {
		throw new Error('PRNG failed');
	}
	for (var i = 0; i < values.length; i++) {
		out[i] = values[i];
	}
	return out;
}

function fromString(s) {
	var arr = [];
	for (var i = 0,l = s.length;i < l;++i) {
		var c = s.charCodeAt(i);
		if (c < 128) {
			arr.push(c);
		} else if (c > 127 && c < 2048) {
			arr.push((c >> 6) | 192);
			arr.push((c & 63) | 128);
		} else {
			arr.push((c >> 12) | 224);
			arr.push(((c >> 6) & 63) | 128);
			arr.push((c & 64) | 128);
		}
	}
	return arr;
};

function fromHex(h) {
	h.replace(' ', '').replace('\x', '');
	var out = [], len = h.length, w = '';
	for (var i = 0; i < len; i += 2) {
		w = h[i];
		if (((i+1) >= len) || typeof h[i+1] === 'undefined') {
			w += '0';
		} else {
			w += h[i+1];
		}
		out.push(parseInt(w, 16));
	}
	return out;
};

function toHex(arr) {
	var hex = [
		'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
		'a', 'b', 'c', 'd', 'e', 'f'
	];
	var out = '';
	for (var i = 0, l = arr.length;i < l;++i) {
		out += hex[(arr[i] >> 4) & 0xf];
		out += hex[arr[i] & 0xf];
	}
	return out;
};


var aliceKey    = randombytes(32);//fromHex("b199e432eb45590eab4054930738bcbe34d5c694a7e7c043aea2a980a094591c");
var alicePublic = KummerScalarmult(aliceKey);

var bobKey    = randombytes(32);//fromHex("d8a326178d98cda59fff281f04357cbce73c98dc5362015f5a8d811a7324ac6d");
var bobPublic = KummerScalarmult(bobKey);

var aliceSharedSecret = KummerScalarmult(aliceKey, bobPublic);

var bobSharedSecret   = KummerScalarmult(bobKey, alicePublic);

console.log('alice secret key    :', toHex(aliceKey));
console.log('alice public key    :', toHex(alicePublic));

console.log('bob secret key      :', toHex(bobKey));
console.log('bob public key      :', toHex(bobPublic));

console.log('alice shared secret :', toHex(aliceSharedSecret));
console.log('bob shared secret   :', toHex(bobSharedSecret));

//phantom.exit();
