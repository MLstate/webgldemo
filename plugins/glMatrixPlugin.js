##opa-type list('a)

##extern-type mat4
##extern-type vec3.private
##opa-type vec3

##register to_list : mat4 -> opa[ list(float) ]
##args(src)
{ return js2list([src[0],src[1],src[2],src[3],src[4],src[5],src[6],src[7],src[8],src[9],src[10],src[11],src[12],src[13],src[14],src[15]].reverse()); }

##register create : -> mat4
##args()
{ return mat4.create(); }

##register perspective : float, float, float, float, mat4 -> void
##args(fovy, aspect, near, far, dest)
{ mat4.perspective(fovy, aspect, near, far, dest); }

##register identity : mat4 -> void
##args(dest)
{ mat4.identity(dest); }

##register vec3_private_from_public : vec3 -> vec3.private
##args(ovec)
{ return [ ovec.f1, ovec.f2, ovec.f3 ]; }

##register translate : mat4, vec3.private, mat4 -> void
##args(mat, vec, dest)
{ mat4.translate(mat, vec, dest); }

##register str : mat4 -> string
##args(mat)
{ return mat4.str(mat); }

##register lookAt : vec3.private, vec3.private, vec3.private, mat4 -> void
##args(eye, center, up, dest)
{ return mat4.lookAt(eye, center, up, dest); }

##register multiply : mat4, mat4, mat4 -> void
##args(mat, mat2, dest)
{ return mat4.multiply(mat, mat2, dest); }

##extern-type mat3

##register toInverseMat3 : mat4, mat3 -> void
##args(mat, dest)
{ mat4.toInverseMat3(mat, dest); }

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
