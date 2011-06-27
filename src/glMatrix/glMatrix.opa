
type vec3.private = external;
type vec3 = (float, float, float);
type vec4.private = external;
type vec4 = (float, float, float, float);

type mat3 = external;
type mat4 = external;

vec3 = {{
     from_public : vec3 -> vec3.private = %% glMatrixPlugin.vec3_private_from_public %% ;
     to_public : vec3.private -> vec3 = %% glMatrixPlugin.vec3_private_to_public %% ;
     str : vec3.private -> string = %% glMatrixPlugin.vec3_str %% ;
     apply: vec3, ({f1}/{f2}/{f3}), (float -> float) -> vec3 = (src, where, f ->
       match where : ({f1}/{f2}/{f3}) with
       | {f1} -> { src with f1=f(src.f1) }
       | {f2} -> { src with f2=f(src.f2) }
       | {f3} -> { src with f3=f(src.f3) }
       end);
     get(src, switch) = match switch : ({f1}/{f2}/{f3}) with
       | {f1} -> src.f1
       | {f2} -> src.f2
       | {f3} -> src.f3
       end;
}}

vec4 = {{
     from_public : vec4 -> vec4.private = %% glMatrixPlugin.vec4_private_from_public %% ;
     to_public : vec4.private -> vec4 = %% glMatrixPlugin.vec4_private_to_public %% ;
     str : vec4.private -> string = %% glMatrixPlugin.vec4_str %% ;
}}

mat3 = {{
     str : mat3 -> string = %% glMatrixPlugin.mat3_str %%
     create : -> mat3 = %% glMatrixPlugin.mat3_create %% ;
     transpose : mat3, mat3 -> void = %% glMatrixPlugin.mat3_transpose %% ;
     to_list : mat3 -> list(float) = %% glMatrixPlugin.mat3_to_list %% ;
}}

mat4 = {{
  Low= {{
     to_list : mat4 -> list(float) = %% glMatrixPlugin.mat4_to_list %% ;
     str : mat4 -> string = %% glMatrixPlugin.mat4_str %%
     create : -> mat4 = %% glMatrixPlugin.mat4_create %% ;
     perspective : float, float, float, float, mat4 -> mat4 = %% glMatrixPlugin.mat4_perspective %% ;
     identity : mat4 -> mat4 = %% glMatrixPlugin.mat4_identity %% ;
     translate : mat4, vec3.private, mat4 -> mat4 = %% glMatrixPlugin.mat4_translate %% ;
     lookAt : vec3.private, vec3.private, vec3.private, mat4 -> mat4 = %% glMatrixPlugin.mat4_lookAt %% ;
     multiply : mat4, mat4, mat4 -> mat4 = %% glMatrixPlugin.mat4_multiply %% ;
     toInverseMat3 : mat4, mat3 -> mat3 = %% glMatrixPlugin.mat4_toInverseMat3 %% ;
     
     inverse : mat4, mat4 -> mat4 = %% glMatrixPlugin.mat4_inverse %% ;
     multiplyVec3 : mat4, vec3.private, vec3.private -> vec3.private = %% glMatrixPlugin.mat4_multiplyVec3 %% ;
     copy : mat4 -> mat4 = %% glMatrixPlugin.mat4_copy %% ;
     multiplyVec4 : mat4, vec4.private, vec4.private -> vec4.private = %% glMatrixPlugin.mat4_multiplyVec4 %% ;
     frustum : float, float, float, float, float, float, mat4 -> mat4 = %% glMatrixPlugin.mat4_frustum %% ;
     ortho : float, float, float, float, float, float, mat4 -> mat4 = %% glMatrixPlugin.mat4_ortho %% ;

     rotateX : mat4, float, mat4 -> mat4 = %% glMatrixPlugin.mat4_rotateX %% ;
     rotateY : mat4, float, mat4 -> mat4 = %% glMatrixPlugin.mat4_rotateY %% ;
     rotateZ : mat4, float, mat4 -> mat4 = %% glMatrixPlugin.mat4_rotateZ %% ;

     scale : mat4, vec3.private, mat4 -> mat4 = %% glMatrixPlugin.mat4_scale %% ;
  }}

  to_list = Low.to_list;
  str = Low.str
  create : -> mat4 = Low.create;
  identity() : mat4 = Low.identity(create());
  copy = Low.copy;
  //transpose
  inverse(mat) : mat4 = Low.inverse(mat, create());
  toInverseMat3(mat) : mat3 = Low.toInverseMat3(mat, mat3.create());
  multiply(mat, mat2) : mat4 = Low.multiply(mat, mat2, create());
  multiplyVec3(mat, vec) : vec3.private = Low.multiplyVec3(mat, vec, vec3.from_public((0.,0.,0.)));
  multiplyVec4(mat, vec) : vec4.private = Low.multiplyVec4(mat, vec, vec4.from_public((0.,0.,0.,0.)));
  translate(mat, vec) : mat4 = Low.translate(mat, vec, create());
  scale(mat, vec) : mat4 = Low.scale(mat, vec, create());
  rotateX(mat, angle) : mat4 = Low.rotateX(mat, angle, create());
  rotateY(mat, angle) : mat4 = Low.rotateY(mat, angle, create());
  rotateZ(mat, angle) : mat4 = Low.rotateZ(mat, angle, create());
  frustum(left, right, bottom, top, near, far) : mat4 = Low.frustum(left, right, bottom, top, near, far, create());
  perspective(fovy, aspect, near, far) : mat4 = Low.perspective(fovy, aspect, near, far, create());
  ortho(left, right, bottom, top, near, far) : mat4 = Low.ortho(left, right, bottom, top, near, far, create());
  lookAt(eye, center, up) : mat4 = Low.lookAt(eye, center, up, create());

}}
