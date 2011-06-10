##opa-type list('a)

/* ---- vec3 ---- */

##extern-type vec3.private
##opa-type vec3

##register vec3_private_from_public : vec3 -> vec3.private
##args(ovec)
{ return [ ovec.f1, ovec.f2, ovec.f3 ]; }

##register vec3_private_to_public : vec3.private -> vec3
##args(vec)
{ return { f1: vec[0], f2: vec[1] , f3: vec[2] }; }

##register vec3_str : vec3.private -> string
##args(vec)
{ return vec3.str(vec); }

/* ---- vec4 ---- */

##extern-type vec4.private
##opa-type vec4

##register vec4_private_from_public : vec4 -> vec4.private
##args(ovec)
{ return [ ovec.f1, ovec.f2, ovec.f3, ovec.f4 ]; }

##register vec4_private_to_public : vec4.private -> vec4
##args(vec)
{ return { f1: vec[0], f2: vec[1] , f3: vec[2], f4: vec[3] }; }

##register vec4_str : vec4.private -> string
##args(vec)
{ return '[' + vec[0] + ', ' + vec[1] + ', ' + vec[2] + ', ' + vec[3] + ']'; }


/* ---- mat3 ---- */

##extern-type mat3

##register mat3_create : -> mat3
##args()
{ return mat3.create(); }

##register mat3_transpose : mat3, mat3 -> void
##args(mat, dest)
{ return mat3.transpose(mat, dest); }

##register mat3_to_list : mat3 -> opa[ list(float) ]
##args(src)
{ return js2list([src[0],src[1],src[2],src[3],src[4],src[5],src[6],src[7],src[8]].reverse()); }

##register mat3_str : mat3 -> string
##args(mat)
{ return mat3.str(mat); }


/* ---- mat4 ---- */

##extern-type mat4

##register mat4_to_list : mat4 -> opa[ list(float) ]
##args(src)
{ return js2list([src[0],src[1],src[2],src[3],src[4],src[5],src[6],src[7],src[8],src[9],src[10],src[11],src[12],src[13],src[14],src[15]].reverse()); }

##register mat4_create : -> mat4
##args()
{ return mat4.create(); }

##register mat4_perspective : float, float, float, float, mat4 -> void
##args(fovy, aspect, near, far, dest)
{ mat4.perspective(fovy, aspect, near, far, dest); }

##register mat4_identity : mat4 -> void
##args(dest)
{ mat4.identity(dest); }

##register mat4_translate : mat4, vec3.private, mat4 -> void
##args(mat, vec, dest)
{ mat4.translate(mat, vec, dest); }

##register mat4_str : mat4 -> string
##args(mat)
{ return mat4.str(mat); }

##register mat4_lookAt : vec3.private, vec3.private, vec3.private, mat4 -> void
##args(eye, center, up, dest)
{ return mat4.lookAt(eye, center, up, dest); }

##register mat4_multiply : mat4, mat4, mat4 -> void
##args(mat, mat2, dest)
{ return mat4.multiply(mat, mat2, dest); }

##register mat4_toInverseMat3 : mat4, mat3 -> void
##args(mat, dest)
{ mat4.toInverseMat3(mat, dest); }

##register mat4_inverse : mat4, mat4 -> void
##args(mat, dest)
{ return mat4.inverse(mat, dest); }

##register mat4_multiplyVec3 : mat4, vec3.private, vec3.private -> void
##args(mat, vec, dest)
{ return mat4.multiplyVec3(mat, vec, dest); }

##register mat4_copy : mat4 -> mat4
##args(mat)
{ return mat4.create(mat); }

##register mat4_multiplyVec4 : mat4, vec4.private, vec4.private -> void
##args(mat, vec, dest)
{ return mat4.multiplyVec4(mat, vec, dest); }
